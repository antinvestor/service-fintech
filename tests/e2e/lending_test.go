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

// Package e2e_test runs the real loans and operations services together,
// each on its own database and behind its real Connect handler, with only
// the platform edge (ledger, payment rail, profile, identity, funding,
// limits, notification and OIDC) faked. Authorization is a real Ory Keto
// loaded with the production OPL and the tuples tenancy writes for this
// scenario. It proves one loan's money across the service seam:
// origination, disbursement, repayment from the rail, and a payout the rail
// fails after accepting it; and that the people and services in it can do
// only what their roles and grants allow.
package e2e_test

import (
	"context"
	"encoding/json"
	"io"
	"strings"
	"testing"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/v2/loans/v1/loansv1connect"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/config"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/frametests"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/frame/v3/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/v3/frametests/rlstest"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"

	loansconfig "github.com/antinvestor/service-fintech/apps/loans/config"
	loansrepo "github.com/antinvestor/service-fintech/apps/loans/service/repository"
	opsconfig "github.com/antinvestor/service-fintech/apps/operations/config"
	opsrepo "github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

const (
	currency = "KES"
	// loansMigrations is the SQL the loans service ships, so the suite runs
	// on the schema a deployment gets.
	loansMigrations = "../../apps/loans/migrations"
	// paymentPublisher is the test's handle on the queue the payment service
	// publishes received payments to.
	paymentPublisher = "e2e-payment-service"

	staffToken      = "token-staff"
	staffProfile    = "profile-credit-manager"
	loansToken      = "token-service-loans"
	operationsToken = "token-service-operations"
	schedulerToken  = "token-service-trustage"

	// Service accounts' profile ids: the subject Keto checks.
	loansServiceProfile      = "service_loans"
	operationsServiceProfile = "service_operations"
	trustageServiceProfile   = "service_trustage"

	settleWait = 30 * time.Second
	settleTick = 200 * time.Millisecond
)

// kes is an amount in minor units as the wire's Money.
func kes(minor int64) *commonv1.Money { return moneyx.FromMinorUnitsByCurrency(currency, minor) }

// minor reads a Money back to minor units.
func minor(m *commonv1.Money) int64 { return moneyx.ToInt64(m, moneyx.Decimals(currency)) }

func splitCSV(value string) []string {
	var out []string
	for _, part := range strings.Split(value, ",") {
		if p := strings.TrimSpace(part); p != "" {
			out = append(out, p)
		}
	}
	return out
}

type lendingSuite struct {
	frametests.FrameBaseTestSuite

	ctx         context.Context
	tenantID    string
	partitionID string
	productID   string

	// The lender's partition (partitionID) is a child of the tenant's
	// platform partition, where its service accounts live.
	platformPartitionID string

	authz   security.Authorizer
	tenancy *tenancyKeto

	platform *platform
	fakes    *fakes
	router   *hostRouter
	tokens   *tokens

	opsDB   *gorm.DB
	loansDB *gorm.DB
	opsSvc  *frame.Service
	stops   []func()
	ops     *operationsService

	// What the people and the scheduler hold: each a client of the real
	// servers, under its own token.
	staffLoans   loansv1connect.LoanManagementServiceClient
	schedulerOps operationsv1connect.OperationsServiceClient
}

// TestLending is skipped by `go test -short`: it starts Postgres in Docker.
func TestLending(t *testing.T) {
	if testing.Short() {
		t.Skip("end-to-end suite starts Postgres in Docker; skipped in -short mode")
	}
	suite.Run(t, new(lendingSuite))
}

func (s *lendingSuite) SetupSuite() {
	namespaces, err := ketoNamespaces()
	s.Require().NoError(err)
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts(
				"fintech_e2e",
				definition.WithUserName("ant"),
				definition.WithCredential("s3cr3t"),
				definition.WithEnableLogging(false),
			),
			newKetoResource(namespaces),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()

	s.ctx = s.T().Context()
	s.tenantID = util.IDString()
	s.partitionID = util.IDString()
	s.platformPartitionID = util.IDString()

	s.authz = s.ketoAuthorizer()
	s.tenancy = newTenancyKeto(s.authz)
	s.syncTenancy()

	s.platform = newPlatform()
	s.fakes = startFakes(s.platform)
	s.router = newHostRouter()
	s.tokens = newTokens()
	s.issueTokens()

	s.startLoans()
	s.startOperations()

	s.staffLoans = loansv1connect.NewLoanManagementServiceClient(client(s.router, loansHost, staffToken))
	s.schedulerOps = operationsv1connect.NewOperationsServiceClient(client(s.router, operationsHost, schedulerToken))

	s.productID = s.saveProduct()
}

func (s *lendingSuite) TearDownSuite() {
	// Services stop before their databases are dropped, and both before
	// the container goes.
	for i := len(s.stops) - 1; i >= 0; i-- {
		s.stops[i]()
	}
	if s.fakes != nil {
		s.fakes.close()
	}
	s.FrameBaseTestSuite.TearDownSuite()
}

func (s *lendingSuite) ketoAuthorizer() security.Authorizer {
	for _, r := range s.Resources() {
		if r.Name() == ketoImage {
			authz, err := newKetoAuthorizer(s.ctx, r)
			s.Require().NoError(err)
			return authz
		}
	}
	s.Require().FailNow("keto resource not found")
	return nil
}

// syncTenancy writes what tenancy's sync handlers write for the lender: its
// partition under the platform partition, the staff member's access, and
// the service accounts' policies over the platform partition's tree.
func (s *lendingSuite) syncTenancy() {
	platform := tenancyPath(s.tenantID, s.platformPartitionID)
	lender := tenancyPath(s.tenantID, s.partitionID)
	s.Require().NoError(s.tenancy.partitionSynced(s.ctx, platform, lender))
	s.Require().NoError(s.tenancy.accessSynced(s.ctx, lender, staffProfile, roleAdmin))
	for profileID, grants := range serviceAccountGrants() {
		s.Require().NoError(s.tenancy.serviceAccountSynced(s.ctx, profileID, []string{platform, lender}, grants))
	}
}

// issueTokens mints the principals the flow runs under. People carry their
// tenancy; service accounts carry the internal role and no tenant, and name
// the tenant they act for on each call (X-Tenant-Id), as in production.
func (s *lendingSuite) issueTokens() {
	service := func(subject string) *security.AuthenticationClaims {
		return &security.AuthenticationClaims{
			Roles:            []string{security.ConstantSystemInternalRole},
			RegisteredClaims: jwt.RegisteredClaims{Subject: subject},
		}
	}
	// The credit manager holds the admin role: opening and paying out a loan
	// (loan_manage, disbursement_manage) and setting up products are not an
	// operator's.
	s.tokens.issue(staffToken, s.person(staffProfile, roleAdmin))
	s.tokens.issue(loansToken, service(loansServiceProfile))
	s.tokens.issue(operationsToken, service(operationsServiceProfile))
	s.tokens.issue(schedulerToken, service(trustageServiceProfile))
}

func (s *lendingSuite) person(subject string, roles ...string) *security.AuthenticationClaims {
	return &security.AuthenticationClaims{
		TenantID:         s.tenantID,
		PartitionID:      s.partitionID,
		Roles:            roles,
		RegisteredClaims: jwt.RegisteredClaims{Subject: subject},
	}
}

// database returns a fresh database on the suite's Postgres, and the
// tenancy provider its service runs with: frame's Postgres row-level
// security, with queries dropped to an unprivileged role once the schema is
// migrated. The container's user is a superuser, and a superuser bypasses
// RLS; the application role a deployment connects as must not.
func (s *lendingSuite) database() (string, *rlstest.Provider) {
	var db definition.DependancyConn
	for _, r := range s.Resources() {
		if r.Name() == testpostgres.PostgresqlDBImage && r.GetDS(s.ctx).IsDB() {
			db = r
		}
	}
	s.Require().NotNil(db, "postgres resource not found")
	dsn, cleanup, err := db.GetRandomisedDS(s.ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.stops = append(s.stops, func() { cleanup(s.ctx) })
	s.Require().NoError(rlstest.CreateRole(s.ctx, dsn.String()))
	return dsn.String(), rlstest.New()
}

// enforceRLS grants the unprivileged role the migrated tables and switches
// every later query to it.
func (s *lendingSuite) enforceRLS(dsn string, rls *rlstest.Provider) {
	s.Require().NoError(rlstest.GrantAll(s.ctx, dsn))
	rls.Enable()
}

func (s *lendingSuite) startLoans() {
	cfg, err := config.FromEnv[loansconfig.LoanManagementConfig]()
	s.Require().NoError(err)
	cfg.ServiceName = "service_loans"
	cfg.EventsQueueName = "e2e.loans.events"
	cfg.EventsQueueURL = "mem://e2e.loans.events"

	dsn, rls := s.database()
	driver, server := frametests.WithHTTPTestDriver()
	ctx, svc := frame.NewServiceWithContext(s.ctx,
		frame.WithConfig(&cfg),
		frame.WithTenancyProvider(rls),
		frame.WithDatastore(pool.WithConnection(dsn, false)),
		driver,
	)
	s.stops = append(s.stops, func() { svc.Stop(ctx) })

	s.Require().NoError(loansrepo.Migrate(ctx, svc.DatastoreManager(), loansMigrations))
	s.enforceRLS(dsn, rls)
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)
	s.loansDB = dbPool.DB(ctx, false)

	svc.Init(ctx, loansOptions(ctx, &cfg, svc.EventsManager(), dbPool, svc.WorkManager(),
		newLoansPeers(s.router, s.fakes, loansToken), s.tokens, s.authz)...)
	s.Require().NoError(svc.Run(ctx, ""))
	s.Require().NotNil(server())
	s.router.route(strings.TrimPrefix(loansHost, "http://"), server().URL)
}

func (s *lendingSuite) startOperations() {
	cfg, err := config.FromEnv[opsconfig.OperationsConfig]()
	s.Require().NoError(err)
	cfg.ServiceName = "service_operations"
	cfg.EventsQueueName = "e2e.operations.events"
	cfg.EventsQueueURL = "mem://e2e.operations.events"

	dsn, rls := s.database()
	driver, server := frametests.WithHTTPTestDriver()
	ctx, svc := frame.NewServiceWithContext(s.ctx,
		frame.WithConfig(&cfg),
		frame.WithTenancyProvider(rls),
		frame.WithDatastore(pool.WithConnection(dsn, false)),
		driver,
	)
	s.stops = append(s.stops, func() { svc.Stop(ctx) })

	// Operations ships no SQL migrations; its schema is the models plus
	// postMigrate's partial unique indexes.
	s.Require().NoError(opsrepo.Migrate(ctx, svc.DatastoreManager(), s.T().TempDir()))
	s.enforceRLS(dsn, rls)
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)
	s.opsDB = dbPool.DB(ctx, false)

	platformClients := operationsPlatformClients(s.router, s.fakes, operationsToken)
	opts, ops := operationsOptions(ctx, &cfg, svc.EventsManager(), dbPool, svc.WorkManager(),
		platformClients.LenderRegistry, platformClients,
		newLoansPeers(s.router, s.fakes, operationsToken).limits, s.tokens, s.authz)
	// The payment service's side of the received-payment queue.
	opts = append(opts, frame.WithRegisterPublisher(paymentPublisher, cfg.PaymentReceivedURI))
	svc.Init(ctx, opts...)
	s.Require().NoError(svc.Run(ctx, ""))
	s.Require().NotNil(server())
	s.router.route(strings.TrimPrefix(operationsHost, "http://"), server().URL)
	s.opsSvc = svc
	s.ops = ops
}

