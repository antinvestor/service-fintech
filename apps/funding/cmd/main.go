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
	"fmt"
	"net/http"

	"buf.build/gen/go/antinvestor/audit/connectrpc/go/v2/audit/v1/auditv1connect"
	"buf.build/gen/go/antinvestor/funding/connectrpc/go/v2/funding/v1/fundingv1connect"
	fundingpb "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/v2/loans/v1/loansv1connect"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/antinvestor/common/v3"
	"github.com/antinvestor/common/v3/connection"
	"github.com/antinvestor/common/v3/permissions"
	"github.com/antinvestor/common/v3/servicecatalog"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/config"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/security/authorizer"
	connectInterceptors "github.com/pitabwire/frame/v3/security/interceptors/connect"
	"github.com/pitabwire/frame/v3/setup"
	"github.com/pitabwire/frame/v3/workerpool"
	"github.com/pitabwire/util"

	aconfig "github.com/antinvestor/service-fintech/apps/funding/config"
	"github.com/antinvestor/service-fintech/apps/funding/service/business"
	fundingevents "github.com/antinvestor/service-fintech/apps/funding/service/events"
	fundinghandlers "github.com/antinvestor/service-fintech/apps/funding/service/handlers"
	fundingmodels "github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/apps/funding/service/repository"
	"github.com/antinvestor/service-fintech/pkg/bootcheck"
	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
	"github.com/antinvestor/service-fintech/pkg/dbrole"
	"github.com/antinvestor/service-fintech/pkg/tenantassert"

	stawimodels "github.com/antinvestor/service-fintech/apps/stawi/service/models"
	stawirepo "github.com/antinvestor/service-fintech/apps/stawi/service/repository"

	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/limits/consumer"
)

