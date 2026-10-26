import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Money _kes(int units) =>
    Money(currencyCode: 'KES', units: Int64(units), nanos: 0);

Widget _host({
  required bool canCollectPayment,
  bool canDisburse = false,
  LoanStatus status = LoanStatus.LOAN_STATUS_ACTIVE,
  String paymentAccountRef = '',
}) {
  return ProviderScope(
    overrides: [
      loanAccountDetailProvider.overrideWith(
        (ref, id) async => LoanAccountObject(
          id: id,
          clientId: 'client-1',
          status: status,
          paymentAccountRef: paymentAccountRef,
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
          canDisburse: canDisburse,
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

  // Staff confirm a disbursement; where the money goes is the borrower's own
  // payout contact on the loan, never something typed.
  testWidgets('disbursing asks nothing about where the money goes', (
    tester,
  ) async {
    wide(tester);
    await tester.pumpWidget(
      _host(
        canCollectPayment: false,
        canDisburse: true,
        status: LoanStatus.LOAN_STATUS_PENDING_DISBURSEMENT,
        paymentAccountRef: 'contact-1',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disburse'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNothing);
    expect(find.textContaining('Recipient'), findsNothing);
    final confirm = tester.widget<FilledButton>(
      find.byKey(const Key('disburse-confirm')),
    );
    expect(confirm.onPressed, isNotNull);
  });

  testWidgets('a loan without a payout contact cannot be disbursed', (
    tester,
  ) async {
    wide(tester);
    await tester.pumpWidget(
      _host(
        canCollectPayment: false,
        canDisburse: true,
        status: LoanStatus.LOAN_STATUS_PENDING_DISBURSEMENT,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disburse'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('disburse-no-destination')), findsOneWidget);
    final confirm = tester.widget<FilledButton>(
      find.byKey(const Key('disburse-confirm')),
    );
    expect(confirm.onPressed, isNull);
  });
}
