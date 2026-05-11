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
	"net/http"

	"buf.build/gen/go/antinvestor/funding/connectrpc/go/funding/v1/fundingv1connect"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/loans/v1/loansv1connect"
	loanspb "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/notification/connectrpc/go/notification/v1/notificationv1connect"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
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

	aconfig "github.com/antinvestor/service-fintech/apps/loans/config"
	"github.com/antinvestor/service-fintech/apps/loans/service/authz"
	"github.com/antinvestor/service-fintech/apps/loans/service/business"
	lmevents "github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/handlers"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"

	"github.com/antinvestor/service-fintech/pkg/audit"
)

func main() {
	tmpCtx := context.Background()

	cfg, err := config.LoadWithOIDC[aconfig.LoanManagementConfig](tmpCtx)
	if err != nil {
		util.Log(tmpCtx).With("err", err).Error("could not process configs")
		return
	}

	if cfg.Name() == "" {
		cfg.ServiceName = "service_loans"
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

	// Setup external service clients
	notificationCli, notifErr := setupNotificationClient(ctx, cfg)
	if notifErr != nil {
		log.WithError(notifErr).
			Warn("main -- Could not setup notification client, notifications will be disabled")
	}
	loanNotifier := business.NewLoanNotifier(notificationCli)

	operationsCli, opsErr := setupOperationsClient(ctx, cfg)
	if opsErr != nil {
		log.WithError(opsErr).
			Warn("main -- Could not setup operations client, transfer orders will be disabled")
	}

	fundingCli, fundingErr := setupFundingClient(ctx, cfg)
	if fundingErr != nil {
		log.WithError(fundingErr).
			Warn("main -- Could not setup funding client, loan creation will fail closed")
	}

	limitsCli, limitsErr := setupLimitsClient(ctx, cfg)
	if limitsErr != nil {
		log.WithError(limitsErr).
			Warn("main -- Could not setup limits client, limits gate will be disabled")
	}

	// Get database pool
	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	if dbPool == nil {
		log.Error("Database pool is nil - check DATABASE_PRIMARY_URL environment variable")
		return
	}

	serviceOptions := setupServiceOptions(
		ctx,
		sm,
		evtsMan,
		dbPool,
		workMan,
		fundingCli,
		loanNotifier,
		operationsCli,
		limitsCli,
		cfg.LimitsGateEnabledLoanDisbursement,
		cfg.LimitsGateModeLoanDisbursement,
		cfg.LimitsGateEnabledLoanRequestApproval,
		cfg.LimitsGateModeLoanRequestApproval,
		cfg.LimitsGateEnabledLoanRepayment,
		cfg.LimitsGateModeLoanRepayment,
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
	fundingCli fundingv1connect.FundingServiceClient,
	loanNotifier *business.LoanNotifier,
	operationsCli operationsv1connect.OperationsServiceClient,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsGateEnabledDisbursement bool,
	limitsGateModeDisbursement string,
	limitsGateEnabledLoanRequestApproval bool,
	limitsGateModeLoanRequestApproval string,
	limitsGateEnabledLoanRepayment bool,
	limitsGateModeLoanRepayment string,
) []frame.Option {
	lpRepo := repository.NewLoanProductRepository(ctx, dbPool, workMan)
	loanRequestRepo := repository.NewLoanRequestRepository(ctx, dbPool, workMan)
	cpaRepo := repository.NewClientProductAccessRepository(ctx, dbPool, workMan)
	laRepo := repository.NewLoanAccountRepository(ctx, dbPool, workMan)
	rsRepo := repository.NewRepaymentScheduleRepository(ctx, dbPool, workMan)
	seRepo := repository.NewScheduleEntryRepository(ctx, dbPool, workMan)
	lbRepo := repository.NewLoanBalanceRepository(ctx, dbPool, workMan)
	repRepo := repository.NewRepaymentRepository(ctx, dbPool, workMan)
	penRepo := repository.NewPenaltyRepository(ctx, dbPool, workMan)
	lrRepo := repository.NewLoanRestructureRepository(ctx, dbPool, workMan)
	lscRepo := repository.NewLoanStatusChangeRepository(ctx, dbPool, workMan)
	reconRepo := repository.NewReconciliationRepository(ctx, dbPool, workMan)
	disbRepo := repository.NewDisbursementRepository(ctx, dbPool, workMan)
	auditRepo := audit.NewRepository(ctx, dbPool, workMan)
	auditWriter := audit.NewWriter(evtsMan)

	lpBusiness := business.NewLoanProductBusiness(ctx, evtsMan, lpRepo)
	lrBusiness := business.NewLoanRequestBusiness(
		ctx,
		evtsMan,
		loanRequestRepo,
		lpRepo,
		limitsCli,
		limitsGateEnabledLoanRequestApproval,
		limitsGateModeLoanRequestApproval,
	)
	scheduleBusiness := business.NewRepaymentScheduleBusiness(ctx, evtsMan, laRepo, lpRepo, rsRepo, seRepo)
	laBusiness := business.NewLoanAccountBusiness(
		ctx, evtsMan, lpRepo, laRepo, lbRepo, lscRepo, repRepo, penRepo,
		loanRequestRepo, fundingCli, scheduleBusiness, operationsCli, auditWriter,
	)
	// paidOffHook is currently nil here. A deployment that runs seed
	// inside the loans process (or wires an RPC client for a seed
	// service) can pass an implementation here to get credit profile
	// updates on loan pay-off.
	var paidOffHook business.PaidOffHook
	repBusiness := business.NewRepaymentBusiness(
		ctx,
		evtsMan,
		laRepo,
		repRepo,
		rsRepo,
		seRepo,
		lbRepo,
		loanNotifier,
		operationsCli,
		auditWriter,
		paidOffHook,
		limitsCli,
		limitsGateEnabledLoanRepayment,
		limitsGateModeLoanRepayment,
	)
	penaltyBusiness := business.NewPenaltyBusiness(ctx, evtsMan, penRepo, laRepo, operationsCli, auditWriter)
	restructBusiness := business.NewLoanRestructureBusiness(ctx, evtsMan, lrRepo, laRepo, scheduleBusiness)
	reconBusiness := business.NewReconciliationBusiness(ctx, evtsMan, reconRepo)
	disbBusiness := business.NewDisbursementBusiness(
		ctx,
		evtsMan,
		disbRepo,
		laRepo,
		laBusiness,
		operationsCli,
		auditWriter,
		limitsCli,
		limitsGateEnabledDisbursement,
		limitsGateModeDisbursement,
	)

	portfolioBusiness := business.NewPortfolioBusiness(ctx, dbPool)

	connectHandler := setupConnectServer(ctx, sm, dbPool,
		lpBusiness, lrBusiness, laBusiness, repBusiness, scheduleBusiness,
		penaltyBusiness, restructBusiness, reconBusiness, portfolioBusiness, disbBusiness, lscRepo)

	sd := loanspb.File_loans_v1_loans_proto.Services().ByName("LoanManagementService")

	return []frame.Option{
		frame.WithHTTPHandler(connectHandler),
		frame.WithPermissionRegistration(sd),
		frame.WithRegisterEvents(
			lmevents.NewLoanProductSave(ctx, lpRepo),
			lmevents.NewLoanRequestSave(ctx, loanRequestRepo),
			lmevents.NewClientProductAccessSave(ctx, cpaRepo),
			lmevents.NewLoanAccountSave(ctx, laRepo),
			lmevents.NewRepaymentScheduleSave(ctx, rsRepo),
			lmevents.NewScheduleEntrySave(ctx, seRepo),
			lmevents.NewLoanBalanceSave(ctx, lbRepo),
			lmevents.NewRepaymentSave(ctx, repRepo),
			lmevents.NewPenaltySave(ctx, penRepo),
			lmevents.NewLoanRestructureSave(ctx, lrRepo),
			lmevents.NewLoanStatusChangeSave(ctx, lscRepo),
			lmevents.NewReconciliationSave(ctx, reconRepo),
			lmevents.NewDisbursementSave(ctx, disbRepo),
			audit.NewEventSave(ctx, auditRepo),
		),
	}
}

func handleDatabaseMigration(
	ctx context.Context,
	dbManager datastore.Manager,
	cfg aconfig.LoanManagementConfig,
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

func setupNotificationClient(
	ctx context.Context,
	cfg aconfig.LoanManagementConfig,
) (notificationv1connect.NotificationServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.NotificationServiceURI,
		WorkloadAPITargetPath: cfg.NotificationServiceWorkloadAPITargetPath,
		Audiences:             []string{"service_notification"},
	}, notificationv1connect.NewNotificationServiceClient)
}

func setupOperationsClient(
	ctx context.Context,
	cfg aconfig.LoanManagementConfig,
) (operationsv1connect.OperationsServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.OperationsServiceURI,
		WorkloadAPITargetPath: cfg.OperationsServiceWorkloadAPITargetPath,
		Audiences:             []string{"service_operations"},
	}, operationsv1connect.NewOperationsServiceClient)
}

