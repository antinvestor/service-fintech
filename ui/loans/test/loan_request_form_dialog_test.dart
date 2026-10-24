import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingLoanRequestNotifier extends LoanRequestNotifier {
  _RecordingLoanRequestNotifier(this.saved, {this.failFirst = false});

  final List<LoanRequestObject> saved;
  final bool failFirst;

  @override
  Future<LoanRequestObject> save(LoanRequestObject request) async {
    saved.add(request);
    if (failFirst && saved.length == 1) {
      throw Exception('gateway timeout');
    }
    return request.deepCopy()..id = 'req-${saved.length}';
  }
}

Money _kes(int units) =>
    Money(currencyCode: 'KES', units: Int64(units), nanos: 0);

Widget _host(List<LoanRequestObject> saved, {bool failFirst = false}) {
  return ProviderScope(
    overrides: [
      loanProductListProvider.overrideWith(
        (ref, params) async => PagedResult(
          items: [
            LoanProductObject(
              id: 'prod-1',
              organizationId: 'org-1',
              name: 'Boda Boost',
              currencyCode: 'KES',
              minAmount: _kes(1000),
              maxAmount: _kes(50000),
              minTermDays: 7,
              maxTermDays: 90,
            ),
          ],
          hasMore: false,
        ),
      ),
      loanRequestNotifierProvider.overrideWith(
        () => _RecordingLoanRequestNotifier(saved, failFirst: failFirst),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () => showDialog<LoanRequestObject>(
                context: context,
                builder: (_) => const LoanRequestFormDialog(),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _fill(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('loan-request-product')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Boda Boost').last);
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(const Key('loan-request-client')), 'c-9');
  await tester.enterText(
    find.byKey(const Key('loan-request-amount')),
    '2500.50',
  );
  await tester.enterText(find.byKey(const Key('loan-request-term')), '30');
  await tester.enterText(
    find.byKey(const Key('loan-request-purpose')),
    'Stock',
  );
}

void main() {
  testWidgets('submits a SUBMITTED request with the product currency', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final saved = <LoanRequestObject>[];
    await tester.pumpWidget(_host(saved));
    await _fill(tester);

    await tester.tap(find.byKey(const Key('loan-request-submit')));
    await tester.pumpAndSettle();

    expect(saved, hasLength(1));
    final request = saved.single;
    expect(request.productId, 'prod-1');
    expect(request.clientId, 'c-9');
    expect(request.organizationId, 'org-1');
    expect(request.status, LoanRequestStatus.LOAN_REQUEST_STATUS_SUBMITTED);
    expect(request.requestedAmount.currencyCode, 'KES');
    expect(request.requestedAmount.units.toInt(), 2500);
    expect(request.requestedAmount.nanos, 500000000);
    expect(request.requestedTermDays, 30);
    expect(request.purpose, 'Stock');
    expect(request.idempotencyKey, hasLength(32));
    expect(find.byType(LoanRequestFormDialog), findsNothing);
  });

  testWidgets('a retry after a failure reuses the same idempotency key', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final saved = <LoanRequestObject>[];
    await tester.pumpWidget(_host(saved, failFirst: true));
    await _fill(tester);

    await tester.tap(find.byKey(const Key('loan-request-submit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('loan-request-error')), findsOneWidget);
    expect(find.byType(LoanRequestFormDialog), findsOneWidget);

    await tester.tap(find.byKey(const Key('loan-request-submit')));
    await tester.pumpAndSettle();

    expect(saved, hasLength(2));
    expect(saved[0].idempotencyKey, saved[1].idempotencyKey);
    expect(find.byType(LoanRequestFormDialog), findsNothing);
  });

  testWidgets('rejects a term outside the product range', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final saved = <LoanRequestObject>[];
    await tester.pumpWidget(_host(saved));
    await _fill(tester);
    await tester.enterText(find.byKey(const Key('loan-request-term')), '120');

    await tester.tap(find.byKey(const Key('loan-request-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Maximum term is 90 days'), findsOneWidget);
    expect(saved, isEmpty);
  });
}
