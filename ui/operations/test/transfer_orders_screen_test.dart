import 'package:antinvestor_api_operations/antinvestor_api_operations.dart';
import 'package:antinvestor_ui_operations/antinvestor_ui_operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A list notifier that serves a canned page without touching the network.
class _FakeTransferOrderList extends TransferOrderList {
  _FakeTransferOrderList(super.filter, this._page);

  final TransferOrderPage _page;

  @override
  Future<TransferOrderPage> build() async => _page;
}

TransferOrderObject _order({required int orderType}) {
  return TransferOrderObject(
    id: 'to-1',
    // Servers before the SDK bump populate only the integer field.
    // ignore: deprecated_member_use
    orderType: orderType,
    debitAccountRef: 'debit-1',
    creditAccountRef: 'credit-1',
    reference: 'ref-1',
  );
}

Widget _harness(TransferOrderPage page) {
  const filter = (query: '', orderType: null);
  return ProviderScope(
    overrides: [
      transferOrderListProvider(
        filter,
      ).overrideWith(() => _FakeTransferOrderList(filter, page)),
    ],
    child: const MaterialApp(home: Scaffold(body: TransferOrdersScreen())),
  );
}

void main() {
  // The operations screens target a desktop console; give the test surface a
  // realistic width so the filter row is not artificially overflowed.
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

  testWidgets('renders the backend label for a loan repayment order', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        TransferOrderPage(orders: [_order(orderType: 42)], hasMore: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Loan Repayment'), findsOneWidget);
    expect(find.text('Repayment'), findsNothing);
  });

  testWidgets('shows an empty state when there are no orders', (tester) async {
    await tester.pumpWidget(
      _harness(const TransferOrderPage(orders: [], hasMore: false)),
    );
    await tester.pumpAndSettle();

    expect(find.text('No transfer orders found'), findsOneWidget);
  });

  testWidgets('offers a load-more control when another page may follow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        TransferOrderPage(orders: [_order(orderType: 6)], hasMore: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Load more'), findsOneWidget);
  });
}
