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
	"time"

	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/types/known/structpb"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/messages"
	"github.com/antinvestor/service-fintech/pkg/notify"
	"github.com/antinvestor/service-fintech/pkg/payout"
)

const (
	// defaultSweepBatch and maxSweepBatch bound one call of the sweeps, so a
	// scheduled job finishes in one request whatever the backlog.
	defaultSweepBatch = 50
	maxSweepBatch     = 500

	notifyKindGroupLoan = "group_loan"
)

// OriginationSweep reports one ResumePendingOrigination call.
type OriginationSweep struct {
	Scanned   int `json:"scanned"`
	Disbursed int `json:"disbursed"`
	Failed    int `json:"failed"`
	Pending   int `json:"pending"`
}

// ResumePendingOrigination drives up to batch accepted offers whose loan is
// not yet disbursed. Each offer resumes at the step it recorded last, so a
// repeat call never originates or pays a second loan. Offers are listed
// across tenants and each is worked inside its own partition (act). It is
// the entry for the scheduled job; nothing in stawi runs it on a timer.
func (b *loanOfferBusiness) ResumePendingOrigination(
	ctx context.Context,
	batch int,
	act PartitionActor,
) (OriginationSweep, error) {
	var sweep OriginationSweep
	listCtx := security.SkipTenancyChecksOnClaims(ctx)
	offers, err := b.offers.ListPendingOrigination(listCtx, b.now().UTC(), sweepBatch(batch))
	if err != nil {
		return sweep, fmt.Errorf("list pending origination: %w", err)
	}
	for _, offer := range offers {
		sweep.Scanned++
		advanceErr := b.advance(act(ctx, &offer.BaseModel), offer)
		switch offer.OriginationStatus {
		case models.OriginationDisbursed:
			sweep.Disbursed++
		case models.OriginationFailed:
			sweep.Failed++
		default:
			sweep.Pending++
			if advanceErr != nil {
				util.Log(ctx).WithError(advanceErr).WithField("offer_id", offer.GetID()).
					Warn("group loan origination still pending")
			}
		}
	}
	return sweep, nil
}

// ExpireStale closes up to batch open offers nobody answered before their
// expiry, returning how many it closed. Respond already refuses an expired
// offer; this only stops it showing as open.
func (b *loanOfferBusiness) ExpireStale(
	ctx context.Context,
	now time.Time,
	batch int,
	act PartitionActor,
) (int, error) {
	offers, err := b.offers.ListExpired(security.SkipTenancyChecksOnClaims(ctx), now, sweepBatch(batch))
	if err != nil {
		return 0, fmt.Errorf("list expired offers: %w", err)
	}
	expired := 0
	for _, offer := range offers {
		offer.State = int32(constants.StateInactive)
		setProp(offer, propClosedReason, "expired")
		if saveErr := b.save(act(ctx, &offer.BaseModel), offer); saveErr != nil {
			// Answered or expired by a concurrent call; it is not ours to close.
			if errors.Is(saveErr, errOfferChanged) {
				continue
			}
			return expired, saveErr
		}
		expired++
	}
	return expired, nil
}

// CancelSweep reports one RetryLoanCancels call.
type CancelSweep struct {
	Scanned   int `json:"scanned"`
	Cancelled int `json:"cancelled"`
}

// RetryLoanCancels cancels, again, the unpaid loans of up to batch failed
// offers whose first cancel did not go through, so their funding is
// released. Cancelling a loan the lender already cancelled is accepted, so a
// repeat changes nothing; a cancel that fails again waits before the next
// try.
func (b *loanOfferBusiness) RetryLoanCancels(
	ctx context.Context,
	now time.Time,
	batch int,
	act PartitionActor,
) (CancelSweep, error) {
	var sweep CancelSweep
	offers, err := b.offers.ListUncancelledLoans(security.SkipTenancyChecksOnClaims(ctx), now, sweepBatch(batch))
	if err != nil {
		return sweep, fmt.Errorf("list uncancelled loans: %w", err)
	}
	for _, offer := range offers {
		sweep.Scanned++
		actCtx := act(ctx, &offer.BaseModel)
		if b.cancelUnpaidLoan(actCtx, offer) {
			sweep.Cancelled++
		}
		if saveErr := b.save(actCtx, offer); saveErr != nil {
			util.Log(ctx).WithError(saveErr).WithField("offer_id", offer.GetID()).
				Warn("could not record the retried cancel of a failed offer's loan")
		}
	}
	return sweep, nil
}

