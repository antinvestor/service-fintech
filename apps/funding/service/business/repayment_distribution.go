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
	"encoding/json"
	"errors"
	"fmt"
	"math/big"
	"strings"

	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"
	"github.com/pitabwire/util/decimalx"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/apps/funding/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/calculation"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/transferorder"
)

var (
	// ErrRepaymentInvalid is returned for a repayment with no reference, a
	// negative amount or nothing to share.
	ErrRepaymentInvalid = apperrors.NewError(apperrors.BadRequest,
		"repayment needs a reference, a product and non-negative principal and interest")
	// ErrLoanNotFunded is returned when a repayment names a loan request
	// with no active funding behind it.
	ErrLoanNotFunded = apperrors.NewError(apperrors.Unprocessable,
		"the loan request has no active funding to share a repayment with")
)

// RepaymentApplication is one repayment to share out to a loan's funders.
type RepaymentApplication struct {
	Reference     string
	LoanRequestID string
	LoanAccountID string
	ProductID     string
	Currency      string
	Principal     int64
	Interest      int64
}

// RepaymentShare is one tranche's part of a repayment.
type RepaymentShare struct {
	TrancheID         string `json:"tranche_id"`
	SourceID          string `json:"source_id"`
	SourceType        int32  `json:"source_type"`
	TrancheLevel      int32  `json:"tranche_level"`
	InvestorAccountID string `json:"investor_account_id,omitempty"`
	Principal         int64  `json:"principal"`
	InterestGross     int64  `json:"interest_gross"`
	PlatformFee       int64  `json:"platform_fee"`
	WithholdingTax    int64  `json:"withholding_tax"`
	InterestNet       int64  `json:"interest_net"`
}

// RepaymentApplied is what a repayment came to.
type RepaymentApplied struct {
	Currency string
	Shares   []RepaymentShare
	// Settled is true once every ledger posting the shares need is done.
	Settled bool
}

// LedgerPosting is one double-entry movement funding asks operations to post.
type LedgerPosting struct {
	Reference   string
	Debit       string
	Credit      string
	Amount      int64
	Currency    string
	Type        int
	Description string
	Extra       data.JSONMap
}

// LedgerPoster posts a movement to the ledger, idempotently on its reference.
type LedgerPoster interface {
	Post(ctx context.Context, posting LedgerPosting) error
}

// OperationsPoster posts ledger movements as transfer orders through the
// operations service, keyed on the posting reference.
type OperationsPoster struct {
	Client operationsv1connect.OperationsServiceClient
}

// Post executes one transfer order. Operations converges a repeated
// reference on the order it already holds, so a retry never posts twice.
func (p OperationsPoster) Post(ctx context.Context, posting LedgerPosting) error {
	if p.Client == nil {
		return errors.New("operations client is not configured")
	}
	_, err := p.Client.TransferOrderExecute(ctx, &operationsv1.TransferOrderExecuteRequest{
		Data: transferorder.Typed(&operationsv1.TransferOrderObject{
			DebitAccountRef:  posting.Debit,
			CreditAccountRef: posting.Credit,
			Amount:           moneyx.FromMinorUnitsByCurrency(posting.Currency, posting.Amount),
			Reference:        posting.Reference,
			Description:      posting.Description,
			ExtraData:        posting.Extra.ToProtoStruct(),
		}, posting.Type),
	})
	if err != nil {
		return fmt.Errorf("transfer order %s: %w", posting.Reference, err)
	}
	return nil
}

// RepaymentDistributionBusiness shares loan repayments out to funders.
type RepaymentDistributionBusiness interface {
	Apply(ctx context.Context, app RepaymentApplication) (*RepaymentApplied, error)
}

type repaymentDistributionBusiness struct {
	distRepo      repository.RepaymentDistributionRepository
	lfRepo        repository.LoanFundingRepository
	ftRepo        repository.FundingTrancheRepository
	poster        LedgerPoster
	platformFeeBP int64
	taxBP         int64
}

