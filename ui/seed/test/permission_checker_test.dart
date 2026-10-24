import 'dart:convert';

import 'package:antinvestor_ui_core/permissions/permission_manifest.dart';
import 'package:antinvestor_ui_core/permissions/permission_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:seed_ui/core/auth/permission_checker.dart';

void main() {
  setUp(() {
    PermissionRegistry.instance
      ..clear()
      ..register(
        const PermissionManifest(
          namespace: 'service_identity',
          permissions: [
            PermissionEntry(
              key: 'access_role_assignment_manage',
              label: 'Manage Access Roles',
              scope: PermissionScope.feature,
            ),
          ],
        ),
      );
  });

  tearDown(PermissionRegistry.instance.clear);

  PermissionBatchChecker checkerFor(
    Future<http.Response> Function(http.Request request) handler,
  ) => PermissionBatchChecker(MockClient(handler), 'https://identity.test');

  test('a 200 batch answer is authoritative', () async {
    final checker = checkerFor(
      (request) async => http.Response(
        jsonEncode({
          'granted': ['access_role_assignment_manage'],
        }),
        200,
      ),
    );

    final result = await checker.checkAll('token');

    expect(result.available, isTrue);
    expect(result.granted, equals({'access_role_assignment_manage'}));
    expect(result.has('access_role_assignment_manage'), isTrue);
  });

  test('an empty grant list is a real answer, not an outage', () async {
    final checker = checkerFor(
      (request) async => http.Response(jsonEncode({'granted': []}), 200),
    );

    final result = await checker.checkAll('token');

    expect(result.available, isTrue);
    expect(result.granted, isEmpty);
    expect(result.has('access_role_assignment_manage'), isFalse);
  });

  test('a 404 on both endpoints is unavailable, not "no grants"', () async {
    final checker = checkerFor(
      (request) async => http.Response('not found', 404),
    );

    final result = await checker.checkAll('token');

    expect(result.available, isFalse);
    expect(result.has('access_role_assignment_manage'), isFalse);
    expect(
      result.hasAny(const {'access_role_assignment_manage'}),
      isFalse,
      reason: 'an unreachable capability service must deny',
    );
  });

  test('a 500 is unavailable', () async {
    final checker = checkerFor((request) async => http.Response('boom', 500));
    expect((await checker.checkAll('token')).available, isFalse);
  });

  test('a batch failure falls back to GET /ui/capabilities', () async {
    final checker = checkerFor((request) async {
      if (request.method == 'POST') return http.Response('nope', 500);
      return http.Response(
        jsonEncode({
          'user': {
            'permissions': ['organization_view'],
          },
        }),
        200,
      );
    });

    final result = await checker.checkAll('token');

    expect(result.available, isTrue);
    expect(result.granted, equals({'organization_view'}));
  });

  test('a 200 with an unrecognised shape is unavailable', () async {
    final checker = checkerFor(
      (request) async => http.Response(jsonEncode({'unexpected': true}), 200),
    );

    expect((await checker.checkAll('token')).available, isFalse);
  });

  test('hasAny allows a location that requires nothing', () {
    expect(
      const PermissionResolution.unavailable().hasAny(const {}),
      isTrue,
      reason: 'ungated routes stay reachable during an outage',
    );
  });
}