// cancelUnpaidLoan cancels a failed offer's loan and records the outcome on
// the offer, which the caller saves.
func (b *loanOfferBusiness) cancelUnpaidLoan(ctx context.Context, offer *models.LoanOffer) bool {
	// The loans service refuses to cancel a loan whose payout is under way,
	// so this cannot close a loan that is being paid.
	err := b.lender.CancelLoanAccount(ctx, offer.LoanAccountID,
		"group loan offer "+offer.GetID()+" could not be paid out")
	setProp(offer, propLoanCancelled, err == nil)
	if err != nil {
		util.Log(ctx).WithError(err).WithField("offer_id", offer.GetID()).
			Error("could not cancel the unpaid loan of a failed offer; a later run retries")
		retryAt := b.now().UTC().Add(sweepRetryAfter)
		offer.RetryAt = &retryAt
		return false
	}
	offer.RetryAt = nil
	return true
}

// sweepRetryAfter is how long an offer whose last step failed waits before
// the scheduled job tries it again.
const sweepRetryAfter = 10 * time.Minute

func sweepBatch(batch int) int {
	switch {
	case batch <= 0:
		return defaultSweepBatch
	case batch > maxSweepBatch:
		return maxSweepBatch
	default:
		return batch
	}
}

// advance moves a pending offer as far through origination as the loans
// service allows now. A refusal that will not change on retry marks the
// offer failed; anything else leaves it pending and is returned.
func (b *loanOfferBusiness) advance(ctx context.Context, offer *models.LoanOffer) error {
	if offer.OriginationStatus != models.OriginationPending {
		return nil
	}
	if err := b.claimAttempt(ctx, offer); err != nil {
		return err
	}

	err := b.originate(ctx, offer)
	delete(offer.Properties, propAttemptUntil)
	switch {
	case err == nil:
		delete(offer.Properties, propLastError)
		offer.RetryAt = nil
		// The loans service tells the borrower the money is on its way
		// (LoanDisbursed); a second message from stawi would duplicate it.
		return b.save(ctx, offer)
	case permanentRefusal(err):
		return b.fail(ctx, offer, err)
	default:
		// Recording the reason also releases the attempt; if this write is
		// lost the attempt lapses on its own after originationAttemptLease.
		setProp(offer, propLastError, err.Error())
		retryAt := b.now().UTC().Add(sweepRetryAfter)
		offer.RetryAt = &retryAt
		if saveErr := b.save(ctx, offer); saveErr != nil {
			util.Log(ctx).WithError(saveErr).WithField("offer_id", offer.GetID()).
				Debug("could not record origination error on the offer")
		}
		return err
	}
}

// originationAttemptLease is how long one attempt holds an offer. It only
// has to outlast the loans calls of one attempt; a crashed attempt frees the
// offer when it lapses.
const originationAttemptLease = 2 * time.Minute

// errOriginationInFlight reports an offer another attempt is working on.
var errOriginationInFlight = apperrors.NewError(apperrors.Conflict,
	"the loan offer is being originated by another request")

// claimAttempt makes this call the only one working on the offer until the
// lease lapses. The claim is a versioned write, so of two calls that read
// the offer together only one gets it; the other retries later. Without it,
// one call could record a refusal while the other had just made the loan.
// The loan request id is chosen in the same write, so every attempt writes
// the same request in the loans service.
func (b *loanOfferBusiness) claimAttempt(ctx context.Context, offer *models.LoanOffer) error {
	now := b.now().UTC()
	if until, err := time.Parse(time.RFC3339, propString(offer, propAttemptUntil)); err == nil && now.Before(until) {
		return errOriginationInFlight
	}
	setProp(offer, propAttemptUntil, now.Add(originationAttemptLease).Format(time.RFC3339))
	if offer.ApplicationID == "" {
		offer.ApplicationID = util.IDString()
	}
	return b.save(ctx, offer)
}

// originate runs the loans steps of an accepted offer, recording each result
// on the offer before taking the next, so a retry resumes rather than
// repeats:
//
//  1. the loan request id was chosen and saved when the attempt was claimed;
//  2. the request is submitted and approved, unless loans already has it so;
//  3. the loan account is created (loans answers a repeat with the same loan);
//  4. the loan is disbursed to the member's own payout contact under a key
//     derived from the offer, so the money leaves once.
//
// A nil return means the payout settled; the caller records it.
func (b *loanOfferBusiness) originate(ctx context.Context, offer *models.LoanOffer) error {
	if b.lender == nil {
		return apperrors.NewError(apperrors.ServiceUnavailable, "the loans service is required to originate a loan")
	}

	if offer.LoanAccountID == "" {
		if err := b.ensureApprovedRequest(ctx, offer); err != nil {
			return err
		}
		loanAccountID, err := b.lender.CreateLoanAccount(ctx, offer.ApplicationID)
		if err != nil {
			return err
		}
		offer.LoanAccountID = loanAccountID
		if err = b.save(ctx, offer); err != nil {
			return err
		}
	}

	disbursement, err := b.lender.Disburse(ctx, offer.LoanAccountID, offerDisbursementKey(offer))
	if err != nil {
		return err
	}
	offer.DisbursementID = disbursement.GetId()

	switch disbursement.GetStatus() { //nolint:exhaustive // every other status is not settled yet
	case loansv1.DisbursementStatus_DISBURSEMENT_STATUS_COMPLETED:
		offer.OriginationStatus = models.OriginationDisbursed
		offer.State = int32(constants.StateInactive)
		return nil
	case loansv1.DisbursementStatus_DISBURSEMENT_STATUS_FAILED,
		loansv1.DisbursementStatus_DISBURSEMENT_STATUS_REVERSED:
		return apperrors.NewError(apperrors.Unprocessable, "the payout of the loan was refused")
	default:
		return apperrors.NewError(apperrors.ServiceUnavailable, "the loan's payout has not settled yet")
	}
}

