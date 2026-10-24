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

//go:build dev

package business

import (
	"context"

	"github.com/pitabwire/util"
)

// AlwaysVerifiedKYC treats every client as KYC-verified.
//
// It is compiled only under the `dev` build tag and is never part of a
// production binary: the release build wires NewIdentityKYCVerifier, which
// reads verified client data from the identity service.
type AlwaysVerifiedKYC struct{}

// VerifyClient returns KYCStatusVerified for every client.
func (AlwaysVerifiedKYC) VerifyClient(ctx context.Context, clientID string) (KYCStatus, error) {
	util.Log(ctx).
		WithField("method", "AlwaysVerifiedKYC.VerifyClient").
		WithField("client_id", clientID).
		Warn("stub KYCVerifier in use; replace with real identity integration before production")
	return KYCStatusVerified, nil
}

// StubLoanCreator records the intent of each stage without calling the loans
// service, returning synthetic ids.
//
// It is compiled only under the `dev` build tag and is never part of a
// production binary: the release build wires NewLoansLoanCreator.
type StubLoanCreator struct{}

// CreateApplication records the intent of creating an application and
// returns a synthetic id.
func (StubLoanCreator) CreateApplication(
	ctx context.Context,
	req LoanCreationRequest,
) (string, error) {
	util.Log(ctx).
		WithField("method", "StubLoanCreator.CreateApplication").
		WithField("client_id", req.ClientID).
		WithField("amount", req.Amount).
		Warn("stub LoanCreator in use; no application actually created")
	return "stub-application-" + req.IdempotencyKey, nil
}

// CreateLoanAccount records the intent of creating a loan account and
// returns a synthetic id.
func (StubLoanCreator) CreateLoanAccount(
	ctx context.Context,
	applicationID string,
) (string, error) {
	util.Log(ctx).
		WithField("method", "StubLoanCreator.CreateLoanAccount").
		WithField("application_id", applicationID).
		Warn("stub LoanCreator in use; no loan account actually created")
	return "stub-loan-" + applicationID, nil
}

// Disburse records the intent of disbursing and returns a synthetic id.
func (StubLoanCreator) Disburse(
	ctx context.Context,
	loanAccountID string,
	idempotencyKey string,
) (string, error) {
	util.Log(ctx).
		WithField("method", "StubLoanCreator.Disburse").
		WithField("loan_account_id", loanAccountID).
		Warn("stub LoanCreator in use; no disbursement actually executed")
	return "stub-disb-" + idempotencyKey, nil
}

// FindDisbursement reports that no disbursement exists, because the stub never
// executed one.
func (StubLoanCreator) FindDisbursement(
	ctx context.Context,
	loanAccountID string,
	idempotencyKey string,
) (string, bool, error) {
	util.Log(ctx).
		WithField("method", "StubLoanCreator.FindDisbursement").
		WithField("loan_account_id", loanAccountID).
		WithField("idempotency_key", idempotencyKey).
		Warn("stub LoanCreator in use; no disbursement to find")
	return "", false, nil
}
