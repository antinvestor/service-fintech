import 'package:antinvestor_api_operations/antinvestor_api_operations.dart';
import 'package:antinvestor_ui_operations/antinvestor_ui_operations.dart';
import 'package:connectrpc/connect.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeIncomingPaymentList extends IncomingPaymentList {
  _FakeIncomingPaymentList(super.filter, this._page);

  final IncomingPaymentPage _page;

  @override
  Future<IncomingPaymentPage> build() async => _page;
}

/// Records the assign request instead of sending it.
class _RecordingTransport implements Transport {
  Object? assigned;

  @override
  Future<UnaryResponse<I, O>> unary<I extends Object, O extends Object>(
    Spec<I, O> spec,
    I input, [
    CallOptions? options,
  ]) async {
    assigned = input;
    return UnaryResponse(
      spec,
      Headers(),
      IncomingPaymentAssignResponse() as O,
      Headers(),
    );
  }

  @override
  Future<StreamResponse<I, O>> stream<I extends Object, O extends Object>(
    Spec<I, O> spec,
    Stream<I> input, [
    CallOptions? options,
  ]) async {
    throw ConnectException(Code.unavailable, 'offline');
  }
}

IncomingPaymentObject _payment({required bool matched}) =>
    IncomingPaymentObject(
      id: 'pay-1',
      transactionId: 'MPESA123',
      amount: Money(currencyCode: 'UGX', units: Int64(30000)),
      unallocated: Money(
        currencyCode: 'UGX',
        units: Int64(matched ? 0 : 30000),
      ),
      payerName: 'Jane Borrower',
      reference: 'my loan',
      matched: matched,
    );

Widget _harness({
  required List<IncomingPaymentObject> payments,
  required bool canAssign,
  Transport? transport,
}) {
  const filter = (query: '', unmatchedOnly: true);
  return ProviderScope(
    overrides: [
      incomingPaymentListProvider(filter).overrideWith(
        () => _FakeIncomingPaymentList(
          filter,
          IncomingPaymentPage(payments: payments, hasMore: false),
        ),
      ),
      if (transport != null)
        operationsServiceClientProvider.overrideWithValue(
          OperationsServiceClient(transport),
        ),
    ],
    child: MaterialApp(
      home: Scaffold(body: IncomingPaymentsScreen(canAssign: canAssign)),
    ),
  );
}

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(1600, 1200);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('an unmatched payment offers Assign only with payment_allocate', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(payments: [_payment(matched: false)], canAssign: false),
    );
    await tester.pumpAndSettle();
    expect(find.text('Unmatched'), findsOneWidget);
    expect(
      find.byKey(const Key('incoming-payment-assign-pay-1')),
      findsNothing,
    );

    await tester.pumpWidget(
      _harness(payments: [_payment(matched: false)], canAssign: true),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('incoming-payment-assign-pay-1')),
      findsOneWidget,
    );
  });

  testWidgets('a fully allocated payment offers no action', (tester) async {
    await tester.pumpWidget(
      _harness(payments: [_payment(matched: true)], canAssign: true),
    );
    await tester.pumpAndSettle();
    expect(find.text('Matched'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget); // Refresh only
    expect(
      find.byKey(const Key('incoming-payment-allocate-pay-1')),
      findsNothing,
    );
  });

  testWidgets('assigning names the loan and a note, never an amount', (
    tester,
  ) async {
    final transport = _RecordingTransport();
    await tester.pumpWidget(
      _harness(
        payments: [_payment(matched: false)],
        canAssign: true,
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('incoming-payment-assign-pay-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('assign-payment-loan')), findsOneWidget);
    expect(find.byKey(const Key('assign-payment-note')), findsOneWidget);
    expect(find.textContaining('Amount'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('assign-payment-loan')),
      'loan-1',
    );
    await tester.tap(find.byKey(const Key('assign-payment-submit')));
    await tester.pumpAndSettle();
    expect(find.text('A note is required'), findsOneWidget);
    expect(transport.assigned, isNull);

    await tester.enterText(
      find.byKey(const Key('assign-payment-note')),
      'payer confirmed by phone',
    );
    await tester.tap(find.byKey(const Key('assign-payment-submit')));
    await tester.pumpAndSettle();
    final sent = transport.assigned! as IncomingPaymentAssignRequest;
    expect(sent.paymentId, 'pay-1');
    expect(sent.loanAccountId, 'loan-1');
    expect(sent.savingsAccountId, isEmpty);
    expect(sent.note, 'payer confirmed by phone');
  });

  testWidgets('a payment can be assigned to a savings account instead', (
    tester,
  ) async {
    final transport = _RecordingTransport();
    await tester.pumpWidget(
      _harness(
        payments: [_payment(matched: false)],
        canAssign: true,
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('incoming-payment-assign-pay-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Savings'));
    await tester.pumpAndSettle();
    expect(find.text('Savings account ID'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('assign-payment-loan')),
      'sav-1',
    );
    await tester.enterText(
      find.byKey(const Key('assign-payment-note')),
      'saver quoted their old number',
    );
    await tester.tap(find.byKey(const Key('assign-payment-submit')));
    await tester.pumpAndSettle();
    final sent = transport.assigned! as IncomingPaymentAssignRequest;
    expect(sent.savingsAccountId, 'sav-1');
    expect(sent.loanAccountId, isEmpty);
  });
}
