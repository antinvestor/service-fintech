// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"context"
	"errors"
	"net/http"
	"os"

	"buf.build/gen/go/antinvestor/identity/connectrpc/go/identity/v1/identityv1connect"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	"github.com/antinvestor/common/v2"
	"github.com/antinvestor/common/v2/connection"
	"github.com/antinvestor/common/v2/servicecatalog"
	"github.com/antinvestor/service-trustage/client/workflows"
	"github.com/antinvestor/service-trustage/gen/go/workflow/v1/workflowv1connect"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/config"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"
	"github.com/pitabwire/util"

	aconfig "github.com/antinvestor/service-fintech/apps/stawi/config"

	// Stawi domain (Tenure, Period, Motion, Infraction, LoanWindow, LoanOffer).
	stawibusiness "github.com/antinvestor/service-fintech/apps/stawi/service/business"
	stawievents "github.com/antinvestor/service-fintech/apps/stawi/service/events"
	"github.com/antinvestor/service-fintech/apps/stawi/service/handlers"
	stawimodels "github.com/antinvestor/service-fintech/apps/stawi/service/models"
	stawirepo "github.com/antinvestor/service-fintech/apps/stawi/service/repository"

	// Funding domain (LoanFunding, FundingAllocation, InvestorAccount, FundingTranche).
	fundingbusiness "github.com/antinvestor/service-fintech/apps/funding/service/business"
	fundingevents "github.com/antinvestor/service-fintech/apps/funding/service/events"
	fundingmodels "github.com/antinvestor/service-fintech/apps/funding/service/models"
	fundingrepo "github.com/antinvestor/service-fintech/apps/funding/service/repository"

	// Operations domain.
	opsbusiness "github.com/antinvestor/service-fintech/apps/operations/service/business"
	opsevents "github.com/antinvestor/service-fintech/apps/operations/service/events"
	opsrepo "github.com/antinvestor/service-fintech/apps/operations/service/repository"

	// Platform clients.
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/limits/consumer"

	fevents "github.com/pitabwire/frame/v2/events"
)

var errCurrentPeriodNotFound = errors.New("current period not found")

type appRepositories struct {
	tenure            stawirepo.TenureRepository
	period            stawirepo.PeriodRepository
	motion            stawirepo.MotionRepository
	infraction        stawirepo.InfractionRepository
	loanWindow        stawirepo.LoanWindowRepository
	loanOffer         stawirepo.LoanOfferRepository
	loanFunding       fundingrepo.LoanFundingRepository
	fundingAllocation fundingrepo.FundingAllocationRepository
	fundingTranche    fundingrepo.FundingTrancheRepository
	investorAccount   fundingrepo.InvestorAccountRepository
	transferOrder     opsrepo.TransferOrderRepository
	obligation        opsrepo.ObligationRepository
	incomingPayment   opsrepo.IncomingPaymentRepository
	accountRef        opsrepo.AccountRefRepository
	cbsSyncRecord     opsrepo.CBSSyncRecordRepository
}

type appBusinesses struct {
	group         stawibusiness.ClientGroupBusiness
	membership    stawibusiness.MembershipBusiness
	tenure        stawibusiness.TenureBusiness
	period        stawibusiness.PeriodBusiness
	loanWindow    stawibusiness.LoanWindowBusiness
	loanOffer     stawibusiness.LoanOfferBusiness
	funding       fundingbusiness.FundingAllocationBusiness
	payment       opsbusiness.PaymentRoutingBusiness
	transferOrder opsbusiness.TransferOrderBusiness
	obligation    opsbusiness.ObligationBusiness
}

