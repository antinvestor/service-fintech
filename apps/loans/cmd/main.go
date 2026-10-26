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
	"strings"

	"buf.build/gen/go/antinvestor/payment/connectrpc/go/v2/v1/paymentv1connect"

	"github.com/antinvestor/service-fintech/gen/go/seed/connectrpc/go/seed/v1/seedv1connect"

	"buf.build/gen/go/antinvestor/audit/connectrpc/go/v2/audit/v1/auditv1connect"
	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	"buf.build/gen/go/antinvestor/funding/connectrpc/go/v2/funding/v1/fundingv1connect"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/v2/loans/v1/loansv1connect"
	loanspb "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/notification/connectrpc/go/v2/notification/v1/notificationv1connect"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/antinvestor/common/v3"
	"github.com/antinvestor/common/v3/connection"
	"github.com/antinvestor/common/v3/permissions"
	"github.com/antinvestor/common/v3/servicecatalog"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/config"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/security/authorizer"
	connectInterceptors "github.com/pitabwire/frame/v3/security/interceptors/connect"
	"github.com/pitabwire/frame/v3/setup"
	"github.com/pitabwire/frame/v3/workerpool"
	"github.com/pitabwire/util"

	"github.com/antinvestor/common/notification"

	aconfig "github.com/antinvestor/service-fintech/apps/loans/config"
	"github.com/antinvestor/service-fintech/apps/loans/service/authz"
	"github.com/antinvestor/service-fintech/apps/loans/service/business"
	lmevents "github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/handlers"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/bootcheck"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
	"github.com/antinvestor/service-fintech/pkg/limits/consumer"
	"github.com/antinvestor/service-fintech/pkg/messages"
	"github.com/antinvestor/service-fintech/pkg/notify"
	"github.com/antinvestor/service-fintech/pkg/tenantassert"
	"github.com/antinvestor/service-fintech/pkg/trustage"

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
	// The loans jobs (delinquency, reminders, funder settlement, offer
	// expiry) run only when trustage fires their schedules, so a deploy that
	// cannot register them fails rather than ship a loan book nothing ages.
	svc.Setup().RegisterFunc(trustage.StepName, func(ctx context.Context) error {
		return trustage.SyncWorkflows(ctx, &cfg, cfg.IsRunSecurely())
	})
	defer svc.Stop(ctx)
	log := util.Log(ctx)

	// Frame setup job (DO_SETUP / argv setup): no peer clients required.
	loansSD := loanspb.File_loans_v1_loans_proto.Services().ByName("LoanManagementService")
	if frame.ShouldRunSetup(&cfg) {
		// Every message the service sends is declared in pkg/messages and
		// upserted with the notification service on each deploy, so a
		// template a borrower is owed exists before the first send.
		notification.RegisterTemplateSync(svc, &cfg, notification.Target{
			Endpoint:              cfg.NotificationServiceURI,
			WorkloadAPITargetPath: cfg.NotificationServiceWorkloadAPITargetPath,
		}, messages.Registry())
		svc.Init(ctx, frame.WithPermissionRegistration(loansSD))
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

	peers := setupPeerClients(ctx, cfg)

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
		peers.funding,
		peers.loanNotifier,
		peers.payoutChecker,
		peers.clientStanding,
		peers.operations,
		peers.limits,
		peers.payments,
		peers.teams,
		peers.readScope,
		cfg.LimitsGateEnabledLoanDisbursement,
		cfg.LimitsGateModeLoanDisbursement,
		cfg.LimitsGateEnabledLoanRequestApproval,
		cfg.LimitsGateModeLoanRequestApproval,
		cfg.DelinquencyThresholdDays,
		cfg.DefaultThresholdDays,
		peers.agentProfiles,
		peers.paidOffHook,
		cfg.DueReminderDays,
		cfg.Name(),
		auditCli,
	)

	svc.Init(ctx, serviceOptions...)

	err = svc.Run(ctx, "")
	if err != nil {
		log.WithError(err).Fatal("could not run Server")
	}
}

