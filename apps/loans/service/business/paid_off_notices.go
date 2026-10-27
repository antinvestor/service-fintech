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

	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

// PaidOffNotices tells downstream products (seed) that a loan was paid off,
// and keeps telling them until they acknowledge it. A notice that did not get
// through would otherwise leave a borrower who repaid in full blocked from
// borrowing again; the paid-off notices job retries it.
type PaidOffNotices struct {
	loanAccountRepo repository.LoanAccountRepository
	loanBalanceRepo repository.LoanBalanceRepository
	hook            PaidOffHook
	subject         string
}

// NewPaidOffNotices wires the notices. A nil hook (no downstream product
// configured) makes every notice a no-op. subject is this service's own
// identity, under which each loan is noticed inside its partition.
func NewPaidOffNotices(
	loanAccountRepo repository.LoanAccountRepository,
	loanBalanceRepo repository.LoanBalanceRepository,
	hook PaidOffHook,
	subject string,
) *PaidOffNotices {
	return &PaidOffNotices{
		loanAccountRepo: loanAccountRepo,
		loanBalanceRepo: loanBalanceRepo,
		hook:            hook,
		subject:         subject,
	}
}

// Notify tells downstream products the loan was paid off and records their
// acknowledgement.
func (n *PaidOffNotices) Notify(ctx context.Context, la *models.LoanAccount, totalPaid int64) error {
	if n == nil || n.hook == nil {
		return nil
	}
	if err := n.hook.HandlePaidOff(ctx, la.GetID(), totalPaid); err != nil {
		return fmt.Errorf("paid-off notice for loan %s: %w", la.GetID(), err)
	}
	if err := n.loanAccountRepo.MarkPaidOffNoticed(ctx, la.GetID()); err != nil {
		// The notice landed; downstream handling is idempotent, so the job
		// sending it again is harmless.
		util.Log(ctx).WithError(err).WithField("loan_id", la.GetID()).
			Warn("paid-off notice acknowledged but not recorded")
	}
	return nil
}

// RunBatch notices up to batch paid-off loans whose notice never got
// through. A failure on one loan is logged and left for the next run.
func (n *PaidOffNotices) RunBatch(ctx context.Context, batch int) (int, bool, error) {
	if n == nil || n.hook == nil {
		return 0, false, nil
	}
	loans, err := n.loanAccountRepo.ClaimPaidOffUnnoticed(ctx, batch)
	if err != nil {
		return 0, false, fmt.Errorf("claim unnoticed paid-off loans: %w", err)
	}
	for _, la := range loans {
		loanCtx := n.actIn(ctx, la)
		var totalPaid int64
		balance, balErr := n.loanBalanceRepo.GetByLoanAccountID(loanCtx, la.GetID())
		if balErr == nil && balance != nil {
			totalPaid = balance.TotalPaid
		}
		if notifyErr := n.Notify(loanCtx, la, totalPaid); notifyErr != nil {
			util.Log(ctx).WithError(notifyErr).WithField("loan_id", la.GetID()).
				Warn("paid-off notice failed; next run retries")
		}
	}
	return len(loans), len(loans) == batch, nil
}

// actIn is ctx as this service acting inside the loan's partition.
func (n *PaidOffNotices) actIn(ctx context.Context, la *models.LoanAccount) context.Context {
	claims := &security.AuthenticationClaims{
		TenantID:    la.TenantID,
		PartitionID: la.PartitionID,
		Roles:       []string{security.ConstantSystemInternalRole},
	}
	claims.Subject = n.subject
	return claims.ClaimsToContext(ctx, security.WithoutInternalTenancySkip())
}
