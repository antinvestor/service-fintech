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
	"net/http"
	"net/http/httptest"
	"testing"

	"buf.build/gen/go/antinvestor/tenancy/connectrpc/go/tenancy/v1/tenancyv1connect"
	tenancyv1 "buf.build/gen/go/antinvestor/tenancy/protocolbuffers/go/tenancy/v1"
	"connectrpc.com/connect"
	"github.com/stretchr/testify/require"
)

// stubTenancyServer implements just the handful of tenancy RPCs the platform
// access adapter uses; everything else stays Unimplemented.
type stubTenancyServer struct {
	tenancyv1connect.UnimplementedTenancyServiceHandler

	// knownProfileID resolves to accessForProfile; anything else is NotFound.
	knownProfileID   string
	accessForProfile string
	// partitionRoles and accessRoles are streamed one message per element to
	// exercise multi-message stream draining.
	partitionRoles []*tenancyv1.PartitionRoleObject
	accessRoles    []*tenancyv1.AccessRoleObject
	// listPartitionRoleErr aborts the partition role stream mid-flight.
	listPartitionRoleErr error

	createdRole *tenancyv1.CreatePartitionRoleRequest
	// removedAccessRoleIDs records every RemoveAccessRole request id.
	removedAccessRoleIDs []string
	// removeAccessRoleErr is returned by RemoveAccessRole when set.
	removeAccessRoleErr error
}

func (s *stubTenancyServer) GetAccess(
	_ context.Context,
	req *connect.Request[tenancyv1.GetAccessRequest],
) (*connect.Response[tenancyv1.GetAccessResponse], error) {
	if req.Msg.GetProfileId() != s.knownProfileID {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("no access for profile"))
	}
	return connect.NewResponse(&tenancyv1.GetAccessResponse{
		Data: &tenancyv1.AccessObject{Id: s.accessForProfile},
	}), nil
}

func (s *stubTenancyServer) CreateAccess(
	_ context.Context,
	req *connect.Request[tenancyv1.CreateAccessRequest],
) (*connect.Response[tenancyv1.CreateAccessResponse], error) {
	return connect.NewResponse(&tenancyv1.CreateAccessResponse{
		Data: &tenancyv1.AccessObject{Id: "access-for-" + req.Msg.GetProfileId()},
	}), nil
}

func (s *stubTenancyServer) ListPartitionRole(
	_ context.Context,
	_ *connect.Request[tenancyv1.ListPartitionRoleRequest],
	stream *connect.ServerStream[tenancyv1.ListPartitionRoleResponse],
) error {
	for _, role := range s.partitionRoles {
		if err := stream.Send(&tenancyv1.ListPartitionRoleResponse{
			Data: []*tenancyv1.PartitionRoleObject{role},
		}); err != nil {
			return err
		}
	}
	return s.listPartitionRoleErr
}

func (s *stubTenancyServer) CreatePartitionRole(
	_ context.Context,
	req *connect.Request[tenancyv1.CreatePartitionRoleRequest],
) (*connect.Response[tenancyv1.CreatePartitionRoleResponse], error) {
	s.createdRole = req.Msg
	return connect.NewResponse(&tenancyv1.CreatePartitionRoleResponse{
		Data: &tenancyv1.PartitionRoleObject{Id: "role-created", Name: req.Msg.GetName()},
	}), nil
}

func (s *stubTenancyServer) ListAccessRole(
	_ context.Context,
	_ *connect.Request[tenancyv1.ListAccessRoleRequest],
	stream *connect.ServerStream[tenancyv1.ListAccessRoleResponse],
) error {
	for _, accessRole := range s.accessRoles {
		if err := stream.Send(&tenancyv1.ListAccessRoleResponse{
			Data: []*tenancyv1.AccessRoleObject{accessRole},
		}); err != nil {
			return err
		}
	}
	return nil
}

