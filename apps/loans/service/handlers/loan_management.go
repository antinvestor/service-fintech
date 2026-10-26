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
	"math"
	"strconv"
	"time"

	"buf.build/gen/go/antinvestor/loans/connectrpc/go/v2/loans/v1/loansv1connect"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	audit "github.com/antinvestor/common/audit"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/workerpool"

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
	jobs               *business.LoanJobs
	commissions        *business.TeamCommissions

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
	jobs *business.LoanJobs,
	commissions *business.TeamCommissions,
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
		jobs:               jobs,
		commissions:        commissions,
	}
}

// LoanJobRun runs one batch of a periodic job for the platform scheduler.
func (s *LoanManagementServer) LoanJobRun(
	ctx context.Context,
	req *loansv1.LoanJobRunRequest,
) (*loansv1.LoanJobRunResponse, error) {
	processed, more, err := s.jobs.Run(ctx, req.GetJob(), int(req.GetBatchSize()))
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithAction(ctx, "job_run")
	audit.WithDetail(ctx, "job", req.GetJob().String())
	return &loansv1.LoanJobRunResponse{
		Processed: int32(min(processed, math.MaxInt32)), //nolint:gosec // clamped to int32
		More:      more,
	}, nil
}

// --- LoanProduct RPCs ---

func (s *LoanManagementServer) LoanProductSave(
	ctx context.Context,
	req *loansv1.LoanProductSaveRequest,
) (*loansv1.LoanProductSaveResponse, error) {
	result, err := s.lpBusiness.Save(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanProduct, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "name", result.GetName())
	return &loansv1.LoanProductSaveResponse{Data: result}, nil
}

func (s *LoanManagementServer) LoanProductGet(
	ctx context.Context,
	req *loansv1.LoanProductGetRequest,
) (*loansv1.LoanProductGetResponse, error) {
	result, err := s.lpBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &loansv1.LoanProductGetResponse{Data: result}, nil
}

