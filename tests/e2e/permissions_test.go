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
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/v2/loans/v1/loansv1connect"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"connectrpc.com/connect/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
)

// loansAs is a loans client under a freshly issued token.
func (s *lendingSuite) loansAs(
	token string, claims *security.AuthenticationClaims,
) loansv1connect.LoanManagementServiceClient {
	s.tokens.issue(token, claims)
	return loansv1connect.NewLoanManagementServiceClient(client(s.router, loansHost, token))
}

func (s *lendingSuite) requireCode(want connect.Code, err error, why string) {
	s.Require().Error(err, why)
	s.Require().Equal(want, connect.CodeOf(err), "%s: %v", why, err)
}

// TestFieldAgentCannotApproveOrDisburse: a field agent holds the member
// role, which may submit applications but not decide or pay them.
func (s *lendingSuite) TestFieldAgentCannotApproveOrDisburse() {
	b, agent := s.newBorrower("+254700000303")

	req, err := agent.loans.LoanRequestSave(s.ctx, &loansv1.LoanRequestSaveRequest{Data: &loansv1.LoanRequestObject{
		ProductId:         s.productID,
		ClientId:          b.clientID,
		OrganizationId:    s.tenantID,
		Status:            loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED,
		RequestedAmount:   kes(3_000_00),
		RequestedTermDays: 30,
		CurrencyCode:      currency,
		Purpose:           "stock",
	}})
	s.Require().NoError(err, "the agent may submit (loan_request_submit)")
	requestID := req.GetData().GetId()

	_, err = agent.loans.LoanRequestApprove(s.ctx, &loansv1.LoanRequestApproveRequest{Id: requestID})
	s.requireCode(connect.CodePermissionDenied, err, "an agent cannot approve (loan_request_manage)")

	_, err = s.staffLoans.LoanRequestApprove(s.ctx, &loansv1.LoanRequestApproveRequest{Id: requestID})
	s.Require().NoError(err, "staff approve it")

	_, err = agent.loans.LoanAccountCreate(s.ctx, &loansv1.LoanAccountCreateRequest{LoanRequestId: requestID})
	s.requireCode(connect.CodePermissionDenied, err, "an agent cannot open the loan (loan_manage)")

	la, err := s.staffLoans.LoanAccountCreate(s.ctx, &loansv1.LoanAccountCreateRequest{LoanRequestId: requestID})
	s.Require().NoError(err, "staff open the loan account")

	_, err = agent.loans.DisbursementCreate(s.ctx, &loansv1.DisbursementCreateRequest{
		LoanAccountId:  la.GetData().GetId(),
		Channel:        "mobile_money",
		IdempotencyKey: "agent-disburse-" + la.GetData().GetId(),
	})
	s.requireCode(connect.CodePermissionDenied, err, "an agent cannot disburse (disbursement_manage)")

	s.Equal(loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT, s.loan(la.GetData().GetId()).GetStatus(),
		"nothing was paid out")
	s.Empty(s.platform.payoutSendsFor("disbursement:agent-disburse-"+la.GetData().GetId()),
		"no payout reached the rail")
}

// TestOutsidersAreRefused: nobody outside the lender's partition reaches
// its loans, whatever their role elsewhere or the tenancy they name.
func (s *lendingSuite) TestOutsidersAreRefused() {
	b, agent := s.newBorrower("+254700000404")
	la := s.originate(b, agent, 2_000_00)

	// A credit manager of another lender, with full staff rights there.
	otherTenant, otherPartition := util.IDString(), util.IDString()
	outsiderProfile := util.IDString()
	s.Require().NoError(s.tenancy.accessSynced(s.ctx, tenancyPath(otherTenant, otherPartition),
		outsiderProfile, roleAdmin))
	outsider := s.loansAs("token-outsider-"+outsiderProfile, &security.AuthenticationClaims{
		TenantID:         otherTenant,
		PartitionID:      otherPartition,
		Roles:            []string{roleAdmin},
		RegisteredClaims: jwt.RegisteredClaims{Subject: outsiderProfile},
	})

	_, err := outsider.LoanAccountGet(s.ctx, &loansv1.LoanAccountGetRequest{Id: la.GetId()})
	s.requireCode(connect.CodeNotFound, err, "another lender's staff do not see the loan")

	// Naming the lender's tenancy on the call does not move a person into
	// it: only internal callers act for the tenant they name.
	_, err = outsider.LoanAccountGet(s.asTenant(), &loansv1.LoanAccountGetRequest{Id: la.GetId()})
	s.requireCode(connect.CodePermissionDenied, err, "a person cannot borrow the lender's tenancy by header")

	// A person whose token names the lender's partition but who holds no
	// access there (never granted, or revoked): Keto refuses at the door.
	stranger := s.loansAs("token-stranger", s.person(util.IDString(), roleAdmin))
	_, err = stranger.LoanAccountGet(s.ctx, &loansv1.LoanAccountGetRequest{Id: la.GetId()})
	s.requireCode(connect.CodePermissionDenied, err, "no tenancy_access membership, no entry")
	_, err = stranger.LoanRequestApprove(s.ctx, &loansv1.LoanRequestApproveRequest{Id: la.GetLoanRequestId()})
	s.requireCode(connect.CodePermissionDenied, err, "nor any decision")
}

// TestPayoutOutcomeNeedsTheOperationsGrant: PayoutFailedApply is for the
// operations service alone (payout_outcome_apply, granted to its service
// account). Another service account, staff and agents are refused.
func (s *lendingSuite) TestPayoutOutcomeNeedsTheOperationsGrant() {
	_, agent := s.newBorrower("+254700000505")
	req := &loansv1.PayoutFailedApplyRequest{Reference: "disbursement:none-" + util.IDString(), Reason: "test"}

	operations := loansv1connect.NewLoanManagementServiceClient(client(s.router, loansHost, operationsToken))
	resp, err := operations.PayoutFailedApply(s.asTenant(), req)
	s.Require().NoError(err, "the operations service account holds the grant")
	s.False(resp.GetApplied(), "an unknown reference undoes nothing")

	trustage := loansv1connect.NewLoanManagementServiceClient(client(s.router, loansHost, schedulerToken))
	_, err = trustage.PayoutFailedApply(s.asTenant(), req)
	s.requireCode(connect.CodePermissionDenied, err, "an internal caller without the grant is refused")

	_, err = s.staffLoans.PayoutFailedApply(s.ctx, req)
	s.requireCode(connect.CodePermissionDenied, err, "staff cannot fake a rail outcome")

	_, err = agent.loans.PayoutFailedApply(s.ctx, req)
	s.requireCode(connect.CodePermissionDenied, err, "nor can an agent")
}