func (s *stubTenancyServer) CreateAccessRole(
	_ context.Context,
	req *connect.Request[tenancyv1.CreateAccessRoleRequest],
) (*connect.Response[tenancyv1.CreateAccessRoleResponse], error) {
	return connect.NewResponse(&tenancyv1.CreateAccessRoleResponse{
		Data: &tenancyv1.AccessRoleObject{Id: "access-role-created", AccessId: req.Msg.GetAccessId()},
	}), nil
}

func (s *stubTenancyServer) RemoveAccessRole(
	_ context.Context,
	req *connect.Request[tenancyv1.RemoveAccessRoleRequest],
) (*connect.Response[tenancyv1.RemoveAccessRoleResponse], error) {
	s.removedAccessRoleIDs = append(s.removedAccessRoleIDs, req.Msg.GetId())
	if s.removeAccessRoleErr != nil {
		return nil, s.removeAccessRoleErr
	}
	return connect.NewResponse(&tenancyv1.RemoveAccessRoleResponse{}), nil
}

// newStubTenancyAdapter serves stub over an httptest server and returns the
// production adapter wired to it.
func newStubTenancyAdapter(t *testing.T, stub *stubTenancyServer) platformAccessClient {
	t.Helper()

	mux := http.NewServeMux()
	mux.Handle(tenancyv1connect.NewTenancyServiceHandler(stub))
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)

	return newTenancyPlatformAccessClient(
		tenancyv1connect.NewTenancyServiceClient(srv.Client(), srv.URL),
	)
}

func TestNewTenancyPlatformAccessClientNilStaysNil(t *testing.T) {
	t.Parallel()
	require.Nil(t, newTenancyPlatformAccessClient(nil))
}

func TestTenancyPlatformAccessClientGetAccess(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name         string
		stub         *stubTenancyServer
		profileID    string
		wantAccessID string
		wantErr      error
	}{
		{
			name:         "existing access is returned",
			stub:         &stubTenancyServer{knownProfileID: "profile-1", accessForProfile: "access-1"},
			profileID:    "profile-1",
			wantAccessID: "access-1",
		},
		{
			name:      "not found is mapped to the sentinel",
			stub:      &stubTenancyServer{knownProfileID: "profile-1", accessForProfile: "access-1"},
			profileID: "profile-unknown",
			wantErr:   ErrPlatformAccessNotFound,
		},
		{
			name:      "an empty access id is treated as not found",
			stub:      &stubTenancyServer{knownProfileID: "profile-1", accessForProfile: ""},
			profileID: "profile-1",
			wantErr:   ErrPlatformAccessNotFound,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			adapter := newStubTenancyAdapter(t, tt.stub)
			accessID, err := adapter.GetAccess(t.Context(), "partition-1", tt.profileID)
			if tt.wantErr != nil {
				require.ErrorIs(t, err, tt.wantErr)
				return
			}
			require.NoError(t, err)
			require.Equal(t, tt.wantAccessID, accessID)
		})
	}
}

func TestTenancyPlatformAccessClientCreateAccess(t *testing.T) {
	t.Parallel()

	adapter := newStubTenancyAdapter(t, &stubTenancyServer{})
	accessID, err := adapter.CreateAccess(t.Context(), "partition-1", "profile-9")
	require.NoError(t, err)
	require.Equal(t, "access-for-profile-9", accessID)
}

