import 'package:antinvestor_ui_savings/antinvestor_ui_savings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] inside a Scaffold so dialogs and snackbars have a host.
Future<void> pumpHost(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  group('MoneyAmountDialog', () {
    testWidgets('refuses an empty amount', (tester) async {
      var submitted = 0;
      await pumpHost(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => MoneyAmountDialog(
                title: 'Deposit',
                confirmLabel: 'Deposit',
                currencyCode: 'KES',
                onSubmit: (_, _, _) async => submitted++,
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('money-submit-button')));
      await tester.pumpAndSettle();

      expect(find.text('Amount is required'), findsOneWidget);
      expect(submitted, 0, reason: 'an empty amount must never be submitted');
    });

    testWidgets('refuses a zero amount', (tester) async {
      var submitted = 0;
      await pumpHost(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => MoneyAmountDialog(
                title: 'Deposit',
                confirmLabel: 'Deposit',
                currencyCode: 'KES',
                onSubmit: (_, _, _) async => submitted++,
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('money-amount-field')), '0');
      await tester.tap(find.byKey(const Key('money-submit-button')));
      await tester.pumpAndSettle();

      expect(find.text('Amount must be positive'), findsOneWidget);
      expect(submitted, 0);
    });

    testWidgets('refuses text that is not a number', (tester) async {
      await pumpHost(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => MoneyAmountDialog(
                title: 'Deposit',
                confirmLabel: 'Deposit',
                currencyCode: 'KES',
                onSubmit: (_, _, _) async {},
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('money-amount-field')),
        'lots',
      );
      await tester.tap(find.byKey(const Key('money-submit-button')));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid number'), findsOneWidget);
    });

    testWidgets('submits a valid amount once and closes', (tester) async {
      final amounts = <String>[];
      await pumpHost(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => MoneyAmountDialog(
                title: 'Deposit',
                confirmLabel: 'Deposit',
                currencyCode: 'KES',
                onSubmit: (amount, _, _) async => amounts.add(amount),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('money-amount-field')),
        '125.50',
      );
      await tester.tap(find.byKey(const Key('money-submit-button')));
      await tester.pumpAndSettle();

      expect(amounts, ['125.50']);
      expect(find.byKey(const Key('money-amount-field')), findsNothing);
    });

    // A retry after a failure must carry the key the first attempt used;
    // minting a new one turns the user's second tap into a second deposit.
    testWidgets('reuses the same idempotency key across a retry', (
      tester,
    ) async {
      final keys = <String>[];
      var shouldFail = true;

      await pumpHost(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => MoneyAmountDialog(
                title: 'Deposit',
                confirmLabel: 'Deposit',
                currencyCode: 'KES',
                onSubmit: (_, _, key) async {
                  keys.add(key);
                  if (shouldFail) {
                    shouldFail = false;
                    throw Exception('gateway timeout');
                  }
                },
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('money-amount-field')), '10');
      await tester.tap(find.byKey(const Key('money-submit-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('money-submit-button')));
      await tester.pumpAndSettle();

      expect(keys.length, 2);
      expect(keys.first, keys.last);
    });
  });
}
