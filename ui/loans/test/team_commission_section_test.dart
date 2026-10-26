import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart';
import 'package:connectrpc/connect.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Money _kes(int units) =>
    Money(currencyCode: 'KES', units: Int64(units), nanos: 0);

Widget _host({
  required bool canPayout,
  List<String> memberIds = const ['member-1'],
  int available = 400,
  List<TeamCommissionPayoutObject> payouts = const [],
}) {
  return ProviderScope(
    overrides: [
      teamCommissionProvider.overrideWith(
        (ref, teamId) async => [
          TeamCommissionObject(
            teamId: teamId,
            accrued: _kes(1000),
            paidOut: _kes(1000 - available),
            available: _kes(available),
          ),
        ],
      ),
      teamCommissionPayoutsProvider.overrideWith(
        (ref, teamId) async => payouts,
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: TeamCommissionSection(
          teamId: 'team-7',
          memberIds: memberIds,
          canPayout: canPayout,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows what the team earned, was paid and has left', (
    tester,
  ) async {
    await tester.pumpWidget(_host(canPayout: false));
    await tester.pumpAndSettle();

    expect(find.textContaining('Available KES'), findsOneWidget);
    expect(find.textContaining('Earned KES'), findsOneWidget);
    expect(find.byKey(const Key('commission-payout')), findsNothing);
  });

  testWidgets('pay out is offered with the permit and a member to pay', (
    tester,
  ) async {
    await tester.pumpWidget(_host(canPayout: true));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('commission-payout')), findsOneWidget);
  });

  testWidgets('no pay out without an active member', (tester) async {
    await tester.pumpWidget(_host(canPayout: true, memberIds: const []));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('commission-payout')), findsNothing);
  });

  testWidgets('no pay out when nothing is left', (tester) async {
    await tester.pumpWidget(_host(canPayout: true, available: 0));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('commission-payout')), findsNothing);
  });

  testWidgets('a refused payout is shown with its reason', (tester) async {
    await tester.pumpWidget(
      _host(
        canPayout: false,
        payouts: [
          TeamCommissionPayoutObject(
            id: 'p-1',
            memberId: 'member-1',
            amount: _kes(200),
            status: TeamCommissionPayoutStatus
                .TEAM_COMMISSION_PAYOUT_STATUS_PENDING,
            failureReason: 'no verified number',
            reason: 'October',
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Not paid'), findsOneWidget);
    expect(find.textContaining('no verified number'), findsOneWidget);
  });

  // A refused payout moved nothing and is closed, so the next try is a new
  // payout with a new key.
  testWidgets('a refused payout is retried as a new payout', (tester) async {
    final keys = <String>[];
    var refuse = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommissionPayoutDialog(
            available: _kes(400),
            memberIds: const ['member-1'],
            onSubmit: (member, amount, reason, key) async {
              keys.add(key);
              if (refuse) {
                refuse = false;
                throw ConnectException(
                  Code.failedPrecondition,
                  'no verified number',
                );
              }
            },
          ),
        ),
      ),
    );
    await tester.enterText(find.byKey(const Key('payout-reason')), 'October');
    await tester.tap(find.byKey(const Key('payout-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payout-submit')));
    await tester.pumpAndSettle();

    expect(keys, hasLength(2));
    expect(keys[1], isNot(keys[0]));
  });

  // A retry after a failure must resume the same payout, so the key the
  // dialog sends never changes while it is open.
  testWidgets('the payout dialog retries with the same key', (tester) async {
    final calls = <(String, String, String, String)>[];
    var fail = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommissionPayoutDialog(
            available: _kes(400),
            memberIds: const ['member-1'],
            onSubmit: (member, amount, reason, key) async {
              calls.add((member, amount, reason, key));
              if (fail) {
                fail = false;
                throw Exception('timeout');
              }
            },
          ),
        ),
      ),
    );
    await tester.enterText(find.byKey(const Key('payout-reason')), 'October');
    await tester.tap(find.byKey(const Key('payout-submit')));
    await tester.pumpAndSettle();
    expect(find.textContaining('timeout'), findsOneWidget);

    await tester.tap(find.byKey(const Key('payout-submit')));
    await tester.pumpAndSettle();

    expect(calls, hasLength(2));
    expect(calls[0].$1, 'member-1', reason: 'the only member is chosen');
    expect(calls[0].$2, '400.00', reason: 'defaults to what is available');
    expect(calls[1].$4, calls[0].$4);
  });
}
