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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/frame/v2/queue"
	"github.com/pitabwire/frame/v2/security"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/structpb"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

// ---------------------------------------------------------------------------
// fakes
// ---------------------------------------------------------------------------

var errTenancyBoom = errors.New("tenancy unavailable")

// fakePlatformAccessClient records every call made against the narrow
// platform access port and replays canned tenancy state.
type fakePlatformAccessClient struct {
	// existingAccessID is returned by GetAccess; empty means "not found".
	existingAccessID string
	// newAccessID is returned by CreateAccess.
	newAccessID string
	// partitionRoles is the name -> id map returned by ListPartitionRoles.
	partitionRoles map[string]string
	// accessRoles is the list returned by ListAccessRoles.
	accessRoles []platformAccessRole
	// newRoleID is returned by CreatePartitionRole.
	newRoleID string
	// failOn names the method that should return errTenancyBoom.
	failOn string

	calls []string
	// createPartitionRoleArgs captures (name, description) of the last call.
	createPartitionRoleArgs []string
	createAccessRoleArgs    []string
	// removedAccessRoles captures every access role id passed to RemoveAccessRole.
	removedAccessRoles []string
}

func (f *fakePlatformAccessClient) record(name string) error {
	f.calls = append(f.calls, name)
	if f.failOn == name {
		return errTenancyBoom
	}
	return nil
}

func (f *fakePlatformAccessClient) called(name string) bool {
	for _, c := range f.calls {
		if c == name {
			return true
		}
	}
	return false
}

func (f *fakePlatformAccessClient) GetAccess(_ context.Context, _, _ string) (string, error) {
	if err := f.record("GetAccess"); err != nil {
		return "", err
	}
	if f.existingAccessID == "" {
		return "", ErrPlatformAccessNotFound
	}
	return f.existingAccessID, nil
}

func (f *fakePlatformAccessClient) CreateAccess(_ context.Context, _, _ string) (string, error) {
	if err := f.record("CreateAccess"); err != nil {
		return "", err
	}
	return f.newAccessID, nil
}

func (f *fakePlatformAccessClient) ListPartitionRoles(_ context.Context, _ string) (map[string]string, error) {
	if err := f.record("ListPartitionRoles"); err != nil {
		return nil, err
	}
	return f.partitionRoles, nil
}

func (f *fakePlatformAccessClient) CreatePartitionRole(
	_ context.Context,
	_, name, description string,
) (string, error) {
	f.createPartitionRoleArgs = []string{name, description}
	if err := f.record("CreatePartitionRole"); err != nil {
		return "", err
	}
	return f.newRoleID, nil
}

func (f *fakePlatformAccessClient) ListAccessRoles(_ context.Context, _ string) ([]platformAccessRole, error) {
	if err := f.record("ListAccessRoles"); err != nil {
		return nil, err
	}
	return f.accessRoles, nil
}

func (f *fakePlatformAccessClient) RemoveAccessRole(_ context.Context, accessRoleID string) error {
	f.removedAccessRoles = append(f.removedAccessRoles, accessRoleID)
	return f.record("RemoveAccessRole")
}

func (f *fakePlatformAccessClient) CreateAccessRole(_ context.Context, accessID, partitionRoleID string) error {
	f.createAccessRoleArgs = []string{accessID, partitionRoleID}
	return f.record("CreateAccessRole")
}

// fakeOrganizationRepo embeds the repository interface so only the single
// method exercised here needs an implementation.
type fakeOrganizationRepo struct {
	repository.OrganizationRepository
	org *models.Organization
	err error
}

func (f *fakeOrganizationRepo) GetByID(_ context.Context, _ string) (*models.Organization, error) {
	return f.org, f.err
}

// recordingEventsManager stands in for the frame events manager: it accepts
// every emission and keeps the payloads so tests can assert persistence.
type recordingEventsManager struct {
	emitted []any
}

func (m *recordingEventsManager) Add(fevents.EventI) {}
func (m *recordingEventsManager) Get(string) (fevents.EventI, error) {
	return nil, errors.New("no event")
}
func (m *recordingEventsManager) Handler() queue.SubscribeWorker { return nil }
func (m *recordingEventsManager) Strict() bool                   { return false }
func (m *recordingEventsManager) SetStrict(bool)                 {}
func (m *recordingEventsManager) Emit(_ context.Context, _ string, payload any) error {
	m.emitted = append(m.emitted, payload)
	return nil
}