func TestTenancyPlatformAccessClientListPartitionRoles(t *testing.T) {
	t.Parallel()

	t.Run("drains a multi message stream", func(t *testing.T) {
		t.Parallel()

		adapter := newStubTenancyAdapter(t, &stubTenancyServer{
			partitionRoles: []*tenancyv1.PartitionRoleObject{
				{Id: "role-admin", Name: "admin"},
				{Id: "role-operator", Name: "operator"},
				{Id: "role-viewer", Name: "viewer"},
			},
		})

		roles, err := adapter.ListPartitionRoles(t.Context(), "partition-1")
		require.NoError(t, err)
		require.Equal(t, map[string]string{
			"admin":    "role-admin",
			"operator": "role-operator",
			"viewer":   "role-viewer",
		}, roles)
	})

	t.Run("empty stream yields an empty map", func(t *testing.T) {
		t.Parallel()

		adapter := newStubTenancyAdapter(t, &stubTenancyServer{})
		roles, err := adapter.ListPartitionRoles(t.Context(), "partition-1")
		require.NoError(t, err)
		require.Empty(t, roles)
	})

	t.Run("a stream error after Receive returns false is surfaced", func(t *testing.T) {
		t.Parallel()

		adapter := newStubTenancyAdapter(t, &stubTenancyServer{
			partitionRoles: []*tenancyv1.PartitionRoleObject{{Id: "role-admin", Name: "admin"}},
			listPartitionRoleErr: connect.NewError(
				connect.CodeUnavailable,
				errors.New("tenancy went away mid stream"),
			),
		})

		roles, err := adapter.ListPartitionRoles(t.Context(), "partition-1")
		require.Error(t, err)
		require.Nil(t, roles)
		require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
	})
}

func TestTenancyPlatformAccessClientCreatePartitionRole(t *testing.T) {
	t.Parallel()

	stub := &stubTenancyServer{}
	adapter := newStubTenancyAdapter(t, stub)

	roleID, err := adapter.CreatePartitionRole(t.Context(), "partition-1", "operator", "Platform role operator")
	require.NoError(t, err)
	require.Equal(t, "role-created", roleID)

	require.NotNil(t, stub.createdRole)
	require.Equal(t, "partition-1", stub.createdRole.GetPartitionId())
	require.Equal(t, "operator", stub.createdRole.GetName())
	// The tenancy API has no description field; the adapter carries it in
	// properties.description instead.
	require.Equal(
		t,
		"Platform role operator",
		stub.createdRole.GetProperties().GetFields()["description"].GetStringValue(),
	)
}

func TestTenancyPlatformAccessClientListAccessRoles(t *testing.T) {
	t.Parallel()

	adapter := newStubTenancyAdapter(t, &stubTenancyServer{
		accessRoles: []*tenancyv1.AccessRoleObject{
			{
				Id:       "access-role-1",
				AccessId: "access-1",
				Role:     &tenancyv1.PartitionRoleObject{Id: "role-admin", Name: "admin"},
			},
			{
				Id:       "access-role-2",
				AccessId: "access-1",
				Role:     &tenancyv1.PartitionRoleObject{Id: "role-viewer", Name: "viewer"},
			},
		},
	})

	assigned, err := adapter.ListAccessRoles(t.Context(), "access-1")
	require.NoError(t, err)
	// The role name travels with the assignment so reconciliation can tell a
	// platform role apart from a business role.
	require.Equal(t, []platformAccessRole{
		{AccessRoleID: "access-role-1", PartitionRoleID: "role-admin", Name: "admin"},
		{AccessRoleID: "access-role-2", PartitionRoleID: "role-viewer", Name: "viewer"},
	}, assigned)
}

func TestTenancyPlatformAccessClientCreateAccessRole(t *testing.T) {
	t.Parallel()

	adapter := newStubTenancyAdapter(t, &stubTenancyServer{})
	require.NoError(t, adapter.CreateAccessRole(t.Context(), "access-1", "role-admin"))
}

func TestTenancyPlatformAccessClientRemoveAccessRole(t *testing.T) {
	t.Parallel()

	t.Run("the access role id is sent as the request id", func(t *testing.T) {
		t.Parallel()

		stub := &stubTenancyServer{}
		adapter := newStubTenancyAdapter(t, stub)
		require.NoError(t, adapter.RemoveAccessRole(t.Context(), "access-role-1"))
		require.Equal(t, []string{"access-role-1"}, stub.removedAccessRoleIDs)
	})

	t.Run("a tenancy error is surfaced", func(t *testing.T) {
		t.Parallel()

		adapter := newStubTenancyAdapter(t, &stubTenancyServer{
			removeAccessRoleErr: connect.NewError(connect.CodeUnavailable, errors.New("down")),
		})
		err := adapter.RemoveAccessRole(t.Context(), "access-role-1")
		require.Error(t, err)
		require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
	})
}