//nolint:funlen // linear service wiring; splitting hurts readability
func setupServiceOptions(
	ctx context.Context,
	sm security.Manager,
	evtsMan fevents.Manager,
	dbPool pool.Pool,
	workMan workerpool.Manager,
	fundingCli fundingv1connect.FundingServiceClient,
	loanNotifier *business.LoanNotifier,
	payoutChecker business.PayoutDestinationChecker,
	clientStanding business.ClientStandingChecker,
	operationsCli operationsv1connect.OperationsServiceClient,
	limitsCli limitsv1connect.LimitsServiceClient,
	paymentCli paymentv1connect.PaymentServiceClient,
	teams business.TeamResolver,
	readScope *business.ReadScope,
	limitsGateEnabledDisbursement bool,
	limitsGateModeDisbursement string,
	limitsGateEnabledLoanRequestApproval bool,
	limitsGateModeLoanRequestApproval string,
	delinquencyThresholdDays int,
	defaultThresholdDays int,
	agentProfiles business.AgentProfileResolver,
	paidOffHook business.PaidOffHook,
	dueReminderDays int,
	serviceName string,
	auditCli auditv1connect.AuditServiceClient,
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
		business.WithReadScope(readScope),
		business.WithNotifier(loanNotifier),
		business.WithAuditWriter(auditWriter),
		business.WithClientStanding(clientStanding),
	)
	scheduleBusiness := business.NewRepaymentScheduleBusiness(ctx, evtsMan, laRepo, lpRepo, rsRepo, seRepo,
		business.WithReadScope(readScope))
	laBusiness := business.NewLoanAccountBusiness(
		ctx, evtsMan, lpRepo, laRepo, lbRepo, lscRepo, repRepo, penRepo,
		loanRequestRepo, fundingCli, scheduleBusiness, operationsCli, auditWriter,
		business.WithReadScope(readScope),
		business.WithStatementSources(disbRepo, seRepo),
		business.WithNotifier(loanNotifier),
		business.WithPayoutDestinationChecker(payoutChecker),
	)
	fundingSettlement := business.NewFundingSettlement(repRepo, laRepo, fundingCli).
		WithCommission(business.NewAgentCommission(lpRepo, teams, operationsCli))
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
		business.WithReadScope(readScope),
		business.WithFundingSettlement(fundingSettlement),
		business.WithRepaymentApplier(repository.NewRepaymentApplier(dbPool, lbRepo)),
	)
	penaltyBusiness := business.NewPenaltyBusiness(ctx, penRepo, laRepo, lbRepo, operationsCli, auditWriter,
		business.WithNotifier(loanNotifier), business.WithScheduleEntries(seRepo),
		business.WithReadScope(readScope))
	restructBusiness := business.NewLoanRestructureBusiness(
		ctx, evtsMan, lrRepo, laRepo, lbRepo, rsRepo, laBusiness, scheduleBusiness,
		business.WithNotifier(loanNotifier),
		business.WithReadScope(readScope),
	)
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
		business.WithReadScope(readScope),
		business.WithScheduleBusiness(scheduleBusiness),
		business.WithNotifier(loanNotifier),
		business.WithPayoutDestinationChecker(payoutChecker),
	)

	portfolioBusiness := business.NewPortfolioBusiness(ctx, dbPool)
	cpaBusiness := business.NewClientProductAccessBusiness(ctx, evtsMan, cpaRepo, lpRepo)
	collectionBusiness := business.NewCollectionBusiness(
		ctx, laRepo, lbRepo, loanNotifier, business.WithReadScope(readScope),
		business.WithPayoutDestinationChecker(payoutChecker),
		business.WithPaymentClient(paymentCli),
	)

	// Periodic work runs only when the platform scheduler (trustage) calls
	// LoanJobRun; nothing here runs on a timer. Without those calls no loan
	// becomes delinquent, no reminder goes out and no funder is paid, so the
	// schedules ship with the service (products/loans/workflows).
	scanner := business.NewDelinquencyScanner(
		laRepo, seRepo, penaltyBusiness, laBusiness, lpRepo,
		delinquencyThresholdDays, defaultThresholdDays,
		business.WithScannerNotifications(loanNotifier, agentProfiles, lbRepo),
	)
	reminders := business.NewDueReminderJob(seRepo, laRepo, loanNotifier, dueReminderDays)
	paidOffNotices := business.NewPaidOffNotices(laRepo, lbRepo, paidOffHook, serviceName)
	loanJobs := business.NewLoanJobs(scanner, reminders, fundingSettlement, loanRequestRepo, loanNotifier,
		paidOffNotices)

	connectHandler := setupConnectServer(ctx, sm,
		lpBusiness, lrBusiness, laBusiness, repBusiness, scheduleBusiness,
		penaltyBusiness, restructBusiness, reconBusiness, portfolioBusiness, disbBusiness,
		cpaBusiness, collectionBusiness, lscRepo, loanJobs, auditCli)

	// Runtime options only — permissions/migrate are setup-only.
	return []frame.Option{
		frame.WithHTTPHandler(connectHandler),
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

func setupNotificationClient(
	ctx context.Context,
	cfg aconfig.LoanManagementConfig,
) (notificationv1connect.NotificationServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.NotificationServiceURI,
		WorkloadAPITargetPath: cfg.NotificationServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceNotification,
	}, notificationv1connect.NewNotificationServiceClient)
}

