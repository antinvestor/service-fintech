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

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitspb "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/antinvestor/common/permissions"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/config"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/frame/security/authorizer"
	connectInterceptors "github.com/pitabwire/frame/security/interceptors/connect"
	"github.com/pitabwire/frame/security/interceptors/httptor"
	"github.com/pitabwire/util"

	auditmw "github.com/antinvestor/common/audit"

	aconfig "github.com/antinvestor/service-fintech/apps/limits/config"
	"github.com/antinvestor/service-fintech/apps/limits/service/business"
	"github.com/antinvestor/service-fintech/apps/limits/service/handlers"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

const namespaceTenancyAccess = "tenancy_access"

const (
	// reaperBatchSize bounds how many rows each reaper pass processes.
	reaperBatchSize = 1000
	// reaperInterval is how often the reservation/approval reapers run.
	reaperInterval = 30 * time.Second
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

	// Handle database migration if requested.
	if handleDatabaseMigration(ctx, dbManager, cfg) {
		return
	}

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
	candidateRepo := business.NewPolicyCache(candidatePolicyRepo)
	auditRepo := audit.NewRepository(ctx, dbPool, workMan)

	// ─── Audit infrastructure ─────────────────────────────────────────
	auditWriter := audit.NewWriter(evtsMan)
	auditing := business.NewAuditing(auditWriter)
	eventSave := audit.NewEventSave(ctx, auditRepo)

	// ─── Business layer ───────────────────────────────────────────────
	policyBiz := business.NewPolicyBusiness(policyRepo, policyVerRepo, evtsMan, auditing, dbPool, candidateRepo)
	evaluator := business.NewEvaluator(reservationRepo, ledgerRepo)
	resolver := business.NewAttributeResolver(
		subjAttrRepo,
		nil, // identity client wired in a later task
		time.Duration(cfg.SubjectAttributeCacheTTLSeconds)*time.Second,
	)
	reservationBiz := business.NewReservationBusiness(
		reservationRepo, ledgerRepo, candidateRepo, approvalRepo, policyRepo,
		evaluator, resolver, auditing, dbPool, evtsMan,
	)
	approvalBiz := business.NewApprovalBusiness(
		approvalRepo, decisionRepo, reservationRepo, policyRepo,
		evaluator, auditing, evtsMan, dbPool,
	)
	ledgerSearchBiz := business.NewLedgerSearchBusiness(ledgerRepo)
	auditSearchBiz := business.NewAuditSearchBusiness(dbPool)

	// ─── Handlers ─────────────────────────────────────────────────────
	runtimeH := handlers.NewRuntimeService(reservationBiz)
	adminH := handlers.NewAdminService(policyBiz, approvalBiz, ledgerSearchBiz, auditSearchBiz)

	// ─── Archival job ─────────────────────────────────────────────────
	archivalBiz := business.NewArchival(reservationRepo, ledgerRepo)
	archivalH := handlers.NewArchivalHandler(archivalBiz)

	// ─── Connect RPC server ────────────────────────────────────────────
	connectHandler := setupConnectServer(ctx, sm, dbPool, runtimeH, adminH, archivalH)

	// ─── Reapers ──────────────────────────────────────────────────────
	resvReaper := business.NewReservationReaper(reservationRepo, auditing, reaperBatchSize)
	approvalReaper := business.NewApprovalReaper(approvalRepo, reservationRepo, auditing, reaperBatchSize, evtsMan)
	go runPeriodically(ctx, reaperInterval, resvReaper.Run)
	go runPeriodically(ctx, reaperInterval, approvalReaper.Run)

	// ─── Permission registration + EventSave + Run ────────────────────
	limitsAdminSD := limitspb.File_limits_v1_limits_proto.Services().ByName("LimitsAdminService")
	limitsRuntimeSD := limitspb.File_limits_v1_limits_proto.Services().ByName("LimitsService")

	serviceOptions := []frame.Option{
		frame.WithHTTPHandler(connectHandler),
		frame.WithPermissionRegistration(limitsAdminSD),
		frame.WithPermissionRegistration(limitsRuntimeSD),
		frame.WithRegisterEvents(eventSave),
	}

	svc.Init(ctx, serviceOptions...)

	err = svc.Run(ctx, "")
	if err != nil {
		log.WithError(err).Fatal("could not run Server")
	}
}

func handleDatabaseMigration(
	ctx context.Context,
	dbManager datastore.Manager,
	cfg aconfig.LimitsConfig,
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
) http.Handler {
	auth := sm.GetAuthorizer(ctx)
	authenticator := sm.GetAuthenticator(ctx)
	limitsAuditInterceptor := auditmw.NewInterceptor("service_limits", nil)

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

	runtimePath, runtimeHandler := limitsv1connect.NewLimitsServiceHandler(
		runtimeH,
		connect.WithInterceptors(runtimeInterceptors...),
	)

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

	adminPath, adminHandler := limitsv1connect.NewLimitsAdminServiceHandler(
		adminH,
		connect.WithInterceptors(adminInterceptors...),
	)

	mux := http.NewServeMux()
	mux.Handle(runtimePath, runtimeHandler)
	mux.Handle(adminPath, adminHandler)
	if archivalH != nil {
		// Wrap with the same authenticator the Connect interceptor stack uses so
		// that /admin/archive is not a bare, unauthenticated mount point.
		mux.Handle("/admin/archive", httptor.AuthenticationMiddleware(archivalH, authenticator))
	}

	return mux
}

// runPeriodically calls fn on the given interval until ctx is cancelled.
func runPeriodically(ctx context.Context, interval time.Duration, fn func(context.Context) error) {
	t := time.NewTicker(interval)
	defer t.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-t.C:
			if err := fn(ctx); err != nil {
				util.Log(ctx).WithError(err).Error("reaper run failed")
			}
		}
	}
}