// asTenant is ctx naming the suite's tenancy, which an internal caller (the
// scheduler) sends as X-Tenant-Id / X-Partition-Id.
func (s *lendingSuite) asTenant() context.Context {
	return util.SetTenancy(s.ctx, &security.AuthenticationClaims{
		TenantID: s.tenantID, PartitionID: s.partitionID,
	})
}

// saveProduct creates the lender's loan product as staff.
func (s *lendingSuite) saveProduct() string {
	resp, err := s.staffLoans.LoanProductSave(s.ctx, &loansv1.LoanProductSaveRequest{Data: &loansv1.LoanProductObject{
		OrganizationId:     s.tenantID,
		Name:               "Field agent loan",
		Code:               "FAL-" + util.RandomAlphaNumericString(4),
		ProductType:        loansv1.LoanProductType_LOAN_PRODUCT_TYPE_TERM,
		CurrencyCode:       currency,
		InterestMethod:     loansv1.InterestMethod_INTEREST_METHOD_FLAT,
		RepaymentFrequency: loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_MONTHLY,
		MinAmount:          kes(1_000_00),
		MaxAmount:          kes(1_000_000_00),
		MinTermDays:        30,
		MaxTermDays:        365,
		AnnualInterestRate: "12",
		State:              commonv1.STATE_ACTIVE,
	}})
	s.Require().NoError(err)
	id := resp.GetData().GetId()
	s.Require().NotEmpty(id)
	// The product is written by loans' own event handler, after Save returns.
	s.Require().Eventually(func() bool {
		_, getErr := s.staffLoans.LoanProductGet(s.ctx, &loansv1.LoanProductGetRequest{Id: id})
		return getErr == nil
	}, settleWait, settleTick, "the saved product becomes readable")
	return id
}

