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
	"time"

	"buf.build/gen/go/antinvestor/audit/connectrpc/go/v2/audit/v1/auditv1connect"
	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	limitspb "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"buf.build/gen/go/antinvestor/tenancy/connectrpc/go/v2/tenancy/v1/tenancyv1connect"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	common "github.com/antinvestor/common/v3"
	"github.com/antinvestor/common/v3/connection"
	"github.com/antinvestor/common/v3/permissions"
	"github.com/antinvestor/common/v3/servicecatalog"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/config"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/security/authorizer"
	connectInterceptors "github.com/pitabwire/frame/v3/security/interceptors/connect"
	"github.com/pitabwire/frame/v3/security/interceptors/httptor"
	"github.com/pitabwire/frame/v3/setup"
	"github.com/pitabwire/util"

	aconfig "github.com/antinvestor/service-fintech/apps/limits/config"
	"github.com/antinvestor/service-fintech/apps/limits/service/business"
	"github.com/antinvestor/service-fintech/apps/limits/service/handlers"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/bootcheck"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
	"github.com/antinvestor/service-fintech/pkg/trustage"
)

const namespaceTenancyAccess = "tenancy_access"

const (
	// archivalPath is the Trustage-driven archival entry point.
	archivalPath = "/admin/archive"
	// archivalPermission is the admin permission required to run archival. It
	// is the mutating control-plane permission already declared in the proto
	// service_permissions; a dedicated limits_archive permit would be better
	// and is listed as a proto follow-up.
	archivalPermission = "limits_policy_manage"
)

const (
	// reaperBatchSize bounds how many rows each reaper pass processes.
	reaperBatchSize = 1000
)

