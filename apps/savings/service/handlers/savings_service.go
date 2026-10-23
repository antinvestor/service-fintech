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
	"time"

	"buf.build/gen/go/antinvestor/savings/connectrpc/go/savings/v1/savingsv1connect"
	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"connectrpc.com/connect"
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

	savingsv1connect.UnimplementedSavingsServiceHandler
}

func NewSavingsServer(
	spBusiness business.SavingsProductBusiness,
	saBusiness business.SavingsAccountBusiness,
	depBusiness business.DepositBusiness,
	wdBusiness business.WithdrawalBusiness,
	iaBusiness business.InterestAccrualBusiness,
) savingsv1connect.SavingsServiceHandler {
	return &SavingsServer{
		spBusiness:  spBusiness,
		saBusiness:  saBusiness,
		depBusiness: depBusiness,
		wdBusiness:  wdBusiness,
		iaBusiness:  iaBusiness,
	}
}

// --- SavingsProduct RPCs ---

func (s *SavingsServer) SavingsProductSave(
	ctx context.Context,
	req *connect.Request[savingsv1.SavingsProductSaveRequest],
) (*connect.Response[savingsv1.SavingsProductSaveResponse], error) {
	result, err := s.spBusiness.Save(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceSavingsProduct, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "name", result.GetName())
	return connect.NewResponse(&savingsv1.SavingsProductSaveResponse{Data: result}), nil
}

func (s *SavingsServer) SavingsProductGet(
	ctx context.Context,
	req *connect.Request[savingsv1.SavingsProductGetRequest],
) (*connect.Response[savingsv1.SavingsProductGetResponse], error) {
	result, err := s.spBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&savingsv1.SavingsProductGetResponse{Data: result}), nil
}

func (s *SavingsServer) SavingsProductSearch(
	ctx context.Context,
	req *connect.Request[savingsv1.SavingsProductSearchRequest],
	stream *connect.ServerStream[savingsv1.SavingsProductSearchResponse],
) error {
	err := s.spBusiness.Search(ctx, req.Msg,
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
	req *connect.Request[savingsv1.SavingsAccountCreateRequest],
) (*connect.Response[savingsv1.SavingsAccountCreateResponse], error) {
	result, err := s.saBusiness.Create(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceSavingsAccount, result.GetId())
	audit.WithAction(ctx, audit.ActionCreate)
	return connect.NewResponse(&savingsv1.SavingsAccountCreateResponse{Data: result}), nil
}

func (s *SavingsServer) SavingsAccountGet(
	ctx context.Context,
	req *connect.Request[savingsv1.SavingsAccountGetRequest],
) (*connect.Response[savingsv1.SavingsAccountGetResponse], error) {
	result, err := s.saBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&savingsv1.SavingsAccountGetResponse{Data: result}), nil
}

func (s *SavingsServer) SavingsAccountSearch(
	ctx context.Context,
	req *connect.Request[savingsv1.SavingsAccountSearchRequest],
	stream *connect.ServerStream[savingsv1.SavingsAccountSearchResponse],
) error {
	err := s.saBusiness.Search(ctx, req.Msg,
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
	req *connect.Request[savingsv1.SavingsAccountFreezeRequest],
) (*connect.Response[savingsv1.SavingsAccountFreezeResponse], error) {
	result, err := s.saBusiness.Freeze(ctx, req.Msg.GetId(), req.Msg.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceSavingsAccount, req.Msg.GetId())
	audit.WithAction(ctx, audit.ActionSuspend)
	audit.WithDetail(ctx, "reason", req.Msg.GetReason())
	return connect.NewResponse(&savingsv1.SavingsAccountFreezeResponse{Data: result}), nil
}

func (s *SavingsServer) SavingsAccountClose(
	ctx context.Context,
	req *connect.Request[savingsv1.SavingsAccountCloseRequest],
) (*connect.Response[savingsv1.SavingsAccountCloseResponse], error) {
	result, err := s.saBusiness.Close(ctx, req.Msg.GetId(), req.Msg.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceSavingsAccount, req.Msg.GetId())
	audit.WithAction(ctx, "close")
	audit.WithDetail(ctx, "reason", req.Msg.GetReason())
	return connect.NewResponse(&savingsv1.SavingsAccountCloseResponse{Data: result}), nil
}

// --- Deposit RPCs ---

func (s *SavingsServer) DepositRecord(
	ctx context.Context,
	req *connect.Request[savingsv1.DepositRecordRequest],
) (*connect.Response[savingsv1.DepositRecordResponse], error) {
	result, err := s.depBusiness.Record(ctx, req.Msg)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceDeposit, result.GetId())
	audit.WithAction(ctx, audit.ActionCreate)
	audit.WithDetail(ctx, "savings_account_id", req.Msg.GetSavingsAccountId())
	return connect.NewResponse(&savingsv1.DepositRecordResponse{Data: result}), nil
}

