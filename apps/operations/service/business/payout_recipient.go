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
	"strings"

	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/payout"
)

// Extra-data keys that address a payout. recipient_profile_id names the
// profile directly; recipient_client_id names an identity client whose
// profile is looked up; payment_account_ref is the contact id of one of the
// recipient's payable contacts (never a number or address).
const (
	extraRecipientProfileID = "recipient_profile_id"
	extraRecipientClientID  = "recipient_client_id"
	extraPaymentAccountRef  = "payment_account_ref"
)

var (
	// ErrPayoutRecipientUnresolved is returned when an order names no
	// recipient that resolves to a profile. It will not pass on a retry.
	ErrPayoutRecipientUnresolved = apperrors.NewError(apperrors.Unprocessable,
		"payout recipient could not be resolved to a profile")
	// ErrPayoutDestinationNotRecipient is returned when the destination is
	// not one of the recipient's contacts.
	ErrPayoutDestinationNotRecipient = apperrors.NewError(apperrors.Unprocessable,
		"payout destination is not a contact of the recipient")
	// ErrPayoutRecipientUnverifiable is returned when the identity or
	// profile service could not be asked; the order may be retried.
	ErrPayoutRecipientUnverifiable = apperrors.NewError(apperrors.ServiceUnavailable,
		"payout recipient could not be verified; retry later")
	// ErrPayoutNotSettled is returned when a payout order's ledger leg has
	// posted but the payout has neither gone out nor been reversed. Money
	// has moved; the caller must retry the same order, never treat it as
	// refused.
	ErrPayoutNotSettled = apperrors.NewError(apperrors.ServiceUnavailable,
		"payout is posted but not yet settled or reversed; retry the same order")
	// errReversalMismatch is returned when the stored order under a reversal
	// reference is not the reversal this order needs.
	errReversalMismatch = errors.New("order under the payout reversal reference is not this order's reversal")
)

// payoutReversalPrefix marks system-written reversal orders. API callers
// may not use it, so nobody can pre-create an order under a reversal's
// reference.
const payoutReversalPrefix = "payout-reversal:"

// IsReservedReference reports whether an API caller may not use reference.
func IsReservedReference(reference string) bool {
	return strings.HasPrefix(strings.TrimSpace(reference), payoutReversalPrefix)
}

// Error contract for payout orders, which callers such as savings rely on:
// a precondition-class error (FailedPrecondition, InvalidArgument,
// NotFound, PermissionDenied) means no money moved, either because the
// ledger leg never posted or because it posted and was reversed. Anything
// else may leave money in flight and must be retried.

// isPayoutOrderType reports whether an order type's side effect sends money
// out through the payment rail.
func isPayoutOrderType(orderType int) bool {
	switch orderType {
	case constants.TransferTypeDisbursement,
		constants.TransferTypeDisbursementReversalReroute,
		constants.TransferTypeLoan,
		constants.TransferTypeTerminalDisbursement,
		constants.TransferTypeInvestorWithdrawal:
		return true
	default:
		return false
	}
}

// legacyPayoutRecipient is the recipient key older callers set per type.
func legacyPayoutRecipient(order *models.TransferOrder) string {
	switch int(order.OrderType) {
	case constants.TransferTypeLoan, constants.TransferTypeTerminalDisbursement:
		return extraDataString(order, "member_id")
	default:
		return extraDataString(order, "recipient_id")
	}
}

