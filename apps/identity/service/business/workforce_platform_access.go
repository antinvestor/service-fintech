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

	"buf.build/gen/go/antinvestor/tenancy/connectrpc/go/tenancy/v1/tenancyv1connect"
	tenancyv1 "buf.build/gen/go/antinvestor/tenancy/protocolbuffers/go/tenancy/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/types/known/structpb"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

// PropertyPlatformRole is the workforce member property holding the tenancy
// partition role the member should be granted once activated.
const PropertyPlatformRole = "platform_role"

// ErrPlatformAccessNotFound is the sentinel returned by platformAccessClient
// implementations when a profile holds no access on the partition yet.
var ErrPlatformAccessNotFound = errors.New("tenancy access not found")

const (
	platformRoleAdmin    = "admin"
	platformRoleOperator = "operator"
	platformRoleViewer   = "viewer"
	// platformRoleMember is the baseline role that carries plain tenancy
	// access; it is kept when a member holds no platform_role at all.
	platformRoleMember = "member"
)

// isPlatformRole reports whether a partition role name is one this service
// owns. Reconciliation only ever removes assignments naming one of these; every
// other partition role (business roles, for example) is left alone.
func isPlatformRole(name string) bool {
	switch name {
	case platformRoleAdmin, platformRoleOperator, platformRoleViewer, platformRoleMember:
		return true
	default:
		return false
	}
}

// platformAccessRole is one role assignment held by an access grant.
type platformAccessRole struct {
	AccessRoleID    string
	PartitionRoleID string
	Name            string
}

// platformAccessClient is the narrow port onto the tenancy service used when
// granting workforce members access to their organization's partition. It
// hides the server-streaming list RPCs behind plain values so the business
// logic stays testable.
type platformAccessClient interface {
	// GetAccess resolves the access a profile holds on a partition. It returns
	// ErrPlatformAccessNotFound when no access exists yet.
	GetAccess(ctx context.Context, partitionID, profileID string) (accessID string, err error)
	CreateAccess(ctx context.Context, partitionID, profileID string) (accessID string, err error)
	// ListPartitionRoles returns the partition's roles keyed by role name.
	ListPartitionRoles(ctx context.Context, partitionID string) (map[string]string, error)
	CreatePartitionRole(ctx context.Context, partitionID, name, description string) (roleID string, err error)
	// ListAccessRoles returns the role assignments held by an access.
	ListAccessRoles(ctx context.Context, accessID string) ([]platformAccessRole, error)
	CreateAccessRole(ctx context.Context, accessID, partitionRoleID string) error
	// RemoveAccessRole unassigns a role from an access by access role id.
	RemoveAccessRole(ctx context.Context, accessRoleID string) error
}

// tenancyPlatformAccessClient adapts the generated tenancy Connect client to
// the platformAccessClient port.
type tenancyPlatformAccessClient struct {
	cli tenancyv1connect.TenancyServiceClient
}

// newTenancyPlatformAccessClient wraps a tenancy client. A nil client yields a
// nil port, which callers treat as "platform access disabled".
func newTenancyPlatformAccessClient(cli tenancyv1connect.TenancyServiceClient) platformAccessClient {
	if cli == nil {
		return nil
	}
	return &tenancyPlatformAccessClient{cli: cli}
}

func (t *tenancyPlatformAccessClient) GetAccess(
	ctx context.Context,
	partitionID, profileID string,
) (string, error) {
	resp, err := t.cli.GetAccess(ctx, connect.NewRequest(&tenancyv1.GetAccessRequest{
		PartitionId: partitionID,
		ProfileId:   profileID,
	}))
	if err != nil {
		if connect.CodeOf(err) == connect.CodeNotFound {
			return "", ErrPlatformAccessNotFound
		}
		return "", err
	}
	accessID := resp.Msg.GetData().GetId()
	if accessID == "" {
		return "", ErrPlatformAccessNotFound
	}
	return accessID, nil
}

func (t *tenancyPlatformAccessClient) CreateAccess(
	ctx context.Context,
	partitionID, profileID string,
) (string, error) {
	resp, err := t.cli.CreateAccess(ctx, connect.NewRequest(&tenancyv1.CreateAccessRequest{
		PartitionId: partitionID,
		ProfileId:   profileID,
	}))
	if err != nil {
		return "", err
	}
	return resp.Msg.GetData().GetId(), nil
}

