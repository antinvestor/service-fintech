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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// ErrSourceBalanceUnverifiable is returned when a funding source's real
// balance cannot be read. Allocation refuses to proceed on an unverified
// source: reporting a loan as funded against capital nobody has confirmed is
// worse than reporting that the loan could not be funded.
var ErrSourceBalanceUnverifiable = apperrors.NewError(
	apperrors.ServiceUnavailable, "a funding source balance could not be verified")

// SourceBalances reads the real, currently available balance of the
// non-investor funding sources.
type SourceBalances interface {
	// GroupSavings is what the group's members have actually saved, in minor
	// units of the requested currency.
	GroupSavings(ctx context.Context, groupID, currency string) (int64, error)

	// PlatformReserve is the balance of the platform first-loss reserve for
	// a product, in minor units of the requested currency.
	PlatformReserve(ctx context.Context, productType, currency string) (int64, error)
}

type platformSourceBalances struct {
	clients *clients.PlatformClients
}

// NewSourceBalances wires the balance reader onto the platform clients.
func NewSourceBalances(pc *clients.PlatformClients) SourceBalances {
	return &platformSourceBalances{clients: pc}
}

func (s *platformSourceBalances) GroupSavings(ctx context.Context, groupID, currency string) (int64, error) {
	if groupID == "" {
		return 0, fmt.Errorf("%w: group id is empty", ErrSourceBalanceUnverifiable)
	}
	if s.clients == nil || s.clients.LenderSavings == nil {
		return 0, fmt.Errorf("%w: savings service client is not configured", ErrSourceBalanceUnverifiable)
	}

	stream, err := s.clients.LenderSavings.SavingsAccountSearch(ctx,
		&savingsv1.SavingsAccountSearchRequest{
			OwnerId: groupID,
			Status:  savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_ACTIVE,
			Cursor:  &commonv1.PageCursor{Limit: maxPageLimit},
		})
	if err != nil {
		return 0, fmt.Errorf("%w: %w", ErrSourceBalanceUnverifiable, err)
	}
	defer func() { _ = stream.Close() }()

	var total int64
	for {
		msg, recvErr := stream.Receive()
		if recvErr != nil {
			if errors.Is(recvErr, io.EOF) {
				break
			}
			return 0, fmt.Errorf("%w: %w", ErrSourceBalanceUnverifiable, recvErr)
		}
		for _, account := range msg.GetData() {
			if account.GetCurrencyCode() != currency {
				continue
			}
			balance, balErr := s.clients.LenderSavings.SavingsBalanceGet(ctx,
				&savingsv1.SavingsBalanceGetRequest{SavingsAccountId: account.GetId()})
			if balErr != nil {
				return 0, fmt.Errorf("%w: %w", ErrSourceBalanceUnverifiable, balErr)
			}
			total += moneyx.ToSmallestUnit(balance.GetData().GetAvailableBalance(), moneyx.Decimals(currency))
		}
	}

	return total, nil
}

func (s *platformSourceBalances) PlatformReserve(ctx context.Context, productType, currency string) (int64, error) {
	if s.clients == nil || s.clients.LedgerClient == nil {
		return 0, fmt.Errorf("%w: ledger client is not configured", ErrSourceBalanceUnverifiable)
	}

	accountRef := constants.PlatformFirstLossAccount(productType)
	stream, err := s.clients.LedgerClient.SearchAccounts(ctx,
		&commonv1.SearchRequest{
			IdQuery: accountRef,
			Cursor:  &commonv1.PageCursor{Limit: 1},
		})
	if err != nil {
		return 0, fmt.Errorf("%w: %w", ErrSourceBalanceUnverifiable, err)
	}
	defer func() { _ = stream.Close() }()

	var balance *commonv1.Money
	for {
		msg, recvErr := stream.Receive()
		if recvErr != nil {
			if errors.Is(recvErr, io.EOF) {
				break
			}
			return 0, fmt.Errorf("%w: %w", ErrSourceBalanceUnverifiable, recvErr)
		}
		for _, account := range msg.GetData() {
			if account.GetId() == accountRef {
				balance = account.GetBalance()
			}
		}
	}

	if balance == nil {
		return 0, fmt.Errorf("%w: no ledger account %s", ErrSourceBalanceUnverifiable, accountRef)
	}
	if balance.GetCurrencyCode() != currency {
		return 0, fmt.Errorf("%w: reserve %s holds %s, not %s",
			ErrSourceBalanceUnverifiable, accountRef, balance.GetCurrencyCode(), currency)
	}
	return moneyx.ToSmallestUnit(balance, moneyx.Decimals(currency)), nil
}
