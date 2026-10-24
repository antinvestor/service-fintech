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
	"strings"

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

// collectionPromptStatus is the state a freshly raised prompt is in: the
// borrower has been asked, and nothing has been collected yet. The repayment
// arrives later through RepaymentRecord, on its own idempotency key.
const collectionPromptStatus = "PENDING"

// CollectionBusiness asks a borrower to pay. It raises the prompt; it does not
// move money — the payment that answers a prompt lands as a repayment.
type CollectionBusiness interface {
	Initiate(ctx context.Context, req *loansv1.InitiateCollectionRequest) (*loansv1.InitiateCollectionResponse, error)
}

type collectionBusiness struct {
	loanAccountRepo repository.LoanAccountRepository
	loanBalanceRepo repository.LoanBalanceRepository
	notifier        *LoanNotifier
	scope           *ReadScope
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
	if req.GetPhoneNumber() == "" {
		return nil, ErrCollectionContactRequired
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

	amount, err := collectionAmount(req, la.CurrencyCode)
	if err != nil {
		return nil, err
	}
	if amount <= 0 {
		// An unspecified amount means "whatever is still owed", which is the
		// natural ask when a collections officer prompts a delinquent loan.
		balance, balErr := b.loanBalanceRepo.GetByLoanAccountID(ctx, la.GetID())
		if balErr != nil || balance == nil {
			return nil, ErrBalanceNotFound
		}
		amount = balance.TotalOutstanding
	}
	if amount <= 0 {
		return nil, ErrCollectionNothingOutstanding
	}

	// The prompt id is derived from the caller's idempotency key, so repeating
	// the request identifies the same prompt instead of raising a second one.
	promptID := "collection:" + la.GetID() + ":" + req.GetIdempotencyKey()

	b.notifier.NotifyCollectionRequested(ctx, la, amount, req.GetPhoneNumber(), promptID)

	logger.WithField("loan_id", la.GetID()).Info("collection prompt raised")

	return &loansv1.InitiateCollectionResponse{
		PaymentPromptId: promptID,
		Status:          collectionPromptStatus,
	}, nil
}

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
	return models.StringToMinorUnits(req.GetAmount()), nil //nolint:staticcheck // legacy callers still send amount
}