// offerDisbursementKey is the one idempotency key an offer's payout ever
// uses.
func offerDisbursementKey(offer *models.LoanOffer) string {
	return "stawi:offer:" + offer.GetID()
}

// ensureApprovedRequest brings the offer's loan request to approved. It
// reads the request first, because a previous attempt may have submitted or
// approved it without living to record that, and approving twice is refused.
func (b *loanOfferBusiness) ensureApprovedRequest(ctx context.Context, offer *models.LoanOffer) error {
	status, found, err := b.lender.LoanRequestStatus(ctx, offer.ApplicationID)
	if err != nil {
		return err
	}

	switch {
	case !found, status == loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_DRAFT:
		request, buildErr := b.loanRequestFor(ctx, offer)
		if buildErr != nil {
			return buildErr
		}
		if err = b.lender.SubmitLoanRequest(ctx, request); err != nil {
			return err
		}
		return b.lender.ApproveLoanRequest(ctx, offer.ApplicationID)
	case status == loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED:
		return b.lender.ApproveLoanRequest(ctx, offer.ApplicationID)
	case status == loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED,
		status == loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_LOAN_CREATED:
		return nil
	default:
		return apperrors.NewError(apperrors.Unprocessable,
			"the loan request was closed by the lender ("+status.String()+")")
	}
}

// loanRequestFor builds the loan request of an offer: the member as the
// lender's client, the group product's term and rate, and the member's own
// verified mobile contact as where the money goes.
func (b *loanOfferBusiness) loanRequestFor(
	ctx context.Context,
	offer *models.LoanOffer,
) (*loansv1.LoanRequestObject, error) {
	clientID, payoutContactID, err := b.borrowerForOffer(ctx, offer)
	if err != nil {
		return nil, err
	}
	// Stawi does not verify KYC itself, so it does not assert it: the loans
	// service keeps its own verification gate for products that require it.
	props, err := structpb.NewStruct(map[string]any{
		"payment_account_ref": payoutContactID,
		"group_offer_id":      offer.GetID(),
	})
	if err != nil {
		return nil, fmt.Errorf("loan request properties: %w", err)
	}
	amount := minorUnitsToMoney(offer.Amount, offer.Currency)
	return &loansv1.LoanRequestObject{
		Id:                offer.ApplicationID,
		ClientId:          clientID,
		ProductId:         b.product.LoanProductID,
		RequestedAmount:   amount,
		ApprovedAmount:    amount,
		RequestedTermDays: b.product.LoanTermDays(),
		ApprovedTermDays:  b.product.LoanTermDays(),
		InterestRate:      basisPointsToPercent(b.product.LoanInterestRatePA),
		CurrencyCode:      offer.Currency,
		Purpose:           "Group loan offer " + offer.GetID(),
		SourceService:     "stawi",
		SourceRequestId:   offer.GetID(),
		IdempotencyKey:    "stawi:" + offer.GetID(),
		Status:            loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED,
		Properties:        props,
	}, nil
}

// borrowerForOffer resolves the member behind an offer to the lender's client
// id and the id of the member's own payout contact. Stawi never handles the
// number itself.
func (b *loanOfferBusiness) borrowerForOffer(ctx context.Context, offer *models.LoanOffer) (string, string, error) {
	if b.identity == nil || b.clients == nil || b.profiles == nil {
		return "", "", apperrors.NewError(apperrors.ServiceUnavailable,
			"identity, lender identity and profile services are required to originate a loan")
	}
	resp, err := b.identity.MembershipGet(ctx, &identityv1.MembershipGetRequest{Id: offer.MembershipID})
	if err != nil {
		return "", "", fmt.Errorf("membership get: %w", err)
	}
	membership := resp.GetData()
	clientID := membershipClientID(membership)
	if clientID == "" {
		return "", "", apperrors.NewError(apperrors.Unprocessable,
			"member is not registered as a client with the lender; run group registration first")
	}
	// The membership property is a hint, not an identity: the lender's client
	// row must belong to this member's profile before money is lent on it.
	client, err := b.clients.ClientGet(ctx, &fieldv1.ClientGetRequest{Id: clientID})
	if err != nil {
		return "", "", fmt.Errorf("client get: %w", err)
	}
	if client.GetData().GetProfileId() == "" || client.GetData().GetProfileId() != membership.GetProfileId() {
		return "", "", apperrors.NewError(apperrors.Unprocessable,
			"the client recorded on the membership belongs to a different person")
	}
	profile, err := b.profiles.GetById(ctx, &profilev1.GetByIdRequest{Id: membership.GetProfileId()})
	if err != nil {
		return "", "", fmt.Errorf("profile get: %w", err)
	}
	payoutContactID := payout.DefaultPayoutContactID(profile.GetData())
	if payoutContactID == "" {
		return "", "", apperrors.NewError(apperrors.Unprocessable,
			"member has no verified mobile number to receive the loan")
	}
	return clientID, payoutContactID, nil
}

