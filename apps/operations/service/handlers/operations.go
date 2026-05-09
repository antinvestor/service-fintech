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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect"
	audit "github.com/antinvestor/common/audit"
	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/frame/workerpool"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/operations/service/business"
	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

const moneyDecimalPlaces = 2

// OperationsServer implements the OperationsService RPC handler.
// Tenant-level permission checks are handled by the FunctionAccessInterceptor.
type OperationsServer struct {
	toBusiness business.TransferOrderBusiness
	prBusiness business.PaymentRoutingBusiness
	toRepo     repository.TransferOrderRepository

	operationsv1connect.UnimplementedOperationsServiceHandler
}

func NewOperationsServer(
	toBusiness business.TransferOrderBusiness,
	prBusiness business.PaymentRoutingBusiness,
	toRepo repository.TransferOrderRepository,
) operationsv1connect.OperationsServiceHandler {
	return &OperationsServer{
		toBusiness: toBusiness,
		prBusiness: prBusiness,
		toRepo:     toRepo,
	}
}

func (s *OperationsServer) TransferOrderExecute(
	ctx context.Context,
	req *connect.Request[operationsv1.TransferOrderExecuteRequest],
) (*connect.Response[operationsv1.TransferOrderExecuteResponse], error) {
	obj := req.Msg.GetData()

	// Resolve the order to execute. If the caller provides an ID, use it.
	// If the caller provides a non-empty Reference, that reference is treated
	// as an idempotency key: a prior row with the same reference short-circuits
	// creation so the same logical operation always converges on a single
	// ledger posting. Otherwise we create a fresh order from the payload.
	orderID := obj.GetId()
	if orderID == "" {
		order := transferOrderFromAPI(ctx, obj)
		if err := s.toBusiness.Save(ctx, order); err != nil {
			return nil, apperrors.CleanErr(err)
		}
		orderID = order.GetID()
	}

	if err := s.toBusiness.Execute(ctx, orderID); err != nil {
		return nil, apperrors.CleanErr(err)
	}

	result, err := s.toRepo.GetByID(ctx, orderID)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	audit.WithResource(ctx, audit.ResourceTransferOrder, orderID)
	audit.WithAction(ctx, "execute")
	audit.WithDetail(ctx, "reference", result.Reference)
	return connect.NewResponse(&operationsv1.TransferOrderExecuteResponse{
		Data: transferOrderToAPI(result),
	}), nil
}

