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

	"buf.build/gen/go/antinvestor/identity/connectrpc/go/identity/v1/identityv1connect"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	operationspb "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect"
	"github.com/antinvestor/common"
	"github.com/antinvestor/common/connection"
	"github.com/antinvestor/common/permissions"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/config"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/frame/security/authorizer"
	connectInterceptors "github.com/pitabwire/frame/security/interceptors/connect"
	"github.com/pitabwire/frame/workerpool"
	"github.com/pitabwire/util"

	auditmw "github.com/antinvestor/common/audit"

	aconfig "github.com/antinvestor/service-fintech/apps/operations/config"
	"github.com/antinvestor/service-fintech/apps/operations/service/business"
	opsevents "github.com/antinvestor/service-fintech/apps/operations/service/events"
	"github.com/antinvestor/service-fintech/apps/operations/service/handlers"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"

	fundingmodels "github.com/antinvestor/service-fintech/apps/funding/service/models"
	fundingrepo "github.com/antinvestor/service-fintech/apps/funding/service/repository"
	stawirepo "github.com/antinvestor/service-fintech/apps/stawi/service/repository"

	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/limits/consumer"
)

var errCurrentPeriodNotFound = errors.New("current period not found")

func main() {
	tmpCtx := context.Background()

	cfg, err := config.LoadWithOIDC[aconfig.OperationsConfig](tmpCtx)
	if err != nil {
		util.Log(tmpCtx).With("err", err).Error("could not process configs")
		return
	}

	if cfg.Name() == "" {
		cfg.ServiceName = "service_operations"
	}

	ctx, svc := frame.NewServiceWithContext(
		tmpCtx,
		frame.WithConfig(&cfg),
		frame.WithDatastore(),
	)
	defer svc.Stop(ctx)
	log := util.Log(ctx)

	sm := svc.SecurityManager()
	dbManager := svc.DatastoreManager()
	workMan := svc.WorkManager()
	evtsMan := svc.EventsManager()

	// Handle database migration if requested
	if handleDatabaseMigration(ctx, dbManager, cfg) {
		return
	}

	// Get database pool
	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	if dbPool == nil {
		log.Error("Database pool is nil - check DATABASE_PRIMARY_URL environment variable")
		return
	}

	// Identity SDK client
	identityCli, idErr := setupIdentityClient(ctx, cfg)
	if idErr != nil {
		log.WithError(idErr).Warn("main -- Could not setup identity client")
	}

	// Platform clients for transfer order execution (ledger, payment, etc.).
	// The ledger client is load-bearing: every transfer order has to post a
	// double-entry transaction. Refuse to start if it is missing so we never
	// silently drop postings against a partially-wired deployment.
	platformClients, pcErr := clients.NewPlatformClients(ctx, &cfg, cfg.ServiceEndpoints())
	if pcErr != nil {
		log.WithError(pcErr).Error("main -- could not initialise platform clients")
		return
	}
	if platformClients == nil || platformClients.LedgerClient == nil {
		log.Error("main -- ledger client is required but was not configured")
		return
	}

	// Limits client. Optional — when LimitsServiceURI is empty, SetupClient
	// returns nil and the gate is disabled at runtime regardless of the config flag.
	limitsCli, limitsErr := setupLimitsClient(ctx, cfg)
	if limitsErr != nil {
		log.WithError(limitsErr).
			Warn("main -- Could not setup limits client, limits gate will be disabled")
	}

	serviceOptions := setupServiceOptions(
		ctx,
		sm,
		evtsMan,
		dbPool,
		workMan,
		identityCli,
		platformClients,
		limitsCli,
		cfg,
	)

	svc.Init(ctx, serviceOptions...)

	err = svc.Run(ctx, "")
	if err != nil {
		log.WithError(err).Fatal("could not run Server")
	}
}

