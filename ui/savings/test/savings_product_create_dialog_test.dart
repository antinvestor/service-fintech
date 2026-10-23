import 'package:antinvestor_api_savings/antinvestor_api_savings.dart';
import 'package:antinvestor_ui_savings/antinvestor_ui_savings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openDialog(
  WidgetTester tester, {
  required Future<void> Function(SavingsProductObject) onSave,
  String organizationId = 'org-1',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => SavingsProductCreateDialog(
                organizationId: organizationId,
                onSave: onSave,
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

void main() {
  group('SavingsProductCreateDialog', () {
    testWidgets('requires the fields the contract makes mandatory', (
      tester,
    ) async {
      var saves = 0;
      await openDialog(tester, onSave: (_) async => saves++);

      await tester.tap(find.byKey(const Key('product-create-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Product name is required'), findsOneWidget);
      expect(find.text('Product code is required'), findsOneWidget);
      expect(find.text('Interest rate is required'), findsOneWidget);
      expect(saves, 0);
    });

    testWidgets('sends organization, code, currency and terms', (tester) async {
      SavingsProductObject? saved;
      await openDialog(tester, onSave: (product) async => saved = product);

      await tester.enterText(
        find.byKey(const Key('product-name')),
        'Ordinary savings',
      );
      await tester.enterText(find.byKey(const Key('product-code')), 'sav-std');
      await tester.enterText(find.byKey(const Key('product-rate')), '3.50');
      await tester.enterText(
        find.byKey(const Key('product-min-deposit')),
        '100',
      );
      await tester.tap(find.byKey(const Key('product-create-submit')));
      await tester.pumpAndSettle();

      expect(saved, isNotNull);
      expect(saved!.organizationId, 'org-1');
      expect(saved!.code, 'SAV-STD');
      expect(saved!.currencyCode, 'KES');
      expect(saved!.interestRate, '3.50');
      expect(saved!.minDeposit.units.toInt(), 100);
      expect(saved!.periodType, SavingsPeriodType.SAVINGS_PERIOD_TYPE_MONTHLY);
      expect(
        saved!.compoundingFrequency,
        CompoundingFrequency.COMPOUNDING_FREQUENCY_MONTHLY,
      );
    });

    testWidgets('rejects a negative interest rate', (tester) async {
      await openDialog(tester, onSave: (_) async {});

      await tester.enterText(find.byKey(const Key('product-name')), 'Product');
      await tester.enterText(find.byKey(const Key('product-code')), 'P1');
      await tester.enterText(find.byKey(const Key('product-rate')), '-2');
      await tester.tap(find.byKey(const Key('product-create-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Interest rate cannot be negative'), findsOneWidget);
    });
  });
}
