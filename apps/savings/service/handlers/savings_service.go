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
	"time"

	"buf.build/gen/go/antinvestor/savings/connectrpc/go/v2/savings/v1/savingsv1connect"
	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	audit "github.com/antinvestor/common/audit"

	"github.com/antinvestor/service-fintech/apps/savings/service/business"
	"github.com/antinvestor/service-fintech/apps/savings/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// SavingsServer implements the SavingsService RPC handler.
// Tenant-level permission checks are handled by the FunctionAccessInterceptor.
type SavingsServer struct {
	spBusiness  business.SavingsProductBusiness
	saBusiness  business.SavingsAccountBusiness
	depBusiness business.DepositBusiness
	wdBusiness  business.WithdrawalBusiness
	iaBusiness  business.InterestAccrualBusiness
	jobs        *business.SavingsJobs

	savingsv1connect.UnimplementedSavingsServiceHandler
}

func NewSavingsServer(
	spBusiness business.SavingsProductBusiness,
	saBusiness business.SavingsAccountBusiness,
	depBusiness business.DepositBusiness,
	wdBusiness business.WithdrawalBusiness,
	iaBusiness business.InterestAccrualBusiness,
	jobs *business.SavingsJobs,
) savingsv1connect.SavingsServiceHandler {
	return &SavingsServer{
		spBusiness:  spBusiness,
		saBusiness:  saBusiness,
		depBusiness: depBusiness,
		wdBusiness:  wdBusiness,
		iaBusiness:  iaBusiness,
		jobs:        jobs,
	}
}

// SavingsJobRun runs one batch of a periodic job for the platform scheduler.
func (s *SavingsServer) SavingsJobRun(
	ctx context.Context,
	req *savingsv1.SavingsJobRunRequest,
) (*savingsv1.SavingsJobRunResponse, error) {
	if s.jobs == nil {
		return nil, apperrors.CleanErr(business.ErrUnknownJob)
	}
	processed, more, err := s.jobs.Run(ctx, req.GetJob(), int(req.GetBatchSize()))
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &savingsv1.SavingsJobRunResponse{
		Processed: int32(min(processed, math.MaxInt32)), //nolint:gosec // clamped to int32
		More:      more,
	}, nil
}

