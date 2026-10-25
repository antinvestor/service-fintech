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
	"strings"

	"google.golang.org/protobuf/types/known/structpb"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/v2/loans/v1/loansv1connect"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// clientStandingKYCVerifier reads a client's KYC verdict from identity:
// a client is activated (ACTIVE) only once every field its organization
// requires is verified and the person consented. What each organization
// requires is configured there, on its client form template, not here.
type clientStandingKYCVerifier struct {
	fieldCli fieldv1connect.FieldServiceClient
}

// NewClientStandingKYCVerifier builds the production KYC verifier.
func NewClientStandingKYCVerifier(fieldCli fieldv1connect.FieldServiceClient) KYCVerifier {
	return &clientStandingKYCVerifier{fieldCli: fieldCli}
}

func (v *clientStandingKYCVerifier) VerifyClient(ctx context.Context, clientID string) (KYCStatus, error) {
	resp, err := v.fieldCli.ClientGet(ctx, &fieldv1.ClientGetRequest{Id: clientID})
	if err != nil {
		return KYCStatusUnknown, fmt.Errorf("client get: %w", err)
	}
	switch resp.GetData().GetState() {
	case commonv1.STATE_ACTIVE:
		return KYCStatusVerified, nil
	case commonv1.STATE_CREATED, commonv1.STATE_CHECKED:
		return KYCStatusPending, nil
	case commonv1.STATE_INACTIVE, commonv1.STATE_DELETED:
		return KYCStatusFailed, nil
	default:
		return KYCStatusFailed, nil
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
	// Seed is a service principal: it has verified the borrower's KYC itself
	// and names the payout destination; the loans service keeps these only
	// from staff and services.
	props, propErr := structpb.NewStruct(map[string]any{
		"data_verification_confirmed": true,
		"payment_account_ref":         req.PayoutAccountRef,
		"payment_channel":             "mobile_money",
	})
	if propErr != nil {
		return "", fmt.Errorf("loan request properties: %w", propErr)
	}
	resp, err := c.loansCli.LoanRequestSave(ctx, &loansv1.LoanRequestSaveRequest{
		Data: &loansv1.LoanRequestObject{
			Properties:        props,
			ProductId:         req.ProductID,
			ClientId:          req.ClientID,
			Status:            loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED,
			RequestedAmount:   amount,
			ApprovedAmount:    amount,
			RequestedTermDays: req.TermDays,
			ApprovedTermDays:  req.TermDays,
			CurrencyCode:      req.CurrencyCode,
			// The tier's rate, as a decimal percentage ("22.00"). Without it
			// the loan would be priced at the product's base rate and the
			// credit ladder's discount would never reach the borrower.
			InterestRate:    basisPointsToPercent(req.InterestRateBP),
			Purpose:         req.Purpose,
			SourceService:   sourceServiceSeed,
			SourceRequestId: strings.TrimPrefix(req.IdempotencyKey, "seed:"),
			IdempotencyKey:  req.IdempotencyKey,
		},
	})
	if err != nil {
		return "", fmt.Errorf("loan request save: %w", err)
	}
	if resp.GetData() == nil {
		return "", errors.New("loans service returned no loan request")
	}

	requestID := resp.GetData().GetId()
	if _, approveErr := c.loansCli.LoanRequestApprove(
		ctx,
		&loansv1.LoanRequestApproveRequest{Id: requestID},
	); approveErr != nil {
		return "", fmt.Errorf("loan request approve: %w", approveErr)
	}
	return requestID, nil
}

func (c *loansLoanCreator) CreateLoanAccount(
	ctx context.Context,
	applicationID string,
) (string, error) {
	resp, err := c.loansCli.LoanAccountCreate(ctx, &loansv1.LoanAccountCreateRequest{LoanRequestId: applicationID})
	if err != nil {
		return "", fmt.Errorf("loan account create: %w", err)
	}
	if resp.GetData() == nil {
		return "", errors.New("loans service returned no loan account")
	}
	return resp.GetData().GetId(), nil
}

func (c *loansLoanCreator) Disburse(
	ctx context.Context,
	loanAccountID string,
	idempotencyKey string,
) (string, error) {
	if idempotencyKey == "" {
		return "", apperrors.NewError(apperrors.BadRequest, "an idempotency key is required to disburse")
	}
	resp, err := c.loansCli.DisbursementCreate(ctx, &loansv1.DisbursementCreateRequest{
		LoanAccountId:  loanAccountID,
		IdempotencyKey: idempotencyKey,
	})
	if err != nil {
		return "", fmt.Errorf("disbursement create: %w", err)
	}
	if resp.GetData() == nil {
		return "", errors.New("loans service returned no disbursement")
	}
	return resp.GetData().GetId(), nil
}

func (c *loansLoanCreator) FindDisbursement(
	ctx context.Context,
	loanAccountID string,
	idempotencyKey string,
) (string, bool, error) {
	if loanAccountID == "" || idempotencyKey == "" {
		return "", false, nil
	}
	stream, err := c.loansCli.DisbursementSearch(ctx, &loansv1.DisbursementSearchRequest{LoanAccountId: loanAccountID})
	if err != nil {
		return "", false, fmt.Errorf("disbursement search: %w", err)
	}
	defer func() { _ = stream.Close() }()

	for {
		msg, streamErr := stream.Receive()
		if streamErr != nil {
			if errors.Is(streamErr, io.EOF) {
				break
			}
			return "", false, fmt.Errorf("disbursement search: %w", streamErr)
		}
		for _, disb := range msg.GetData() {
			if disb.GetIdempotencyKey() == idempotencyKey {
				return disb.GetId(), true, nil
			}
		}
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

	stream, err := r.fieldCli.ClientSearch(ctx, &fieldv1.ClientSearchRequest{Query: profileID})
	if err != nil {
		return "", fmt.Errorf("client search: %w", err)
	}
	defer func() { _ = stream.Close() }()

	for {
		msg, streamErr := stream.Receive()
		if streamErr != nil {
			if errors.Is(streamErr, io.EOF) {
				break
			}
			return "", fmt.Errorf("client search: %w", streamErr)
		}
		for _, client := range msg.GetData() {
			if client.GetProfileId() == profileID {
				return client.GetId(), nil
			}
		}
	}

	return "", ErrNoClientForProfile
}

// basisPointsToPercent renders basis points as the decimal percentage the
// loans API takes; zero leaves the product's rate in force.
func basisPointsToPercent(bp int64) string {
	if bp <= 0 {
		return ""
	}
	return fmt.Sprintf("%d.%02d", bp/100, bp%100) //nolint:mnd // basis points per percent
}
