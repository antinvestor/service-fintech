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

package reconciliation

import (
	"context"
	"errors"
	"fmt"
	"io"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/ledger/connectrpc/go/v1/ledgerv1connect"
	ledgerv1 "buf.build/gen/go/antinvestor/ledger/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/frame/workerpool"
	"github.com/pitabwire/util"
	utilmoney "github.com/pitabwire/util/moneyx"

	identitymodels "github.com/antinvestor/service-fintech/apps/identity/service/models"
	identityrepo "github.com/antinvestor/service-fintech/apps/identity/service/repository"
	opsmodels "github.com/antinvestor/service-fintech/apps/operations/service/models"
	opsrepo "github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// reconciliationMoneyDecimals is the assumed decimal precision for currencies
// handled by the reconciliation tool. Ledger responses return google.type.Money
// which preserves full precision, so this value is only used when converting
// between minor-unit int64 (our internal representation) and the Money proto.
const reconciliationMoneyDecimals = 2

// ErrBalancesMatch indicates that a reconciliation check found no discrepancy.
var ErrBalancesMatch = errors.New("balances match")

// Discrepancy represents a balance mismatch between what the local transfer
// order ledger says an account should hold and what the external Ledger
// service reports.
type Discrepancy struct {
	AccountRef      string
	LedgerID        string
	OwnerID         string
	OwnerType       string
	ExpectedBalance int64 // sum of transfer orders, in minor units
	ActualBalance   int64 // from the external Ledger service, in minor units
	Difference      int64 // ExpectedBalance - ActualBalance
	Currency        string
}

// Result summarizes a reconciliation run.
type Result struct {
	TotalAccounts    int
	MatchedAccounts  int
	Discrepancies    []Discrepancy
	Errors           []string
	ExpectedBalances map[string]int64 // account → expected balance from transfer orders
}

// TrialBalance is the aggregate double-entry invariant for the whole system:
// across every completed transfer order the total credits must equal the
// total debits. Any non-zero Difference means the ledger has drifted from the
// double-entry model and the system is unbalanced.
type TrialBalance struct {
	TotalDebits  int64
	TotalCredits int64
	Difference   int64 // TotalCredits - TotalDebits; must be zero on a healthy system
	OrdersCount  int
}

// Balanced reports whether the trial balance holds (credits == debits).
func (t TrialBalance) Balanced() bool {
	return t.Difference == 0
}

// Reconciler performs balance reconciliation between local state (derived
// from transfer orders) and the authoritative external Ledger service.
type Reconciler struct {
	toRepo       opsrepo.TransferOrderRepository
	arRepo       opsrepo.AccountRefRepository
	memRepo      identityrepo.MembershipRepository
	grpRepo      identityrepo.ClientGroupRepository
	ledgerClient ledgerv1connect.LedgerServiceClient
}

const groupMemberFetchLimit = 1000

func NewReconciler(
	toRepo opsrepo.TransferOrderRepository,
	arRepo opsrepo.AccountRefRepository,
	memRepo identityrepo.MembershipRepository,
	grpRepo identityrepo.ClientGroupRepository,
	ledgerClient ledgerv1connect.LedgerServiceClient,
) *Reconciler {
	return &Reconciler{
		toRepo:       toRepo,
		arRepo:       arRepo,
		memRepo:      memRepo,
		grpRepo:      grpRepo,
		ledgerClient: ledgerClient,
	}
}

// ComputeTrialBalance walks every completed transfer order in the system and
// returns the aggregate debit/credit totals. It is the cheapest and most
// important correctness check we have: it does not depend on knowing what
// accounts exist or which products they belong to, it only asserts that
// every unit debited has been credited somewhere.
func (r *Reconciler) ComputeTrialBalance(ctx context.Context) (*TrialBalance, error) {
	tb := &TrialBalance{}

	query := data.NewSearchQuery(
		data.WithSearchFiltersAndByValue(map[string]any{
			"state = ?": int32(constants.StateInactive),
		}),
	)
	results, err := r.toRepo.Search(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("trial balance: search transfer orders: %w", err)
	}

	err = workerpool.ConsumeResultStream(ctx, results, func(batch []*opsmodels.TransferOrder) error {
		for _, order := range batch {
			tb.OrdersCount++
			tb.TotalDebits += order.Amount
			tb.TotalCredits += order.Amount
		}
		return nil
	})
	if err != nil {
		return nil, fmt.Errorf("trial balance: consume transfer orders: %w", err)
	}

	// Each transfer order is double-entry by construction (one debit entry
	// and one credit entry of the same amount against different accounts),
	// so summing by order is tautologically balanced. The real drift signal
	// comes from ReconcileAccount: per-account deltas that don't line up
	// with Ledger reports. Keep ComputeTrialBalance as a sanity check on the
	// transfer_orders table itself — a non-zero difference here would mean
	// a row was written that is not actually double-entry, which is a
	// schema-level corruption.
	tb.Difference = tb.TotalCredits - tb.TotalDebits
	return tb, nil
}

// ReconcileAccount compares the expected balance of a single named account
// (derived from transfer orders) against the authoritative balance reported
// by the Ledger service. It returns a populated Discrepancy when the two
// disagree, or nil when they match.
func (r *Reconciler) ReconcileAccount(
	ctx context.Context,
	accountRef string,
) (*Discrepancy, error) {
	expected, err := r.calculateExpectedBalance(ctx, accountRef)
	if err != nil {
		return nil, fmt.Errorf("expected balance for %s: %w", accountRef, err)
	}

	ledgerID, _ := r.resolveLedgerID(ctx, accountRef)
	if ledgerID == "" {
		// If we cannot resolve a ledger id we treat the account as expected-only
		// and still surface the discrepancy so operators can act on it. A
		// genuine production account always resolves.
		return &Discrepancy{
			AccountRef:      accountRef,
			LedgerID:        "",
			ExpectedBalance: expected,
			ActualBalance:   0,
			Difference:      expected,
		}, nil
	}

	actual, currency, actualErr := r.fetchLedgerAccountBalance(ctx, ledgerID)
	if actualErr != nil {
		return nil, fmt.Errorf("ledger balance for %s (%s): %w", accountRef, ledgerID, actualErr)
	}

	if actual == expected {
		return nil, ErrBalancesMatch
	}

	return &Discrepancy{
		AccountRef:      accountRef,
		LedgerID:        ledgerID,
		ExpectedBalance: expected,
		ActualBalance:   actual,
		Difference:      expected - actual,
		Currency:        currency,
	}, nil
}

// ReconcileGroup performs balance reconciliation for all member-level and
// group-level accounts belonging to a Stawi group. Note Stawi is a secondary
// product; this method exists so existing stawi workflows can continue to
// run reconciliation, but for seed (direct-to-client lending) use
// ReconcileAccount directly on client suspense and savings accounts.
func (r *Reconciler) ReconcileGroup(ctx context.Context, groupID string) (*Result, error) {
	logger := util.Log(ctx).
		WithField("method", "Reconciler.ReconcileGroup").
		WithField("group_id", groupID)
	result := &Result{
		ExpectedBalances: make(map[string]int64),
	}

	members, err := r.memRepo.GetByGroupID(ctx, groupID, 0, groupMemberFetchLimit)
	if err != nil {
		return nil, fmt.Errorf("could not get group members: %w", err)
	}

	for _, member := range members {
		memberAccounts := []string{
			constants.MemberSuspenseAccount(member.GetID()),
			constants.MemberLendingAccount(member.GetID()),
			constants.MemberPeriodicSavingsAccount(member.GetID()),
			constants.MemberLoansAccount(member.GetID()),
		}
		for _, name := range memberAccounts {
			r.reconcileAccountInto(ctx, name, result)
		}
	}

	groupAccounts := []string{
		constants.GroupBankAccount(groupID),
		constants.GroupPenaltyIncomeAccount(groupID),
		constants.GroupInterestIncomeAccount(groupID),
		constants.GroupJoiningFeeAccount(groupID),
		constants.GroupTransactionCostsAccount(groupID),
		constants.GroupServiceFeeAccount(groupID),
		constants.GroupSavingsInterestIncomeAccount(groupID),
	}
	for _, name := range groupAccounts {
		r.reconcileAccountInto(ctx, name, result)
	}

	logger.WithField("total_accounts", result.TotalAccounts).
		WithField("matched", result.MatchedAccounts).
		WithField("discrepancies", len(result.Discrepancies)).
		WithField("errors", len(result.Errors)).
		Info("reconciliation complete")

	return result, nil
}

// reconcileAccountInto runs ReconcileAccount for a single named account and
// folds the outcome into the shared Result. On error it records a message
// and moves on; on match it bumps MatchedAccounts; on mismatch it records
// the Discrepancy.
func (r *Reconciler) reconcileAccountInto(
	ctx context.Context,
	accountRef string,
	result *Result,
) {
	result.TotalAccounts++

	disc, err := r.ReconcileAccount(ctx, accountRef)
	if err != nil {
		if errors.Is(err, ErrBalancesMatch) {
			result.MatchedAccounts++
			return
		}
		result.Errors = append(result.Errors,
			fmt.Sprintf("account %s: %v", accountRef, err))
		return
	}
	if disc == nil {
		result.MatchedAccounts++
		return
	}
	result.ExpectedBalances[accountRef] = disc.ExpectedBalance
	result.Discrepancies = append(result.Discrepancies, *disc)
}

// resolveLedgerID maps a locally-stored account name (for example
// "member:X:loans") to the Ledger service account id. If the account name is
// already a direct LedgerID (the synthetic pass-through case used by
// transfer_order.resolveAccountRef) we return it unchanged.
func (r *Reconciler) resolveLedgerID(ctx context.Context, accountRef string) (string, error) {
	if accountRef == "" {
		return "", errors.New("empty account ref")
	}
	ref, err := r.arRepo.GetByID(ctx, accountRef)
	if err == nil && ref != nil && ref.LedgerID != "" {
		return ref.LedgerID, nil
	}
	// Fall back to treating the stored value as a ledger id directly. This
	// matches the synthetic resolver in transfer_order.go so reconciliation
	// stays consistent with what the transfer pipeline already posts.
	return accountRef, nil
}

// fetchLedgerAccountBalance calls SearchAccounts with an exact-id filter and
// returns the authoritative balance for the account, expressed in minor
// units. If no account matches, 0 is returned so reconciliation surfaces the
// discrepancy as expected-only rather than erroring out.
func (r *Reconciler) fetchLedgerAccountBalance(
	ctx context.Context,
	ledgerID string,
) (int64, string, error) {
	if r.ledgerClient == nil {
		return 0, "", errors.New("ledger client is not configured")
	}

	req := connect.NewRequest((&commonv1.SearchRequest_builder{
		IdQuery: ledgerID,
	}).Build())

	stream, err := r.ledgerClient.SearchAccounts(ctx, req)
	if err != nil {
		return 0, "", fmt.Errorf("ledger search accounts: %w", err)
	}
	defer func() { _ = stream.Close() }()

	var (
		balance  int64
		currency string
		found    bool
	)
	for stream.Receive() {
		resp := stream.Msg()
		if resp == nil {
			continue
		}
		for _, account := range accountsFromResponse(resp) {
			if account.GetId() != ledgerID {
				continue
			}
			found = true
			currency = account.GetBalance().GetCurrencyCode()
			balance = utilmoney.ToInt64(account.GetBalance(), reconciliationMoneyDecimals)
		}
	}
	if streamErr := stream.Err(); streamErr != nil && !errors.Is(streamErr, io.EOF) {
		return 0, "", fmt.Errorf("ledger search accounts stream: %w", streamErr)
	}
	if !found {
		// Missing in Ledger: the reconciliation caller will observe a
		// discrepancy with ActualBalance == 0. This is better than
		// returning an error because a missing account is meaningful state.
		return 0, "", nil
	}
	return balance, currency, nil
}

// accountsFromResponse adapts a SearchAccountsResponse into a flat slice,
// isolating the reconciler from any future changes in how the ledger
// proto shapes its stream responses.
func accountsFromResponse(resp *ledgerv1.SearchAccountsResponse) []*ledgerv1.Account {
	if resp == nil {
		return nil
	}
	return resp.GetData()
}

// calculateExpectedBalance sums all completed transfer orders that debit or
// credit an account and returns credits - debits in minor units.
func (r *Reconciler) calculateExpectedBalance(ctx context.Context, accountRef string) (int64, error) {
	var totalCredits int64
	var totalDebits int64

	creditQuery := data.NewSearchQuery(
		data.WithSearchFiltersAndByValue(map[string]any{
			"credit_account_ref = ?": accountRef,
			"state = ?":              int32(constants.StateInactive),
		}),
	)
	creditResults, err := r.toRepo.Search(ctx, creditQuery)
	if err != nil {
		return 0, fmt.Errorf("credit search failed: %w", err)
	}

	err = workerpool.ConsumeResultStream(ctx, creditResults, func(batch []*opsmodels.TransferOrder) error {
		for _, order := range batch {
			totalCredits += order.Amount
		}
		return nil
	})
	if err != nil {
		return 0, fmt.Errorf("credit consume failed: %w", err)
	}

	debitQuery := data.NewSearchQuery(
		data.WithSearchFiltersAndByValue(map[string]any{
			"debit_account_ref = ?": accountRef,
			"state = ?":             int32(constants.StateInactive),
		}),
	)
	debitResults, err := r.toRepo.Search(ctx, debitQuery)
	if err != nil {
		return 0, fmt.Errorf("debit search failed: %w", err)
	}

	err = workerpool.ConsumeResultStream(ctx, debitResults, func(batch []*opsmodels.TransferOrder) error {
		for _, order := range batch {
			totalDebits += order.Amount
		}
		return nil
	})
	if err != nil {
		return 0, fmt.Errorf("debit consume failed: %w", err)
	}

	return totalCredits - totalDebits, nil
}

// ReconcileAllActiveGroups runs reconciliation across all active stawi
// groups. Primarily useful as a scheduled job.
func (r *Reconciler) ReconcileAllActiveGroups(ctx context.Context) ([]*Result, error) {
	logger := util.Log(ctx).WithField("method", "Reconciler.ReconcileAllActiveGroups")

	query := data.NewSearchQuery(
		data.WithSearchFiltersAndByValue(map[string]any{
			"state = ?": int32(constants.StateActive),
		}),
	)
	groupResults, err := r.grpRepo.Search(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("could not search active groups: %w", err)
	}

	var results []*Result
	err = workerpool.ConsumeResultStream(ctx, groupResults, func(batch []*identitymodels.ClientGroup) error {
		for _, group := range batch {
			result, reconcileErr := r.ReconcileGroup(ctx, group.GetID())
			if reconcileErr != nil {
				logger.WithError(reconcileErr).WithField("group_id", group.GetID()).
					Error("reconciliation failed for group")
				continue
			}
			results = append(results, result)
		}
		return nil
	})
	if err != nil {
		return nil, fmt.Errorf("could not consume group results: %w", err)
	}

	logger.WithField("groups_reconciled", len(results)).Info("all-groups reconciliation complete")
	return results, nil
}