// PayoutFailedApply reverses a completed withdrawal the payment rail failed
// afterwards. Only operations calls it.
func (s *SavingsServer) PayoutFailedApply(
	ctx context.Context,
	req *savingsv1.PayoutFailedApplyRequest,
) (*savingsv1.PayoutFailedApplyResponse, error) {
	applied, err := s.wdBusiness.PayoutFailed(ctx, req.GetReference(), req.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &savingsv1.PayoutFailedApplyResponse{Applied: applied}, nil
}

// --- SavingsProduct RPCs ---

func (s *SavingsServer) SavingsProductSave(
	ctx context.Context,
	req *savingsv1.SavingsProductSaveRequest,
) (*savingsv1.SavingsProductSaveResponse, error) {
	result, err := s.spBusiness.Save(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceSavingsProduct, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "name", result.GetName())
	return &savingsv1.SavingsProductSaveResponse{Data: result}, nil
}

func (s *SavingsServer) SavingsProductGet(
	ctx context.Context,
	req *savingsv1.SavingsProductGetRequest,
) (*savingsv1.SavingsProductGetResponse, error) {
	result, err := s.spBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &savingsv1.SavingsProductGetResponse{Data: result}, nil
}

func (s *SavingsServer) SavingsProductSearch(
	ctx context.Context,
	req *savingsv1.SavingsProductSearchRequest,
	stream savingsv1connect.SavingsServiceSavingsProductSearchServerStream,
) error {
	err := s.spBusiness.Search(ctx, req,
		func(_ context.Context, batch []*savingsv1.SavingsProductObject) error {
			return stream.Send(&savingsv1.SavingsProductSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- SavingsAccount RPCs ---

func (s *SavingsServer) SavingsAccountCreate(
	ctx context.Context,
	req *savingsv1.SavingsAccountCreateRequest,
) (*savingsv1.SavingsAccountCreateResponse, error) {
	result, err := s.saBusiness.Create(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceSavingsAccount, result.GetId())
	audit.WithAction(ctx, audit.ActionCreate)
	return &savingsv1.SavingsAccountCreateResponse{Data: result}, nil
}

func (s *SavingsServer) SavingsAccountGet(
	ctx context.Context,
	req *savingsv1.SavingsAccountGetRequest,
) (*savingsv1.SavingsAccountGetResponse, error) {
	result, err := s.saBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &savingsv1.SavingsAccountGetResponse{Data: result}, nil
}

func (s *SavingsServer) SavingsAccountSearch(
	ctx context.Context,
	req *savingsv1.SavingsAccountSearchRequest,
	stream savingsv1connect.SavingsServiceSavingsAccountSearchServerStream,
) error {
	err := s.saBusiness.Search(ctx, req,
		func(_ context.Context, batch []*savingsv1.SavingsAccountObject) error {
			return stream.Send(&savingsv1.SavingsAccountSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

func (s *SavingsServer) SavingsAccountFreeze(
	ctx context.Context,
	req *savingsv1.SavingsAccountFreezeRequest,
) (*savingsv1.SavingsAccountFreezeResponse, error) {
	result, err := s.saBusiness.Freeze(ctx, req.GetId(), req.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceSavingsAccount, req.GetId())
	audit.WithAction(ctx, audit.ActionSuspend)
	audit.WithDetail(ctx, "reason", req.GetReason())
	return &savingsv1.SavingsAccountFreezeResponse{Data: result}, nil
}

func (s *SavingsServer) SavingsAccountClose(
	ctx context.Context,
	req *savingsv1.SavingsAccountCloseRequest,
) (*savingsv1.SavingsAccountCloseResponse, error) {
	result, err := s.saBusiness.Close(ctx, req.GetId(), req.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceSavingsAccount, req.GetId())
	audit.WithAction(ctx, "close")
	audit.WithDetail(ctx, "reason", req.GetReason())
	return &savingsv1.SavingsAccountCloseResponse{Data: result}, nil
}

// --- Deposit RPCs ---

func (s *SavingsServer) DepositRecord(
	ctx context.Context,
	req *savingsv1.DepositRecordRequest,
) (*savingsv1.DepositRecordResponse, error) {
	result, err := s.depBusiness.Record(ctx, req)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceDeposit, result.GetId())
	audit.WithAction(ctx, audit.ActionCreate)
	audit.WithDetail(ctx, "savings_account_id", req.GetSavingsAccountId())
	return &savingsv1.DepositRecordResponse{Data: result}, nil
}

func (s *SavingsServer) DepositGet(
	ctx context.Context,
	req *savingsv1.DepositGetRequest,
) (*savingsv1.DepositGetResponse, error) {
	result, err := s.depBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &savingsv1.DepositGetResponse{Data: result}, nil
}

func (s *SavingsServer) DepositSearch(
	ctx context.Context,
	req *savingsv1.DepositSearchRequest,
	stream savingsv1connect.SavingsServiceDepositSearchServerStream,
) error {
	err := s.depBusiness.Search(ctx, req,
		func(_ context.Context, batch []*savingsv1.DepositObject) error {
			return stream.Send(&savingsv1.DepositSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- Withdrawal RPCs ---

func (s *SavingsServer) WithdrawalRequest(
	ctx context.Context,
	req *savingsv1.WithdrawalRequestRequest,
) (*savingsv1.WithdrawalRequestResponse, error) {
	result, err := s.wdBusiness.Request(ctx, req)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceWithdrawal, result.GetId())
	audit.WithAction(ctx, audit.ActionCreate)
	audit.WithDetail(ctx, "savings_account_id", req.GetSavingsAccountId())
	return &savingsv1.WithdrawalRequestResponse{Data: result}, nil
}

func (s *SavingsServer) WithdrawalApprove(
	ctx context.Context,
	req *savingsv1.WithdrawalApproveRequest,
) (*savingsv1.WithdrawalApproveResponse, error) {
	result, err := s.wdBusiness.Approve(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceWithdrawal, req.GetId())
	audit.WithAction(ctx, audit.ActionApprove)
	return &savingsv1.WithdrawalApproveResponse{Data: result}, nil
}

func (s *SavingsServer) WithdrawalCancel(
	ctx context.Context,
	req *savingsv1.WithdrawalCancelRequest,
) (*savingsv1.WithdrawalCancelResponse, error) {
	result, err := s.wdBusiness.Cancel(ctx, req.GetId(), req.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceWithdrawal, req.GetId())
	audit.WithAction(ctx, audit.ActionReject)
	return &savingsv1.WithdrawalCancelResponse{Data: result}, nil
}

func (s *SavingsServer) WithdrawalGet(
	ctx context.Context,
	req *savingsv1.WithdrawalGetRequest,
) (*savingsv1.WithdrawalGetResponse, error) {
	result, err := s.wdBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &savingsv1.WithdrawalGetResponse{Data: result}, nil
}

func (s *SavingsServer) WithdrawalSearch(
	ctx context.Context,
	req *savingsv1.WithdrawalSearchRequest,
	stream savingsv1connect.SavingsServiceWithdrawalSearchServerStream,
) error {
	err := s.wdBusiness.Search(ctx, req,
		func(_ context.Context, batch []*savingsv1.WithdrawalObject) error {
			return stream.Send(&savingsv1.WithdrawalSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- InterestAccrual RPCs ---

func (s *SavingsServer) InterestAccrualGet(
	ctx context.Context,
	req *savingsv1.InterestAccrualGetRequest,
) (*savingsv1.InterestAccrualGetResponse, error) {
	result, err := s.iaBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &savingsv1.InterestAccrualGetResponse{Data: result}, nil
}

func (s *SavingsServer) InterestAccrualSearch(
	ctx context.Context,
	req *savingsv1.InterestAccrualSearchRequest,
	stream savingsv1connect.SavingsServiceInterestAccrualSearchServerStream,
) error {
	err := s.iaBusiness.Search(ctx, req,
		func(_ context.Context, batch []*savingsv1.InterestAccrualObject) error {
			return stream.Send(&savingsv1.InterestAccrualSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- Balance & Statement RPCs ---

func (s *SavingsServer) SavingsBalanceGet(
	ctx context.Context,
	req *savingsv1.SavingsBalanceGetRequest,
) (*savingsv1.SavingsBalanceGetResponse, error) {
	result, err := s.saBusiness.GetBalance(ctx, req.GetSavingsAccountId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &savingsv1.SavingsBalanceGetResponse{Data: result}, nil
}

func (s *SavingsServer) SavingsStatement(
	ctx context.Context,
	req *savingsv1.SavingsStatementRequest,
) (*savingsv1.SavingsStatementResponse, error) {
	from := models.StringToTime(req.GetFromDate())
	to := models.StringToTime(req.GetToDate())
	var fromTime, toTime time.Time
	if from != nil {
		fromTime = *from
	}
	if to != nil {
		toTime = *to
	}
	result, err := s.saBusiness.GetStatement(ctx, req.GetSavingsAccountId(), fromTime, toTime)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return result, nil
}
