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

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	"buf.build/gen/go/antinvestor/savings/connectrpc/go/savings/v1/savingsv1connect"
	savingspb "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"connectrpc.com/connect"
	"github.com/antinvestor/common/v2"
	"github.com/antinvestor/common/v2/connection"
	"github.com/antinvestor/common/v2/servicecatalog"
	"github.com/antinvestor/common/v2/permissions"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/config"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/frame/v2/security/authorizer"
	connectInterceptors "github.com/pitabwire/frame/v2/security/interceptors/connect"
	"github.com/pitabwire/util"

	auditmw "github.com/antinvestor/common/audit"

	aconfig "github.com/antinvestor/service-fintech/apps/savings/config"
	"github.com/antinvestor/service-fintech/apps/savings/service/authz"
	"github.com/antinvestor/service-fintech/apps/savings/service/business"
	savingsevents "github.com/antinvestor/service-fintech/apps/savings/service/events"
	"github.com/antinvestor/service-fintech/apps/savings/service/handlers"
	"github.com/antinvestor/service-fintech/apps/savings/service/repository"

	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/limits/consumer"
)

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
	if limitsErr != nil {
		log.WithError(limitsErr).
			Warn("main -- Could not setup limits client, limits gate will be disabled")
	}

	// Create business logic with all dependencies
	spBusiness := business.NewSavingsProductBusiness(ctx, evtsMan, spRepo)
	saBusiness := business.NewSavingsAccountBusiness(ctx, evtsMan, saRepo, depRepo, wdRepo, iaRepo, sbRepo)
	depBusiness := business.NewDepositBusiness(
		ctx, evtsMan, depRepo, saRepo, sbRepo, operationsCli, auditWriter,
		limitsCli, cfg.LimitsGateEnabledSavingsDeposit, cfg.LimitsGateModeSavingsDeposit,
	)
	wdBusiness := business.NewWithdrawalBusiness(
		ctx,
		evtsMan,
		wdRepo,
		saRepo,
		sbRepo,
		saBusiness,
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
		spBusiness, saBusiness, depBusiness, wdBusiness, iaBusiness)

	// Initialise the service with all options
	sd := savingspb.File_savings_v1_savings_proto.Services().ByName("SavingsService")

	serviceOptions := []frame.Option{
		frame.WithHTTPHandler(connectHandler),
		frame.WithPermissionRegistration(sd),
		frame.WithRegisterEvents(
			savingsevents.NewSavingsProductSave(ctx, spRepo),
			savingsevents.NewSavingsAccountSave(ctx, saRepo),
			savingsevents.NewDepositSave(ctx, depRepo),
			savingsevents.NewWithdrawalSave(ctx, wdRepo),
			savingsevents.NewInterestAccrualSave(ctx, iaRepo),
			savingsevents.NewSavingsBalanceSave(ctx, sbRepo),
			audit.NewEventSave(ctx, auditRepo),
		),
	}

	svc.Init(ctx, serviceOptions...)

	err = svc.Run(ctx, "")
	if err != nil {
		log.WithError(err).Fatal("could not run Server")
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

func handleDatabaseMigration(
	ctx context.Context,
	dbManager datastore.Manager,
	cfg aconfig.SavingsConfig,
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

	savingsAuditInterceptor := auditmw.NewInterceptor("service_savings", nil)

	defaultInterceptorList, err := connectInterceptors.DefaultList(
		ctx, sm.GetAuthenticator(ctx),
		tenancyAccessInterceptor, functionAccessInterceptor, savingsAuditInterceptor)
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
