import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

LoanAccountObject _loan(String id, {int dpd = 0}) => LoanAccountObject(
  id: id,
  clientId: 'client-$id',
  status: dpd > 0
      ? LoanStatus.LOAN_STATUS_DELINQUENT
      : LoanStatus.LOAN_STATUS_ACTIVE,
  termDays: 30,
  daysPastDue: dpd,
);

Widget _host({
  required List<LoanAccountListParams> seen,
  String? agentId,
  List<LoanAccountObject>? loans,
}) {
  return ProviderScope(
    overrides: [
      currentAgentIdProvider.overrideWithValue(agentId),
      loanAccountListProvider.overrideWith((ref, params) async {
        seen.add(params);
        return PagedResult(
          items: loans ?? [_loan('a'), _loan('b')],
          hasMore: false,
        );
      }),
    ],
    child: const MaterialApp(home: Scaffold(body: LoanAccountsScreen())),
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('sortByDaysPastDue orders worst first and keeps ties stable', () {
    final sorted = sortByDaysPastDue([
      _loan('x', dpd: 3),
      _loan('y', dpd: 30),
      _loan('z', dpd: 3),
      _loan('w'),
    ]);
    expect(sorted.map((l) => l.id), ['y', 'x', 'z', 'w']);
  });

  testWidgets('My portfolio is disabled when the agent id is unknown', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final seen = <LoanAccountListParams>[];
    await tester.pumpWidget(_host(seen: seen));
    await tester.pumpAndSettle();

    final chip = tester.widget<FilterChip>(
      find.byKey(const Key('my-portfolio-filter')),
    );
    expect(chip.onSelected, isNull);
    expect(chip.selected, isFalse);
    expect(seen.last.agentId, '');
  });

  testWidgets('My portfolio filters the search by the caller agent id', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final seen = <LoanAccountListParams>[];
    await tester.pumpWidget(_host(seen: seen, agentId: 'wm-7'));
    await tester.pumpAndSettle();
    expect(seen.last.agentId, '');

    await tester.tap(find.byKey(const Key('my-portfolio-filter')));
    await tester.pumpAndSettle();

    expect(seen.last.agentId, 'wm-7');
  });

  testWidgets('Delinquent searches delinquent loans and shows days past due '
      'worst first', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final seen = <LoanAccountListParams>[];
    await tester.pumpWidget(
      _host(seen: seen, loans: [_loan('low', dpd: 2), _loan('high', dpd: 45)]),
    );
    await tester.pumpAndSettle();
    expect(find.text('DAYS PAST DUE'), findsNothing);

    await tester.tap(find.byKey(const Key('delinquent-filter')));
    await tester.pumpAndSettle();

    expect(seen.last.status, LoanStatus.LOAN_STATUS_DELINQUENT);
    expect(find.text('DAYS PAST DUE'), findsOneWidget);
    final high = tester.getTopLeft(find.byKey(const Key('dpd-high')));
    final low = tester.getTopLeft(find.byKey(const Key('dpd-low')));
    expect(high.dy, lessThan(low.dy), reason: '45 days sorts above 2');
  });
}
