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
	"strings"

	"buf.build/gen/go/antinvestor/field/connectrpc/go/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/loans/v1/loansv1connect"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// identityKYCVerifier resolves a client's KYC verdict from the verified client
// data the identity service holds. A client counts as verified when every
// field key in the deployment's checklist is present and VERIFIED.
type identityKYCVerifier struct {
	identityCli identityv1connect.IdentityServiceClient
	// requiredFields is the deployment's KYC checklist. An empty checklist
	// means "at least one verified data entry".
	requiredFields []string
}

// NewIdentityKYCVerifier builds the production KYC verifier.
func NewIdentityKYCVerifier(
	identityCli identityv1connect.IdentityServiceClient,
	requiredFields []string,
) KYCVerifier {
	return &identityKYCVerifier{identityCli: identityCli, requiredFields: requiredFields}
}

func (v *identityKYCVerifier) VerifyClient(ctx context.Context, clientID string) (KYCStatus, error) {
	stream, err := v.identityCli.ClientDataList(ctx, connect.NewRequest(
		&identityv1.ClientDataListRequest{ClientId: clientID},
	))
	if err != nil {
		return KYCStatusUnknown, fmt.Errorf("list client data: %w", err)
	}

	verified := map[string]bool{}
	rejected := false
	anyEntry := false
	for stream.Receive() {
		for _, entry := range stream.Msg().GetData() {
			anyEntry = true
			switch entry.GetVerificationStatus() {
			case identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_VERIFIED:
				verified[entry.GetFieldKey()] = true
			case identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_REJECTED,
				identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_EXPIRED:
				rejected = true
			case identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_UNSPECIFIED,
				identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_COLLECTED,
				identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_UNDER_REVIEW,
				identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_MORE_INFO_NEEDED:
			}
		}
	}
	if streamErr := stream.Err(); streamErr != nil {
		return KYCStatusUnknown, fmt.Errorf("list client data: %w", streamErr)
	}

	if len(v.requiredFields) == 0 {
		if len(verified) > 0 {
			return KYCStatusVerified, nil
		}
		return pendingOrFailed(anyEntry, rejected), nil
	}

	for _, field := range v.requiredFields {
		if !verified[field] {
			return pendingOrFailed(anyEntry, rejected), nil
		}
	}
	return KYCStatusVerified, nil
}

func pendingOrFailed(anyEntry, rejected bool) KYCStatus {
	switch {
	case rejected:
		return KYCStatusFailed
	case anyEntry:
		return KYCStatusPending
	default:
		return KYCStatusUnknown
	}
}

// loansLoanCreator drives the real loans service through the
// request → approve → account → disburse chain.
type loansLoanCreator struct {
	loansCli loansv1connect.LoanManagementServiceClient
}

// NewLoansLoanCreator builds the production loan creator.
func NewLoansLoanCreator(loansCli loansv1connect.LoanManagementServiceClient) LoanCreator {
	return &loansLoanCreator{loansCli: loansCli}
}

func (c *loansLoanCreator) CreateApplication(
	ctx context.Context,
	req LoanCreationRequest,
) (string, error) {
	amount := moneyx.FromMinorUnitsByCurrency(req.CurrencyCode, req.Amount)
	resp, err := c.loansCli.LoanRequestSave(ctx, connect.NewRequest(&loansv1.LoanRequestSaveRequest{
		Data: &loansv1.LoanRequestObject{
			ProductId:         req.ProductID,
			ClientId:          req.ClientID,
			Status:            loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED,
			RequestedAmount:   amount,
			ApprovedAmount:    amount,
			RequestedTermDays: req.TermDays,
			ApprovedTermDays:  req.TermDays,
			CurrencyCode:      req.CurrencyCode,
			Purpose:           req.Purpose,
			SourceService:     sourceServiceSeed,
			SourceRequestId:   strings.TrimPrefix(req.IdempotencyKey, "seed:"),
			IdempotencyKey:    req.IdempotencyKey,
		},
	}))
	if err != nil {
		return "", fmt.Errorf("loan request save: %w", err)
	}
	if resp.Msg.GetData() == nil {
		return "", errors.New("loans service returned no loan request")
	}

	requestID := resp.Msg.GetData().GetId()
	if _, approveErr := c.loansCli.LoanRequestApprove(ctx, connect.NewRequest(
		&loansv1.LoanRequestApproveRequest{Id: requestID},
	)); approveErr != nil {
		return "", fmt.Errorf("loan request approve: %w", approveErr)
	}
	return requestID, nil
}

