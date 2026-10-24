import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures what the Record Payment dialog sends instead of calling the
/// service.
class _RecordingRepaymentNotifier extends RepaymentNotifier {
  _RecordingRepaymentNotifier(this.calls);

  final List<({String channel, String idempotencyKey})> calls;

  @override
  Future<RepaymentObject> record({
    required String loanAccountId,
    required String amount,
    required String currencyCode,
    required String paymentReference,
    required String channel,
    required String payerReference,
    required String idempotencyKey,
  }) async {
    calls.add((channel: channel, idempotencyKey: idempotencyKey));
    return RepaymentObject(id: 'rep-1');
  }
}

Money _kes(int units) =>
    Money(currencyCode: 'KES', units: Int64(units), nanos: 0);

Widget _host({
  required bool canRecordPayment,
  required bool canCollectPayment,
  List<({String channel, String idempotencyKey})>? calls,
}) {
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
      if (calls != null)
        repaymentNotifierProvider.overrideWith(
          () => _RecordingRepaymentNotifier(calls),
        ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: LoanAccountDetailScreen(
          loanId: 'loan-1',
          canRecordPayment: canRecordPayment,
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

  testWidgets('Collect Payment is gated separately from Record Payment', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _host(canRecordPayment: true, canCollectPayment: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Record Payment'), findsOneWidget);
    expect(find.text('Collect Payment'), findsNothing);
  });

  testWidgets('Collect Payment appears with collection_manage alone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _host(canRecordPayment: false, canCollectPayment: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Record Payment'), findsNothing);
    expect(find.text('Collect Payment'), findsOneWidget);
  });

  testWidgets('Record Payment sends the chosen channel value and explains '
      'cash handling', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final calls = <({String channel, String idempotencyKey})>[];
    await tester.pumpWidget(
      _host(canRecordPayment: true, canCollectPayment: false, calls: calls),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Record Payment'));
    await tester.pumpAndSettle();

    // The channel is a fixed set of values, not free text.
    expect(find.byKey(const Key('record-payment-channel')), findsOneWidget);
    expect(find.byKey(const Key('record-payment-cash-note')), findsNothing);

    await tester.tap(find.byKey(const Key('record-payment-channel')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cash collected in the field').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('record-payment-cash-note')), findsOneWidget);
    expect(find.text(kCashCollectionNote), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '500');
    await tester.enterText(fields.at(1), 'RCPT-1');
    await tester.enterText(fields.at(2), '0700000000');
    await tester.tap(find.widgetWithText(FilledButton, 'Record'));
    await tester.pumpAndSettle();

    expect(calls, hasLength(1));
    expect(calls.single.channel, kRepaymentChannelCash);
    expect(calls.single.idempotencyKey, hasLength(32));
  });

  test('channel values are the lowercase wire values', () {
    expect(kRepaymentChannels, ['cash', 'mobile_money', 'bank', 'savings']);
    expect(
      repaymentChannelLabel(kRepaymentChannelCash),
      'Cash collected in the field',
    );
  });
}