// NewRepaymentDistributionBusiness builds the repayment sharing logic.
// platformFeeBP and taxBP are the platform's fee and the withholding tax on
// investors' interest, in basis points.
func NewRepaymentDistributionBusiness(
	distRepo repository.RepaymentDistributionRepository,
	lfRepo repository.LoanFundingRepository,
	ftRepo repository.FundingTrancheRepository,
	poster LedgerPoster,
	platformFeeBP, taxBP int64,
) RepaymentDistributionBusiness {
	return &repaymentDistributionBusiness{
		distRepo:      distRepo,
		lfRepo:        lfRepo,
		ftRepo:        ftRepo,
		poster:        poster,
		platformFeeBP: platformFeeBP,
		taxBP:         taxBP,
	}
}

// Apply records the repayment's shares and moves every tranche and investor
// counter in one transaction, then posts the interest legs to the ledger.
// A repeated call with the same reference moves nothing and only finishes
// postings an earlier call left undone.
func (b *repaymentDistributionBusiness) Apply(
	ctx context.Context,
	app RepaymentApplication,
) (*RepaymentApplied, error) {
	if strings.TrimSpace(app.Reference) == "" || app.ProductID == "" ||
		app.Principal < 0 || app.Interest < 0 || app.Principal+app.Interest == 0 {
		return nil, ErrRepaymentInvalid
	}

	if existing, err := b.distRepo.GetByReference(ctx, app.Reference); err == nil && existing != nil {
		return b.settle(ctx, existing)
	} else if err != nil && !data.ErrorIsNoRows(err) {
		return nil, fmt.Errorf("look up repayment distribution: %w", err)
	}

	sources, err := loadTrancheSources(ctx, b.lfRepo, b.ftRepo, app.LoanRequestID)
	if err != nil {
		return nil, err
	}
	if len(sources) == 0 {
		return nil, ErrLoanNotFunded
	}

	shares := computeRepaymentShares(sources, app.Principal, app.Interest, app.Currency, b.platformFeeBP, b.taxBP)
	dist := &models.RepaymentDistribution{
		Reference:     app.Reference,
		LoanRequestID: app.LoanRequestID,
		LoanAccountID: app.LoanAccountID,
		ProductID:     app.ProductID,
		Currency:      app.Currency,
		Principal:     app.Principal,
		Interest:      app.Interest,
		Shares:        encodeShares(shares),
	}
	dist.GenID(ctx)
	dist.CopyPartitionInfo(&sources[0].tranche.BaseModel)

	movements := make([]repository.TrancheMovement, 0, len(shares))
	for _, s := range shares {
		movements = append(movements, repository.TrancheMovement{
			TrancheID:         s.TrancheID,
			InvestorAccountID: s.InvestorAccountID,
			Principal:         s.Principal,
			InterestGross:     s.InterestGross,
			InterestNet:       s.InterestNet,
		})
	}

	row, _, err := b.distRepo.Apply(ctx, dist, movements)
	if err != nil {
		return nil, fmt.Errorf("apply repayment distribution: %w", err)
	}
	return b.settle(ctx, row)
}

// settle posts the ledger legs of a recorded distribution and marks it
// settled once all of them went through. Each posting is keyed on the
// distribution and tranche, so posting twice converges on one movement.
func (b *repaymentDistributionBusiness) settle(
	ctx context.Context,
	dist *models.RepaymentDistribution,
) (*RepaymentApplied, error) {
	shares, err := decodeShares(dist.Shares)
	if err != nil {
		return nil, fmt.Errorf("read distribution %s: %w", dist.GetID(), err)
	}
	result := &RepaymentApplied{Currency: dist.Currency, Shares: shares, Settled: dist.SettledAt != nil}
	if result.Settled {
		return result, nil
	}

	logger := util.Log(ctx).WithField("repayment_reference", dist.Reference)
	for _, posting := range repaymentPostings(dist, shares) {
		if postErr := b.poster.Post(ctx, posting); postErr != nil {
			logger.WithError(postErr).WithField("posting_reference", posting.Reference).
				Warn("repayment share not yet posted; a later call finishes it")
			return result, nil
		}
	}
	if markErr := b.distRepo.MarkSettled(ctx, dist.GetID()); markErr != nil {
		logger.WithError(markErr).Warn("repayment shares posted but not marked settled; a later call marks it")
		return result, nil
	}
	result.Settled = true
	return result, nil
}

