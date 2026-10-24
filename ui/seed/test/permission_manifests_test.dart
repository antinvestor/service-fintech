import 'package:antinvestor_ui_core/permissions/permission_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_ui/core/auth/permission_manifests.dart';
import 'package:seed_ui/core/navigation/nav_items.dart';

Iterable<NavItem> _flatten(Iterable<NavItem> items) sync* {
  for (final item in items) {
    yield item;
    yield* _flatten(item.children);
  }
}

void main() {
  setUpAll(registerPermissionManifests);

  test('every permission the nav tree gates on is batch-checked', () {
    final registered = PermissionRegistry.instance.permissionsByNamespace.values
        .expand((keys) => keys)
        .toSet();
    for (final item in _flatten(buildNavItems())) {
      for (final permission in item.requiredPermissions) {
        expect(
          registered,
          contains(permission),
          reason: '${item.id} gates on $permission, which no manifest declares',
        );
      }
    }
  });

  test('loans and field permits are registered under their namespaces', () {
    final byNamespace = PermissionRegistry.instance.permissionsByNamespace;
    expect(byNamespace['service_field'], containsAll(['client_view']));
    expect(
      byNamespace['service_loans'],
      containsAll(['loan_view', 'loan_request_submit', 'collection_manage']),
    );
  });
}
