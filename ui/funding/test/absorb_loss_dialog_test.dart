import 'package:antinvestor_ui_funding/antinvestor_ui_funding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Submission = ({String loanRequestId, String amount, String key});

Future<void> openDialog(
  WidgetTester tester, {
  required Future<void> Function(String, String, String) onSubmit,
  String initialLoanRequestId = '',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => AbsorbLossDialog(
                currencyCode: 'KES',
                initialLoanRequestId: initialLoanRequestId,
                onSubmit: onSubmit,
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> fillAndReview(
  WidgetTester tester, {
  String loan = 'loan-req-1',
  String amount = '250.00',
}) async {
  await tester.enterText(find.byKey(const Key('absorb-loss-loan-field')), loan);
  await tester.enterText(
    find.byKey(const Key('absorb-loss-amount-field')),
    amount,
  );
  await tester.tap(find.byKey(const Key('absorb-loss-review')));
  await tester.pumpAndSettle();
}

void main() {
  group('AbsorbLossDialog', () {
    testWidgets('refuses to review without a loan and a positive amount', (
      tester,
    ) async {
      var submissions = 0;
      await openDialog(tester, onSubmit: (_, _, _) async => submissions++);

      await tester.tap(find.byKey(const Key('absorb-loss-review')));
      await tester.pumpAndSettle();
      expect(find.text('Loan request ID is required'), findsOneWidget);
      expect(find.text('Amount is required'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('absorb-loss-loan-field')),
        'loan-req-1',
      );
      await tester.enterText(
        find.byKey(const Key('absorb-loss-amount-field')),
        '0',
      );
      await tester.tap(find.byKey(const Key('absorb-loss-review')));
      await tester.pumpAndSettle();
      expect(find.text('Amount must be positive'), findsOneWidget);

      expect(find.byKey(const Key('absorb-loss-confirm')), findsNothing);
      expect(submissions, 0);
    });

    testWidgets('reads the write-off back before anything is submitted', (
      tester,
    ) async {
      var submissions = 0;
      await openDialog(tester, onSubmit: (_, _, _) async => submissions++);
      await fillAndReview(tester);

      expect(find.byKey(const Key('absorb-loss-summary')), findsOneWidget);
      expect(find.textContaining('KES 250.00'), findsOneWidget);
      expect(find.textContaining('loan-req-1'), findsOneWidget);
      expect(submissions, 0, reason: 'review is not submission');

      // Back returns to the form with the figures intact.
      await tester.tap(find.byKey(const Key('absorb-loss-back')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('absorb-loss-amount-field')), findsOneWidget);
      expect(find.text('250.00'), findsOneWidget);
      expect(submissions, 0);
    });

    testWidgets('submits once with the figures and closes on success', (
      tester,
    ) async {
      final submissions = <Submission>[];
      await openDialog(
        tester,
        onSubmit: (loan, amount, key) async =>
            submissions.add((loanRequestId: loan, amount: amount, key: key)),
      );
      await fillAndReview(tester);

      await tester.tap(find.byKey(const Key('absorb-loss-confirm')));
      await tester.pumpAndSettle();

      expect(submissions, hasLength(1));
      expect(submissions.single.loanRequestId, 'loan-req-1');
      expect(submissions.single.amount, '250.00');
      expect(submissions.single.key, hasLength(32));
      expect(find.byType(AbsorbLossDialog), findsNothing);
    });

    testWidgets('a retry after a failure carries the same idempotency key', (
      tester,
    ) async {
      final keys = <String>[];
      var fail = true;
      await openDialog(
        tester,
        onSubmit: (_, _, key) async {
          keys.add(key);
          if (fail) throw Exception('funding unavailable');
        },
      );
      await fillAndReview(tester);

      await tester.tap(find.byKey(const Key('absorb-loss-confirm')));
      await tester.pumpAndSettle();
      expect(find.textContaining('funding unavailable'), findsOneWidget);
      expect(
        find.byType(AbsorbLossDialog),
        findsOneWidget,
        reason: 'stay open',
      );

      fail = false;
      await tester.tap(find.byKey(const Key('absorb-loss-confirm')));
      await tester.pumpAndSettle();

      expect(keys, hasLength(2));
      expect(keys[0], keys[1], reason: 'same intent, same key');
      expect(find.byType(AbsorbLossDialog), findsNothing);
    });

    testWidgets('two dialogs never share a key', (tester) async {
      final keys = <String>[];
      Future<void> record(String _, String _, String key) async =>
          keys.add(key);

      await openDialog(tester, onSubmit: record);
      await fillAndReview(tester);
      await tester.tap(find.byKey(const Key('absorb-loss-confirm')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await fillAndReview(tester);
      await tester.tap(find.byKey(const Key('absorb-loss-confirm')));
      await tester.pumpAndSettle();

      expect(keys, hasLength(2));
      expect(keys[0], isNot(keys[1]));
    });
  });
}
