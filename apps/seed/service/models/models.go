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

// Package models defines the seed product data model. Seed is the
// direct-to-client lending product: a client with verified KYC and
// identity can request a loan at any time, receives it up to a limit
// derived from their credit profile, and unlocks higher limits by
// successfully repaying.
//
// The data model captures three things:
//
//  1. CreditProfile   — per-client credit state (tier, limit, counters).
//     One row per (client, currency) pair.
//
//  2. CreditTierConfig — the platform-wide ladder of tiers: each tier has
//     a minimum number of successful repayments required to enter it and
//     a maximum loan amount a client in that tier can borrow. This is
//     stored (not hard-coded) so credit policy can be tuned without a
//     code release.
//
//  3. LoanRequest     — a customer-initiated loan request. This is the
//     seed product's own record of "the customer asked for X"; the
//     downstream loan request and loan account in the loans service
//     are linked back to it via loan_request_id and loan_account_id.
package models

import (
	"time"

	"github.com/pitabwire/frame/v2/data"
)

// CreditProfileStatus is the lifecycle of a client credit profile.
type CreditProfileStatus int32

const (
	// CreditProfileStatusUnspecified is the zero value (uninitialised).
	CreditProfileStatusUnspecified CreditProfileStatus = 0
	// CreditProfileStatusActive is the normal operating state: the client
	// can request loans up to their current limit.
	CreditProfileStatusActive CreditProfileStatus = 1
	// CreditProfileStatusSuspended temporarily disables new borrowing
	// (e.g. KYC re-verification required, fraud investigation) but
	// retains the existing tier and counters.
	CreditProfileStatusSuspended CreditProfileStatus = 2
	// CreditProfileStatusBlocked hard-stops any new borrowing. Tier and
	// counters are retained so reinstatement is possible without loss
	// of reputation, but the client cannot borrow until moved back to
	// Active by an operator.
	CreditProfileStatusBlocked CreditProfileStatus = 3
)

// LoanRequestStatus is the lifecycle of a customer-initiated loan request.
type LoanRequestStatus int32

const (
	LoanRequestStatusUnspecified LoanRequestStatus = 0
	// LoanRequestStatusSubmitted means the seed service has accepted the
	// request and started the eligibility pipeline.
	LoanRequestStatusSubmitted LoanRequestStatus = 1
	// LoanRequestStatusEligibilityFailed means KYC or credit limit
	// rejected the request before any downstream action. The reason is
	// captured on the row and in the audit stream.
	LoanRequestStatusEligibilityFailed LoanRequestStatus = 2
	// LoanRequestStatusApproved means eligibility passed and seed has
	// begun creating the application and loan account downstream.
	LoanRequestStatusApproved LoanRequestStatus = 3
	// LoanRequestStatusDisbursed means the downstream disbursement
	// completed and the money has left the platform.
	LoanRequestStatusDisbursed LoanRequestStatus = 4
	// LoanRequestStatusFailed means the downstream pipeline errored
	// after eligibility had passed. The row is preserved for retry
	// and operator review.
	LoanRequestStatusFailed LoanRequestStatus = 5
	// LoanRequestStatusCancelled is an operator-initiated cancel path.
	LoanRequestStatusCancelled LoanRequestStatus = 6
)

// CreditProfile is the authoritative per-client credit state for seed.
// The (ClientID, CurrencyCode) pair is unique: a client borrowing in
// KES and USD has two independent profiles.
type CreditProfile struct {
	data.BaseModel

	ClientID     string `gorm:"type:varchar(50);index:idx_cp_client;uniqueIndex:uq_cp_client_currency"`
	CurrencyCode string `gorm:"type:varchar(3);uniqueIndex:uq_cp_client_currency"`

	// ProductID points to the seed loan product that governs this profile
	// (interest rate, term, fees). Kept on the profile so later tier
	// evaluation can reference product-level ladder overrides.
	ProductID string `gorm:"type:varchar(50);index:idx_cp_product"`

	Status int32 `gorm:"index:idx_cp_status"` // CreditProfileStatus

	// Tier tracks the current credit tier level (1-based). Corresponds to
	// the sequence on CreditTierConfig rows that the evaluate path uses.
	Tier int32

	// MaxLoanAmount is the cached cap in minor units. Always recomputed
	// from CreditTierConfig when the tier changes so the cap reflects
	// the latest policy.
	MaxLoanAmount int64

	// SuccessfulRepayments counts loans that have reached PAID_OFF under
	// this profile. Increments exactly once per loan, via the seed
	// RecordSuccessfulRepayment path which is idempotent on loan id.
	SuccessfulRepayments int32

	// OutstandingLoanCount caches how many active loans the client has
	// in-flight so the seed eligibility check can refuse a second loan
	// while the first is unsettled without a cross-service query.
	OutstandingLoanCount int32

	// TotalBorrowed and TotalRepaid are lifetime counters in minor units,
	// useful for tier rules that reward volume as well as frequency.
	TotalBorrowed int64
	TotalRepaid   int64

	FirstBorrowedAt *time.Time
	LastBorrowedAt  *time.Time
	LastRepaidAt    *time.Time

	Properties data.JSONMap
}