func main() {
	tmpCtx := context.Background()

	cfg, err := config.LoadWithOIDC[aconfig.StawiConfig](tmpCtx)
	if err != nil {
		util.Log(tmpCtx).With("err", err).Error("could not process configs")
		return
	}

	if cfg.Name() == "" {
		cfg.ServiceName = "service_stawi"
	}

	ctx, svc := frame.NewServiceWithContext(
		tmpCtx,
		frame.WithConfig(&cfg),
		frame.WithDatastore(),
	)
	defer svc.Stop(ctx)
	log := util.Log(ctx)

	dbManager := svc.DatastoreManager()
	workMan := svc.WorkManager()
	evtsMan := svc.EventsManager()

	// Handle database migration if requested (stawi domain only)
	if handleDatabaseMigration(ctx, dbManager, cfg) {
		return
	}

	// Get database pool
	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	if dbPool == nil {
		log.Error("Database pool is nil - check DATABASE_PRIMARY_URL environment variable")
		return
	}

	// --- Identity SDK client (for ClientGroup + Membership) ---
	identityCli, idErr := setupIdentityClient(ctx, cfg)
	if idErr != nil {
		log.WithError(idErr).Warn("main -- Could not setup identity client")
	}

	// --- Platform clients ---
	platformClients, pcErr := clients.NewPlatformClients(ctx, &cfg, cfg.ServiceEndpoints())
	if pcErr != nil {
		log.WithError(pcErr).Warn("main -- Some platform clients could not be initialised")
	}

	// Limits client. Optional — when LimitsServiceURI is empty, SetupClient
	// returns nil and the gate is disabled at runtime regardless of the config flag.
	limitsCli, limitsErr := setupLimitsClient(ctx, cfg)
	if limitsErr != nil {
		log.WithError(limitsErr).
			Warn("main -- Could not setup limits client, limits gate will be disabled")
	}

	repos := initRepositories(ctx, dbPool, workMan)
	biz := initBusinesses(ctx, evtsMan, identityCli, platformClients, repos, limitsCli, cfg)
	mux := buildWorkflowMux(platformClients, biz)
	serviceOptions := buildServiceOptions(ctx, mux, repos)

	svc.Init(ctx, serviceOptions...)

	err = svc.Run(ctx, "")
	if err != nil {
		log.WithError(err).Fatal("could not run Server")
	}
}

func initRepositories(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) appRepositories {
	return appRepositories{
		tenure:            stawirepo.NewTenureRepository(ctx, dbPool, workMan),
		period:            stawirepo.NewPeriodRepository(ctx, dbPool, workMan),
		motion:            stawirepo.NewMotionRepository(ctx, dbPool, workMan),
		infraction:        stawirepo.NewInfractionRepository(ctx, dbPool, workMan),
		loanWindow:        stawirepo.NewLoanWindowRepository(ctx, dbPool, workMan),
		loanOffer:         stawirepo.NewLoanOfferRepository(ctx, dbPool, workMan),
		loanFunding:       fundingrepo.NewLoanFundingRepository(ctx, dbPool, workMan),
		fundingAllocation: fundingrepo.NewFundingAllocationRepository(ctx, dbPool, workMan),
		fundingTranche:    fundingrepo.NewFundingTrancheRepository(ctx, dbPool, workMan),
		investorAccount:   fundingrepo.NewInvestorAccountRepository(ctx, dbPool, workMan),
		transferOrder:     opsrepo.NewTransferOrderRepository(ctx, dbPool, workMan),
		obligation:        opsrepo.NewObligationRepository(ctx, dbPool, workMan),
		incomingPayment:   opsrepo.NewIncomingPaymentRepository(ctx, dbPool, workMan),
		accountRef:        opsrepo.NewAccountRefRepository(ctx, dbPool, workMan),
		cbsSyncRecord:     opsrepo.NewCBSSyncRecordRepository(ctx, dbPool, workMan),
	}
}