func (c *loansLoanCreator) CreateLoanAccount(
	ctx context.Context,
	applicationID string,
) (string, error) {
	resp, err := c.loansCli.LoanAccountCreate(ctx, connect.NewRequest(
		&loansv1.LoanAccountCreateRequest{LoanRequestId: applicationID},
	))
	if err != nil {
		return "", fmt.Errorf("loan account create: %w", err)
	}
	if resp.Msg.GetData() == nil {
		return "", errors.New("loans service returned no loan account")
	}
	return resp.Msg.GetData().GetId(), nil
}

func (c *loansLoanCreator) Disburse(
	ctx context.Context,
	loanAccountID string,
	idempotencyKey string,
) (string, error) {
	if idempotencyKey == "" {
		return "", apperrors.NewError(apperrors.BadRequest, "an idempotency key is required to disburse")
	}
	resp, err := c.loansCli.DisbursementCreate(ctx, connect.NewRequest(
		&loansv1.DisbursementCreateRequest{
			LoanAccountId:  loanAccountID,
			IdempotencyKey: idempotencyKey,
		},
	))
	if err != nil {
		return "", fmt.Errorf("disbursement create: %w", err)
	}
	if resp.Msg.GetData() == nil {
		return "", errors.New("loans service returned no disbursement")
	}
	return resp.Msg.GetData().GetId(), nil
}

func (c *loansLoanCreator) FindDisbursement(
	ctx context.Context,
	loanAccountID string,
	idempotencyKey string,
) (string, bool, error) {
	if loanAccountID == "" || idempotencyKey == "" {
		return "", false, nil
	}
	stream, err := c.loansCli.DisbursementSearch(ctx, connect.NewRequest(
		&loansv1.DisbursementSearchRequest{LoanAccountId: loanAccountID},
	))
	if err != nil {
		return "", false, fmt.Errorf("disbursement search: %w", err)
	}
	defer func() { _ = stream.Close() }()

	for stream.Receive() {
		for _, disb := range stream.Msg().GetData() {
			if disb.GetIdempotencyKey() == idempotencyKey {
				return disb.GetId(), true, nil
			}
		}
	}
	if streamErr := stream.Err(); streamErr != nil {
		return "", false, fmt.Errorf("disbursement search: %w", streamErr)
	}
	return "", false, nil
}

// identityClientResolver bridges an authenticated profile to the client row
// the identity platform holds for it. Clients are exposed on the field
// service, which the identity binary serves alongside its own API.
type identityClientResolver struct {
	fieldCli fieldv1connect.FieldServiceClient
}

// NewIdentityClientResolver builds the production client resolver.
func NewIdentityClientResolver(fieldCli fieldv1connect.FieldServiceClient) ClientResolver {
	return &identityClientResolver{fieldCli: fieldCli}
}

// ResolveByProfileID searches clients by free text. The clients search vector
// includes profile_id, so the profile id is a usable query term; the streamed
// results are still filtered on an exact profile match because a free-text
// index can return neighbours.
func (r *identityClientResolver) ResolveByProfileID(ctx context.Context, profileID string) (string, error) {
	profileID = strings.TrimSpace(profileID)
	if profileID == "" {
		return "", ErrNoClientForProfile
	}

	stream, err := r.fieldCli.ClientSearch(ctx, connect.NewRequest(
		&fieldv1.ClientSearchRequest{Query: profileID},
	))
	if err != nil {
		return "", fmt.Errorf("client search: %w", err)
	}
	defer func() { _ = stream.Close() }()

	for stream.Receive() {
		for _, client := range stream.Msg().GetData() {
			if client.GetProfileId() == profileID {
				return client.GetId(), nil
			}
		}
	}
	if streamErr := stream.Err(); streamErr != nil {
		return "", fmt.Errorf("client search: %w", streamErr)
	}
	return "", ErrNoClientForProfile
}
