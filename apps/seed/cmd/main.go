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
// Extension points:
//
//   - KYCVerifier: today the binary ships with AlwaysVerifiedKYC,
//     a development stub. Production deployments must inject a real
//     implementation that calls identity.ClientDataList and enforces
//     the seed-product's KYC checklist.
//
//   - LoanCreator: today the binary ships with StubLoanCreator, a
//     development stub. Production deployments must inject a real
//     implementation backed by the loan management service client.
//
// Both extension points are behind Go interfaces so swapping in a
// real implementation is a matter of changing a single constructor
// call in this file.
package main

import (
	"context"
	"net/http"
	"os"

	"github.com/antinvestor/common"
	"github.com/antinvestor/common/connection"
	"github.com/antinvestor/service-trustage/client/workflows"
	"github.com/antinvestor/service-trustage/gen/go/workflow/v1/workflowv1connect"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/config"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/util"

	aconfig "github.com/antinvestor/service-fintech/apps/seed/config"
	"github.com/antinvestor/service-fintech/apps/seed/service/business"
	seedevents "github.com/antinvestor/service-fintech/apps/seed/service/events"
	seedhandlers "github.com/antinvestor/service-fintech/apps/seed/service/handlers"
	"github.com/antinvestor/service-fintech/apps/seed/service/repository"

	"github.com/antinvestor/service-fintech/pkg/audit"
)

// syncTrustageWorkflows pushes the workflow definitions baked into the image
// to the Trustage service, when TRUSTAGE_URL is configured.
func syncTrustageWorkflows(ctx context.Context, cfg *aconfig.SeedConfig, log *util.LogEntry) {
	trustageURL := os.Getenv("TRUSTAGE_URL")
	if trustageURL == "" {
		return
	}
	workflowsDir := os.Getenv("TRUSTAGE_WORKFLOWS_DIR")
	if workflowsDir == "" {
		workflowsDir = "/workflows"
	}
	trustageCli, cliErr := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
		Endpoint:  trustageURL,
		Audiences: []string{"service_trustage"},
	}, workflowv1connect.NewWorkflowServiceClient)
	if cliErr != nil {
		log.WithError(cliErr).Warn("trustage workflow client init failed")
		return
	}
	if syncErr := workflows.SyncFromDir(ctx, trustageCli, workflowsDir); syncErr != nil {
		log.WithError(syncErr).Warn("trustage workflow sync failed")
	}
}

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

	ctx, svc := frame.NewServiceWithContext(
		tmpCtx,
		frame.WithConfig(&cfg),
		frame.WithDatastore(),
	)
	defer svc.Stop(ctx)
	log := util.Log(ctx)

	dbManager := svc.DatastoreManager()
	workMan := svc.WorkManager()
	evtsMan := svc.EventsManager()

	if cfg.DoDatabaseMigrate() {
		if migErr := repository.Migrate(ctx, dbManager, cfg.GetDatabaseMigrationPath()); migErr != nil {
			log.WithError(migErr).Error("main -- could not migrate successfully")
		}
		syncTrustageWorkflows(ctx, &cfg, log)
		return
	}

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

	// Extension points — swap StubLoanCreator and AlwaysVerifiedKYC for
	// real implementations wired to loans/identity before
	// deploying to production. See service/business/stubs.go for the
	// contracts they must satisfy.
	kycVerifier := business.AlwaysVerifiedKYC{}
	loanCreator := business.StubLoanCreator{}

	cpBusiness := business.NewCreditProfileBusiness(ctx, cpRepo, tierRepo, evtsMan, auditWriter)
	lrBusiness := business.NewLoanRequestBusiness(
		ctx,
		cpBusiness,
		cpRepo,
		lrRepo,
		tierRepo,
		kycVerifier,
		loanCreator,
		evtsMan,
		auditWriter,
	)

	// HTTP mux.
	mux := http.NewServeMux()
	seedhandlers.NewServer(lrBusiness, cpBusiness).Register(mux)
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ok"))
	})

	serviceOptions := []frame.Option{
		frame.WithHTTPHandler(mux),
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