func (s *LoanManagementServer) LoanProductSearch(
	ctx context.Context,
	req *loansv1.LoanProductSearchRequest,
	stream loansv1connect.LoanManagementServiceLoanProductSearchServerStream,
) error {
	err := s.lpBusiness.Search(ctx, req, func(_ context.Context, batch []*loansv1.LoanProductObject) error {
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
	req *loansv1.LoanRequestSaveRequest,
) (*loansv1.LoanRequestSaveResponse, error) {
	result, err := s.lrBusiness.Save(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanRequest, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	return &loansv1.LoanRequestSaveResponse{Data: result}, nil
}

func (s *LoanManagementServer) LoanRequestGet(
	ctx context.Context,
	req *loansv1.LoanRequestGetRequest,
) (*loansv1.LoanRequestGetResponse, error) {
	result, err := s.lrBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &loansv1.LoanRequestGetResponse{Data: result}, nil
}

func (s *LoanManagementServer) LoanRequestSearch(
	ctx context.Context,
	req *loansv1.LoanRequestSearchRequest,
	stream loansv1connect.LoanManagementServiceLoanRequestSearchServerStream,
) error {
	err := s.lrBusiness.Search(ctx, req, func(_ context.Context, batch []*loansv1.LoanRequestObject) error {
		return stream.Send(&loansv1.LoanRequestSearchResponse{Data: batch})
	})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

func (s *LoanManagementServer) LoanRequestApprove(
	ctx context.Context,
	req *loansv1.LoanRequestApproveRequest,
) (*loansv1.LoanRequestApproveResponse, error) {
	result, err := s.lrBusiness.Approve(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanRequest, req.GetId())
	audit.WithAction(ctx, audit.ActionApprove)
	return &loansv1.LoanRequestApproveResponse{Data: result}, nil
}

func (s *LoanManagementServer) LoanRequestReject(
	ctx context.Context,
	req *loansv1.LoanRequestRejectRequest,
) (*loansv1.LoanRequestRejectResponse, error) {
	result, err := s.lrBusiness.Reject(ctx, req.GetId(), req.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanRequest, req.GetId())
	audit.WithAction(ctx, audit.ActionReject)
	audit.WithDetail(ctx, "reason", req.GetReason())
	return &loansv1.LoanRequestRejectResponse{Data: result}, nil
}

func (s *LoanManagementServer) LoanRequestCancel(
	ctx context.Context,
	req *loansv1.LoanRequestCancelRequest,
) (*loansv1.LoanRequestCancelResponse, error) {
	result, err := s.lrBusiness.Cancel(ctx, req.GetId(), req.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanRequest, req.GetId())
	audit.WithAction(ctx, audit.ActionCancel)
	audit.WithDetail(ctx, "reason", req.GetReason())
	return &loansv1.LoanRequestCancelResponse{Data: result}, nil
}

// --- LoanAccount RPCs ---

func (s *LoanManagementServer) LoanAccountCreate(
	ctx context.Context,
	req *loansv1.LoanAccountCreateRequest,
) (*loansv1.LoanAccountCreateResponse, error) {
	result, err := s.laBusiness.Create(ctx, req.GetLoanRequestId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanAccount, result.GetId())
	audit.WithAction(ctx, audit.ActionCreate)
	audit.WithDetail(ctx, "loan_request_id", req.GetLoanRequestId())
	return &loansv1.LoanAccountCreateResponse{Data: result}, nil
}

func (s *LoanManagementServer) LoanAccountCancel(
	ctx context.Context,
	req *loansv1.LoanAccountCancelRequest,
) (*loansv1.LoanAccountCancelResponse, error) {
	result, err := s.laBusiness.Cancel(ctx, req.GetId(), req.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanAccount, req.GetId())
	audit.WithAction(ctx, "cancel")
	audit.WithDetail(ctx, "reason", req.GetReason())
	return &loansv1.LoanAccountCancelResponse{Data: result}, nil
}

func (s *LoanManagementServer) LoanAccountGet(
	ctx context.Context,
	req *loansv1.LoanAccountGetRequest,
) (*loansv1.LoanAccountGetResponse, error) {
	result, err := s.laBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &loansv1.LoanAccountGetResponse{Data: result}, nil
}

func (s *LoanManagementServer) LoanAccountSearch(
	ctx context.Context,
	req *loansv1.LoanAccountSearchRequest,
	stream loansv1connect.LoanManagementServiceLoanAccountSearchServerStream,
) error {
	err := s.laBusiness.Search(ctx, req,
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
	req *loansv1.LoanBalanceGetRequest,
) (*loansv1.LoanBalanceGetResponse, error) {
	result, err := s.laBusiness.GetBalance(ctx, req.GetLoanAccountId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &loansv1.LoanBalanceGetResponse{Data: result}, nil
}

func (s *LoanManagementServer) LoanStatement(
	ctx context.Context,
	req *loansv1.LoanStatementRequest,
) (*loansv1.LoanStatementResponse, error) {
	result, err := s.laBusiness.GetStatement(ctx, req)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return result, nil
}

// --- Repayment RPCs ---

func (s *LoanManagementServer) RepaymentRecord(
	ctx context.Context,
	req *loansv1.RepaymentRecordRequest,
) (*loansv1.RepaymentRecordResponse, error) {
	result, err := s.repBusiness.Record(ctx, req)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceRepayment, result.GetId())
	audit.WithAction(ctx, audit.ActionCreate)
	audit.WithDetail(ctx, "loan_account_id", req.GetLoanAccountId())
	return &loansv1.RepaymentRecordResponse{Data: result}, nil
}

func (s *LoanManagementServer) RepaymentGet(
	ctx context.Context,
	req *loansv1.RepaymentGetRequest,
) (*loansv1.RepaymentGetResponse, error) {
	result, err := s.repBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &loansv1.RepaymentGetResponse{Data: result}, nil
}

func (s *LoanManagementServer) RepaymentSearch(
	ctx context.Context,
	req *loansv1.RepaymentSearchRequest,
	stream loansv1connect.LoanManagementServiceRepaymentSearchServerStream,
) error {
	err := s.repBusiness.Search(ctx, req,
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
	req *loansv1.RepaymentScheduleGetRequest,
) (*loansv1.RepaymentScheduleGetResponse, error) {
	result, err := s.scheduleBusiness.GetActive(ctx, req.GetLoanAccountId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &loansv1.RepaymentScheduleGetResponse{Data: result}, nil
}

// --- Penalty RPCs ---

func (s *LoanManagementServer) PenaltySave(
	ctx context.Context,
	req *loansv1.PenaltySaveRequest,
) (*loansv1.PenaltySaveResponse, error) {
	result, err := s.penaltyBusiness.Save(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourcePenalty, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	return &loansv1.PenaltySaveResponse{Data: result}, nil
}

func (s *LoanManagementServer) PenaltyWaive(
	ctx context.Context,
	req *loansv1.PenaltyWaiveRequest,
) (*loansv1.PenaltyWaiveResponse, error) {
	result, err := s.penaltyBusiness.Waive(ctx, req.GetId(), req.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourcePenalty, req.GetId())
	audit.WithAction(ctx, "waive")
	audit.WithDetail(ctx, "reason", req.GetReason())
	return &loansv1.PenaltyWaiveResponse{Data: result}, nil
}

func (s *LoanManagementServer) PenaltySearch(
	ctx context.Context,
	req *loansv1.PenaltySearchRequest,
	stream loansv1connect.LoanManagementServicePenaltySearchServerStream,
) error {
	err := s.penaltyBusiness.Search(ctx, req,
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
	req *loansv1.LoanRestructureCreateRequest,
) (*loansv1.LoanRestructureCreateResponse, error) {
	result, err := s.restructBusiness.Create(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanRestructure, result.GetId())
	audit.WithAction(ctx, audit.ActionCreate)
	return &loansv1.LoanRestructureCreateResponse{Data: result}, nil
}

func (s *LoanManagementServer) LoanRestructureApprove(
	ctx context.Context,
	req *loansv1.LoanRestructureApproveRequest,
) (*loansv1.LoanRestructureApproveResponse, error) {
	result, err := s.restructBusiness.Approve(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanRestructure, req.GetId())
	audit.WithAction(ctx, audit.ActionApprove)
	return &loansv1.LoanRestructureApproveResponse{Data: result}, nil
}

func (s *LoanManagementServer) LoanRestructureReject(
	ctx context.Context,
	req *loansv1.LoanRestructureRejectRequest,
) (*loansv1.LoanRestructureRejectResponse, error) {
	result, err := s.restructBusiness.Reject(ctx, req.GetId(), req.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanRestructure, req.GetId())
	audit.WithAction(ctx, audit.ActionReject)
	audit.WithDetail(ctx, "reason", req.GetReason())
	return &loansv1.LoanRestructureRejectResponse{Data: result}, nil
}

func (s *LoanManagementServer) LoanRestructureSearch(
	ctx context.Context,
	req *loansv1.LoanRestructureSearchRequest,
	stream loansv1connect.LoanManagementServiceLoanRestructureSearchServerStream,
) error {
	err := s.restructBusiness.Search(ctx, req,
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
	req *loansv1.ReconciliationSaveRequest,
) (*loansv1.ReconciliationSaveResponse, error) {
	result, err := s.reconBusiness.Save(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceReconciliation, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	return &loansv1.ReconciliationSaveResponse{Data: result}, nil
}

func (s *LoanManagementServer) ReconciliationSearch(
	ctx context.Context,
	req *loansv1.ReconciliationSearchRequest,
	stream loansv1connect.LoanManagementServiceReconciliationSearchServerStream,
) error {
	err := s.reconBusiness.Search(ctx, req,
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
	req *loansv1.LoanStatusChangeSearchRequest,
	stream loansv1connect.LoanManagementServiceLoanStatusChangeSearchServerStream,
) error {
	var searchOpts []data.SearchOption

	cursor := req.GetCursor()
	if cursor != nil {
		offset, offsetErr := strconv.Atoi(cursor.GetPage())
		if offsetErr != nil {
			offset = 0
		}
		searchOpts = append(searchOpts, data.WithSearchOffset(offset), data.WithSearchLimit(int(cursor.GetLimit())))
	}

	andQueryVal := map[string]any{}
	if req.GetLoanAccountId() != "" {
		andQueryVal["loan_account_id = ?"] = req.GetLoanAccountId()
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
	req *loansv1.DisbursementCreateRequest,
) (*loansv1.DisbursementCreateResponse, error) {
	result, err := s.disbBusiness.Create(ctx, req)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceDisbursement, result.GetId())
	audit.WithAction(ctx, audit.ActionCreate)
	audit.WithDetail(ctx, "loan_account_id", req.GetLoanAccountId())
	return &loansv1.DisbursementCreateResponse{Data: result}, nil
}

func (s *LoanManagementServer) DisbursementGet(
	ctx context.Context,
	req *loansv1.DisbursementGetRequest,
) (*loansv1.DisbursementGetResponse, error) {
	result, err := s.disbBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &loansv1.DisbursementGetResponse{Data: result}, nil
}

func (s *LoanManagementServer) DisbursementSearch(
	ctx context.Context,
	req *loansv1.DisbursementSearchRequest,
	stream loansv1connect.LoanManagementServiceDisbursementSearchServerStream,
) error {
	err := s.disbBusiness.Search(ctx, req,
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
	req *loansv1.ClientProductAccessSaveRequest,
) (*loansv1.ClientProductAccessSaveResponse, error) {
	result, err := s.cpaBusiness.Save(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanProduct, result.GetProductId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "client_id", result.GetClientId())
	return &loansv1.ClientProductAccessSaveResponse{Data: result}, nil
}

func (s *LoanManagementServer) ClientProductAccessGet(
	ctx context.Context,
	req *loansv1.ClientProductAccessGetRequest,
) (*loansv1.ClientProductAccessGetResponse, error) {
	result, err := s.cpaBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &loansv1.ClientProductAccessGetResponse{Data: result}, nil
}

func (s *LoanManagementServer) ClientProductAccessSearch(
	ctx context.Context,
	req *loansv1.ClientProductAccessSearchRequest,
	stream loansv1connect.LoanManagementServiceClientProductAccessSearchServerStream,
) error {
	err := s.cpaBusiness.Search(ctx, req,
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
	req *loansv1.InitiateCollectionRequest,
) (*loansv1.InitiateCollectionResponse, error) {
	result, err := s.collectionBusiness.Initiate(ctx, req)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceLoanAccount, req.GetLoanAccountId())
	audit.WithAction(ctx, audit.ActionCreate)
	audit.WithDetail(ctx, "payment_prompt_id", result.GetPaymentPromptId())
	return result, nil
}

// --- Portfolio RPCs ---

func (s *LoanManagementServer) PortfolioSummary(
	ctx context.Context,
	req *loansv1.PortfolioSummaryRequest,
) (*loansv1.PortfolioSummaryResponse, error) {
	filter := business.PortfolioFilter{
		OrganizationID: req.GetOrganizationId(),
		BranchID:       req.GetBranchId(),
		AgentID:        req.GetAgentId(),
		ProductID:      req.GetProductId(),
		ClientID:       req.GetClientId(),
		CurrencyCode:   req.GetCurrencyCode(),
	}

	result, err := s.portfolioBusiness.GetSummary(ctx, filter)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	currency := result.CurrencyCode
	return &loansv1.PortfolioSummaryResponse{
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
	}, nil
}

func (s *LoanManagementServer) PortfolioExport(
	ctx context.Context,
	req *loansv1.PortfolioExportRequest,
) (*loansv1.PortfolioExportResponse, error) {
	filter := business.PortfolioFilter{
		OrganizationID: req.GetOrganizationId(),
		BranchID:       req.GetBranchId(),
		AgentID:        req.GetAgentId(),
		ProductID:      req.GetProductId(),
		ClientID:       req.GetClientId(),
		CurrencyCode:   req.GetCurrencyCode(),
	}

	csvData, err := s.portfolioBusiness.ExportCSV(ctx, filter)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	audit.WithAction(ctx, "export")
	return &loansv1.PortfolioExportResponse{
		Data:        csvData,
		Filename:    "loan_book_" + time.Now().UTC().Format("20060102_150405") + ".csv",
		ContentType: "text/csv",
	}, nil
}