func main() {
	tmpCtx := context.Background()

	cfg, err := config.LoadWithOIDC[aconfig.FundingConfig](tmpCtx)
	if err != nil {
		util.Log(tmpCtx).With("err", err).Error("could not process configs")
		return
	}

	if cfg.Name() == "" {
		cfg.ServiceName = "service_funding"
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
		return dbmigrate.Locked(ctx, svc.DatastoreManager(), cfg.Name(), func(ctx context.Context) error {
			return repository.Migrate(ctx, svc.DatastoreManager(), cfg.GetDatabaseMigrationPath())
		})
	})
	svc.Setup().RegisterFunc(dbrole.StepName, dbrole.Step(svc.DatastoreManager()))
	defer svc.Stop(ctx)
	log := util.Log(ctx)

	// Frame setup job (DO_SETUP / argv setup): no peer clients required.
	fundingSD := fundingpb.File_funding_v1_funding_proto.Services().ByName("FundingService")
	if frame.ShouldRunSetup(&cfg) {
		svc.Init(ctx, frame.WithPermissionRegistration(fundingSD))
		if setupErr := svc.RunSetupForProcess(ctx, &cfg); setupErr != nil {
			log.WithError(setupErr).Fatal("setup plan failed")
		}
		return
	}
	dbrole.MustVerify(ctx, svc.DatastoreManager())

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

	// Platform clients for external service calls (loan mgmt, ledger, identity, etc.)
	platformClients, pcErr := clients.NewPlatformClients(ctx, &cfg, cfg.ServiceEndpoints())
	if pcErr != nil {
		log.WithError(pcErr).Warn("main -- Some platform clients could not be initialised")
	}

	// Operations client is load-bearing for investor capital movements and
	// must be available at startup; failing loudly here beats silently
	// dropping ledger postings later.
	operationsCli, opsErr := setupOperationsClient(ctx, cfg)
	if opsErr != nil {
		log.WithError(opsErr).Fatal("main -- could not initialise operations client")
	}

	// Limits client. Optional — when LimitsServiceURI is empty, SetupClient
	// returns nil and the gate is disabled at runtime regardless of the config flag.
	limitsCli, limitsErr := setupLimitsClient(ctx, cfg)
	if gateErr := consumer.RequireForGates(limitsCli, limitsErr, map[string]bool{
		"funding_withdraw": cfg.LimitsGateEnabledFundingWithdraw,
	}); gateErr != nil {
		log.WithError(gateErr).Fatal("main -- transaction limits cannot be enforced")
	}

	serviceOptions := setupServiceOptions(
		ctx,
		sm,
		evtsMan,
		dbPool,
		workMan,
		platformClients,
		operationsCli,
		limitsCli,
		cfg,
		auditCli,
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
	platformClients *clients.PlatformClients,
	operationsCli operationsv1connect.OperationsServiceClient,
	limitsCli limitsv1connect.LimitsServiceClient,
	cfg aconfig.FundingConfig,
	auditCli auditv1connect.AuditServiceClient,
) []frame.Option {
	// Funding repositories
	lfRepo := repository.NewLoanFundingRepository(ctx, dbPool, workMan)
	claimRepo := repository.NewLoanFundingClaimRepository(ctx, dbPool, workMan)
	lossRepo := repository.NewLossAbsorptionRepository(ctx, dbPool, workMan)
	ftRepo := repository.NewFundingTrancheRepository(ctx, dbPool, workMan)
	iaRepo := repository.NewInvestorAccountRepository(ctx, dbPool, workMan)
	icmRepo := repository.NewInvestorCapitalMovementRepository(ctx, dbPool, workMan)
	auditRepo := audit.NewRepository(ctx, dbPool, workMan)
	auditWriter := audit.NewWriter(evtsMan)

	// Legacy Stawi request repository used as a compatibility source while canonical
	// request data is still split across services.
	loRepo := stawirepo.NewLoanOfferRepository(ctx, dbPool, workMan)
	var loanMgmtCli loansv1connect.LoanManagementServiceClient
	if platformClients != nil {
		loanMgmtCli = platformClients.LenderLoanMgmt
	}

	// Funding's ledger legs (repayment shares, absorbed losses) are posted
	// as transfer orders through operations.
	poster := business.OperationsPoster{Client: operationsCli}
	rdBiz := business.NewRepaymentDistributionBusiness(
		repository.NewRepaymentDistributionRepository(ctx, dbPool, workMan),
		lfRepo, ftRepo, poster, cfg.PlatformFeeBP, cfg.WithholdingTaxBP,
	)

	recoveryBiz := business.NewLossRecoveryBusiness(
		lossRepo, repository.NewLossRecoveryRepository(ctx, dbPool, workMan), ftRepo, poster,
	)

	// Business logic
	faBiz := business.NewFundingAllocationBusiness(
		ctx,
		evtsMan,
		lfRepo,
		claimRepo,
		lossRepo,
		&loanRequestAdapter{repo: loRepo, loanMgmtCli: loanMgmtCli},
		iaRepo,
		ftRepo,
		business.NewSourceBalances(platformClients),
		poster,
	)
	iaBiz := business.NewInvestorAccountBusiness(
		ctx,
		evtsMan,
		iaRepo,
		icmRepo,
		operationsCli,
		auditWriter,
		limitsCli,
		cfg.LimitsGateEnabledFundingWithdraw,
		cfg.LimitsGateModeFundingWithdraw,
		business.WithInvestorPayouts(investorPayouts(platformClients)),
	)

	// ConnectRPC handler
	var investorOwners business.InvestorOwnerResolver
	if platformClients != nil {
		investorOwners = business.NewIdentityInvestorOwners(platformClients.LenderRegistry)
	}
	reads := business.NewInvestorReads(iaRepo, repository.NewStatementRepository(dbPool), investorOwners)
	connectHandler := setupConnectServer(ctx, sm, dbPool, iaBiz, faBiz, rdBiz, recoveryBiz, reads, auditCli)

	// Runtime options only — permissions/migrate are setup-only.
	return []frame.Option{
		frame.WithHTTPHandler(connectHandler),
		frame.WithRegisterEvents(
			fundingevents.NewLoanFundingSave(ctx, lfRepo),
			fundingevents.NewFundingTrancheSave(ctx, ftRepo),
			fundingevents.NewInvestorAccountSave(ctx, iaRepo),
			audit.NewEventSave(ctx, auditRepo),
		),
	}
}

// setupOperationsClient wires the operations service client used for every
// investor capital transfer order. Fails at startup if it cannot be
// initialised so funding never accepts a deposit it cannot settle on the
// ledger.
func setupOperationsClient(
	ctx context.Context,
	cfg aconfig.FundingConfig,
) (operationsv1connect.OperationsServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.OperationsServiceURI,
		WorkloadAPITargetPath: cfg.OperationsServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceOperations,
	}, operationsv1connect.NewOperationsServiceClient)
}

var errLoanRequestNotFound = errors.New("loan request not found")

// loanRequestAdapter bridges loan offer and loan request sources into a canonical loan-request view.
type loanRequestAdapter struct {
	repo        stawirepo.LoanOfferRepository
	loanMgmtCli loansv1connect.LoanManagementServiceClient
}

func (a *loanRequestAdapter) GetByID(ctx context.Context, id string) (*business.LoanRequestInfo, error) {
	if a.repo != nil {
		offer, err := a.repo.GetByID(ctx, id)
		if err == nil && offer != nil {
			return loanOfferToRequestInfo(offer), nil
		}
	}

	if a.loanMgmtCli != nil {
		resp, err := a.loanMgmtCli.LoanRequestGet(
			ctx,
			&loansv1.LoanRequestGetRequest{Id: id},
		)
		if err == nil && resp.GetData() != nil {
			info, convErr := loanRequestToRequestInfo(resp.GetData())
			if convErr != nil {
				// A malformed rate must not be funded as 0%: skip the loan.
				util.Log(ctx).WithError(convErr).WithField("loan_request_id", id).
					Warn("skipping loan request with an unparseable interest rate")
				return nil, fmt.Errorf("loan request %s: %w", id, convErr)
			}
			return info, nil
		}
	}

	return nil, errLoanRequestNotFound
}

