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

	"buf.build/gen/go/antinvestor/audit/connectrpc/go/audit/v1/auditv1connect"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	"buf.build/gen/go/antinvestor/savings/connectrpc/go/savings/v1/savingsv1connect"
	savingspb "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"connectrpc.com/connect"
	"github.com/antinvestor/common/v2"
	"github.com/antinvestor/common/v2/connection"
	"github.com/antinvestor/common/v2/permissions"
	"github.com/antinvestor/common/v2/servicecatalog"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/config"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/frame/v2/security/authorizer"
	connectInterceptors "github.com/pitabwire/frame/v2/security/interceptors/connect"
	"github.com/pitabwire/frame/v2/setup"
	"github.com/pitabwire/util"

	aconfig "github.com/antinvestor/service-fintech/apps/savings/config"
	"github.com/antinvestor/service-fintech/apps/savings/service/authz"
	"github.com/antinvestor/service-fintech/apps/savings/service/business"
	savingsevents "github.com/antinvestor/service-fintech/apps/savings/service/events"
	"github.com/antinvestor/service-fintech/apps/savings/service/handlers"
	"github.com/antinvestor/service-fintech/apps/savings/service/repository"
	"github.com/antinvestor/service-fintech/pkg/bootcheck"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
	"github.com/antinvestor/service-fintech/pkg/tenantassert"

	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/limits/consumer"
)

// accrualPeriod is the closing period the accrual engine settles: one UTC day.
const accrualPeriod = 24 * time.Hour

//nolint:funlen // linear service wiring; splitting hurts readability
func main() {
	tmpCtx := context.Background()

	cfg, err := config.LoadWithOIDC[aconfig.SavingsConfig](tmpCtx)
	if err != nil {
		util.Log(tmpCtx).With("err", err).Error("could not process configs")
		return
	}

	if cfg.Name() == "" {
		cfg.ServiceName = "service_savings"
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
	defer svc.Stop(ctx)
	log := util.Log(ctx)

	// Frame setup job (DO_SETUP / argv setup): migrate + permissions only.
	// Exit before peer clients / heavy runtime wiring (Cloud Run setup Job).
	sd := savingspb.File_savings_v1_savings_proto.Services().ByName("SavingsService")
	if frame.ShouldRunSetup(&cfg) {
		svc.Init(ctx, frame.WithPermissionRegistration(sd))
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

	// Initialise repositories
	spRepo := repository.NewSavingsProductRepository(ctx, dbPool, workMan)
	saRepo := repository.NewSavingsAccountRepository(ctx, dbPool, workMan)
	depRepo := repository.NewDepositRepository(ctx, dbPool, workMan)
	wdRepo := repository.NewWithdrawalRepository(ctx, dbPool, workMan)
	iaRepo := repository.NewInterestAccrualRepository(ctx, dbPool, workMan)
	sbRepo := repository.NewSavingsBalanceRepository(ctx, dbPool, workMan)
	auditRepo := audit.NewRepository(ctx, dbPool, workMan)
	auditWriter := audit.NewWriter(evtsMan)

	// Operations client. Every deposit / withdrawal posts a transfer order via
	// this client so the external ledger mirrors savings state. Refuse to
	// start if it cannot be wired: running without it would drop money
	// movements on the floor.
	operationsCli, opsErr := setupOperationsClient(ctx, cfg)
	if opsErr != nil {
		log.WithError(opsErr).Fatal("main -- could not initialise operations client")
	}

	// Limits client. Optional — when LimitsServiceURI is empty, SetupClient
	// returns nil and both gates are disabled at runtime regardless of the
	// config flags.
	limitsCli, limitsErr := setupLimitsClient(ctx, cfg)
	if gateErr := consumer.RequireForGates(limitsCli, limitsErr, map[string]bool{
		"savings_deposit":    cfg.LimitsGateEnabledSavingsDeposit,
		"savings_withdrawal": cfg.LimitsGateEnabledSavingsWithdrawal,
	}); gateErr != nil {
		log.WithError(gateErr).Fatal("main -- transaction limits cannot be enforced")
	}

	// Create business logic with all dependencies
	spBusiness := business.NewSavingsProductBusiness(ctx, evtsMan, spRepo)
	saBusiness := business.NewSavingsAccountBusiness(ctx, evtsMan, saRepo, spRepo, depRepo, wdRepo, iaRepo, sbRepo)
	depBusiness := business.NewDepositBusiness(
		ctx, depRepo, saRepo, operationsCli, auditWriter,
		limitsCli, cfg.LimitsGateEnabledSavingsDeposit, cfg.LimitsGateModeSavingsDeposit,
	)
	wdBusiness := business.NewWithdrawalBusiness(
		ctx,
		wdRepo,
		saRepo,
		operationsCli,
		auditWriter,
		limitsCli,
		cfg.LimitsGateEnabledSavingsWithdrawal,
		cfg.LimitsGateModeSavingsWithdrawal,
	)
	iaBusiness := business.NewInterestAccrualBusiness(
		ctx,
		iaRepo,
		saRepo,
		spRepo,
		sbRepo,
		evtsMan,
		operationsCli,
		auditWriter,
	)

	// Setup Connect RPC servers
	connectHandler := setupConnectServer(ctx, sm, dbPool,
		spBusiness, saBusiness, depBusiness, wdBusiness, iaBusiness, auditCli)

	// Runtime: HTTP + queue handlers only. Permissions/migrate are setup-only.
	serviceOptions := []frame.Option{
		frame.WithHTTPHandler(connectHandler),
		frame.WithRegisterEvents(
			savingsevents.NewSavingsProductSave(ctx, spRepo),
			savingsevents.NewSavingsAccountSave(ctx, saRepo),
			savingsevents.NewDepositSave(ctx, depRepo),
			savingsevents.NewWithdrawalSave(ctx, wdRepo),
			savingsevents.NewInterestAccrualSave(ctx, iaRepo),
			audit.NewEventSave(ctx, auditRepo),
		),
	}

	svc.Init(ctx, serviceOptions...)

	if cfg.InterestAccrualEnabled {
		go runInterestAccrual(ctx, iaBusiness, cfg.InterestAccrualInterval)
	}

	err = svc.Run(ctx, "")
	if err != nil {
		log.WithError(err).Fatal("could not run Server")
	}
}

// runInterestAccrual drives the accrual engine until ctx is cancelled. Each
// pass accrues the most recently closed UTC day; Accrue is idempotent on
// (savings_account_id, period_end), so overlapping passes and restarts post
// interest exactly once per account per day.
func runInterestAccrual(ctx context.Context, iaBusiness business.InterestAccrualBusiness, interval time.Duration) {
	if interval <= 0 {
		interval = time.Hour
	}
	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			periodEnd := time.Now().UTC().Truncate(accrualPeriod)
			periodStart := periodEnd.Add(-accrualPeriod)
			processed, errs := iaBusiness.AccrueAllActive(ctx, periodStart, periodEnd)
			util.Log(ctx).
				WithField("processed", processed).
				WithField("errors", len(errs)).
				WithField("period_end", periodEnd.Format(time.RFC3339)).
				Info("interest accrual pass complete")
		}
	}
}

