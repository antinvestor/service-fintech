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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/funding/connectrpc/go/funding/v1/fundingv1connect"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	"connectrpc.com/connect"
	audit "github.com/antinvestor/common/audit"
	"github.com/pitabwire/frame/v2/data"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/funding/service/business"
	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/fundingcompat"
)

// idempotencyHeader carries the caller's replay key for money movements.
const idempotencyHeader = "Idempotency-Key"

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
	account, err := investorAccountFromAPI(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	result, err := s.iaBusiness.Save(ctx, account)
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
	accounts, err := s.iaBusiness.Search(ctx, req.Msg)
	if err != nil {
		return apperrors.CleanErr(err)
	}

	apiResults := make([]*fundingv1.InvestorAccountObject, 0, len(accounts))
	for _, acct := range accounts {
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
	idemKey := req.Header().Get(idempotencyHeader)
	if idemKey == "" {
		return nil, apperrors.CleanErr(business.ErrIdempotencyKeyRequired)
	}

	if err := s.iaBusiness.Deposit(ctx, req.Msg.GetAccountId(), req.Msg.GetAmount(), idemKey); err != nil {
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
	idemKey := req.Header().Get(idempotencyHeader)
	if idemKey == "" {
		return nil, apperrors.CleanErr(business.ErrIdempotencyKeyRequired)
	}

	if err := s.iaBusiness.Withdraw(ctx, req.Msg.GetAccountId(), req.Msg.GetAmount(), idemKey); err != nil {
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
	currency := req.Msg.GetAmount().GetCurrencyCode()
	amount := moneyx.ToSmallestUnit(req.Msg.GetAmount(), moneyx.Decimals(currency))

	loanRequestID := fundingcompat.LoanRequestIDFromAbsorbLossRequest(req.Msg)
	result, err := s.faBusiness.AbsorbLoss(ctx, loanRequestID, amount)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	if result.Currency == "" {
		result.Currency = currency
	}

	audit.WithResource(ctx, audit.ResourceFundingAllocation, loanRequestID)
	audit.WithAction(ctx, "absorb_loss")
	return connect.NewResponse(&fundingv1.AbsorbLossResponse{
		Absorbed:      moneyx.FromMinorUnitsByCurrency(result.Currency, result.Absorbed),
		Unrecoverable: moneyx.FromMinorUnitsByCurrency(result.Currency, result.Unrecoverable),
	}), nil
}

// --- Conversion helpers ---

// investorAccountToAPI converts a model InvestorAccount to the proto InvestorAccountObject.
func investorAccountToAPI(m *models.InvestorAccount) *fundingv1.InvestorAccountObject {
	return &fundingv1.InvestorAccountObject{
		Id:                m.GetID(),
		InvestorId:        m.InvestorID,
		AccountName:       m.AccountName,
		AvailableBalance:  models.MinorUnitsToMoney(m.AvailableBalance, m.Currency),
		ReservedBalance:   models.MinorUnitsToMoney(m.ReservedBalance, m.Currency),
		TotalDeployed:     models.MinorUnitsToMoney(m.TotalDeployed, m.Currency),
		TotalReturned:     models.MinorUnitsToMoney(m.TotalReturned, m.Currency),
		MaxExposure:       models.MinorUnitsToMoney(m.MaxExposure, m.Currency),
		MinInterestRate:   models.BasisPointsToString(m.MinInterestRate),
		AllowedProducts:   m.AllowedProducts.ToProtoStruct(),
		AllowedRegions:    m.AllowedRegions.ToProtoStruct(),
		GroupAffiliations: m.GroupAffiliations.ToProtoStruct(),
		State:             commonv1.STATE(m.State),
		Properties:        m.Properties.ToProtoStruct(),
	}
}

// investorAccountFromAPI converts a proto InvestorAccountObject to a model
// InvestorAccount. Balances are deliberately not read: available_balance
// contributes only its currency_code, which is how the contract carries the
// account's denomination. Capital moves through Deposit and Withdraw alone.
// A min_interest_rate that is not a decimal percentage is rejected rather
// than silently stored as "no minimum".
func investorAccountFromAPI(
	ctx context.Context,
	obj *fundingv1.InvestorAccountObject,
) (*models.InvestorAccount, error) {
	if obj == nil {
		return nil, business.ErrMissingInvestorContext
	}

	currency := obj.GetAvailableBalance().GetCurrencyCode()
	if currency == "" {
		currency = obj.GetMaxExposure().GetCurrencyCode()
	}
	maxExposure, _ := models.MoneyToMinorUnits(obj.GetMaxExposure())
	minRate, err := models.ParseRate(obj.GetMinInterestRate())
	if err != nil {
		return nil, business.ErrInvalidInterestRate.Extend(err.Error())
	}

	model := &models.InvestorAccount{
		InvestorID:      obj.GetInvestorId(),
		AccountName:     obj.GetAccountName(),
		Currency:        currency,
		MaxExposure:     maxExposure,
		MinInterestRate: minRate,
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

	return model, nil
}

// fundLoanResultToAPI renders the allocation result on the wire.
func fundLoanResultToAPI(result *business.AllocationResult) *fundingv1.FundLoanResponse {
	resp := &fundingv1.FundLoanResponse{
		FullyFunded:    result.FullyFunded,
		TotalAllocated: models.MinorUnitsToMoney(result.TotalAllocated, result.Currency),
		Deficit:        models.MinorUnitsToMoney(result.Deficit, result.Currency),
	}

	resp.Allocations = make([]*fundingv1.FundingAllocationObject, 0, len(result.Allocations))
	for _, allocation := range result.Allocations {
		obj := &fundingv1.FundingAllocationObject{
			Id:           allocation.ID,
			SourceId:     allocation.SourceID,
			SourceType:   allocation.SourceType,
			TrancheLevel: allocation.TrancheLevel,
			Amount:       models.MinorUnitsToMoney(allocation.Amount, allocation.Currency),
		}
		fundingcompat.SetAllocationLoanRequestID(obj, allocation.LoanRequestID)
		resp.Allocations = append(resp.Allocations, obj)
	}

	return resp
}