func setupOperationsClient(
	ctx context.Context,
	cfg aconfig.LoanManagementConfig,
) (operationsv1connect.OperationsServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.OperationsServiceURI,
		WorkloadAPITargetPath: cfg.OperationsServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceOperations,
	}, operationsv1connect.NewOperationsServiceClient)
}

// peerClients are the outbound service clients the runtime process needs.
type peerClients struct {
	loanNotifier   *business.LoanNotifier
	payoutChecker  business.PayoutDestinationChecker
	clientStanding business.ClientStandingChecker
	agentProfiles  business.AgentProfileResolver
	operations     operationsv1connect.OperationsServiceClient
	funding        fundingv1connect.FundingServiceClient
	limits         limitsv1connect.LimitsServiceClient
	// payments raises the prompts that ask a borrower to pay. Nil when the
	// payment client cannot be built; collection prompts are then refused.
	payments paymentv1connect.PaymentServiceClient
	// teams names the field team serving a client, for its commission.
	teams     business.TeamResolver
	readScope *business.ReadScope
	// paidOffHook tells seed a loan was repaid in full, so it can complete
	// its loan request and credit the borrower's profile. Nil when
	// SEED_SERVICE_URI is unset.
	paidOffHook business.PaidOffHook
}

// setupPeerClients builds every peer client. Optional peers degrade with a
// warning; the field client is required because per-client read scoping
// cannot fail open.
func setupPeerClients(ctx context.Context, cfg aconfig.LoanManagementConfig) peerClients {
	log := util.Log(ctx)

	notificationCli, notifErr := setupNotificationClient(ctx, cfg)
	if notifErr != nil {
		log.WithError(notifErr).
			Warn("main -- Could not setup notification client, notifications will be disabled")
	}

	operationsCli, opsErr := setupOperationsClient(ctx, cfg)
	if opsErr != nil {
		log.WithError(opsErr).
			Warn("main -- Could not setup operations client, transfer orders will be disabled")
	}

	paymentCli, paymentErr := connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.PaymentServiceURI,
		WorkloadAPITargetPath: cfg.PaymentServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServicePayment,
	}, paymentv1connect.NewPaymentServiceClient)
	if paymentErr != nil {
		log.WithError(paymentErr).Warn("main -- Could not setup payment client, collection prompts will be refused")
	}

	fundingCli, fundingErr := setupFundingClient(ctx, cfg)
	if fundingErr != nil {
		log.WithError(fundingErr).
			Warn("main -- Could not setup funding client, loan creation will fail closed")
	}

	limitsCli, limitsErr := setupLimitsClient(ctx, cfg)
	if gateErr := consumer.RequireForGates(limitsCli, limitsErr, map[string]bool{
		"loan_disbursement":     cfg.LimitsGateEnabledLoanDisbursement,
		"loan_request_approval": cfg.LimitsGateEnabledLoanRequestApproval,
	}); gateErr != nil {
		log.WithError(gateErr).Fatal("main -- transaction limits cannot be enforced")
	}

	fieldCli, fieldErr := setupFieldClient(ctx, cfg)
	if fieldErr != nil {
		log.WithError(fieldErr).Fatal("main -- Could not setup field client")
	}

	// Money leaves only to a destination that belongs to the borrower; the
	// borrower's contacts live on the profile service. Without it no
	// disbursement can be verified, which is the right failure.
	profileCli, profileErr := setupProfileClient(ctx, cfg)
	if profileErr != nil {
		log.WithError(profileErr).Fatal("main -- Could not setup profile client")
	}
	clientProfiles := business.NewFieldClientProfileResolver(fieldCli)

	// Field agents are workforce members on the identity service; the
	// arrears notice to an agent needs their profile.
	identityCli, identityErr := setupIdentityClient(ctx, cfg)
	if identityErr != nil {
		log.WithError(identityErr).Warn("main -- Could not setup identity client, agent notifications will be disabled")
	}

	var paidOffHook business.PaidOffHook
	if cfg.SeedServiceURI != "" {
		seedCli, seedErr := connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
			Endpoint:              cfg.SeedServiceURI,
			WorkloadAPITargetPath: cfg.SeedServiceWorkloadAPITargetPath,
			ServiceID:             servicecatalog.ServiceSeed,
		}, seedv1connect.NewSeedServiceClient)
		if seedErr != nil {
			log.WithError(seedErr).Warn("main -- Could not setup seed client, paid-off loans will not reach seed")
		} else {
			paidOffHook = business.NewSeedPaidOffHook(seedCli)
		}
	}

	return peerClients{
		paidOffHook:    paidOffHook,
		payoutChecker:  business.NewProfilePayoutChecker(clientProfiles, profileCli),
		clientStanding: business.NewFieldClientStanding(fieldCli),
		teams:          business.NewFieldTeamResolver(fieldCli),
		agentProfiles:  business.NewIdentityAgentProfileResolver(identityCli),
		loanNotifier: business.NewLoanNotifier(
			notify.New(notificationCli, messages.Registry()),
			clientProfiles,
			cfg.LenderDisplayName,
		),
		operations: operationsCli,
		funding:    fundingCli,
		limits:     limitsCli,
		payments:   paymentCli,
		readScope: business.NewReadScope(
			business.NewFieldAccessResolver(fieldCli), splitCSV(cfg.LoansStaffRoles)...,
		),
	}
}

