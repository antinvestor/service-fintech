import 'package:flutter_test/flutter_test.dart';
import 'package:seed_ui/app/router.dart';
import 'package:seed_ui/core/auth/permission_checker.dart';

void main() {
  Future<String?> redirect(
    String location, {
    required bool loggedIn,
    PermissionResolution permissions = const PermissionResolution.unavailable(),
    void Function()? onAuthenticated,
  }) => resolveRedirect(
    location: location,
    isLoggedIn: () async => loggedIn,
    permissions: () async => permissions,
    onAuthenticated: onAuthenticated == null
        ? null
        : () async => onAuthenticated(),
  );

  group('unauthenticated', () {
    test('every app location redirects to /login', () async {
      for (final location in [
        '/',
        '/organizations',
        '/organizations/org-1',
        '/workforce',
        '/access-roles',
        '/limits/policies',
      ]) {
        expect(
          await redirect(location, loggedIn: false),
          '/login',
          reason: '$location must not render without a session',
        );
      }
    });

    test('/login itself is allowed', () async {
      expect(await redirect('/login', loggedIn: false), isNull);
    });

    test('the OAuth callback is allowed to finish the exchange', () async {
      expect(await redirect('/auth/callback', loggedIn: false), isNull);
    });

    test('tenancy is not initialised', () async {
      var initialized = false;
      await redirect(
        '/',
        loggedIn: false,
        onAuthenticated: () => initialized = true,
      );
      expect(initialized, isFalse);
    });
  });

  group('authenticated', () {
    test('/login bounces to the dashboard', () async {
      expect(
        await redirect(
          '/login',
          loggedIn: true,
          permissions: const PermissionResolution.resolved(<String>{}),
        ),
        '/',
      );
    });

    test('the callback bounces to the dashboard', () async {
      expect(await redirect('/auth/callback', loggedIn: true), '/');
    });

    test('ungated locations are allowed', () async {
      for (final location in ['/', '/organizations', '/limits/policies']) {
        expect(
          await redirect(
            location,
            loggedIn: true,
            permissions: const PermissionResolution.resolved(<String>{}),
          ),
          isNull,
          reason: '$location is not permission gated',
        );
      }
    });

    test('tenancy is initialised once the session is confirmed', () async {
      var initialized = false;
      await redirect(
        '/',
        loggedIn: true,
        permissions: const PermissionResolution.resolved(<String>{}),
        onAuthenticated: () => initialized = true,
      );
      expect(initialized, isTrue);
    });
  });

  group('permission gate', () {
    test('/access-roles is reachable with the grant', () async {
      expect(
        await redirect(
          '/access-roles',
          loggedIn: true,
          permissions: const PermissionResolution.resolved(<String>{
            'access_role_assignment_manage',
          }),
        ),
        isNull,
      );
    });

    test('/access-roles is denied without the grant', () async {
      expect(
        await redirect(
          '/access-roles',
          loggedIn: true,
          permissions: const PermissionResolution.resolved(<String>{
            'organization_view',
          }),
        ),
        '/',
      );
    });

    test('/access-roles is denied when capabilities are unavailable', () async {
      expect(
        await redirect(
          '/access-roles',
          loggedIn: true,
          permissions: const PermissionResolution.unavailable(),
        ),
        '/',
        reason: 'an unknown permission set must fail closed',
      );
    });
  });
}