func initBusinesses(
	ctx context.Context,
	evtsMan fevents.Manager,
	identityCli identityv1connect.IdentityServiceClient,
	platformClients *clients.PlatformClients,
	repos appRepositories,
	limitsCli limitsv1connect.LimitsServiceClient,
	cfg aconfig.StawiConfig,
) appBusinesses {
	groupBiz := stawibusiness.NewClientGroupBusiness(ctx, identityCli, platformClients)
	membershipBiz := stawibusiness.NewMembershipBusiness(ctx, identityCli)
	tenureBiz := stawibusiness.NewTenureBusiness(ctx, evtsMan, identityCli, repos.tenure, repos.period)
	periodBiz := stawibusiness.NewPeriodBusiness(ctx, evtsMan, repos.tenure, repos.period)
	_ = stawibusiness.NewMotionBusiness(ctx, evtsMan, repos.motion)

	loanWindowBiz := stawibusiness.NewLoanWindowBusiness(ctx, evtsMan, repos.loanWindow)
	loanOfferBiz := stawibusiness.NewLoanOfferBusiness(
		ctx, evtsMan, repos.loanOffer, repos.loanWindow, identityCli, platformClients,
		limitsCli, cfg.LimitsGateEnabledStawiLoanDisbursement, cfg.LimitsGateModeStawiLoanDisbursement,
	)
	fundingBiz := fundingbusiness.NewFundingAllocationBusiness(
		ctx,
		evtsMan,
		repos.loanFunding,
		repos.fundingAllocation,
		&loanOfferAdapter{repo: repos.loanOffer},
		repos.investorAccount,
		repos.fundingTranche,
		platformClients,
	)

	periodAdapter := &periodAdapter{repo: repos.period}
	loanFundingAdapter := &loanFundingAdapter{repo: repos.loanFunding}
	fundingTrancheAdapter := &fundingTrancheAdapter{repo: repos.fundingTranche, eventsMan: evtsMan}
	investorAccountAdapter := &investorAccountAdapter{repo: repos.investorAccount, eventsMan: evtsMan}

	paymentBiz := opsbusiness.NewPaymentRoutingBusiness(
		ctx,
		evtsMan,
		repos.incomingPayment,
		repos.transferOrder,
		repos.obligation,
		repos.accountRef,
		identityCli,
		platformClients,
	)
	transferOrderBiz := opsbusiness.NewTransferOrderBusiness(
		ctx,
		evtsMan,
		repos.transferOrder,
		repos.cbsSyncRecord,
		repos.accountRef,
		loanFundingAdapter,
		fundingTrancheAdapter,
		investorAccountAdapter,
		platformClients,
		audit.NewWriter(evtsMan),
		limitsCli,
		false,     // transfer-order gate not yet enabled for stawi; governed separately
		"enforce", // default mode; irrelevant when gate is disabled
	)
	obligationBiz := opsbusiness.NewObligationBusiness(ctx, evtsMan, repos.obligation, identityCli, periodAdapter)

	return appBusinesses{
		group:         groupBiz,
		membership:    membershipBiz,
		tenure:        tenureBiz,
		period:        periodBiz,
		loanWindow:    loanWindowBiz,
		loanOffer:     loanOfferBiz,
		funding:       fundingBiz,
		payment:       paymentBiz,
		transferOrder: transferOrderBiz,
		obligation:    obligationBiz,
	}
}

func buildWorkflowMux(
	platformClients *clients.PlatformClients,
	biz appBusinesses,
) *http.ServeMux {
	mux := http.NewServeMux()
	handlers.RegisterWorkflowCallbacks(
		mux,
		biz.group,
		biz.membership,
		biz.tenure,
		biz.period,
		biz.loanWindow,
		biz.loanOffer,
		biz.funding,
		biz.payment,
		biz.transferOrder,
		biz.obligation,
		platformClients,
	)

	return mux
}

// setupLimitsClient wires the limits service client used for stawi loan
// disbursement gate checks. Returns nil, nil when LimitsServiceURI is empty.
func setupLimitsClient(
	ctx context.Context,
	cfg aconfig.StawiConfig,
) (limitsv1connect.LimitsServiceClient, error) {
	return consumer.SetupClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.LimitsServiceURI,
		WorkloadAPITargetPath: cfg.LimitsServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceLimits,
	})
}

