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
	"io"
	"strings"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/payout"
	"github.com/antinvestor/service-fintech/pkg/transferorder"
)

var (
	// ErrCommissionPayoutInvalid is returned for a payout without a positive
	// amount and a currency.
	ErrCommissionPayoutInvalid = apperrors.NewError(apperrors.BadRequest,
		"a commission payout needs a positive amount and a currency")
	// ErrCommissionInsufficient is returned when the team has less left to
	// be paid than the payout asks for. Nothing moved.
	ErrCommissionInsufficient = apperrors.NewError(apperrors.Unprocessable,
		"the team's commission balance does not cover the payout")
	// ErrCommissionPayoutKeyReused is returned when an idempotency key is
	// replayed for a different payout.
	ErrCommissionPayoutKeyReused = apperrors.NewError(apperrors.Conflict,
		"the idempotency key was already used for a different payout")
	// ErrCommissionMemberNotOnTeam is returned when the member is not an
	// active member of the team being paid.
	ErrCommissionMemberNotOnTeam = apperrors.NewError(apperrors.Unprocessable,
		"commission is paid only to an active member of the team")
	// ErrCommissionNoPayoutContact is returned when the member has no
	// verified mobile number to be paid to.
	ErrCommissionNoPayoutContact = apperrors.NewError(apperrors.Unprocessable,
		"the member has no verified mobile number to be paid to")
	// ErrCommissionPayoutUnavailable is returned when the member's payout
	// destination cannot be looked up; the caller retries.
	ErrCommissionPayoutUnavailable = apperrors.NewError(apperrors.ServiceUnavailable,
		"the member's payout contact cannot be looked up; retry")
)

const (
	actionCommissionPaidOut   = "team_commission.paid_out"
	entityTeamCommission      = "team_commission"
	commissionPayoutPrefix    = "team-payout:"
	commissionPayoutReference = "team_commission_payout:"
	maxCommissionPageSize     = 200
)

// MemberPayout is where a member is paid: their own profile, and one of its
// verified mobile contacts, named by id.
type MemberPayout struct {
	ProfileID string
	ContactID string
}

// TeamMemberPayoutResolver finds where an active member of a team is paid.
type TeamMemberPayoutResolver interface {
	MemberPayout(ctx context.Context, teamID, memberID string) (MemberPayout, error)
}

type identityMemberPayoutResolver struct {
	identity identityv1connect.IdentityServiceClient
	profiles profilev1connect.ProfileServiceClient
}

// NewIdentityMemberPayoutResolver builds the production resolver: the
// membership and the member's profile from identity, its first payable
// contact from the profile service. The number itself is never read.
func NewIdentityMemberPayoutResolver(
	identity identityv1connect.IdentityServiceClient,
	profiles profilev1connect.ProfileServiceClient,
) TeamMemberPayoutResolver {
	return &identityMemberPayoutResolver{identity: identity, profiles: profiles}
}

func (r *identityMemberPayoutResolver) MemberPayout(
	ctx context.Context,
	teamID, memberID string,
) (MemberPayout, error) {
	if r == nil || r.identity == nil || r.profiles == nil {
		return MemberPayout{}, ErrCommissionPayoutUnavailable
	}
	onTeam, err := r.activeOnTeam(ctx, teamID, memberID)
	if err != nil {
		return MemberPayout{}, fmt.Errorf("%w: %s", ErrCommissionPayoutUnavailable, err.Error())
	}
	if !onTeam {
		return MemberPayout{}, ErrCommissionMemberNotOnTeam
	}
	member, err := r.identity.WorkforceMemberGet(ctx, &identityv1.WorkforceMemberGetRequest{Id: memberID})
	if err != nil {
		return MemberPayout{}, fmt.Errorf("%w: %s", ErrCommissionPayoutUnavailable, err.Error())
	}
	profileID := strings.TrimSpace(member.GetData().GetProfileId())
	if profileID == "" {
		return MemberPayout{}, ErrCommissionNoPayoutContact
	}
	profile, err := r.profiles.GetById(ctx, &profilev1.GetByIdRequest{Id: profileID})
	if err != nil {
		return MemberPayout{}, fmt.Errorf("%w: %s", ErrCommissionPayoutUnavailable, err.Error())
	}
	contactID := payout.DefaultPayoutContactID(profile.GetData())
	if contactID == "" {
		return MemberPayout{}, ErrCommissionNoPayoutContact
	}
	return MemberPayout{ProfileID: profileID, ContactID: contactID}, nil
}