func setupFundingClient(
	ctx context.Context,
	cfg aconfig.LoanManagementConfig,
) (fundingv1connect.FundingServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.FundingServiceURI,
		WorkloadAPITargetPath: cfg.FundingServiceWorkloadAPITargetPath,
		Audiences:             []string{"service_funding"},
	}, fundingv1connect.NewFundingServiceClient)
}

func setupLimitsClient(
	ctx context.Context,
	cfg aconfig.LoanManagementConfig,
) (limitsv1connect.LimitsServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.LimitsServiceURI,
		WorkloadAPITargetPath: cfg.LimitsServiceWorkloadAPITargetPath,
		Audiences:             []string{"service_limits"},
	}, limitsv1connect.NewLimitsServiceClient)
}

func setupConnectServer(
	ctx context.Context,
	sm security.Manager,
	dbPool pool.Pool,
	lpBusiness business.LoanProductBusiness,
	lrBusiness business.LoanRequestBusiness,
	laBusiness business.LoanAccountBusiness,
	repBusiness business.RepaymentBusiness,
	scheduleBusiness business.RepaymentScheduleBusiness,
	penaltyBusiness business.PenaltyBusiness,
	restructBusiness business.LoanRestructureBusiness,
	reconBusiness business.ReconciliationBusiness,
	portfolioBusiness business.PortfolioBusiness,
	disbBusiness business.DisbursementBusiness,
	statusChangeRepo repository.LoanStatusChangeRepository,
) http.Handler {
	// Create handler with injected dependencies
	lmHandler := handlers.NewLoanManagementServer(
		lpBusiness,
		lrBusiness,
		laBusiness,
		repBusiness,
		scheduleBusiness,
		penaltyBusiness,
		restructBusiness,
		reconBusiness,
		portfolioBusiness,
		disbBusiness,
		statusChangeRepo,
	)

	auth := sm.GetAuthorizer(ctx)

	// Layer 1: TenancyAccessChecker verifies caller can access the partition
	tenancyAccessChecker := authorizer.NewTenancyAccessChecker(auth, authz.NamespaceTenancyAccess)
	tenancyAccessInterceptor := connectInterceptors.NewTenancyAccessInterceptor(tenancyAccessChecker)

	// Layer 2: FunctionAccessInterceptor enforces per-RPC permissions from proto annotations.
	sd := loanspb.File_loans_v1_loans_proto.Services().ByName("LoanManagementService")
	procMap := permissions.BuildProcedureMap(sd)
	svcPerms := permissions.ForService(sd)
	functionChecker := authorizer.NewFunctionChecker(auth, svcPerms.Namespace)
	functionAccessInterceptor := connectInterceptors.NewFunctionAccessInterceptor(functionChecker, procMap)

	loansAuditInterceptor := auditmw.NewInterceptor("service_loans", nil)

	// TenancyTxInterceptor opens a request-scoped transaction after auth
	// has populated the claims, publishes app.tenant_id + app.partition_id
	// from the claims via set_config, and binds the transaction to the
	// request context. Repository code then calls pool.DB(ctx, _) and gets
	// the bound tx transparently; tenancy is enforced by Row-Level Security
	// at the database layer.
	tenancyTxInterceptor := connectInterceptors.NewTenancyTxInterceptor(dbPool)

	defaultInterceptorList, err := connectInterceptors.DefaultList(
		ctx, sm.GetAuthenticator(ctx),
		tenancyAccessInterceptor, functionAccessInterceptor, loansAuditInterceptor, tenancyTxInterceptor)
	if err != nil {
		util.Log(ctx).WithError(err).Fatal("main -- Could not create default interceptors")
	}

	interceptorOption := connect.WithInterceptors(defaultInterceptorList...)

	// Register the loan management service on the mux
	lmPath, lmServerHandler := loansv1connect.NewLoanManagementServiceHandler(lmHandler, interceptorOption)

	mux := http.NewServeMux()
	mux.Handle(lmPath, lmServerHandler)

	return mux
}
