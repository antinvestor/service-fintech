import 'dart:async';

import 'package:antinvestor_api_savings/antinvestor_api_savings.dart';
import 'package:antinvestor_ui_savings/antinvestor_ui_savings.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

PendingWithdrawal pending(String id, String accountId, int units) {
  final withdrawal = WithdrawalObject(
    id: id,
    savingsAccountId: accountId,
    status: WithdrawalStatus.WITHDRAWAL_STATUS_PENDING,
    reason: 'School fees',
  );
  withdrawal.ensureAmount()
    ..currencyCode = 'KES'
    ..units = Int64(units)
    ..nanos = 0;
  return (
    account: SavingsAccountObject(
      id: accountId,
      ownerId: 'owner-$accountId',
      currencyCode: 'KES',
    ),
    withdrawal: withdrawal,
  );
}

/// Records the decisions the screen makes instead of calling the service.
class RecordingWithdrawalNotifier extends WithdrawalNotifier {
  final approved = <String>[];
  final cancelled = <(String id, String reason)>[];
  Object? failWith;

  @override
  Future<WithdrawalObject> approve(String id, String savingsAccountId) async {
    if (failWith != null) throw failWith!;
    approved.add(id);
    return WithdrawalObject(
      id: id,
      status: WithdrawalStatus.WITHDRAWAL_STATUS_COMPLETED,
    );
  }

  @override
  Future<WithdrawalObject> cancel(
    String id,
    String savingsAccountId,
    String reason,
  ) async {
    cancelled.add((id, reason));
    return WithdrawalObject(
      id: id,
      status: WithdrawalStatus.WITHDRAWAL_STATUS_REJECTED,
    );
  }
}

Future<RecordingWithdrawalNotifier> pumpQueue(
  WidgetTester tester, {
  required FutureOr<List<PendingWithdrawal>> Function() load,
  bool canManage = true,
}) async {
  final notifier = RecordingWithdrawalNotifier();
  await tester.pumpWidget(
    ProviderScope(
      // Riverpod 3 retries a failed provider on its own; the tests assert on
      // the failure the operator sees, so retries are the operator's call.
      retry: (_, _) => null,
      overrides: [
        pendingWithdrawalQueueProvider.overrideWith((ref, orgId) => load()),
        withdrawalNotifierProvider.overrideWith(() => notifier),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: WithdrawalApprovalQueueScreen(canManage: canManage),
        ),
      ),
    ),
  );
  return notifier;
}

void main() {
  group('WithdrawalApprovalQueueScreen', () {
    testWidgets('shows a spinner while the queue loads', (tester) async {
      final gate = Completer<List<PendingWithdrawal>>();
      await pumpQueue(tester, load: () => gate.future);
      await tester.pump();

      expect(find.byKey(const Key('async-list-loading')), findsOneWidget);

      gate.complete([pending('w-1', 'acct-1', 500)]);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('async-list-loading')), findsNothing);
      expect(find.byKey(const Key('queue-row-w-1')), findsOneWidget);
    });

    testWidgets('shows the failure and retries on demand', (tester) async {
      var attempts = 0;
      await pumpQueue(
        tester,
        load: () {
          attempts++;
          if (attempts == 1) throw Exception('savings unavailable');
          return [pending('w-1', 'acct-1', 500)];
        },
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('async-list-error')), findsOneWidget);
      expect(find.textContaining('savings unavailable'), findsOneWidget);

      await tester.tap(find.byKey(const Key('async-list-retry')));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(find.byKey(const Key('queue-row-w-1')), findsOneWidget);
    });

    testWidgets('tells an empty queue apart from a failed one', (tester) async {
      await pumpQueue(tester, load: () => const []);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('async-list-empty')), findsOneWidget);
      expect(find.text('Nothing to approve'), findsOneWidget);
      expect(find.byKey(const Key('async-list-error')), findsNothing);
    });

    testWidgets('lists withdrawals from several accounts with their money', (
      tester,
    ) async {
      await pumpQueue(
        tester,
        load: () => [
          pending('w-1', 'acct-1', 500),
          pending('w-2', 'acct-2', 1250),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('KES 500.00'), findsOneWidget);
      expect(find.text('KES 1250.00'), findsOneWidget);
      expect(find.textContaining('Account acct-1'), findsOneWidget);
      expect(find.textContaining('Account acct-2'), findsOneWidget);
    });

    testWidgets('approves only after the operator confirms', (tester) async {
      final notifier = await pumpQueue(
        tester,
        load: () => [pending('w-1', 'acct-1', 500)],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('queue-approve-w-1')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Release KES 500.00'), findsOneWidget);
      expect(notifier.approved, isEmpty, reason: 'nothing before confirm');

      await tester.tap(find.text('Keep pending'));
      await tester.pumpAndSettle();
      expect(notifier.approved, isEmpty, reason: 'declined confirmation');

      await tester.tap(find.byKey(const Key('queue-approve-w-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('queue-confirm-approve')));
      await tester.pumpAndSettle();

      expect(notifier.approved, ['w-1']);
      expect(find.text('Withdrawal approved'), findsOneWidget);
    });

    testWidgets('surfaces an approval failure instead of swallowing it', (
      tester,
    ) async {
      final notifier = await pumpQueue(
        tester,
        load: () => [pending('w-1', 'acct-1', 500)],
      );
      notifier.failWith = Exception('insufficient reserved balance');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('queue-approve-w-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('queue-confirm-approve')));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('insufficient reserved balance'),
        findsOneWidget,
      );
    });

    testWidgets('cancelling requires a reason and passes it through', (
      tester,
    ) async {
      final notifier = await pumpQueue(
        tester,
        load: () => [pending('w-1', 'acct-1', 500)],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('queue-cancel-w-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('queue-confirm-cancel')));
      await tester.pumpAndSettle();

      expect(find.text('Reason is required'), findsOneWidget);
      expect(notifier.cancelled, isEmpty);

      await tester.enterText(
        find.byKey(const Key('queue-cancel-reason')),
        'Member withdrew the request',
      );
      await tester.tap(find.byKey(const Key('queue-confirm-cancel')));
      await tester.pumpAndSettle();

      expect(notifier.cancelled, [('w-1', 'Member withdrew the request')]);
      expect(find.text('Withdrawal cancelled'), findsOneWidget);
    });

    testWidgets(
      'hides approve and cancel from callers without the permission',
      (tester) async {
        await pumpQueue(
          tester,
          load: () => [pending('w-1', 'acct-1', 500)],
          canManage: false,
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('queue-row-w-1')), findsOneWidget);
        expect(find.byKey(const Key('queue-approve-w-1')), findsNothing);
        expect(find.byKey(const Key('queue-cancel-w-1')), findsNothing);
        expect(find.text('Pending'), findsOneWidget);
      },
    );
  });
}