// fieldAgent is a field agent (platform role member) signed in to loans.
type fieldAgent struct {
	memberID string
	loans    loansv1connect.LoanManagementServiceClient
}

// newBorrower registers a borrower, with a verified mobile number on their
// profile, and the field agent who serves them. Each borrower gets their own
// agent: loans caches who an agent serves for 30 seconds.
func (s *lendingSuite) newBorrower(msisdn string) (*borrower, *fieldAgent) {
	b := &borrower{
		clientID:  util.IDString(),
		profileID: util.IDString(),
		contactID: util.IDString(),
		msisdn:    msisdn,
	}
	s.platform.addBorrower(b)

	agentProfile := util.IDString()
	agent := &fieldAgent{memberID: util.IDString()}
	s.platform.addAgent(agentProfile, agent.memberID, b.clientID)
	// A field agent's access in the lender's partition carries the member
	// role only.
	s.Require().NoError(s.tenancy.accessSynced(s.ctx, tenancyPath(s.tenantID, s.partitionID),
		agentProfile, roleMember))
	token := "token-agent-" + agentProfile
	s.tokens.issue(token, s.person(agentProfile, roleMember))
	agent.loans = loansv1connect.NewLoanManagementServiceClient(client(s.router, loansHost, token))
	return b, agent
}

