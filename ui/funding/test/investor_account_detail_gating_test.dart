import 'package:antinvestor_api_funding/antinvestor_api_funding.dart';
import 'package:antinvestor_ui_funding/antinvestor_ui_funding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({required bool canManage}) {
  return ProviderScope(
    overrides: [
      investorAccountDetailProvider(
        'acc-1',
      ).overrideWith((ref) async => InvestorAccountObject(id: 'acc-1')),
      investorStatementProvider.overrideWith(
        (ref, period) async => InvestorStatementResponse(),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: InvestorAccountDetailScreen(
          accountId: 'acc-1',
          canManage: canManage,
        ),
      ),
    ),
  );
}

void main() {
  const deposit = Key('funding-action-deposit');
  const withdraw = Key('funding-action-withdraw');
  const fund = Key('funding-action-fund-loan');
  const instructions = Key('funding-deposit-instructions');

  testWidgets('a viewer is offered no money actions', (tester) async {
    await tester.pumpWidget(_host(canManage: false));
    await tester.pumpAndSettle();
    expect(find.byKey(withdraw), findsNothing);
    expect(find.byKey(instructions), findsOneWidget);
  });

  // Capital arrives only from the investor's own payment; nobody types a
  // deposit, and loans are funded when they open, from the whole pool.
  testWidgets('nobody records a deposit or funds a loan by hand', (
    tester,
  ) async {
    await tester.pumpWidget(_host(canManage: true));
    await tester.pumpAndSettle();
    expect(find.byKey(deposit), findsNothing);
    expect(find.byKey(fund), findsNothing);
    expect(find.byKey(withdraw), findsOneWidget);
    expect(find.textContaining('quoting acc-1'), findsOneWidget);
  });
}
