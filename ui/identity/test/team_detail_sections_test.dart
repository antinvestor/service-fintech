import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Another product's section on a team page is offered only the members
  // who are active, so nobody is paid through a lapsed membership.
  testWidgets('a team section is given the active members only', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    List<String>? given;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          internalTeamByIdProvider.overrideWith(
            (ref, id) async =>
                InternalTeamObject(id: id, name: 'North', state: STATE.ACTIVE),
          ),
          teamMembershipListProvider.overrideWith(
            (ref, params) async => [
              TeamMembershipObject(
                teamId: params.teamId,
                memberId: 'member-1',
                state: STATE.ACTIVE,
              ),
              TeamMembershipObject(
                teamId: params.teamId,
                memberId: 'member-2',
                state: STATE.INACTIVE,
              ),
            ],
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: TeamDetailScreen(
              teamId: 'team-7',
              canManage: false,
              sections: [
                (context, team, memberIds) {
                  given = memberIds;
                  return Text('Section for ${team.name}');
                },
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Section for North'), findsOneWidget);
    expect(given, ['member-1']);
  });
}