func setupServiceOptions(
	ctx context.Context,
	sm security.Manager,
	evtsMan fevents.Manager,
	dbPool pool.Pool,
	workMan workerpool.Manager,
	identityCli identityv1connect.IdentityServiceClient,
	platformClients *clients.PlatformClients,
	limitsCli limitsv1connect.LimitsServiceClient,
	cfg aconfig.OperationsConfig,
) []frame.Option {
	// Operations repositories
	toRepo := repository.NewTransferOrderRepository(ctx, dbPool, workMan)
	obRepo := repository.NewObligationRepository(ctx, dbPool, workMan)
	ipRepo := repository.NewIncomingPaymentRepository(ctx, dbPool, workMan)
	arRepo := repository.NewAccountRefRepository(ctx, dbPool, workMan)
	csRepo := repository.NewCBSSyncRecordRepository(ctx, dbPool, workMan)
	auditRepo := audit.NewRepository(ctx, dbPool, workMan)
	auditWriter := audit.NewWriter(evtsMan)

	// Funding repositories (shared database, adapted to local interfaces)
	lfRepo := fundingrepo.NewLoanFundingRepository(ctx, dbPool, workMan)
	ftRepo := fundingrepo.NewFundingTrancheRepository(ctx, dbPool, workMan)
	iaRepo := fundingrepo.NewInvestorAccountRepository(ctx, dbPool, workMan)

	// Stawi period repository (shared database)
	perRepo := stawirepo.NewPeriodRepository(ctx, dbPool, workMan)

	// Wrap cross-domain repos in adapters for the business layer.
	perAdapter := &periodAdapter{repo: perRepo}
	lfAdapter := &loanFundingAdapter{repo: lfRepo}
	ftAdapter := &fundingTrancheAdapter{repo: ftRepo, eventsMan: evtsMan}
	iaAdapter := &investorAccountAdapter{repo: iaRepo, eventsMan: evtsMan}

	// Business logic (identity lookups use SDK client directly)
	prBiz := business.NewPaymentRoutingBusiness(
		ctx,
		evtsMan,
		ipRepo,
		toRepo,
		obRepo,
		arRepo,
		identityCli,
		platformClients,
	)
	toBiz := business.NewTransferOrderBusiness(
		ctx,
		evtsMan,
		toRepo,
		csRepo,
		arRepo,
		lfAdapter,
		ftAdapter,
		iaAdapter,
		platformClients,
		auditWriter,
		limitsCli,
		cfg.LimitsGateEnabledOperationsTransfer,
		cfg.LimitsGateModeOperationsTransfer,
	)
	_ = business.NewObligationBusiness(ctx, evtsMan, obRepo, identityCli, perAdapter)

	// ConnectRPC handler
	connectHandler := setupConnectServer(ctx, sm, dbPool, toBiz, prBiz, toRepo)

	sd := operationspb.File_operations_v1_operations_proto.Services().ByName("OperationsService")

	return []frame.Option{
		frame.WithHTTPHandler(connectHandler),
		frame.WithPermissionRegistration(sd),
		frame.WithRegisterEvents(
			opsevents.NewTransferOrderSave(ctx, toRepo),
			opsevents.NewObligationSave(ctx, obRepo),
			opsevents.NewIncomingPaymentSave(ctx, ipRepo),
			opsevents.NewAccountRefSave(ctx, arRepo),
			opsevents.NewCBSSyncRecordSave(ctx, csRepo),
			audit.NewEventSave(ctx, auditRepo),
		),
	}
}

func handleDatabaseMigration(
	ctx context.Context,
	dbManager datastore.Manager,
	cfg aconfig.OperationsConfig,
) bool {
	if cfg.DoDatabaseMigrate() {
		err := repository.Migrate(ctx, dbManager, cfg.GetDatabaseMigrationPath())
		if err != nil {
			util.Log(ctx).WithError(err).Fatal("main -- Could not migrate successfully")
		}
		return true
	}
	return false
}

func setupIdentityClient(
	ctx context.Context,
	cfg aconfig.OperationsConfig,
) (identityv1connect.IdentityServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:  cfg.IdentityServiceURI,
		Audiences: []string{"service_identity"},
	}, identityv1connect.NewIdentityServiceClient)
}