// setupOperationsClient wires the operations service client used for every
// transfer order the savings service emits. The Endpoint and SPIFFE workload
// target path come from config; a failure here is fatal at startup because
// the savings service would otherwise have no path to the ledger.
func setupOperationsClient(
	ctx context.Context,
	cfg aconfig.SavingsConfig,
) (operationsv1connect.OperationsServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.OperationsServiceURI,
		WorkloadAPITargetPath: cfg.OperationsServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceOperations,
	}, operationsv1connect.NewOperationsServiceClient)
}

func setupLimitsClient(
	ctx context.Context,
	cfg aconfig.SavingsConfig,
) (limitsv1connect.LimitsServiceClient, error) {
	return consumer.SetupClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.LimitsServiceURI,
		WorkloadAPITargetPath: cfg.LimitsServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceLimits,
	})
}

func setupConnectServer(
	ctx context.Context,
	sm security.Manager,
	_ pool.Pool,
	spBusiness business.SavingsProductBusiness,
	saBusiness business.SavingsAccountBusiness,
	depBusiness business.DepositBusiness,
	wdBusiness business.WithdrawalBusiness,
	iaBusiness business.InterestAccrualBusiness,
	auditCli auditv1connect.AuditServiceClient,
) http.Handler {
	// Create handler with injected dependencies
	savingsHandler := handlers.NewSavingsServer(
		spBusiness,
		saBusiness,
		depBusiness,
		wdBusiness,
		iaBusiness,
	)

	auth := sm.GetAuthorizer(ctx)

	// Layer 1: TenancyAccessChecker verifies caller can access the partition
	tenancyAccessChecker := authorizer.NewTenancyAccessChecker(auth, authz.NamespaceTenancyAccess)
	tenancyAccessInterceptor := connectInterceptors.NewTenancyAccessInterceptor(tenancyAccessChecker)

	// Layer 2: FunctionAccessInterceptor enforces per-RPC permissions from proto annotations.
	sd := savingspb.File_savings_v1_savings_proto.Services().ByName("SavingsService")
	procMap := permissions.BuildProcedureMap(sd)
	svcPerms := permissions.ForService(sd)
	functionChecker := authorizer.NewFunctionChecker(auth, svcPerms.Namespace)
	functionAccessInterceptor := connectInterceptors.NewFunctionAccessInterceptor(functionChecker, procMap)

	savingsAuditInterceptor := clients.AuditInterceptor("service_savings", auditCli)

	defaultInterceptorList, err := connectInterceptors.DefaultList(
		ctx, sm.GetAuthenticator(ctx),
		tenancyAccessInterceptor, tenantassert.Interceptor(), functionAccessInterceptor, savingsAuditInterceptor)
	if err != nil {
		util.Log(ctx).WithError(err).Fatal("main -- Could not create default interceptors")
	}

	interceptorOption := connect.WithInterceptors(defaultInterceptorList...)

	// Register the savings service on the mux
	savingsPath, savingsServerHandler := savingsv1connect.NewSavingsServiceHandler(savingsHandler, interceptorOption)

	mux := http.NewServeMux()
	mux.Handle(savingsPath, savingsServerHandler)

	return mux
}
