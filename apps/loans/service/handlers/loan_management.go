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
	"strconv"
	"time"

	"buf.build/gen/go/antinvestor/loans/connectrpc/go/loans/v1/loansv1connect"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"connectrpc.com/connect"
	audit "github.com/antinvestor/common/audit"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/workerpool"

	"github.com/antinvestor/service-fintech/apps/loans/service/business"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// LoanManagementServer implements the LoanManagementService RPC handler.
// Tenant-level permission checks are handled by the FunctionAccessInterceptor.
type LoanManagementServer struct {
	lpBusiness         business.LoanProductBusiness
	lrBusiness         business.LoanRequestBusiness
	laBusiness         business.LoanAccountBusiness
	repBusiness        business.RepaymentBusiness
	scheduleBusiness   business.RepaymentScheduleBusiness
	penaltyBusiness    business.PenaltyBusiness
	restructBusiness   business.LoanRestructureBusiness
	reconBusiness      business.ReconciliationBusiness
	portfolioBusiness  business.PortfolioBusiness
	disbBusiness       business.DisbursementBusiness
	cpaBusiness        business.ClientProductAccessBusiness
	collectionBusiness business.CollectionBusiness
	statusChangeRepo   repository.LoanStatusChangeRepository

	loansv1connect.UnimplementedLoanManagementServiceHandler
}

func NewLoanManagementServer(
	lpBusiness business.LoanProductBusiness,
	lrBusiness business.LoanRequestBusiness,
	laBusiness business.LoanAccountBusiness,
	repBusiness business.RepaymentBusiness,
	scheduleBusiness business.RepaymentScheduleBusiness,
	penaltyBusiness business.PenaltyBusiness,
	restructBusiness business.LoanRestructureBusiness,
	reconBusiness business.ReconciliationBusiness,
	portfolioBusiness business.PortfolioBusiness,
	disbBusiness business.DisbursementBusiness,
	cpaBusiness business.ClientProductAccessBusiness,
	collectionBusiness business.CollectionBusiness,
	statusChangeRepo repository.LoanStatusChangeRepository,
) loansv1connect.LoanManagementServiceHandler {
	return &LoanManagementServer{
		lpBusiness:         lpBusiness,
		lrBusiness:         lrBusiness,
		laBusiness:         laBusiness,
		repBusiness:        repBusiness,
		scheduleBusiness:   scheduleBusiness,
		penaltyBusiness:    penaltyBusiness,
		restructBusiness:   restructBusiness,
		reconBusiness:      reconBusiness,
		portfolioBusiness:  portfolioBusiness,
		disbBusiness:       disbBusiness,
		cpaBusiness:        cpaBusiness,
		collectionBusiness: collectionBusiness,
		statusChangeRepo:   statusChangeRepo,
	}
}

// --- LoanProduct RPCs ---

func (s *LoanManagementServer) LoanProductSave(
	ctx context.Context,
	req *connect.Request[loansv1.LoanProductSaveRequest],
) (*connect.Response[loansv1.LoanProductSaveResponse], error) {
	result, err := s.lpBusiness.Save(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanProduct, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "name", result.GetName())
	return connect.NewResponse(&loansv1.LoanProductSaveResponse{Data: result}), nil
}

func (s *LoanManagementServer) LoanProductGet(
	ctx context.Context,
	req *connect.Request[loansv1.LoanProductGetRequest],
) (*connect.Response[loansv1.LoanProductGetResponse], error) {
	result, err := s.lpBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&loansv1.LoanProductGetResponse{Data: result}), nil
}

