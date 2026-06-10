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
	"errors"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/funding/connectrpc/go/funding/v1/fundingv1connect"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	"connectrpc.com/connect"
	audit "github.com/antinvestor/common/audit"
	"github.com/pitabwire/frame/data"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/funding/service/business"
	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/fundingcompat"
)

const moneyDecimalPlaces = 2

// FundingServer implements the FundingService RPC handler.
// Tenant-level permission checks are handled by the FunctionAccessInterceptor.
type FundingServer struct {
	iaBusiness business.InvestorAccountBusiness
	faBusiness business.FundingAllocationBusiness

	fundingv1connect.UnimplementedFundingServiceHandler
}

func NewFundingServer(
	iaBusiness business.InvestorAccountBusiness,
	faBusiness business.FundingAllocationBusiness,
) fundingv1connect.FundingServiceHandler {
	return &FundingServer{
		iaBusiness: iaBusiness,
		faBusiness: faBusiness,
	}
}

// --- InvestorAccount RPCs ---

func (s *FundingServer) InvestorAccountSave(
	ctx context.Context,
	req *connect.Request[fundingv1.InvestorAccountSaveRequest],
) (*connect.Response[fundingv1.InvestorAccountSaveResponse], error) {
	account := investorAccountFromAPI(ctx, req.Msg.GetData())

	result, err := s.iaBusiness.Create(ctx, account)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	audit.WithResource(ctx, audit.ResourceInvestorAccount, result.GetID())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "investor_id", result.InvestorID)
	return connect.NewResponse(&fundingv1.InvestorAccountSaveResponse{
		Data: investorAccountToAPI(result),
	}), nil
}

func (s *FundingServer) InvestorAccountGet(
	ctx context.Context,
	req *connect.Request[fundingv1.InvestorAccountGetRequest],
) (*connect.Response[fundingv1.InvestorAccountGetResponse], error) {
	result, err := s.iaBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	return connect.NewResponse(&fundingv1.InvestorAccountGetResponse{
		Data: investorAccountToAPI(result),
	}), nil
}

func (s *FundingServer) InvestorAccountSearch(
	ctx context.Context,
	req *connect.Request[fundingv1.InvestorAccountSearchRequest],
	stream *connect.ServerStream[fundingv1.InvestorAccountSearchResponse],
) error {
	investorID := req.Msg.GetInvestorId()
	if investorID == "" {
		return apperrors.CleanErr(apperrors.ErrMissingRequiredData.Extend("investor_id is required"))
	}

	accounts, err := s.iaBusiness.GetByInvestorID(ctx, investorID)
	if err != nil {
		return apperrors.CleanErr(err)
	}

	// Filter by currency if specified.
	currencyCode := req.Msg.GetCurrencyCode()
	var apiResults []*fundingv1.InvestorAccountObject
	for _, acct := range accounts {
		if currencyCode != "" && acct.Currency != currencyCode {
			continue
		}
		apiResults = append(apiResults, investorAccountToAPI(acct))
	}

	return stream.Send(&fundingv1.InvestorAccountSearchResponse{Data: apiResults})
}

// --- Deposit / Withdraw RPCs ---

//nolint:dupl // deposit and withdraw RPCs mirror each other over distinct proto types
func (s *FundingServer) InvestorDeposit(
	ctx context.Context,
	req *connect.Request[fundingv1.InvestorDepositRequest],
) (*connect.Response[fundingv1.InvestorDepositResponse], error) {
	idemKey := req.Header().Get("Idempotency-Key")
	if idemKey == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("Idempotency-Key header required"))
	}

	amount := moneyx.ToSmallestUnit(req.Msg.GetAmount(), moneyDecimalPlaces)

	err := s.iaBusiness.Deposit(ctx, req.Msg.GetAccountId(), amount, idemKey)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	updated, err := s.iaBusiness.Get(ctx, req.Msg.GetAccountId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	audit.WithResource(ctx, audit.ResourceInvestorAccount, req.Msg.GetAccountId())
	audit.WithAction(ctx, "deposit")
	return connect.NewResponse(&fundingv1.InvestorDepositResponse{
		Data: investorAccountToAPI(updated),
	}), nil
}

