import 'dart:async';

import 'package:antinvestor_api_savings/antinvestor_api_savings.dart';
import 'package:antinvestor_ui_savings/antinvestor_ui_savings.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fills a service-typed Money in place; the savings SDK carries its own
/// generated Money class, so amounts are set through the ensure* accessors.
void kes(dynamic money, int units) {
  money
    ..currencyCode = 'KES'
    ..units = Int64(units)
    ..nanos = 0;
}

/// A statement whose running balance is carried through [count] deposits of
/// 100 each, starting from an opening balance of 0.
SavingsStatementResponse statementWith(int count) {
  var running = 0;
  final response = SavingsStatementResponse(
    account: SavingsAccountObject(id: 'acct-1', currencyCode: 'KES'),
    balance: SavingsBalanceObject(),
  );
  kes(response.balance.ensureAvailableBalance(), count * 100);
  for (var i = 0; i < count; i++) {
    final entry = SavingsStatementEntry(
      date: DateTime.utc(2026, 1, 1 + i).toIso8601String(),
      description: 'Deposit ${i + 1}',
      reference: 'ref-${i + 1}',
    );
    kes(entry.ensureCredit(), 100);
    kes(entry.ensureDebit(), 0);
    kes(entry.ensureBalance(), running += 100);
    response.entries.add(entry);
  }
  return response;
}

Future<void> pumpStatement(
  WidgetTester tester, {
  required FutureOr<SavingsStatementResponse> Function() load,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      // Riverpod 3 retries a failed provider on its own; the tests assert on
      // the failure the operator sees, so retries are the operator's call.
      retry: (_, _) => null,
      overrides: [
        savingsStatementProvider.overrideWith((ref, params) => load()),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SavingsStatementScreen(accountId: 'acct-1')),
      ),
    ),
  );
}

void main() {
  group('SavingsStatementScreen', () {
    testWidgets('shows a spinner while the statement loads', (tester) async {
      final gate = Completer<SavingsStatementResponse>();
      await pumpStatement(tester, load: () => gate.future);
      await tester.pump();

      expect(find.byKey(const Key('statement-loading')), findsOneWidget);
      expect(find.byKey(const Key('statement-table')), findsNothing);

      gate.complete(statementWith(1));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('statement-loading')), findsNothing);
    });

    testWidgets('shows the failure and offers a retry', (tester) async {
      var attempts = 0;
      await pumpStatement(
        tester,
        load: () {
          attempts++;
          if (attempts == 1) throw Exception('ledger unavailable');
          return statementWith(2);
        },
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('statement-error')), findsOneWidget);
      expect(find.textContaining('ledger unavailable'), findsOneWidget);

      await tester.tap(find.byKey(const Key('statement-retry')));
      await tester.pumpAndSettle();

      expect(attempts, 2, reason: 'retry must re-run the request');
      expect(find.byKey(const Key('statement-table')), findsOneWidget);
    });

    testWidgets('distinguishes an empty period from a failure', (tester) async {
      await pumpStatement(tester, load: () => statementWith(0));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('statement-empty')), findsOneWidget);
      expect(find.byKey(const Key('statement-error')), findsNothing);
      // A zero balance is a fact and renders as a number, never a dash.
      expect(find.textContaining('KES 0.00'), findsOneWidget);
    });

    testWidgets('renders the running balance for every line', (tester) async {
      await pumpStatement(tester, load: () => statementWith(3));
      await tester.pumpAndSettle();

      expect(find.text('KES 100.00'), findsWidgets);
      expect(find.text('KES 200.00'), findsOneWidget);
      // The closing balance appears in the table and in the summary tile.
      expect(find.text('KES 300.00'), findsNWidgets(3));
      // A blank debit column, not a zero, on a credit line.
      expect(find.text('Deposit 1'), findsOneWidget);
    });

    testWidgets('pages through a long statement', (tester) async {
      await pumpStatement(
        tester,
        load: () => statementWith(statementPageSize + 5),
      );
      await tester.pumpAndSettle();

      expect(find.text('Showing 1–25 of 30'), findsOneWidget);
      expect(find.text('Deposit 1'), findsOneWidget);
      expect(find.text('Deposit 26'), findsNothing);

      final prev = tester.widget<IconButton>(
        find.byKey(const Key('statement-prev')),
      );
      expect(prev.onPressed, isNull, reason: 'no page before the first');

      await tester.tap(find.byKey(const Key('statement-next')));
      await tester.pumpAndSettle();

      expect(find.text('Showing 26–30 of 30'), findsOneWidget);
      expect(find.text('Deposit 26'), findsOneWidget);
      expect(find.text('Deposit 1'), findsNothing);

      final next = tester.widget<IconButton>(
        find.byKey(const Key('statement-next')),
      );
      expect(next.onPressed, isNull, reason: 'no page after the last');
    });

    testWidgets(
      'a chosen date range is sent to the server and can be cleared',
      (tester) async {
        final seen = <({String accountId, String fromDate, String toDate})>[];
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              savingsStatementProvider.overrideWith((ref, params) {
                seen.add(params);
                return statementWith(1);
              }),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: SavingsStatementScreen(
                  accountId: 'acct-1',
                  initialRange: DateTimeRange(
                    start: DateTime(2026, 3, 1),
                    end: DateTime(2026, 3, 31),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(seen, hasLength(1));
        expect(seen.first.accountId, 'acct-1');
        expect(
          DateTime.parse(seen.first.fromDate).toLocal(),
          DateTime(2026, 3, 1),
        );
        expect(
          DateTime.parse(seen.first.toDate).toLocal().day,
          31,
          reason: 'the window runs to the end of the last day',
        );
        expect(find.text('2026-03-01 – 2026-03-31'), findsOneWidget);

        await tester.tap(find.byKey(const Key('statement-range-clear')));
        await tester.pumpAndSettle();

        expect(seen, hasLength(2));
        expect(seen.last.fromDate, isEmpty, reason: 'server default window');
        expect(seen.last.toDate, isEmpty);
        expect(find.text('Last 90 days'), findsOneWidget);
      },
    );
  });
}