//nolint:funlen // linear service wiring; splitting hurts readability
func main() {
	tmpCtx := context.Background()

	cfg, err := config.LoadWithOIDC[aconfig.LimitsConfig](tmpCtx)
	if err != nil {
		util.Log(tmpCtx).With("err", err).Error("could not process configs")
		return
	}

	if cfg.Name() == "" {
		cfg.ServiceName = "service_limits"
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
	// Expired reservations and approvals are reaped only when trustage fires
	// their schedules, so a deploy that cannot register them fails rather
	// than ship holds that never lapse.
	svc.Setup().RegisterFunc(trustage.StepName, func(ctx context.Context) error {
		return trustage.SyncWorkflows(ctx, &cfg, cfg.IsRunSecurely())
	})
	defer svc.Stop(ctx)
	log := util.Log(ctx)

	// Frame setup job (DO_SETUP / argv setup): schema + permissions only.
	// Register only LimitsAdminService — it owns service_permissions for
	// service_limits. LimitsService has method_permissions only; a second
	// WithPermissionRegistration would overwrite the setup step and skip.
	limitsAdminSD := limitspb.File_limits_v1_limits_proto.Services().ByName("LimitsAdminService")
	if frame.ShouldRunSetup(&cfg) {
		svc.Init(ctx, frame.WithPermissionRegistration(limitsAdminSD))
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

	// Get database pool.
	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	if dbPool == nil {
		log.Error("Database pool is nil - check DATABASE_PRIMARY_URL environment variable")
		return
	}

	// ─── Repositories ──────────────────────────────────────────────────
	policyRepo := repository.NewPolicyRepository(ctx, dbPool, workMan)
	policyVerRepo := repository.NewPolicyVersionRepository(ctx, dbPool, workMan)
	reservationRepo := repository.NewReservationRepository(ctx, dbPool, workMan)
	ledgerRepo := repository.NewLedgerRepository(ctx, dbPool, workMan)
	approvalRepo := repository.NewApprovalRequestRepository(ctx, dbPool, workMan)
	decisionRepo := repository.NewApprovalDecisionRepository(ctx, dbPool, workMan)
	subjAttrRepo := repository.NewSubjectAttributeRepository(ctx, dbPool, workMan)
	candidatePolicyRepo := repository.NewCandidatePolicyRepository(dbPool)
	candidateRepo := business.NewPolicyCache(
		candidatePolicyRepo,
		time.Duration(cfg.PolicyCacheTTLSeconds)*time.Second,
	)
	auditRepo := audit.NewRepository(ctx, dbPool, workMan)

	// ─── Audit infrastructure ─────────────────────────────────────────
	auditWriter := audit.NewWriter(evtsMan)
	auditing := business.NewAuditing(auditWriter)
	eventSave := audit.NewEventSave(ctx, auditRepo)

	// ─── Business layer ───────────────────────────────────────────────
	policyBiz := business.NewPolicyBusiness(policyRepo, policyVerRepo, evtsMan, auditing, dbPool, candidateRepo)
	evaluator := business.NewEvaluator(reservationRepo, ledgerRepo)
	identityClient, identityErr := setupIdentityClient(ctx, cfg)
	if identityErr != nil {
		// Attribute-filtered enforce policies fail closed without identity, so
		// starting without it would deny every matching intent.
		log.WithError(identityErr).Fatal("could not create identity client")
	}
	fieldClient, fieldErr := setupFieldClient(ctx, cfg)
	if fieldErr != nil {
		// Borrowers (CLIENT subjects from loans and savings) live in the field
		// service; without it a client-tier policy could never match.
		log.WithError(fieldErr).Fatal("could not create field client")
	}
	resolver := business.NewAttributeResolver(
		subjAttrRepo,
		identityClient,
		time.Duration(cfg.SubjectAttributeCacheTTLSeconds)*time.Second,
		business.WithFieldClients(fieldClient),
	)
	tenancyClient, tenancyErr := setupTenancyClient(ctx, cfg)
	if tenancyErr != nil {
		// Without the partition tree an ancestor's cap could not be applied
		// to its descendants; refuse to serve rather than under-enforce.
		log.WithError(tenancyErr).Fatal("could not create tenancy client")
	}
	ancestry := business.NewPartitionAncestry(
		tenancyClient,
		time.Duration(cfg.PartitionChainCacheTTLSeconds)*time.Second,
	)
	reservationBiz := business.NewReservationBusiness(
		reservationRepo, ledgerRepo, candidateRepo, approvalRepo, policyRepo,
		evaluator, resolver, auditing, dbPool, evtsMan,
		business.WithPartitionAncestry(ancestry),
	)
	// The approver-tier role check needs to consult limits_approval_override in
	// the service's own namespace, so it gets its own function checker.
	adminPermissions := authorizer.NewFunctionChecker(
		sm.GetAuthorizer(ctx),
		permissions.ForService(limitsAdminSD).Namespace,
	)
	approvalBiz := business.NewApprovalBusiness(
		approvalRepo, decisionRepo, reservationRepo, policyRepo,
		evaluator, auditing, evtsMan, dbPool, adminPermissions,
	)
	ledgerSearchBiz := business.NewLedgerSearchBusiness(ledgerRepo)
	auditSearchBiz := business.NewAuditSearchBusiness(dbPool)

	// ─── Handlers ─────────────────────────────────────────────────────
	runtimeH := handlers.NewRuntimeService(reservationBiz)
	// ─── Reapers ──────────────────────────────────────────────────────
	// Run only when trustage fires their schedules (LimitsJobRun); each pass
	// holds a Postgres advisory lock so overlapping runs reap once.
	resvReaper := business.NewReservationReaper(
		reservationRepo, auditing, reaperBatchSize, business.WithReaperPool(dbPool),
	)
	approvalReaper := business.NewApprovalReaper(
		approvalRepo, reservationRepo, auditing, reaperBatchSize, evtsMan, business.WithReaperPool(dbPool),
	)
	limitsJobs := business.NewLimitsJobs(resvReaper, approvalReaper, dbPool)

	adminH := handlers.NewAdminService(policyBiz, approvalBiz, ledgerSearchBiz, auditSearchBiz).
		WithJobs(limitsJobs)

	// ─── Archival job ─────────────────────────────────────────────────
	archivalBiz := business.NewArchival(
		reservationRepo, ledgerRepo, policyRepo,
		time.Duration(cfg.ArchivalReservationRetentionHours)*time.Hour,
		time.Duration(cfg.ArchivalLedgerRetentionHours)*time.Hour,
	)
	archivalH := handlers.NewArchivalHandler(archivalBiz)

	// ─── Connect RPC server ────────────────────────────────────────────
	connectHandler := setupConnectServer(ctx, sm, dbPool, runtimeH, adminH, archivalH, auditCli)

	// Runtime: HTTP + queue handlers only. Migrate/permissions run solely via
	// the setup Job path above (ShouldRunSetup).
	serviceOptions := []frame.Option{
		frame.WithHTTPHandler(connectHandler),
		frame.WithRegisterEvents(eventSave, business.NewPolicyInvalidateHandler(candidateRepo)),
	}

	// Per-replica policy-cache invalidation. Every replica subscribes under
	// its own consumer reference so a policy change fans out to all of them;
	// without it a replica's cache still converges within POLICY_CACHE_TTL_SECONDS.
	broadcast, bErr := business.NewPolicyInvalidateBroadcast(
		candidateRepo, cfg.GetEventsQueueSubscribeURL(), business.InstanceID(),
	)
	if bErr != nil {
		log.WithError(bErr).
			Warn("main -- policy invalidation broadcast disabled; caches converge within POLICY_CACHE_TTL_SECONDS")
	} else {
		serviceOptions = append(serviceOptions,
			frame.WithRegisterSubscriber(broadcast.Reference, broadcast.URL, broadcast.Worker))
	}

	svc.Init(ctx, serviceOptions...)

	err = svc.Run(ctx, "")
	if err != nil {
		log.WithError(err).Fatal("could not run Server")
	}
}

// setupConnectServer mounts both LimitsService (runtime) and LimitsAdminService
// (control plane) on the provided HTTP mux, each wrapped in the standard
// authenticate + RBAC + audit interceptor stack. archivalH is mounted at
// POST /admin/archive for Trustage-driven archival runs.
func setupConnectServer(
	ctx context.Context,
	sm security.Manager,
	_ pool.Pool,
	runtimeH *handlers.RuntimeService,
	adminH *handlers.AdminService,
	archivalH *handlers.ArchivalHandler,
	auditCli auditv1connect.AuditServiceClient,
) http.Handler {
	auth := sm.GetAuthorizer(ctx)
	authenticator := sm.GetAuthenticator(ctx)
	limitsAuditInterceptor := clients.AuditInterceptor("service_limits", auditCli)

	// ─── Runtime service (LimitsService) ─────────────────────────────
	runtimeSD := limitspb.File_limits_v1_limits_proto.Services().ByName("LimitsService")
	runtimeProcMap := permissions.BuildProcedureMap(runtimeSD)
	runtimeSvcPerms := permissions.ForService(runtimeSD)
	runtimeFunctionChecker := authorizer.NewFunctionChecker(auth, runtimeSvcPerms.Namespace)
	runtimeFunctionAccessInterceptor := connectInterceptors.NewFunctionAccessInterceptor(
		runtimeFunctionChecker,
		runtimeProcMap,
	)

	runtimeTenancyChecker := authorizer.NewTenancyAccessChecker(auth, namespaceTenancyAccess)
	runtimeTenancyInterceptor := connectInterceptors.NewTenancyAccessInterceptor(runtimeTenancyChecker)

	runtimeInterceptors, err := connectInterceptors.DefaultList(
		ctx, authenticator,
		runtimeTenancyInterceptor, runtimeFunctionAccessInterceptor, limitsAuditInterceptor,
		handlers.TenantAssertionInterceptor(),
	)
	if err != nil {
		util.Log(ctx).WithError(err).Fatal("main -- Could not create runtime interceptors")
	}

	// Each service keeps its own interceptor chain, so each gets its own
	// server; both mount on the same mux.
	runtimeServer := connect.NewServer(runtimeInterceptors...)
	limitsv1connect.RegisterLimitsServiceHandler(runtimeServer, runtimeH)

	// ─── Admin service (LimitsAdminService) ───────────────────────────
	adminSD := limitspb.File_limits_v1_limits_proto.Services().ByName("LimitsAdminService")
	adminProcMap := permissions.BuildProcedureMap(adminSD)
	adminSvcPerms := permissions.ForService(adminSD)
	adminFunctionChecker := authorizer.NewFunctionChecker(auth, adminSvcPerms.Namespace)
	adminFunctionAccessInterceptor := connectInterceptors.NewFunctionAccessInterceptor(
		adminFunctionChecker,
		adminProcMap,
	)

	adminTenancyChecker := authorizer.NewTenancyAccessChecker(auth, namespaceTenancyAccess)
	adminTenancyInterceptor := connectInterceptors.NewTenancyAccessInterceptor(adminTenancyChecker)

	adminInterceptors, err := connectInterceptors.DefaultList(
		ctx, authenticator,
		adminTenancyInterceptor, adminFunctionAccessInterceptor, limitsAuditInterceptor,
		handlers.TenantAssertionInterceptor(),
	)
	if err != nil {
		util.Log(ctx).WithError(err).Fatal("main -- Could not create admin interceptors")
	}

	adminServer := connect.NewServer(adminInterceptors...)
	limitsv1connect.RegisterLimitsAdminServiceHandler(adminServer, adminH)

	mux := http.NewServeMux()
	connecthttp.Mount(mux, runtimeServer)
	connecthttp.Mount(mux, adminServer)
	if archivalH != nil {
		// /admin/archive hard-deletes across every tenant. Authentication alone
		// is not a control: it is mounted behind the same function-access check
		// the admin RPCs use, requiring limits_policy_manage, and the handler
		// itself additionally rejects non-service principals.
		archivalGuarded := httptor.FunctionAccessMiddleware(
			archivalH,
			adminFunctionChecker,
			map[string][]string{archivalPath: {archivalPermission}},
		)
		mux.Handle(archivalPath, httptor.AuthenticationMiddleware(archivalGuarded, authenticator))
	}

	return mux
}

// setupIdentityClient dials the identity service used to resolve subject
// attributes for attribute-filtered policies.
func setupIdentityClient(
	ctx context.Context,
	cfg aconfig.LimitsConfig,
) (identityv1connect.IdentityServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:  cfg.IdentityServiceURI,
		ServiceID: servicecatalog.ServiceIdentity,
	}, identityv1connect.NewIdentityServiceClient)
}

// setupFieldClient dials the field service, served by the identity binary,
// which owns the borrowers sent as CLIENT subjects.
func setupFieldClient(
	ctx context.Context,
	cfg aconfig.LimitsConfig,
) (fieldv1connect.FieldServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:  cfg.IdentityServiceURI,
		ServiceID: servicecatalog.ServiceIdentity,
	}, fieldv1connect.NewFieldServiceClient)
}

// setupTenancyClient dials the tenancy service that owns the partition tree.
func setupTenancyClient(
	ctx context.Context,
	cfg aconfig.LimitsConfig,
) (tenancyv1connect.TenancyServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.TenancyServiceURI,
		WorkloadAPITargetPath: cfg.TenancyServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceTenancy,
	}, tenancyv1connect.NewTenancyServiceClient)
}
