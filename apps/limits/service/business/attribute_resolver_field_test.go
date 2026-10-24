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
	"testing"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"connectrpc.com/connect/v2"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/structpb"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
)

type fakeFieldClients struct {
	fieldv1connect.FieldServiceClient
	clients map[string]*fieldv1.ClientObject
}

func (f fakeFieldClients) ClientGet(
	_ context.Context,
	req *fieldv1.ClientGetRequest,
) (*fieldv1.ClientGetResponse, error) {
	c, ok := f.clients[req.GetId()]
	if !ok {
		return nil, connect.NewError(connect.CodeNotFound, "no such client")
	}
	return &fieldv1.ClientGetResponse{Data: c}, nil
}

func TestResolver_FieldClientPropertiesCannotOverrideSystemAttributes(t *testing.T) {
	props, err := structpb.NewStruct(map[string]any{"limit_tier": "restricted", "state": "ACTIVE"})
	require.NoError(t, err)
	field := fakeFieldClients{clients: map[string]*fieldv1.ClientObject{
		"client-1": {Id: "client-1", Name: "Amina", State: commonv1.STATE_INACTIVE, Properties: props},
	}}
	r := NewAttributeResolver(newStubAttrRepo(), nil, time.Minute, WithFieldClients(field))

	attrs, err := r.Get(context.Background(), models.SubjectClient, "client-1")
	require.NoError(t, err)
	assert.Equal(t, "restricted", attrs["limit_tier"], "a tier the agent set is visible to tier policies")
	assert.Equal(t, commonv1.STATE_INACTIVE.String(), attrs["state"], "a property cannot claim a different state")
}

func TestResolver_UnknownClientIsUnavailableNotAttributeless(t *testing.T) {
	r := NewAttributeResolver(newStubAttrRepo(), nil, time.Minute,
		WithFieldClients(fakeFieldClients{clients: map[string]*fieldv1.ClientObject{}}))

	attrs, err := r.Get(context.Background(), models.SubjectClient, "nobody")
	require.NoError(t, err)
	assert.Nil(t, attrs, "nil means unavailable: enforce policies with a filter fail closed on it")
}
