import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Money _kes(int units) =>
    Money(currencyCode: 'KES', units: Int64(units), nanos: 0);

Widget _host({required bool canCollectPayment}) {
  return ProviderScope(
    overrides: [
      loanAccountDetailProvider.overrideWith(
        (ref, id) async => LoanAccountObject(
          id: id,
          clientId: 'client-1',
          status: LoanStatus.LOAN_STATUS_ACTIVE,
          principalAmount: _kes(5000),
          termDays: 30,
        ),
      ),
      loanBalanceDetailProvider.overrideWith(
        (ref, id) async => LoanBalanceObject(
          loanAccountId: id,
          principalOutstanding: _kes(4000),
          interestAccrued: _kes(100),
          feesOutstanding: _kes(0),
          penaltiesOutstanding: _kes(0),
          totalOutstanding: _kes(4100),
          totalPaid: _kes(1000),
          totalDisbursed: _kes(5000),
        ),
      ),
      repaymentScheduleDetailProvider.overrideWith(
        (ref, id) async => RepaymentScheduleObject(loanAccountId: id),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: LoanAccountDetailScreen(
          loanId: 'loan-1',
          canCollectPayment: canCollectPayment,
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  void wide(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // The borrower pays from their own contact; the most anyone else can do is
  // prompt them to.
  testWidgets('no one is offered to record a payment by hand', (tester) async {
    wide(tester);
    await tester.pumpWidget(_host(canCollectPayment: true));
    await tester.pumpAndSettle();

    expect(find.text('Record Payment'), findsNothing);
    expect(find.text('Collect Payment'), findsOneWidget);
  });

  testWidgets('Collect Payment needs collection_manage', (tester) async {
    wide(tester);
    await tester.pumpWidget(_host(canCollectPayment: false));
    await tester.pumpAndSettle();

    expect(find.text('Collect Payment'), findsNothing);
  });

  test('channel labels cover only payments the borrower makes', () {
    expect(repaymentChannelLabel(kRepaymentChannelMobileMoney), 'Mobile money');
    expect(repaymentChannelLabel('cash'), 'cash');
  });
}
