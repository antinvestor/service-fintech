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

// Package main is the entry point for the seed direct-to-client
// lending service. Seed composes the existing fintech platform
// primitives — identity, loans, operations, the ledger —
// behind a customer-facing RequestLoan API and a credit profile
// progression that rewards successful repayments with higher limits.
//
// The service boots in two modes:
//
//   - Migrate mode: runs GORM migrations for the seed tables
//     (seed_credit_profiles, seed_credit_tiers, seed_loan_requests)
//     plus the shared audit_events table, then exits.
//
//   - Serve mode: runs the HTTP server with the customer-facing and
//     internal endpoints registered.
//
// KYC verification and loan creation are wired to the identity and loans
// services. The development stubs live behind the `dev` build tag and are not
// part of a release binary; main refuses to start when either peer is
// unconfigured.
package main

import (
	"context"
	"errors"
	"net/http"
	"strings"

	"buf.build/gen/go/antinvestor/audit/connectrpc/go/audit/v1/auditv1connect"
	"buf.build/gen/go/antinvestor/field/connectrpc/go/field/v1/fieldv1connect"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/identity/v1/identityv1connect"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/loans/v1/loansv1connect"
	"github.com/antinvestor/common/v2"
	"github.com/antinvestor/common/v2/connection"
	"github.com/antinvestor/common/v2/permissions"
	"github.com/antinvestor/common/v2/servicecatalog"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/config"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/frame/v2/security/authorizer"
	"github.com/pitabwire/frame/v2/security/interceptors/httptor"
	"github.com/pitabwire/frame/v2/setup"
	"github.com/pitabwire/frame/v2/tenancy"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/reflect/protoreflect"

	aconfig "github.com/antinvestor/service-fintech/apps/seed/config"
	"github.com/antinvestor/service-fintech/apps/seed/service/business"
	seedevents "github.com/antinvestor/service-fintech/apps/seed/service/events"
	seedhandlers "github.com/antinvestor/service-fintech/apps/seed/service/handlers"
	"github.com/antinvestor/service-fintech/apps/seed/service/repository"
	seedv1 "github.com/antinvestor/service-fintech/gen/go/seed/protocolbuffers/go/seed/v1"
	"github.com/antinvestor/service-fintech/pkg/bootcheck"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
	"github.com/antinvestor/service-fintech/pkg/tenantassert"

	"github.com/antinvestor/service-fintech/pkg/audit"
)

// namespaceTenancyAccess is the Keto namespace carrying partition-level data
// access for every fintech service.
const namespaceTenancyAccess = "tenancy_access"

// manifestServiceName is the proto service in seed.v1 that carries the
// service_permissions manifest for the HTTP routes.
const manifestServiceName = "SeedService"

var errNoDatabasePool = errors.New("no database pool configured")

func main() {
	tmpCtx := context.Background()

	cfg, err := config.LoadWithOIDC[aconfig.SeedConfig](tmpCtx)
	if err != nil {
		util.Log(tmpCtx).With("err", err).Error("could not process configs")
		return
	}
	if cfg.Name() == "" {
		cfg.ServiceName = "service_seed"
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

	svc.Setup().RegisterFunc(setup.NameMigrate, func(ctx context.Context) error {
		return runSetup(ctx, svc, &cfg)
	})
	defer svc.Stop(ctx)
	log := util.Log(ctx)

	// The seed.v1 manifest owns the service_seed permission namespace: it names
	// every HTTP route and the permission each requires.
	manifestSD := seedv1.File_seed_v1_seed_proto.Services().ByName(manifestServiceName)

	// Setup job (DO_SETUP / argv setup): schema, the default credit ladder and
	// permission manifest registration, then exit. Runtime never re-registers
	// permissions.
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

	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	if dbPool == nil {
		log.Error("main -- database pool is nil; check DATABASE_PRIMARY_URL")
		return
	}

	// Repositories.
	cpRepo := repository.NewCreditProfileRepository(ctx, dbPool, workMan)
	tierRepo := repository.NewCreditTierRepository(ctx, dbPool, workMan)
	lrRepo := repository.NewLoanRequestRepository(ctx, dbPool, workMan)
	auditRepo := audit.NewRepository(ctx, dbPool, workMan)

	auditWriter := audit.NewWriter(evtsMan)

	kycVerifier, loanCreator, clientResolver := buildPeers(ctx, &cfg, log)

	cpBusiness := business.NewCreditProfileBusiness(ctx, cpRepo, tierRepo, evtsMan, auditWriter)
	lrBusiness := business.NewLoanRequestBusiness(
		ctx,
		cpBusiness,
		cpRepo,
		lrRepo,
		tierRepo,
		kycVerifier,
		loanCreator,
		auditWriter,
	)

	serviceOptions := []frame.Option{
		frame.WithHTTPHandler(
			buildHandler(ctx, sm, manifestSD, lrBusiness, cpBusiness, clientResolver, cfg.SeedStaffRole, auditCli),
		),
		frame.WithRegisterEvents(
			seedevents.NewCreditProfileSave(ctx, cpRepo),
			seedevents.NewLoanRequestSave(ctx, lrRepo),
			audit.NewEventSave(ctx, auditRepo),
		),
	}

	svc.Init(ctx, serviceOptions...)

	if runErr := svc.Run(ctx, ""); runErr != nil {
		log.WithError(runErr).Fatal("could not run seed server")
	}
}

// buildPeers wires the platform services seed depends on. Seed cannot make a
// credit decision without identity, and cannot originate a loan without the
// loans service, so a missing peer stops the process rather than degrading it.
func buildPeers(
	ctx context.Context,
	cfg *aconfig.SeedConfig,
	log *util.LogEntry,
) (business.KYCVerifier, business.LoanCreator, business.ClientResolver) {
	identityCli, idErr := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
		Endpoint:  cfg.IdentityServiceURI,
		ServiceID: servicecatalog.ServiceIdentity,
	}, identityv1connect.NewIdentityServiceClient)
	if idErr != nil {
		log.WithError(idErr).Fatal("main -- identity client is required but could not be created")
	}
	// Clients live on the field service, which the identity binary also serves.
	fieldCli, fieldErr := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
		Endpoint:  cfg.IdentityServiceURI,
		ServiceID: servicecatalog.ServiceIdentity,
	}, fieldv1connect.NewFieldServiceClient)
	if fieldErr != nil {
		log.WithError(fieldErr).Fatal("main -- field client is required but could not be created")
	}
	loansCli, loanErr := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
		Endpoint:  cfg.LoanMgmtServiceURI,
		ServiceID: servicecatalog.ServiceLoans,
	}, loansv1connect.NewLoanManagementServiceClient)
	if loanErr != nil {
		log.WithError(loanErr).Fatal("main -- loans client is required but could not be created")
	}

	return business.NewIdentityKYCVerifier(identityCli, splitCSV(cfg.SeedKYCRequiredFields)),
		business.NewLoansLoanCreator(loansCli),
		business.NewIdentityClientResolver(fieldCli)
}