// repaymentPostings are the ledger legs a distribution needs. Principal
// needs none: a funder's capital claim did not shrink when the loan went out,
// so it does not grow when it comes back; the tranche counters record it.
// Interest arrived as the platform's income; each funder's part moves out of
// it. The platform fee is income the platform keeps, so it never moves, and
// the platform reserve's own part stays where it is.
func repaymentPostings(dist *models.RepaymentDistribution, shares []RepaymentShare) []LedgerPosting {
	income := constants.PlatformIncomeAccount(dist.ProductID)
	extra := func(s RepaymentShare) data.JSONMap {
		return data.JSONMap{
			fieldLoanRequestID:     dist.LoanRequestID,
			"loan_account_id":      dist.LoanAccountID,
			fieldTrancheID:         s.TrancheID,
			fieldInvestorAccountID: s.InvestorAccountID,
		}
	}
	var postings []LedgerPosting
	for _, s := range shares {
		base := fmt.Sprintf("fund-dist:%s:%s", dist.GetID(), s.TrancheID)
		switch models.FundingSource(s.SourceType) {
		case models.FundingSourceInvestorAffiliated, models.FundingSourceInvestorGeneral:
			if s.InterestNet > 0 {
				postings = append(postings, LedgerPosting{
					Reference: base + ":net", Debit: income,
					Credit: constants.InvestorCapitalAccount(s.InvestorAccountID),
					Amount: s.InterestNet, Currency: dist.Currency,
					Type:        constants.TransferTypeInvestorIncomeDistribution,
					Description: "Investor interest share", Extra: extra(s),
				})
			}
			if s.WithholdingTax > 0 {
				postings = append(postings, LedgerPosting{
					Reference: base + ":wht", Debit: income,
					Credit: constants.PlatformWithholdingTaxPayableAccount(dist.ProductID),
					Amount: s.WithholdingTax, Currency: dist.Currency,
					Type:        constants.TransferTypeCost,
					Description: "Withholding tax on investor interest", Extra: extra(s),
				})
			}
		case models.FundingSourceGroupSavings, models.FundingSourceGroupIncome:
			if s.InterestNet > 0 {
				postings = append(postings, LedgerPosting{
					Reference: base + ":net", Debit: income,
					Credit: constants.GroupInterestIncomeAccount(s.SourceID),
					Amount: s.InterestNet, Currency: dist.Currency,
					Type:        constants.TransferTypeLoanInterestIncomeDistribution,
					Description: "Group interest share", Extra: extra(s),
				})
			}
		case models.FundingSourcePlatformReserve, models.FundingSourceUnspecified:
		}
	}
	return postings
}

// trancheSource is an active tranche with the funding record behind it.
type trancheSource struct {
	tranche *models.FundingTranche
	funding *models.LoanFunding
}

// loadTrancheSources returns the loan request's active tranches in priority
// order, each with its funding record.
func loadTrancheSources(
	ctx context.Context,
	lfRepo repository.LoanFundingRepository,
	ftRepo repository.FundingTrancheRepository,
	loanRequestID string,
) ([]trancheSource, error) {
	fundings, err := lfRepo.GetByLoanRequestID(ctx, loanRequestID)
	if err != nil {
		return nil, fmt.Errorf("load loan fundings: %w", err)
	}
	byID := make(map[string]*models.LoanFunding, len(fundings))
	for _, f := range fundings {
		if f.State == int32(constants.StateActive) {
			byID[f.GetID()] = f
		}
	}
	tranches, err := ftRepo.GetByLoanRequestID(ctx, loanRequestID)
	if err != nil {
		return nil, fmt.Errorf("load funding tranches: %w", err)
	}
	sources := make([]trancheSource, 0, len(tranches))
	for _, t := range tranches {
		f, ok := byID[t.LoanFundingID]
		if !ok || t.State != int32(constants.StateActive) || t.Amount <= 0 {
			continue
		}
		sources = append(sources, trancheSource{tranche: t, funding: f})
	}
	return sources, nil
}