// membershipClientID is the lender client id group registration recorded on
// the membership.
func membershipClientID(membership *identityv1.MembershipObject) string {
	if props := membership.GetProperties(); props != nil {
		if v, ok := props.AsMap()["client_id"].(string); ok {
			return v
		}
	}
	return ""
}

// fail records a refusal on the offer, closes any loan that was made but not
// paid out so its funding is released, and tells the member.
func (b *loanOfferBusiness) fail(ctx context.Context, offer *models.LoanOffer, cause error) error {
	logger := util.Log(ctx).WithError(cause).WithField("offer_id", offer.GetID())
	logger.Warn("group loan origination refused")

	offer.OriginationStatus = models.OriginationFailed
	offer.State = int32(constants.StateInactive)
	setProp(offer, propFailureReason, memberReason(cause))
	setProp(offer, propLastError, cause.Error())
	// The failure is recorded before anything is undone, so a write lost to
	// another request leaves the offer pending rather than a loan cancelled
	// under a request that was still making it.
	if err := b.save(ctx, offer); err != nil {
		offer.OriginationStatus = models.OriginationPending
		return err
	}

	if offer.LoanAccountID != "" {
		b.cancelUnpaidLoan(ctx, offer)
		if err := b.save(ctx, offer); err != nil {
			logger.WithError(err).Error("could not record the cancel of a failed offer's loan")
		}
	}

	b.notifyMember(ctx, offer, messages.GroupLoanFailed, map[string]any{
		messages.VarGroupName: propString(offer, propGroupName),
		messages.VarAmount:    messages.FormatAmount(offer.Currency, offer.Amount),
		messages.VarCurrency:  offer.Currency,
		messages.VarReason:    propString(offer, propFailureReason),
	})
	return failedOfferError(offer)
}

// memberReason is the refusal as the member may read it: stawi's own
// messages are written for that, a peer's may name internal records.
func memberReason(err error) string {
	var appErr *apperrors.Error
	if errors.As(err, &appErr) {
		return appErr.Message()
	}
	return "the lender could not approve the loan"
}

// permanentRefusal reports whether a failed step will fail the same way on
// retry: the request is invalid, refused in its current state, names
// something that does not exist, or is not allowed. Anything else
// (unavailable, timeouts, conflicts, internal errors) is worth retrying.
func permanentRefusal(err error) bool {
	code := connect.CodeOf(err)
	var appErr *apperrors.Error
	if errors.As(err, &appErr) {
		code = appErr.ConnectCode()
	}
	switch code { //nolint:exhaustive // every other code is retryable
	case connect.CodeInvalidArgument, connect.CodeFailedPrecondition,
		connect.CodeNotFound, connect.CodePermissionDenied:
		return true
	default:
		return false
	}
}

// notifyMember sends a group loan message to the member by profile id. The
// money or state change it reports has already happened, so a failed send
// is logged, never returned.
func (b *loanOfferBusiness) notifyMember(
	ctx context.Context,
	offer *models.LoanOffer,
	template string,
	vars map[string]any,
) {
	recipient := notify.ToProfile(propString(offer, propProfileID))
	if recipient == nil {
		util.Log(ctx).WithField("offer_id", offer.GetID()).WithField("template", template).
			Warn("loan offer has no member profile to notify")
		return
	}
	b.notifier.SendOrLog(ctx, notify.Message{
		Template:  template,
		Kind:      notifyKindGroupLoan,
		Recipient: recipient,
		Vars:      vars,
		Priority:  notificationv1.PRIORITY_HIGH,
	})
}

// basisPointsPerPercent is how many basis points make one percent.
const basisPointsPerPercent = 100

// basisPointsToPercent renders 2400 basis points as "24.00".
func basisPointsToPercent(bp int64) string {
	return fmt.Sprintf("%d.%02d", bp/basisPointsPerPercent, bp%basisPointsPerPercent)
}
