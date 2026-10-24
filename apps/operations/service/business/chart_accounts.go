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

	ledgerv1 "buf.build/gen/go/antinvestor/ledger/protocolbuffers/go/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/types/known/structpb"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// ledgerTypeOf maps a chart category onto the ledger service's type.
func ledgerTypeOf(category constants.LedgerCategory) ledgerv1.LedgerType {
	switch category {
	case constants.CategoryLiability:
		return ledgerv1.LedgerType_LIABILITY
	case constants.CategoryIncome:
		return ledgerv1.LedgerType_INCOME
	case constants.CategoryExpense:
		return ledgerv1.LedgerType_EXPENSE
	case constants.CategoryCapital:
		return ledgerv1.LedgerType_CAPITAL
	case constants.CategoryAsset:
		return ledgerv1.LedgerType_ASSET
	default:
		return ledgerv1.LedgerType_ASSET
	}
}

// ensureChartAccounts creates the platform-named ledger accounts of an order
// (and their chart ledgers) that the ledger does not hold yet. Accounts the
// order names through an account ref are the ledger's own and are left
// alone. Creation is best-effort and idempotent in effect: an account or
// ledger that already exists makes its create fail, and the caller's retry
// of the posting is what decides.
func (b *transferOrderBusiness) ensureChartAccounts(
	ctx context.Context,
	order *models.TransferOrder,
	refs ...*models.AccountRef,
) {
	for _, ref := range refs {
		if ref == nil || ref.Properties == nil || ref.Properties["synthetic"] != true {
			continue
		}
		b.ensureChartAccount(ctx, ref.LedgerID, order.Currency)
	}
}

func (b *transferOrderBusiness) ensureChartAccount(ctx context.Context, accountID, currency string) {
	logger := util.Log(ctx).WithField("account_id", accountID)
	ledgerID, known := constants.LedgerForAccount(accountID)
	if !known {
		// Only names the platform builds are created; anything else must
		// already exist in the ledger, so the retried posting fails.
		logger.Warn("account name is not on the chart; not creating it")
		return
	}
	meta, _ := structpb.NewStruct(map[string]any{"chart_account": true})
	create := func() error {
		_, err := b.clients.LedgerClient.CreateAccount(ctx, &ledgerv1.CreateAccountRequest{
			Id: accountID, LedgerId: ledgerID, Currency: currency, Data: meta,
		})
		return err
	}
	err := create()
	if err == nil {
		logger.Info("created chart account in the ledger")
		return
	}
	if connect.CodeOf(err) != connect.CodeNotFound {
		// Most often it already exists; the retried posting decides.
		return
	}
	// The chart ledger itself is missing: create it, then the account.
	category := constants.ChartLedgers()[ledgerID]
	ledgerMeta, _ := structpb.NewStruct(map[string]any{"chart_ledger": true})
	if _, ledgerErr := b.clients.LedgerClient.CreateLedger(ctx, &ledgerv1.CreateLedgerRequest{
		Id: ledgerID, Type: ledgerTypeOf(category), Data: ledgerMeta,
	}); ledgerErr != nil {
		logger.WithError(ledgerErr).WithField("ledger_id", ledgerID).Warn("could not create chart ledger")
	}
	if retryErr := create(); retryErr != nil {
		logger.WithError(retryErr).Warn("could not create chart account")
	}
}