func (s *LoanManagementServer) LoanProductSearch(
	ctx context.Context,
	req *connect.Request[loansv1.LoanProductSearchRequest],
	stream *connect.ServerStream[loansv1.LoanProductSearchResponse],
) error {
	err := s.lpBusiness.Search(ctx, req.Msg, func(_ context.Context, batch []*loansv1.LoanProductObject) error {
		return stream.Send(&loansv1.LoanProductSearchResponse{Data: batch})
	})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- LoanRequest RPCs ---

func (s *LoanManagementServer) LoanRequestSave(
	ctx context.Context,
	req *connect.Request[loansv1.LoanRequestSaveRequest],
) (*connect.Response[loansv1.LoanRequestSaveResponse], error) {
	result, err := s.lrBusiness.Save(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanRequest, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	return connect.NewResponse(&loansv1.LoanRequestSaveResponse{Data: result}), nil
}

func (s *LoanManagementServer) LoanRequestGet(
	ctx context.Context,
	req *connect.Request[loansv1.LoanRequestGetRequest],
) (*connect.Response[loansv1.LoanRequestGetResponse], error) {
	result, err := s.lrBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&loansv1.LoanRequestGetResponse{Data: result}), nil
}

func (s *LoanManagementServer) LoanRequestSearch(
	ctx context.Context,
	req *connect.Request[loansv1.LoanRequestSearchRequest],
	stream *connect.ServerStream[loansv1.LoanRequestSearchResponse],
) error {
	err := s.lrBusiness.Search(ctx, req.Msg, func(_ context.Context, batch []*loansv1.LoanRequestObject) error {
		return stream.Send(&loansv1.LoanRequestSearchResponse{Data: batch})
	})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

func (s *LoanManagementServer) LoanRequestApprove(
	ctx context.Context,
	req *connect.Request[loansv1.LoanRequestApproveRequest],
) (*connect.Response[loansv1.LoanRequestApproveResponse], error) {
	result, err := s.lrBusiness.Approve(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanRequest, req.Msg.GetId())
	audit.WithAction(ctx, audit.ActionApprove)
	return connect.NewResponse(&loansv1.LoanRequestApproveResponse{Data: result}), nil
}

func (s *LoanManagementServer) LoanRequestReject(
	ctx context.Context,
	req *connect.Request[loansv1.LoanRequestRejectRequest],
) (*connect.Response[loansv1.LoanRequestRejectResponse], error) {
	result, err := s.lrBusiness.Reject(ctx, req.Msg.GetId(), req.Msg.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanRequest, req.Msg.GetId())
	audit.WithAction(ctx, audit.ActionReject)
	audit.WithDetail(ctx, "reason", req.Msg.GetReason())
	return connect.NewResponse(&loansv1.LoanRequestRejectResponse{Data: result}), nil
}

func (s *LoanManagementServer) LoanRequestCancel(
	ctx context.Context,
	req *connect.Request[loansv1.LoanRequestCancelRequest],
) (*connect.Response[loansv1.LoanRequestCancelResponse], error) {
	result, err := s.lrBusiness.Cancel(ctx, req.Msg.GetId(), req.Msg.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanRequest, req.Msg.GetId())
	audit.WithAction(ctx, audit.ActionCancel)
	audit.WithDetail(ctx, "reason", req.Msg.GetReason())
	return connect.NewResponse(&loansv1.LoanRequestCancelResponse{Data: result}), nil
}

// --- LoanAccount RPCs ---

func (s *LoanManagementServer) LoanAccountCreate(
	ctx context.Context,
	req *connect.Request[loansv1.LoanAccountCreateRequest],
) (*connect.Response[loansv1.LoanAccountCreateResponse], error) {
	result, err := s.laBusiness.Create(ctx, req.Msg.GetLoanRequestId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanAccount, result.GetId())
	audit.WithAction(ctx, audit.ActionCreate)
	audit.WithDetail(ctx, "loan_request_id", req.Msg.GetLoanRequestId())
	return connect.NewResponse(&loansv1.LoanAccountCreateResponse{Data: result}), nil
}

func (s *LoanManagementServer) LoanAccountGet(
	ctx context.Context,
	req *connect.Request[loansv1.LoanAccountGetRequest],
) (*connect.Response[loansv1.LoanAccountGetResponse], error) {
	result, err := s.laBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&loansv1.LoanAccountGetResponse{Data: result}), nil
}

func (s *LoanManagementServer) LoanAccountSearch(
	ctx context.Context,
	req *connect.Request[loansv1.LoanAccountSearchRequest],
	stream *connect.ServerStream[loansv1.LoanAccountSearchResponse],
) error {
	err := s.laBusiness.Search(ctx, req.Msg,
		func(_ context.Context, batch []*loansv1.LoanAccountObject) error {
			return stream.Send(&loansv1.LoanAccountSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

func (s *LoanManagementServer) LoanBalanceGet(
	ctx context.Context,
	req *connect.Request[loansv1.LoanBalanceGetRequest],
) (*connect.Response[loansv1.LoanBalanceGetResponse], error) {
	result, err := s.laBusiness.GetBalance(ctx, req.Msg.GetLoanAccountId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&loansv1.LoanBalanceGetResponse{Data: result}), nil
}

func (s *LoanManagementServer) LoanStatement(
	ctx context.Context,
	req *connect.Request[loansv1.LoanStatementRequest],
) (*connect.Response[loansv1.LoanStatementResponse], error) {
	result, err := s.laBusiness.GetStatement(ctx, req.Msg)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(result), nil
}

// --- Repayment RPCs ---

func (s *LoanManagementServer) RepaymentRecord(
	ctx context.Context,
	req *connect.Request[loansv1.RepaymentRecordRequest],
) (*connect.Response[loansv1.RepaymentRecordResponse], error) {
	result, err := s.repBusiness.Record(ctx, req.Msg)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceRepayment, result.GetId())
	audit.WithAction(ctx, audit.ActionCreate)
	audit.WithDetail(ctx, "loan_account_id", req.Msg.GetLoanAccountId())
	return connect.NewResponse(&loansv1.RepaymentRecordResponse{Data: result}), nil
}

func (s *LoanManagementServer) RepaymentGet(
	ctx context.Context,
	req *connect.Request[loansv1.RepaymentGetRequest],
) (*connect.Response[loansv1.RepaymentGetResponse], error) {
	result, err := s.repBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&loansv1.RepaymentGetResponse{Data: result}), nil
}

func (s *LoanManagementServer) RepaymentSearch(
	ctx context.Context,
	req *connect.Request[loansv1.RepaymentSearchRequest],
	stream *connect.ServerStream[loansv1.RepaymentSearchResponse],
) error {
	err := s.repBusiness.Search(ctx, req.Msg,
		func(_ context.Context, batch []*loansv1.RepaymentObject) error {
			return stream.Send(&loansv1.RepaymentSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- RepaymentSchedule RPCs ---

func (s *LoanManagementServer) RepaymentScheduleGet(
	ctx context.Context,
	req *connect.Request[loansv1.RepaymentScheduleGetRequest],
) (*connect.Response[loansv1.RepaymentScheduleGetResponse], error) {
	result, err := s.scheduleBusiness.GetActive(ctx, req.Msg.GetLoanAccountId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&loansv1.RepaymentScheduleGetResponse{Data: result}), nil
}

// --- Penalty RPCs ---

func (s *LoanManagementServer) PenaltySave(
	ctx context.Context,
	req *connect.Request[loansv1.PenaltySaveRequest],
) (*connect.Response[loansv1.PenaltySaveResponse], error) {
	result, err := s.penaltyBusiness.Save(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourcePenalty, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	return connect.NewResponse(&loansv1.PenaltySaveResponse{Data: result}), nil
}

func (s *LoanManagementServer) PenaltyWaive(
	ctx context.Context,
	req *connect.Request[loansv1.PenaltyWaiveRequest],
) (*connect.Response[loansv1.PenaltyWaiveResponse], error) {
	result, err := s.penaltyBusiness.Waive(ctx, req.Msg.GetId(), req.Msg.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourcePenalty, req.Msg.GetId())
	audit.WithAction(ctx, "waive")
	audit.WithDetail(ctx, "reason", req.Msg.GetReason())
	return connect.NewResponse(&loansv1.PenaltyWaiveResponse{Data: result}), nil
}

func (s *LoanManagementServer) PenaltySearch(
	ctx context.Context,
	req *connect.Request[loansv1.PenaltySearchRequest],
	stream *connect.ServerStream[loansv1.PenaltySearchResponse],
) error {
	err := s.penaltyBusiness.Search(ctx, req.Msg,
		func(_ context.Context, batch []*loansv1.PenaltyObject) error {
			return stream.Send(&loansv1.PenaltySearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- Restructure RPCs ---

func (s *LoanManagementServer) LoanRestructureCreate(
	ctx context.Context,
	req *connect.Request[loansv1.LoanRestructureCreateRequest],
) (*connect.Response[loansv1.LoanRestructureCreateResponse], error) {
	result, err := s.restructBusiness.Create(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanRestructure, result.GetId())
	audit.WithAction(ctx, audit.ActionCreate)
	return connect.NewResponse(&loansv1.LoanRestructureCreateResponse{Data: result}), nil
}

func (s *LoanManagementServer) LoanRestructureApprove(
	ctx context.Context,
	req *connect.Request[loansv1.LoanRestructureApproveRequest],
) (*connect.Response[loansv1.LoanRestructureApproveResponse], error) {
	result, err := s.restructBusiness.Approve(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanRestructure, req.Msg.GetId())
	audit.WithAction(ctx, audit.ActionApprove)
	return connect.NewResponse(&loansv1.LoanRestructureApproveResponse{Data: result}), nil
}

func (s *LoanManagementServer) LoanRestructureReject(
	ctx context.Context,
	req *connect.Request[loansv1.LoanRestructureRejectRequest],
) (*connect.Response[loansv1.LoanRestructureRejectResponse], error) {
	result, err := s.restructBusiness.Reject(ctx, req.Msg.GetId(), req.Msg.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanRestructure, req.Msg.GetId())
	audit.WithAction(ctx, audit.ActionReject)
	audit.WithDetail(ctx, "reason", req.Msg.GetReason())
	return connect.NewResponse(&loansv1.LoanRestructureRejectResponse{Data: result}), nil
}

func (s *LoanManagementServer) LoanRestructureSearch(
	ctx context.Context,
	req *connect.Request[loansv1.LoanRestructureSearchRequest],
	stream *connect.ServerStream[loansv1.LoanRestructureSearchResponse],
) error {
	err := s.restructBusiness.Search(ctx, req.Msg,
		func(_ context.Context, batch []*loansv1.LoanRestructureObject) error {
			return stream.Send(&loansv1.LoanRestructureSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- Reconciliation RPCs ---

func (s *LoanManagementServer) ReconciliationSave(
	ctx context.Context,
	req *connect.Request[loansv1.ReconciliationSaveRequest],
) (*connect.Response[loansv1.ReconciliationSaveResponse], error) {
	result, err := s.reconBusiness.Save(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceReconciliation, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	return connect.NewResponse(&loansv1.ReconciliationSaveResponse{Data: result}), nil
}

func (s *LoanManagementServer) ReconciliationSearch(
	ctx context.Context,
	req *connect.Request[loansv1.ReconciliationSearchRequest],
	stream *connect.ServerStream[loansv1.ReconciliationSearchResponse],
) error {
	err := s.reconBusiness.Search(ctx, req.Msg,
		func(_ context.Context, batch []*loansv1.ReconciliationObject) error {
			return stream.Send(&loansv1.ReconciliationSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- LoanStatusChange (Audit) RPCs ---

func (s *LoanManagementServer) LoanStatusChangeSearch(
	ctx context.Context,
	req *connect.Request[loansv1.LoanStatusChangeSearchRequest],
	stream *connect.ServerStream[loansv1.LoanStatusChangeSearchResponse],
) error {
	var searchOpts []data.SearchOption

	cursor := req.Msg.GetCursor()
	if cursor != nil {
		offset, offsetErr := strconv.Atoi(cursor.GetPage())
		if offsetErr != nil {
			offset = 0
		}
		searchOpts = append(searchOpts, data.WithSearchOffset(offset), data.WithSearchLimit(int(cursor.GetLimit())))
	}

	andQueryVal := map[string]any{}
	if req.Msg.GetLoanAccountId() != "" {
		andQueryVal["loan_account_id = ?"] = req.Msg.GetLoanAccountId()
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := s.statusChangeRepo.Search(ctx, query)
	if err != nil {
		return apperrors.CleanErr(err)
	}

	if consumeErr := workerpool.ConsumeResultStream(ctx, results, func(res []*models.LoanStatusChange) error {
		var apiResults []*loansv1.LoanStatusChangeObject
		for _, sc := range res {
			apiResults = append(apiResults, sc.ToAPI())
		}
		return stream.Send(&loansv1.LoanStatusChangeSearchResponse{Data: apiResults})
	}); consumeErr != nil {
		return apperrors.CleanErr(consumeErr)
	}
	return nil
}

// --- Disbursement RPCs ---

func (s *LoanManagementServer) DisbursementCreate(
	ctx context.Context,
	req *connect.Request[loansv1.DisbursementCreateRequest],
) (*connect.Response[loansv1.DisbursementCreateResponse], error) {
	result, err := s.disbBusiness.Create(ctx, req.Msg)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceDisbursement, result.GetId())
	audit.WithAction(ctx, audit.ActionCreate)
	audit.WithDetail(ctx, "loan_account_id", req.Msg.GetLoanAccountId())
	return connect.NewResponse(&loansv1.DisbursementCreateResponse{Data: result}), nil
}

func (s *LoanManagementServer) DisbursementGet(
	ctx context.Context,
	req *connect.Request[loansv1.DisbursementGetRequest],
) (*connect.Response[loansv1.DisbursementGetResponse], error) {
	result, err := s.disbBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&loansv1.DisbursementGetResponse{Data: result}), nil
}

func (s *LoanManagementServer) DisbursementSearch(
	ctx context.Context,
	req *connect.Request[loansv1.DisbursementSearchRequest],
	stream *connect.ServerStream[loansv1.DisbursementSearchResponse],
) error {
	err := s.disbBusiness.Search(ctx, req.Msg,
		func(_ context.Context, batch []*loansv1.DisbursementObject) error {
			return stream.Send(&loansv1.DisbursementSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- ClientProductAccess RPCs ---

func (s *LoanManagementServer) ClientProductAccessSave(
	ctx context.Context,
	req *connect.Request[loansv1.ClientProductAccessSaveRequest],
) (*connect.Response[loansv1.ClientProductAccessSaveResponse], error) {
	result, err := s.cpaBusiness.Save(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanProduct, result.GetProductId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "client_id", result.GetClientId())
	return connect.NewResponse(&loansv1.ClientProductAccessSaveResponse{Data: result}), nil
}

func (s *LoanManagementServer) ClientProductAccessGet(
	ctx context.Context,
	req *connect.Request[loansv1.ClientProductAccessGetRequest],
) (*connect.Response[loansv1.ClientProductAccessGetResponse], error) {
	result, err := s.cpaBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&loansv1.ClientProductAccessGetResponse{Data: result}), nil
}

func (s *LoanManagementServer) ClientProductAccessSearch(
	ctx context.Context,
	req *connect.Request[loansv1.ClientProductAccessSearchRequest],
	stream *connect.ServerStream[loansv1.ClientProductAccessSearchResponse],
) error {
	err := s.cpaBusiness.Search(ctx, req.Msg,
		func(_ context.Context, batch []*loansv1.ClientProductAccessObject) error {
			return stream.Send(&loansv1.ClientProductAccessSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- Collections RPC ---

func (s *LoanManagementServer) InitiateCollection(
	ctx context.Context,
	req *connect.Request[loansv1.InitiateCollectionRequest],
) (*connect.Response[loansv1.InitiateCollectionResponse], error) {
	result, err := s.collectionBusiness.Initiate(ctx, req.Msg)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanAccount, req.Msg.GetLoanAccountId())
	audit.WithAction(ctx, audit.ActionCreate)
	audit.WithDetail(ctx, "payment_prompt_id", result.GetPaymentPromptId())
	return connect.NewResponse(result), nil
}

// --- Portfolio RPCs ---

func (s *LoanManagementServer) PortfolioSummary(
	ctx context.Context,
	req *connect.Request[loansv1.PortfolioSummaryRequest],
) (*connect.Response[loansv1.PortfolioSummaryResponse], error) {
	filter := business.PortfolioFilter{
		OrganizationID: req.Msg.GetOrganizationId(),
		BranchID:       req.Msg.GetBranchId(),
		AgentID:        req.Msg.GetAgentId(),
		ProductID:      req.Msg.GetProductId(),
		ClientID:       req.Msg.GetClientId(),
		CurrencyCode:   req.Msg.GetCurrencyCode(),
	}

	result, err := s.portfolioBusiness.GetSummary(ctx, filter)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	currency := result.CurrencyCode
	return connect.NewResponse(&loansv1.PortfolioSummaryResponse{
		Data: &loansv1.PortfolioSummary{
			TotalLoans:           result.TotalLoans,
			ActiveLoans:          result.ActiveLoans,
			DelinquentLoans:      result.DelinquentLoans,
			DefaultLoans:         result.DefaultLoans,
			PaidOffLoans:         result.PaidOffLoans,
			WrittenOffLoans:      result.WrittenOffLoans,
			TotalDisbursed:       models.MinorUnitsToMoney(result.TotalDisbursed, currency),
			TotalOutstanding:     models.MinorUnitsToMoney(result.TotalOutstanding, currency),
			TotalCollected:       models.MinorUnitsToMoney(result.TotalCollected, currency),
			PrincipalOutstanding: models.MinorUnitsToMoney(result.PrincipalOutstanding, currency),
			InterestOutstanding:  models.MinorUnitsToMoney(result.InterestOutstanding, currency),
			FeesOutstanding:      models.MinorUnitsToMoney(result.FeesOutstanding, currency),
			PenaltiesOutstanding: models.MinorUnitsToMoney(result.PenaltiesOutstanding, currency),
			CurrencyCode:         currency,
			CollectionRate:       result.CollectionRate,
			Par_30:               result.PAR30,
		},
	}), nil
}

func (s *LoanManagementServer) PortfolioExport(
	ctx context.Context,
	req *connect.Request[loansv1.PortfolioExportRequest],
) (*connect.Response[loansv1.PortfolioExportResponse], error) {
	filter := business.PortfolioFilter{
		OrganizationID: req.Msg.GetOrganizationId(),
		BranchID:       req.Msg.GetBranchId(),
		AgentID:        req.Msg.GetAgentId(),
		ProductID:      req.Msg.GetProductId(),
		ClientID:       req.Msg.GetClientId(),
		CurrencyCode:   req.Msg.GetCurrencyCode(),
	}

	csvData, err := s.portfolioBusiness.ExportCSV(ctx, filter)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	audit.WithAction(ctx, "export")
	return connect.NewResponse(&loansv1.PortfolioExportResponse{
		Data:        csvData,
		Filename:    "loan_book_" + time.Now().UTC().Format("20060102_150405") + ".csv",
		ContentType: "text/csv",
	}), nil
}