func platformAccessTestContext(t *testing.T) context.Context {
	t.Helper()
	return (&security.AuthenticationClaims{
		TenantID:         "tenant-test",
		PartitionID:      "partition-claims",
		RegisteredClaims: jwt.RegisteredClaims{Subject: "profile-requestor"},
	}).ClaimsToContext(t.Context())
}

// adminAccessRole is the assigned "admin" platform role fixture.
func adminAccessRole() platformAccessRole {
	return platformAccessRole{AccessRoleID: "ar-admin", PartitionRoleID: "role-admin", Name: "admin"}
}

// allPlatformAccessRoles lists one assignment per platform role plus a
// business role that reconciliation must never touch.
func allPlatformAccessRoles() []platformAccessRole {
	return []platformAccessRole{
		adminAccessRole(),
		{AccessRoleID: "ar-operator", PartitionRoleID: "role-operator", Name: "operator"},
		{AccessRoleID: "ar-viewer", PartitionRoleID: "role-viewer", Name: "viewer"},
		{AccessRoleID: "ar-member", PartitionRoleID: "role-member", Name: "member"},
		{AccessRoleID: "ar-finance", PartitionRoleID: "role-finance", Name: "finance_approver"},
	}
}

func activeOrganization() *models.Organization {
	org := &models.Organization{Name: "Acme"}
	org.ID = "org-1"
	org.PartitionID = "partition-org"
	return org
}

// ---------------------------------------------------------------------------
// ensurePlatformAccess
// ---------------------------------------------------------------------------

