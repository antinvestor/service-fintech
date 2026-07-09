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

package models

import (
	"time"

	"github.com/pitabwire/frame/v2/data"
)

// LoanOfferResponse defines a member's response to a loan offer.
type LoanOfferResponse int32

const (
	LoanOfferResponseNone   LoanOfferResponse = 0
	LoanOfferResponseAccept LoanOfferResponse = 1
	LoanOfferResponseReject LoanOfferResponse = 2
	LoanOfferResponseHalf   LoanOfferResponse = 3
	LoanOfferResponseBlock  LoanOfferResponse = 4
	LoanOfferResponseCustom LoanOfferResponse = 5
)

// LoanOfferType defines whether a loan was offered or self-initiated.
type LoanOfferType int32

const (
	LoanOfferTypeUnspecified   LoanOfferType = 0
	LoanOfferTypeOffered       LoanOfferType = 1
	LoanOfferTypeSelfInitiated LoanOfferType = 2
)

// LoanWindow represents a lending window for a member within a group cycle.
type LoanWindow struct {
	data.BaseModel
	GroupID        string `gorm:"type:varchar(50);index:idx_lw_group;not null"`
	MembershipID   string `gorm:"type:varchar(50);index:idx_lw_member;not null"`
	TenureID       string `gorm:"type:varchar(50);index:idx_lw_tenure;not null"`
	PeriodID       string `gorm:"type:varchar(50);index:idx_lw_period;not null"`
	GracePeriod    int32
	LoanTenure     int32
	Position       int32
	PeriodicAmount int64  // minor units
	Leverage       int64  // basis points (e.g. 190 = 1.90x)
	Currency       string `gorm:"type:varchar(3)"`
	State          int32
	Properties     data.JSONMap
}

func (m *LoanWindow) TableName() string { return "loan_windows" }

// LoanOffer represents a loan offer to a member (maps from Java LoanRequest).
type LoanOffer struct {
	data.BaseModel
	MembershipID   string `gorm:"type:varchar(50);index:idx_lo_member;not null"`
	LoanWindowID   string `gorm:"type:varchar(50);index:idx_lo_window;not null"`
	PeriodID       string `gorm:"type:varchar(50);index:idx_lo_period;not null"`
	Amount         int64  // minor units - offered amount
	Currency       string `gorm:"type:varchar(3)"`
	OfferType      int32  `gorm:"column:offer_type"`
	Response       int32  // LoanOfferResponse
	ExpiryDate     *time.Time
	NotificationID string `gorm:"type:varchar(50)"`
	Description    string `gorm:"type:text"`
	LoanAccountID  string `gorm:"type:varchar(50)"` // cross-ref to Lender LoanAccountObject
	ApplicationID  string `gorm:"type:varchar(50)"` // cross-ref to Lender ApplicationObject
	State          int32
	Properties     data.JSONMap
}

func (m *LoanOffer) TableName() string { return "loan_offers" }

// PeriodType defines the period frequency.
type PeriodType int32

const (
	PeriodTypeUnspecified PeriodType = 0
	PeriodTypeWeekly      PeriodType = 1
	PeriodTypeBiweekly    PeriodType = 2
	PeriodTypeMonthly     PeriodType = 3
)

// InfractionType defines types of infractions.
type InfractionType int32

const (
	InfractionTypeUnspecified               InfractionType = 0
	InfractionTypeGroupClosedOwesMoney      InfractionType = 1
	InfractionTypeGroupInactivated          InfractionType = 2
	InfractionTypeGroupClosedVoluntarily    InfractionType = 3
	InfractionTypeAccountInvalid            InfractionType = 4
	InfractionTypeSavingsLowerThanExpected  InfractionType = 5
	InfractionTypeLoanPaymentsNotAsExpected InfractionType = 6
	InfractionTypeSystemError               InfractionType = 7
)

// Tenure represents a group's lifecycle period (e.g. 52 weeks).
type Tenure struct {
	data.BaseModel
	GroupID    string `gorm:"type:varchar(50);index:idx_ten_group;not null"`
	StartDate  *time.Time
	EndDate    *time.Time
	Duration   int32 // number of periods
	Position   int32
	Welcomed   bool
	State      int32
	Properties data.JSONMap
}

