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
	"strconv"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

type LoanRestructureBusiness interface {
	Create(ctx context.Context, obj *loansv1.LoanRestructureObject) (*loansv1.LoanRestructureObject, error)
	Approve(ctx context.Context, id string) (*loansv1.LoanRestructureObject, error)
	Reject(ctx context.Context, id, reason string) (*loansv1.LoanRestructureObject, error)
	Search(
		ctx context.Context,
		req *loansv1.LoanRestructureSearchRequest,
		consumer func(ctx context.Context, batch []*loansv1.LoanRestructureObject) error,
	) error
}

type loanRestructureBusiness struct {
	eventsMan           fevents.Manager
	loanRestructureRepo repository.LoanRestructureRepository
	loanAccountRepo     repository.LoanAccountRepository
	loanBalanceRepo     repository.LoanBalanceRepository
	scheduleRepo        repository.RepaymentScheduleRepository
	laBusiness          LoanAccountBusiness
	scheduleBusiness    RepaymentScheduleBusiness
	notifier            *LoanNotifier
	scope               *ReadScope
}

func NewLoanRestructureBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	loanRestructureRepo repository.LoanRestructureRepository,
	loanAccountRepo repository.LoanAccountRepository,
	loanBalanceRepo repository.LoanBalanceRepository,
	scheduleRepo repository.RepaymentScheduleRepository,
	laBusiness LoanAccountBusiness,
	scheduleBusiness RepaymentScheduleBusiness,
	opts ...Option,
) LoanRestructureBusiness {
	return &loanRestructureBusiness{
		notifier:            applyOptions(opts).notifier,
		scope:               applyOptions(opts).scope,
		eventsMan:           eventsMan,
		loanRestructureRepo: loanRestructureRepo,
		loanAccountRepo:     loanAccountRepo,
		loanBalanceRepo:     loanBalanceRepo,
		scheduleRepo:        scheduleRepo,
		laBusiness:          laBusiness,
		scheduleBusiness:    scheduleBusiness,
	}
}

func (b *loanRestructureBusiness) Create(
	ctx context.Context,
	obj *loansv1.LoanRestructureObject,
) (*loansv1.LoanRestructureObject, error) {
	logger := util.Log(ctx).WithField("method", "LoanRestructureBusiness.Create")

	lr := models.LoanRestructureFromAPI(ctx, obj)
	if lr == nil {
		return nil, apperrors.NewError(apperrors.BadRequest, "restructure payload is required")
	}
	if lr.LoanAccountID == "" {
		return nil, ErrRestructureLoanAccountRequired
	}
	if err := validateRestructureType(lr.RestructureType); err != nil {
		return nil, err
	}
	if lr.NewTermDays < 0 || lr.NewInterestRate < 0 {
		return nil, ErrRestructureTermsInvalid
	}

	la, laErr := b.loanAccountRepo.GetByID(ctx, lr.LoanAccountID)
	if laErr != nil {
		return nil, ErrLoanAccountNotFound
	}
	if !restructureAllowed(lr.RestructureType, la.Status) {
		return nil, ErrRestructureLoanNotEligible
	}

	// The requester is whoever is authenticated, never whoever the payload
	// claims: a restructure is a credit decision with a maker on it.
	lr.RequestedBy = callerSubject(ctx)
	lr.ApprovedBy = ""
	lr.OldInterestRate = la.InterestRate
	lr.OldTermDays = la.TermDays
	lr.CurrencyCode = la.CurrencyCode
	lr.NewScheduleID = ""
	lr.State = int32(commonv1.STATE_CREATED)
	lr.GenID(ctx)

	// Written synchronously: the approver reads it back by id.
	if err := b.loanRestructureRepo.Create(ctx, lr); err != nil {
		logger.WithError(err).Error("could not save loan restructure")
		return nil, err
	}

	return lr.ToAPI(), nil
}

// validateRestructureType rejects the restructure kinds this service cannot
// carry out. Rescheduling, refinancing and rate changes rewrite a schedule;
// a write-off recognises the loss and closes the loan. A partial waiver
// forgives part of a receivable, which needs postings this service does not
// make yet; accepting one silently would leave the loan book and the ledger
// disagreeing about what the borrower owes.
func validateRestructureType(restructureType int32) error {
	switch loansv1.RestructureType(restructureType) {
	case loansv1.RestructureType_RESTRUCTURE_TYPE_RESCHEDULE,
		loansv1.RestructureType_RESTRUCTURE_TYPE_REFINANCE,
		loansv1.RestructureType_RESTRUCTURE_TYPE_RATE_CHANGE,
		loansv1.RestructureType_RESTRUCTURE_TYPE_WRITE_OFF:
		return nil
	case loansv1.RestructureType_RESTRUCTURE_TYPE_PARTIAL_WAIVER:
		return ErrRestructureTypeUnsupported
	case loansv1.RestructureType_RESTRUCTURE_TYPE_UNSPECIFIED:
		return ErrRestructureTypeRequired
	default:
		return ErrRestructureTypeRequired
	}
}

