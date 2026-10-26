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
	"fmt"
	"sort"
	"strings"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/security"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/apps/funding/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

const (
	// maxStatementPeriod bounds how much one statement reads.
	maxStatementPeriod = 366 * 24 * time.Hour
	// maxStatementRows bounds each kind of record one statement reads.
	maxStatementRows = 2000
)

var (
	// ErrStatementPeriodInvalid is returned for a period that is not a
	// forward span of at most 366 days.
	ErrStatementPeriodInvalid = apperrors.NewError(apperrors.BadRequest,
		"a statement period runs forward from 'from' to 'to' and spans at most 366 days")
	// ErrInvestorAccountNotVisible hides an account the caller may not read
	// behind the same answer as one that does not exist.
	ErrInvestorAccountNotVisible = apperrors.ErrDataNotFound.Extend("investor account")
	// ErrInvestorSearchNeedsOwnInvestor is returned when an investor lists
	// accounts without naming themselves.
	ErrInvestorSearchNeedsOwnInvestor = apperrors.NewError(apperrors.Forbidden,
		"an investor lists only their own accounts")
	// ErrInvestorOwnerUnverifiable is returned when the account's owner
	// cannot be looked up; the caller retries.
	ErrInvestorOwnerUnverifiable = apperrors.NewError(apperrors.ServiceUnavailable,
		"the account's owner cannot be checked; retry")
)

// InvestorOwnerResolver names the profile an investor signs in with.
type InvestorOwnerResolver interface {
	InvestorProfileID(ctx context.Context, investorID string) (string, error)
}

type identityInvestorOwners struct {
	identity identityv1connect.IdentityServiceClient
}

// NewIdentityInvestorOwners reads an investor's profile from identity.
func NewIdentityInvestorOwners(identity identityv1connect.IdentityServiceClient) InvestorOwnerResolver {
	if identity == nil {
		return nil
	}
	return &identityInvestorOwners{identity: identity}
}

func (r *identityInvestorOwners) InvestorProfileID(ctx context.Context, investorID string) (string, error) {
	resp, err := r.identity.InvestorGet(ctx, &identityv1.InvestorGetRequest{Id: investorID})
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(resp.GetData().GetProfileId()), nil
}

// staffRoles are the roles that read every investor account in a partition.
func staffRoles() []string { return []string{"owner", "admin", "operator", "viewer"} }

// callerIsStaff reports whether the caller acts for the lender: a staff role
// or a service principal. Anyone else is an investor reading their own, and
// a call without claims is nobody's.
func callerIsStaff(ctx context.Context) bool {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return false
	}
	if claims.IsInternalSystem() {
		return true
	}
	for _, role := range claims.GetRoles() {
		for _, staff := range staffRoles() {
			if strings.EqualFold(role, staff) {
				return true
			}
		}
	}
	return false
}

// InvestorReads decides which investor accounts a caller may read and
// builds their statements. Staff read every account in the partition; an
// investor reads only the accounts of the investor record their own profile
// holds.
type InvestorReads struct {
	accounts   repository.InvestorAccountRepository
	statements repository.StatementRepository
	owners     InvestorOwnerResolver
}

// NewInvestorReads wires investor reads.
func NewInvestorReads(
	accounts repository.InvestorAccountRepository,
	statements repository.StatementRepository,
	owners InvestorOwnerResolver,
) *InvestorReads {
	return &InvestorReads{accounts: accounts, statements: statements, owners: owners}
}

// CheckInvestor reports whether the caller may read the investor's accounts.
func (r *InvestorReads) CheckInvestor(ctx context.Context, investorID string) error {
	if callerIsStaff(ctx) {
		return nil
	}
	claims := security.ClaimsFromContext(ctx)
	profileID := strings.TrimSpace(claims.GetProfileID())
	if profileID == "" || investorID == "" || r == nil || r.owners == nil {
		return ErrInvestorAccountNotVisible
	}
	owner, err := r.owners.InvestorProfileID(ctx, investorID)
	if err != nil {
		if connect.CodeOf(err) == connect.CodeNotFound {
			return ErrInvestorAccountNotVisible
		}
		return fmt.Errorf("%w: %s", ErrInvestorOwnerUnverifiable, err.Error())
	}
	if owner != profileID {
		return ErrInvestorAccountNotVisible
	}
	return nil
}

