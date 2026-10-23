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

// Transfer type constants live in pkg/constants/transfer_types.go.

// ObligationType defines the type of financial obligation.
type ObligationType int32

const (
	ObligationTypeUnspecified ObligationType = 0
	ObligationTypePeriodic    ObligationType = 1
	ObligationTypeOneTime     ObligationType = 2
	ObligationTypeVoluntary   ObligationType = 3
)

// TransferOrder represents a financial transfer between accounts.
type TransferOrder struct {
	data.BaseModel
	DebitAccountRef  string `gorm:"type:varchar(50);index:idx_to_debit;not null"`
	CreditAccountRef string `gorm:"type:varchar(50);index:idx_to_credit;not null"`
	Amount           int64  // minor units
	Currency         string `gorm:"type:varchar(3)"`
	OrderType        int32  `gorm:"column:order_type;index:idx_to_type"` // TransferType
	Reference        string `gorm:"type:varchar(255)"`
	Description      string `gorm:"type:text"`
	ExtraData        data.JSONMap
	State            int32
	Properties       data.JSONMap
	// LedgerTransactionID is the id the ledger returned when the posting
	// landed. A retry of an order that carries one skips the ledger call: the
	// money has moved, only the side effects or the completion mark are owed.
	LedgerTransactionID string `gorm:"type:varchar(50);index:idx_to_ledger_txn"`
	// PaymentInitiatedAt is claimed once, immediately before the first call to
	// the payment rail. A retry that finds it set does not send a second payout.
	PaymentInitiatedAt *time.Time
	// PaymentID is the payment service's id for the payout, when one was sent.
	PaymentID string `gorm:"type:varchar(50)"`
	// PayoutStatus is PayoutStatusFailed once the payment rail reported the
	// payout as failed. Such an order never completes; it needs a reversal.
	PayoutStatus string `gorm:"type:varchar(20)"`
	// FailureReason records why the last execution attempt released the order.
	FailureReason string `gorm:"type:text"`

	payout payoutTarget `gorm:"-"`
}

func (m *TransferOrder) TableName() string { return "transfer_orders" }

// LedgerPosted reports whether the ledger leg of this order has landed.
func (m *TransferOrder) LedgerPosted() bool { return m.LedgerTransactionID != "" }

// PayoutStatusFailed marks an order whose payout the rail rejected.
const PayoutStatusFailed = "failed"

// PayoutFailed reports whether the payment rail rejected this order's payout.
func (m *TransferOrder) PayoutFailed() bool { return m.PayoutStatus == PayoutStatusFailed }

// payoutTarget is the transient payout destination, set by the side-effect
// handler for the execution in progress; never persisted.
type payoutTarget struct {
	recipientID string
	route       string
}

func (m *TransferOrder) SetPayoutTarget(recipientID, route string) {
	m.payout = payoutTarget{recipientID: recipientID, route: route}
}

func (m *TransferOrder) PayoutRecipient() string { return m.payout.recipientID }
func (m *TransferOrder) PayoutRoute() string     { return m.payout.route }

// Obligation represents a financial obligation for a member.
type Obligation struct {
	data.BaseModel
	MembershipID   string `gorm:"type:varchar(50);index:idx_obl_member;not null"`
	CauseType      string `gorm:"type:varchar(50)"`
	CauseID        string `gorm:"type:varchar(50)"`
	ObligationType int32  `gorm:"column:obligation_type"` // ObligationType
	PeriodID       string `gorm:"type:varchar(50);index:idx_obl_period"`
	Amount         int64  // minor units
	Currency       string `gorm:"type:varchar(3)"`
	Deadline       *time.Time
	Description    string `gorm:"type:text"`
	NotificationID string `gorm:"type:varchar(50)"`
	State          int32
	Properties     data.JSONMap
}

func (m *Obligation) TableName() string { return "obligations" }