// activeOnTeam reports whether the member holds an active membership of the
// team.
func (r *identityMemberPayoutResolver) activeOnTeam(ctx context.Context, teamID, memberID string) (bool, error) {
	stream, err := r.identity.TeamMembershipSearch(ctx, &identityv1.TeamMembershipSearchRequest{
		TeamId:   teamID,
		MemberId: memberID,
	})
	if err != nil {
		return false, err
	}
	defer func() { _ = stream.Close() }()
	for {
		msg, recvErr := stream.Receive()
		if recvErr != nil {
			if errors.Is(recvErr, io.EOF) {
				return false, nil
			}
			return false, recvErr
		}
		for _, m := range msg.GetData() {
			if m.GetTeamId() == teamID && m.GetMemberId() == memberID &&
				m.GetState() == commonv1.STATE_ACTIVE {
				return true, nil
			}
		}
	}
}

// TeamCommissions keeps teams' commission: it records what each repayment
// earned and pays it out to a member of the team.
type TeamCommissions struct {
	repo        repository.TeamCommissionRepository
	members     TeamMemberPayoutResolver
	operations  operationsv1connect.OperationsServiceClient
	auditWriter *audit.Writer
}

// NewTeamCommissions wires team commission.
func NewTeamCommissions(
	repo repository.TeamCommissionRepository,
	members TeamMemberPayoutResolver,
	operations operationsv1connect.OperationsServiceClient,
	auditWriter *audit.Writer,
) *TeamCommissions {
	return &TeamCommissions{repo: repo, members: members, operations: operations, auditWriter: auditWriter}
}

// Accrue adds commission a repayment earned to the team's balance, once.
func (t *TeamCommissions) Accrue(
	ctx context.Context,
	la *models.LoanAccount,
	teamID, currency string,
	amount int64,
	reference string,
) error {
	if t == nil || t.repo == nil {
		return nil
	}
	m := &models.TeamCommissionMovement{
		TeamID:       teamID,
		CurrencyCode: currency,
		Kind:         int32(models.TeamCommissionAccrual),
		Amount:       amount,
		Reference:    reference,
		Status:       int32(loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_COMPLETED),
		Properties:   data.JSONMap{fieldLoanID: la.GetID()},
	}
	m.CopyPartitionInfo(&la.BaseModel)
	if _, err := t.repo.Accrue(ctx, m); err != nil {
		return fmt.Errorf("record commission %s: %w", reference, err)
	}
	return nil
}

// Search lists teams' commission balances.
func (t *TeamCommissions) Search(
	ctx context.Context,
	teamID string,
	offset, limit int,
) ([]*loansv1.TeamCommissionObject, error) {
	rows, err := t.repo.Search(ctx, teamID, offset, pageSize(limit))
	if err != nil {
		return nil, err
	}
	out := make([]*loansv1.TeamCommissionObject, 0, len(rows))
	for _, row := range rows {
		out = append(out, row.ToAPI())
	}
	return out, nil
}

// SearchPayouts lists a team's payouts, newest first.
func (t *TeamCommissions) SearchPayouts(
	ctx context.Context,
	teamID string,
	offset, limit int,
) ([]*loansv1.TeamCommissionPayoutObject, error) {
	rows, err := t.repo.SearchPayouts(ctx, teamID, offset, pageSize(limit))
	if err != nil {
		return nil, err
	}
	out := make([]*loansv1.TeamCommissionPayoutObject, 0, len(rows))
	for _, row := range rows {
		out = append(out, row.ToPayoutAPI())
	}
	return out, nil
}