// TableName maps the model to seed_credit_profiles.
func (CreditProfile) TableName() string { return "seed_credit_profiles" }

// CreditTierConfig is a single rung on the tier ladder. Rows are ordered
// by MinSuccessfulRepayments and the seed EvaluateTier function picks
// the highest rung whose threshold is met.
//
// The config is product-scoped so different seed products can have
// different ladders (e.g. a short-term product might have a tighter
// progression than a long-term one).
type CreditTierConfig struct {
	data.BaseModel

	ProductID    string `gorm:"type:varchar(50);index:idx_ct_product;uniqueIndex:uq_ct_product_tier"`
	CurrencyCode string `gorm:"type:varchar(3);uniqueIndex:uq_ct_product_tier"`
	Tier         int32  `gorm:"uniqueIndex:uq_ct_product_tier"`

	// Name is a short human label ("Starter", "Builder", "Trusted",
	// "Premium") shown in operator tools.
	Name string `gorm:"type:varchar(64)"`

	// MinSuccessfulRepayments is the threshold required to enter this
	// tier. A fresh client with zero repayments enters Tier 1 by default;
	// Tier 2 might require 1, Tier 3 might require 3, and so on.
	MinSuccessfulRepayments int32

	// MaxLoanAmount is the cap in minor units for this tier.
	MaxLoanAmount int64

	// InterestRate in basis points for loans issued under this tier,
	// letting seed discount interest for more trusted customers.
	InterestRate int64

	// TermDays is the default repayment term for loans in this tier.
	TermDays int32

	State      int32
	Properties data.JSONMap
}

// TableName maps the model to seed_credit_tiers.
func (CreditTierConfig) TableName() string { return "seed_credit_tiers" }

// LoanRequest is the seed product's authoritative record of a
// customer-initiated loan request. It captures what the customer asked
// for, the eligibility decision, and the links to downstream records
// (application, loan account, disbursement) once the pipeline runs.
//
// The IdempotencyKey column is unique: a customer hitting "Request"
// twice with the same key converges on one row rather than creating
// duplicate loans.
type LoanRequest struct {
	data.BaseModel

	ClientID        string `gorm:"type:varchar(50);index:idx_lr_client;not null"`
	CreditProfileID string `gorm:"type:varchar(50);index:idx_lr_profile"`
	ProductID       string `gorm:"type:varchar(50);index:idx_lr_product"`

	Amount       int64  // minor units
	CurrencyCode string `gorm:"type:varchar(3)"`

	Purpose string `gorm:"type:text"`

	Status       int32  `gorm:"index:idx_lr_status"` // LoanRequestStatus
	DeniedReason string `gorm:"type:text"`

	// Tier + policy applied at the time of approval. These are frozen
	// on the request so a later policy change does not retroactively
	// alter what the customer was offered.
	TierAtApproval         int32
	InterestRateAtApproval int64 // basis points
	TermDaysAtApproval     int32

	// Downstream links. Empty strings mean the corresponding stage has
	// not run yet.
	ApplicationID  string `gorm:"type:varchar(50);index:idx_lr_app"`
	LoanAccountID  string `gorm:"type:varchar(50);index:idx_lr_loan"`
	DisbursementID string `gorm:"type:varchar(50)"`

	IdempotencyKey string `gorm:"type:varchar(255);uniqueIndex:uq_lr_idempotency"`

	RequestedAt *time.Time
	ApprovedAt  *time.Time
	DisbursedAt *time.Time
	CompletedAt *time.Time

	Properties data.JSONMap
}

// TableName maps the model to seed_loan_requests.
func (LoanRequest) TableName() string { return "seed_loan_requests" }
