import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

RepaymentObject _repayment(String id, int units, int nanos, String channel) =>
    RepaymentObject(
      id: id,
      loanAccountId: 'loan-$id',
      channel: channel,
      receivedAt: '2026-10-24T09:00:00Z',
      amount: Money(currencyCode: 'KES', units: Int64(units), nanos: nanos),
    );

void main() {
  test('collection totals add units and nanos exactly per currency', () {
    final totals = collectionTotals([
      _repayment('a', 100, 600000000, 'cash'),
      _repayment('b', 50, 500000000, 'cash'),
    ]);
    expect(totals['KES']!.units, Int64(151));
    expect(totals['KES']!.nanos, 100000000);
  });

  testWidgets('shows today\'s collections and their total', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myCollectionsTodayProvider.overrideWith(
            (ref) async => [
              _repayment('a', 1000, 0, 'cash'),
              _repayment('b', 250, 0, 'cash'),
            ],
          ),
        ],
        child: const MaterialApp(home: MyCollectionsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 collections'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });
}
