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
	"context"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"github.com/pitabwire/frame/v2/data"
)

// SavingsProduct defines savings terms, rates, and rules for a bank.
type SavingsProduct struct {
	data.BaseModel
	BankID               string `gorm:"type:varchar(50);index:idx_sp_bank"`
	Name                 string `gorm:"type:varchar(255)"`
	Code                 string `gorm:"type:varchar(50);uniqueIndex:uq_sp_code"`
	Description          string `gorm:"type:text"`
	CurrencyCode         string `gorm:"type:varchar(3)"`
	InterestRate         int64  // basis points
	CompoundingFrequency int32
	PeriodType           int32
	MinDeposit           int64 // minor units
	MaxDeposit           int64 // minor units
	WithdrawalRules      data.JSONMap
	State                int32
	Properties           data.JSONMap
}

func (m *SavingsProduct) TableName() string { return "savings_products" }

func (m *SavingsProduct) ToAPI() *savingsv1.SavingsProductObject {
	return &savingsv1.SavingsProductObject{
		Id:                   m.GetID(),
		OrganizationId:       m.BankID,
		Name:                 m.Name,
		Code:                 m.Code,
		Description:          m.Description,
		CurrencyCode:         m.CurrencyCode,
		InterestRate:         BasisPointsToString(m.InterestRate),
		CompoundingFrequency: savingsv1.CompoundingFrequency(m.CompoundingFrequency),
		PeriodType:           savingsv1.SavingsPeriodType(m.PeriodType),
		MinDeposit:           MinorUnitsToMoney(m.MinDeposit, m.CurrencyCode),
		MaxDeposit:           MinorUnitsToMoney(m.MaxDeposit, m.CurrencyCode),
		WithdrawalRules:      m.WithdrawalRules.ToProtoStruct(),
		State:                commonv1.STATE(m.State),
		Properties:           m.Properties.ToProtoStruct(),
	}
}

