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

	"buf.build/gen/go/antinvestor/audit/connectrpc/go/v2/audit/v1/auditv1connect"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	"github.com/antinvestor/common/v3"
	"github.com/antinvestor/common/v3/connection"
	"github.com/antinvestor/common/v3/permissions"
	"github.com/antinvestor/common/v3/servicecatalog"
	"github.com/antinvestor/service-trustage/client/workflows"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/config"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/security/authorizer"
	"github.com/pitabwire/frame/v3/security/interceptors/httptor"
	"github.com/pitabwire/frame/v3/setup"
	"github.com/pitabwire/frame/v3/tenancy"
	"github.com/pitabwire/frame/v3/workerpool"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/reflect/protoreflect"

	aconfig "github.com/antinvestor/service-fintech/apps/stawi/config"
	stawiv1 "github.com/antinvestor/service-fintech/gen/go/stawi/protocolbuffers/go/stawi/v1"
	"github.com/antinvestor/service-fintech/pkg/bootcheck"
	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
	"github.com/antinvestor/service-fintech/pkg/tenantassert"

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

	fevents "github.com/pitabwire/frame/v3/events"
)

// namespaceTenancyAccess is the Keto namespace that carries partition-level
// data access for every fintech service.
const namespaceTenancyAccess = "tenancy_access"

// manifestServiceName is the proto service in stawi.v1 that carries the
// service_permissions manifest for the workflow callback routes.
const manifestServiceName = "StawiWorkflowService"

var errCurrentPeriodNotFound = errors.New("current period not found")

type appRepositories struct {
	tenure          stawirepo.TenureRepository
	period          stawirepo.PeriodRepository
	motion          stawirepo.MotionRepository
	infraction      stawirepo.InfractionRepository
	loanWindow      stawirepo.LoanWindowRepository
	loanOffer       stawirepo.LoanOfferRepository
	loanFunding     fundingrepo.LoanFundingRepository
	fundingClaim    fundingrepo.LoanFundingClaimRepository
	lossAbsorption  fundingrepo.LossAbsorptionRepository
	fundingTranche  fundingrepo.FundingTrancheRepository
	investorAccount fundingrepo.InvestorAccountRepository
	transferOrder   opsrepo.TransferOrderRepository
	obligation      opsrepo.ObligationRepository
	incomingPayment opsrepo.IncomingPaymentRepository
	accountRef      opsrepo.AccountRefRepository
	cbsSyncRecord   opsrepo.CBSSyncRecordRepository
	auditRepo       audit.Repository
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

	// Refuse to serve on an environment that is unsafe outside local
	// development (docs/runbook/required-environment.md).
	if err = bootcheck.Validate(tmpCtx, &cfg); err != nil {
		util.Log(tmpCtx).WithError(err).Fatal("environment is not deployment-safe")
	}

	ctx, svc := frame.NewServiceWithContext(
		tmpCtx,
		frame.WithConfig(&cfg),
		frame.WithDatastore(),
	)

	// The advisory lock serialises overlapping migrate Jobs on the same
	// database so concurrent DDL cannot race.
	svc.Setup().RegisterFunc(setup.NameMigrate, func(ctx context.Context) error {
		migErr := dbmigrate.Locked(ctx, svc.DatastoreManager(), cfg.Name(), func(ctx context.Context) error {
			return stawirepo.Migrate(ctx, svc.DatastoreManager(), cfg.GetDatabaseMigrationPath())
		})
		if migErr != nil {
			return migErr
		}
		syncTrustageWorkflows(ctx, &cfg)
		return nil
	})
	defer svc.Stop(ctx)
	log := util.Log(ctx)

	// The stawi.v1 manifest owns the service_stawi permission namespace: it
	// names every workflow callback route and the permission each requires.
	manifestSD := stawiv1.File_stawi_v1_stawi_proto.Services().ByName(manifestServiceName)

	// Setup job (DO_SETUP / argv setup): schema plus permission manifest
	// registration, then exit. Runtime never re-registers permissions.
	if frame.ShouldRunSetup(&cfg) {
		svc.Init(ctx, frame.WithPermissionRegistration(manifestSD))
		if setupErr := svc.RunSetupForProcess(ctx, &cfg); setupErr != nil {
			log.WithError(setupErr).Fatal("setup plan failed")
		}
		return
	}

	sm := svc.SecurityManager()

	// RPC-level audit delivery. Required when running securely; a nil client
	// is tolerated (and logged) only for local development.
	auditCli, err := clients.ResolveAuditClient(ctx, &cfg, cfg.IsRunSecurely(), cfg.AuditConfig)
	if err != nil {
		log.WithError(err).Fatal("main -- Could not setup audit client")
	}
	dbManager := svc.DatastoreManager()
	workMan := svc.WorkManager()
	evtsMan := svc.EventsManager()

	// Get database pool
	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	if dbPool == nil {
		log.Error("Database pool is nil - check DATABASE_PRIMARY_URL environment variable")
		return
	}

	// --- Identity SDK client (for ClientGroup + Membership) ---
	// Every group, membership and offer lookup goes through identity; without
	// it the service can only fail requests, so refuse to start.
	identityCli, idErr := setupIdentityClient(ctx, cfg)
	if idErr != nil {
		log.WithError(idErr).Fatal("main -- could not setup identity client")
	}

	// --- Platform clients ---
	platformClients, pcErr := clients.NewPlatformClients(ctx, &cfg, cfg.ServiceEndpoints())
	if pcErr != nil {
		log.WithError(pcErr).Fatal("main -- could not initialise platform clients")
	}
	if platformClients == nil || platformClients.LedgerClient == nil {
		log.Error("main -- ledger client is required but was not configured")
		return
	}

	// Limits client. Required while the transfer-order gate is on.
	limitsCli, limitsErr := setupLimitsClient(ctx, cfg)
	if gateErr := consumer.RequireForGates(limitsCli, limitsErr, map[string]bool{
		"operations_transfer": cfg.LimitsGateEnabledOperationsTransfer,
	}); gateErr != nil {
		log.WithError(gateErr).Fatal("main -- transaction limits cannot be enforced")
	}

	repos := initRepositories(ctx, dbPool, workMan)
	biz := initBusinesses(ctx, evtsMan, identityCli, platformClients, repos, limitsCli, cfg)
	handler := buildHandler(ctx, sm, manifestSD, biz, auditCli)
	serviceOptions := buildServiceOptions(ctx, handler, repos)

	svc.Init(ctx, serviceOptions...)

	err = svc.Run(ctx, "")
	if err != nil {
		log.WithError(err).Fatal("could not run Server")
	}
}

