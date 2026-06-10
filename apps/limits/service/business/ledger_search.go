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

// Package business holds the limits service domain logic.
//
// ledger_search.go provides the LedgerSearchBusiness interface that
// streams committed ledger entries to admin/risk callers.
package business

import (
	"context"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// LedgerSearchBusiness streams committed ledger entries to admin/risk callers.
type LedgerSearchBusiness interface {
	Search(
		ctx context.Context,
		req *limitsv1.LedgerSearchRequest,
		batch func(ctx context.Context, items []*limitsv1.LedgerEntryObject) error,
	) error
}

type ledgerSearchBusiness struct {
	repo repository.LedgerRepository
}

// NewLedgerSearchBusiness wires the LedgerRepository into a business object.
func NewLedgerSearchBusiness(repo repository.LedgerRepository) LedgerSearchBusiness {
	return &ledgerSearchBusiness{repo: repo}
}

func (b *ledgerSearchBusiness) Search(
	ctx context.Context,
	req *limitsv1.LedgerSearchRequest,
	batch func(ctx context.Context, items []*limitsv1.LedgerEntryObject) error,
) error {
	const pageSize = 50
	cursor := ""
	if req.GetCursor() != nil {
		cursor = req.GetCursor().GetPage()
	}
	for {
		filter := repository.LedgerSearchFilter{
			SubjectID:    req.GetSubjectId(),
			CurrencyCode: req.GetCurrencyCode(),
		}
		if a, _ := models.ActionFromAPISafe(req.GetAction()); a != "" {
			filter.Action = a
		}
		if s, _ := models.SubjectFromAPISafe(req.GetSubjectType()); s != "" {
			filter.SubjectType = s
		}
		if t := req.GetFrom(); t != nil {
			filter.From = t.AsTime()
		}
		if t := req.GetTo(); t != nil {
			filter.To = t.AsTime()
		}
		out, err := b.repo.Search(ctx, filter, pageSize, cursor)
		if err != nil {
			return err
		}
		api := make([]*limitsv1.LedgerEntryObject, len(out.Items))
		for i, e := range out.Items {
			api[i] = e.ToAPI()
		}
		if batchErr := batch(ctx, api); batchErr != nil {
			return batchErr
		}
		if out.NextCursor == "" {
			return nil
		}
		cursor = out.NextCursor
	}
}
