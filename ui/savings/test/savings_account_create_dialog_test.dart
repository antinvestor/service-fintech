import 'package:antinvestor_api_savings/antinvestor_api_savings.dart';
import 'package:antinvestor_ui_savings/antinvestor_ui_savings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openDialog(
  WidgetTester tester, {
  required String organizationId,
  required Future<void> Function(SavingsAccountObject) onSave,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => SavingsAccountCreateDialog(
                organizationId: organizationId,
                branchId: 'branch-1',
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
  group('SavingsAccountCreateDialog', () {
    testWidgets('blocks submission until every required field is filled', (
      tester,
    ) async {
      var saves = 0;
      await openDialog(
        tester,
        organizationId: 'org-1',
        onSave: (_) async => saves++,
      );

      await tester.tap(find.byKey(const Key('account-create-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Client ID is required'), findsOneWidget);
      expect(find.text('Savings Product ID is required'), findsOneWidget);
      expect(saves, 0);
    });

    testWidgets('rejects a malformed currency code', (tester) async {
      await openDialog(tester, organizationId: 'org-1', onSave: (_) async {});

      await tester.enterText(
        find.byKey(const Key('account-client-id')),
        'client-1',
      );
      await tester.enterText(
        find.byKey(const Key('account-product-id')),
        'product-1',
      );
      await tester.enterText(
        find.byKey(const Key('account-currency-code')),
        'KESH',
      );
      await tester.tap(find.byKey(const Key('account-create-submit')));
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a 3-letter currency code (e.g. KES)'),
        findsOneWidget,
      );
    });

    // The server rejects a create without an organization, so the dialog must
    // supply it from the session rather than leaving it to the operator.
    testWidgets(
      'carries the tenancy organization and branch onto the account',
      (tester) async {
        SavingsAccountObject? saved;
        await openDialog(
          tester,
          organizationId: 'org-1',
          onSave: (account) async => saved = account,
        );

        await tester.enterText(
          find.byKey(const Key('account-client-id')),
          'client-1',
        );
        await tester.enterText(
          find.byKey(const Key('account-product-id')),
          'product-1',
        );
        await tester.tap(find.byKey(const Key('account-create-submit')));
        await tester.pumpAndSettle();

        expect(saved, isNotNull);
        expect(saved!.organizationId, 'org-1');
        expect(saved!.branchId, 'branch-1');
        expect(saved!.currencyCode, 'KES');
        expect(saved!.ownerId, 'client-1');
        expect(saved!.productId, 'product-1');
      },
    );

    testWidgets('refuses to submit with no organization selected', (
      tester,
    ) async {
      var saves = 0;
      await openDialog(
        tester,
        organizationId: '',
        onSave: (_) async => saves++,
      );

      await tester.enterText(
        find.byKey(const Key('account-client-id')),
        'client-1',
      );
      await tester.enterText(
        find.byKey(const Key('account-product-id')),
        'product-1',
      );
      await tester.tap(find.byKey(const Key('account-create-submit')));
      await tester.pumpAndSettle();

      expect(saves, 0);
      expect(
        find.text('Select an organization before opening an account'),
        findsOneWidget,
      );
    });
  });
}
