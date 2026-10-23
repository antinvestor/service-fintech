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
	"strconv"
	"time"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
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
	scope             *ReadScope
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
	opts ...Option,
) LoanRequestBusiness {
	return &loanRequestBusiness{
		scope:             applyOptions(opts).scope,
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
	if lr == nil {
		return nil, apperrors.NewError(apperrors.BadRequest, "loan request payload is required")
	}

	if lr.Status == int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_UNSPECIFIED) {
		lr.Status = int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_DRAFT)
	}

	// Save is the borrower-facing write. Everything past SUBMITTED is a
	// decision, and decisions are made by Approve/Reject/Cancel where the
	// limits gate and the product requirement checks live. Accepting a
	// client-supplied APPROVED here would route around both.
	if !isClientSettableRequestStatus(lr.Status) {
		return nil, ErrLoanRequestStatusNotSettable
	}

	existing, existErr := b.loanRequestRepo.GetByID(ctx, lr.GetID())
	if existErr == nil && existing != nil {
		if isTerminalLoanRequestStatus(existing.Status) ||
			existing.Status == int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED) {
			return nil, ErrLoanRequestTerminal
		}
		if lr.Status < existing.Status {
			return nil, ErrLoanRequestStatusRegression
		}
		// Decision fields belong to the reviewer, not to the submitter.
		lr.ApprovedAmount = existing.ApprovedAmount
		lr.ApprovedTermDays = existing.ApprovedTermDays
		lr.RejectionReason = existing.RejectionReason
		lr.DecidedAt = existing.DecidedAt
		lr.LoanAccountID = existing.LoanAccountID
	} else {
		lr.ApprovedAmount = 0
		lr.ApprovedTermDays = 0
		lr.DecidedAt = nil
		lr.LoanAccountID = ""
	}

	if lr.Status == int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED) && lr.SubmittedAt == nil {
		now := time.Now().UTC()
		lr.SubmittedAt = &now
	}

	if err := b.validateAgainstProduct(ctx, lr); err != nil {
		return nil, err
	}

	if err := b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr); err != nil {
		logger.WithError(err).Error("could not emit loan request save event")
		return nil, err
	}

	return lr.ToAPI(), nil
}

// isClientSettableRequestStatus reports whether a caller of Save may put a
// request into this status directly.
func isClientSettableRequestStatus(status int32) bool {
	return status == int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_DRAFT) ||
		status == int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED)
}

// validateAgainstProduct rejects a request whose amount or term falls outside
// the product's configured envelope. A request that cannot become a legal loan
// should never reach an approver's queue.
func (b *loanRequestBusiness) validateAgainstProduct(ctx context.Context, lr *models.LoanRequest) error {
	if lr.RequestedAmount <= 0 {
		return ErrLoanRequestAmountInvalid
	}
	if lr.RequestedTermDays <= 0 {
		return ErrLoanRequestTermInvalid
	}
	if lr.ProductID == "" {
		return nil
	}

	product, err := b.loanProductRepo.GetByID(ctx, lr.ProductID)
	if err != nil || product == nil {
		return ErrLoanProductNotFound
	}

	if product.CurrencyCode != "" && lr.CurrencyCode != "" && product.CurrencyCode != lr.CurrencyCode {
		return ErrLoanRequestCurrencyMismatch
	}
	if product.MinAmount > 0 && lr.RequestedAmount < product.MinAmount {
		return ErrLoanRequestAmountOutOfRange
	}
	if product.MaxAmount > 0 && lr.RequestedAmount > product.MaxAmount {
		return ErrLoanRequestAmountOutOfRange
	}
	if product.MinTermDays > 0 && lr.RequestedTermDays < product.MinTermDays {
		return ErrLoanRequestTermOutOfRange
	}
	if product.MaxTermDays > 0 && lr.RequestedTermDays > product.MaxTermDays {
		return ErrLoanRequestTermOutOfRange
	}

	return nil
}

func (b *loanRequestBusiness) Get(ctx context.Context, id string) (*loansv1.LoanRequestObject, error) {
	lr, err := b.loanRequestRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrLoanRequestNotFound
	}
	if scopeErr := b.scope.AuthorizeClient(ctx, lr.ClientID); scopeErr != nil {
		return nil, scopeErr
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
				map[string]any{searchableTSQuery: req.GetQuery()},
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
	if !b.limitsGateEnabled || b.limitsCli == nil || b.limitsGateMode == gateModeOff {
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
		// Wrapped rather than replaced, so callers that inspect the chain for
		// a pending reservation still find it.
		return nil, connect.NewError(connect.CodeFailedPrecondition, gateErr)
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

	now := time.Now().UTC()
	if lr.OfferExpiresAt != nil && lr.OfferExpiresAt.Before(now) {
		return nil, ErrLoanRequestOfferExpired
	}

	// Approval confirms what was requested unless a reviewer has already
	// recorded different terms. Deriving the approved terms here keeps the
	// amount that becomes a loan tied to the amount that was validated
	// against the product on submission.
	if lr.ApprovedAmount == 0 {
		lr.ApprovedAmount = lr.RequestedAmount
	}
	if lr.ApprovedTermDays == 0 {
		lr.ApprovedTermDays = lr.RequestedTermDays
	}
	if err = b.validateApprovedTerms(ctx, lr); err != nil {
		return nil, err
	}

	lr.Status = int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED)
	lr.DecidedAt = &now

	if errEmit := b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr); errEmit != nil {
		logger.WithError(errEmit).Error("could not emit loan request approve event")
		return nil, errEmit
	}

	return lr.ToAPI(), nil
}

// validateApprovedTerms checks the terms a loan will actually be written on
// against the product envelope, not just the terms that were asked for.
func (b *loanRequestBusiness) validateApprovedTerms(ctx context.Context, lr *models.LoanRequest) error {
	if lr.ApprovedAmount <= 0 {
		return ErrLoanRequestAmountInvalid
	}
	if lr.ApprovedTermDays <= 0 {
		return ErrLoanRequestTermInvalid
	}
	if lr.ProductID == "" {
		return nil
	}

	product, err := b.loanProductRepo.GetByID(ctx, lr.ProductID)
	if err != nil || product == nil {
		return ErrLoanProductNotFound
	}
	if product.MinAmount > 0 && lr.ApprovedAmount < product.MinAmount {
		return ErrLoanRequestAmountOutOfRange
	}
	if product.MaxAmount > 0 && lr.ApprovedAmount > product.MaxAmount {
		return ErrLoanRequestAmountOutOfRange
	}
	if product.MinTermDays > 0 && lr.ApprovedTermDays < product.MinTermDays {
		return ErrLoanRequestTermOutOfRange
	}
	if product.MaxTermDays > 0 && lr.ApprovedTermDays > product.MaxTermDays {
		return ErrLoanRequestTermOutOfRange
	}
	return nil
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
