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
	"fmt"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	ledgerv1 "buf.build/gen/go/antinvestor/ledger/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

type groupBusiness struct {
	identityCli identityv1connect.IdentityServiceClient
	clients     *clients.PlatformClients
}

const membershipSearchLimit int32 = 1000

func NewClientGroupBusiness(
	_ context.Context,
	identityCli identityv1connect.IdentityServiceClient,
	pc *clients.PlatformClients,
) ClientGroupBusiness {
	return &groupBusiness{identityCli: identityCli, clients: pc}
}

func (b *groupBusiness) Create(
	ctx context.Context,
	group *identityv1.ClientGroupObject,
) (*identityv1.ClientGroupObject, error) {
	if group.GetState() == commonv1.STATE_CREATED {
		group.State = commonv1.STATE_CREATED
	}

	resp, err := b.identityCli.ClientGroupSave(ctx, connect.NewRequest(
		&identityv1.ClientGroupSaveRequest{Data: group},
	))
	if err != nil {
		return nil, fmt.Errorf("could not save client group: %w", err)
	}

	return resp.Msg.GetData(), nil
}

func (b *groupBusiness) Get(ctx context.Context, id string) (*identityv1.ClientGroupObject, error) {
	resp, err := b.identityCli.ClientGroupGet(ctx, connect.NewRequest(
		&identityv1.ClientGroupGetRequest{Id: id},
	))
	if err != nil {
		return nil, fmt.Errorf("client group not found: %w", err)
	}
	return resp.Msg.GetData(), nil
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
		valid = true
	case int32(constants.StateDeleted):
		valid = currentState == int32(constants.StateShutdown)
	}

	if !valid {
		return fmt.Errorf("invalid state transition from %d to %d", currentState, newState)
	}

	group.State = commonv1.STATE(newState)
	if _, saveErr := b.identityCli.ClientGroupSave(ctx, connect.NewRequest(
		&identityv1.ClientGroupSaveRequest{Data: group},
	)); saveErr != nil {
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
	minMembers := 5
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
	logger := util.Log(ctx).WithField("method", "GroupBusiness.WelcomeGroup")

	group, err := b.Get(ctx, groupID)
	if err != nil {
		return err
	}

	if int32(group.GetState()) != int32(constants.StateCheckCreated) {
		return fmt.Errorf("group must be in CHECK_CREATED state, currently %d", int32(group.GetState()))
	}

	if regErr := b.RegisterWithLender(ctx, groupID); regErr != nil {
		logger.WithError(regErr).Warn("could not register with lender during welcome")
	}

	return b.Transition(ctx, groupID, int32(constants.StateActive), "group welcomed and activated")
}

func (b *groupBusiness) SetupLedgerAccounts(ctx context.Context, groupID string) error {
	logger := util.Log(ctx).WithField("method", "GroupBusiness.SetupLedgerAccounts")

	if b.clients == nil || b.clients.LedgerClient == nil {
		logger.Warn("ledger client not available, skipping")
		return nil
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

	for _, acctName := range accountNames {
		req := connect.NewRequest(&ledgerv1.CreateAccountRequest{
			Id:       acctName,
			LedgerId: groupID,
			Currency: group.GetCurrencyCode(),
		})
		if _, createErr := b.clients.LedgerClient.CreateAccount(ctx, req); createErr != nil {
			logger.WithError(createErr).WithField("account", acctName).Warn("could not create ledger account")
		}
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
		logger.Warn("lender field client not available, skipping registration")
		return nil
	}

	members, err := b.searchMembers(ctx, groupID)
	if err != nil {
		return fmt.Errorf("could not get members: %w", err)
	}

	agentID := group.GetAgentId()
	b.registerMembers(ctx, logger, members, agentID)
	return nil
}

func (b *groupBusiness) searchMembers(ctx context.Context, groupID string) ([]*identityv1.MembershipObject, error) {
	stream, err := b.identityCli.MembershipSearch(ctx, connect.NewRequest(
		&identityv1.MembershipSearchRequest{
			GroupId: groupID,
			Cursor:  &commonv1.PageCursor{Limit: membershipSearchLimit},
		},
	))
	if err != nil {
		return nil, err
	}

	var result []*identityv1.MembershipObject
	for stream.Receive() {
		result = append(result, stream.Msg().GetData()...)
	}
	if stream.Err() != nil {
		return nil, stream.Err()
	}
	return result, nil
}

func (b *groupBusiness) registerMembers(
	ctx context.Context,
	logger *util.LogEntry,
	members []*identityv1.MembershipObject,
	agentID string,
) {
	for _, m := range members {
		if m.GetProperties() != nil {
			if _, ok := m.GetProperties().GetFields()["client_id"]; ok {
				continue
			}
		}

		if agentID != "" && b.clients != nil {
			clientID, cliErr := b.clients.RegisterClient(ctx, agentID, m.GetProfileId(), m.GetName())
			if cliErr != nil {
				logger.WithError(cliErr).WithField("membership_id", m.GetId()).Warn("could not register client")
			} else if clientID != "" {
				logger.WithField("membership_id", m.GetId()).
					WithField("client_id", clientID).
					Info("member registered as client")
			}
		}
	}
}