func TestEnsurePlatformAccess(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name           string
		nilClient      bool
		client         *fakePlatformAccessClient
		org            *models.Organization
		properties     data.JSONMap
		profileID      string
		wantErr        error
		wantGranted    bool
		wantCalls      []string
		wantRoleName   string
		wantAccessRole []string
		wantRemoved    []string
	}{
		{
			name:      "nil client is a no-op",
			nilClient: true,
			org:       activeOrganization(),
			profileID: "profile-1",
			properties: data.JSONMap{
				PropertyPlatformRole: "operator",
			},
		},
		{
			name: "new member creates access, role and assignment",
			client: &fakePlatformAccessClient{
				newAccessID:    "access-new",
				partitionRoles: map[string]string{},
				newRoleID:      "role-new",
				accessRoles:    nil,
			},
			org:        activeOrganization(),
			profileID:  "profile-1",
			properties: data.JSONMap{PropertyPlatformRole: "operator"},
			wantCalls: []string{
				"GetAccess",
				"CreateAccess",
				"ListPartitionRoles",
				"CreatePartitionRole",
				"ListAccessRoles",
				"CreateAccessRole",
			},
			wantGranted:    true,
			wantRoleName:   "operator",
			wantAccessRole: []string{"access-new", "role-new"},
		},
		{
			name: "existing access and assigned role creates nothing",
			client: &fakePlatformAccessClient{
				existingAccessID: "access-1",
				partitionRoles:   map[string]string{"admin": "role-admin"},
				accessRoles:      []platformAccessRole{adminAccessRole()},
			},
			org:        activeOrganization(),
			profileID:  "profile-1",
			properties: data.JSONMap{PropertyPlatformRole: "admin"},
			wantCalls:  []string{"GetAccess", "ListPartitionRoles", "ListAccessRoles"},
		},
		{
			name: "existing partition role is reused for a new assignment",
			client: &fakePlatformAccessClient{
				existingAccessID: "access-1",
				partitionRoles:   map[string]string{"viewer": "role-viewer"},
				accessRoles:      nil,
			},
			org:            activeOrganization(),
			profileID:      "profile-1",
			properties:     data.JSONMap{PropertyPlatformRole: "viewer"},
			wantGranted:    true,
			wantCalls:      []string{"GetAccess", "ListPartitionRoles", "ListAccessRoles", "CreateAccessRole"},
			wantAccessRole: []string{"access-1", "role-viewer"},
		},
		{
			name: "member without a platform role only gets access",
			client: &fakePlatformAccessClient{
				newAccessID: "access-new",
			},
			org:         activeOrganization(),
			profileID:   "profile-1",
			properties:  data.JSONMap{},
			wantGranted: true,
			wantCalls:   []string{"GetAccess", "CreateAccess", "ListAccessRoles"},
		},
		{
			name: "member without a profile is skipped",
			client: &fakePlatformAccessClient{
				newAccessID: "access-new",
			},
			org:        activeOrganization(),
			profileID:  "",
			properties: data.JSONMap{PropertyPlatformRole: "operator"},
			wantCalls:  nil,
		},
		{
			name: "platform role is normalised before matching",
			client: &fakePlatformAccessClient{
				existingAccessID: "access-1",
				partitionRoles:   map[string]string{"admin": "role-admin"},
				accessRoles:      []platformAccessRole{adminAccessRole()},
			},
			org:        activeOrganization(),
			profileID:  "profile-1",
			properties: data.JSONMap{PropertyPlatformRole: "  Admin "},
			wantCalls:  []string{"GetAccess", "ListPartitionRoles", "ListAccessRoles"},
		},
		{
			name: "demotion removes the superseded platform role",
			client: &fakePlatformAccessClient{
				existingAccessID: "access-1",
				partitionRoles:   map[string]string{"admin": "role-admin", "viewer": "role-viewer"},
				accessRoles:      []platformAccessRole{adminAccessRole()},
			},
			org:        activeOrganization(),
			profileID:  "profile-1",
			properties: data.JSONMap{PropertyPlatformRole: "viewer"},
			wantCalls: []string{
				"GetAccess", "ListPartitionRoles", "ListAccessRoles",
				"CreateAccessRole", "RemoveAccessRole",
			},
			wantGranted:    true,
			wantAccessRole: []string{"access-1", "role-viewer"},
			wantRemoved:    []string{"ar-admin"},
		},
		{
			name: "promotion removes the superseded member role",
			client: &fakePlatformAccessClient{
				existingAccessID: "access-1",
				partitionRoles:   map[string]string{"member": "role-member", "operator": "role-operator"},
				accessRoles: []platformAccessRole{
					{AccessRoleID: "ar-member", PartitionRoleID: "role-member", Name: "member"},
				},
			},
			org:        activeOrganization(),
			profileID:  "profile-1",
			properties: data.JSONMap{PropertyPlatformRole: "operator"},
			wantCalls: []string{
				"GetAccess", "ListPartitionRoles", "ListAccessRoles",
				"CreateAccessRole", "RemoveAccessRole",
			},
			wantGranted:    true,
			wantAccessRole: []string{"access-1", "role-operator"},
			wantRemoved:    []string{"ar-member"},
		},
		{
			name: "clearing the platform role keeps member and business roles",
			client: &fakePlatformAccessClient{
				existingAccessID: "access-1",
				accessRoles:      allPlatformAccessRoles(),
			},
			org:        activeOrganization(),
			profileID:  "profile-1",
			properties: data.JSONMap{},
			wantCalls: []string{
				"GetAccess", "ListAccessRoles",
				"RemoveAccessRole", "RemoveAccessRole", "RemoveAccessRole",
			},
			wantGranted: true,
			wantRemoved: []string{"ar-admin", "ar-operator", "ar-viewer"},
		},
		{
			name: "reconciliation never touches non platform roles",
			client: &fakePlatformAccessClient{
				existingAccessID: "access-1",
				partitionRoles:   map[string]string{"viewer": "role-viewer"},
				accessRoles: []platformAccessRole{
					{AccessRoleID: "ar-finance", PartitionRoleID: "role-finance", Name: "finance_approver"},
					{AccessRoleID: "ar-viewer", PartitionRoleID: "role-viewer", Name: "viewer"},
				},
			},
			org:        activeOrganization(),
			profileID:  "profile-1",
			properties: data.JSONMap{PropertyPlatformRole: "viewer"},
			wantCalls:  []string{"GetAccess", "ListPartitionRoles", "ListAccessRoles"},
		},
		{
			name: "removal failure is wrapped in ErrPlatformAccessFailed",
			client: &fakePlatformAccessClient{
				existingAccessID: "access-1",
				partitionRoles:   map[string]string{"admin": "role-admin", "viewer": "role-viewer"},
				accessRoles:      []platformAccessRole{adminAccessRole()},
				failOn:           "RemoveAccessRole",
			},
			org:        activeOrganization(),
			profileID:  "profile-1",
			properties: data.JSONMap{PropertyPlatformRole: "viewer"},
			wantErr:    errTenancyBoom,
			wantCalls: []string{
				"GetAccess", "ListPartitionRoles", "ListAccessRoles",
				"CreateAccessRole", "RemoveAccessRole",
			},
			// The new assignment landed before the removal failed, so the
			// partial change is still reported to the caller.
			wantGranted: true,
			wantRemoved: []string{"ar-admin"},
		},
		{
			name: "tenancy failure is wrapped in ErrPlatformAccessFailed",
			client: &fakePlatformAccessClient{
				failOn: "GetAccess",
			},
			org:        activeOrganization(),
			profileID:  "profile-1",
			properties: data.JSONMap{PropertyPlatformRole: "operator"},
			wantErr:    errTenancyBoom,
			wantCalls:  []string{"GetAccess"},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			ctx := platformAccessTestContext(t)
			biz := &workforceBusiness{
				organizationRepo: &fakeOrganizationRepo{org: tt.org},
			}
			if !tt.nilClient {
				biz.platformAccessCli = tt.client
			}

			member := &models.WorkforceMember{
				OrganizationID: "org-1",
				ProfileID:      tt.profileID,
				State:          int32(commonv1.STATE_ACTIVE),
				Properties:     tt.properties,
			}

			granted, err := biz.ensurePlatformAccess(ctx, member)
			if tt.wantErr != nil {
				require.ErrorIs(t, err, ErrPlatformAccessFailed)
				require.ErrorIs(t, err, tt.wantErr)
			} else {
				require.NoError(t, err)
			}
			require.Equal(t, tt.wantGranted, granted)

			if tt.nilClient {
				return
			}
			require.Equal(t, tt.wantCalls, tt.client.calls)
			if tt.wantRoleName != "" {
				require.Equal(
					t,
					[]string{tt.wantRoleName, "Platform role " + tt.wantRoleName},
					tt.client.createPartitionRoleArgs,
				)
			}
			if tt.wantAccessRole != nil {
				require.Equal(t, tt.wantAccessRole, tt.client.createAccessRoleArgs)
			}
			require.Equal(t, tt.wantRemoved, tt.client.removedAccessRoles)
		})
	}
}

