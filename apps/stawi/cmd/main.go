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

	"buf.build/gen/go/antinvestor/audit/connectrpc/go/v2/audit/v1/auditv1connect"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	"github.com/antinvestor/common/v3"
	"github.com/antinvestor/common/v3/connection"
	"github.com/antinvestor/common/v3/permissions"
	"github.com/antinvestor/common/v3/servicecatalog"
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
	stawirepo "github.com/antinvestor/service-fintech/apps/stawi/service/repository"

	// Operations domain.
	opsbusiness "github.com/antinvestor/service-fintech/apps/operations/service/business"
	opsevents "github.com/antinvestor/service-fintech/apps/operations/service/events"
	opsrepo "github.com/antinvestor/service-fintech/apps/operations/service/repository"

	// Platform clients.
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/trustage"

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
	transferOrder   opsrepo.TransferOrderRepository
	obligation      opsrepo.ObligationRepository
	incomingPayment opsrepo.IncomingPaymentRepository
	accountRef      opsrepo.AccountRefRepository
	cbsSyncRecord   opsrepo.CBSSyncRecordRepository
	auditRepo       audit.Repository
}

type appBusinesses struct {
	group      stawibusiness.ClientGroupBusiness
	membership stawibusiness.MembershipBusiness
	tenure     stawibusiness.TenureBusiness
	period     stawibusiness.PeriodBusiness
	loanWindow stawibusiness.LoanWindowBusiness
	loanOffer  stawibusiness.LoanOfferBusiness
	payment    opsbusiness.PaymentRoutingBusiness
	obligation opsbusiness.ObligationBusiness
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

	registerSetupSteps(svc, &cfg)
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

	repos := initRepositories(ctx, dbPool, workMan)
	biz := initBusinesses(ctx, evtsMan, identityCli, platformClients, repos, cfg)
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
		ctx, product, evtsMan, repos.loanOffer, identityCli, platformClients,
	)
	periodAdapter := &periodAdapter{repo: repos.period}

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
	obligationBiz := opsbusiness.NewObligationBusiness(ctx, evtsMan, repos.obligation, identityCli, periodAdapter)

	return appBusinesses{
		group:      groupBiz,
		membership: membershipBiz,
		tenure:     tenureBiz,
		period:     periodBiz,
		loanWindow: loanWindowBiz,
		loanOffer:  loanOfferBiz,
		payment:    paymentBiz,
		obligation: obligationBiz,
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
		Group:      biz.group,
		Membership: biz.membership,
		Tenure:     biz.tenure,
		Period:     biz.period,
		LoanWindow: biz.loanWindow,
		LoanOffer:  biz.loanOffer,
		Payment:    biz.payment,
		Obligation: biz.obligation,
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
			opsevents.NewTransferOrderSave(ctx, repos.transferOrder),
			opsevents.NewObligationSave(ctx, repos.obligation),
			opsevents.NewIncomingPaymentSave(ctx, repos.incomingPayment),
			opsevents.NewAccountRefSave(ctx, repos.accountRef),
			opsevents.NewCBSSyncRecordSave(ctx, repos.cbsSyncRecord),
			audit.NewEventSave(ctx, repos.auditRepo),
		),
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
// Cross-domain adapters
// ---------------------------------------------------------------------------

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

// registerSetupSteps adds the setup-job steps: schema migration, then the
// group workflows.
func registerSetupSteps(svc *frame.Service, cfg *aconfig.StawiConfig) {
	// The advisory lock serialises overlapping migrate Jobs on the same
	// database so concurrent DDL cannot race.
	svc.Setup().RegisterFunc(setup.NameMigrate, func(ctx context.Context) error {
		return dbmigrate.Locked(ctx, svc.DatastoreManager(), cfg.Name(), func(ctx context.Context) error {
			return stawirepo.Migrate(ctx, svc.DatastoreManager(), cfg.GetDatabaseMigrationPath())
		})
	})
	// Stawi's group workflows are registered by the setup job, never at
	// runtime start. A failed sync is logged, as it always has been, so it
	// cannot block a deploy of the group callbacks themselves.
	svc.Setup().RegisterFunc(trustage.StepName, func(ctx context.Context) error {
		if syncErr := trustage.SyncWorkflows(ctx, cfg, false); syncErr != nil {
			util.Log(ctx).WithError(syncErr).Warn("trustage workflow sync failed")
		}
		return nil
	})
}
