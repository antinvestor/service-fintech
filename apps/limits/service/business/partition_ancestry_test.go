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
	"testing"

	"buf.build/gen/go/antinvestor/tenancy/connectrpc/go/v2/tenancy/v1/tenancyv1connect"
	tenancyv1 "buf.build/gen/go/antinvestor/tenancy/protocolbuffers/go/tenancy/v1"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func partition(id, parent string) *tenancyv1.PartitionObject {
	return &tenancyv1.PartitionObject{Id: id, ParentId: parent}
}

func TestChainFromParents(t *testing.T) {
	tests := []struct {
		name    string
		parents []*tenancyv1.PartitionObject
		want    []string
		wantErr bool
	}{
		{name: "root partition", parents: nil, want: []string{"unit"}},
		{
			name: "walks from the partition up to the root",
			parents: []*tenancyv1.PartitionObject{
				partition("org", ""),
				partition("region", "org"),
				partition("branch", "region"),
			},
			want: []string{"unit", "branch", "region", "org"},
		},
		{
			name:    "a walk cut short above the root is refused",
			parents: []*tenancyv1.PartitionObject{partition("region", "org"), partition("branch", "region")},
			wantErr: true,
		},
		{
			name:    "duplicates and blanks are dropped",
			parents: []*tenancyv1.PartitionObject{partition("org", ""), partition("", "org"), partition("unit", "org")},
			want:    []string{"unit", "org"},
		},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			got, err := chainFromParents("unit", tc.parents)
			if tc.wantErr {
				require.ErrorIs(t, err, ErrPartitionChainUnavailable)
				return
			}
			require.NoError(t, err)
			assert.Equal(t, tc.want, got)
		})
	}
}

type fakeTenancy struct {
	tenancyv1connect.TenancyServiceClient
	calls   int
	parents []*tenancyv1.PartitionObject
	err     error
}

func (f *fakeTenancy) GetPartitionParents(
	_ context.Context,
	_ *tenancyv1.GetPartitionParentsRequest,
) (*tenancyv1.GetPartitionParentsResponse, error) {
	f.calls++
	if f.err != nil {
		return nil, f.err
	}
	return &tenancyv1.GetPartitionParentsResponse{Data: f.parents}, nil
}

func TestPartitionAncestry_CachesAndFailsClosed(t *testing.T) {
	cli := &fakeTenancy{parents: []*tenancyv1.PartitionObject{partition("org", "")}}
	a := NewPartitionAncestry(cli, 0)

	for range 2 {
		chain, err := a.Chain(context.Background(), "branch")
		require.NoError(t, err)
		assert.Equal(t, []string{"branch", "org"}, chain)
	}
	assert.Equal(t, 1, cli.calls, "the tree is cached between transactions")

	failing := NewPartitionAncestry(&fakeTenancy{err: errors.New("tenancy down")}, 0)
	_, err := failing.Chain(context.Background(), "branch")
	require.ErrorIs(t, err, ErrPartitionChainUnavailable)

	empty, err := failing.Chain(context.Background(), "")
	require.NoError(t, err)
	assert.Nil(t, empty, "an unknown partition carries no chain")
}
