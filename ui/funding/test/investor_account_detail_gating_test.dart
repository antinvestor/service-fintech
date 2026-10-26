import 'package:antinvestor_api_funding/antinvestor_api_funding.dart';
import 'package:antinvestor_ui_funding/antinvestor_ui_funding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({required bool canManage, required bool canFund}) {
  return ProviderScope(
    overrides: [
      investorAccountDetailProvider(
        'acc-1',
      ).overrideWith((ref) async => InvestorAccountObject(id: 'acc-1')),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: InvestorAccountDetailScreen(
          accountId: 'acc-1',
          canManage: canManage,
          canFund: canFund,
        ),
      ),
    ),
  );
}

void main() {
  const deposit = Key('funding-action-deposit');
  const withdraw = Key('funding-action-withdraw');
  const fund = Key('funding-action-fund-loan');

  testWidgets('a viewer is offered no money actions', (tester) async {
    await tester.pumpWidget(_host(canManage: false, canFund: false));
    await tester.pumpAndSettle();
    expect(find.byKey(deposit), findsNothing);
    expect(find.byKey(withdraw), findsNothing);
    expect(find.byKey(fund), findsNothing);
  });

  testWidgets('fund_manage alone offers only Fund Loan', (tester) async {
    await tester.pumpWidget(_host(canManage: false, canFund: true));
    await tester.pumpAndSettle();
    expect(find.byKey(deposit), findsNothing);
    expect(find.byKey(fund), findsOneWidget);
  });

  testWidgets('investor_account_manage offers deposit and withdraw', (
    tester,
  ) async {
    await tester.pumpWidget(_host(canManage: true, canFund: false));
    await tester.pumpAndSettle();
    expect(find.byKey(deposit), findsOneWidget);
    expect(find.byKey(withdraw), findsOneWidget);
    expect(find.byKey(fund), findsNothing);
  });
}
