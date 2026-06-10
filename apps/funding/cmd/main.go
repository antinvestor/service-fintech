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

	"buf.build/gen/go/antinvestor/funding/connectrpc/go/funding/v1/fundingv1connect"
	fundingpb "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/loans/v1/loansv1connect"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	"connectrpc.com/connect"
	"github.com/antinvestor/common"
	"github.com/antinvestor/common/connection"
	"github.com/antinvestor/common/permissions"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/config"
	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/frame/security/authorizer"
	connectInterceptors "github.com/pitabwire/frame/security/interceptors/connect"
	"github.com/pitabwire/frame/workerpool"
	"github.com/pitabwire/util"

	auditmw "github.com/antinvestor/common/audit"

	aconfig "github.com/antinvestor/service-fintech/apps/funding/config"
	"github.com/antinvestor/service-fintech/apps/funding/service/business"
	fundingevents "github.com/antinvestor/service-fintech/apps/funding/service/events"
	fundinghandlers "github.com/antinvestor/service-fintech/apps/funding/service/handlers"
	fundingmodels "github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/apps/funding/service/repository"

	stawimodels "github.com/antinvestor/service-fintech/apps/stawi/service/models"
	stawirepo "github.com/antinvestor/service-fintech/apps/stawi/service/repository"

	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/limits/consumer"
)

func main() {
	tmpCtx := context.Background()

	cfg, err := config.LoadWithOIDC[aconfig.FundingConfig](tmpCtx)
	if err != nil {
		util.Log(tmpCtx).With("err", err).Error("could not process configs")
		return
	}

	if cfg.Name() == "" {
		cfg.ServiceName = "service_funding"
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

	// Platform clients for external service calls (loan mgmt, ledger, identity, etc.)
	platformClients, pcErr := clients.NewPlatformClients(ctx, &cfg, cfg.ServiceEndpoints())
	if pcErr != nil {
		log.WithError(pcErr).Warn("main -- Some platform clients could not be initialised")
	}

	// Operations client is load-bearing for investor capital movements and
	// must be available at startup; failing loudly here beats silently
	// dropping ledger postings later.
	operationsCli, opsErr := setupOperationsClient(ctx, cfg)
	if opsErr != nil {
		log.WithError(opsErr).Fatal("main -- could not initialise operations client")
	}

	// Limits client. Optional — when LimitsServiceURI is empty, SetupClient
	// returns nil and the gate is disabled at runtime regardless of the config flag.
	limitsCli, limitsErr := setupLimitsClient(ctx, cfg)
	if limitsErr != nil {
		log.WithError(limitsErr).
			Warn("main -- Could not setup limits client, limits gate will be disabled")
	}

	serviceOptions := setupServiceOptions(
		ctx,
		sm,
		evtsMan,
		dbPool,
		workMan,
		platformClients,
		operationsCli,
		limitsCli,
		cfg,
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
	platformClients *clients.PlatformClients,
	operationsCli operationsv1connect.OperationsServiceClient,
	limitsCli limitsv1connect.LimitsServiceClient,
	cfg aconfig.FundingConfig,
) []frame.Option {
	// Funding repositories
	lfRepo := repository.NewLoanFundingRepository(ctx, dbPool, workMan)
	faRepo := repository.NewFundingAllocationRepository(ctx, dbPool, workMan)
	ftRepo := repository.NewFundingTrancheRepository(ctx, dbPool, workMan)
	iaRepo := repository.NewInvestorAccountRepository(ctx, dbPool, workMan)
	auditRepo := audit.NewRepository(ctx, dbPool, workMan)
	auditWriter := audit.NewWriter(evtsMan)

	// Legacy Stawi request repository used as a compatibility source while canonical
	// request data is still split across services.
	loRepo := stawirepo.NewLoanOfferRepository(ctx, dbPool, workMan)
	var loanMgmtCli loansv1connect.LoanManagementServiceClient
	if platformClients != nil {
		loanMgmtCli = platformClients.LenderLoanMgmt
	}

	// Business logic
	faBiz := business.NewFundingAllocationBusiness(
		ctx,
		evtsMan,
		lfRepo,
		faRepo,
		&loanRequestAdapter{repo: loRepo, loanMgmtCli: loanMgmtCli},
		iaRepo,
		ftRepo,
		platformClients,
	)
	iaBiz := business.NewInvestorAccountBusiness(
		ctx,
		evtsMan,
		iaRepo,
		operationsCli,
		auditWriter,
		limitsCli,
		cfg.LimitsGateEnabledFundingDeposit,
		cfg.LimitsGateModeFundingDeposit,
		cfg.LimitsGateEnabledFundingWithdraw,
		cfg.LimitsGateModeFundingWithdraw,
	)

	// ConnectRPC handler
	connectHandler := setupConnectServer(ctx, sm, dbPool, iaBiz, faBiz)

	sd := fundingpb.File_funding_v1_funding_proto.Services().ByName("FundingService")

	return []frame.Option{
		frame.WithHTTPHandler(connectHandler),
		frame.WithPermissionRegistration(sd),
		frame.WithRegisterEvents(
			fundingevents.NewLoanFundingSave(ctx, lfRepo),
			fundingevents.NewFundingAllocationSave(ctx, faRepo),
			fundingevents.NewFundingTrancheSave(ctx, ftRepo),
			fundingevents.NewInvestorAccountSave(ctx, iaRepo),
			audit.NewEventSave(ctx, auditRepo),
		),
	}
}

// setupOperationsClient wires the operations service client used for every
// investor capital transfer order. Fails at startup if it cannot be
// initialised so funding never accepts a deposit it cannot settle on the
// ledger.
func setupOperationsClient(
	ctx context.Context,
	cfg aconfig.FundingConfig,
) (operationsv1connect.OperationsServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.OperationsServiceURI,
		WorkloadAPITargetPath: cfg.OperationsServiceWorkloadAPITargetPath,
		Audiences:             []string{"service_operations"},
	}, operationsv1connect.NewOperationsServiceClient)
}

