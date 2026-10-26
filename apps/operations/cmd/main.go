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
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	operationspb "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
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

	aconfig "github.com/antinvestor/service-fintech/apps/operations/config"
	"github.com/antinvestor/service-fintech/apps/operations/service/business"
	opsevents "github.com/antinvestor/service-fintech/apps/operations/service/events"
	"github.com/antinvestor/service-fintech/apps/operations/service/handlers"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/bootcheck"
	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
	"github.com/antinvestor/service-fintech/pkg/tenantassert"
	"github.com/antinvestor/service-fintech/pkg/trustage"

	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/limits/consumer"
)

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
	// Individuals' payments that could not be settled at once are finished
	// only when trustage fires the settle schedule, so a deploy that cannot
	// register it fails rather than ship repayments nothing retries.
	svc.Setup().RegisterFunc(trustage.StepName, func(ctx context.Context) error {
		return trustage.SyncWorkflows(ctx, &cfg, cfg.IsRunSecurely())
	})
	defer svc.Stop(ctx)
	log := util.Log(ctx)

	// Frame setup job (DO_SETUP / argv setup): no ledger/identity peers required.
	opsSD := operationspb.File_operations_v1_operations_proto.Services().ByName("OperationsService")
	if frame.ShouldRunSetup(&cfg) {
		svc.Init(ctx, frame.WithPermissionRegistration(opsSD))
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

	peers, peerErr := setupPeerClients(ctx, cfg)
	if peerErr != nil {
		log.WithError(peerErr).Error("main -- could not initialise peer clients")
		return
	}

	serviceOptions := setupServiceOptions(
		ctx,
		sm,
		evtsMan,
		dbPool,
		workMan,
		peers.identity,
		peers.platform,
		peers.limits,
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
	identityCli identityv1connect.IdentityServiceClient,
	platformClients *clients.PlatformClients,
	limitsCli limitsv1connect.LimitsServiceClient,
	cfg aconfig.OperationsConfig,
	auditCli auditv1connect.AuditServiceClient,
) []frame.Option {
	// Operations repositories
	toRepo := repository.NewTransferOrderRepository(ctx, dbPool, workMan)
	obRepo := repository.NewObligationRepository(ctx, dbPool, workMan)
	ipRepo := repository.NewIncomingPaymentRepository(ctx, dbPool, workMan)
	arRepo := repository.NewAccountRefRepository(ctx, dbPool, workMan)
	csRepo := repository.NewCBSSyncRecordRepository(ctx, dbPool, workMan)
	auditRepo := audit.NewRepository(ctx, dbPool, workMan)
	auditWriter := audit.NewWriter(evtsMan)

	// Business logic (identity lookups use SDK client directly)
	toBiz := business.NewTransferOrderBusiness(
		ctx,
		evtsMan,
		toRepo,
		csRepo,
		arRepo,
		platformClients,
		auditWriter,
		limitsCli,
		cfg.LimitsGateEnabledOperationsTransfer,
		cfg.LimitsGateModeOperationsTransfer,
	)
	prBiz := business.NewPaymentRoutingBusiness(
		ctx,
		evtsMan,
		ipRepo,
		toRepo,
		obRepo,
		arRepo,
		identityCli,
		platformClients,
		business.WithOrderExecutor(toBiz),
	)
	jobs := business.NewOperationsJobs(prBiz, toBiz, ipRepo, toRepo, cfg.Name())
	// Obligations are owned by stawi: it is the process that wires
	// ObligationBusiness into its workflow callbacks and creates the rows this
	// service allocates against. Operations only reads and consumes them.

	// ConnectRPC handler
	connectHandler := setupConnectServer(ctx, sm, dbPool, toBiz, prBiz, toRepo, ipRepo, jobs, auditCli)

	// Runtime options only — permissions/migrate are setup-only.
	return []frame.Option{
		frame.WithHTTPHandler(connectHandler),
		frame.WithRegisterSubscriber(cfg.PaymentReceivedName, cfg.PaymentReceivedURI,
			handlers.NewPaymentReceived(prBiz, cfg.Name())),
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

var (
	errIdentityClientRequired = errors.New("identity client is required but was not configured")
	errLedgerClientRequired   = errors.New("ledger client is required but was not configured")
	errPaymentClientRequired  = errors.New("payment client is required but was not configured: " +
		"payout orders would post to the ledger with no cash leaving")
)

// peerClients are the outbound service clients the runtime process needs.
type peerClients struct {
	identity identityv1connect.IdentityServiceClient
	platform *clients.PlatformClients
	limits   limitsv1connect.LimitsServiceClient
}

// setupPeerClients builds the peer clients. Identity and ledger are
// load-bearing: payment identification resolves every payer through identity
// and every transfer order posts a double-entry transaction, so a missing
// client fails startup instead of silently misrouting payments or dropping
// postings. The limits client is optional; when LimitsServiceURI is empty the
// gate is disabled at runtime.
func setupPeerClients(ctx context.Context, cfg aconfig.OperationsConfig) (peerClients, error) {
	identityCli, err := setupIdentityClient(ctx, cfg)
	if err != nil {
		return peerClients{}, fmt.Errorf("identity client: %w", err)
	}
	if identityCli == nil {
		return peerClients{}, errIdentityClientRequired
	}

	platformClients, err := clients.NewPlatformClients(ctx, &cfg, cfg.ServiceEndpoints())
	if err != nil {
		return peerClients{}, fmt.Errorf("platform clients: %w", err)
	}
	if platformClients == nil || platformClients.LedgerClient == nil {
		return peerClients{}, errLedgerClientRequired
	}
	if platformClients.PaymentClient == nil {
		return peerClients{}, errPaymentClientRequired
	}

	limitsCli, limitsErr := setupLimitsClient(ctx, cfg)
	if gateErr := consumer.RequireForGates(limitsCli, limitsErr, map[string]bool{
		"operations_transfer": cfg.LimitsGateEnabledOperationsTransfer,
	}); gateErr != nil {
		return peerClients{}, gateErr
	}

	return peerClients{identity: identityCli, platform: platformClients, limits: limitsCli}, nil
}

func setupIdentityClient(
	ctx context.Context,
	cfg aconfig.OperationsConfig,
) (identityv1connect.IdentityServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:  cfg.IdentityServiceURI,
		ServiceID: servicecatalog.ServiceIdentity,
	}, identityv1connect.NewIdentityServiceClient)
}

func setupConnectServer(
	ctx context.Context,
	sm security.Manager,
	_ pool.Pool,
	toBiz business.TransferOrderBusiness,
	prBiz business.PaymentRoutingBusiness,
	toRepo repository.TransferOrderRepository,
	ipRepo repository.IncomingPaymentRepository,
	jobs *business.OperationsJobs,
	auditCli auditv1connect.AuditServiceClient,
) http.Handler {
	opsHandler := handlers.NewOperationsServer(toBiz, prBiz, toRepo, ipRepo, jobs)

	auth := sm.GetAuthorizer(ctx)

	tenancyAccessChecker := authorizer.NewTenancyAccessChecker(auth, "tenancy_access")
	tenancyAccessInterceptor := connectInterceptors.NewTenancyAccessInterceptor(tenancyAccessChecker)

	sd := operationspb.File_operations_v1_operations_proto.Services().ByName("OperationsService")
	procMap := permissions.BuildProcedureMap(sd)
	svcPerms := permissions.ForService(sd)
	functionChecker := authorizer.NewFunctionChecker(auth, svcPerms.Namespace)
	functionAccessInterceptor := connectInterceptors.NewFunctionAccessInterceptor(functionChecker, procMap)

	opsAuditInterceptor := clients.AuditInterceptor("service_operations", auditCli)

	defaultInterceptorList, err := connectInterceptors.DefaultList(
		ctx, sm.GetAuthenticator(ctx),
		tenancyAccessInterceptor, tenantassert.Interceptor(), functionAccessInterceptor, opsAuditInterceptor)
	if err != nil {
		util.Log(ctx).WithError(err).Fatal("main -- Could not create default interceptors")
	}

	server := connect.NewServer(defaultInterceptorList...)
	operationsv1connect.RegisterOperationsServiceHandler(server, opsHandler)

	mux := http.NewServeMux()
	connecthttp.Mount(mux, server)

	return mux
}

func setupLimitsClient(
	ctx context.Context,
	cfg aconfig.OperationsConfig,
) (limitsv1connect.LimitsServiceClient, error) {
	return consumer.SetupClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.LimitsServiceURI,
		WorkloadAPITargetPath: cfg.LimitsServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceLimits,
	})
}
