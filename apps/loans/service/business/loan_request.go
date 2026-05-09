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

package business

import (
	"context"
	"errors"
	"fmt"
	"strconv"
	"time"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/frame/data"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

type LoanRequestBusiness interface {
	Save(ctx context.Context, obj *loansv1.LoanRequestObject) (*loansv1.LoanRequestObject, error)
	Get(ctx context.Context, id string) (*loansv1.LoanRequestObject, error)
	GetModel(ctx context.Context, id string) (*models.LoanRequest, error)
	Search(
		ctx context.Context,
		req *loansv1.LoanRequestSearchRequest,
		consumer func(ctx context.Context, batch []*loansv1.LoanRequestObject) error,
	) error
	Approve(ctx context.Context, id string) (*loansv1.LoanRequestObject, error)
	Reject(ctx context.Context, id string, reason string) (*loansv1.LoanRequestObject, error)
	Cancel(ctx context.Context, id string, reason string) (*loansv1.LoanRequestObject, error)
}

type loanRequestBusiness struct {
	eventsMan         fevents.Manager
	loanRequestRepo   repository.LoanRequestRepository
	loanProductRepo   repository.LoanProductRepository
	limitsCli         limitsv1connect.LimitsServiceClient
	limitsGateEnabled bool
	limitsGateMode    string
}

func NewLoanRequestBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	loanRequestRepo repository.LoanRequestRepository,
	loanProductRepo repository.LoanProductRepository,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsGateEnabled bool,
	limitsGateMode string,
) LoanRequestBusiness {
	return &loanRequestBusiness{
		eventsMan:         eventsMan,
		loanRequestRepo:   loanRequestRepo,
		loanProductRepo:   loanProductRepo,
		limitsCli:         limitsCli,
		limitsGateEnabled: limitsGateEnabled,
		limitsGateMode:    limitsGateMode,
	}
}

func (b *loanRequestBusiness) Save(
	ctx context.Context,
	obj *loansv1.LoanRequestObject,
) (*loansv1.LoanRequestObject, error) {
	logger := util.Log(ctx).WithField("method", "LoanRequestBusiness.Save")

	lr := models.LoanRequestFromAPI(ctx, obj)

	if lr.Status == 0 {
		lr.Status = int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_DRAFT)
	}

	err := b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr)
	if err != nil {
		logger.WithError(err).Error("could not emit loan request save event")
		return nil, err
	}

	return lr.ToAPI(), nil
}

func (b *loanRequestBusiness) Get(ctx context.Context, id string) (*loansv1.LoanRequestObject, error) {
	lr, err := b.loanRequestRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrLoanRequestNotFound
	}
	return lr.ToAPI(), nil
}

func (b *loanRequestBusiness) GetModel(ctx context.Context, id string) (*models.LoanRequest, error) {
	lr, err := b.loanRequestRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrLoanRequestNotFound
	}
	return lr, nil
}

func (b *loanRequestBusiness) Search(
	ctx context.Context,
	req *loansv1.LoanRequestSearchRequest,
	consumer func(ctx context.Context, batch []*loansv1.LoanRequestObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "LoanRequestBusiness.Search")

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
	if req.GetClientId() != "" {
		andQueryVal["client_id = ?"] = req.GetClientId()
	}
	if req.GetAgentId() != "" {
		andQueryVal["agent_id = ?"] = req.GetAgentId()
	}
	if req.GetBranchId() != "" {
		andQueryVal["branch_id = ?"] = req.GetBranchId()
	}
	if req.GetOrganizationId() != "" {
		andQueryVal["organization_id = ?"] = req.GetOrganizationId()
	}
	if req.GetStatus() != loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_UNSPECIFIED {
		andQueryVal["status = ?"] = int32(req.GetStatus())
	}
	if req.GetSourceService() != "" {
		andQueryVal["source_service = ?"] = req.GetSourceService()
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	if req.GetQuery() != "" {
		searchOpts = append(searchOpts,
			data.WithSearchFiltersOrByValue(
				map[string]any{"searchable @@ websearch_to_tsquery( 'english', ?) ": req.GetQuery()},
			),
		)
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.loanRequestRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search loan requests")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.LoanRequest) error {
		var apiResults []*loansv1.LoanRequestObject
		for _, lr := range res {
			apiResults = append(apiResults, lr.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}

func (b *loanRequestBusiness) Approve(ctx context.Context, id string) (*loansv1.LoanRequestObject, error) {
	if !b.limitsGateEnabled || b.limitsCli == nil || b.limitsGateMode == "off" {
		return b.approveInner(ctx, id)
	}

	// Load the request to build the intent before the gate.
	lr, err := b.loanRequestRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrLoanRequestNotFound
	}

	intent := &limitsv1.LimitIntent{
		Action: limitsv1.LimitAction_LIMIT_ACTION_LOAN_REQUEST,
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: lr.ClientID},
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: lr.OrganizationID},
		},
		TenantId: lr.OrganizationID,
		Amount:   moneyx.FromMinorUnitsByCurrency(lr.CurrencyCode, lr.RequestedAmount),
		MakerId:  callerSubject(ctx),
	}
	idemKey := "loan_request_approval:" + id

	var result *loansv1.LoanRequestObject
	gateErr := limits.Gate(ctx, b.limitsCli, intent, idemKey, limits.ParseMode(b.limitsGateMode),
		func(innerCtx context.Context, reservationID string) error {
			util.Log(innerCtx).
				With("limits_reservation_id", reservationID).
				Info("loan request approval gated by limits")
			inner, innerErr := b.approveInner(innerCtx, id)
			if innerErr != nil {
				return innerErr
			}
			result = inner
			return nil
		})

	var pendingErr *limits.PendingApprovalError
	if errors.As(gateErr, &pendingErr) {
		return nil, fmt.Errorf("loan request approval requires approval (reservation %s): %w",
			pendingErr.ReservationID, gateErr)
	}
	if gateErr != nil {
		return nil, gateErr
	}
	return result, nil
}

