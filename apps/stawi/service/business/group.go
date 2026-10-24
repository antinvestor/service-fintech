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

	"google.golang.org/protobuf/types/known/structpb"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	ledgerv1 "buf.build/gen/go/antinvestor/ledger/protocolbuffers/go/v1"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/constants"
	stawiproduct "github.com/antinvestor/service-fintech/products/stawi"
)

type groupBusiness struct {
	product     stawiproduct.ProductConfig
	identityCli identityv1connect.IdentityServiceClient
	clients     *clients.PlatformClients
}

const membershipSearchLimit int32 = 1000

func NewClientGroupBusiness(
	_ context.Context,
	product stawiproduct.ProductConfig,
	identityCli identityv1connect.IdentityServiceClient,
	pc *clients.PlatformClients,
) ClientGroupBusiness {
	return &groupBusiness{product: product, identityCli: identityCli, clients: pc}
}

func (b *groupBusiness) Create(
	ctx context.Context,
	group *identityv1.ClientGroupObject,
) (*identityv1.ClientGroupObject, error) {
	// A group always starts in CREATED. Accepting a caller-supplied state would
	// let a group skip formation checks, ledger setup and lender registration.
	group.State = commonv1.STATE_CREATED

	resp, err := b.identityCli.ClientGroupSave(ctx, &identityv1.ClientGroupSaveRequest{Data: group})
	if err != nil {
		return nil, fmt.Errorf("could not save client group: %w", err)
	}

	return resp.GetData(), nil
}

func (b *groupBusiness) Get(ctx context.Context, id string) (*identityv1.ClientGroupObject, error) {
	resp, err := b.identityCli.ClientGroupGet(ctx, &identityv1.ClientGroupGetRequest{Id: id})
	if err != nil {
		return nil, apperrors.ErrDataNotFound.Extend("client group")
	}
	return resp.GetData(), nil
}

func (b *groupBusiness) Transition(ctx context.Context, groupID string, newState int32, reason string) error {
	logger := util.Log(ctx).WithFields(map[string]any{
		"method": "GroupBusiness.Transition", fieldGroupID: groupID, "new_state": newState,
	})

	group, err := b.Get(ctx, groupID)
	if err != nil {
		return err
	}

	currentState := int32(group.GetState())
	valid := false
	switch newState {
	case int32(constants.StateCheckCreated):
		valid = currentState == int32(constants.StateJustCreated)
	case int32(constants.StateActive):
		valid = currentState == int32(constants.StateCheckCreated) || currentState == int32(constants.StateInactive)
	case int32(constants.StateInactive):
		valid = currentState == int32(constants.StateActive)
	case int32(constants.StateShutdown):
		valid = currentState == int32(constants.StateJustCreated) ||
			currentState == int32(constants.StateCheckCreated) ||
			currentState == int32(constants.StateActive) ||
			currentState == int32(constants.StateInactive)
	case int32(constants.StateDeleted):
		valid = currentState == int32(constants.StateShutdown)
	}

	if !valid {
		return apperrors.NewError(apperrors.Unprocessable,
			fmt.Sprintf("invalid group state transition from %d to %d", currentState, newState))
	}

	group.State = commonv1.STATE(newState)
	if _, saveErr := b.identityCli.ClientGroupSave(
		ctx,
		&identityv1.ClientGroupSaveRequest{Data: group},
	); saveErr != nil {
		logger.WithError(saveErr).Error("could not save group state transition")
		return saveErr
	}

	logger.WithField("reason", reason).Info("group state transitioned")
	return nil
}

func (b *groupBusiness) CheckFormation(ctx context.Context, groupID string) (map[string]interface{}, error) {
	logger := util.Log(ctx).WithField("method", "GroupBusiness.CheckFormation")

	group, err := b.Get(ctx, groupID)
	if err != nil {
		return nil, err
	}

	members, err := b.searchMembers(ctx, groupID)
	if err != nil {
		logger.WithError(err).Error("could not get members")
		return nil, err
	}

	memberCount := len(members)
	minMembers := int(b.product.MinGroupSize)
	if group.GetMinMembers() > 0 {
		minMembers = int(group.GetMinMembers())
	}

	formed := memberCount >= minMembers
	result := map[string]interface{}{
		fieldGroupID:    groupID,
		"member_count":  memberCount,
		"min_members":   minMembers,
		"formed":        formed,
		"current_state": int32(group.GetState()),
	}

	if formed && int32(group.GetState()) == int32(constants.StateJustCreated) {
		if transErr := b.Transition(
			ctx,
			groupID,
			int32(constants.StateCheckCreated),
			"formation threshold met",
		); transErr != nil {
			logger.WithError(transErr).Warn("could not auto-transition to CHECK_CREATED")
		} else {
			result["transitioned_to"] = constants.StateCheckCreated
		}
	}

	return result, nil
}

func (b *groupBusiness) WelcomeGroup(ctx context.Context, groupID string) error {
	group, err := b.Get(ctx, groupID)
	if err != nil {
		return err
	}

	if int32(group.GetState()) != int32(constants.StateCheckCreated) {
		return apperrors.NewError(apperrors.Unprocessable,
			"group must have passed formation checks before it can be welcomed")
	}

	if regErr := b.RegisterWithLender(ctx, groupID); regErr != nil {
		return fmt.Errorf("could not register group with lender: %w", regErr)
	}

	return b.Transition(ctx, groupID, int32(constants.StateActive), "group welcomed and activated")
}