// computeRepaymentShares splits principal and interest across the tranches
// in proportion to what each put in. The last tranche takes the rounding
// remainder so the shares always add up to the repayment. Investors' interest
// carries the platform fee and withholding tax; groups and the platform
// reserve take their interest whole.
func computeRepaymentShares(
	sources []trancheSource,
	principal, interest int64,
	currency string,
	platformFeeBP, taxBP int64,
) []RepaymentShare {
	var total int64
	for _, s := range sources {
		total += s.tranche.Amount
	}
	shares := make([]RepaymentShare, 0, len(sources))
	var givenPrincipal, givenInterest int64
	for i, s := range sources {
		p := proportionOf(principal, s.tranche.Amount, total)
		in := proportionOf(interest, s.tranche.Amount, total)
		if i == len(sources)-1 {
			p = principal - givenPrincipal
			in = interest - givenInterest
		}
		givenPrincipal += p
		givenInterest += in

		share := RepaymentShare{
			TrancheID:         s.tranche.GetID(),
			SourceID:          s.funding.OwnerID,
			SourceType:        s.funding.FundingType,
			TrancheLevel:      s.tranche.TrancheLevel,
			InvestorAccountID: s.tranche.InvestorAccountID,
			Principal:         p,
			InterestGross:     in,
			InterestNet:       in,
		}
		switch models.FundingSource(s.funding.FundingType) {
		case models.FundingSourceInvestorAffiliated, models.FundingSourceInvestorGeneral:
			fee, tax := interestDeductions(in, currency, platformFeeBP, taxBP)
			share.PlatformFee = fee
			share.WithholdingTax = tax
			share.InterestNet = in - fee - tax
		case models.FundingSourceGroupSavings, models.FundingSourceGroupIncome,
			models.FundingSourcePlatformReserve, models.FundingSourceUnspecified:
		}
		shares = append(shares, share)
	}
	return shares
}

// proportionOf returns amount * part / total, rounded down, without
// overflowing on large minor-unit amounts.
func proportionOf(amount, part, total int64) int64 {
	if amount <= 0 || part <= 0 || total <= 0 {
		return 0
	}
	v := new(big.Int).Mul(big.NewInt(amount), big.NewInt(part))
	v.Quo(v, big.NewInt(total))
	return v.Int64()
}

func encodeShares(shares []RepaymentShare) data.JSONMap {
	raw, _ := json.Marshal(shares)
	var list []any
	_ = json.Unmarshal(raw, &list)
	return data.JSONMap{"shares": list}
}

func decodeShares(m data.JSONMap) ([]RepaymentShare, error) {
	if m == nil {
		return nil, nil
	}
	raw, err := json.Marshal(m["shares"])
	if err != nil {
		return nil, err
	}
	var shares []RepaymentShare
	if err = json.Unmarshal(raw, &shares); err != nil {
		return nil, err
	}
	return shares, nil
}

// interestDeductions splits the platform fee and withholding tax off an
// investor's interest share, in the currency's own minor units. Fee and tax
// never exceed the share.
func interestDeductions(share int64, currency string, platformFeeBP, taxBP int64) (int64, int64) {
	if share <= 0 {
		return 0, 0
	}
	decimals := moneyx.Decimals(currency)
	dist := calculation.CalculateInterestDistribution(decimalx.FromMinorUnits(share, decimals), platformFeeBP, taxBP)
	fee := min(max(dist.PlatformFee.ToMinorUnits(decimals), 0), share)
	tax := min(max(dist.WithholdingTax.ToMinorUnits(decimals), 0), share-fee)
	return fee, tax
}