func initRepositories(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) appRepositories {
	return appRepositories{
		tenure:          stawirepo.NewTenureRepository(ctx, dbPool, workMan),
		period:          stawirepo.NewPeriodRepository(ctx, dbPool, workMan),
		motion:          stawirepo.NewMotionRepository(ctx, dbPool, workMan),
		infraction:      stawirepo.NewInfractionRepository(ctx, dbPool, workMan),
		loanWindow:      stawirepo.NewLoanWindowRepository(ctx, dbPool, workMan),
		loanOffer:       stawirepo.NewLoanOfferRepository(ctx, dbPool, workMan),
		loanFunding:     fundingrepo.NewLoanFundingRepository(ctx, dbPool, workMan),
		fundingClaim:    fundingrepo.NewLoanFundingClaimRepository(ctx, dbPool, workMan),
		lossAbsorption:  fundingrepo.NewLossAbsorptionRepository(ctx, dbPool, workMan),
		fundingTranche:  fundingrepo.NewFundingTrancheRepository(ctx, dbPool, workMan),
		investorAccount: fundingrepo.NewInvestorAccountRepository(ctx, dbPool, workMan),
		transferOrder:   opsrepo.NewTransferOrderRepository(ctx, dbPool, workMan),
		obligation:      opsrepo.NewObligationRepository(ctx, dbPool, workMan),
		incomingPayment: opsrepo.NewIncomingPaymentRepository(ctx, dbPool, workMan),
		accountRef:      opsrepo.NewAccountRefRepository(ctx, dbPool, workMan),
		cbsSyncRecord:   opsrepo.NewCBSSyncRecordRepository(ctx, dbPool, workMan),
		auditRepo:       audit.NewRepository(ctx, dbPool, workMan),
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
	product := cfg.ProductConfig
	groupBiz := stawibusiness.NewClientGroupBusiness(ctx, product, identityCli, platformClients)
	membershipBiz := stawibusiness.NewMembershipBusiness(ctx, identityCli)
	tenureBiz := stawibusiness.NewTenureBusiness(ctx, product, identityCli, repos.tenure, repos.period)
	periodBiz := stawibusiness.NewPeriodBusiness(ctx, repos.tenure, repos.period)

	loanWindowBiz := stawibusiness.NewLoanWindowBusiness(
		ctx, product, identityCli, repos.loanWindow, repos.period, repos.tenure,
	)
	loanOfferBiz := stawibusiness.NewLoanOfferBusiness(
		ctx, product, evtsMan, repos.loanOffer, repos.loanWindow, identityCli, platformClients,
	)
	fundingBiz := fundingbusiness.NewFundingAllocationBusiness(
		ctx,
		evtsMan,
		repos.loanFunding,
		repos.fundingClaim,
		repos.lossAbsorption,
		&loanOfferAdapter{repo: repos.loanOffer},
		repos.investorAccount,
		repos.fundingTranche,
		fundingbusiness.NewSourceBalances(platformClients),
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
		cfg.LimitsGateEnabledOperationsTransfer,
		cfg.LimitsGateModeOperationsTransfer,
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

// buildHandler wires the callback routes behind the frame security chain.
// Stawi moves money — a bare mux made every endpoint reachable by anyone with
// network access to the pod.
//
// The chain, outermost first, is: context setup → authentication (JWT bearer,
// claims into context) → tenancy claims binding (so pool.DB is RLS-scoped) →
// partition data access (Plane 1) → internal-principal tenant assertion →
// audit → per-route function access (Plane 2, permissions from the stawi.v1
// manifest) → mux.
func buildHandler(
	ctx context.Context,
	sm security.Manager,
	manifestSD protoreflect.ServiceDescriptor,
	biz appBusinesses,
	auditCli auditv1connect.AuditServiceClient,
) http.Handler {
	log := util.Log(ctx)

	mux := http.NewServeMux()
	handlers.RegisterWorkflowCallbacks(mux, handlers.Businesses{
		Group:         biz.group,
		Membership:    biz.membership,
		Tenure:        biz.tenure,
		Period:        biz.period,
		LoanWindow:    biz.loanWindow,
		LoanOffer:     biz.loanOffer,
		Funding:       biz.funding,
		Payment:       biz.payment,
		TransferOrder: biz.transferOrder,
		Obligation:    biz.obligation,
	})

	routes, routesErr := handlers.BuildRoutePermissions(manifestSD)
	if routesErr != nil {
		log.WithError(routesErr).Fatal("main -- stawi permission manifest is invalid")
	}

	auth := sm.GetAuthorizer(ctx)
	tenancyChecker := authorizer.NewTenancyAccessChecker(auth, namespaceTenancyAccess)
	functionChecker := authorizer.NewFunctionChecker(auth, permissions.ForService(manifestSD).Namespace)

	secured := handlers.FunctionAccessMiddleware(mux, functionChecker, routes)
	secured = clients.AuditHTTPMiddleware("service_stawi", auditCli)(secured)
	secured = tenantassert.Middleware(secured)
	secured = httptor.TenancyAccessMiddleware(secured, tenancyChecker)
	secured = tenancy.ClaimsMiddleware(secured, nil)
	secured = httptor.AuthenticationMiddleware(secured, sm.GetAuthenticator(ctx))

	root := http.NewServeMux()
	root.HandleFunc("GET /healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ok"))
	})
	root.Handle("/", secured)

	return httptor.ContextSetupMiddleware(ctx, root)
}