func SavingsProductFromAPI(ctx context.Context, obj *savingsv1.SavingsProductObject) *SavingsProduct {
	if obj == nil {
		return nil
	}

	minDeposit, _ := MoneyToMinorUnits(obj.GetMinDeposit())
	maxDeposit, _ := MoneyToMinorUnits(obj.GetMaxDeposit())

	model := &SavingsProduct{
		BankID:               obj.GetOrganizationId(),
		Name:                 obj.GetName(),
		Code:                 obj.GetCode(),
		Description:          obj.GetDescription(),
		CurrencyCode:         obj.GetCurrencyCode(),
		InterestRate:         StringToBasisPoints(obj.GetInterestRate()),
		CompoundingFrequency: int32(obj.GetCompoundingFrequency()),
		PeriodType:           int32(obj.GetPeriodType()),
		MinDeposit:           minDeposit,
		MaxDeposit:           maxDeposit,
		State:                int32(obj.GetState()),
	}

	if obj.GetWithdrawalRules() != nil {
		model.WithdrawalRules = (&data.JSONMap{}).FromProtoStruct(obj.GetWithdrawalRules())
	}
	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// SavingsAccount represents an individual or group savings account.
type SavingsAccount struct {
	data.BaseModel
	ProductID         string `gorm:"type:varchar(50);index:idx_sa_product"`
	OwnerID           string `gorm:"type:varchar(50);index:idx_sa_owner"`
	OwnerType         int32
	BankID            string `gorm:"type:varchar(50);index:idx_sa_bank"`
	BranchID          string `gorm:"type:varchar(50);index:idx_sa_branch"`
	AgentID           string `gorm:"type:varchar(50);index:idx_sa_agent"`
	CurrencyCode      string `gorm:"type:varchar(3)"`
	Status            int32
	LedgerAccountID   string `gorm:"type:varchar(50)"`
	PaymentAccountRef string `gorm:"type:varchar(255)"`
	Properties        data.JSONMap
}

func (m *SavingsAccount) TableName() string { return "savings_accounts" }

func (m *SavingsAccount) ToAPI() *savingsv1.SavingsAccountObject {
	return &savingsv1.SavingsAccountObject{
		Id:                m.GetID(),
		ProductId:         m.ProductID,
		OwnerId:           m.OwnerID,
		OwnerType:         savingsv1.SavingsAccountOwnerType(m.OwnerType),
		OrganizationId:    m.BankID,
		BranchId:          m.BranchID,
		AgentId:           m.AgentID,
		CurrencyCode:      m.CurrencyCode,
		Status:            savingsv1.SavingsAccountStatus(m.Status),
		LedgerAccountId:   m.LedgerAccountID,
		PaymentAccountRef: m.PaymentAccountRef,
		Properties:        m.Properties.ToProtoStruct(),
	}
}

func SavingsAccountFromAPI(ctx context.Context, obj *savingsv1.SavingsAccountObject) *SavingsAccount {
	if obj == nil {
		return nil
	}

	model := &SavingsAccount{
		ProductID:         obj.GetProductId(),
		OwnerID:           obj.GetOwnerId(),
		OwnerType:         int32(obj.GetOwnerType()),
		BankID:            obj.GetOrganizationId(),
		BranchID:          obj.GetBranchId(),
		AgentID:           obj.GetAgentId(),
		CurrencyCode:      obj.GetCurrencyCode(),
		Status:            int32(obj.GetStatus()),
		LedgerAccountID:   obj.GetLedgerAccountId(),
		PaymentAccountRef: obj.GetPaymentAccountRef(),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// Deposit records a deposit into a savings account.
type Deposit struct {
	data.BaseModel
	SavingsAccountID    string `gorm:"type:varchar(50);index:idx_dep_account"`
	Amount              int64  // minor units
	CurrencyCode        string `gorm:"type:varchar(3)"`
	Status              int32
	PaymentReference    string `gorm:"type:varchar(255)"`
	LedgerTransactionID string `gorm:"type:varchar(50)"`
	Channel             string `gorm:"type:varchar(50)"`
	PayerReference      string `gorm:"type:varchar(255)"`
	IdempotencyKey      string `gorm:"type:varchar(255);uniqueIndex:uq_dep_idempotency"`
	Properties          data.JSONMap
}

func (m *Deposit) TableName() string { return "deposits" }

func (m *Deposit) ToAPI() *savingsv1.DepositObject {
	return &savingsv1.DepositObject{
		Id:                  m.GetID(),
		SavingsAccountId:    m.SavingsAccountID,
		Amount:              MinorUnitsToMoney(m.Amount, m.CurrencyCode),
		Status:              savingsv1.DepositStatus(m.Status),
		PaymentReference:    m.PaymentReference,
		LedgerTransactionId: m.LedgerTransactionID,
		Channel:             m.Channel,
		PayerReference:      m.PayerReference,
		IdempotencyKey:      m.IdempotencyKey,
		Properties:          m.Properties.ToProtoStruct(),
	}
}

func DepositFromAPI(ctx context.Context, obj *savingsv1.DepositObject) *Deposit {
	if obj == nil {
		return nil
	}

	amount, currencyCode := MoneyToMinorUnits(obj.GetAmount())

	model := &Deposit{
		SavingsAccountID:    obj.GetSavingsAccountId(),
		Amount:              amount,
		CurrencyCode:        currencyCode,
		Status:              int32(obj.GetStatus()),
		PaymentReference:    obj.GetPaymentReference(),
		LedgerTransactionID: obj.GetLedgerTransactionId(),
		Channel:             obj.GetChannel(),
		PayerReference:      obj.GetPayerReference(),
		IdempotencyKey:      obj.GetIdempotencyKey(),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// Withdrawal records a withdrawal from a savings account.
type Withdrawal struct {
	data.BaseModel
	SavingsAccountID    string `gorm:"type:varchar(50);index:idx_wdr_account"`
	Amount              int64  // minor units
	CurrencyCode        string `gorm:"type:varchar(3)"`
	Status              int32
	PaymentReference    string `gorm:"type:varchar(255)"`
	LedgerTransactionID string `gorm:"type:varchar(50)"`
	Channel             string `gorm:"type:varchar(50)"`
	RecipientReference  string `gorm:"type:varchar(255)"`
	Reason              string `gorm:"type:text"`
	IdempotencyKey      string `gorm:"type:varchar(255);uniqueIndex:uq_wdr_idempotency"`
	Properties          data.JSONMap
}

func (m *Withdrawal) TableName() string { return "withdrawals" }

func (m *Withdrawal) ToAPI() *savingsv1.WithdrawalObject {
	return &savingsv1.WithdrawalObject{
		Id:                  m.GetID(),
		SavingsAccountId:    m.SavingsAccountID,
		Amount:              MinorUnitsToMoney(m.Amount, m.CurrencyCode),
		Status:              savingsv1.WithdrawalStatus(m.Status),
		PaymentReference:    m.PaymentReference,
		LedgerTransactionId: m.LedgerTransactionID,
		Channel:             m.Channel,
		RecipientReference:  m.RecipientReference,
		Reason:              m.Reason,
		IdempotencyKey:      m.IdempotencyKey,
		Properties:          m.Properties.ToProtoStruct(),
	}
}

func WithdrawalFromAPI(ctx context.Context, obj *savingsv1.WithdrawalObject) *Withdrawal {
	if obj == nil {
		return nil
	}

	wdAmount, wdCurrency := MoneyToMinorUnits(obj.GetAmount())

	model := &Withdrawal{
		SavingsAccountID:    obj.GetSavingsAccountId(),
		Amount:              wdAmount,
		CurrencyCode:        wdCurrency,
		Status:              int32(obj.GetStatus()),
		PaymentReference:    obj.GetPaymentReference(),
		LedgerTransactionID: obj.GetLedgerTransactionId(),
		Channel:             obj.GetChannel(),
		RecipientReference:  obj.GetRecipientReference(),
		Reason:              obj.GetReason(),
		IdempotencyKey:      obj.GetIdempotencyKey(),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// InterestAccrual records periodic interest accrued on a savings account.
//
// The (savings_account_id, period_end) pair is unique: rerunning the accrual
// job for the same closing period returns the existing row rather than
// double-crediting the member. Callers should use GetByAccountAndPeriod
// before attempting to create a new accrual, or rely on the duplicate-key
// handling in the InterestAccrualSave event handler.
type InterestAccrual struct {
	data.BaseModel
	SavingsAccountID    string `gorm:"type:varchar(50);index:idx_ia_account;uniqueIndex:uq_ia_account_period"`
	Amount              int64  // minor units
	CurrencyCode        string `gorm:"type:varchar(3)"`
	PeriodStart         *time.Time
	PeriodEnd           *time.Time `gorm:"uniqueIndex:uq_ia_account_period"`
	RateApplied         int64      // basis points
	BalanceUsed         int64      // minor units
	LedgerTransactionID string     `gorm:"type:varchar(50)"`
	Properties          data.JSONMap
}

func (m *InterestAccrual) TableName() string { return "interest_accruals" }

func (m *InterestAccrual) ToAPI() *savingsv1.InterestAccrualObject {
	return &savingsv1.InterestAccrualObject{
		Id:                  m.GetID(),
		SavingsAccountId:    m.SavingsAccountID,
		Amount:              MinorUnitsToMoney(m.Amount, m.CurrencyCode),
		PeriodStart:         TimeToString(m.PeriodStart),
		PeriodEnd:           TimeToString(m.PeriodEnd),
		RateApplied:         BasisPointsToString(m.RateApplied),
		BalanceUsed:         MinorUnitsToMoney(m.BalanceUsed, m.CurrencyCode),
		LedgerTransactionId: m.LedgerTransactionID,
		Properties:          m.Properties.ToProtoStruct(),
	}
}

func InterestAccrualFromAPI(ctx context.Context, obj *savingsv1.InterestAccrualObject) *InterestAccrual {
	if obj == nil {
		return nil
	}

	iaAmount, iaCurrency := MoneyToMinorUnits(obj.GetAmount())
	iaBalance, _ := MoneyToMinorUnits(obj.GetBalanceUsed())

	model := &InterestAccrual{
		SavingsAccountID:    obj.GetSavingsAccountId(),
		Amount:              iaAmount,
		CurrencyCode:        iaCurrency,
		PeriodStart:         StringToTime(obj.GetPeriodStart()),
		PeriodEnd:           StringToTime(obj.GetPeriodEnd()),
		RateApplied:         StringToBasisPoints(obj.GetRateApplied()),
		BalanceUsed:         iaBalance,
		LedgerTransactionID: obj.GetLedgerTransactionId(),
	}

	if obj.GetProperties() != nil {
		model.Properties = (&data.JSONMap{}).FromProtoStruct(obj.GetProperties())
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}