// restructureAllowed reports whether a loan in this status may take this
// kind of restructure. Only a defaulted loan may be written off.
func restructureAllowed(restructureType, status int32) bool {
	if loansv1.RestructureType(restructureType) == loansv1.RestructureType_RESTRUCTURE_TYPE_WRITE_OFF {
		return loansv1.LoanStatus(status) == loansv1.LoanStatus_LOAN_STATUS_DEFAULT ||
			loansv1.LoanStatus(status) == loansv1.LoanStatus_LOAN_STATUS_WRITTEN_OFF
	}
	return canRestructure(status)
}

// canRestructure reports whether a loan in this status may be restructured.
func canRestructure(status int32) bool {
	for _, allowed := range validTransitions[loansv1.LoanStatus(status)] {
		if allowed == loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED {
			return true
		}
	}
	return false
}

func (b *loanRestructureBusiness) Approve(
	ctx context.Context,
	id string,
) (*loansv1.LoanRestructureObject, error) {
	lr, err := b.loanRestructureRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrRestructureNotFound
	}
	if err = validateRestructureType(lr.RestructureType); err != nil {
		return nil, err
	}
	la, laErr := b.loanAccountRepo.GetByID(ctx, lr.LoanAccountID)
	if laErr != nil {
		return nil, ErrLoanAccountNotFound
	}

	// A restructure is a credit decision: whoever asked for it cannot
	// approve it.
	approvedBy := callerSubject(ctx)
	if err = requireSeparationOfDuties(ctx, approvedBy, lr.RequestedBy); err != nil {
		return nil, err
	}

	claimed, claimErr := b.loanRestructureRepo.ClaimDecision(
		ctx, id, int32(commonv1.STATE_CHECKED), approvedBy, "", true)
	if claimErr != nil {
		return nil, claimErr
	}
	if !claimed {
		return nil, ErrRestructureNotPending
	}

	var oldScheduleID, newScheduleID string
	if loansv1.RestructureType(lr.RestructureType) == loansv1.RestructureType_RESTRUCTURE_TYPE_WRITE_OFF {
		err = b.applyWriteOff(ctx, la, lr, approvedBy)
	} else {
		oldScheduleID, newScheduleID, err = b.applyReschedule(ctx, la, lr, approvedBy)
	}
	if err != nil {
		// Every step above is safe to repeat, so the restructure goes back to
		// pending and a later approval finishes it.
		if relErr := b.loanRestructureRepo.ReleaseDecision(ctx, id); relErr != nil {
			util.Log(ctx).WithError(relErr).WithField("restructure_id", id).
				Error("could not release a restructure whose approval failed; it is retaken after the lease")
		}
		return nil, err
	}
	if err = b.loanRestructureRepo.CompleteDecision(ctx, id, oldScheduleID, newScheduleID); err != nil {
		return nil, err
	}

	lr.State = int32(commonv1.STATE_ACTIVE)
	lr.ApprovedBy = approvedBy
	lr.OldScheduleID = oldScheduleID
	lr.NewScheduleID = newScheduleID
	return lr.ToAPI(), nil
}

// applyWriteOff recognises the loss on a defaulted loan and closes it. The
// write-off transition posts the loss and charges the funders; a loan already
// written off by an earlier, interrupted approval is only closed.
func (b *loanRestructureBusiness) applyWriteOff(
	ctx context.Context,
	la *models.LoanAccount,
	lr *models.LoanRestructure,
	approvedBy string,
) error {
	if la.Status != int32(loansv1.LoanStatus_LOAN_STATUS_WRITTEN_OFF) {
		if _, err := b.laBusiness.TransitionStatus(
			ctx, la.GetID(), loansv1.LoanStatus_LOAN_STATUS_WRITTEN_OFF,
			approvedBy, "write-off "+lr.GetID()+" approved",
		); err != nil {
			return err
		}
	}
	_, err := b.laBusiness.TransitionStatus(
		ctx, la.GetID(), loansv1.LoanStatus_LOAN_STATUS_CLOSED,
		approvedBy, "closed after write-off "+lr.GetID(),
	)
	return err
}

