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
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/frame/v2/data"
)

// ---------------------------------------------------------------------------
// LoanAccount
// ---------------------------------------------------------------------------

type LoanAccount struct {
	data.BaseModel
	LoanRequestID                 string `gorm:"type:varchar(50);uniqueIndex:uq_loan_request"`
	ProductID                     string `gorm:"type:varchar(50);index:idx_la_product"`
	ClientID                      string `gorm:"type:varchar(50);index:idx_la_client"`
	AgentID                       string `gorm:"type:varchar(50);index:idx_la_agent"`
	BranchID                      string `gorm:"type:varchar(50);index:idx_la_branch"`
	OrganizationID                string `gorm:"type:varchar(50);index:idx_la_organization"`
	Status                        int32
	CurrencyCode                  string `gorm:"type:varchar(3)"`
	PrincipalAmount               int64
	InterestRate                  int64 // basis points
	TermDays                      int32
	InterestMethod                int32
	RepaymentFrequency            int32
	DisbursedAt                   *time.Time
	MaturityDate                  *time.Time
	FirstRepaymentDate            *time.Time
	LastRepaymentDate             *time.Time
	DaysPastDue                   int32
	LedgerAssetAccountID          string `gorm:"type:varchar(50)"`
	LedgerInterestIncomeAccountID string `gorm:"type:varchar(50)"`
	LedgerFeeIncomeAccountID      string `gorm:"type:varchar(50)"`
	LedgerPenaltyIncomeAccountID  string `gorm:"type:varchar(50)"`
	PaymentAccountRef             string `gorm:"type:varchar(100)"`
	Properties                    data.JSONMap
}

func (m *LoanAccount) TableName() string { return "loan_accounts" }

func (m *LoanAccount) ToAPI() *loansv1.LoanAccountObject {
	return &loansv1.LoanAccountObject{
		Id:                            m.GetID(),
		LoanRequestId:                 m.LoanRequestID,
		ProductId:                     m.ProductID,
		ClientId:                      m.ClientID,
		AgentId:                       m.AgentID,
		BranchId:                      m.BranchID,
		OrganizationId:                m.OrganizationID,
		Status:                        loansv1.LoanStatus(m.Status),
		PrincipalAmount:               MinorUnitsToMoney(m.PrincipalAmount, m.CurrencyCode),
		InterestRate:                  BasisPointsToString(m.InterestRate),
		TermDays:                      m.TermDays,
		InterestMethod:                loansv1.InterestMethod(m.InterestMethod),
		RepaymentFrequency:            loansv1.RepaymentFrequency(m.RepaymentFrequency),
		DisbursedAt:                   TimeToString(m.DisbursedAt),
		MaturityDate:                  TimeToString(m.MaturityDate),
		FirstRepaymentDate:            TimeToString(m.FirstRepaymentDate),
		LastRepaymentDate:             TimeToString(m.LastRepaymentDate),
		DaysPastDue:                   m.DaysPastDue,
		LedgerAssetAccountId:          m.LedgerAssetAccountID,
		LedgerInterestIncomeAccountId: m.LedgerInterestIncomeAccountID,
		LedgerFeeIncomeAccountId:      m.LedgerFeeIncomeAccountID,
		LedgerPenaltyIncomeAccountId:  m.LedgerPenaltyIncomeAccountID,
		PaymentAccountRef:             m.PaymentAccountRef,
		Properties:                    m.Properties.ToProtoStruct(),
	}
}