func handleDatabaseMigration(
	ctx context.Context,
	dbManager datastore.Manager,
	cfg aconfig.FundingConfig,
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

var errLoanRequestNotFound = errors.New("loan request not found")

// loanRequestAdapter bridges loan offer and loan request sources into a canonical loan-request view.
type loanRequestAdapter struct {
	repo        stawirepo.LoanOfferRepository
	loanMgmtCli loansv1connect.LoanManagementServiceClient
}

func (a *loanRequestAdapter) GetByID(ctx context.Context, id string) (*business.LoanRequestInfo, error) {
	if a.repo != nil {
		offer, err := a.repo.GetByID(ctx, id)
		if err == nil && offer != nil {
			return loanOfferToRequestInfo(offer), nil
		}
	}

	if a.loanMgmtCli != nil {
		resp, err := a.loanMgmtCli.LoanRequestGet(
			ctx,
			connect.NewRequest(&loansv1.LoanRequestGetRequest{Id: id}),
		)
		if err == nil && resp.Msg.GetData() != nil {
			return loanRequestToRequestInfo(resp.Msg.GetData()), nil
		}
	}

	return nil, errLoanRequestNotFound
}

func loanOfferToRequestInfo(o *stawimodels.LoanOffer) *business.LoanRequestInfo {
	if o == nil {
		return nil
	}
	info := &business.LoanRequestInfo{
		Amount:     o.Amount,
		Currency:   o.Currency,
		Properties: o.Properties,
	}
	info.BaseModel = o.BaseModel
	return info
}

func loanRequestToRequestInfo(lr *loansv1.LoanRequestObject) *business.LoanRequestInfo {
	if lr == nil {
		return nil
	}

	amount, currency := fundingmodels.MoneyToMinorUnits(lr.GetApprovedAmount())
	if amount <= 0 {
		amount, currency = fundingmodels.MoneyToMinorUnits(lr.GetRequestedAmount())
	}

	properties := (&data.JSONMap{}).FromProtoStruct(lr.GetProperties())
	if properties == nil {
		properties = data.JSONMap{}
	}
	properties["interest_rate"] = float64(fundingmodels.StringToBasisPoints(lr.GetInterestRate()))

	info := &business.LoanRequestInfo{
		Amount:     amount,
		Currency:   currency,
		Properties: properties,
	}
	info.GenID(context.Background())
	info.ID = lr.GetId()
	return info
}

func setupConnectServer(
	ctx context.Context,
	sm security.Manager,
	_ pool.Pool,
	iaBiz business.InvestorAccountBusiness,
	faBiz business.FundingAllocationBusiness,
) http.Handler {
	fundingHandler := fundinghandlers.NewFundingServer(iaBiz, faBiz)

	auth := sm.GetAuthorizer(ctx)

	tenancyAccessChecker := authorizer.NewTenancyAccessChecker(auth, "tenancy_access")
	tenancyAccessInterceptor := connectInterceptors.NewTenancyAccessInterceptor(tenancyAccessChecker)

	sd := fundingpb.File_funding_v1_funding_proto.Services().ByName("FundingService")
	procMap := permissions.BuildProcedureMap(sd)
	svcPerms := permissions.ForService(sd)
	functionChecker := authorizer.NewFunctionChecker(auth, svcPerms.Namespace)
	functionAccessInterceptor := connectInterceptors.NewFunctionAccessInterceptor(functionChecker, procMap)

	fundingAuditInterceptor := auditmw.NewInterceptor("service_funding", nil)

	defaultInterceptorList, err := connectInterceptors.DefaultList(
		ctx, sm.GetAuthenticator(ctx),
		tenancyAccessInterceptor, functionAccessInterceptor, fundingAuditInterceptor)
	if err != nil {
		util.Log(ctx).WithError(err).Fatal("main -- Could not create default interceptors")
	}

	interceptorOption := connect.WithInterceptors(defaultInterceptorList...)

	fundingPath, fundingServerHandler := fundingv1connect.NewFundingServiceHandler(fundingHandler, interceptorOption)

	mux := http.NewServeMux()
	mux.Handle(fundingPath, fundingServerHandler)

	return mux
}

// setupLimitsClient wires the limits service client used for investor deposit
// and withdrawal gate checks. Returns nil, nil when LimitsServiceURI is empty.
func setupLimitsClient(
	ctx context.Context,
	cfg aconfig.FundingConfig,
) (limitsv1connect.LimitsServiceClient, error) {
	return consumer.SetupClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.LimitsServiceURI,
		WorkloadAPITargetPath: cfg.LimitsServiceWorkloadAPITargetPath,
		Audiences:             []string{"service_limits"},
	})
}
