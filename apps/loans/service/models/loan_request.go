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
	"encoding/json"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/frame/v2/data"
)

// ---------------------------------------------------------------------------
// LoanRequest
// ---------------------------------------------------------------------------

type LoanRequest struct {
	data.BaseModel
	ProductID         string `gorm:"type:varchar(50);index:idx_lr_product"`
	ClientID          string `gorm:"type:varchar(50);index:idx_lr_client"`
	AgentID           string `gorm:"type:varchar(50);index:idx_lr_agent"`
	BranchID          string `gorm:"type:varchar(50);index:idx_lr_branch"`
	OrganizationID    string `gorm:"type:varchar(50);index:idx_lr_organization"`
	Status            int32  `gorm:"index:idx_lr_status"`
	RequestedAmount   int64
	ApprovedAmount    int64
	RequestedTermDays int32
	ApprovedTermDays  int32
	InterestRate      int64  // basis points
	CurrencyCode      string `gorm:"type:varchar(3)"`
	Purpose           string `gorm:"type:text"`
	RejectionReason   string `gorm:"type:text"`
	OfferExpiresAt    *time.Time
	SubmittedAt       *time.Time
	DecidedAt         *time.Time
	LoanAccountID     string `gorm:"type:varchar(50);index:idx_lr_loan"`
	SourceService     string `gorm:"type:varchar(50);index:idx_lr_source"`
	SourceRequestID   string `gorm:"type:varchar(50)"`
	IdempotencyKey    string `gorm:"type:varchar(255);uniqueIndex:uq_lr_idempotency"`
	Properties        data.JSONMap
}

func (m *LoanRequest) TableName() string { return "loan_requests" }

func (m *LoanRequest) ToAPI() *loansv1.LoanRequestObject {
	return &loansv1.LoanRequestObject{
		Id:                m.GetID(),
		ProductId:         m.ProductID,
		ClientId:          m.ClientID,
		AgentId:           m.AgentID,
		BranchId:          m.BranchID,
		OrganizationId:    m.OrganizationID,
		Status:            loansv1.LoanRequestStatus(m.Status),
		RequestedAmount:   MinorUnitsToMoney(m.RequestedAmount, m.CurrencyCode),
		ApprovedAmount:    MinorUnitsToMoney(m.ApprovedAmount, m.CurrencyCode),
		RequestedTermDays: m.RequestedTermDays,
		ApprovedTermDays:  m.ApprovedTermDays,
		InterestRate:      BasisPointsToString(m.InterestRate),
		CurrencyCode:      m.CurrencyCode,
		Purpose:           m.Purpose,
		RejectionReason:   m.RejectionReason,
		OfferExpiresAt:    TimeToString(m.OfferExpiresAt),
		SubmittedAt:       TimeToString(m.SubmittedAt),
		DecidedAt:         TimeToString(m.DecidedAt),
		LoanAccountId:     m.LoanAccountID,
		SourceService:     m.SourceService,
		SourceRequestId:   m.SourceRequestID,
		IdempotencyKey:    m.IdempotencyKey,
		Properties:        m.Properties.ToProtoStruct(),
	}
}