// originate takes a loan from the agent's application to an approved,
// funded loan account awaiting disbursement.
func (s *lendingSuite) originate(b *borrower, agent *fieldAgent, principal int64) *loansv1.LoanAccountObject {
	req, err := agent.loans.LoanRequestSave(s.ctx, &loansv1.LoanRequestSaveRequest{Data: &loansv1.LoanRequestObject{
		ProductId:         s.productID,
		ClientId:          b.clientID,
		OrganizationId:    s.tenantID,
		Status:            loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED,
		RequestedAmount:   kes(principal),
		RequestedTermDays: 30,
		CurrencyCode:      currency,
		Purpose:           "stock for the shop",
	}})
	s.Require().NoError(err, "agent submits the application")
	s.Equal(agent.memberID, req.GetData().GetAgentId(), "the serving agent is stamped from the caller")

	_, err = s.staffLoans.LoanRequestApprove(s.ctx, &loansv1.LoanRequestApproveRequest{Id: req.GetData().GetId()})
	s.Require().NoError(err, "staff approve the application")

	la, err := s.staffLoans.LoanAccountCreate(s.ctx,
		&loansv1.LoanAccountCreateRequest{LoanRequestId: req.GetData().GetId()})
	s.Require().NoError(err, "staff open the loan account")
	s.Equal(loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT, la.GetData().GetStatus())
	s.Equal(b.contactID, la.GetData().GetPaymentAccountRef(),
		"the payout goes to the borrower's verified mobile number, by contact id")
	return la.GetData()
}

// disburse pays the loan out through operations and the payment rail.
func (s *lendingSuite) disburse(la *loansv1.LoanAccountObject) string {
	key := "disburse-" + la.GetId()
	disb, err := s.staffLoans.DisbursementCreate(s.ctx, &loansv1.DisbursementCreateRequest{
		LoanAccountId:  la.GetId(),
		Channel:        "mobile_money",
		IdempotencyKey: key,
	})
	s.Require().NoError(err, "staff disburse the loan")
	s.Equal(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_COMPLETED, disb.GetData().GetStatus())
	return "disbursement:" + key
}

func (s *lendingSuite) loan(id string) *loansv1.LoanAccountObject {
	resp, err := s.staffLoans.LoanAccountGet(s.ctx, &loansv1.LoanAccountGetRequest{Id: id})
	s.Require().NoError(err)
	return resp.GetData()
}

func (s *lendingSuite) balance(id string) *loansv1.LoanBalanceObject {
	resp, err := s.staffLoans.LoanBalanceGet(s.ctx, &loansv1.LoanBalanceGetRequest{LoanAccountId: id})
	s.Require().NoError(err)
	return resp.GetData()
}

func (s *lendingSuite) repayments(loanID string) []*loansv1.RepaymentObject {
	stream, err := s.staffLoans.RepaymentSearch(s.ctx, &loansv1.RepaymentSearchRequest{LoanAccountId: loanID})
	s.Require().NoError(err)
	defer func() { _ = stream.Close() }()
	var out []*loansv1.RepaymentObject
	for {
		msg, recvErr := stream.Receive()
		if recvErr != nil {
			s.Require().ErrorIs(recvErr, io.EOF)
			return out
		}
		out = append(out, msg.GetData()...)
	}
}