func (t *tenancyPlatformAccessClient) ListPartitionRoles(
	ctx context.Context,
	partitionID string,
) (map[string]string, error) {
	stream, err := t.cli.ListPartitionRole(ctx, connect.NewRequest(&tenancyv1.ListPartitionRoleRequest{
		PartitionId: partitionID,
	}))
	if err != nil {
		return nil, err
	}
	defer func() { _ = stream.Close() }()

	roles := make(map[string]string)
	for stream.Receive() {
		for _, role := range stream.Msg().GetData() {
			roles[role.GetName()] = role.GetId()
		}
	}
	if err = stream.Err(); err != nil {
		return nil, err
	}
	return roles, nil
}

func (t *tenancyPlatformAccessClient) CreatePartitionRole(
	ctx context.Context,
	partitionID, name, description string,
) (string, error) {
	// The tenancy API carries free-form role metadata in properties; there is
	// no dedicated description field.
	properties, err := structpb.NewStruct(map[string]any{"description": description})
	if err != nil {
		return "", err
	}
	resp, err := t.cli.CreatePartitionRole(ctx, connect.NewRequest(&tenancyv1.CreatePartitionRoleRequest{
		PartitionId: partitionID,
		Name:        name,
		Properties:  properties,
	}))
	if err != nil {
		return "", err
	}
	return resp.Msg.GetData().GetId(), nil
}

func (t *tenancyPlatformAccessClient) ListAccessRoles(
	ctx context.Context,
	accessID string,
) ([]platformAccessRole, error) {
	stream, err := t.cli.ListAccessRole(ctx, connect.NewRequest(&tenancyv1.ListAccessRoleRequest{
		AccessId: accessID,
	}))
	if err != nil {
		return nil, err
	}
	defer func() { _ = stream.Close() }()

	var assigned []platformAccessRole
	for stream.Receive() {
		for _, accessRole := range stream.Msg().GetData() {
			assigned = append(assigned, platformAccessRole{
				AccessRoleID:    accessRole.GetId(),
				PartitionRoleID: accessRole.GetRole().GetId(),
				Name:            accessRole.GetRole().GetName(),
			})
		}
	}
	if err = stream.Err(); err != nil {
		return nil, err
	}
	return assigned, nil
}

func (t *tenancyPlatformAccessClient) CreateAccessRole(
	ctx context.Context,
	accessID, partitionRoleID string,
) error {
	_, err := t.cli.CreateAccessRole(ctx, connect.NewRequest(&tenancyv1.CreateAccessRoleRequest{
		AccessId:        accessID,
		PartitionRoleId: partitionRoleID,
	}))
	return err
}

func (t *tenancyPlatformAccessClient) RemoveAccessRole(ctx context.Context, accessRoleID string) error {
	_, err := t.cli.RemoveAccessRole(ctx, connect.NewRequest(&tenancyv1.RemoveAccessRoleRequest{
		Id: accessRoleID,
	}))
	return err
}

// ensurePlatformAccess grants tenancy access on the organization's partition,
// assigns the platform role named in member.Properties["platform_role"] and
// removes any platform role the member should no longer hold, so a demotion or
// a cleared role takes effect. It is idempotent and a no-op when the platform
// access client is nil.
//
// It reports whether anything actually changed, so callers can tell a real
// reconciliation apart from a no-op re-save. Failures are logged here and returned
// wrapped in ErrPlatformAccessFailed; callers decide whether to surface them.
func (b *workforceBusiness) ensurePlatformAccess(
	ctx context.Context,
	member *models.WorkforceMember,
) (bool, error) {
	if b.platformAccessCli == nil || member == nil {
		return false, nil
	}

	logger := util.Log(ctx).
		WithField("method", "WorkforceBusiness.ensurePlatformAccess").
		WithField("workforce_member_id", member.GetID()).
		WithField("organization_id", member.OrganizationID).
		WithField("profile_id", member.ProfileID)

	if member.ProfileID == "" {
		logger.Warn("workforce member has no profile, skipping platform access")
		return false, nil
	}

	role := platformRoleOf(member)
	logger = logger.WithField("platform_role", role)

	partitionID, err := b.platformPartitionID(ctx, member)
	if err != nil {
		logger.WithError(err).Error("could not resolve partition for platform access")
		return false, fmt.Errorf("%w: %w", ErrPlatformAccessFailed, err)
	}
	logger = logger.WithField("partition_id", partitionID)

	changed, err := b.reconcilePlatformAccess(ctx, logger, partitionID, member.ProfileID, role)
	if err != nil {
		logger.WithError(err).Error("could not reconcile platform access for workforce member")
		return changed, fmt.Errorf("%w: %w", ErrPlatformAccessFailed, err)
	}

	if changed {
		logger.Info("reconciled platform access for workforce member")
	} else {
		logger.Debug("workforce member platform access already up to date")
	}
	return changed, nil
}