func LoanRequestFromAPI(ctx context.Context, obj *loansv1.LoanRequestObject) *LoanRequest {
	if obj == nil {
		return nil
	}

	reqAmt, _ := MoneyToMinorUnits(obj.GetRequestedAmount())
	apvAmt, _ := MoneyToMinorUnits(obj.GetApprovedAmount())

	model := &LoanRequest{
		ProductID:         obj.GetProductId(),
		ClientID:          obj.GetClientId(),
		AgentID:           obj.GetAgentId(),
		BranchID:          obj.GetBranchId(),
		OrganizationID:    obj.GetOrganizationId(),
		Status:            int32(obj.GetStatus()),
		RequestedAmount:   reqAmt,
		ApprovedAmount:    apvAmt,
		RequestedTermDays: obj.GetRequestedTermDays(),
		ApprovedTermDays:  obj.GetApprovedTermDays(),
		InterestRate:      StringToBasisPoints(obj.GetInterestRate()),
		CurrencyCode:      obj.GetCurrencyCode(),
		Purpose:           obj.GetPurpose(),
		RejectionReason:   obj.GetRejectionReason(),
		OfferExpiresAt:    StringToTime(obj.GetOfferExpiresAt()),
		SubmittedAt:       StringToTime(obj.GetSubmittedAt()),
		DecidedAt:         StringToTime(obj.GetDecidedAt()),
		LoanAccountID:     obj.GetLoanAccountId(),
		SourceService:     obj.GetSourceService(),
		SourceRequestID:   obj.GetSourceRequestId(),
		IdempotencyKey:    obj.GetIdempotencyKey(),
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
// ClientProductAccess
// ---------------------------------------------------------------------------

type ClientProductAccess struct {
	data.BaseModel
	ClientID  string `gorm:"type:varchar(50);index:idx_cpa_client;uniqueIndex:uq_cpa_client_product"`
	ProductID string `gorm:"type:varchar(50);index:idx_cpa_product;uniqueIndex:uq_cpa_client_product"`
	GrantedBy string `gorm:"type:varchar(50)"`
	State     int32
}

func (m *ClientProductAccess) TableName() string { return "client_product_access" }

func (m *ClientProductAccess) ToAPI() *loansv1.ClientProductAccessObject {
	return &loansv1.ClientProductAccessObject{
		Id:        m.GetID(),
		ClientId:  m.ClientID,
		ProductId: m.ProductID,
		GrantedBy: m.GrantedBy,
		State:     commonv1.STATE(m.State),
	}
}

func ClientProductAccessFromAPI(ctx context.Context, obj *loansv1.ClientProductAccessObject) *ClientProductAccess {
	if obj == nil {
		return nil
	}

	model := &ClientProductAccess{
		ClientID:  obj.GetClientId(),
		ProductID: obj.GetProductId(),
		GrantedBy: obj.GetGrantedBy(),
		State:     int32(obj.GetState()),
	}

	model.GenID(ctx)
	if model.ValidXID(obj.GetId()) {
		model.ID = obj.GetId()
	}

	return model
}

// ---------------------------------------------------------------------------
// LoanProduct RequiredForms helper
// ---------------------------------------------------------------------------

// ProductFormRequirement mirrors the proto ProductFormRequirement for JSON storage.
type ProductFormRequirement struct {
	TemplateID  string `json:"template_id"`
	Stage       string `json:"stage"`
	Required    bool   `json:"required"`
	Order       int32  `json:"order"`
	Description string `json:"description"`
}

// RequiredFormsToAPI converts the RequiredForms JSONMap to proto messages.
func RequiredFormsToAPI(jm data.JSONMap) []*loansv1.ProductFormRequirement {
	if jm == nil {
		return nil
	}

	raw, ok := jm["forms"]
	if !ok {
		return nil
	}

	rawBytes, err := json.Marshal(raw)
	if err != nil {
		return nil
	}

	var reqs []ProductFormRequirement
	if errUnmarshal := json.Unmarshal(rawBytes, &reqs); errUnmarshal != nil {
		return nil
	}

	result := make([]*loansv1.ProductFormRequirement, 0, len(reqs))
	for _, r := range reqs {
		result = append(result, &loansv1.ProductFormRequirement{
			TemplateId:  r.TemplateID,
			Stage:       r.Stage,
			Required:    r.Required,
			Order:       r.Order,
			Description: r.Description,
		})
	}
	return result
}

// RequiredFormsFromAPI converts proto messages to a JSONMap for storage.
func RequiredFormsFromAPI(reqs []*loansv1.ProductFormRequirement) data.JSONMap {
	if len(reqs) == 0 {
		return nil
	}

	forms := make([]ProductFormRequirement, 0, len(reqs))
	for _, r := range reqs {
		forms = append(forms, ProductFormRequirement{
			TemplateID:  r.GetTemplateId(),
			Stage:       r.GetStage(),
			Required:    r.GetRequired(),
			Order:       r.GetOrder(),
			Description: r.GetDescription(),
		})
	}

	return data.JSONMap{"forms": forms}
}