// CheckSearch decides whether the caller may list accounts with this
// investor filter: staff list any, an investor only their own.
func (r *InvestorReads) CheckSearch(ctx context.Context, investorID string) error {
	if callerIsStaff(ctx) {
		return nil
	}
	if investorID == "" {
		return ErrInvestorSearchNeedsOwnInvestor
	}
	return r.CheckInvestor(ctx, investorID)
}

// StatementResult is a statement before it is rendered.
type StatementResult struct {
	Account   *models.InvestorAccount
	From, To  time.Time
	Entries   []*fundingv1.InvestorStatementEntry
	Totals    *fundingv1.InvestorStatementTotals
	Truncated bool
}

// Statement reports what moved the account's capital over the period.
func (r *InvestorReads) Statement(
	ctx context.Context,
	req *fundingv1.InvestorStatementRequest,
) (*StatementResult, error) {
	from, to, err := statementPeriod(req.GetFrom(), req.GetTo(), time.Now().UTC())
	if err != nil {
		return nil, err
	}
	account, err := r.accounts.GetByID(ctx, req.GetInvestorAccountId())
	if err != nil {
		return nil, ErrInvestorAccountNotVisible
	}
	if checkErr := r.CheckInvestor(ctx, account.InvestorID); checkErr != nil {
		return nil, checkErr
	}

	w := repository.StatementWindow{
		InvestorAccountID: account.GetID(), From: from, To: to, Limit: maxStatementRows + 1,
	}
	b := &statementBuilder{account: account.GetID(), currency: account.Currency}
	if err = b.read(ctx, r.statements, w); err != nil {
		return nil, fmt.Errorf("read statement: %w", err)
	}
	sort.SliceStable(b.entries, func(i, j int) bool {
		return b.entries[i].GetOccurredAt() < b.entries[j].GetOccurredAt()
	})
	return &StatementResult{
		Account:   account,
		From:      from,
		To:        to,
		Entries:   b.entries,
		Totals:    b.totals(),
		Truncated: b.truncated,
	}, nil
}

// statementPeriod parses a period, defaulting to to now.
func statementPeriod(fromRaw, toRaw string, now time.Time) (time.Time, time.Time, error) {
	from, err := time.Parse(time.RFC3339, fromRaw)
	if err != nil {
		return time.Time{}, time.Time{}, ErrStatementPeriodInvalid
	}
	to := now
	if toRaw != "" {
		if to, err = time.Parse(time.RFC3339, toRaw); err != nil {
			return time.Time{}, time.Time{}, ErrStatementPeriodInvalid
		}
	}
	if !to.After(from) || to.Sub(from) > maxStatementPeriod {
		return time.Time{}, time.Time{}, ErrStatementPeriodInvalid
	}
	return from.UTC(), to.UTC(), nil
}

// statementBuilder turns the records of a period into entries for one
// account, keeping running totals in minor units.
type statementBuilder struct {
	account   string
	currency  string
	entries   []*fundingv1.InvestorStatementEntry
	sums      map[fundingv1.InvestorStatementEntryType]int64
	fees, tax int64
	truncated bool
}

func (b *statementBuilder) read(
	ctx context.Context,
	repo repository.StatementRepository,
	w repository.StatementWindow,
) error {
	movements, err := repo.Movements(ctx, w)
	if err != nil {
		return err
	}
	b.noteTruncation(len(movements))
	for _, m := range capRows(movements) {
		b.addMovement(m)
	}

	tranches, err := repo.Tranches(ctx, w)
	if err != nil {
		return err
	}
	b.noteTruncation(len(tranches))
	for _, t := range capRows(tranches) {
		b.addTranche(t, w)
	}

	distributions, err := repo.Distributions(ctx, w)
	if err != nil {
		return err
	}
	b.noteTruncation(len(distributions))
	for _, d := range capRows(distributions) {
		if addErr := b.addDistribution(d); addErr != nil {
			return addErr
		}
	}

	losses, err := repo.Losses(ctx, w)
	if err != nil {
		return err
	}
	b.noteTruncation(len(losses))
	for _, l := range capRows(losses) {
		if addErr := b.addShares(l.Properties, l.CreatedAt, l.LoanRequestID, l.Reference,
			fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_LOSS); addErr != nil {
			return addErr
		}
	}

	recoveries, err := repo.Recoveries(ctx, w)
	if err != nil {
		return err
	}
	b.noteTruncation(len(recoveries))
	for _, rc := range capRows(recoveries) {
		if addErr := b.addShares(rc.Properties, rc.CreatedAt, rc.LoanRequestID, rc.Reference,
			fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_RECOVERY); addErr != nil {
			return addErr
		}
	}
	return nil
}

