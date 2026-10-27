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
	"strings"

	"github.com/antinvestor/service-fintech/pkg/transferorder"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	audit "github.com/antinvestor/common/audit"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/workerpool"
	moneyx "github.com/pitabwire/util/moneyx"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/antinvestor/service-fintech/apps/operations/service/business"
	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

const (
	propertyRemainingAmount = "remaining_amount"
	// defaultSearchLimit is used when a caller supplies a cursor without a
	// limit, or no cursor at all.
	defaultSearchLimit = 50
	// maxSearchLimit bounds how many transfer orders one search page may
	// return, so an unbounded caller limit cannot scan the whole table.
	maxSearchLimit = 200
)

// OperationsServer implements the OperationsService RPC handler.
// Tenant-level permission checks are handled by the FunctionAccessInterceptor.
type OperationsServer struct {
	toBusiness business.TransferOrderBusiness
	prBusiness business.PaymentRoutingBusiness
	toRepo     repository.TransferOrderRepository
	ipRepo     repository.IncomingPaymentRepository
	jobs       *business.OperationsJobs
	obBusiness business.ObligationBusiness

	operationsv1connect.UnimplementedOperationsServiceHandler
}

func NewOperationsServer(
	toBusiness business.TransferOrderBusiness,
	prBusiness business.PaymentRoutingBusiness,
	obBusiness business.ObligationBusiness,
	toRepo repository.TransferOrderRepository,
	ipRepo repository.IncomingPaymentRepository,
	jobs *business.OperationsJobs,
) operationsv1connect.OperationsServiceHandler {
	return &OperationsServer{
		toBusiness: toBusiness,
		prBusiness: prBusiness,
		obBusiness: obBusiness,
		ipRepo:     ipRepo,
		toRepo:     toRepo,
		jobs:       jobs,
	}
}

// maxJobBatch bounds one scheduled run.
const maxJobBatch = 5000

// OperationsJobRun runs one batch of a periodic job for the platform
// scheduler.
func (s *OperationsServer) OperationsJobRun(
	ctx context.Context,
	req *operationsv1.OperationsJobRunRequest,
) (*operationsv1.OperationsJobRunResponse, error) {
	if req.GetBatchSize() < 0 || req.GetBatchSize() > maxJobBatch {
		return nil, apperrors.CleanErr(apperrors.NewError(apperrors.BadRequest,
			"batch_size must be between 0 and 5000"))
	}
	processed, more, err := s.jobs.Run(ctx, req.GetJob(), int(req.GetBatchSize()))
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &operationsv1.OperationsJobRunResponse{
		Processed: int32(processed), //nolint:gosec // bounded by maxJobBatch per kind
		More:      more,
	}, nil
}

func (s *OperationsServer) TransferOrderExecute(
	ctx context.Context,
	req *operationsv1.TransferOrderExecuteRequest,
) (*operationsv1.TransferOrderExecuteResponse, error) {
	obj := req.GetData()
	if obj == nil {
		return nil, apperrors.CleanErr(apperrors.NewError(apperrors.BadRequest, "transfer order data is required"))
	}
	if obj.GetId() == "" {
		if validationErr := validateTransferOrderInput(obj); validationErr != nil {
			return nil, apperrors.CleanErr(validationErr)
		}
	}

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
	return &operationsv1.TransferOrderExecuteResponse{
		Data: transferOrderToAPI(result),
	}, nil
}