// payoutRecipient resolves who a payout goes to and where. It is called
// before the ledger leg posts, so an order addressed to nobody, or to a
// destination that is not the recipient's, never moves money.
func (b *transferOrderBusiness) payoutRecipient(
	ctx context.Context,
	order *models.TransferOrder,
	legacyID string,
) (string, string, error) {
	profileID, legacy, err := b.recipientProfile(ctx, order, legacyID)
	if err != nil {
		return "", "", err
	}
	destination := strings.TrimSpace(extraDataString(order, extraPaymentAccountRef))
	if destination == "" {
		return profileID, "", nil
	}

	profile, err := b.loadProfile(ctx, profileID)
	if legacy && errors.Is(err, errProfileNotFound) {
		// Older loans orders named the client id as recipient_id.
		if profileID, err = b.profileForClient(ctx, profileID); err != nil {
			return "", "", err
		}
		profile, err = b.loadProfile(ctx, profileID)
	}
	if errors.Is(err, errProfileNotFound) {
		return "", "", ErrPayoutRecipientUnresolved
	}
	if err != nil {
		return "", "", err
	}
	if payout.PayableContact(profile, destination) == nil {
		util.Log(ctx).WithField("order_id", order.GetID()).WithField("profile_id", profileID).
			Error("payout destination is not one of the recipient's contacts")
		return "", "", ErrPayoutDestinationNotRecipient
	}
	return profileID, destination, nil
}

// recipientProfile names the profile a payout is for: recipient_profile_id,
// else the profile of recipient_client_id, else the legacy id the handler
// passes (reported with legacy=true).
func (b *transferOrderBusiness) recipientProfile(
	ctx context.Context,
	order *models.TransferOrder,
	legacyID string,
) (string, bool, error) {
	if profileID := strings.TrimSpace(extraDataString(order, extraRecipientProfileID)); profileID != "" {
		return profileID, false, nil
	}
	if clientID := strings.TrimSpace(extraDataString(order, extraRecipientClientID)); clientID != "" {
		profileID, err := b.profileForClient(ctx, clientID)
		return profileID, false, err
	}
	if legacyID = strings.TrimSpace(legacyID); legacyID != "" {
		return legacyID, true, nil
	}
	return "", false, ErrPayoutRecipientUnresolved
}

// readsAsRefusal reports whether a caller would read err as "nothing
// moved": the precondition-class codes of the payout error contract.
func readsAsRefusal(err error) bool {
	switch apperrors.CleanErr(err).Code() { //nolint:exhaustive // only refusal codes matter
	case connect.CodeInvalidArgument, connect.CodeFailedPrecondition,
		connect.CodeNotFound, connect.CodePermissionDenied:
		return true
	default:
		return false
	}
}

// isReversalOf reports whether rev mirrors order exactly.
func isReversalOf(rev, order *models.TransferOrder) bool {
	return rev != nil &&
		rev.OrderType == int32(constants.TransferTypeDisbursementReversal) &&
		rev.DebitAccountRef == order.CreditAccountRef &&
		rev.CreditAccountRef == order.DebitAccountRef &&
		rev.Amount == order.Amount &&
		rev.Currency == order.Currency &&
		extraDataString(rev, "original_order_id") == order.GetID()
}

// checkPayoutRecipient runs the recipient check for a payout order whose
// ledger leg has not posted, releasing the order when it fails.
func (b *transferOrderBusiness) checkPayoutRecipient(
	ctx context.Context,
	logger *util.LogEntry,
	order *models.TransferOrder,
) error {
	if !isPayoutOrderType(int(order.OrderType)) || order.LedgerPosted() {
		return nil
	}
	if _, _, err := b.payoutRecipient(ctx, order, legacyPayoutRecipient(order)); err != nil {
		logger.WithError(err).Error("payout recipient check failed")
		b.releaseExecution(ctx, logger, order.GetID(), "payout recipient: "+err.Error())
		return err
	}
	return nil
}

// failSideEffect releases an order whose side effect failed and, when the
// rail rejected its payout, reverses the ledger leg.
func (b *transferOrderBusiness) failSideEffect(
	ctx context.Context,
	logger *util.LogEntry,
	order *models.TransferOrder,
	reason string,
	cause error,
) error {
	b.releaseExecution(ctx, logger, order.GetID(), reason)
	if !isPayoutOrderType(int(order.OrderType)) || !order.LedgerPosted() {
		return cause
	}
	if !errors.Is(cause, ErrPayoutFailed) {
		// Posted, not paid, not reversed: never a refusal to the caller.
		if readsAsRefusal(cause) {
			return fmt.Errorf("%w: %s", ErrPayoutNotSettled, cause.Error())
		}
		return cause
	}
	if revErr := b.reverseRejectedPayout(ctx, logger, order); revErr != nil {
		logger.WithError(revErr).Error("could not reverse the rejected payout; it is retried with the order")
		return fmt.Errorf("%w: reversal pending: %s", ErrPayoutNotSettled, revErr.Error())
	}
	return cause
}

