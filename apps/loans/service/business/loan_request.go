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

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/audit"
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
	notifier          *LoanNotifier
	auditWriter       *audit.Writer
}

// reservedRequestProperties are keys only staff or a service principal may
// write on a request: they steer verification and where the money goes.
func reservedRequestProperties() []string {
	return []string{
		"data_verification_confirmed",
		"payment_account_ref",
		"payment_channel",
		"loan_request_id",
		"funding_fully_funded",
		"funding_allocations",
	}
}

const (
	colDecidedAt   = "decided_at"
	colDecidedBy   = "decided_by"
	fieldProductID = "product_id"
	fieldAgentID   = "agent_id"
)

// sanitizeRequestProperties strips the reserved keys from a request written
// by a client caller. Staff and service principals keep them.
func (b *loanRequestBusiness) sanitizeRequestProperties(ctx context.Context, lr *models.LoanRequest) {
	if lr.Properties == nil || b.scope.IsStaff(ctx) {
		return
	}
	for _, key := range reservedRequestProperties() {
		delete(lr.Properties, key)
	}
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
	o := applyOptions(opts)
	return &loanRequestBusiness{
		scope:             o.scope,
		notifier:          o.notifier,
		auditWriter:       o.auditWriter,
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

	// Whoever writes an application must be allowed to act for its client:
	// staff and field agents (configured staff roles) for anyone, a client
	// caller only for themselves. Checked before anything is persisted or
	// anyone is messaged.
	if scopeErr := b.scope.AuthorizeClient(ctx, lr.ClientID); scopeErr != nil {
		return nil, scopeErr
	}
	b.sanitizeRequestProperties(ctx, lr)

	existing, reconcileErr := b.reconcileWithStored(ctx, lr)
	if reconcileErr != nil {
		return nil, reconcileErr
	}

	submittedNow := lr.Status == int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED) &&
		(existing == nil || existing.Status != lr.Status)
	if submittedNow {
		now := time.Now().UTC()
		lr.SubmittedAt = &now
		lr.SubmittedBy = callerSubject(ctx)
	}

	if err := b.validateAgainstProduct(ctx, lr); err != nil {
		return nil, err
	}

	if err := b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr); err != nil {
		logger.WithError(err).Error("could not emit loan request save event")
		return nil, err
	}

	// The borrower hears about the submission once: the first save that
	// lands on SUBMITTED. Re-saves of a submitted request stay silent.
	if submittedNow {
		b.recordRequestAudit(ctx, lr, "loan_request.submitted", "", nil)
		b.notifier.NotifyApplicationSubmitted(ctx, lr)
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
// reconcileWithStored applies the rules a re-save of an existing request must
// obey and copies the reviewer-owned and identity fields from the stored row.
// It returns the stored row (nil for a new request).
func (b *loanRequestBusiness) reconcileWithStored(
	ctx context.Context,
	lr *models.LoanRequest,
) (*models.LoanRequest, error) {
	existing, existErr := b.loanRequestRepo.GetByID(ctx, lr.GetID())
	if existErr != nil && !data.ErrorIsNoRows(existErr) && !errors.Is(existErr, ErrLoanRequestNotFound) {
		return nil, fmt.Errorf("load loan request %s: %w", lr.GetID(), existErr)
	}
	if existing == nil {
		lr.ApprovedAmount = 0
		lr.ApprovedTermDays = 0
		lr.DecidedAt = nil
		lr.LoanAccountID = ""
		return nil, nil //nolint:nilnil // a new request has no stored row
	}
	if isTerminalLoanRequestStatus(existing.Status) ||
		existing.Status == int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED) {
		return nil, ErrLoanRequestTerminal
	}
	if lr.Status < existing.Status {
		return nil, ErrLoanRequestStatusRegression
	}
	// Who the application is for and who brought it in are fixed at
	// creation. A re-save cannot move it to another client or agent.
	if existing.ClientID != lr.ClientID {
		return nil, ErrLoanRequestClientImmutable
	}
	lr.AgentID = existing.AgentID
	lr.OrganizationID = existing.OrganizationID
	lr.BranchID = existing.BranchID
	lr.SubmittedAt = existing.SubmittedAt
	lr.SubmittedBy = existing.SubmittedBy
	lr.DecidedBy = existing.DecidedBy
	// Decision fields belong to the reviewer, not to the submitter.
	lr.ApprovedAmount = existing.ApprovedAmount
	lr.ApprovedTermDays = existing.ApprovedTermDays
	lr.RejectionReason = existing.RejectionReason
	lr.DecidedAt = existing.DecidedAt
	lr.LoanAccountID = existing.LoanAccountID
	return existing, nil
}

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
		},
		limits.InPartition(lr.TenantID, lr.PartitionID),
	)

	var pendingErr *limits.PendingApprovalError
	if errors.As(gateErr, &pendingErr) {
		// Wrapped rather than replaced, so callers that inspect the chain for
		// a pending reservation still find it.
		return nil, connect.NewError(connect.CodeFailedPrecondition, gateErr.Error()).WithCause(gateErr)
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

	decider := callerSubject(ctx)
	if err = requireSeparationOfDuties(lr, decider); err != nil {
		return nil, err
	}

	// The decision is a conditional write on the status that was read, so an
	// approve racing a reject (or a second approve) converges on one winner.
	// The in-memory copy is updated only once the row has moved.
	claimed, claimErr := b.loanRequestRepo.ClaimStatus(ctx, lr.GetID(),
		[]int32{int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED)},
		int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED),
		map[string]any{
			"approved_amount":    lr.ApprovedAmount,
			"approved_term_days": lr.ApprovedTermDays,
			colDecidedAt:         now,
			colDecidedBy:         decider,
		})
	if claimErr != nil {
		logger.WithError(claimErr).Error("could not record loan request approval")
		return nil, claimErr
	}
	if !claimed {
		return nil, ErrLoanRequestDecisionConflict
	}
	lr.Status = int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED)
	lr.DecidedAt = &now
	lr.DecidedBy = decider

	if errEmit := b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr); errEmit != nil {
		logger.WithError(errEmit).Error("could not emit loan request approve event")
	}

	b.recordRequestAudit(ctx, lr, "loan_request.approved", "", data.JSONMap{
		"approved_amount":    lr.ApprovedAmount,
		"approved_term_days": lr.ApprovedTermDays,
	})
	b.notifier.NotifyApplicationApproved(ctx, lr)

	return lr.ToAPI(), nil
}