// IncomingPayment represents a received payment before identification/allocation.
type IncomingPayment struct {
	data.BaseModel
	PayableID     string `gorm:"type:varchar(50)"`
	PayableType   string `gorm:"type:varchar(50)"`
	Amount        int64  // minor units
	Currency      string `gorm:"type:varchar(3)"`
	Description   string `gorm:"type:text"`
	TransactionID string `gorm:"type:varchar(100);index:idx_ip_txn"`
	OwnerID       string `gorm:"type:varchar(50);index:idx_ip_owner"`
	OwnerType     string `gorm:"type:varchar(50)"`
	State         int32
	Properties    data.JSONMap
	// AllocatingAt is the lease an allocation run holds on the payment. One
	// run at a time may allocate; a lease older than the stale window is
	// taken over, so a crashed run never parks a payment for ever.
	AllocatingAt *time.Time
}

func (m *IncomingPayment) TableName() string { return "incoming_payments" }

// AccountRef maps an owner to a ledger account.
type AccountRef struct {
	data.BaseModel
	OwnerID    string `gorm:"type:varchar(50);index:idx_ar_owner"`
	OwnerType  string `gorm:"type:varchar(50)"`
	Name       string `gorm:"type:varchar(100);index:idx_ar_name"`
	Currency   string `gorm:"type:varchar(3)"`
	LedgerID   string `gorm:"type:varchar(50)"`
	Reference  string `gorm:"type:varchar(255)"`
	State      int32
	Properties data.JSONMap
}

func (m *AccountRef) TableName() string { return "account_refs" }

// LedgerRef represents a reference to an external ledger.
type LedgerRef struct {
	data.BaseModel
	OwnerID    string `gorm:"type:varchar(50);index:idx_lr_owner"`
	OwnerType  string `gorm:"type:varchar(50)"`
	Reference  string `gorm:"type:varchar(255)"`
	LedgerType int32
	State      int32
	Properties data.JSONMap
}

func (m *LedgerRef) TableName() string { return "ledger_refs" }

// CBSSyncRecord tracks synchronization with core banking system.
type CBSSyncRecord struct {
	data.BaseModel
	OwnerID          string `gorm:"type:varchar(50);index:idx_cbs_owner"`
	OwnerType        string `gorm:"type:varchar(50)"`
	OrderType        int32  `gorm:"column:order_type"` // TransferType
	TransactionID    string `gorm:"type:varchar(100)"`
	CBSTransactionID string `gorm:"type:varchar(100)"`
	CBSStatus        string `gorm:"type:varchar(50)"`
	Amount           int64  // minor units
	Currency         string `gorm:"type:varchar(3)"`
	Details          string `gorm:"type:text"`
	LedgerID         string `gorm:"type:varchar(50)"`
	State            int32
	Properties       data.JSONMap
}

func (m *CBSSyncRecord) TableName() string { return "cbs_sync_records" }

// PayBack tracks loan repayment splits back to funding sources.
type PayBack struct {
	data.BaseModel
	LoanFundingID       string `gorm:"type:varchar(50);index:idx_pb_funding;not null"`
	AmortizationEntryID string `gorm:"type:varchar(50)"`
	Amount              int64  // minor units
	Currency            string `gorm:"type:varchar(3)"`
	Description         string `gorm:"type:text"`
	State               int32
	Properties          data.JSONMap
}

func (m *PayBack) TableName() string { return "pay_backs" }

// TransactionCost represents costs associated with a financial transaction.
type TransactionCost struct {
	data.BaseModel
	CostlyID    string `gorm:"type:varchar(50);index:idx_tc_costly"`
	CostlyType  string `gorm:"type:varchar(50)"`
	Amount      int64  // minor units
	Currency    string `gorm:"type:varchar(3)"`
	Description string `gorm:"type:text"`
	State       int32
	Properties  data.JSONMap
}

func (m *TransactionCost) TableName() string { return "transaction_costs" }

// ServiceFee represents a service fee charged on a transaction.
type ServiceFee struct {
	data.BaseModel
	SourceType string `gorm:"type:varchar(50)"`
	SourceID   string `gorm:"type:varchar(50);index:idx_sf_source"`
	PeriodID   string `gorm:"type:varchar(50)"`
	Proportion int64  // basis points
	Amount     int64  // minor units
	Currency   string `gorm:"type:varchar(3)"`
	OwnerID    string `gorm:"type:varchar(50);index:idx_sf_owner"`
	OwnerType  string `gorm:"type:varchar(50)"`
	State      int32
	Properties data.JSONMap
}

func (m *ServiceFee) TableName() string { return "service_fees" }
