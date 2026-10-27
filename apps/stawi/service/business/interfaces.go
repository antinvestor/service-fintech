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
	"time"

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
)

// ClientGroupBusiness handles customer group lifecycle operations.
type ClientGroupBusiness interface {
	Create(ctx context.Context, group *identityv1.ClientGroupObject) (*identityv1.ClientGroupObject, error)
	Get(ctx context.Context, id string) (*identityv1.ClientGroupObject, error)
	SetupLedgerAccounts(ctx context.Context, groupID string) error
	RegisterWithLender(ctx context.Context, groupID string) error
}

// MembershipBusiness handles group membership operations.
type MembershipBusiness interface {
	Create(ctx context.Context, membership *identityv1.MembershipObject) (*identityv1.MembershipObject, error)
	Get(ctx context.Context, id string) (*identityv1.MembershipObject, error)
	GetByGroupID(ctx context.Context, groupID string) ([]*identityv1.MembershipObject, error)
	UpdateRole(ctx context.Context, membershipID string, role int32) error
	CheckPeriodicPayment(ctx context.Context, membershipID string) (map[string]interface{}, error)
}

// TenureBusiness handles tenure lifecycle operations.
type TenureBusiness interface {
	Open(ctx context.Context, groupID string) (*models.Tenure, error)
	Close(ctx context.Context, tenureID string) error
	GetActive(ctx context.Context, groupID string) (*models.Tenure, error)
}

// PeriodBusiness handles period lifecycle operations.
type PeriodBusiness interface {
	Open(ctx context.Context, groupID string) (*models.Period, error)
	OpenNext(ctx context.Context, previous *models.Period) (*models.Period, error)
	Close(ctx context.Context, periodID string) error
	Freeze(ctx context.Context, periodID string) (*models.Period, error)
	Extend(ctx context.Context, periodID, reason string) (*models.Period, error)
	GetCurrent(ctx context.Context, groupID string) (*models.Period, error)
}

// MotionBusiness handles group voting/decision operations.
type MotionBusiness interface {
	Create(ctx context.Context, motion *models.Motion) (*models.Motion, error)
	Vote(ctx context.Context, motionID, membershipID string, choice int32) error
}

// LoanWindowBusiness handles loan window operations.
type LoanWindowBusiness interface {
	Evaluate(ctx context.Context, groupID string) (map[string]interface{}, error)
	Open(ctx context.Context, groupID string) (*models.LoanWindow, error)
}

// OfferGenerator makes a loan window's offers.
type OfferGenerator interface {
	GenerateForWindow(ctx context.Context, group *identityv1.ClientGroupObject, window *models.LoanWindow) (int, error)
}

// LoanOfferBusiness handles loan offers: making them when a window opens,
// members' answers, and originating accepted ones through the loans service.
type LoanOfferBusiness interface {
	OfferGenerator
	Respond(ctx context.Context, groupID, offerID string, response int32) (*models.LoanOffer, error)
	CreateLoanAccount(ctx context.Context, groupID, offerID string) (map[string]any, error)
	// ResumePendingOrigination, ExpireStale and RetryLoanCancels are
	// bounded, idempotent sweeps for a scheduled job. Each lists offers
	// across tenants and works on each inside its own partition (act).
	ResumePendingOrigination(ctx context.Context, batch int, act PartitionActor) (OriginationSweep, error)
	ExpireStale(ctx context.Context, now time.Time, batch int, act PartitionActor) (int, error)
	RetryLoanCancels(ctx context.Context, now time.Time, batch int, act PartitionActor) (CancelSweep, error)
}

// GroupObligationBusiness raises and closes a period's member obligations,
// which operations owns.
type GroupObligationBusiness interface {
	Raise(ctx context.Context, groupID, periodID string) (map[string]any, error)
	Close(ctx context.Context, groupID, periodID string) (map[string]any, error)
}
