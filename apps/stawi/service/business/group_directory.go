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
	"strconv"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"

	"github.com/antinvestor/service-fintech/pkg/apperrors"
	stawiproduct "github.com/antinvestor/service-fintech/products/stawi"
)

const (
	// groupSearchPage is identity's largest search page.
	groupSearchPage int32 = 200
	// maxGroupSearchPages bounds one listing of a tenant's groups.
	maxGroupSearchPages = 100
)

// GroupDirectory is identity's view of the groups stawi runs. Identity owns
// groups; stawi reads their state and where their records belong.
type GroupDirectory interface {
	// ActiveGroups lists the active groups of the types stawi runs, in the
	// tenant ctx acts for.
	ActiveGroups(ctx context.Context) ([]*identityv1.ClientGroupObject, error)
	Get(ctx context.Context, id string) (*identityv1.ClientGroupObject, error)
	// PartitionOf is the partition a group's records belong in: the
	// partition of the branch that runs it.
	PartitionOf(ctx context.Context, group *identityv1.ClientGroupObject) (string, error)
}

type identityGroupDirectory struct {
	product  stawiproduct.ProductConfig
	identity identityv1connect.IdentityServiceClient
}

// NewGroupDirectory reads stawi's groups from identity.
func NewGroupDirectory(
	product stawiproduct.ProductConfig,
	identity identityv1connect.IdentityServiceClient,
) GroupDirectory {
	return &identityGroupDirectory{product: product, identity: identity}
}

// ActiveGroups asks identity for only the active groups of stawi's types, so
// a run pages through the groups it runs rather than the whole tenant. The
// filter is checked again here so an identity that ignores it still yields
// only groups stawi runs.
func (d *identityGroupDirectory) ActiveGroups(ctx context.Context) ([]*identityv1.ClientGroupObject, error) {
	var active []*identityv1.ClientGroupObject
	for page := range maxGroupSearchPages {
		offset := page * int(groupSearchPage)
		groups, err := d.searchPage(ctx, offset, commonv1.STATE_ACTIVE)
		if err != nil {
			return nil, err
		}
		for _, g := range groups {
			if groupActive(g) && d.product.RunsGroupType(g.GetGroupType()) {
				active = append(active, g)
			}
		}
		if len(groups) < int(groupSearchPage) {
			return active, nil
		}
	}
	return active, nil
}

func (d *identityGroupDirectory) searchPage(
	ctx context.Context,
	offset int,
	states ...commonv1.STATE,
) ([]*identityv1.ClientGroupObject, error) {
	stream, err := d.identity.ClientGroupSearch(ctx, d.searchRequest(offset, states...))
	if err != nil {
		return nil, fmt.Errorf("client group search: %w", err)
	}
	var groups []*identityv1.ClientGroupObject
	for {
		msg, recvErr := stream.Receive()
		if recvErr != nil {
			if errors.Is(recvErr, io.EOF) {
				return groups, nil
			}
			return nil, fmt.Errorf("client group search: %w", recvErr)
		}
		groups = append(groups, msg.GetData()...)
	}
}

// searchRequest asks identity for one page of the groups of stawi's types
// in the given states.
func (d *identityGroupDirectory) searchRequest(
	offset int,
	states ...commonv1.STATE,
) *identityv1.ClientGroupSearchRequest {
	return &identityv1.ClientGroupSearchRequest{
		States:     states,
		GroupTypes: d.product.GroupTypes,
		Cursor:     &commonv1.PageCursor{Limit: groupSearchPage, Page: strconv.Itoa(offset)},
	}
}

func (d *identityGroupDirectory) Get(ctx context.Context, id string) (*identityv1.ClientGroupObject, error) {
	resp, err := d.identity.ClientGroupGet(ctx, &identityv1.ClientGroupGetRequest{Id: id})
	if err != nil {
		return nil, fmt.Errorf("client group get: %w", err)
	}
	return resp.GetData(), nil
}

func (d *identityGroupDirectory) PartitionOf(ctx context.Context, group *identityv1.ClientGroupObject) (string, error) {
	if group.GetBranchId() == "" {
		return "", apperrors.NewError(apperrors.Unprocessable, "the group has no branch to place its records in")
	}
	resp, err := d.identity.OrgUnitGet(ctx, &identityv1.OrgUnitGetRequest{Id: group.GetBranchId()})
	if err != nil {
		return "", fmt.Errorf("org unit get: %w", err)
	}
	if resp.GetData().GetPartitionId() == "" {
		return "", apperrors.NewError(apperrors.Unprocessable, "the group's branch has no partition")
	}
	return resp.GetData().GetPartitionId(), nil
}

// groupActive reports whether identity holds the group active. Identity
// types group state with the platform's common STATE.
func groupActive(group *identityv1.ClientGroupObject) bool {
	return group.GetState() == commonv1.STATE_ACTIVE
}