// approveInner is the pre-Gate body factored out so Gate's handler can wrap it.
func (b *loanRequestBusiness) approveInner(ctx context.Context, id string) (*loansv1.LoanRequestObject, error) {
	logger := util.Log(ctx).WithField("method", "LoanRequestBusiness.Approve")

	lr, err := b.loanRequestRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrLoanRequestNotFound
	}

	if lr.Status != int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED) {
		return nil, ErrLoanRequestNotSubmitted
	}

	// Verification gate: if the product has required forms, the caller must
	// confirm that all required data has been verified by setting the
	// "data_verification_confirmed" property to true on the loan request.
	if errReq := b.enforceProductRequirements(ctx, logger, lr); errReq != nil {
		return nil, errReq
	}

	now := time.Now()
	lr.Status = int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED)
	lr.DecidedAt = &now

	if errEmit := b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr); errEmit != nil {
		logger.WithError(errEmit).Error("could not emit loan request approve event")
		return nil, errEmit
	}

	return lr.ToAPI(), nil
}

func (b *loanRequestBusiness) Reject(
	ctx context.Context,
	id string,
	reason string,
) (*loansv1.LoanRequestObject, error) {
	logger := util.Log(ctx).WithField("method", "LoanRequestBusiness.Reject")

	lr, err := b.loanRequestRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrLoanRequestNotFound
	}

	if isTerminalLoanRequestStatus(lr.Status) {
		return nil, ErrLoanRequestTerminal
	}

	now := time.Now()
	lr.Status = int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_REJECTED)
	lr.RejectionReason = reason
	lr.DecidedAt = &now

	if errEmit := b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr); errEmit != nil {
		logger.WithError(errEmit).Error("could not emit loan request reject event")
		return nil, errEmit
	}

	return lr.ToAPI(), nil
}

func (b *loanRequestBusiness) Cancel(
	ctx context.Context,
	id string,
	reason string,
) (*loansv1.LoanRequestObject, error) {
	logger := util.Log(ctx).WithField("method", "LoanRequestBusiness.Cancel")

	lr, err := b.loanRequestRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrLoanRequestNotFound
	}

	if isTerminalLoanRequestStatus(lr.Status) {
		return nil, ErrLoanRequestTerminal
	}

	lr.Status = int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_CANCELLED)
	lr.RejectionReason = reason

	if errEmit := b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr); errEmit != nil {
		logger.WithError(errEmit).Error("could not emit loan request cancel event")
		return nil, errEmit
	}

	return lr.ToAPI(), nil
}

// enforceProductRequirements checks that the loan product's required forms
// have been satisfied before allowing approval. If the product has required
// forms, the loan request must have "data_verification_confirmed" set to true
// in its properties — this is set by the product service (seed, stawi) after
// it has verified all required data via the identity service.
func (b *loanRequestBusiness) enforceProductRequirements(
	ctx context.Context,
	logger *util.LogEntry,
	lr *models.LoanRequest,
) error {
	if lr.ProductID == "" {
		return nil // No product, no requirements
	}

	product, err := b.loanProductRepo.GetByID(ctx, lr.ProductID)
	if err != nil {
		logger.WithError(err).Warn("could not fetch loan product for requirement check")
		return nil // Product not found locally — allow (product may be external)
	}

	requiredForms := models.RequiredFormsToAPI(product.RequiredForms)
	if len(requiredForms) == 0 {
		return nil // No required forms on this product
	}

	// Count how many forms are marked as required
	requiredCount := 0
	for _, rf := range requiredForms {
		if rf.GetRequired() {
			requiredCount++
		}
	}
	if requiredCount == 0 {
		return nil // Forms exist but none are mandatory
	}

	// The product service must set this property after verifying client data
	// against identity service (FormSubmission + ClientDataEntry checks).
	confirmed, _ := lr.Properties["data_verification_confirmed"].(bool)
	if !confirmed {
		logger.WithField("product_id", lr.ProductID).
			WithField("required_forms", requiredCount).
			Warn("loan request approval blocked — product requires data verification")
		return ErrDataVerificationRequired
	}

	return nil
}

func isTerminalLoanRequestStatus(status int32) bool {
	switch loansv1.LoanRequestStatus(status) { //nolint:exhaustive // only terminal states matter
	case loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_LOAN_CREATED,
		loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_CANCELLED,
		loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_REJECTED,
		loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_EXPIRED:
		return true
	default:
		return false
	}
}