//nolint:dupl // deposit and withdraw RPCs mirror each other over distinct proto types
func (s *FundingServer) InvestorWithdraw(
	ctx context.Context,
	req *connect.Request[fundingv1.InvestorWithdrawRequest],
) (*connect.Response[fundingv1.InvestorWithdrawResponse], error) {
	idemKey := req.Header().Get("Idempotency-Key")
	if idemKey == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("Idempotency-Key header required"))
	}

	amount := moneyx.ToSmallestUnit(req.Msg.GetAmount(), moneyDecimalPlaces)

	err := s.iaBusiness.Withdraw(ctx, req.Msg.GetAccountId(), amount, idemKey)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	updated, err := s.iaBusiness.Get(ctx, req.Msg.GetAccountId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	audit.WithResource(ctx, audit.ResourceInvestorAccount, req.Msg.GetAccountId())
	audit.WithAction(ctx, "withdraw")
	return connect.NewResponse(&fundingv1.InvestorWithdrawResponse{
		Data: investorAccountToAPI(updated),
	}), nil
}

// --- Funding Allocation RPCs ---

func (s *FundingServer) FundLoan(
	ctx context.Context,
	req *connect.Request[fundingv1.FundLoanRequest],
) (*connect.Response[fundingv1.FundLoanResponse], error) {
	loanRequestID := fundingcompat.LoanRequestIDFromFundLoanRequest(req.Msg)
	result, err := s.faBusiness.SourceForRequest(ctx, loanRequestID)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	audit.WithResource(ctx, audit.ResourceFundingAllocation, loanRequestID)
	audit.WithAction(ctx, "fund")
	return connect.NewResponse(fundLoanResultToAPI(result)), nil
}

func (s *FundingServer) AbsorbLoss(
	ctx context.Context,
	req *connect.Request[fundingv1.AbsorbLossRequest],
) (*connect.Response[fundingv1.AbsorbLossResponse], error) {
	amount := moneyx.ToSmallestUnit(req.Msg.GetAmount(), moneyDecimalPlaces)

	loanRequestID := fundingcompat.LoanRequestIDFromAbsorbLossRequest(req.Msg)
	err := s.faBusiness.AbsorbLoss(ctx, loanRequestID, amount)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	audit.WithResource(ctx, audit.ResourceFundingAllocation, loanRequestID)
	audit.WithAction(ctx, "absorb_loss")
	return connect.NewResponse(&fundingv1.AbsorbLossResponse{
		Absorbed: req.Msg.GetAmount(),
	}), nil
}

// --- Conversion helpers ---

// investorAccountToAPI converts a model InvestorAccount to the proto InvestorAccountObject.
func investorAccountToAPI(m *models.InvestorAccount) *fundingv1.InvestorAccountObject {
	return &fundingv1.InvestorAccountObject{
		Id:                m.GetID(),
		InvestorId:        m.InvestorID,
		AccountName:       m.AccountName,
		AvailableBalance:  moneyx.FromSmallestUnit(m.Currency, m.AvailableBalance, moneyDecimalPlaces),
		ReservedBalance:   moneyx.FromSmallestUnit(m.Currency, m.ReservedBalance, moneyDecimalPlaces),
		TotalDeployed:     moneyx.FromSmallestUnit(m.Currency, m.TotalDeployed, moneyDecimalPlaces),
		TotalReturned:     moneyx.FromSmallestUnit(m.Currency, m.TotalReturned, moneyDecimalPlaces),
		MaxExposure:       moneyx.FromSmallestUnit(m.Currency, m.MaxExposure, moneyDecimalPlaces),
		MinInterestRate:   models.BasisPointsToString(m.MinInterestRate),
		AllowedProducts:   m.AllowedProducts.ToProtoStruct(),
		AllowedRegions:    m.AllowedRegions.ToProtoStruct(),
		GroupAffiliations: m.GroupAffiliations.ToProtoStruct(),
		State:             commonv1.STATE(m.State),
		Properties:        m.Properties.ToProtoStruct(),
	}
}