func buildServiceOptions(ctx context.Context, mux *http.ServeMux, repos appRepositories) []frame.Option {
	return []frame.Option{
		frame.WithHTTPHandler(mux),
		frame.WithRegisterEvents(
			stawievents.NewTenureSave(ctx, repos.tenure),
			stawievents.NewPeriodSave(ctx, repos.period),
			stawievents.NewMotionSave(ctx, repos.motion),
			stawievents.NewInfractionSave(ctx, repos.infraction),
			stawievents.NewLoanWindowSave(ctx, repos.loanWindow),
			stawievents.NewLoanOfferSave(ctx, repos.loanOffer),
			fundingevents.NewLoanFundingSave(ctx, repos.loanFunding),
			fundingevents.NewFundingAllocationSave(ctx, repos.fundingAllocation),
			fundingevents.NewFundingTrancheSave(ctx, repos.fundingTranche),
			fundingevents.NewInvestorAccountSave(ctx, repos.investorAccount),
			opsevents.NewTransferOrderSave(ctx, repos.transferOrder),
			opsevents.NewObligationSave(ctx, repos.obligation),
			opsevents.NewIncomingPaymentSave(ctx, repos.incomingPayment),
			opsevents.NewAccountRefSave(ctx, repos.accountRef),
			opsevents.NewCBSSyncRecordSave(ctx, repos.cbsSyncRecord),
		),
	}
}

func handleDatabaseMigration(
	ctx context.Context,
	dbManager datastore.Manager,
	cfg aconfig.StawiConfig,
) bool {
	if !cfg.DoDatabaseMigrate() {
		return false
	}
	migrationPath := cfg.GetDatabaseMigrationPath()
	if err := stawirepo.Migrate(ctx, dbManager, migrationPath); err != nil {
		util.Log(ctx).WithError(err).Fatal("main -- Could not migrate stawi tables")
	}
	syncTrustageWorkflows(ctx, &cfg)
	return true
}

// syncTrustageWorkflows pushes the workflow definitions baked into the image
// to the Trustage service, when TRUSTAGE_URL is configured.
func syncTrustageWorkflows(ctx context.Context, cfg *aconfig.StawiConfig) {
	trustageURL := os.Getenv("TRUSTAGE_URL")
	if trustageURL == "" {
		return
	}
	workflowsDir := os.Getenv("TRUSTAGE_WORKFLOWS_DIR")
	if workflowsDir == "" {
		workflowsDir = "/workflows"
	}
	trustageCli, cliErr := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
		Endpoint:  trustageURL,
		ServiceID:             servicecatalog.ServiceTrustage,
	}, workflowv1connect.NewWorkflowServiceClient)
	if cliErr != nil {
		util.Log(ctx).WithError(cliErr).Warn("trustage workflow client init failed")
		return
	}
	if syncErr := workflows.SyncFromDir(ctx, trustageCli, workflowsDir); syncErr != nil {
		util.Log(ctx).WithError(syncErr).Warn("trustage workflow sync failed")
	}
}

func setupIdentityClient(
	ctx context.Context,
	cfg aconfig.StawiConfig,
) (identityv1connect.IdentityServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:  cfg.IdentityServiceURI,
		ServiceID:             servicecatalog.ServiceIdentity,
	}, identityv1connect.NewIdentityServiceClient)
}

// ---------------------------------------------------------------------------
// Cross-domain adapters (funding repos, stawi period, stawi loan offer)
// ---------------------------------------------------------------------------

// loanOfferAdapter wraps stawi's LoanOfferRepository for funding's LoanRequestReader.
type loanOfferAdapter struct {
	repo stawirepo.LoanOfferRepository
}

func (a *loanOfferAdapter) GetByID(ctx context.Context, id string) (*fundingbusiness.LoanRequestInfo, error) {
	offer, err := a.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	return loanOfferToInfo(offer), nil
}

func loanOfferToInfo(o *stawimodels.LoanOffer) *fundingbusiness.LoanRequestInfo {
	if o == nil {
		return nil
	}
	info := &fundingbusiness.LoanRequestInfo{
		Amount:     o.Amount,
		Currency:   o.Currency,
		Properties: o.Properties,
	}
	info.BaseModel = o.BaseModel
	return info
}

