import 'dart:async';

import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _PageFetch =
    Future<List<OrganizationObject>> Function(int offset, int limit);

class _FakeOrganizationPagedList extends OrganizationPagedList {
  _FakeOrganizationPagedList(super.query, this._fetch);

  final _PageFetch _fetch;

  @override
  Future<List<OrganizationObject>> fetchPage(int offset, int limit) =>
      _fetch(offset, limit);
}

List<OrganizationObject> _orgs(int from, int count) => [
  for (var i = from; i < from + count; i++)
    OrganizationObject(id: 'org-$i', name: 'Organization $i', code: 'O$i'),
];

/// The admin list header lays its actions out in one row, so give the
/// screen a desktop-sized surface, the way it is used in the seed app.
void _useDesktopSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _host(_PageFetch fetch) {
  return ProviderScope(
    overrides: [
      organizationPagedListProvider.overrideWith2(
        (query) => _FakeOrganizationPagedList(query, fetch),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(body: OrganizationsScreen(canManage: false)),
    ),
  );
}

void main() {
  testWidgets('offers Load more only while a page came back full', (
    tester,
  ) async {
    _useDesktopSurface(tester);
    final calls = <(int, int)>[];
    await tester.pumpWidget(
      _host((offset, limit) async {
        calls.add((offset, limit));
        // Sixty rows: the first page is full, the second is short.
        return _orgs(offset, offset == 0 ? limit : 10);
      }),
    );
    await tester.pumpAndSettle();

    expect(calls, [(0, kIdentityListPageSize)]);
    expect(find.byKey(const Key('load-more-action')), findsOneWidget);
    expect(find.text('Showing first $kIdentityListPageSize'), findsOneWidget);

    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();

    expect(calls, [
      (0, kIdentityListPageSize),
      (kIdentityListPageSize, kIdentityListPageSize),
    ], reason: 'the second read must resume from the offset after page one');
    expect(
      find.byKey(const Key('load-more-action')),
      findsNothing,
      reason: 'a short page proves the list is exhausted',
    );
    expect(
      find.byKey(const Key('list-error-view')),
      findsNothing,
      reason: 'appending must never replace the table with an error page',
    );
  });

  testWidgets('never offers Load more for a short first page', (tester) async {
    await tester.pumpWidget(_host((offset, limit) async => _orgs(0, 3)));
    await tester.pumpAndSettle();

    expect(find.text('Organization 0'), findsOneWidget);
    expect(find.byKey(const Key('load-more-action')), findsNothing);
  });

  testWidgets('disables the action while the next page is in flight', (
    tester,
  ) async {
    _useDesktopSurface(tester);
    final second = Completer<List<OrganizationObject>>();
    await tester.pumpWidget(
      _host((offset, limit) {
        if (offset == 0) return Future.value(_orgs(0, limit));
        return second.future;
      }),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Load more'));
    await tester.pump();

    final button = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('Load more'),
        matching: find.byType(TextButton),
      ),
    );
    expect(button.onPressed, isNull, reason: 'no double-fetch while loading');
    expect(
      find.descendant(
        of: find.byKey(const Key('load-more-action')),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    second.complete(const []);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('load-more-action')), findsNothing);
  });

  testWidgets('keeps loaded rows and offers retry when the append fails', (
    tester,
  ) async {
    _useDesktopSurface(tester);
    var attempts = 0;
    await tester.pumpWidget(
      _host((offset, limit) async {
        if (offset == 0) return _orgs(0, limit);
        attempts++;
        if (attempts == 1) throw Exception('connection refused');
        return _orgs(offset, 2);
      }),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();

    expect(find.text('Organization 0'), findsOneWidget);
    expect(find.byKey(const Key('list-error-view')), findsNothing);
    expect(find.byKey(const Key('load-more-action')), findsOneWidget);
    expect(
      find.text('Showing first $kIdentityListPageSize'),
      findsNothing,
      reason: 'the row count gives way to the failure message',
    );

    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();

    expect(attempts, 2, reason: 'retry must re-read the same page');
    expect(find.byKey(const Key('load-more-action')), findsNothing);
  });
}