var errProfileNotFound = errors.New("profile not found")

func (b *transferOrderBusiness) loadProfile(ctx context.Context, profileID string) (*profilev1.ProfileObject, error) {
	if b.clients == nil || b.clients.ProfileClient == nil {
		return nil, ErrPayoutRecipientUnverifiable
	}
	resp, err := b.clients.ProfileClient.GetById(ctx, &profilev1.GetByIdRequest{Id: profileID})
	if err != nil {
		if connect.CodeOf(err) == connect.CodeNotFound {
			return nil, errProfileNotFound
		}
		return nil, fmt.Errorf("%w: %s", ErrPayoutRecipientUnverifiable, err.Error())
	}
	if resp.GetData() == nil {
		return nil, errProfileNotFound
	}
	return resp.GetData(), nil
}

func (b *transferOrderBusiness) profileForClient(ctx context.Context, clientID string) (string, error) {
	if b.clients == nil || b.clients.LenderIdentity == nil {
		return "", ErrPayoutRecipientUnverifiable
	}
	resp, err := b.clients.LenderIdentity.ClientGet(ctx, &fieldv1.ClientGetRequest{Id: clientID})
	if err != nil {
		if connect.CodeOf(err) == connect.CodeNotFound {
			return "", ErrPayoutRecipientUnresolved
		}
		return "", fmt.Errorf("%w: %s", ErrPayoutRecipientUnverifiable, err.Error())
	}
	profileID := strings.TrimSpace(resp.GetData().GetProfileId())
	if profileID == "" {
		return "", ErrPayoutRecipientUnresolved
	}
	return profileID, nil
}

// reverseRejectedPayout posts the mirror of an order whose ledger leg landed
// but whose payout the rail rejected, so the books show the money never
// left, and closes the original so it is never executed again. The reversal
// is idempotent on its reference.
func (b *transferOrderBusiness) reverseRejectedPayout(
	ctx context.Context,
	logger *util.LogEntry,
	order *models.TransferOrder,
) error {
	if !order.LedgerPosted() {
		return nil
	}
	reference := order.Reference
	if reference == "" {
		reference = order.GetID()
	}
	reversal := &models.TransferOrder{
		DebitAccountRef:  order.CreditAccountRef,
		CreditAccountRef: order.DebitAccountRef,
		Amount:           order.Amount,
		Currency:         order.Currency,
		OrderType:        int32(constants.TransferTypeDisbursementReversal),
		Reference:        payoutReversalPrefix + reference,
		Description:      "Reversal of payout rejected by the payment rail",
		ExtraData: map[string]any{
			"original_order_id":  order.GetID(),
			"original_reference": order.Reference,
		},
	}
	reversal.TenantID = order.TenantID
	reversal.PartitionID = order.PartitionID
	if err := b.Save(ctx, reversal); err != nil {
		return fmt.Errorf("save payout reversal: %w", err)
	}
	// Save converges on any order already under the reference; execute it
	// only if it is exactly this order's mirror.
	stored, err := b.toRepo.GetByID(ctx, reversal.GetID())
	if err != nil {
		return fmt.Errorf("reload payout reversal: %w", err)
	}
	if !isReversalOf(stored, order) {
		return errReversalMismatch
	}
	// The reversal returns money to where it came from, so it is not put
	// through the limits gate again.
	if err = b.executeInner(ctx, reversal.GetID()); err != nil {
		return fmt.Errorf("execute payout reversal: %w", err)
	}
	if _, err = b.toRepo.ClaimState(ctx, order.GetID(),
		[]int32{int32(constants.StateJustCreated), int32(constants.StateCheckCreated)},
		int32(constants.StateShutdown)); err != nil {
		logger.WithError(err).Error("could not close the order after reversing its payout")
	}
	logger.WithField("reversal_order_id", reversal.GetID()).Warn("rejected payout reversed")
	return nil
}