// applyReschedule moves the loan to RESTRUCTURED, applies the new terms and
// regenerates the schedule on the principal still owed. It returns the old
// and new schedule ids.
func (b *loanRestructureBusiness) applyReschedule(
	ctx context.Context,
	la *models.LoanAccount,
	lr *models.LoanRestructure,
	approvedBy string,
) (string, string, error) {
	logger := util.Log(ctx).WithField("method", "LoanRestructureBusiness.applyReschedule")

	balance, balErr := b.loanBalanceRepo.GetByLoanAccountID(ctx, la.GetID())
	if balErr != nil || balance == nil {
		return "", "", ErrBalanceNotFound
	}
	// A restructure reschedules what is still owed. Regenerating from the
	// original principal would re-charge a borrower who has already repaid
	// most of the loan.
	outstandingPrincipal := balance.PrincipalOutstanding
	if outstandingPrincipal <= 0 {
		return "", "", ErrRestructureNothingOutstanding
	}

	oldScheduleID := ""
	if oldSchedule, schedErr := b.scheduleRepo.GetActivByLoanAccountID(ctx, la.GetID()); schedErr == nil &&
		oldSchedule != nil {
		oldScheduleID = oldSchedule.GetID()
	}

	// Routed through the loan's own state machine, so a CLOSED or WRITTEN_OFF
	// loan cannot be revived by approving a restructure against it, and the
	// change lands in the loan's status history.
	if la.Status != int32(loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED) {
		if _, transErr := b.laBusiness.TransitionStatus(
			ctx, la.GetID(),
			loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED,
			approvedBy, "restructure "+lr.GetID()+" approved",
		); transErr != nil {
			return "", "", transErr
		}
	}

	if err := b.applyRestructuredTerms(ctx, la, lr); err != nil {
		return "", "", err
	}

	schedule, schedErr := b.scheduleBusiness.GenerateFor(ctx, la, outstandingPrincipal)
	if schedErr != nil {
		logger.WithError(schedErr).Error("could not regenerate schedule after restructure")
		return "", "", schedErr
	}

	var nextDue *time.Time
	if len(schedule.Entries) > 0 {
		nextDue = schedule.Entries[0].DueDate
	}
	b.notifier.NotifyLoanRestructured(ctx, la, balance.TotalOutstanding, nextDue)
	return oldScheduleID, schedule.Schedule.GetID(), nil
}

// applyRestructuredTerms writes only the terms the restructure changes.
func (b *loanRestructureBusiness) applyRestructuredTerms(
	ctx context.Context,
	la *models.LoanAccount,
	lr *models.LoanRestructure,
) error {
	values := map[string]any{}
	if lr.NewInterestRate > 0 {
		la.InterestRate = lr.NewInterestRate
		values["interest_rate"] = lr.NewInterestRate
	}
	if lr.NewTermDays > 0 {
		la.TermDays = lr.NewTermDays
		values["term_days"] = lr.NewTermDays
	}
	if len(values) == 0 {
		return nil
	}

	_, err := b.loanAccountRepo.UpdateColumns(ctx, la.GetID(), values)
	return err
}

func (b *loanRestructureBusiness) Reject(
	ctx context.Context,
	id, reason string,
) (*loansv1.LoanRestructureObject, error) {
	lr, err := b.loanRestructureRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrRestructureNotFound
	}
	claimed, claimErr := b.loanRestructureRepo.ClaimDecision(
		ctx, id, int32(commonv1.STATE_INACTIVE), callerSubject(ctx), reason, false)
	if claimErr != nil {
		return nil, claimErr
	}
	if !claimed {
		return nil, ErrRestructureNotPending
	}
	lr.State = int32(commonv1.STATE_INACTIVE)
	lr.Reason = reason
	return lr.ToAPI(), nil
}

func (b *loanRestructureBusiness) Search(
	ctx context.Context,
	req *loansv1.LoanRestructureSearchRequest,
	consumer func(ctx context.Context, batch []*loansv1.LoanRestructureObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "LoanRestructureBusiness.Search")

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
	if req.GetLoanAccountId() == "" && !b.scope.IsStaff(ctx) {
		// Only staff list restructures across the partition.
		return ErrLoanNotOwned
	}
	if req.GetLoanAccountId() != "" {
		if err := authorizeLoanAccount(ctx, b.scope, b.loanAccountRepo, req.GetLoanAccountId()); err != nil {
			return err
		}
		andQueryVal["loan_account_id = ?"] = req.GetLoanAccountId()
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.loanRestructureRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search loan restructures")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.LoanRestructure) error {
		var apiResults []*loansv1.LoanRestructureObject
		for _, lr := range res {
			apiResults = append(apiResults, lr.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}