func loanOfferToRequestInfo(o *stawimodels.LoanOffer) *business.LoanRequestInfo {
	if o == nil {
		return nil
	}
	info := &business.LoanRequestInfo{
		Amount:     o.Amount,
		Currency:   o.Currency,
		Properties: o.Properties,
	}
	info.BaseModel = o.BaseModel
	return info
}

func loanRequestToRequestInfo(lr *loansv1.LoanRequestObject) (*business.LoanRequestInfo, error) {
	if lr == nil {
		return nil, nil //nolint:nilnil // absent request maps to absent info, as before
	}

	amount, currency := fundingmodels.MoneyToMinorUnits(lr.GetApprovedAmount())
	if amount <= 0 {
		amount, currency = fundingmodels.MoneyToMinorUnits(lr.GetRequestedAmount())
	}

	properties := (&data.JSONMap{}).FromProtoStruct(lr.GetProperties())
	if properties == nil {
		properties = data.JSONMap{}
	}
	rate, err := fundingmodels.ParseRate(lr.GetInterestRate())
	if err != nil {
		return nil, fmt.Errorf("parse interest rate %q: %w", lr.GetInterestRate(), err)
	}
	properties["interest_rate"] = float64(rate)

	info := &business.LoanRequestInfo{
		Amount:     amount,
		Currency:   currency,
		Properties: properties,
	}
	info.GenID(context.Background())
	info.ID = lr.GetId()
	return info, nil
}

func setupConnectServer(
	ctx context.Context,
	sm security.Manager,
	_ pool.Pool,
	iaBiz business.InvestorAccountBusiness,
	faBiz business.FundingAllocationBusiness,
	rdBiz business.RepaymentDistributionBusiness,
	recoveryBiz *business.LossRecoveryBusiness,
	reads *business.InvestorReads,
	auditCli auditv1connect.AuditServiceClient,
) http.Handler {
	fundingHandler := fundinghandlers.NewFundingServer(iaBiz, faBiz, rdBiz, recoveryBiz, reads)

	auth := sm.GetAuthorizer(ctx)

	tenancyAccessChecker := authorizer.NewTenancyAccessChecker(auth, "tenancy_access")
	tenancyAccessInterceptor := connectInterceptors.NewTenancyAccessInterceptor(tenancyAccessChecker)

	sd := fundingpb.File_funding_v1_funding_proto.Services().ByName("FundingService")
	procMap := permissions.BuildProcedureMap(sd)
	svcPerms := permissions.ForService(sd)
	functionChecker := authorizer.NewFunctionChecker(auth, svcPerms.Namespace)
	functionAccessInterceptor := connectInterceptors.NewFunctionAccessInterceptor(functionChecker, procMap)

	fundingAuditInterceptor := clients.AuditInterceptor("service_funding", auditCli)

	defaultInterceptorList, err := connectInterceptors.DefaultList(
		ctx, sm.GetAuthenticator(ctx),
		tenancyAccessInterceptor, tenantassert.Interceptor(), functionAccessInterceptor, fundingAuditInterceptor)
	if err != nil {
		util.Log(ctx).WithError(err).Fatal("main -- Could not create default interceptors")
	}

	server := connect.NewServer(defaultInterceptorList...)
	fundingv1connect.RegisterFundingServiceHandler(server, fundingHandler)

	mux := http.NewServeMux()
	connecthttp.Mount(mux, server)

	return mux
}

// setupLimitsClient wires the limits service client used for investor deposit
// and withdrawal gate checks. Returns nil, nil when LimitsServiceURI is empty.
func setupLimitsClient(
	ctx context.Context,
	cfg aconfig.FundingConfig,
) (limitsv1connect.LimitsServiceClient, error) {
	return consumer.SetupClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.LimitsServiceURI,
		WorkloadAPITargetPath: cfg.LimitsServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceLimits,
	})
}

// investorPayouts resolves where an investor's withdrawal is paid; without
// the identity and profile clients withdrawals are refused.
func investorPayouts(pc *clients.PlatformClients) business.InvestorPayoutResolver {
	if pc == nil || pc.LenderRegistry == nil || pc.ProfileClient == nil {
		return nil
	}
	return business.NewInvestorPayoutResolver(pc.LenderRegistry, pc.ProfileClient)
}
