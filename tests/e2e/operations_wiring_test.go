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

package e2e_test

import (
	"context"
	"net/http"

	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	"buf.build/gen/go/antinvestor/ledger/connectrpc/go/v2/v1/ledgerv1connect"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/v2/loans/v1/loansv1connect"
	"buf.build/gen/go/antinvestor/notification/connectrpc/go/v2/notification/v1/notificationv1connect"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	operationspb "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"buf.build/gen/go/antinvestor/payment/connectrpc/go/v2/v1/paymentv1connect"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/antinvestor/common/v3/permissions"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore/pool"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/security/authorizer"
	connectInterceptors "github.com/pitabwire/frame/v3/security/interceptors/connect"
	"github.com/pitabwire/frame/v3/workerpool"

	aconfig "github.com/antinvestor/service-fintech/apps/operations/config"
	"github.com/antinvestor/service-fintech/apps/operations/service/business"
	opsevents "github.com/antinvestor/service-fintech/apps/operations/service/events"
	"github.com/antinvestor/service-fintech/apps/operations/service/handlers"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/tenantassert"
)

// operationsPlatformClients mirrors clients.NewPlatformClients for the
// endpoints apps/operations/config sets: the loans client points at the real
// loans server, the rest at fakes. Savings, funding, files and tenancy are
// unset, as their endpoints default to empty or are not on this path.
func operationsPlatformClients(router http.RoundTripper, f *fakes, token string) *clients.PlatformClients {
	return &clients.PlatformClients{
		LenderIdentity: fieldv1connect.NewFieldServiceClient(client(router, f.field.URL, token)),
		LenderRegistry: identityv1connect.NewIdentityServiceClient(client(router, f.identity.URL, token)),
		LenderLoanMgmt: loansv1connect.NewLoanManagementServiceClient(client(router, loansHost, token)),
		LedgerClient:   ledgerv1connect.NewLedgerServiceClient(client(router, f.ledger.URL, token)),
		PaymentClient:  paymentv1connect.NewPaymentServiceClient(client(router, f.payment.URL, token)),
		NotificationClient: notificationv1connect.NewNotificationServiceClient(
			client(router, f.notification.URL, token)),
		ProfileClient: profilev1connect.NewProfileServiceClient(client(router, f.profile.URL, token)),
	}
}

// operationsService is what the test reaches inside operations besides its
// RPC surface: the consumer the payment service publishes received payments
// to.
type operationsService struct {
	paymentReceived *handlers.PaymentReceived
}

// operationsOptions replicates apps/operations/cmd/main.go
// setupServiceOptions and setupConnectServer. Keep it in step with main.go.
// Only the authenticator and the authorizer differ.
func operationsOptions(
	ctx context.Context,
	cfg *aconfig.OperationsConfig,
	evtsMan fevents.Manager,
	dbPool pool.Pool,
	workMan workerpool.Manager,
	identityCli identityv1connect.IdentityServiceClient,
	platformClients *clients.PlatformClients,
	limitsCli limitsv1connect.LimitsServiceClient,
	authn security.Authenticator,
	authzr security.Authorizer,
) ([]frame.Option, *operationsService) {
	toRepo := repository.NewTransferOrderRepository(ctx, dbPool, workMan)
	obRepo := repository.NewObligationRepository(ctx, dbPool, workMan)
	ipRepo := repository.NewIncomingPaymentRepository(ctx, dbPool, workMan)
	arRepo := repository.NewAccountRefRepository(ctx, dbPool, workMan)
	csRepo := repository.NewCBSSyncRecordRepository(ctx, dbPool, workMan)
	auditRepo := audit.NewRepository(ctx, dbPool, workMan)
	auditWriter := audit.NewWriter(evtsMan)

	toBiz := business.NewTransferOrderBusiness(
		ctx, evtsMan, toRepo, csRepo, arRepo, platformClients, auditWriter, limitsCli,
		cfg.LimitsGateEnabledOperationsTransfer, cfg.LimitsGateModeOperationsTransfer,
	)
	prBiz := business.NewPaymentRoutingBusiness(
		ctx, evtsMan, ipRepo, toRepo, obRepo, arRepo, identityCli, platformClients,
		business.WithOrderExecutor(toBiz),
	)
	jobs := business.NewOperationsJobs(prBiz, toBiz, ipRepo, toRepo, cfg.Name())
	if reconciler, ok := toBiz.(business.PayoutReconciler); ok {
		jobs.WithPayoutReconciler(reconciler)
	}
	obBiz := business.NewObligationBusiness(ctx, evtsMan, obRepo, prBiz)

	opsHandler := handlers.NewOperationsServer(toBiz, prBiz, obBiz, toRepo, ipRepo, jobs)
	tenancyAccessChecker := authorizer.NewTenancyAccessChecker(authzr, "tenancy_access")
	tenancyAccessInterceptor := connectInterceptors.NewTenancyAccessInterceptor(tenancyAccessChecker)
	sd := operationspb.File_operations_v1_operations_proto.Services().ByName("OperationsService")
	functionChecker := authorizer.NewFunctionChecker(authzr, permissions.ForService(sd).Namespace)
	functionAccessInterceptor := connectInterceptors.NewFunctionAccessInterceptor(
		functionChecker, permissions.BuildProcedureMap(sd))
	interceptorList, err := connectInterceptors.DefaultList(ctx, authn,
		tenancyAccessInterceptor, tenantassert.Interceptor(), functionAccessInterceptor,
		clients.AuditInterceptor("service_operations", nil))
	if err != nil {
		panic(err)
	}
	server := connect.NewServer(interceptorList...)
	operationsv1connect.RegisterOperationsServiceHandler(server, opsHandler)
	mux := http.NewServeMux()
	connecthttp.Mount(mux, server)

	paymentReceived := handlers.NewPaymentReceived(prBiz, cfg.Name())
	return []frame.Option{
		frame.WithHTTPHandler(mux),
		frame.WithRegisterSubscriber(cfg.PaymentReceivedName, cfg.PaymentReceivedURI, paymentReceived),
		frame.WithRegisterEvents(
			opsevents.NewTransferOrderSave(ctx, toRepo),
			opsevents.NewObligationSave(ctx, obRepo),
			opsevents.NewIncomingPaymentSave(ctx, ipRepo),
			opsevents.NewAccountRefSave(ctx, arRepo),
			opsevents.NewCBSSyncRecordSave(ctx, csRepo),
			audit.NewEventSave(ctx, auditRepo),
		),
	}, &operationsService{paymentReceived: paymentReceived}
}