// requireSeparationOfDuties refuses a decision by the person who submitted
// the application (or created it, for requests submitted before submitters
// were recorded). A field agent cannot approve their own client's loan.
func requireSeparationOfDuties(lr *models.LoanRequest, decider string) error {
	if decider == "" {
		return nil
	}
	for _, maker := range []string{lr.SubmittedBy, lr.CreatedBy, lr.AgentID} {
		if maker != "" && maker == decider {
			return ErrLoanRequestSelfDecision
		}
	}
	return nil
}

// recordRequestAudit writes one descriptive audit record for a request
// lifecycle action, with the actor from the caller's claims.
func (b *loanRequestBusiness) recordRequestAudit(
	ctx context.Context,
	lr *models.LoanRequest,
	action, reason string,
	after data.JSONMap,
) {
	if b.auditWriter == nil {
		return
	}
	if after == nil {
		after = data.JSONMap{}
	}
	after[fieldStatus] = loansv1.LoanRequestStatus(lr.Status).String()
	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: "loan_request",
		EntityID:   lr.GetID(),
		Action:     action,
		Reason:     reason,
		After:      after,
		Metadata: data.JSONMap{
			fieldClientID:      lr.ClientID,
			fieldAgentID:       lr.AgentID,
			fieldProductID:     lr.ProductID,
			"requested_amount": lr.RequestedAmount,
			fieldCurrency:      lr.CurrencyCode,
		},
		Parent: &lr.BaseModel,
	}, func(err error) {
		util.Log(ctx).WithError(err).Warn("audit emission failed for loan request")
	})
}

// nonTerminalRequestStatuses lists the statuses a decision may still be
// taken from.
func nonTerminalRequestStatuses() []int32 {
	out := make([]int32, 0, len(loansv1.LoanRequestStatus_name))
	for v := range loansv1.LoanRequestStatus_name {
		if v == int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_UNSPECIFIED) || isTerminalLoanRequestStatus(v) {
			continue
		}
		out = append(out, v)
	}
	return out
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

	decider := callerSubject(ctx)
	if err = requireSeparationOfDuties(lr, decider); err != nil {
		return nil, err
	}

	now := time.Now().UTC()
	claimed, claimErr := b.loanRequestRepo.ClaimStatus(ctx, lr.GetID(), nonTerminalRequestStatuses(),
		int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_REJECTED),
		map[string]any{"rejection_reason": reason, colDecidedAt: now, colDecidedBy: decider})
	if claimErr != nil {
		logger.WithError(claimErr).Error("could not record loan request rejection")
		return nil, claimErr
	}
	if !claimed {
		return nil, ErrLoanRequestDecisionConflict
	}
	lr.Status = int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_REJECTED)
	lr.RejectionReason = reason
	lr.DecidedAt = &now
	lr.DecidedBy = decider

	if errEmit := b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr); errEmit != nil {
		logger.WithError(errEmit).Error("could not emit loan request reject event")
	}

	b.recordRequestAudit(ctx, lr, "loan_request.rejected", reason, nil)
	b.notifier.NotifyApplicationRejected(ctx, lr)

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

	// Cancelling is the applicant's (or their agent's) act, so the caller
	// must be allowed to act for the client; no separation of duties applies.
	if scopeErr := b.scope.AuthorizeClient(ctx, lr.ClientID); scopeErr != nil {
		return nil, scopeErr
	}

	now := time.Now().UTC()
	actor := callerSubject(ctx)
	claimed, claimErr := b.loanRequestRepo.ClaimStatus(ctx, lr.GetID(), nonTerminalRequestStatuses(),
		int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_CANCELLED),
		map[string]any{"rejection_reason": reason, colDecidedAt: now, colDecidedBy: actor})
	if claimErr != nil {
		logger.WithError(claimErr).Error("could not record loan request cancellation")
		return nil, claimErr
	}
	if !claimed {
		return nil, ErrLoanRequestDecisionConflict
	}
	lr.Status = int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_CANCELLED)
	lr.RejectionReason = reason
	lr.DecidedAt = &now
	lr.DecidedBy = actor

	if errEmit := b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr); errEmit != nil {
		logger.WithError(errEmit).Error("could not emit loan request cancel event")
	}

	b.recordRequestAudit(ctx, lr, "loan_request.cancelled", reason, nil)
	b.notifier.NotifyApplicationCancelled(ctx, lr)

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
