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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"connectrpc.com/connect"

	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

type membershipBusiness struct {
	identityCli identityv1connect.IdentityServiceClient
}

func NewMembershipBusiness(
	_ context.Context,
	identityCli identityv1connect.IdentityServiceClient,
) MembershipBusiness {
	return &membershipBusiness{identityCli: identityCli}
}

func (b *membershipBusiness) Create(
	ctx context.Context,
	membership *identityv1.MembershipObject,
) (*identityv1.MembershipObject, error) {
	resp, err := b.identityCli.MembershipSave(ctx, connect.NewRequest(
		&identityv1.MembershipSaveRequest{Data: membership},
	))
	if err != nil {
		return nil, err
	}
	return resp.Msg.GetData(), nil
}

func (b *membershipBusiness) Get(ctx context.Context, id string) (*identityv1.MembershipObject, error) {
	resp, err := b.identityCli.MembershipGet(ctx, connect.NewRequest(
		&identityv1.MembershipGetRequest{Id: id},
	))
	if err != nil {
		return nil, err
	}
	return resp.Msg.GetData(), nil
}

func (b *membershipBusiness) GetByGroupID(ctx context.Context, groupID string) ([]*identityv1.MembershipObject, error) {
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

func (b *membershipBusiness) UpdateRole(_ context.Context, _ string, _ int32) error {
	return apperrors.NewError(apperrors.Unprocessable,
		"membership role changes are not available for this product")
}

func (b *membershipBusiness) CheckPeriodicPayment(_ context.Context, _ string) (map[string]interface{}, error) {
	return nil, apperrors.NewError(apperrors.Unprocessable,
		"periodic payment checks are not available for this product")
}
