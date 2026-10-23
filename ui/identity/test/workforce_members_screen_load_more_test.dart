import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeWorkforceMemberPagedList extends WorkforceMemberPagedList {
  _FakeWorkforceMemberPagedList(super.params, this.calls);

  final List<int> calls;

  @override
  Future<List<WorkforceMemberObject>> fetchPage(int offset, int limit) async {
    calls.add(offset);
    final count = offset == 0 ? limit : 5;
    return [
      for (var i = offset; i < offset + count; i++)
        WorkforceMemberObject(
          id: 'member-$i',
          profileId: 'profile-$i',
          organizationId: 'org-1',
        ),
    ];
  }
}

void main() {
  testWidgets('workforce members append the next page through the cursor', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final calls = <int>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workforceMemberPagedListProvider.overrideWith2(
            (params) => _FakeWorkforceMemberPagedList(params, calls),
          ),
          organizationListProvider.overrideWith((ref, query) async => const []),
        ],
        child: const MaterialApp(
          home: Scaffold(body: WorkforceMembersScreen(canManage: false)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('profile-0'), findsOneWidget);
    expect(find.byKey(const Key('load-more-action')), findsOneWidget);

    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();

    expect(calls, [0, kIdentityListPageSize]);
    expect(find.byKey(const Key('load-more-action')), findsNothing);
    expect(find.byKey(const Key('list-error-view')), findsNothing);
  });
}
