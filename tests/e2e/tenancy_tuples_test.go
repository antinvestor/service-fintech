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

package e2e_test

import (
	"context"
	"fmt"

	loanspb "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	operationspb "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"github.com/antinvestor/common/v3/permissions"
	"github.com/pitabwire/frame/v3/security"
)

// This file writes into the suite's throwaway Keto the tuples the tenancy
// service (github.com/antinvestor/service-authentication, apps/tenancy)
// writes for the same people, partitions and service accounts. Each builder
// mirrors the tenancy function named in its comment; the relation names,
// subject namespaces and subject sets must stay identical to it, or the
// suite stops proving what production enforces.

const (
	roleOwner   = "owner"
	roleAdmin   = "admin"
	roleMember  = "member"
	roleService = "service"

	nsTenancyAccess = "tenancy_access"
)

// standardRoles mirrors authz.StandardRoles (service/authz/role_mapping.go).
var standardRoles = []string{roleOwner, roleAdmin, roleMember} //nolint:gochecknoglobals // mirrored registry

// registeredNamespaces are the permission manifests the loans and
// operations setup jobs register with tenancy (common/v3/permissions
// BuildManifest from proto service_permissions): tenancy's
// service_namespaces rows, whose role_bindings decide which namespaces a
// role reaches.
func registeredNamespaces() []permissions.PermissionManifest {
	return []permissions.PermissionManifest{
		permissions.BuildManifest(loanspb.File_loans_v1_loans_proto.Services().ByName("LoanManagementService")),
		permissions.BuildManifest(
			operationspb.File_operations_v1_operations_proto.Services().ByName("OperationsService")),
	}
}

func tenancyPath(tenantID, partitionID string) string {
	return fmt.Sprintf("%s/%s", tenantID, partitionID)
}

// accessTuple mirrors authz.BuildAccessTuple: every access record makes its
// profile a member of the partition.
func accessTuple(path, profileID string) security.RelationTuple {
	return security.RelationTuple{
		Object:   security.ObjectRef{Namespace: nsTenancyAccess, ID: path},
		Relation: roleMember,
		Subject:  security.SubjectRef{Namespace: security.NamespaceProfile, ID: profileID},
	}
}

// roleTuples mirrors authz.BuildRoleTuples: the role on every registered
// namespace that binds it, and on tenancy_access.
func roleTuples(path, profileID, role string, namespaces []permissions.PermissionManifest) []security.RelationTuple {
	var tuples []security.RelationTuple
	for _, ns := range namespaces {
		if _, ok := ns.RoleBindings[role]; !ok {
			continue
		}
		tuples = append(tuples, security.RelationTuple{
			Object:   security.ObjectRef{Namespace: ns.Namespace, ID: path},
			Relation: role,
			Subject:  security.SubjectRef{Namespace: security.NamespaceProfile, ID: profileID},
		})
	}
	return append(tuples, security.RelationTuple{
		Object:   security.ObjectRef{Namespace: nsTenancyAccess, ID: path},
		Relation: role,
		Subject:  security.SubjectRef{Namespace: security.NamespaceProfile, ID: profileID},
	})
}

// partitionInheritanceTuple mirrors authz.BuildPartitionInheritanceTuple:
// the parent partition's members are members of the child.
func partitionInheritanceTuple(parentPath, childPath string) security.RelationTuple {
	return security.RelationTuple{
		Object:   security.ObjectRef{Namespace: nsTenancyAccess, ID: childPath},
		Relation: roleMember,
		Subject:  security.SubjectRef{Namespace: nsTenancyAccess, ID: parentPath, Relation: roleMember},
	}
}

// roleInheritanceTuples mirrors authz.BuildRoleInheritanceTuples: each
// namespace's role in a partition takes in tenancy_access's same role there.
func roleInheritanceTuples(path string, namespaces []string, roles []string) []security.RelationTuple {
	var tuples []security.RelationTuple
	for _, ns := range namespaces {
		for _, role := range roles {
			tuples = append(tuples, security.RelationTuple{
				Object:   security.ObjectRef{Namespace: ns, ID: path},
				Relation: role,
				Subject:  security.SubjectRef{Namespace: nsTenancyAccess, ID: path, Relation: role},
			})
		}
	}
	return tuples
}

// serviceAccessTuple mirrors authz.BuildServiceAccessTuple.
func serviceAccessTuple(path, profileID string) security.RelationTuple {
	return security.RelationTuple{
		Object:   security.ObjectRef{Namespace: nsTenancyAccess, ID: path},
		Relation: roleService,
		Subject:  security.SubjectRef{Namespace: security.NamespaceProfile, ID: profileID},
	}
}

// servicePermissionTuples mirrors authz.BuildServicePermissionTuples
// (granted_<permission> per permission, authz.BuildPermissionTuple).
func servicePermissionTuples(path, profileID, namespace string, perms []string) []security.RelationTuple {
	tuples := make([]security.RelationTuple, 0, len(perms))
	for _, perm := range perms {
		tuples = append(tuples, security.RelationTuple{
			Object:   security.ObjectRef{Namespace: namespace, ID: path},
			Relation: "granted_" + perm,
			Subject:  security.SubjectRef{Namespace: security.NamespaceProfile, ID: profileID},
		})
	}
	return tuples
}