func (s *SavingsServer) DepositGet(
	ctx context.Context,
	req *connect.Request[savingsv1.DepositGetRequest],
) (*connect.Response[savingsv1.DepositGetResponse], error) {
	result, err := s.depBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&savingsv1.DepositGetResponse{Data: result}), nil
}

func (s *SavingsServer) DepositSearch(
	ctx context.Context,
	req *connect.Request[savingsv1.DepositSearchRequest],
	stream *connect.ServerStream[savingsv1.DepositSearchResponse],
) error {
	err := s.depBusiness.Search(ctx, req.Msg,
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
	req *connect.Request[savingsv1.WithdrawalRequestRequest],
) (*connect.Response[savingsv1.WithdrawalRequestResponse], error) {
	result, err := s.wdBusiness.Request(ctx, req.Msg)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceWithdrawal, result.GetId())
	audit.WithAction(ctx, audit.ActionCreate)
	audit.WithDetail(ctx, "savings_account_id", req.Msg.GetSavingsAccountId())
	return connect.NewResponse(&savingsv1.WithdrawalRequestResponse{Data: result}), nil
}

func (s *SavingsServer) WithdrawalApprove(
	ctx context.Context,
	req *connect.Request[savingsv1.WithdrawalApproveRequest],
) (*connect.Response[savingsv1.WithdrawalApproveResponse], error) {
	result, err := s.wdBusiness.Approve(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceWithdrawal, req.Msg.GetId())
	audit.WithAction(ctx, audit.ActionApprove)
	return connect.NewResponse(&savingsv1.WithdrawalApproveResponse{Data: result}), nil
}

func (s *SavingsServer) WithdrawalCancel(
	ctx context.Context,
	req *connect.Request[savingsv1.WithdrawalCancelRequest],
) (*connect.Response[savingsv1.WithdrawalCancelResponse], error) {
	result, err := s.wdBusiness.Cancel(ctx, req.Msg.GetId(), req.Msg.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceWithdrawal, req.Msg.GetId())
	audit.WithAction(ctx, audit.ActionReject)
	return connect.NewResponse(&savingsv1.WithdrawalCancelResponse{Data: result}), nil
}

func (s *SavingsServer) WithdrawalGet(
	ctx context.Context,
	req *connect.Request[savingsv1.WithdrawalGetRequest],
) (*connect.Response[savingsv1.WithdrawalGetResponse], error) {
	result, err := s.wdBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&savingsv1.WithdrawalGetResponse{Data: result}), nil
}

func (s *SavingsServer) WithdrawalSearch(
	ctx context.Context,
	req *connect.Request[savingsv1.WithdrawalSearchRequest],
	stream *connect.ServerStream[savingsv1.WithdrawalSearchResponse],
) error {
	err := s.wdBusiness.Search(ctx, req.Msg,
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
	req *connect.Request[savingsv1.InterestAccrualGetRequest],
) (*connect.Response[savingsv1.InterestAccrualGetResponse], error) {
	result, err := s.iaBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&savingsv1.InterestAccrualGetResponse{Data: result}), nil
}

func (s *SavingsServer) InterestAccrualSearch(
	ctx context.Context,
	req *connect.Request[savingsv1.InterestAccrualSearchRequest],
	stream *connect.ServerStream[savingsv1.InterestAccrualSearchResponse],
) error {
	err := s.iaBusiness.Search(ctx, req.Msg,
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
	req *connect.Request[savingsv1.SavingsBalanceGetRequest],
) (*connect.Response[savingsv1.SavingsBalanceGetResponse], error) {
	result, err := s.saBusiness.GetBalance(ctx, req.Msg.GetSavingsAccountId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&savingsv1.SavingsBalanceGetResponse{Data: result}), nil
}

func (s *SavingsServer) SavingsStatement(
	ctx context.Context,
	req *connect.Request[savingsv1.SavingsStatementRequest],
) (*connect.Response[savingsv1.SavingsStatementResponse], error) {
	from := models.StringToTime(req.Msg.GetFromDate())
	to := models.StringToTime(req.Msg.GetToDate())
	var fromTime, toTime time.Time
	if from != nil {
		fromTime = *from
	}
	if to != nil {
		toTime = *to
	}
	result, err := s.saBusiness.GetStatement(ctx, req.Msg.GetSavingsAccountId(), fromTime, toTime)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(result), nil
}
