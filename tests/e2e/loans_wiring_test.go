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
	"buf.build/gen/go/antinvestor/funding/connectrpc/go/v2/funding/v1/fundingv1connect"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/v2/loans/v1/loansv1connect"
	loanspb "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/notification/connectrpc/go/v2/notification/v1/notificationv1connect"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
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

	aconfig "github.com/antinvestor/service-fintech/apps/loans/config"
	"github.com/antinvestor/service-fintech/apps/loans/service/authz"
	"github.com/antinvestor/service-fintech/apps/loans/service/business"
	lmevents "github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/handlers"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/messages"
	"github.com/antinvestor/service-fintech/pkg/notify"
	"github.com/antinvestor/service-fintech/pkg/tenantassert"
)

// loansPeers are the loans service's outbound clients, as
// apps/loans/cmd/main.go setupPeerClients builds them: the operations client
// points at the real operations server, every other peer at a fake.
type loansPeers struct {
	operations   operationsv1connect.OperationsServiceClient
	funding      fundingv1connect.FundingServiceClient
	limits       limitsv1connect.LimitsServiceClient
	payments     paymentv1connect.PaymentServiceClient
	field        fieldv1connect.FieldServiceClient
	profile      profilev1connect.ProfileServiceClient
	identity     identityv1connect.IdentityServiceClient
	notification notificationv1connect.NotificationServiceClient
}

func newLoansPeers(router http.RoundTripper, f *fakes, token string) loansPeers {
	return loansPeers{
		operations: operationsv1connect.NewOperationsServiceClient(client(router, operationsHost, token)),
		funding:    fundingv1connect.NewFundingServiceClient(client(router, f.funding.URL, token)),
		limits:     limitsv1connect.NewLimitsServiceClient(client(router, f.limits.URL, token)),
		payments:   paymentv1connect.NewPaymentServiceClient(client(router, f.payment.URL, token)),
		field:      fieldv1connect.NewFieldServiceClient(client(router, f.field.URL, token)),
		profile:    profilev1connect.NewProfileServiceClient(client(router, f.profile.URL, token)),
		identity:   identityv1connect.NewIdentityServiceClient(client(router, f.identity.URL, token)),
		notification: notificationv1connect.NewNotificationServiceClient(
			client(router, f.notification.URL, token)),
	}
}

