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

package business

import (
	"context"
	"errors"
	"fmt"
	"io"

	"buf.build/gen/go/antinvestor/loans/connectrpc/go/v2/loans/v1/loansv1connect"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"connectrpc.com/connect/v2"
)

// GroupLender is the part of the loans service a group loan goes through.
// The loans service owns the loan, its funding and the money that leaves;
// stawi only asks for each step and remembers how far it got.
type GroupLender interface {
	// HasOpenLoan reports whether the client has a loan that is not yet
	// repaid or closed.
	HasOpenLoan(ctx context.Context, clientID string) (bool, error)
	// LoanRequestStatus reads a loan request; found is false when the loans
	// service has no request with that id.
	LoanRequestStatus(ctx context.Context, id string) (status loansv1.LoanRequestStatus, found bool, err error)
	// SubmitLoanRequest writes the request under the id it carries, so
	// sending it again rewrites the same request.
	SubmitLoanRequest(ctx context.Context, request *loansv1.LoanRequestObject) error
	ApproveLoanRequest(ctx context.Context, id string) error
	// CreateLoanAccount returns the loan of an approved request; the loans
	// service answers a repeat with the loan it already made.
	CreateLoanAccount(ctx context.Context, loanRequestID string) (string, error)
	// Disburse pays the loan out to its payment account. The loans service
	// answers a repeat of the same key with the disbursement it started.
	Disburse(ctx context.Context, loanAccountID, idempotencyKey string) (*loansv1.DisbursementObject, error)
	// CancelLoanAccount closes a loan that was never paid out, releasing its
	// funding.
	CancelLoanAccount(ctx context.Context, loanAccountID, reason string) error
}

// openLoanStatuses are the loan statuses that still hold the borrower: the
// loan is waiting for its money or is being repaid.
//
//nolint:gochecknoglobals // immutable status set
var openLoanStatuses = map[loansv1.LoanStatus]bool{
	loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT: true,
	loansv1.LoanStatus_LOAN_STATUS_ACTIVE:               true,
	loansv1.LoanStatus_LOAN_STATUS_DELINQUENT:           true,
	loansv1.LoanStatus_LOAN_STATUS_DEFAULT:              true,
	loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED:         true,
}

type loansGroupLender struct {
	cli loansv1connect.LoanManagementServiceClient
}

// NewLoansGroupLender adapts the loans service client. A nil client gives a
// nil lender, which the offer business reports as unavailable.
func NewLoansGroupLender(cli loansv1connect.LoanManagementServiceClient) GroupLender {
	if cli == nil {
		return nil
	}
	return &loansGroupLender{cli: cli}
}

func (l *loansGroupLender) HasOpenLoan(ctx context.Context, clientID string) (bool, error) {
	stream, err := l.cli.LoanAccountSearch(ctx, &loansv1.LoanAccountSearchRequest{ClientId: clientID})
	if err != nil {
		return false, fmt.Errorf("loan account search: %w", err)
	}
	defer func() { _ = stream.Close() }()

	for {
		msg, recvErr := stream.Receive()
		if recvErr != nil {
			if errors.Is(recvErr, io.EOF) {
				return false, nil
			}
			return false, fmt.Errorf("loan account search: %w", recvErr)
		}
		for _, loan := range msg.GetData() {
			// The filter is the loans service's; the client check is ours, so
			// another client's loan never blocks this member.
			if loan.GetClientId() == clientID && openLoanStatuses[loan.GetStatus()] {
				return true, nil
			}
		}
	}
}

func (l *loansGroupLender) LoanRequestStatus(
	ctx context.Context,
	id string,
) (loansv1.LoanRequestStatus, bool, error) {
	resp, err := l.cli.LoanRequestGet(ctx, &loansv1.LoanRequestGetRequest{Id: id})
	if err != nil {
		if connect.CodeOf(err) == connect.CodeNotFound {
			return loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_UNSPECIFIED, false, nil
		}
		return loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_UNSPECIFIED, false, fmt.Errorf("loan request get: %w", err)
	}
	if resp.GetData() == nil {
		return loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_UNSPECIFIED, false, nil
	}
	return resp.GetData().GetStatus(), true, nil
}

func (l *loansGroupLender) SubmitLoanRequest(ctx context.Context, request *loansv1.LoanRequestObject) error {
	if _, err := l.cli.LoanRequestSave(ctx, &loansv1.LoanRequestSaveRequest{Data: request}); err != nil {
		return fmt.Errorf("loan request save: %w", err)
	}
	return nil
}

func (l *loansGroupLender) ApproveLoanRequest(ctx context.Context, id string) error {
	if _, err := l.cli.LoanRequestApprove(ctx, &loansv1.LoanRequestApproveRequest{Id: id}); err != nil {
		return fmt.Errorf("loan request approve: %w", err)
	}
	return nil
}

func (l *loansGroupLender) CreateLoanAccount(ctx context.Context, loanRequestID string) (string, error) {
	resp, err := l.cli.LoanAccountCreate(ctx, &loansv1.LoanAccountCreateRequest{LoanRequestId: loanRequestID})
	if err != nil {
		return "", fmt.Errorf("loan account create: %w", err)
	}
	if resp.GetData().GetId() == "" {
		return "", errors.New("loans service returned no loan account")
	}
	return resp.GetData().GetId(), nil
}

func (l *loansGroupLender) Disburse(
	ctx context.Context,
	loanAccountID, idempotencyKey string,
) (*loansv1.DisbursementObject, error) {
	resp, err := l.cli.DisbursementCreate(ctx, &loansv1.DisbursementCreateRequest{
		LoanAccountId:  loanAccountID,
		IdempotencyKey: idempotencyKey,
	})
	if err != nil {
		return nil, fmt.Errorf("disbursement create: %w", err)
	}
	if resp.GetData() == nil {
		return nil, errors.New("loans service returned no disbursement")
	}
	return resp.GetData(), nil
}

func (l *loansGroupLender) CancelLoanAccount(ctx context.Context, loanAccountID, reason string) error {
	if _, err := l.cli.LoanAccountCancel(ctx, &loansv1.LoanAccountCancelRequest{
		Id:     loanAccountID,
		Reason: reason,
	}); err != nil {
		return fmt.Errorf("loan account cancel: %w", err)
	}
	return nil
}
