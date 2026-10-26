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

package handlers

import (
	"context"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
)

// LoanWindowBusiness is the subset of loan window business used by workflow callbacks.
type LoanWindowBusiness interface {
	Evaluate(ctx context.Context, groupID string) (map[string]interface{}, error)
	Open(ctx context.Context, groupID string) (*models.LoanWindow, error)
}

// LoanOfferBusiness is the subset of loan offer business used by workflow callbacks.
type LoanOfferBusiness interface {
	CreateLoanAccount(ctx context.Context, offerID string) (map[string]interface{}, error)
	Respond(ctx context.Context, groupID, offerID string, response int32) error
}

// GroupObligationBusiness raises and closes a period's member obligations in
// operations.
type GroupObligationBusiness interface {
	Raise(ctx context.Context, groupID, periodID string) (map[string]interface{}, error)
	Close(ctx context.Context, groupID, periodID string) (map[string]interface{}, error)
}