func (s *OperationsServer) TransferOrderSearch(
	ctx context.Context,
	req *connect.Request[operationsv1.TransferOrderSearchRequest],
	stream *connect.ServerStream[operationsv1.TransferOrderSearchResponse],
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
	if req.Msg.GetOrderType() != 0 {
		andQueryVal["order_type = ?"] = req.Msg.GetOrderType()
	}
	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	if req.Msg.GetQuery() != "" {
		searchOpts = append(searchOpts,
			data.WithSearchFiltersOrByValue(
				map[string]any{
					"reference ILIKE ?":   "%" + req.Msg.GetQuery() + "%",
					"description ILIKE ?": "%" + req.Msg.GetQuery() + "%",
				},
			),
		)
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := s.toRepo.Search(ctx, query)
	if err != nil {
		return apperrors.CleanErr(err)
	}

	return workerpool.ConsumeResultStream(ctx, results, func(batch []*models.TransferOrder) error {
		var apiResults []*operationsv1.TransferOrderObject
		for _, order := range batch {
			apiResults = append(apiResults, transferOrderToAPI(order))
		}
		return stream.Send(&operationsv1.TransferOrderSearchResponse{Data: apiResults})
	})
}

// transferOrderFromAPI converts a proto TransferOrderObject to a TransferOrder model.
func transferOrderFromAPI(ctx context.Context, obj *operationsv1.TransferOrderObject) *models.TransferOrder {
	amount := moneyx.ToSmallestUnit(obj.GetAmount(), moneyDecimalPlaces)
	currency := obj.GetAmount().GetCurrencyCode()
	m := &models.TransferOrder{
		DebitAccountRef:  obj.GetDebitAccountRef(),
		CreditAccountRef: obj.GetCreditAccountRef(),
		Amount:           amount,
		Currency:         currency,
		OrderType:        obj.GetOrderType(),
		Reference:        obj.GetReference(),
		Description:      obj.GetDescription(),
		State:            int32(obj.GetState()),
	}
	if obj.GetExtraData() != nil {
		m.ExtraData = (&data.JSONMap{}).FromProtoStruct(obj.GetExtraData())
	}
	m.GenID(ctx)
	if obj.GetId() != "" {
		m.ID = obj.GetId()
	}
	return m
}

// transferOrderToAPI converts a TransferOrder model to the proto TransferOrderObject.
func transferOrderToAPI(m *models.TransferOrder) *operationsv1.TransferOrderObject {
	return &operationsv1.TransferOrderObject{
		Id:               m.GetID(),
		DebitAccountRef:  m.DebitAccountRef,
		CreditAccountRef: m.CreditAccountRef,
		Amount:           moneyx.FromSmallestUnit(m.Currency, m.Amount, moneyDecimalPlaces),
		OrderType:        m.OrderType,
		Reference:        m.Reference,
		Description:      m.Description,
		ExtraData:        m.ExtraData.ToProtoStruct(),
		State:            commonv1.STATE(m.State),
	}
}

// --- Payment Routing RPCs ---

func (s *OperationsServer) IncomingPaymentNotify(
	ctx context.Context,
	req *connect.Request[operationsv1.IncomingPaymentNotifyRequest],
) (*connect.Response[operationsv1.IncomingPaymentNotifyResponse], error) {
	amount := moneyx.ToSmallestUnit(req.Msg.GetAmount(), moneyDecimalPlaces)
	currency := req.Msg.GetAmount().GetCurrencyCode()

	paymentData := map[string]interface{}{
		"transaction_id":  req.Msg.GetTransactionId(),
		"amount":          amount,
		"currency":        currency,
		"payer_reference": req.Msg.GetPayerReference(),
		"payer_name":      req.Msg.GetPayerName(),
		"product_id":      req.Msg.GetProductId(),
		"group_id":        req.Msg.GetGroupId(),
		"properties":      (&data.JSONMap{}).FromProtoStruct(req.Msg.GetProperties()),
	}

	result, err := s.prBusiness.IdentifyPayment(ctx, paymentData)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	paymentID, _ := result["payment_id"].(string)
	status, _ := result["strategy"].(string)
	if status == "" {
		status = "unidentified"
	}

	resultStruct := (&data.JSONMap{}).FromProtoStruct(nil)
	for k, v := range result {
		resultStruct[k] = v
	}

	audit.WithResource(ctx, audit.ResourcePayment, paymentID)
	audit.WithAction(ctx, "notify")
	audit.WithDetail(ctx, "transaction_id", req.Msg.GetTransactionId())
	audit.WithDetail(ctx, "status", status)

	return connect.NewResponse(&operationsv1.IncomingPaymentNotifyResponse{
		PaymentId: paymentID,
		Status:    status,
		Result:    resultStruct.ToProtoStruct(),
	}), nil
}

func (s *OperationsServer) PaymentAllocate(
	ctx context.Context,
	req *connect.Request[operationsv1.PaymentAllocateRequest],
) (*connect.Response[operationsv1.PaymentAllocateResponse], error) {
	result, err := s.prBusiness.AllocatePayment(ctx, req.Msg.GetPaymentId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	resultMap := data.JSONMap{}
	for k, v := range result {
		resultMap[k] = v
	}

	audit.WithResource(ctx, audit.ResourcePayment, req.Msg.GetPaymentId())
	audit.WithAction(ctx, "allocate")

	return connect.NewResponse(&operationsv1.PaymentAllocateResponse{
		Result: resultMap.ToProtoStruct(),
	}), nil
}
