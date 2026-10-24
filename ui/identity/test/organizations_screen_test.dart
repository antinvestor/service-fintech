import 'dart:async';

import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Fetch = Future<List<OrganizationObject>> Function(String query);

class _FakeOrganizationPagedList extends OrganizationPagedList {
  _FakeOrganizationPagedList(super.query, this._fetch);

  final _Fetch _fetch;

  @override
  Future<List<OrganizationObject>> fetchPage(int offset, int limit) =>
      _fetch(query);
}

Widget _host(_Fetch list) {
  return ProviderScope(
    overrides: [
      organizationPagedListProvider.overrideWith2(
        (query) => _FakeOrganizationPagedList(query, list),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(body: OrganizationsScreen(canManage: false)),
    ),
  );
}

void main() {
  testWidgets('renders a spinner while the first page is loading', (
    tester,
  ) async {
    final completer = Completer<List<OrganizationObject>>();
    await tester.pumpWidget(_host((query) => completer.future));
    await tester.pump();

    expect(find.byKey(const Key('list-loading-view')), findsOneWidget);
    expect(find.byKey(const Key('list-error-view')), findsNothing);

    completer.complete(const []);
    await tester.pumpAndSettle();
  });

  testWidgets('renders an error with retry instead of an empty table', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      _host((query) {
        calls++;
        return Future<List<OrganizationObject>>.error(
          Exception('connection refused'),
        );
      }),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('list-error-view')), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Organizations'), findsWidgets);

    final before = calls;
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(calls, greaterThan(before), reason: 'retry must re-run the query');
  });

  testWidgets('renders the list itself when the query succeeds', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        (query) async => [
          OrganizationObject(
            id: 'org-1',
            name: 'Stawi Capital',
            code: 'STAWI',
            organizationType: OrganizationType.ORGANIZATION_TYPE_MICROFINANCE,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('list-error-view')), findsNothing);
    expect(find.byKey(const Key('list-loading-view')), findsNothing);
    expect(find.text('Stawi Capital'), findsOneWidget);
    expect(find.text('Microfinance'), findsOneWidget);
  });

  testWidgets('renders an empty result without an error or a spinner', (
    tester,
  ) async {
    await tester.pumpWidget(_host((query) async => const []));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('list-error-view')), findsNothing);
    expect(find.byKey(const Key('list-loading-view')), findsNothing);
    expect(find.text('Stawi Capital'), findsNothing);
    expect(find.text('Organizations'), findsWidgets);
  });
}