// loansOptions replicates apps/loans/cmd/main.go setupServiceOptions and
// setupConnectServer. The cmd package is main, so the wiring is copied; keep
// it in step with main.go. Only the authenticator differs (an OIDC
// stand-in); the authorizer is frame's Keto adapter against a real Keto.
func loansOptions(
	ctx context.Context,
	cfg *aconfig.LoanManagementConfig,
	evtsMan fevents.Manager,
	dbPool pool.Pool,
	workMan workerpool.Manager,
	peers loansPeers,
	authn security.Authenticator,
	authzr security.Authorizer,
) []frame.Option {
	clientProfiles := business.NewFieldClientProfileResolver(peers.field)
	payoutChecker := business.NewProfilePayoutChecker(clientProfiles, peers.profile)
	clientStanding := business.NewFieldClientStanding(peers.field)
	teams := business.NewFieldTeamResolver(peers.field)
	members := business.NewIdentityMemberPayoutResolver(peers.identity, peers.profile)
	agentProfiles := business.NewIdentityAgentProfileResolver(peers.identity)
	loanNotifier := business.NewLoanNotifier(
		notify.New(peers.notification, messages.Registry()), clientProfiles, cfg.LenderDisplayName)
	readScope := business.NewReadScope(business.NewFieldAccessResolver(peers.field), splitCSV(cfg.LoansStaffRoles)...)
	var paidOffHook business.PaidOffHook // SEED_SERVICE_URI unset

	lpRepo := repository.NewLoanProductRepository(ctx, dbPool, workMan)
	loanRequestRepo := repository.NewLoanRequestRepository(ctx, dbPool, workMan)
	cpaRepo := repository.NewClientProductAccessRepository(ctx, dbPool, workMan)
	laRepo := repository.NewLoanAccountRepository(ctx, dbPool, workMan)
	rsRepo := repository.NewRepaymentScheduleRepository(ctx, dbPool, workMan)
	seRepo := repository.NewScheduleEntryRepository(ctx, dbPool, workMan)
	lbRepo := repository.NewLoanBalanceRepository(ctx, dbPool, workMan)
	repRepo := repository.NewRepaymentRepository(ctx, dbPool, workMan)
	penRepo := repository.NewPenaltyRepository(ctx, dbPool, workMan)
	lrRepo := repository.NewLoanRestructureRepository(ctx, dbPool, workMan)
	lscRepo := repository.NewLoanStatusChangeRepository(ctx, dbPool, workMan)
	reconRepo := repository.NewReconciliationRepository(ctx, dbPool, workMan)
	disbRepo := repository.NewDisbursementRepository(ctx, dbPool, workMan)
	auditRepo := audit.NewRepository(ctx, dbPool, workMan)
	auditWriter := audit.NewWriter(evtsMan)

	lpBusiness := business.NewLoanProductBusiness(ctx, evtsMan, lpRepo)
	lrBusiness := business.NewLoanRequestBusiness(
		ctx, evtsMan, loanRequestRepo, lpRepo, peers.limits,
		cfg.LimitsGateEnabledLoanRequestApproval, cfg.LimitsGateModeLoanRequestApproval,
		business.WithReadScope(readScope),
		business.WithNotifier(loanNotifier),
		business.WithAuditWriter(auditWriter),
		business.WithClientStanding(clientStanding),
	)
	scheduleBusiness := business.NewRepaymentScheduleBusiness(ctx, evtsMan, laRepo, lpRepo, rsRepo, seRepo,
		business.WithReadScope(readScope))
	laBusiness := business.NewLoanAccountBusiness(
		ctx, evtsMan, lpRepo, laRepo, lbRepo, lscRepo, repRepo, penRepo,
		loanRequestRepo, peers.funding, scheduleBusiness, peers.operations, auditWriter,
		business.WithReadScope(readScope),
		business.WithStatementSources(disbRepo, seRepo),
		business.WithNotifier(loanNotifier),
		business.WithPayoutDestinationChecker(payoutChecker),
	)
	teamCommissions := business.NewTeamCommissions(
		repository.NewTeamCommissionRepository(dbPool), members, peers.operations, auditWriter)
	fundingSettlement := business.NewFundingSettlement(repRepo, laRepo, peers.funding).
		WithCommission(business.NewAgentCommission(lpRepo, teams, peers.operations, teamCommissions)).
		WithSubject(cfg.Name())
	repBusiness := business.NewRepaymentBusiness(
		ctx, evtsMan, laRepo, repRepo, rsRepo, seRepo, lbRepo, loanNotifier, peers.operations, auditWriter,
		paidOffHook,
		business.WithReadScope(readScope),
		business.WithFundingSettlement(fundingSettlement),
		business.WithRepaymentApplier(repository.NewRepaymentApplier(dbPool, lbRepo)),
	)
	penaltyBusiness := business.NewPenaltyBusiness(ctx, penRepo, laRepo, lbRepo, peers.operations, auditWriter,
		business.WithNotifier(loanNotifier), business.WithScheduleEntries(seRepo),
		business.WithReadScope(readScope))
	restructBusiness := business.NewLoanRestructureBusiness(
		ctx, evtsMan, lrRepo, laRepo, lbRepo, rsRepo, laBusiness, scheduleBusiness,
		business.WithNotifier(loanNotifier),
		business.WithReadScope(readScope),
	)
	reconBusiness := business.NewReconciliationBusiness(ctx, evtsMan, reconRepo)
	disbBusiness := business.NewDisbursementBusiness(
		ctx, evtsMan, disbRepo, laRepo, laBusiness, peers.operations, auditWriter, peers.limits,
		cfg.LimitsGateEnabledLoanDisbursement, cfg.LimitsGateModeLoanDisbursement,
		business.WithReadScope(readScope),
		business.WithScheduleBusiness(scheduleBusiness),
		business.WithNotifier(loanNotifier),
		business.WithPayoutDestinationChecker(payoutChecker),
	)
	portfolioBusiness := business.NewPortfolioBusiness(ctx, dbPool)
	cpaBusiness := business.NewClientProductAccessBusiness(ctx, evtsMan, cpaRepo, lpRepo)
	collectionBusiness := business.NewCollectionBusiness(
		ctx, laRepo, lbRepo, loanNotifier, business.WithReadScope(readScope),
		business.WithPayoutDestinationChecker(payoutChecker),
		business.WithPaymentClient(peers.payments),
	)
	scanner := business.NewDelinquencyScanner(
		laRepo, seRepo, penaltyBusiness, laBusiness, lpRepo,
		cfg.DelinquencyThresholdDays, cfg.DefaultThresholdDays,
		business.WithScannerNotifications(loanNotifier, agentProfiles, lbRepo),
		business.WithScannerSubject(cfg.Name()),
	)
	reminders := business.NewDueReminderJob(seRepo, laRepo, loanNotifier, cfg.DueReminderDays).WithSubject(cfg.Name())
	paidOffNotices := business.NewPaidOffNotices(laRepo, lbRepo, paidOffHook, cfg.Name())
	loanJobs := business.NewLoanJobs(scanner, reminders, fundingSettlement, loanRequestRepo, loanNotifier,
		paidOffNotices).WithSubject(cfg.Name())

	lmHandler := handlers.NewLoanManagementServer(
		lpBusiness, lrBusiness, laBusiness, repBusiness, scheduleBusiness,
		penaltyBusiness, restructBusiness, reconBusiness, portfolioBusiness, disbBusiness,
		cpaBusiness, collectionBusiness, lscRepo, loanJobs, teamCommissions,
		business.NewPayoutFailures(disbRepo, laRepo, repRepo, evtsMan, teamCommissions),
	)

	tenancyAccessChecker := authorizer.NewTenancyAccessChecker(authzr, authz.NamespaceTenancyAccess)
	tenancyAccessInterceptor := connectInterceptors.NewTenancyAccessInterceptor(tenancyAccessChecker)
	sd := loanspb.File_loans_v1_loans_proto.Services().ByName("LoanManagementService")
	functionChecker := authorizer.NewFunctionChecker(authzr, permissions.ForService(sd).Namespace)
	functionAccessInterceptor := connectInterceptors.NewFunctionAccessInterceptor(
		functionChecker, permissions.BuildProcedureMap(sd))
	interceptorList, err := connectInterceptors.DefaultList(ctx, authn,
		tenancyAccessInterceptor, tenantassert.Interceptor(), functionAccessInterceptor,
		clients.AuditInterceptor("service_loans", nil))
	if err != nil {
		panic(err)
	}
	server := connect.NewServer(interceptorList...)
	loansv1connect.RegisterLoanManagementServiceHandler(server, lmHandler)
	mux := http.NewServeMux()
	connecthttp.Mount(mux, server)

	return []frame.Option{
		frame.WithHTTPHandler(mux),
		frame.WithRegisterEvents(
			lmevents.NewLoanProductSave(ctx, lpRepo),
			lmevents.NewLoanRequestSave(ctx, loanRequestRepo),
			lmevents.NewClientProductAccessSave(ctx, cpaRepo),
			lmevents.NewLoanAccountSave(ctx, laRepo),
			lmevents.NewRepaymentScheduleSave(ctx, rsRepo),
			lmevents.NewScheduleEntrySave(ctx, seRepo),
			lmevents.NewLoanBalanceSave(ctx, lbRepo),
			lmevents.NewRepaymentSave(ctx, repRepo),
			lmevents.NewPenaltySave(ctx, penRepo),
			lmevents.NewLoanRestructureSave(ctx, lrRepo),
			lmevents.NewLoanStatusChangeSave(ctx, lscRepo),
			lmevents.NewReconciliationSave(ctx, reconRepo),
			lmevents.NewDisbursementSave(ctx, disbRepo),
			audit.NewEventSave(ctx, auditRepo),
		),
	}
}