// receivedPayment is an inbound payment as the payment service publishes it
// to operations' payment-received queue: its Payment model as JSON. The
// payer is named by profile and contact id; the collection prompt that
// asked for it named the loan.
func (s *lendingSuite) receivedPayment(b *borrower, railID, loanID, amount string) []byte {
	msg, err := json.Marshal(map[string]any{
		"ID":              railID,
		"TenantID":        s.tenantID,
		"PartitionID":     s.partitionID,
		"SenderProfileID": b.profileID,
		"SenderContactID": b.contactID,
		"amount":          amount,
		"Currency":        currency,
		"TransactionID":   "MPESA-" + railID,
		"OutBound":        false,
		"extra": map[string]any{
			"product_id":      s.productID,
			"loan_account_id": loanID,
			"prompt_id":       railID,
			"purpose":         "loan_repayment",
		},
	})
	s.Require().NoError(err)
	return msg
}

// publishPayment delivers a received payment the way production does: on
// the queue operations consumes.
func (s *lendingSuite) publishPayment(msg []byte) {
	s.Require().NoError(s.opsSvc.QueueManager().Publish(s.ctx, paymentPublisher, msg))
}

// redeliverPayment hands the same message to operations' consumer again,
// synchronously, as a queue redelivery would.
func (s *lendingSuite) redeliverPayment(msg []byte) {
	s.Require().NoError(s.ops.paymentReceived.Handle(s.ctx, nil, msg))
}

func (s *lendingSuite) awaitOutstanding(loanID string, want int64) {
	s.Require().Eventually(func() bool {
		return minor(s.balance(loanID).GetTotalOutstanding()) == want
	}, settleWait, settleTick, "loan %s outstanding never reached %d", loanID, want)
}

func (s *lendingSuite) runOperationsJob(job operationsv1.OperationsJob) {
	_, err := s.schedulerOps.OperationsJobRun(s.asTenant(), &operationsv1.OperationsJobRunRequest{Job: job})
	s.Require().NoError(err)
}