// Payout pays part of a team's commission to one of its active members'
// own verified mobile money. The movement row is the idempotency record:
// the balance is taken once, in the transaction that moves the row out of
// PENDING, and a retry with the same key resumes the same order.
func (t *TeamCommissions) Payout(
	ctx context.Context,
	req *loansv1.TeamCommissionPayoutRequest,
) (*loansv1.TeamCommissionPayoutObject, error) {
	minor, currency := models.MoneyToMinorUnits(req.GetAmount())
	if minor <= 0 || currency == "" {
		return nil, ErrCommissionPayoutInvalid
	}
	if t.operations == nil {
		return nil, ErrOperationsClientUnavailable
	}
	logger := util.Log(ctx).WithField("team_id", req.GetTeamId()).WithField("member_id", req.GetMemberId())

	// Where the money goes is settled before anything is taken: the
	// member's own number, never one somebody names.
	dest, err := t.members.MemberPayout(ctx, req.GetTeamId(), req.GetMemberId())
	if err != nil {
		return nil, err
	}

	claim := &models.TeamCommissionMovement{
		TeamID:       req.GetTeamId(),
		CurrencyCode: currency,
		Kind:         int32(models.TeamCommissionPayout),
		Amount:       minor,
		Reference:    commissionPayoutPrefix + req.GetIdempotencyKey(),
		Status:       int32(loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_PENDING),
		MemberID:     req.GetMemberId(),
		Reason:       req.GetReason(),
		CreatedBy:    callerSubject(ctx),
	}
	movement, _, err := t.repo.ClaimPayout(ctx, claim)
	if err != nil {
		return nil, fmt.Errorf("claim commission payout: %w", err)
	}
	if movement.TeamID != claim.TeamID || movement.MemberID != claim.MemberID ||
		movement.Amount != claim.Amount || movement.CurrencyCode != claim.CurrencyCode ||
		movement.Kind != claim.Kind {
		return nil, ErrCommissionPayoutKeyReused
	}
	switch loansv1.TeamCommissionPayoutStatus(movement.Status) { //nolint:exhaustive // the rest resume below
	case loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_COMPLETED:
		return movement.ToPayoutAPI(), nil
	case loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_PENDING:
		if debitErr := t.repo.DebitPayout(ctx, movement); debitErr != nil {
			if errors.Is(debitErr, repository.ErrCommissionInsufficient) {
				return nil, ErrCommissionInsufficient
			}
			return nil, fmt.Errorf("take commission payout from balance: %w", debitErr)
		}
		movement.Status = int32(loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_PROCESSING)
	}

	_, err = t.operations.TransferOrderExecute(ctx, &operationsv1.TransferOrderExecuteRequest{
		Data: transferorder.Typed(&operationsv1.TransferOrderObject{
			DebitAccountRef:  constants.TeamCommissionPayableAccount(movement.TeamID),
			CreditAccountRef: constants.PlatformExternalCashAccount(),
			Amount:           moneyx.FromMinorUnitsByCurrency(movement.CurrencyCode, movement.Amount),
			Reference:        commissionPayoutReference + movement.GetID(),
			Description:      "Team commission paid to a member",
			ExtraData: (&data.JSONMap{
				"team_id":              movement.TeamID,
				"member_id":            movement.MemberID,
				"recipient_profile_id": dest.ProfileID,
				fieldPaymentAccount:    dest.ContactID,
				fieldPaymentChannel:    "mobile_money",
			}).ToProtoStruct(),
		}, constants.TransferTypeTeamCommissionPayout),
	})
	if err != nil {
		// Only a refusal means nothing moved; then the amount goes back to
		// the balance and the same key may be retried. Any other failure may
		// have paid the member, so the payout stays taken; retrying the key
		// resumes the same order and never pays twice.
		if !payoutRefused(err) {
			logger.WithError(err).Warn("commission payout outcome unknown; kept taken for a retry")
			return nil, err
		}
		if revertErr := t.repo.RevertPayout(ctx, movement, err.Error()); revertErr != nil {
			logger.WithError(revertErr).Error("could not return a refused commission payout to the balance")
		}
		return nil, err
	}

	if completeErr := t.repo.CompletePayout(ctx, movement.GetID()); completeErr != nil {
		return nil, fmt.Errorf("mark commission payout paid: %w", completeErr)
	}
	movement.Status = int32(loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_COMPLETED)

	t.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityTeamCommission,
		EntityID:   movement.TeamID,
		Action:     actionCommissionPaidOut,
		ActorID:    movement.CreatedBy,
		Reason:     movement.Reason,
		After: data.JSONMap{
			fieldAmount:   movement.Amount,
			fieldCurrency: movement.CurrencyCode,
			"member_id":   movement.MemberID,
		},
		Metadata: data.JSONMap{"payout_id": movement.GetID()},
		Parent:   &movement.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for commission payout")
	})
	return movement.ToPayoutAPI(), nil
}

// payoutRefused reports whether a payout error means nothing moved: the
// precondition-class codes of the operations payout contract.
func payoutRefused(err error) bool {
	switch connect.CodeOf(err) { //nolint:exhaustive // only refusal codes matter
	case connect.CodeInvalidArgument, connect.CodeFailedPrecondition,
		connect.CodeNotFound, connect.CodePermissionDenied:
		return true
	default:
		return false
	}
}

func pageSize(limit int) int {
	if limit <= 0 || limit > maxCommissionPageSize {
		return maxCommissionPageSize
	}
	return limit
}
