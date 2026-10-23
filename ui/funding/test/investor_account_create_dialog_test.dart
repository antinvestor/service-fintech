import 'package:antinvestor_api_funding/antinvestor_api_funding.dart';
import 'package:antinvestor_ui_funding/antinvestor_ui_funding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openDialog(
  WidgetTester tester, {
  required Future<void> Function(InvestorAccountObject) onSave,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => InvestorAccountCreateDialog(onSave: onSave),
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

void main() {
  group('InvestorAccountCreateDialog', () {
    testWidgets('requires a name, an investor and a currency', (tester) async {
      var saves = 0;
      await openDialog(tester, onSave: (_) async => saves++);

      await tester.enterText(find.byKey(const Key('investor-currency')), '');
      await tester.tap(find.byKey(const Key('investor-create-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Account name is required'), findsOneWidget);
      expect(find.text('Investor ID is required'), findsOneWidget);
      expect(find.text('Currency is required'), findsOneWidget);
      expect(saves, 0);
    });

    // Without a currency the server cannot denominate the account, and every
    // later deposit fails; the dialog must always send one.
    testWidgets('always carries a currency onto the new account', (
      tester,
    ) async {
      InvestorAccountObject? saved;
      await openDialog(tester, onSave: (account) async => saved = account);

      await tester.enterText(
        find.byKey(const Key('investor-account-name')),
        'Growth fund',
      );
      await tester.enterText(find.byKey(const Key('investor-id')), 'inv-1');
      await tester.enterText(find.byKey(const Key('investor-currency')), 'usd');
      await tester.tap(find.byKey(const Key('investor-create-submit')));
      await tester.pumpAndSettle();

      expect(saved, isNotNull);
      expect(saved!.availableBalance.currencyCode, 'USD');
      expect(saved!.availableBalance.units.toInt(), 0);
      expect(saved!.minInterestRate, '0.00');
    });

    testWidgets('rejects a non-numeric maximum exposure', (tester) async {
      await openDialog(tester, onSave: (_) async {});

      await tester.enterText(
        find.byKey(const Key('investor-account-name')),
        'Growth fund',
      );
      await tester.enterText(find.byKey(const Key('investor-id')), 'inv-1');
      await tester.enterText(
        find.byKey(const Key('investor-max-exposure')),
        'plenty',
      );
      await tester.tap(find.byKey(const Key('investor-create-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid number'), findsOneWidget);
    });
  });
}