func (b *statementBuilder) noteTruncation(n int) {
	if n > maxStatementRows {
		b.truncated = true
	}
}

func capRows[T any](rows []T) []T {
	if len(rows) > maxStatementRows {
		return rows[:maxStatementRows]
	}
	return rows
}

func (b *statementBuilder) add(
	at time.Time,
	kind fundingv1.InvestorStatementEntryType,
	amount int64,
	loanRequestID, reference string,
) *fundingv1.InvestorStatementEntry {
	if b.sums == nil {
		b.sums = map[fundingv1.InvestorStatementEntryType]int64{}
	}
	b.sums[kind] += amount
	e := &fundingv1.InvestorStatementEntry{
		OccurredAt:    at.UTC().Format(time.RFC3339),
		Type:          kind,
		Amount:        b.money(amount),
		LoanRequestId: loanRequestID,
		Reference:     reference,
	}
	b.entries = append(b.entries, e)
	return e
}

func (b *statementBuilder) addMovement(m *models.InvestorCapitalMovement) {
	kind := fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_DEPOSIT
	if models.CapitalMovementDirection(m.Direction) == models.CapitalMovementWithdraw {
		kind = fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_WITHDRAWAL
	}
	e := b.add(m.CreatedAt, kind, m.Amount, "", m.GetID())
	e.Pending = m.Status == models.CapitalMovementDebited
}

func (b *statementBuilder) addTranche(t *repository.StatementTranche, w repository.StatementWindow) {
	if !t.CreatedAt.Before(w.From) && t.CreatedAt.Before(w.To) {
		b.add(t.CreatedAt, fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_DEPLOYMENT,
			t.Amount, t.LoanRequestID, t.GetID())
	}
	if t.State == int32(constants.StateInactive) && !t.ModifiedAt.Before(w.From) && t.ModifiedAt.Before(w.To) {
		b.add(t.ModifiedAt, fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_RELEASE,
			t.Amount, t.LoanRequestID, t.GetID())
	}
}

func (b *statementBuilder) addDistribution(d *models.RepaymentDistribution) error {
	shares, err := decodeShares(d.Shares)
	if err != nil {
		return fmt.Errorf("read distribution %s: %w", d.GetID(), err)
	}
	for _, s := range shares {
		if s.InvestorAccountID != b.account {
			continue
		}
		if s.Principal > 0 {
			b.add(d.CreatedAt, fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_PRINCIPAL_RETURNED,
				s.Principal, d.LoanRequestID, d.Reference)
		}
		if s.InterestGross > 0 {
			e := b.add(d.CreatedAt, fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_INTEREST_EARNED,
				s.InterestNet, d.LoanRequestID, d.Reference)
			e.InterestGross = b.money(s.InterestGross)
			e.PlatformFee = b.money(s.PlatformFee)
			e.WithholdingTax = b.money(s.WithholdingTax)
			b.fees += s.PlatformFee
			b.tax += s.WithholdingTax
		}
	}
	return nil
}

func (b *statementBuilder) addShares(
	properties map[string]any,
	at time.Time,
	loanRequestID, reference string,
	kind fundingv1.InvestorStatementEntryType,
) error {
	shares, err := decodeShares(properties)
	if err != nil {
		return fmt.Errorf("read %s %s: %w", kind, reference, err)
	}
	for _, s := range shares {
		if s.InvestorAccountID == b.account && s.Principal > 0 {
			b.add(at, kind, s.Principal, loanRequestID, reference)
		}
	}
	return nil
}

func (b *statementBuilder) money(minor int64) *commonv1.Money {
	return moneyx.FromMinorUnitsByCurrency(b.currency, minor)
}

func (b *statementBuilder) totals() *fundingv1.InvestorStatementTotals {
	sum := func(k fundingv1.InvestorStatementEntryType) *commonv1.Money { return b.money(b.sums[k]) }
	return &fundingv1.InvestorStatementTotals{
		Deposits:          sum(fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_DEPOSIT),
		Withdrawals:       sum(fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_WITHDRAWAL),
		Deployed:          sum(fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_DEPLOYMENT),
		Released:          sum(fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_RELEASE),
		PrincipalReturned: sum(fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_PRINCIPAL_RETURNED),
		InterestEarned:    sum(fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_INTEREST_EARNED),
		PlatformFees:      b.money(b.fees),
		WithholdingTax:    b.money(b.tax),
		Losses:            sum(fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_LOSS),
		Recoveries:        sum(fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_RECOVERY),
	}
}