// tenancyKeto writes tuples the way tenancy's sync handlers do.
type tenancyKeto struct {
	authz      security.Authorizer
	namespaces []permissions.PermissionManifest
}

func newTenancyKeto(authz security.Authorizer) *tenancyKeto {
	return &tenancyKeto{authz: authz, namespaces: registeredNamespaces()}
}

// partitionSynced mirrors events.AuthzPartitionSyncEvent.Execute
// (service/events/authz_partition_sync.go) for a partition with a parent:
// the member inheritance tuple first, then each standard role's bridge on
// every namespace that binds it. A partition without a parent writes
// nothing.
func (k *tenancyKeto) partitionSynced(ctx context.Context, parentPath, path string) error {
	if err := k.authz.WriteTuple(ctx, partitionInheritanceTuple(parentPath, path)); err != nil {
		return fmt.Errorf("partition inheritance %s -> %s: %w", parentPath, path, err)
	}
	var bridges []security.RelationTuple
	for _, role := range standardRoles {
		var supported []string
		for _, ns := range k.namespaces {
			if _, ok := ns.RoleBindings[role]; ok {
				supported = append(supported, ns.Namespace)
			}
		}
		bridges = append(bridges, roleInheritanceTuples(path, supported, []string{role})...)
	}
	if err := k.authz.WriteTuples(ctx, bridges); err != nil {
		return fmt.Errorf("partition role bridges %s: %w", path, err)
	}
	return nil
}

// accessSynced mirrors events.AuthzAccessSyncEvent.Execute
// (service/events/authz_access_sync.go): the member tuple, then each of the
// access record's partition roles. (The root-partition service tuple for
// owners and admins does not apply: no person here is in the root
// partition.)
func (k *tenancyKeto) accessSynced(ctx context.Context, path, profileID string, roles ...string) error {
	tuples := []security.RelationTuple{accessTuple(path, profileID)}
	for _, role := range roles {
		tuples = append(tuples, roleTuples(path, profileID, role, k.namespaces)...)
	}
	if err := k.authz.WriteTuples(ctx, tuples); err != nil {
		return fmt.Errorf("access %s in %s: %w", profileID, path, err)
	}
	return nil
}

// serviceAccountSynced mirrors events.AuthzServiceAccountSyncEvent
// desiredTuples (service/events/authz_service_account_sync.go) for a policy
// whose grants are all scope partition_tree: the granted permissions on
// every partition of the tree, and the service relation on tenancy_access
// for each of them. grants maps namespace to permissions, as the
// service_account_authorization_grants / _permissions rows do.
func (k *tenancyKeto) serviceAccountSynced(
	ctx context.Context, profileID string, tree []string, grants map[string][]string,
) error {
	var tuples []security.RelationTuple
	for namespace, perms := range grants {
		for _, path := range tree {
			tuples = append(tuples, servicePermissionTuples(path, profileID, namespace, perms)...)
		}
	}
	for _, path := range tree {
		tuples = append(tuples, serviceAccessTuple(path, profileID))
	}
	if err := k.authz.WriteTuples(ctx, tuples); err != nil {
		return fmt.Errorf("service account %s: %w", profileID, err)
	}
	return nil
}

// Service accounts' grants on the namespaces the real servers here check
// (service_loans, service_operations), as tenancy's migrations hold them
// (service-authentication apps/tenancy/migrations/0001). Grants on the
// faked peers' namespaces are not checked by anything in this suite.
//
//   - service_loans (policy d94lkmcpf2t39vdkp420) on service_operations,
//     grant d94lkmcpf2t39vdkp4vg: 20260704_02_auth_contract_seed.sql.
//   - service_operations (policy d94lkmcpf2t39vdkp8i0) on service_loans,
//     grant dbe6k5g1j4o4jru4etf0: repayment_manage
//     (20261024_01_fintech_peer_audiences_grants.sql), loan_view
//     (20261024_02_fintech_operations_loan_view.sql), payout_outcome_apply
//     (20261026_08_fintech_payout_outcomes_savings_jobs.sql).
//   - trustage (policy d94lkmcpf2t39vdkp1f0): loan_job_run on service_loans
//     (20261025_01_fintech_loans_trustage_jobs.sql), operations_job_run on
//     service_operations (20261026_03_fintech_operations_trustage_jobs.sql).
func serviceAccountGrants() map[string]map[string][]string {
	return map[string]map[string][]string{
		loansServiceProfile: {
			"service_operations": {"payment_allocate", "payment_notify", "transfer_execute", "transfer_view"},
		},
		operationsServiceProfile: {
			"service_loans": {"loan_view", "payout_outcome_apply", "repayment_manage"},
		},
		trustageServiceProfile: {
			"service_loans":      {"loan_job_run"},
			"service_operations": {"operations_job_run"},
		},
	}
}