func LoanAccountFromAPI(ctx context.Context, obj *loansv1.LoanAccountObject) *LoanAccount {
	if obj == nil {
		return nil
	}

	principalAmount, principalCurrency := MoneyToMinorUnits(obj.GetPrincipalAmount())

	model := &LoanAccount{
		LoanRequestID:                 obj.GetLoanRequestId(),
		ProductID:                     obj.GetProductId(),
		ClientID:                      obj.GetClientId(),
		AgentID:                       obj.GetAgentId(),
		BranchID:                      obj.GetBranchId(),
		OrganizationID:                obj.GetOrganizationId(),
		Status:                        int32(obj.GetStatus()),
		CurrencyCode:                  principalCurrency,
		PrincipalAmount:               principalAmount,
		InterestRate:                  StringToBasisPoints(obj.GetInterestRate()),
		TermDays:                      obj.GetTermDays(),
		InterestMethod:                int32(obj.GetInterestMethod()),
		RepaymentFrequency:            int32(obj.GetRepaymentFrequency()),
		DisbursedAt:                   StringToTime(obj.GetDisbursedAt()),
		MaturityDate:                  StringToTime(obj.GetMaturityDate()),
		FirstRepaymentDate:            StringToTime(obj.GetFirstRepaymentDate()),
		LastRepaymentDate:             StringToTime(obj.GetLastRepaymentDate()),
		DaysPastDue:                   obj.GetDaysPastDue(),
		LedgerAssetAccountID:          obj.GetLedgerAssetAccountId(),
		LedgerInterestIncomeAccountID: obj.GetLedgerInterestIncomeAccountId(),
		LedgerFeeIncomeAccountID:      obj.GetLedgerFeeIncomeAccountId(),
		LedgerPenaltyIncomeAccountID:  obj.GetLedgerPenaltyIncomeAccountId(),
		PaymentAccountRef:             obj.GetPaymentAccountRef(),
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

// ---------------------------------------------------------------------------
// RepaymentSchedule
// ---------------------------------------------------------------------------

type RepaymentSchedule struct {
	data.BaseModel
	LoanAccountID string `gorm:"type:varchar(50);index:idx_rs_loan"`
	Version       int32
	IsActive      bool
	GeneratedAt   *time.Time
	Properties    data.JSONMap
}

func (m *RepaymentSchedule) TableName() string { return "repayment_schedules" }

func (m *RepaymentSchedule) ToAPI(entries []*ScheduleEntry) *loansv1.RepaymentScheduleObject {
	var apiEntries []*loansv1.ScheduleEntryObject
	for _, e := range entries {
		apiEntries = append(apiEntries, e.ToAPI())
	}
	return &loansv1.RepaymentScheduleObject{
		Id:            m.GetID(),
		LoanAccountId: m.LoanAccountID,
		Version:       m.Version,
		IsActive:      m.IsActive,
		GeneratedAt:   TimeToString(m.GeneratedAt),
		Entries:       apiEntries,
		Properties:    m.Properties.ToProtoStruct(),
	}
}

func RepaymentScheduleFromAPI(ctx context.Context, obj *loansv1.RepaymentScheduleObject) *RepaymentSchedule {
	if obj == nil {
		return nil
	}

	model := &RepaymentSchedule{
		LoanAccountID: obj.GetLoanAccountId(),
		Version:       obj.GetVersion(),
		IsActive:      obj.GetIsActive(),
		GeneratedAt:   StringToTime(obj.GetGeneratedAt()),
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

// ---------------------------------------------------------------------------
// ScheduleEntry
// ---------------------------------------------------------------------------

type ScheduleEntry struct {
	data.BaseModel
	ScheduleID        string `gorm:"type:varchar(50);index:idx_se_schedule"`
	LoanAccountID     string `gorm:"type:varchar(50);index:idx_se_loan"`
	InstallmentNumber int32
	DueDate           *time.Time
	CurrencyCode      string `gorm:"type:varchar(3)"`
	PrincipalDue      int64
	InterestDue       int64
	FeesDue           int64
	TotalDue          int64
	PrincipalPaid     int64
	InterestPaid      int64
	FeesPaid          int64
	TotalPaid         int64
	Outstanding       int64
	Status            int32
	PaidDate          *time.Time
	Properties        data.JSONMap
}

func (m *ScheduleEntry) TableName() string { return "schedule_entries" }

func (m *ScheduleEntry) ToAPI() *loansv1.ScheduleEntryObject {
	cc := m.CurrencyCode
	return &loansv1.ScheduleEntryObject{
		Id:                m.GetID(),
		ScheduleId:        m.ScheduleID,
		InstallmentNumber: m.InstallmentNumber,
		DueDate:           TimeToString(m.DueDate),
		PrincipalDue:      MinorUnitsToMoney(m.PrincipalDue, cc),
		InterestDue:       MinorUnitsToMoney(m.InterestDue, cc),
		FeesDue:           MinorUnitsToMoney(m.FeesDue, cc),
		TotalDue:          MinorUnitsToMoney(m.TotalDue, cc),
		PrincipalPaid:     MinorUnitsToMoney(m.PrincipalPaid, cc),
		InterestPaid:      MinorUnitsToMoney(m.InterestPaid, cc),
		FeesPaid:          MinorUnitsToMoney(m.FeesPaid, cc),
		TotalPaid:         MinorUnitsToMoney(m.TotalPaid, cc),
		Outstanding:       MinorUnitsToMoney(m.Outstanding, cc),
		Status:            loansv1.ScheduleEntryStatus(m.Status),
		PaidDate:          TimeToString(m.PaidDate),
		Properties:        m.Properties.ToProtoStruct(),
	}
}

func ScheduleEntryFromAPI(ctx context.Context, obj *loansv1.ScheduleEntryObject) *ScheduleEntry {
	if obj == nil {
		return nil
	}

	sePrincipalDue, seCurrency := MoneyToMinorUnits(obj.GetPrincipalDue())
	seInterestDue, _ := MoneyToMinorUnits(obj.GetInterestDue())
	seFeesDue, _ := MoneyToMinorUnits(obj.GetFeesDue())
	seTotalDue, _ := MoneyToMinorUnits(obj.GetTotalDue())
	sePrincipalPaid, _ := MoneyToMinorUnits(obj.GetPrincipalPaid())
	seInterestPaid, _ := MoneyToMinorUnits(obj.GetInterestPaid())
	seFeesPaid, _ := MoneyToMinorUnits(obj.GetFeesPaid())
	seTotalPaid, _ := MoneyToMinorUnits(obj.GetTotalPaid())
	seOutstanding, _ := MoneyToMinorUnits(obj.GetOutstanding())

	model := &ScheduleEntry{
		ScheduleID:        obj.GetScheduleId(),
		InstallmentNumber: obj.GetInstallmentNumber(),
		DueDate:           StringToTime(obj.GetDueDate()),
		CurrencyCode:      seCurrency,
		PrincipalDue:      sePrincipalDue,
		InterestDue:       seInterestDue,
		FeesDue:           seFeesDue,
		TotalDue:          seTotalDue,
		PrincipalPaid:     sePrincipalPaid,
		InterestPaid:      seInterestPaid,
		FeesPaid:          seFeesPaid,
		TotalPaid:         seTotalPaid,
		Outstanding:       seOutstanding,
		Status:            int32(obj.GetStatus()),
		PaidDate:          StringToTime(obj.GetPaidDate()),
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

// ---------------------------------------------------------------------------
// LoanBalance (internal snapshot)
// ---------------------------------------------------------------------------

type LoanBalance struct {
	data.BaseModel
	LoanAccountID        string `gorm:"type:varchar(50);uniqueIndex:uq_lb_loan"`
	CurrencyCode         string `gorm:"type:varchar(3)"`
	PrincipalOutstanding int64
	InterestAccrued      int64
	FeesOutstanding      int64
	PenaltiesOutstanding int64
	TotalOutstanding     int64
	TotalPaid            int64
	TotalDisbursed       int64
	LastCalculatedAt     *time.Time
}

func (m *LoanBalance) TableName() string { return "loan_balances" }

func (m *LoanBalance) ToAPI() *loansv1.LoanBalanceObject {
	cc := m.CurrencyCode
	return &loansv1.LoanBalanceObject{
		LoanAccountId:        m.LoanAccountID,
		PrincipalOutstanding: MinorUnitsToMoney(m.PrincipalOutstanding, cc),
		InterestAccrued:      MinorUnitsToMoney(m.InterestAccrued, cc),
		FeesOutstanding:      MinorUnitsToMoney(m.FeesOutstanding, cc),
		PenaltiesOutstanding: MinorUnitsToMoney(m.PenaltiesOutstanding, cc),
		TotalOutstanding:     MinorUnitsToMoney(m.TotalOutstanding, cc),
		TotalPaid:            MinorUnitsToMoney(m.TotalPaid, cc),
		TotalDisbursed:       MinorUnitsToMoney(m.TotalDisbursed, cc),
		LastCalculatedAt:     TimeToString(m.LastCalculatedAt),
	}
}

// ---------------------------------------------------------------------------
// LoanProduct
// ---------------------------------------------------------------------------

type LoanProduct struct {
	data.BaseModel
	OrganizationID       string `gorm:"type:varchar(50);index:idx_lp_organization"`
	Name                 string `gorm:"type:varchar(255)"`
	Code                 string `gorm:"type:varchar(50);uniqueIndex:uq_lp_code"`
	Description          string `gorm:"type:text"`
	ProductType          int32
	CurrencyCode         string `gorm:"type:varchar(3)"`
	InterestMethod       int32
	RepaymentFrequency   int32
	MinAmount            int64
	MaxAmount            int64
	MinTermDays          int32
	MaxTermDays          int32
	AnnualInterestRate   int64 // basis points
	ProcessingFeePercent int64 // basis points
	InsuranceFeePercent  int64 // basis points
	LatePenaltyRate      int64 // basis points
	GracePeriodDays      int32
	FeeStructure         data.JSONMap
	EligibilityCriteria  data.JSONMap
	RequiredForms        data.JSONMap // JSON array of ProductFormRequirement
	State                int32
	Properties           data.JSONMap
}

func (m *LoanProduct) TableName() string { return "loan_products" }

func (m *LoanProduct) ToAPI() *loansv1.LoanProductObject {
	return &loansv1.LoanProductObject{
		Id:                   m.GetID(),
		OrganizationId:       m.OrganizationID,
		Name:                 m.Name,
		Code:                 m.Code,
		Description:          m.Description,
		ProductType:          loansv1.LoanProductType(m.ProductType),
		CurrencyCode:         m.CurrencyCode,
		InterestMethod:       loansv1.InterestMethod(m.InterestMethod),
		RepaymentFrequency:   loansv1.RepaymentFrequency(m.RepaymentFrequency),
		MinAmount:            MinorUnitsToMoney(m.MinAmount, m.CurrencyCode),
		MaxAmount:            MinorUnitsToMoney(m.MaxAmount, m.CurrencyCode),
		MinTermDays:          m.MinTermDays,
		MaxTermDays:          m.MaxTermDays,
		AnnualInterestRate:   BasisPointsToString(m.AnnualInterestRate),
		ProcessingFeePercent: BasisPointsToString(m.ProcessingFeePercent),
		InsuranceFeePercent:  BasisPointsToString(m.InsuranceFeePercent),
		LatePenaltyRate:      BasisPointsToString(m.LatePenaltyRate),
		GracePeriodDays:      m.GracePeriodDays,
		FeeStructure:         m.FeeStructure.ToProtoStruct(),
		EligibilityCriteria:  m.EligibilityCriteria.ToProtoStruct(),
		State:                commonv1.STATE(m.State),
		Properties:           m.Properties.ToProtoStruct(),
		RequiredForms:        RequiredFormsToAPI(m.RequiredForms),
	}
}

func LoanProductFromAPI(ctx context.Context, obj *loansv1.LoanProductObject) *LoanProduct {
	if obj == nil {
		return nil
	}

	lpMin, _ := MoneyToMinorUnits(obj.GetMinAmount())
	lpMax, _ := MoneyToMinorUnits(obj.GetMaxAmount())

	model := &LoanProduct{
		OrganizationID:       obj.GetOrganizationId(),
		Name:                 obj.GetName(),
		Code:                 obj.GetCode(),
		Description:          obj.GetDescription(),
		ProductType:          int32(obj.GetProductType()),
		CurrencyCode:         obj.GetCurrencyCode(),
		InterestMethod:       int32(obj.GetInterestMethod()),
		RepaymentFrequency:   int32(obj.GetRepaymentFrequency()),
		MinAmount:            lpMin,
		MaxAmount:            lpMax,
		MinTermDays:          obj.GetMinTermDays(),
		MaxTermDays:          obj.GetMaxTermDays(),
		AnnualInterestRate:   StringToBasisPoints(obj.GetAnnualInterestRate()),
		ProcessingFeePercent: StringToBasisPoints(obj.GetProcessingFeePercent()),
		InsuranceFeePercent:  StringToBasisPoints(obj.GetInsuranceFeePercent()),
		LatePenaltyRate:      StringToBasisPoints(obj.GetLatePenaltyRate()),
		GracePeriodDays:      obj.GetGracePeriodDays(),
		RequiredForms:        RequiredFormsFromAPI(obj.GetRequiredForms()),
		State:                int32(obj.GetState()),
	}

	if obj.GetFeeStructure() != nil {
		model.FeeStructure = (&data.JSONMap{}).FromProtoStruct(obj.GetFeeStructure())
	}
	if obj.GetEligibilityCriteria() != nil {
		model.EligibilityCriteria = (&data.JSONMap{}).FromProtoStruct(obj.GetEligibilityCriteria())
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

// ---------------------------------------------------------------------------
// Repayment
// ---------------------------------------------------------------------------

type Repayment struct {
	data.BaseModel
	LoanAccountID       string `gorm:"type:varchar(50);index:idx_rep_loan"`
	Amount              int64
	CurrencyCode        string `gorm:"type:varchar(3)"`
	Status              int32
	PaymentReference    string `gorm:"type:varchar(100)"`
	LedgerTransactionID string `gorm:"type:varchar(50)"`
	Channel             string `gorm:"type:varchar(50)"`
	PayerReference      string `gorm:"type:varchar(100)"`
	PrincipalApplied    int64
	InterestApplied     int64
	FeesApplied         int64
	PenaltiesApplied    int64
	ExcessAmount        int64
	IdempotencyKey      string `gorm:"type:varchar(100);uniqueIndex:uq_rep_idem"`
	Properties          data.JSONMap
}

func (m *Repayment) TableName() string { return "repayments" }

func (m *Repayment) ToAPI() *loansv1.RepaymentObject {
	cc := m.CurrencyCode
	return &loansv1.RepaymentObject{
		Id:                  m.GetID(),
		LoanAccountId:       m.LoanAccountID,
		Amount:              MinorUnitsToMoney(m.Amount, cc),
		Status:              loansv1.RepaymentStatus(m.Status),
		PaymentReference:    m.PaymentReference,
		LedgerTransactionId: m.LedgerTransactionID,
		ReceivedAt:          TimeToString(&m.CreatedAt),
		Channel:             m.Channel,
		PayerReference:      m.PayerReference,
		PrincipalApplied:    MinorUnitsToMoney(m.PrincipalApplied, cc),
		InterestApplied:     MinorUnitsToMoney(m.InterestApplied, cc),
		FeesApplied:         MinorUnitsToMoney(m.FeesApplied, cc),
		PenaltiesApplied:    MinorUnitsToMoney(m.PenaltiesApplied, cc),
		ExcessAmount:        MinorUnitsToMoney(m.ExcessAmount, cc),
		IdempotencyKey:      m.IdempotencyKey,
		Properties:          m.Properties.ToProtoStruct(),
	}
}

func RepaymentFromAPI(ctx context.Context, obj *loansv1.RepaymentObject) *Repayment {
	if obj == nil {
		return nil
	}

	repAmount, repCurrency := MoneyToMinorUnits(obj.GetAmount())
	repPrincipal, _ := MoneyToMinorUnits(obj.GetPrincipalApplied())
	repInterest, _ := MoneyToMinorUnits(obj.GetInterestApplied())
	repFees, _ := MoneyToMinorUnits(obj.GetFeesApplied())
	repPenalties, _ := MoneyToMinorUnits(obj.GetPenaltiesApplied())
	repExcess, _ := MoneyToMinorUnits(obj.GetExcessAmount())

	model := &Repayment{
		LoanAccountID:       obj.GetLoanAccountId(),
		Amount:              repAmount,
		CurrencyCode:        repCurrency,
		Status:              int32(obj.GetStatus()),
		PaymentReference:    obj.GetPaymentReference(),
		LedgerTransactionID: obj.GetLedgerTransactionId(),
		Channel:             obj.GetChannel(),
		PayerReference:      obj.GetPayerReference(),
		PrincipalApplied:    repPrincipal,
		InterestApplied:     repInterest,
		FeesApplied:         repFees,
		PenaltiesApplied:    repPenalties,
		ExcessAmount:        repExcess,
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

// ---------------------------------------------------------------------------
// Penalty
// ---------------------------------------------------------------------------

type Penalty struct {
	data.BaseModel
	LoanAccountID       string `gorm:"type:varchar(50);index:idx_pen_loan"`
	PenaltyType         int32
	Amount              int64
	CurrencyCode        string `gorm:"type:varchar(3)"`
	Reason              string `gorm:"type:text"`
	IsWaived            bool
	WaivedBy            string `gorm:"type:varchar(50)"`
	WaivedReason        string `gorm:"type:text"`
	LedgerTransactionID string `gorm:"type:varchar(50)"`
	ScheduleEntryID     string `gorm:"type:varchar(50)"`
	Properties          data.JSONMap
}

func (m *Penalty) TableName() string { return "penalties" }

func (m *Penalty) ToAPI() *loansv1.PenaltyObject {
	return &loansv1.PenaltyObject{
		Id:                  m.GetID(),
		LoanAccountId:       m.LoanAccountID,
		PenaltyType:         loansv1.PenaltyType(m.PenaltyType),
		Amount:              MinorUnitsToMoney(m.Amount, m.CurrencyCode),
		Reason:              m.Reason,
		IsWaived:            m.IsWaived,
		WaivedBy:            m.WaivedBy,
		WaivedReason:        m.WaivedReason,
		LedgerTransactionId: m.LedgerTransactionID,
		AppliedAt:           TimeToString(&m.CreatedAt),
		ScheduleEntryId:     m.ScheduleEntryID,
		Properties:          m.Properties.ToProtoStruct(),
	}
}

func PenaltyFromAPI(ctx context.Context, obj *loansv1.PenaltyObject) *Penalty {
	if obj == nil {
		return nil
	}

	penAmount, penCurrency := MoneyToMinorUnits(obj.GetAmount())

	model := &Penalty{
		LoanAccountID:       obj.GetLoanAccountId(),
		PenaltyType:         int32(obj.GetPenaltyType()),
		Amount:              penAmount,
		CurrencyCode:        penCurrency,
		Reason:              obj.GetReason(),
		IsWaived:            obj.GetIsWaived(),
		WaivedBy:            obj.GetWaivedBy(),
		WaivedReason:        obj.GetWaivedReason(),
		LedgerTransactionID: obj.GetLedgerTransactionId(),
		ScheduleEntryID:     obj.GetScheduleEntryId(),
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

// ---------------------------------------------------------------------------
// LoanRestructure
// ---------------------------------------------------------------------------

type LoanRestructure struct {
	data.BaseModel
	LoanAccountID   string `gorm:"type:varchar(50);index:idx_lr_loan"`
	RestructureType int32
	RequestedBy     string `gorm:"type:varchar(50)"`
	ApprovedBy      string `gorm:"type:varchar(50)"`
	Reason          string `gorm:"type:text"`
	CurrencyCode    string `gorm:"type:varchar(3)"`
	OldInterestRate int64
	NewInterestRate int64
	OldTermDays     int32
	NewTermDays     int32
	WaivedAmount    int64
	OldScheduleID   string `gorm:"type:varchar(50)"`
	NewScheduleID   string `gorm:"type:varchar(50)"`
	State           int32
	Properties      data.JSONMap
}

func (m *LoanRestructure) TableName() string { return "loan_restructures" }

func (m *LoanRestructure) ToAPI() *loansv1.LoanRestructureObject {
	return &loansv1.LoanRestructureObject{
		Id:              m.GetID(),
		LoanAccountId:   m.LoanAccountID,
		RestructureType: loansv1.RestructureType(m.RestructureType),
		RequestedBy:     m.RequestedBy,
		ApprovedBy:      m.ApprovedBy,
		Reason:          m.Reason,
		OldInterestRate: BasisPointsToString(m.OldInterestRate),
		NewInterestRate: BasisPointsToString(m.NewInterestRate),
		OldTermDays:     m.OldTermDays,
		NewTermDays:     m.NewTermDays,
		WaivedAmount:    MinorUnitsToMoney(m.WaivedAmount, m.CurrencyCode),
		OldScheduleId:   m.OldScheduleID,
		NewScheduleId:   m.NewScheduleID,
		State:           commonv1.STATE(m.State),
		Properties:      m.Properties.ToProtoStruct(),
	}
}

func LoanRestructureFromAPI(ctx context.Context, obj *loansv1.LoanRestructureObject) *LoanRestructure {
	if obj == nil {
		return nil
	}

	model := &LoanRestructure{
		LoanAccountID:   obj.GetLoanAccountId(),
		RestructureType: int32(obj.GetRestructureType()),
		RequestedBy:     obj.GetRequestedBy(),
		ApprovedBy:      obj.GetApprovedBy(),
		Reason:          obj.GetReason(),
		OldInterestRate: StringToBasisPoints(obj.GetOldInterestRate()),
		NewInterestRate: StringToBasisPoints(obj.GetNewInterestRate()),
		OldTermDays:     obj.GetOldTermDays(),
		NewTermDays:     obj.GetNewTermDays(),
		WaivedAmount:    func() int64 { v, _ := MoneyToMinorUnits(obj.GetWaivedAmount()); return v }(),
		OldScheduleID:   obj.GetOldScheduleId(),
		NewScheduleID:   obj.GetNewScheduleId(),
		State:           int32(obj.GetState()),
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

// ---------------------------------------------------------------------------
// LoanStatusChange (internal audit)
// ---------------------------------------------------------------------------

type LoanStatusChange struct {
	data.BaseModel
	LoanAccountID string `gorm:"type:varchar(50);index:idx_lsc_loan"`
	FromStatus    int32
	ToStatus      int32
	ChangedBy     string `gorm:"type:varchar(50)"`
	Reason        string `gorm:"type:text"`
}

func (m *LoanStatusChange) TableName() string { return "loan_status_changes" }

func (m *LoanStatusChange) ToAPI() *loansv1.LoanStatusChangeObject {
	return &loansv1.LoanStatusChangeObject{
		Id:            m.GetID(),
		LoanAccountId: m.LoanAccountID,
		FromStatus:    m.FromStatus,
		ToStatus:      m.ToStatus,
		ChangedBy:     m.ChangedBy,
		Reason:        m.Reason,
		ChangedAt:     TimeToString(&m.CreatedAt),
	}
}

// ---------------------------------------------------------------------------
// Disbursement
// ---------------------------------------------------------------------------

type Disbursement struct {
	data.BaseModel
	LoanAccountID       string `gorm:"type:varchar(50);index:idx_disb_loan"`
	Amount              int64
	CurrencyCode        string `gorm:"type:varchar(3)"`
	Status              int32
	PaymentReference    string `gorm:"type:varchar(100)"`
	LedgerTransactionID string `gorm:"type:varchar(50)"`
	Channel             string `gorm:"type:varchar(50)"`
	RecipientReference  string `gorm:"type:varchar(100)"`
	FailureReason       string `gorm:"type:text"`
	IdempotencyKey      string `gorm:"type:varchar(100);uniqueIndex:uq_disb_idem"`
	Properties          data.JSONMap
}

func (m *Disbursement) TableName() string { return "disbursements" }

func (m *Disbursement) ToAPI() *loansv1.DisbursementObject {
	return &loansv1.DisbursementObject{
		Id:                  m.GetID(),
		LoanAccountId:       m.LoanAccountID,
		Amount:              MinorUnitsToMoney(m.Amount, m.CurrencyCode),
		Status:              loansv1.DisbursementStatus(m.Status),
		PaymentReference:    m.PaymentReference,
		LedgerTransactionId: m.LedgerTransactionID,
		DisbursedAt:         TimeToString(&m.CreatedAt),
		Channel:             m.Channel,
		RecipientReference:  m.RecipientReference,
		FailureReason:       m.FailureReason,
		IdempotencyKey:      m.IdempotencyKey,
		Properties:          m.Properties.ToProtoStruct(),
	}
}

func DisbursementFromAPI(ctx context.Context, obj *loansv1.DisbursementObject) *Disbursement {
	if obj == nil {
		return nil
	}

	disbAmount, disbCurrency := MoneyToMinorUnits(obj.GetAmount())

	model := &Disbursement{
		LoanAccountID:       obj.GetLoanAccountId(),
		Amount:              disbAmount,
		CurrencyCode:        disbCurrency,
		Status:              int32(obj.GetStatus()),
		PaymentReference:    obj.GetPaymentReference(),
		LedgerTransactionID: obj.GetLedgerTransactionId(),
		Channel:             obj.GetChannel(),
		RecipientReference:  obj.GetRecipientReference(),
		FailureReason:       obj.GetFailureReason(),
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

// ---------------------------------------------------------------------------
// Reconciliation
// ---------------------------------------------------------------------------

type Reconciliation struct {
	data.BaseModel
	LoanAccountID      string `gorm:"type:varchar(50);index:idx_rec_loan"`
	PaymentReference   string `gorm:"type:varchar(100)"`
	ExternalReference  string `gorm:"type:varchar(100)"`
	Amount             int64
	CurrencyCode       string `gorm:"type:varchar(3)"`
	Status             int32
	MatchedRepaymentID string `gorm:"type:varchar(50)"`
	Notes              string `gorm:"type:text"`
	ReconciledBy       string `gorm:"type:varchar(50)"`
	Properties         data.JSONMap
}

func (m *Reconciliation) TableName() string { return "reconciliations" }

func (m *Reconciliation) ToAPI() *loansv1.ReconciliationObject {
	return &loansv1.ReconciliationObject{
		Id:                 m.GetID(),
		LoanAccountId:      m.LoanAccountID,
		PaymentReference:   m.PaymentReference,
		ExternalReference:  m.ExternalReference,
		Amount:             MinorUnitsToMoney(m.Amount, m.CurrencyCode),
		Status:             loansv1.ReconciliationStatus(m.Status),
		MatchedRepaymentId: m.MatchedRepaymentID,
		Notes:              m.Notes,
		ReconciledAt:       TimeToString(&m.CreatedAt),
		ReconciledBy:       m.ReconciledBy,
		Properties:         m.Properties.ToProtoStruct(),
	}
}

func ReconciliationFromAPI(ctx context.Context, obj *loansv1.ReconciliationObject) *Reconciliation {
	if obj == nil {
		return nil
	}

	recAmount, recCurrency := MoneyToMinorUnits(obj.GetAmount())

	model := &Reconciliation{
		LoanAccountID:      obj.GetLoanAccountId(),
		PaymentReference:   obj.GetPaymentReference(),
		ExternalReference:  obj.GetExternalReference(),
		Amount:             recAmount,
		CurrencyCode:       recCurrency,
		Status:             int32(obj.GetStatus()),
		MatchedRepaymentID: obj.GetMatchedRepaymentId(),
		Notes:              obj.GetNotes(),
		ReconciledBy:       obj.GetReconciledBy(),
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