func (b *groupBusiness) SetupLedgerAccounts(ctx context.Context, groupID string) error {
	logger := util.Log(ctx).WithField("method", "GroupBusiness.SetupLedgerAccounts")

	if b.clients == nil || b.clients.LedgerClient == nil {
		return apperrors.NewError(apperrors.ServiceUnavailable,
			"ledger service is required to set up group accounts")
	}

	group, err := b.Get(ctx, groupID)
	if err != nil {
		return err
	}

	accountNames := []string{
		constants.GroupBankAccount(groupID),
		constants.GroupPenaltyIncomeAccount(groupID),
		constants.GroupInterestIncomeAccount(groupID),
		constants.GroupJoiningFeeAccount(groupID),
		constants.GroupTransactionCostsAccount(groupID),
		constants.GroupServiceFeeAccount(groupID),
		constants.GroupSavingsInterestIncomeAccount(groupID),
	}

	// Every failure is collected and returned: activating a group whose bank
	// account does not exist breaks every later transfer, long after obligations
	// and offers have been generated. CreateAccount is idempotent on Id, so the
	// step is safe to re-run.
	var failures []error
	for _, acctName := range accountNames {
		req := &ledgerv1.CreateAccountRequest{
			Id:       acctName,
			LedgerId: groupID,
			Currency: group.GetCurrencyCode(),
		}
		if _, createErr := b.clients.LedgerClient.CreateAccount(ctx, req); createErr != nil {
			logger.WithError(createErr).WithField("account", acctName).Error("could not create ledger account")
			failures = append(failures, fmt.Errorf("account %s: %w", acctName, createErr))
		}
	}
	if len(failures) > 0 {
		return fmt.Errorf("ledger account setup failed: %w", errors.Join(failures...))
	}

	logger.Info("ledger account setup completed")
	return nil
}

func (b *groupBusiness) RegisterWithLender(ctx context.Context, groupID string) error {
	logger := util.Log(ctx).WithField("method", "GroupBusiness.RegisterWithLender")

	group, err := b.Get(ctx, groupID)
	if err != nil {
		return err
	}

	if b.clients == nil || b.clients.LenderIdentity == nil {
		return apperrors.NewError(apperrors.ServiceUnavailable,
			"lender identity service is required to register group members")
	}

	members, err := b.searchMembers(ctx, groupID)
	if err != nil {
		return fmt.Errorf("could not get members: %w", err)
	}

	return b.registerMembers(ctx, logger, members, group.GetAgentId())
}

func (b *groupBusiness) searchMembers(ctx context.Context, groupID string) ([]*identityv1.MembershipObject, error) {
	stream, err := b.identityCli.MembershipSearch(ctx, &identityv1.MembershipSearchRequest{
		GroupId: groupID,
		Cursor:  &commonv1.PageCursor{Limit: membershipSearchLimit},
	})
	if err != nil {
		return nil, err
	}

	var result []*identityv1.MembershipObject
	for {
		msg, recvErr := stream.Receive()
		if recvErr != nil {
			if errors.Is(recvErr, io.EOF) {
				break
			}
			return nil, recvErr
		}
		result = append(result, msg.GetData()...)
	}

	return result, nil
}

func (b *groupBusiness) registerMembers(
	ctx context.Context,
	logger *util.LogEntry,
	members []*identityv1.MembershipObject,
	agentID string,
) error {
	if agentID == "" {
		return apperrors.NewError(apperrors.Unprocessable, "group has no lending agent assigned")
	}

	var failures []error
	for _, m := range members {
		if m.GetProperties() != nil {
			if _, ok := m.GetProperties().GetFields()["client_id"]; ok {
				continue
			}
		}

		clientID, cliErr := b.clients.RegisterClient(ctx, agentID, m.GetProfileId(), m.GetName())
		if cliErr != nil {
			logger.WithError(cliErr).WithField("membership_id", m.GetId()).Error("could not register client")
			failures = append(failures, fmt.Errorf("membership %s: %w", m.GetId(), cliErr))
			continue
		}
		if clientID != "" {
			logger.WithField("membership_id", m.GetId()).
				WithField("client_id", clientID).
				Info("member registered as client")
			// Remember the client on the membership, so a retried welcome
			// does not register the member a second time and loan
			// origination knows which client to lend to.
			if err := b.rememberClientID(ctx, m, clientID); err != nil {
				logger.WithError(err).WithField("membership_id", m.GetId()).
					Error("could not record client id on membership")
				failures = append(failures, fmt.Errorf("membership %s: %w", m.GetId(), err))
			}
		}
	}
	if len(failures) > 0 {
		return errors.Join(failures...)
	}
	return nil
}

// rememberClientID stores the lender's client id on the membership.
func (b *groupBusiness) rememberClientID(ctx context.Context, m *identityv1.MembershipObject, clientID string) error {
	props := map[string]any{}
	if m.GetProperties() != nil {
		props = m.GetProperties().AsMap()
	}
	props["client_id"] = clientID
	updated, err := structpb.NewStruct(props)
	if err != nil {
		return err
	}
	m.Properties = updated
	_, err = b.identityCli.MembershipSave(ctx, &identityv1.MembershipSaveRequest{Data: m})
	return err
}
