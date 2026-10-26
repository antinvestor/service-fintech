import 'package:antinvestor_ui_core/permissions/permission_manifest.dart';
import 'package:antinvestor_ui_core/permissions/permission_registry.dart';
import 'package:antinvestor_ui_funding/antinvestor_ui_funding.dart'
    show FundingRouteModule;
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart'
    show LoansRouteModule;
import 'package:antinvestor_ui_operations/antinvestor_ui_operations.dart'
    show OperationsRouteModule;
import 'package:antinvestor_ui_savings/antinvestor_ui_savings.dart'
    show SavingsRouteModule;

void registerPermissionManifests() {
  final registry = PermissionRegistry.instance;

  registry.register(
    const PermissionManifest(
      namespace: 'service_identity',
      permissions: [
        PermissionEntry(
          key: 'organization_view',
          label: 'View Organizations',
          scope: PermissionScope.service,
        ),
        PermissionEntry(
          key: 'organization_manage',
          label: 'Manage Organizations',
          scope: PermissionScope.action,
        ),
        PermissionEntry(
          key: 'workforce_member_view',
          label: 'View Workforce',
          scope: PermissionScope.service,
        ),
        PermissionEntry(
          key: 'workforce_member_manage',
          label: 'Manage Workforce',
          scope: PermissionScope.action,
        ),
        PermissionEntry(
          key: 'access_role_assignment_manage',
          label: 'Manage Access Roles',
          scope: PermissionScope.feature,
        ),
        PermissionEntry(
          key: 'client_data_verify',
          label: 'Verify Client KYC Data',
          scope: PermissionScope.action,
        ),
        PermissionEntry(
          key: 'form_template_view',
          label: 'View Form Templates',
          scope: PermissionScope.feature,
        ),
        PermissionEntry(
          key: 'form_template_manage',
          label: 'Manage Form Templates',
          scope: PermissionScope.feature,
        ),
      ],
    ),
  );

  // Borrowers live in the field service; the identity package only renders
  // them. The permits are checked against that namespace.
  registry.register(
    const PermissionManifest(
      namespace: 'service_field',
      permissions: [
        PermissionEntry(
          key: 'client_view',
          label: 'View Clients',
          scope: PermissionScope.service,
        ),
        PermissionEntry(
          key: 'client_manage',
          label: 'Onboard and Manage Clients',
          scope: PermissionScope.action,
        ),
        PermissionEntry(
          key: 'client_relationship_manage',
          label: 'Assign Staff to Clients',
          scope: PermissionScope.action,
        ),
      ],
    ),
  );

  // The seed service's own permits: the client screen's Lending tab.
  registry.register(
    const PermissionManifest(
      namespace: 'service_seed',
      permissions: [
        PermissionEntry(
          key: 'seed_credit_profile_view',
          label: 'View Credit Profiles',
          scope: PermissionScope.feature,
        ),
        PermissionEntry(
          key: 'seed_credit_profile_admin',
          label: 'Suspend, Block and Reinstate Borrowing',
          scope: PermissionScope.action,
        ),
      ],
    ),
  );

  // The loans package declares every permit its screens gate on.
  registry.register(LoansRouteModule().permissionManifest);
  registry.register(FundingRouteModule().permissionManifest);
  registry.register(OperationsRouteModule().permissionManifest);
  registry.register(SavingsRouteModule().permissionManifest);

  registry.register(
    const PermissionManifest(
      namespace: 'service_limits',
      permissions: [
        PermissionEntry(
          key: 'limits_policy_manage',
          label: 'Manage Limit Policies',
          scope: PermissionScope.action,
        ),
        PermissionEntry(
          key: 'limits_approval_act',
          label: 'Decide Limit Approvals',
          scope: PermissionScope.action,
        ),
      ],
    ),
  );
}