// runSetup migrates the schema and provisions the default credit ladder. Any
// failure fails the setup job so the deployment stops instead of serving on an
// unprovisioned database.
func runSetup(ctx context.Context, svc *frame.Service, cfg *aconfig.SeedConfig) error {
	dbManager := svc.DatastoreManager()
	// The advisory lock serialises overlapping migrate Jobs on the same
	// database so concurrent DDL cannot race.
	err := dbmigrate.Locked(ctx, dbManager, cfg.Name(), func(ctx context.Context) error {
		return repository.Migrate(ctx, dbManager, cfg.GetDatabaseMigrationPath())
	})
	if err != nil {
		return err
	}

	// An empty override falls back to repository.DefaultTierLadder.
	tiers, err := repository.ParseTierLadder(cfg.SeedCreditTierLadder, cfg.SeedProductID, cfg.SeedCurrencyCode)
	if err != nil {
		return err
	}
	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	if dbPool == nil {
		return errNoDatabasePool
	}
	if err = repository.EnsureTierLadder(ctx, dbPool, tiers); err != nil {
		return err
	}

	return nil
}

// buildHandler puts every seed endpoint behind the frame security chain.
// Outermost first: context setup → authentication (JWT bearer) → tenancy
// claims binding → partition data access (Plane 1) → internal-principal
// tenant assertion → audit → per-route function access (Plane 2, permissions
// from the seed.v1 manifest) → mux. Only the health probe is left open.
func buildHandler(
	ctx context.Context,
	sm security.Manager,
	manifestSD protoreflect.ServiceDescriptor,
	lrBusiness business.LoanRequestBusiness,
	cpBusiness business.CreditProfileBusiness,
	clientResolver business.ClientResolver,
	staffRole string,
	auditCli auditv1connect.AuditServiceClient,
) http.Handler {
	mux := http.NewServeMux()
	seedhandlers.NewServer(lrBusiness, cpBusiness, clientResolver, staffRole).Register(mux)

	routes, routesErr := seedhandlers.BuildRoutePermissions(manifestSD)
	if routesErr != nil {
		util.Log(ctx).WithError(routesErr).Fatal("main -- seed permission manifest is invalid")
	}

	auth := sm.GetAuthorizer(ctx)
	tenancyChecker := authorizer.NewTenancyAccessChecker(auth, namespaceTenancyAccess)
	functionChecker := authorizer.NewFunctionChecker(auth, permissions.ForService(manifestSD).Namespace)

	secured := seedhandlers.FunctionAccessMiddleware(mux, functionChecker, routes)
	secured = clients.AuditHTTPMiddleware("service_seed", auditCli)(secured)
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

// splitCSV turns a comma-separated env value into a trimmed slice.
func splitCSV(value string) []string {
	var result []string
	for _, part := range strings.Split(value, ",") {
		if trimmed := strings.TrimSpace(part); trimmed != "" {
			result = append(result, trimmed)
		}
	}
	return result
}