func setupConnectServer(
	ctx context.Context,
	sm security.Manager,
	dbPool pool.Pool,
	toBiz business.TransferOrderBusiness,
	prBiz business.PaymentRoutingBusiness,
	toRepo repository.TransferOrderRepository,
) http.Handler {
	opsHandler := handlers.NewOperationsServer(toBiz, prBiz, toRepo)

	auth := sm.GetAuthorizer(ctx)

	tenancyAccessChecker := authorizer.NewTenancyAccessChecker(auth, "tenancy_access")
	tenancyAccessInterceptor := connectInterceptors.NewTenancyAccessInterceptor(tenancyAccessChecker)

	sd := operationspb.File_operations_v1_operations_proto.Services().ByName("OperationsService")
	procMap := permissions.BuildProcedureMap(sd)
	svcPerms := permissions.ForService(sd)
	functionChecker := authorizer.NewFunctionChecker(auth, svcPerms.Namespace)
	functionAccessInterceptor := connectInterceptors.NewFunctionAccessInterceptor(functionChecker, procMap)

	opsAuditInterceptor := auditmw.NewInterceptor("service_operations", nil)

	defaultInterceptorList, err := connectInterceptors.DefaultList(
		ctx, sm.GetAuthenticator(ctx),
		tenancyAccessInterceptor, functionAccessInterceptor, opsAuditInterceptor)
	if err != nil {
		util.Log(ctx).WithError(err).Fatal("main -- Could not create default interceptors")
	}

	interceptorOption := connect.WithInterceptors(defaultInterceptorList...)

	opsPath, opsServerHandler := operationsv1connect.NewOperationsServiceHandler(opsHandler, interceptorOption)

	mux := http.NewServeMux()
	mux.Handle(opsPath, opsServerHandler)

	return mux
}

func setupLimitsClient(
	ctx context.Context,
	cfg aconfig.OperationsConfig,
) (limitsv1connect.LimitsServiceClient, error) {
	return consumer.SetupClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.LimitsServiceURI,
		WorkloadAPITargetPath: cfg.LimitsServiceWorkloadAPITargetPath,
		Audiences:             []string{"service_limits"},
	})
}

// ---------------------------------------------------------------------------
// Cross-domain adapters (stawi period, funding repos)
// ---------------------------------------------------------------------------

type periodAdapter struct {
	repo stawirepo.PeriodRepository
}

func (a *periodAdapter) GetCurrentByGroupID(ctx context.Context, groupID string) (*business.PeriodInfo, error) {
	p, err := a.repo.GetCurrentByGroupID(ctx, groupID)
	if err != nil {
		return nil, err
	}
	if p == nil {
		return nil, errCurrentPeriodNotFound
	}
	info := &business.PeriodInfo{
		EndDate:  p.EndDate,
		Position: p.Position,
	}
	info.BaseModel = p.BaseModel
	return info, nil
}

type loanFundingAdapter struct {
	repo fundingrepo.LoanFundingRepository
}

func (a *loanFundingAdapter) GetByLoanRequestID(
	ctx context.Context,
	loanRequestID string,
) ([]*business.LoanFundingInfo, error) {
	fundings, err := a.repo.GetByLoanRequestID(ctx, loanRequestID)
	if err != nil {
		return nil, err
	}
	result := make([]*business.LoanFundingInfo, len(fundings))
	for i, f := range fundings {
		info := &business.LoanFundingInfo{
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
) ([]*business.FundingTrancheInfo, error) {
	tranches, err := a.repo.GetByLoanFundingID(ctx, loanFundingID)
	if err != nil {
		return nil, err
	}
	result := make([]*business.FundingTrancheInfo, len(tranches))
	for i, t := range tranches {
		info := &business.FundingTrancheInfo{
			PrincipalRepaid: t.PrincipalRepaid,
			InterestEarned:  t.InterestEarned,
		}
		info.BaseModel = t.BaseModel
		result[i] = info
	}
	return result, nil
}

func (a *fundingTrancheAdapter) Save(ctx context.Context, tranche *business.FundingTrancheInfo) error {
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

func (a *investorAccountAdapter) GetByID(ctx context.Context, id string) (*business.InvestorAccountInfo, error) {
	acct, err := a.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	info := &business.InvestorAccountInfo{
		ReservedBalance:  acct.ReservedBalance,
		AvailableBalance: acct.AvailableBalance,
		TotalReturned:    acct.TotalReturned,
	}
	info.BaseModel = acct.BaseModel
	return info, nil
}

func (a *investorAccountAdapter) Save(ctx context.Context, account *business.InvestorAccountInfo) error {
	model := &fundingmodels.InvestorAccount{
		ReservedBalance:  account.ReservedBalance,
		AvailableBalance: account.AvailableBalance,
		TotalReturned:    account.TotalReturned,
	}
	model.BaseModel = account.BaseModel
	return a.eventsMan.Emit(ctx, "investor_account.save", model)
}
