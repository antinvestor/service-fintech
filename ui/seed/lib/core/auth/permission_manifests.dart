import 'package:antinvestor_ui_core/permissions/permission_manifest.dart';
import 'package:antinvestor_ui_core/permissions/permission_registry.dart';

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
