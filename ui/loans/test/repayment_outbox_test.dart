import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers RepaymentRecord with whatever [outcome] says next, and counts the
/// idempotency keys it was sent.
class _FakeTransport implements Transport {
  Object? Function()? outcome;
  final keys = <String>[];

  @override
  Future<UnaryResponse<I, O>> unary<I extends Object, O extends Object>(
    Spec<I, O> spec,
    I input, [
    CallOptions? options,
  ]) async {
    keys.add((input as RepaymentRecordRequest).idempotencyKey);
    final result = outcome?.call();
    if (result is Exception) throw result;
    return UnaryResponse(
      spec,
      Headers(),
      RepaymentRecordResponse(data: RepaymentObject(id: 'rep-1')) as O,
      Headers(),
    );
  }

  @override
  Future<StreamResponse<I, O>> stream<I extends Object, O extends Object>(
    Spec<I, O> spec,
    Stream<I> input, [
    CallOptions? options,
  ]) => throw UnimplementedError();
}

ProviderContainer _container(_FakeTransport transport) => ProviderContainer(
  overrides: [loansTransportProvider.overrideWithValue(transport)],
);

Future<RepaymentObject?> _record(ProviderContainer c) => c
    .read(repaymentNotifierProvider.notifier)
    .record(
      loanAccountId: 'loan-1',
      amount: '500',
      currencyCode: 'KES',
      paymentReference: 'cash-1',
      channel: kRepaymentChannelCash,
      payerReference: '',
      idempotencyKey: 'key-1',
    );

void main() {
  test('a repayment that cannot reach the service is queued, then sent '
      'once with the same key', () async {
    final transport = _FakeTransport()
      ..outcome = () => ConnectException(Code.unavailable, 'offline');
    final c = _container(transport);
    addTearDown(c.dispose);

    expect(await _record(c), isNull, reason: 'queued, not failed');
    expect(await c.read(repaymentOutboxProvider.future), hasLength(1));

    // Still offline: nothing is lost.
    expect(await c.read(repaymentOutboxProvider.notifier).flush(), 0);
    expect(await c.read(repaymentOutboxProvider.future), hasLength(1));

    transport.outcome = null;
    expect(await c.read(repaymentOutboxProvider.notifier).flush(), 1);
    expect(await c.read(repaymentOutboxProvider.future), isEmpty);
    expect(transport.keys.toSet(), {
      'key-1',
    }, reason: 'every attempt reuses the key');
  });

  test('a refusal is shown at once and never queued', () async {
    final transport = _FakeTransport()
      ..outcome = () =>
          ConnectException(Code.permissionDenied, 'agents record cash only');
    final c = _container(transport);
    addTearDown(c.dispose);

    await expectLater(_record(c), throwsA(isA<ConnectException>()));
    expect(await c.read(repaymentOutboxProvider.future), isEmpty);
  });

  test('a queued repayment the service later refuses stays marked', () async {
    final transport = _FakeTransport()
      ..outcome = () => ConnectException(Code.unavailable, 'offline');
    final c = _container(transport);
    addTearDown(c.dispose);
    await _record(c);

    transport.outcome = () =>
        ConnectException(Code.failedPrecondition, 'loan is closed');
    expect(await c.read(repaymentOutboxProvider.notifier).flush(), 0);
    final items = await c.read(repaymentOutboxProvider.future);
    expect(items.single.rejected, isTrue);
    expect(items.single.rejection, 'loan is closed');

    await c.read(repaymentOutboxProvider.notifier).dismiss('key-1');
    expect(await c.read(repaymentOutboxProvider.future), isEmpty);
  });
}
