import 'package:flutter_test/flutter_test.dart';
import 'package:seed_ui/core/navigation/nav_items.dart';
import 'package:seed_ui/core/navigation/nav_state.dart';

Iterable<NavItem> flatten(Iterable<NavItem> items) sync* {
  for (final item in items) {
    yield item;
    yield* flatten(item.children);
  }
}

Set<String> idsOf(Iterable<NavItem> items) =>
    flatten(items).map((i) => i.id).toSet();

void main() {
  group('navItemsFor', () {
    test('hides gated items when nothing is granted', () {
      final ids = idsOf(navItemsFor(const {}));

      expect(ids, isNot(contains('access_roles')));
      expect(
        ids,
        containsAll(<String>[
          'dashboard',
          'organizations',
          'workforce_members',
        ]),
        reason: 'ungated items stay visible',
      );
    });

    test('shows a gated item once its permission is granted', () {
      final ids = idsOf(navItemsFor(const {'access_role_assignment_manage'}));
      expect(ids, contains('access_roles'));
    });

    test('an unrelated grant does not unlock a gated item', () {
      final ids = idsOf(navItemsFor(const {'organization_manage'}));
      expect(ids, isNot(contains('access_roles')));
    });

    test('clients appear with client_view only', () {
      expect(idsOf(navItemsFor(const {})), isNot(contains('clients')));
      expect(idsOf(navItemsFor(const {'client_view'})), contains('clients'));
    });

    test('the loans section is hidden until a loans permit is granted', () {
      expect(idsOf(navItemsFor(const {})), isNot(contains('loans_section')));

      final ids = idsOf(navItemsFor(const {'loan_view'}));
      expect(ids, containsAll(<String>['loans_section', 'loans']));
      expect(ids, isNot(contains('loan_products')));

      expect(
        idsOf(navItemsFor(const {'loan_product_view'})),
        containsAll(<String>['loans_section', 'loan_products']),
      );
    });

    test('every gated nav item is gated by a route guard too', () {
      for (final item in flatten(buildNavItems())) {
        if (item.requiredPermissions.isEmpty || item.route == null) continue;
        expect(
          requiredPermissionsForRoute(item.route!),
          equals(item.requiredPermissions),
          reason: '${item.route} is hidden but not guarded',
        );
      }
    });
  });

  group('routeMatches', () {
    test('the dashboard only matches itself', () {
      expect(routeMatches('/', '/'), isTrue);
      expect(routeMatches('/', '/organizations'), isFalse);
      expect(routeMatches('/', '/limits/policies'), isFalse);
    });

    test('a section matches its own subtree', () {
      expect(routeMatches('/organizations', '/organizations'), isTrue);
      expect(routeMatches('/organizations', '/organizations/org-1'), isTrue);
    });

    test('a section does not match a sibling with a shared prefix', () {
      expect(routeMatches('/org-units', '/org-units-archive'), isFalse);
    });
  });

  group('requiredPermissionsForRoute', () {
    test('gates /access-roles and its subtree', () {
      expect(
        requiredPermissionsForRoute('/access-roles'),
        equals({'access_role_assignment_manage'}),
      );
      expect(
        requiredPermissionsForRoute('/access-roles/role-1'),
        equals({'access_role_assignment_manage'}),
      );
    });

    test('gates loans routes on the module permits', () {
      expect(requiredPermissionsForRoute('/loans'), equals({'loan_view'}));
      expect(requiredPermissionsForRoute('/loans/ln-1'), equals({'loan_view'}));
      expect(
        requiredPermissionsForRoute('/loans/products'),
        equals({'loan_product_view'}),
      );
      expect(
        requiredPermissionsForRoute('/loans/requests/req-1'),
        equals({'loan_request_view'}),
      );
      expect(
        requiredPermissionsForRoute('/reports/loan-book'),
        equals({'portfolio_export'}),
      );
      expect(
        requiredPermissionsForRoute('/clients/c-1'),
        equals({'client_view'}),
      );
    });

    test('gates form templates on form_template_view', () {
      expect(
        requiredPermissionsForRoute('/form-templates/new'),
        equals({'form_template_view'}),
      );
    });

    test('gates funding and payment routes on their permits', () {
      expect(
        requiredPermissionsForRoute('/funding/accounts/acc-1'),
        equals({'investor_account_view'}),
      );
      expect(
        requiredPermissionsForRoute('/operations/payments'),
        equals({'payment_view'}),
      );
      expect(
        requiredPermissionsForRoute('/operations/transfers'),
        equals({'transfer_view'}),
      );
    });

    test('leaves ungated routes ungated', () {
      for (final route in ['/', '/organizations', '/limits/ledger']) {
        expect(requiredPermissionsForRoute(route), isEmpty, reason: route);
      }
    });

    test('an unknown route is ungated', () {
      expect(requiredPermissionsForRoute('/nowhere'), isEmpty);
    });
  });
}