func (s *OperationsServer) TransferOrderSearch(
	ctx context.Context,
	req *operationsv1.TransferOrderSearchRequest,
	stream operationsv1connect.OperationsServiceTransferOrderSearchServerStream,
) error {
	var searchOpts []data.SearchOption

	offset := 0
	limit := defaultSearchLimit
	if cursor := req.GetCursor(); cursor != nil {
		if parsed, offsetErr := strconv.Atoi(cursor.GetPage()); offsetErr == nil && parsed > 0 {
			offset = parsed
		}
		limit = clampSearchLimit(int(cursor.GetLimit()))
	}
	searchOpts = append(searchOpts, data.WithSearchOffset(offset), data.WithSearchLimit(limit))

	andQueryVal := map[string]any{}
	if t := searchOrderType(req); t != 0 {
		andQueryVal["order_type = ?"] = t
	}
	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	if req.GetQuery() != "" {
		searchOpts = append(searchOpts,
			data.WithSearchFiltersOrByValue(
				map[string]any{
					"reference ILIKE ?":   "%" + req.GetQuery() + "%",
					"description ILIKE ?": "%" + req.GetQuery() + "%",
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

// clampSearchLimit keeps a caller-supplied page size within a sane band. Zero
// (the value a cursor carries when only a page was set) falls back to the
// default rather than to "no limit".
func clampSearchLimit(limit int) int {
	switch {
	case limit <= 0:
		return defaultSearchLimit
	case limit > maxSearchLimit:
		return maxSearchLimit
	default:
		return limit
	}
}

// validateTransferOrderInput rejects a new order that cannot post a balanced
// ledger transaction before any row is written.
func validateTransferOrderInput(obj *operationsv1.TransferOrderObject) error {
	switch {
	case obj.GetDebitAccountRef() == "":
		return apperrors.NewError(apperrors.BadRequest, "debit account ref is required")
	case obj.GetCreditAccountRef() == "":
		return apperrors.NewError(apperrors.BadRequest, "credit account ref is required")
	case obj.GetDebitAccountRef() == obj.GetCreditAccountRef():
		return apperrors.NewError(apperrors.BadRequest, "debit and credit account refs must differ")
	case obj.GetAmount().GetCurrencyCode() == "":
		return apperrors.NewError(apperrors.BadRequest, "amount currency code is required")
	case moneyx.ToSmallestUnit(obj.GetAmount(), moneyx.Decimals(obj.GetAmount().GetCurrencyCode())) <= 0:
		return apperrors.NewError(apperrors.BadRequest, "amount must be positive")
	case transferorder.TypeOf(obj) == 0:
		return apperrors.NewError(apperrors.BadRequest, "order type is required")
	case business.IsReservedReference(obj.GetReference()):
		return apperrors.NewError(apperrors.BadRequest, "the reference prefix is reserved for system orders")
	}
	return nil
}

// searchOrderType reads the type filter: transfer_type when set, else the
// deprecated order_type older callers send.
func searchOrderType(req *operationsv1.TransferOrderSearchRequest) int32 {
	if t := req.GetTransferType(); t != operationsv1.TransferOrderType_TRANSFER_ORDER_TYPE_UNSPECIFIED {
		return int32(t)
	}
	return req.GetOrderType() //nolint:staticcheck // legacy callers
}

// transferOrderFromAPI converts a proto TransferOrderObject to a TransferOrder model.
func transferOrderFromAPI(ctx context.Context, obj *operationsv1.TransferOrderObject) *models.TransferOrder {
	amount := moneyx.ToSmallestUnit(obj.GetAmount(), moneyx.Decimals(obj.GetAmount().GetCurrencyCode()))
	currency := obj.GetAmount().GetCurrencyCode()
	m := &models.TransferOrder{
		DebitAccountRef:  obj.GetDebitAccountRef(),
		CreditAccountRef: obj.GetCreditAccountRef(),
		Amount:           amount,
		Currency:         currency,
		OrderType:        transferorder.TypeOf(obj),
		Reference:        obj.GetReference(),
		Description:      obj.GetDescription(),
		State:            int32(obj.GetState()),
	}
	if obj.GetExtraData() != nil {
		m.ExtraData = (&data.JSONMap{}).FromProtoStruct(obj.GetExtraData())
		// The allocation path marks the orders it raises itself; a caller
		// cannot claim that provenance through the API.
		delete(m.ExtraData, "source")
	}
	m.GenID(ctx)
	if obj.GetId() != "" {
		m.ID = obj.GetId()
	}
	return m
}

// transferOrderToAPI converts a TransferOrder model to the proto TransferOrderObject.
func transferOrderToAPI(m *models.TransferOrder) *operationsv1.TransferOrderObject {
	return transferorder.Typed(&operationsv1.TransferOrderObject{
		Id:               m.GetID(),
		DebitAccountRef:  m.DebitAccountRef,
		CreditAccountRef: m.CreditAccountRef,
		Amount:           moneyx.FromMinorUnitsByCurrency(m.Currency, m.Amount),
		Reference:        m.Reference,
		Description:      m.Description,
		ExtraData:        m.ExtraData.ToProtoStruct(),
		State:            commonv1.STATE(m.State),
	}, int(m.OrderType))
}

// --- Payment Routing RPCs ---

func (s *OperationsServer) IncomingPaymentNotify(
	ctx context.Context,
	req *operationsv1.IncomingPaymentNotifyRequest,
) (*operationsv1.IncomingPaymentNotifyResponse, error) {
	// Money is announced only by the payment rail. A person announcing a
	// payment would be typing money into a borrower's loan.
	if claims := security.ClaimsFromContext(ctx); claims == nil || !claims.IsInternalSystem() {
		return nil, apperrors.CleanErr(business.ErrPaymentNotifyInternalOnly)
	}
	currency := req.GetAmount().GetCurrencyCode()
	amount := moneyx.ToSmallestUnit(req.GetAmount(), moneyx.Decimals(currency))

	paymentData := map[string]interface{}{
		"transaction_id":  req.GetTransactionId(),
		"amount":          amount,
		"currency":        currency,
		"payer_reference": req.GetPayerReference(),
		"payer_name":      req.GetPayerName(),
		"product_id":      req.GetProductId(),
		"group_id":        req.GetGroupId(),
		"properties":      (&data.JSONMap{}).FromProtoStruct(req.GetProperties()),
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
	audit.WithDetail(ctx, "transaction_id", req.GetTransactionId())
	audit.WithDetail(ctx, "status", status)

	return &operationsv1.IncomingPaymentNotifyResponse{
		PaymentId: paymentID,
		Status:    status,
		Result:    resultStruct.ToProtoStruct(),
	}, nil
}

func (s *OperationsServer) PaymentAllocate(
	ctx context.Context,
	req *operationsv1.PaymentAllocateRequest,
) (*operationsv1.PaymentAllocateResponse, error) {
	result, err := s.prBusiness.AllocatePayment(ctx, req.GetPaymentId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	resultMap := data.JSONMap{}
	for k, v := range result {
		resultMap[k] = v
	}

	audit.WithResource(ctx, audit.ResourcePayment, req.GetPaymentId())
	audit.WithAction(ctx, "allocate")

	return &operationsv1.PaymentAllocateResponse{
		Result: resultMap.ToProtoStruct(),
	}, nil
}

func (s *OperationsServer) IncomingPaymentSearch(
	ctx context.Context,
	req *operationsv1.IncomingPaymentSearchRequest,
	stream operationsv1connect.OperationsServiceIncomingPaymentSearchServerStream,
) error {
	offset := 0
	limit := defaultSearchLimit
	if cursor := req.GetCursor(); cursor != nil {
		if parsed, offsetErr := strconv.Atoi(cursor.GetPage()); offsetErr == nil && parsed > 0 {
			offset = parsed
		}
		limit = clampSearchLimit(int(cursor.GetLimit()))
	}
	searchOpts := []data.SearchOption{data.WithSearchOffset(offset), data.WithSearchLimit(limit)}

	andQueryVal := map[string]any{}
	if req.GetUnmatchedOnly() {
		andQueryVal["coalesce(owner_id, '') = ?"] = ""
		andQueryVal["state = ?"] = constants.StateJustCreated
	}
	if productID := strings.TrimSpace(req.GetProductId()); productID != "" {
		andQueryVal["properties ->> 'product_id' = ?"] = productID
	}
	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}
	if q := strings.TrimSpace(req.GetQuery()); q != "" {
		like := "%" + q + "%"
		searchOpts = append(searchOpts, data.WithSearchFiltersOrByValue(map[string]any{
			"transaction_id ILIKE ?":              like,
			"properties ->> 'reference' ILIKE ?":  like,
			"properties ->> 'payer_name' ILIKE ?": like,
		}))
	}

	results, err := s.ipRepo.Search(ctx, data.NewSearchQuery(searchOpts...))
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return workerpool.ConsumeResultStream(ctx, results, func(batch []*models.IncomingPayment) error {
		out := make([]*operationsv1.IncomingPaymentObject, 0, len(batch))
		for _, payment := range batch {
			out = append(out, incomingPaymentToAPI(payment))
		}
		return stream.Send(&operationsv1.IncomingPaymentSearchResponse{Data: out})
	})
}

func (s *OperationsServer) IncomingPaymentAssign(
	ctx context.Context,
	req *operationsv1.IncomingPaymentAssignRequest,
) (*operationsv1.IncomingPaymentAssignResponse, error) {
	audit.WithResource(ctx, audit.ResourcePayment, req.GetPaymentId())
	audit.WithAction(ctx, "assign")
	audit.WithDetail(ctx, "loan_account_id", req.GetLoanAccountId())
	audit.WithDetail(ctx, "savings_account_id", req.GetSavingsAccountId())

	payment, allocation, err := s.prBusiness.AssignPayment(
		ctx, req.GetPaymentId(), req.GetLoanAccountId(), req.GetSavingsAccountId(), req.GetNote(),
	)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	allocationMap := data.JSONMap(allocation)
	return &operationsv1.IncomingPaymentAssignResponse{
		Data:       incomingPaymentToAPI(payment),
		Allocation: allocationMap.ToProtoStruct(),
	}, nil
}

// incomingPaymentToAPI converts a stored payment. The payer reference the
// rail supplied (often a phone number) is deliberately left out.
func incomingPaymentToAPI(m *models.IncomingPayment) *operationsv1.IncomingPaymentObject {
	props := m.Properties
	remaining := m.Amount
	if raw, ok := props[propertyRemainingAmount]; ok {
		switch typed := raw.(type) {
		case float64:
			remaining = int64(typed)
		case int64:
			remaining = typed
		}
	}
	return &operationsv1.IncomingPaymentObject{
		Id:                     m.GetID(),
		TransactionId:          m.TransactionID,
		Amount:                 moneyx.FromMinorUnitsByCurrency(m.Currency, m.Amount),
		PayerName:              props.GetString("payer_name"),
		Reference:              props.GetString("reference"),
		ProductId:              props.GetString("product_id"),
		Matched:                m.OwnerID != "",
		ClientId:               props.GetString("client_id"),
		LoanAccountId:          props.GetString("loan_id"),
		IdentificationStrategy: props.GetString("identification_strategy"),
		Unallocated:            moneyx.FromMinorUnitsByCurrency(m.Currency, remaining),
		State:                  paymentStateToAPI(m.State),
		ReceivedAt:             timestamppb.New(m.CreatedAt),
		AssignedBy:             props.GetString("assigned_by"),
		AssignmentNote:         props.GetString("assignment_note"),
		SavingsAccountId:       props.GetString("savings_account_id"),
	}
}

// paymentStateToAPI maps the stored state, which follows pkg/constants
// (just created = 1), onto the proto STATE (created = 0).
func paymentStateToAPI(state int32) commonv1.STATE {
	switch state {
	case constants.StateJustCreated:
		return commonv1.STATE_CREATED
	case constants.StateCheckCreated:
		return commonv1.STATE_CHECKED
	case constants.StateActive:
		return commonv1.STATE_ACTIVE
	case constants.StateInactive:
		return commonv1.STATE_INACTIVE
	case constants.StateDeleted:
		return commonv1.STATE_DELETED
	default:
		return commonv1.STATE_CREATED
	}
}