// splitCSV turns a comma-separated env value into a trimmed slice.
func splitCSV(value string) []string {
	var out []string
	for _, part := range strings.Split(value, ",") {
		if p := strings.TrimSpace(part); p != "" {
			out = append(out, p)
		}
	}
	return out
}

// setupFieldClient resolves the client a profile belongs to. FieldService is
// served by the identity binary, so it targets the identity service account.
func setupFieldClient(
	ctx context.Context,
	cfg aconfig.LoanManagementConfig,
) (fieldv1connect.FieldServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.FieldServiceURI,
		WorkloadAPITargetPath: cfg.FieldServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceIdentity,
	}, fieldv1connect.NewFieldServiceClient)
}

func setupIdentityClient(
	ctx context.Context,
	cfg aconfig.LoanManagementConfig,
) (identityv1connect.IdentityServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.IdentityServiceURI,
		WorkloadAPITargetPath: cfg.IdentityServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceIdentity,
	}, identityv1connect.NewIdentityServiceClient)
}

func setupProfileClient(
	ctx context.Context,
	cfg aconfig.LoanManagementConfig,
) (profilev1connect.ProfileServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.ProfileServiceURI,
		WorkloadAPITargetPath: cfg.ProfileServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceProfile,
	}, profilev1connect.NewProfileServiceClient)
}

func setupFundingClient(
	ctx context.Context,
	cfg aconfig.LoanManagementConfig,
) (fundingv1connect.FundingServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.FundingServiceURI,
		WorkloadAPITargetPath: cfg.FundingServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceFunding,
	}, fundingv1connect.NewFundingServiceClient)
}

func setupLimitsClient(
	ctx context.Context,
	cfg aconfig.LoanManagementConfig,
) (limitsv1connect.LimitsServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.LimitsServiceURI,
		WorkloadAPITargetPath: cfg.LimitsServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceLimits,
	}, limitsv1connect.NewLimitsServiceClient)
}

func setupConnectServer(
	ctx context.Context,
	sm security.Manager,
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
	cpaBusiness business.ClientProductAccessBusiness,
	collectionBusiness business.CollectionBusiness,
	statusChangeRepo repository.LoanStatusChangeRepository,
	loanJobs *business.LoanJobs,
	auditCli auditv1connect.AuditServiceClient,
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
		cpaBusiness,
		collectionBusiness,
		statusChangeRepo,
		loanJobs,
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

	loansAuditInterceptor := clients.AuditInterceptor("service_loans", auditCli)

	defaultInterceptorList, err := connectInterceptors.DefaultList(
		ctx, sm.GetAuthenticator(ctx),
		tenancyAccessInterceptor, tenantassert.Interceptor(), functionAccessInterceptor, loansAuditInterceptor)
	if err != nil {
		util.Log(ctx).WithError(err).Fatal("main -- Could not create default interceptors")
	}

	server := connect.NewServer(defaultInterceptorList...)
	loansv1connect.RegisterLoanManagementServiceHandler(server, lmHandler)

	mux := http.NewServeMux()
	connecthttp.Mount(mux, server)

	return mux
}