// periodAdapter wraps stawi's PeriodRepository for operations' PeriodReader.
type periodAdapter struct {
	repo stawirepo.PeriodRepository
}

func (a *periodAdapter) GetCurrentByGroupID(ctx context.Context, groupID string) (*opsbusiness.PeriodInfo, error) {
	p, err := a.repo.GetCurrentByGroupID(ctx, groupID)
	if err != nil {
		return nil, err
	}
	if p == nil {
		return nil, errCurrentPeriodNotFound
	}
	info := &opsbusiness.PeriodInfo{
		EndDate:  p.EndDate,
		Position: p.Position,
	}
	info.BaseModel = p.BaseModel
	return info, nil
}

// loanFundingAdapter wraps funding's LoanFundingRepository for operations' LoanFundingReader.
type loanFundingAdapter struct {
	repo fundingrepo.LoanFundingRepository
}

func (a *loanFundingAdapter) GetByLoanRequestID(
	ctx context.Context,
	loanRequestID string,
) ([]*opsbusiness.LoanFundingInfo, error) {
	fundings, err := a.repo.GetByLoanRequestID(ctx, loanRequestID)
	if err != nil {
		return nil, err
	}
	result := make([]*opsbusiness.LoanFundingInfo, len(fundings))
	for i, f := range fundings {
		info := &opsbusiness.LoanFundingInfo{
			OwnerID:     f.OwnerID,
			FundingType: f.FundingType,
			Proportion:  f.Proportion,
		}
		info.BaseModel = f.BaseModel
		result[i] = info
	}
	return result, nil
}

type fundingTrancheAdapter struct {
	repo      fundingrepo.FundingTrancheRepository
	eventsMan fevents.Manager
}

func (a *fundingTrancheAdapter) GetByLoanFundingID(
	ctx context.Context,
	loanFundingID string,
) ([]*opsbusiness.FundingTrancheInfo, error) {
	tranches, err := a.repo.GetByLoanFundingID(ctx, loanFundingID)
	if err != nil {
		return nil, err
	}
	result := make([]*opsbusiness.FundingTrancheInfo, len(tranches))
	for i, t := range tranches {
		info := &opsbusiness.FundingTrancheInfo{
			PrincipalRepaid: t.PrincipalRepaid,
			InterestEarned:  t.InterestEarned,
		}
		info.BaseModel = t.BaseModel
		result[i] = info
	}
	return result, nil
}

func (a *fundingTrancheAdapter) Save(ctx context.Context, tranche *opsbusiness.FundingTrancheInfo) error {
	model := &fundingmodels.FundingTranche{
		PrincipalRepaid: tranche.PrincipalRepaid,
		InterestEarned:  tranche.InterestEarned,
	}
	model.BaseModel = tranche.BaseModel
	return a.eventsMan.Emit(ctx, "funding_tranche.save", model)
}

type investorAccountAdapter struct {
	repo      fundingrepo.InvestorAccountRepository
	eventsMan fevents.Manager
}

func (a *investorAccountAdapter) GetByID(ctx context.Context, id string) (*opsbusiness.InvestorAccountInfo, error) {
	acct, err := a.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	info := &opsbusiness.InvestorAccountInfo{
		ReservedBalance:  acct.ReservedBalance,
		AvailableBalance: acct.AvailableBalance,
		TotalReturned:    acct.TotalReturned,
	}
	info.BaseModel = acct.BaseModel
	return info, nil
}

func (a *investorAccountAdapter) Save(ctx context.Context, account *opsbusiness.InvestorAccountInfo) error {
	model := &fundingmodels.InvestorAccount{
		ReservedBalance:  account.ReservedBalance,
		AvailableBalance: account.AvailableBalance,
		TotalReturned:    account.TotalReturned,
	}
	model.BaseModel = account.BaseModel
	return a.eventsMan.Emit(ctx, "investor_account.save", model)
}
