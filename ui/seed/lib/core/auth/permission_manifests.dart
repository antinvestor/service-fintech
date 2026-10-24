import 'package:antinvestor_ui_core/permissions/permission_manifest.dart';
import 'package:antinvestor_ui_core/permissions/permission_registry.dart';
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart'
    show LoansRouteModule;

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
      ],
    ),
  );

  // The loans package declares every permit its screens gate on.
  registry.register(LoansRouteModule().permissionManifest);

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