// TestLoanLifecycle drives one loan from application to paid off across the
// loans/operations seam.
func (s *lendingSuite) TestLoanLifecycle() {
	b, agent := s.newBorrower("+254700000101")
	const principal = int64(10_000_00)
	la := s.originate(b, agent, principal)

	// 1. Disbursement: operations pays the borrower through the rail.
	reference := s.disburse(la)
	var order struct {
		OrderType           int32
		State               int32
		Amount              int64
		LedgerTransactionID string
		PaymentID           string
		PayoutStatus        string
	}
	s.Require().NoError(s.opsDB.Table("transfer_orders").Where("reference = ?", reference).Take(&order).Error,
		"operations holds the disbursement order")
	s.Equal(int32(constants.TransferTypeDisbursement), order.OrderType)
	s.Equal(int32(constants.StateInactive), order.State, "executed")
	s.Equal(principal, order.Amount)
	s.NotEmpty(order.LedgerTransactionID, "its ledger leg posted")
	s.NotEmpty(order.PaymentID, "the rail's payment id is recorded")
	s.Equal("pending", order.PayoutStatus, "accepted by the rail, not yet confirmed")

	sends := s.platform.payoutSendsFor(reference)
	s.Require().Len(sends, 1, "exactly one payout reached the payment service")
	payout := sends[0].GetData()
	s.True(payout.GetOutbound())
	s.Equal(b.profileID, payout.GetRecipient().GetProfileId(), "paid to the borrower's profile")
	s.Equal(b.contactID, payout.GetRecipient().GetContactId(), "at their verified mobile number")
	s.Empty(payout.GetRecipient().GetDetail(), "operations never handles the number itself")
	s.Empty(payout.GetRoute(), "routing belongs to the payment service")
	s.Equal(principal, minor(payout.GetAmount()))
	s.Equal(currency, payout.GetAmount().GetCurrencyCode())

	active := s.loan(la.GetId())
	s.Equal(loansv1.LoanStatus_LOAN_STATUS_ACTIVE, active.GetStatus())
	s.NotEmpty(active.GetDisbursedAt())
	// Loans writes the opening balance through its own event queue.
	s.Require().Eventually(func() bool {
		_, err := s.staffLoans.LoanBalanceGet(s.ctx, &loansv1.LoanBalanceGetRequest{LoanAccountId: la.GetId()})
		return err == nil
	}, settleWait, settleTick, "the opening balance is written")
	owed := minor(s.balance(la.GetId()).GetTotalOutstanding())
	s.Require().Greater(owed, principal, "principal plus interest is owed")

	// The schedule re-anchored at disbursement replaces the opening one:
	// one active schedule, whatever order the two saves landed in.
	s.Require().Eventually(func() bool {
		var schedules int64
		s.Require().NoError(s.loansDB.Table("repayment_schedules").
			Where("loan_account_id = ? AND deleted_at IS NULL", la.GetId()).Count(&schedules).Error)
		return schedules >= 2
	}, settleWait, settleTick, "the opening and re-anchored schedules are written")
	var activeSchedules int64
	s.Require().NoError(s.loansDB.Table("repayment_schedules").
		Where("loan_account_id = ? AND is_active AND deleted_at IS NULL", la.GetId()).Count(&activeSchedules).Error)
	s.Equal(int64(1), activeSchedules, "a loan has one active repayment schedule")

	// 2. A partial repayment from the borrower's own number.
	const partial = int64(2_500_50)
	first := s.receivedPayment(b, "rail-"+util.IDString(), la.GetId(), "2500.50")
	s.publishPayment(first)
	s.awaitOutstanding(la.GetId(), owed-partial)
	reps := s.repayments(la.GetId())
	s.Require().Len(reps, 1, "the payment is recorded once")
	s.Equal(partial, minor(reps[0].GetAmount()))
	s.Equal("mobile_money", reps[0].GetChannel())

	// 3. The rail redelivers the same payment: nothing is applied twice, and
	// the scheduled settle pass finds nothing left to do.
	s.redeliverPayment(first)
	s.runOperationsJob(operationsv1.OperationsJob_OPERATIONS_JOB_SETTLE_PAYMENTS)
	s.Equal(owed-partial, minor(s.balance(la.GetId()).GetTotalOutstanding()))
	s.Len(s.repayments(la.GetId()), 1, "a redelivered payment books nothing")

	// 4. The rest of the loan, paid in full.
	rest := owed - partial
	final := s.receivedPayment(b, "rail-"+util.IDString(), la.GetId(),
		moneyx.FromMoney(kes(rest)).String())
	s.publishPayment(final)
	s.awaitOutstanding(la.GetId(), 0)
	s.Require().Eventually(func() bool {
		return s.loan(la.GetId()).GetStatus() == loansv1.LoanStatus_LOAN_STATUS_PAID_OFF
	}, settleWait, settleTick, "a fully repaid loan is paid off")
	var paid int64
	for _, r := range s.repayments(la.GetId()) {
		paid += minor(r.GetAmount())
	}
	s.Len(s.repayments(la.GetId()), 2)
	s.Equal(owed, paid, "the two repayments add up to what was owed")
}

// TestPayoutFailedAfterAcceptance: the rail accepts a payout and fails it
// later. Operations' reconcile job finds out, reverses the ledger leg and
// tells loans, which puts the loan back to awaiting disbursement.
func (s *lendingSuite) TestPayoutFailedAfterAcceptance() {
	b, agent := s.newBorrower("+254700000202")
	la := s.originate(b, agent, 5_000_00)
	reference := s.disburse(la)
	s.Equal(loansv1.LoanStatus_LOAN_STATUS_ACTIVE, s.loan(la.GetId()).GetStatus())

	s.platform.settlePayout(reference, commonv1.STATUS_FAILED)
	// The reconcile job looks only at payouts older than its settle window;
	// age this one instead of waiting it out.
	s.Require().NoError(s.opsDB.Exec(
		"UPDATE transfer_orders SET payment_initiated_at = ? WHERE reference = ?",
		time.Now().UTC().Add(-time.Hour), reference).Error)

	s.runOperationsJob(operationsv1.OperationsJob_OPERATIONS_JOB_RECONCILE_PAYOUTS)
	s.Require().Eventually(func() bool {
		return s.loan(la.GetId()).GetStatus() == loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT
	}, settleWait, settleTick, "the loan awaits disbursement again")

	var reversals int64
	s.Require().NoError(s.opsDB.Table("transfer_orders").
		Where("reference = ? AND state = ?", "payout-reversal:"+reference, constants.StateInactive).
		Count(&reversals).Error)
	s.Equal(int64(1), reversals, "the ledger leg is reversed once")
	s.Len(s.platform.payoutSendsFor(reference), 1, "nothing is resent on its own")
}