// setupLimitsClient wires the limits service client that gates stawi's
// transfer orders. Returns nil, nil when LimitsServiceURI is empty.
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

func buildServiceOptions(ctx context.Context, handler http.Handler, repos appRepositories) []frame.Option {
	return []frame.Option{
		frame.WithHTTPHandler(handler),
		frame.WithRegisterEvents(
			stawievents.NewTenureSave(ctx, repos.tenure),
			stawievents.NewPeriodSave(ctx, repos.period),
			stawievents.NewMotionSave(ctx, repos.motion),
			stawievents.NewInfractionSave(ctx, repos.infraction),
			stawievents.NewLoanWindowSave(ctx, repos.loanWindow),
			stawievents.NewLoanOfferSave(ctx, repos.loanOffer),
			fundingevents.NewLoanFundingSave(ctx, repos.loanFunding),
			fundingevents.NewFundingTrancheSave(ctx, repos.fundingTranche),
			fundingevents.NewInvestorAccountSave(ctx, repos.investorAccount),
			opsevents.NewTransferOrderSave(ctx, repos.transferOrder),
			opsevents.NewObligationSave(ctx, repos.obligation),
			opsevents.NewIncomingPaymentSave(ctx, repos.incomingPayment),
			opsevents.NewAccountRefSave(ctx, repos.accountRef),
			opsevents.NewCBSSyncRecordSave(ctx, repos.cbsSyncRecord),
			audit.NewEventSave(ctx, repos.auditRepo),
		),
	}
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
		ServiceID: servicecatalog.ServiceTrustage,
	}, newTrustageWorkflows)
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
		ServiceID: servicecatalog.ServiceIdentity,
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