func (m *Tenure) TableName() string { return "tenures" }
func (m *Tenure) SetVersion(v uint) { m.Version = v }

// Period represents a single time period within a tenure (e.g. 1 week).
type Period struct {
	data.BaseModel
	GroupID        string `gorm:"type:varchar(50);index:idx_per_group;not null"`
	TenureID       string `gorm:"type:varchar(50);index:idx_per_tenure;not null"`
	StartDate      *time.Time
	EndDate        *time.Time
	PeriodType     int32 `gorm:"column:period_type"`
	Position       int32
	ParentPeriodID string `gorm:"type:varchar(50);uniqueIndex:uq_per_parent"`
	State          int32
	Properties     data.JSONMap
}

func (m *Period) TableName() string { return "periods" }
func (m *Period) SetVersion(v uint) { m.Version = v }

// Motion represents a group voting/decision motion.
type Motion struct {
	data.BaseModel
	GroupID     string `gorm:"type:varchar(50);index:idx_mot_group;not null"`
	MotionType  int32
	Agenda      string `gorm:"type:text"`
	Threshold   int32  // minimum votes needed
	ExpiryDate  *time.Time
	Description string `gorm:"type:text"`
	State       int32
	Properties  data.JSONMap
}

func (m *Motion) TableName() string { return "motions" }
func (m *Motion) SetVersion(v uint) { m.Version = v }

// MotionVote represents a member's vote on a motion.
type MotionVote struct {
	data.BaseModel
	MotionID     string `gorm:"type:varchar(50);index:idx_mv_motion;not null"`
	MembershipID string `gorm:"type:varchar(50);index:idx_mv_member;not null"`
	Choice       int32
	Properties   data.JSONMap
}

func (m *MotionVote) TableName() string { return "motion_votes" }

// Infraction represents a rule violation by a member.
type Infraction struct {
	data.BaseModel
	OwnerID        string `gorm:"type:varchar(50);index:idx_inf_owner"`
	OwnerType      string `gorm:"type:varchar(50)"`
	GroupID        string `gorm:"type:varchar(50);index:idx_inf_group"`
	InfractionType int32  `gorm:"column:infraction_type"`
	Amount         int64  // minor units
	Currency       string `gorm:"type:varchar(3)"`
	Message        string `gorm:"type:text"`
	Canceled       bool
	State          int32
	Properties     data.JSONMap
}

func (m *Infraction) TableName() string { return "infractions" }
func (m *Infraction) SetVersion(v uint) { m.Version = v }

// GroupWarning represents a warning issued to a group.
type GroupWarning struct {
	data.BaseModel
	GroupID     string `gorm:"type:varchar(50);index:idx_gw_group;not null"`
	WarningType int32
	Message     string `gorm:"type:text"`
	State       int32
	Properties  data.JSONMap
}

func (m *GroupWarning) TableName() string { return "group_warnings" }

// MemberScore represents a member's compliance/creditworthiness score.
type MemberScore struct {
	data.BaseModel
	MembershipID string `gorm:"type:varchar(50);index:idx_ms_member;not null"`
	Score        int32
	ScoreType    int32
	Description  string `gorm:"type:text"`
	Properties   data.JSONMap
}

func (m *MemberScore) TableName() string { return "member_scores" }

// Occurrence represents a notable event in a group's lifecycle.
type Occurrence struct {
	data.BaseModel
	GroupID     string `gorm:"type:varchar(50);index:idx_occ_group"`
	OccurType   int32
	Description string `gorm:"type:text"`
	Properties  data.JSONMap
}

func (m *Occurrence) TableName() string { return "occurrences" }

// RequestLog represents an audit log of API requests.
type RequestLog struct {
	data.BaseModel
	GroupID     string `gorm:"type:varchar(50);index:idx_rl_group"`
	RequestType int32
	Details     string `gorm:"type:text"`
	State       int32
	Properties  data.JSONMap
}

func (m *RequestLog) TableName() string { return "request_logs" }