func TestEnsurePlatformAccessFallsBackToClaimsPartition(t *testing.T) {
	t.Parallel()

	ctx := platformAccessTestContext(t)
	cli := &fakePlatformAccessClient{newAccessID: "access-new"}
	org := activeOrganization()
	org.PartitionID = ""
	biz := &workforceBusiness{
		organizationRepo:  &fakeOrganizationRepo{org: org},
		platformAccessCli: cli,
	}

	member := &models.WorkforceMember{
		OrganizationID: "org-1",
		ProfileID:      "profile-1",
		State:          int32(commonv1.STATE_ACTIVE),
	}
	granted, err := biz.ensurePlatformAccess(ctx, member)
	require.NoError(t, err)
	require.True(t, granted)
	require.True(t, cli.called("CreateAccess"))
}

// ---------------------------------------------------------------------------
// WorkforceMemberSave trigger
// ---------------------------------------------------------------------------

func TestWorkforceMemberSavePlatformAccessTrigger(t *testing.T) {
	t.Parallel()

	newProperties := func(role string) *structpb.Struct {
		s, err := structpb.NewStruct(map[string]any{PropertyPlatformRole: role})
		require.NoError(t, err)
		return s
	}

	tests := []struct {
		name   string
		id     string
		state  commonv1.STATE
		client *fakePlatformAccessClient
		// wantCalls is the exact call sequence expected on the tenancy port.
		wantCalls   []string
		wantRemoved []string
	}{
		{
			name:  "new active member grants platform access",
			state: commonv1.STATE_ACTIVE,
			client: &fakePlatformAccessClient{
				newAccessID:    "access-new",
				partitionRoles: map[string]string{},
				newRoleID:      "role-new",
				accessRoles:    nil,
			},
			wantCalls: []string{
				"GetAccess", "CreateAccess", "ListPartitionRoles",
				"CreatePartitionRole", "ListAccessRoles", "CreateAccessRole",
			},
		},
		{
			name:      "new created member grants nothing",
			state:     commonv1.STATE_CREATED,
			client:    &fakePlatformAccessClient{newAccessID: "access-new"},
			wantCalls: nil,
		},
		{
			name:  "re-saving an already provisioned active member is a no-op",
			id:    "member-1",
			state: commonv1.STATE_ACTIVE,
			client: &fakePlatformAccessClient{
				existingAccessID: "access-1",
				partitionRoles:   map[string]string{"operator": "role-operator"},
				accessRoles: []platformAccessRole{
					{AccessRoleID: "ar-operator", PartitionRoleID: "role-operator", Name: "operator"},
				},
			},
			wantCalls: []string{"GetAccess", "ListPartitionRoles", "ListAccessRoles"},
		},
		{
			name:  "re-saving an active member retries a missing grant",
			id:    "member-1",
			state: commonv1.STATE_ACTIVE,
			client: &fakePlatformAccessClient{
				existingAccessID: "access-1",
				partitionRoles:   map[string]string{"operator": "role-operator"},
				accessRoles:      nil,
			},
			wantCalls: []string{"GetAccess", "ListPartitionRoles", "ListAccessRoles", "CreateAccessRole"},
		},
		{
			name:  "demotion removes the superseded role on re-save",
			id:    "member-1",
			state: commonv1.STATE_ACTIVE,
			client: &fakePlatformAccessClient{
				existingAccessID: "access-1",
				partitionRoles:   map[string]string{"admin": "role-admin", "operator": "role-operator"},
				accessRoles:      []platformAccessRole{adminAccessRole()},
			},
			wantCalls: []string{
				"GetAccess", "ListPartitionRoles", "ListAccessRoles",
				"CreateAccessRole", "RemoveAccessRole",
			},
			wantRemoved: []string{"ar-admin"},
		},
		{
			name:      "tenancy failure never fails the save",
			state:     commonv1.STATE_ACTIVE,
			client:    &fakePlatformAccessClient{failOn: "GetAccess"},
			wantCalls: []string{"GetAccess"},
		},
		{
			name:  "a removal failure never fails the save",
			id:    "member-1",
			state: commonv1.STATE_ACTIVE,
			client: &fakePlatformAccessClient{
				existingAccessID: "access-1",
				partitionRoles:   map[string]string{"admin": "role-admin", "operator": "role-operator"},
				accessRoles:      []platformAccessRole{adminAccessRole()},
				failOn:           "RemoveAccessRole",
			},
			wantCalls: []string{
				"GetAccess", "ListPartitionRoles", "ListAccessRoles",
				"CreateAccessRole", "RemoveAccessRole",
			},
			wantRemoved: []string{"ar-admin"},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			ctx := platformAccessTestContext(t)
			evts := &recordingEventsManager{}
			biz := &workforceBusiness{
				eventsMan:         evts,
				organizationRepo:  &fakeOrganizationRepo{org: activeOrganization()},
				platformAccessCli: tt.client,
			}

			saved, err := biz.WorkforceMemberSave(ctx, &identityv1.WorkforceMemberObject{
				Id:             tt.id,
				OrganizationId: "org-1",
				ProfileId:      "profile-1",
				State:          tt.state,
				Properties:     newProperties("operator"),
			})

			// A platform access failure must never fail the RPC: the save event
			// has already been enqueued, so an error would make a client retry
			// of a create produce a duplicate member.
			require.NoError(t, err)
			require.NotNil(t, saved)
			require.Len(t, evts.emitted, 1, "member must be enqueued for persistence exactly once")
			require.Equal(t, tt.wantCalls, tt.client.calls)
			require.Equal(t, tt.wantRemoved, tt.client.removedAccessRoles)
		})
	}
}
