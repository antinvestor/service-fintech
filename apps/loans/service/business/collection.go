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
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"strings"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	paymentv1 "buf.build/gen/go/antinvestor/payment/protocolbuffers/go/v1"

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/payment/connectrpc/go/v2/v1/paymentv1connect"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

// collectionPromptStatus is the state a freshly raised prompt is in: the
// borrower has been asked, and nothing has been collected yet. The repayment
// arrives later from the payment rail, which matches the prompt's money to
// the loan the prompt names.
const collectionPromptStatus = "PENDING"

// CollectionBusiness asks a borrower to pay. It raises a payment prompt on the
// borrower's own mobile number; it does not move money — the payment that
// answers a prompt reaches the loan through the payment rail.
type CollectionBusiness interface {
	Initiate(ctx context.Context, req *loansv1.InitiateCollectionRequest) (*loansv1.InitiateCollectionResponse, error)
}

type collectionBusiness struct {
	loanAccountRepo repository.LoanAccountRepository
	loanBalanceRepo repository.LoanBalanceRepository
	notifier        *LoanNotifier
	scope           *ReadScope
	contacts        PayoutDestinationChecker
	payments        paymentv1connect.PaymentServiceClient
}

func NewCollectionBusiness(
	_ context.Context,
	loanAccountRepo repository.LoanAccountRepository,
	loanBalanceRepo repository.LoanBalanceRepository,
	notifier *LoanNotifier,
	opts ...Option,
) CollectionBusiness {
	o := applyOptions(opts)
	return &collectionBusiness{
		scope:           o.scope,
		contacts:        o.payoutChecker,
		payments:        o.payments,
		loanAccountRepo: loanAccountRepo,
		loanBalanceRepo: loanBalanceRepo,
		notifier:        notifier,
	}
}

func (b *collectionBusiness) Initiate(
	ctx context.Context,
	req *loansv1.InitiateCollectionRequest,
) (*loansv1.InitiateCollectionResponse, error) {
	logger := util.Log(ctx).WithField("method", "CollectionBusiness.Initiate")

	if req.GetIdempotencyKey() == "" {
		return nil, ErrIdempotencyKeyRequired
	}
	if req.GetPhoneNumber() != "" { //nolint:staticcheck // refusing the deprecated field
		// Fintech never takes a raw number: the borrower's contact is named
		// by its id on their profile.
		return nil, ErrCollectionRawContactRefused
	}

	la, err := b.loanAccountRepo.GetByID(ctx, req.GetLoanAccountId())
	if err != nil {
		return nil, ErrLoanAccountNotFound
	}
	// Prompting a borrower to pay is a lender-side action: staff, or the
	// field agent serving the client. The phone number is caller-supplied,
	// so letting anyone else raise prompts would let them message strangers.
	if scopeErr := b.scope.AuthorizeAgent(ctx, la.ClientID); scopeErr != nil {
		return nil, scopeErr
	}
	if !isRepayableStatus(la.Status) {
		return nil, ErrLoanNotRepayable
	}
	if b.payments == nil {
		return nil, ErrCollectionPromptUnavailable
	}
	if b.contacts == nil {
		return nil, ErrPayoutDestinationUnverifiable
	}
	// The prompt goes to the borrower's own verified mobile number: the one
	// named, or their first when none is.
	profileID, contactID, err := b.contacts.CollectionContact(ctx, la.ClientID, strings.TrimSpace(req.GetContactId()))
	if err != nil {
		return nil, err
	}

	amount, err := collectionAmount(req, la.CurrencyCode)
	if err != nil {
		return nil, err
	}
	// An unspecified amount means "whatever is still owed", which is the
	// natural ask when a collections officer prompts a delinquent loan; a
	// stated one is never more than that, so a prompt cannot ask a borrower
	// to pay more than they owe.
	balance, balErr := b.loanBalanceRepo.GetByLoanAccountID(ctx, la.GetID())
	if balErr != nil || balance == nil {
		return nil, ErrBalanceNotFound
	}
	if amount <= 0 || amount > balance.TotalOutstanding {
		amount = balance.TotalOutstanding
	}
	if amount <= 0 {
		return nil, ErrCollectionNothingOutstanding
	}

	// The prompt id is derived from the caller's idempotency key, so repeating
	// the request names the same prompt and the payment service does not
	// push the borrower a second time.
	promptID := collectionPromptID(la.GetID(), req.GetIdempotencyKey())

	// The extras travel with the money: the rail matches the payment that
	// answers this prompt to the loan and product named here.
	extra := data.JSONMap{
		"product_id":      la.ProductID,
		"loan_account_id": la.GetID(),
		"reference_id":    la.GetID(),
		"purpose":         "loan_collection",
	}
	if _, err = b.payments.InitiatePrompt(ctx, &paymentv1.InitiatePromptRequest{
		Id:     promptID,
		Source: &commonv1.ContactLink{ProfileId: profileID, ContactId: contactID},
		Amount: models.MinorUnitsToMoney(amount, la.CurrencyCode),
		Extra:  extra.ToProtoStruct(),
	}); err != nil {
		logger.WithError(err).WithField("loan_id", la.GetID()).Error("payment prompt could not be raised")
		return nil, fmt.Errorf("raise payment prompt: %w", err)
	}

	b.notifier.NotifyCollectionRequested(ctx, la, amount, contactID, promptID)

	logger.WithField("loan_id", la.GetID()).WithField("prompt_id", promptID).Info("collection prompt raised")

	return &loansv1.InitiateCollectionResponse{
		PaymentPromptId: promptID,
		Status:          collectionPromptStatus,
	}, nil
}

// collectionPromptID is the payment prompt id for one collection request:
// stable for a loan and idempotency key, and short enough for the payment
// service's ids.
func collectionPromptID(loanID, idempotencyKey string) string {
	sum := sha256.Sum256([]byte(loanID + ":" + idempotencyKey))
	return "col" + hex.EncodeToString(sum[:])[:collectionPromptIDHexLen]
}

// collectionPromptIDHexLen keeps prompt ids within 40 characters.
const collectionPromptIDHexLen = 32

// collectionAmount reads the amount to collect: collection_amount when set
// (it must be in the loan's currency), otherwise the deprecated bare decimal.
// Zero means "whatever is still owed".
func collectionAmount(req *loansv1.InitiateCollectionRequest, loanCurrency string) (int64, error) {
	if m := req.GetCollectionAmount(); m != nil {
		amount, currency := models.MoneyToMinorUnits(m)
		if currency != "" && !strings.EqualFold(currency, loanCurrency) {
			return 0, ErrRepaymentCurrencyMismatch
		}
		return amount, nil
	}
	legacy := strings.TrimSpace(req.GetAmount()) //nolint:staticcheck // legacy callers still send amount
	if legacy == "" {
		return 0, nil
	}
	amount, err := models.StringToMinorUnits(legacy, loanCurrency)
	if err != nil || amount < 0 {
		return 0, ErrRepaymentAmountInvalid
	}
	return amount, nil
}