// investorAccountFromAPI converts a proto InvestorAccountObject to a model InvestorAccount.
func investorAccountFromAPI(ctx context.Context, obj *fundingv1.InvestorAccountObject) *models.InvestorAccount {
	if obj == nil {
		return nil
	}

	availBalance := moneyx.ToSmallestUnit(obj.GetAvailableBalance(), moneyDecimalPlaces)
	currency := obj.GetAvailableBalance().GetCurrencyCode()
	maxExposure := moneyx.ToSmallestUnit(obj.GetMaxExposure(), moneyDecimalPlaces)

	model := &models.InvestorAccount{
		InvestorID:       obj.GetInvestorId(),
		AccountName:      obj.GetAccountName(),
		Currency:         currency,
		AvailableBalance: availBalance,
		MaxExposure:      maxExposure,
		MinInterestRate:  models.StringToBasisPoints(obj.GetMinInterestRate()),
		State:            int32(obj.GetState()),
	}

	if obj.GetAllowedProducts() != nil {
		model.AllowedProducts = (&data.JSONMap{}).FromProtoStruct(obj.GetAllowedProducts())
	}
	if obj.GetAllowedRegions() != nil {
		model.AllowedRegions = (&data.JSONMap{}).FromProtoStruct(obj.GetAllowedRegions())
	}
	if obj.GetGroupAffiliations() != nil {
		model.GroupAffiliations = (&data.JSONMap{}).FromProtoStruct(obj.GetGroupAffiliations())
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

// fundLoanResultToAPI converts the SourceForRequest result map to a FundLoanResponse.
func fundLoanResultToAPI(result map[string]interface{}) *fundingv1.FundLoanResponse {
	resp := &fundingv1.FundLoanResponse{}
	currency, _ := result["currency"].(string)

	if fullyFunded, ok := result["fully_funded"].(bool); ok {
		resp.FullyFunded = fullyFunded
	}

	if totalAllocated, ok := result["total_allocated"].(int64); ok {
		resp.TotalAllocated = moneyx.FromSmallestUnit(currency, totalAllocated, moneyDecimalPlaces)
	}

	if deficit, ok := result["deficit"].(int64); ok {
		resp.Deficit = moneyx.FromSmallestUnit(currency, deficit, moneyDecimalPlaces)
	}

	resp.Allocations = fundingAllocationsToAPI(result["allocations"])

	return resp
}

func fundingAllocationsToAPI(value interface{}) []*fundingv1.FundingAllocationObject {
	allocations, ok := value.([]map[string]interface{})
	if !ok {
		return nil
	}

	apiAllocations := make([]*fundingv1.FundingAllocationObject, 0, len(allocations))
	for _, allocation := range allocations {
		apiAllocations = append(apiAllocations, fundingAllocationToAPI(allocation))
	}

	return apiAllocations
}

func fundingAllocationToAPI(allocation map[string]interface{}) *fundingv1.FundingAllocationObject {
	obj := &fundingv1.FundingAllocationObject{}
	if id, found := allocation["id"].(string); found {
		obj.Id = id
	}
	if loanRequestID, found := allocation["loan_request_id"].(string); found {
		fundingcompat.SetAllocationLoanRequestID(obj, loanRequestID)
	}
	if sourceID, found := allocation["source_id"].(string); found {
		obj.SourceId = sourceID
	}
	if sourceType, found := allocation["source_type"].(string); found {
		obj.SourceType = sourceType
	}
	if trancheLevel, found := allocation["tranche_level"].(int32); found {
		obj.TrancheLevel = trancheLevel
	}
	if amount, found := allocation["amount"].(int64); found {
		currency, _ := allocation["currency"].(string)
		obj.Amount = moneyx.FromSmallestUnit(currency, amount, moneyDecimalPlaces)
	}

	return obj
}