// reconcilePlatformAccess performs the idempotent tenancy calls that bring the
// member's assignments in line with the desired role: it ensures the access
// grant and the desired role assignment exist, then removes every other
// platform role the member still holds. It reports whether anything changed.
func (b *workforceBusiness) reconcilePlatformAccess(
	ctx context.Context,
	logger *util.LogEntry,
	partitionID, profileID, role string,
) (bool, error) {
	changed := false

	accessID, err := b.platformAccessCli.GetAccess(ctx, partitionID, profileID)
	if err != nil {
		if !errors.Is(err, ErrPlatformAccessNotFound) {
			return false, err
		}
		accessID, err = b.platformAccessCli.CreateAccess(ctx, partitionID, profileID)
		if err != nil {
			return false, err
		}
		changed = true
	}

	desiredRoleID := ""
	if role != "" {
		desiredRoleID, err = b.ensurePartitionRole(ctx, partitionID, role)
		if err != nil {
			return changed, err
		}
	}

	assigned, err := b.platformAccessCli.ListAccessRoles(ctx, accessID)
	if err != nil {
		return changed, err
	}

	// The desired assignment is created before the superseded ones are removed
	// so the member never loses access mid-reconciliation.
	if desiredRoleID != "" && !holdsRole(assigned, desiredRoleID) {
		if err = b.platformAccessCli.CreateAccessRole(ctx, accessID, desiredRoleID); err != nil {
			return changed, err
		}
		changed = true
	}

	for _, current := range assigned {
		if !supersededPlatformRole(current, role, desiredRoleID) {
			continue
		}
		if err = b.platformAccessCli.RemoveAccessRole(ctx, current.AccessRoleID); err != nil {
			return changed, err
		}
		IdentityPlatformAccessRevoked.Add(ctx, 1)
		logger.WithField("removed_platform_role", current.Name).
			WithField("access_role_id", current.AccessRoleID).
			Info("removed superseded platform role from workforce member")
		changed = true
	}

	return changed, nil
}

// holdsRole reports whether the partition role is already assigned.
func holdsRole(assigned []platformAccessRole, partitionRoleID string) bool {
	for _, current := range assigned {
		if current.PartitionRoleID == partitionRoleID {
			return true
		}
	}
	return false
}

// supersededPlatformRole reports whether an existing assignment is a platform
// role the member should no longer hold. Roles outside the platform set are
// never touched, and with no desired role the baseline "member" role is kept so
// the member retains plain tenancy access.
func supersededPlatformRole(current platformAccessRole, role, desiredRoleID string) bool {
	if current.AccessRoleID == "" || !isPlatformRole(current.Name) {
		return false
	}
	if current.PartitionRoleID == desiredRoleID || current.Name == role {
		return false
	}
	return role != "" || current.Name != platformRoleMember
}

// platformPartitionID resolves the partition the member should be granted
// access on, falling back to the caller's partition when the organization
// carries none.
func (b *workforceBusiness) platformPartitionID(
	ctx context.Context,
	member *models.WorkforceMember,
) (string, error) {
	organization, err := b.organizationRepo.GetByID(ctx, member.OrganizationID)
	if err != nil {
		return "", err
	}
	partitionID := ""
	if organization != nil {
		partitionID = organization.PartitionID
	}
	if partitionID == "" {
		if claims := security.ClaimsFromContext(ctx); claims != nil {
			partitionID = claims.GetPartitionID()
		}
	}
	if partitionID == "" {
		return "", ErrOrganizationNotFound
	}
	return partitionID, nil
}

// ensurePartitionRole returns the id of the named partition role, creating it
// when the partition does not define it yet.
func (b *workforceBusiness) ensurePartitionRole(
	ctx context.Context,
	partitionID, role string,
) (string, error) {
	roles, err := b.platformAccessCli.ListPartitionRoles(ctx, partitionID)
	if err != nil {
		return "", err
	}
	if roleID, ok := roles[role]; ok {
		return roleID, nil
	}
	return b.platformAccessCli.CreatePartitionRole(ctx, partitionID, role, "Platform role "+role)
}

// platformRoleOf reads the member's platform role, normalised to the lower-case
// form tenancy partition roles are keyed by.
func platformRoleOf(member *models.WorkforceMember) string {
	value, ok := member.Properties[PropertyPlatformRole]
	if !ok {
		return ""
	}
	role, ok := value.(string)
	if !ok {
		return ""
	}
	return strings.ToLower(strings.TrimSpace(role))
}
