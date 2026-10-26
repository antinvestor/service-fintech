import 'package:antinvestor_api_operations/antinvestor_api_operations.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'operations_transport_provider.dart';

/// Page size for the incoming payment list; the backend clamps at 200.
const int incomingPaymentPageSize = 50;

/// Filters the incoming payment list is scoped by.
typedef IncomingPaymentFilter = ({String query, bool unmatchedOnly});

/// A page of incoming payments plus whether more may follow.
class IncomingPaymentPage {
  const IncomingPaymentPage({required this.payments, required this.hasMore});

  final List<IncomingPaymentObject> payments;
  final bool hasMore;
}

/// Paginated list of payments the rail received, newest first.
///
/// [loadMore] appends through a direct client call so a failure mid-scroll
/// never replaces the rows already on screen.
class IncomingPaymentList extends AsyncNotifier<IncomingPaymentPage> {
  IncomingPaymentList(this.filter);

  final IncomingPaymentFilter filter;

  bool _loadingMore = false;

  @override
  Future<IncomingPaymentPage> build() async {
    final payments = await _fetchPage(offset: 0);
    return IncomingPaymentPage(
      payments: payments,
      hasMore: payments.length >= incomingPaymentPageSize,
    );
  }

  Future<List<IncomingPaymentObject>> _fetchPage({required int offset}) {
    final client = ref.read(operationsServiceClientProvider);
    return collectStream(
      client.incomingPaymentSearch(
        IncomingPaymentSearchRequest(
          query: filter.query,
          unmatchedOnly: filter.unmatchedOnly,
          cursor: PageCursor(limit: incomingPaymentPageSize, page: '$offset'),
        ),
      ),
      extract: (response) => response.data,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || _loadingMore) return;
    _loadingMore = true;
    try {
      final next = await _fetchPage(offset: current.payments.length);
      state = AsyncData(
        IncomingPaymentPage(
          payments: [...current.payments, ...next],
          hasMore: next.length >= incomingPaymentPageSize,
        ),
      );
    } finally {
      _loadingMore = false;
    }
  }
}

final incomingPaymentListProvider =
    AsyncNotifierProvider.family<
      IncomingPaymentList,
      IncomingPaymentPage,
      IncomingPaymentFilter
    >(IncomingPaymentList.new);

/// Ties an unmatched payment to its loan. A direct client call: the result
/// of a person's action is never cached, so a refusal can be retried.
Future<IncomingPaymentAssignResponse> assignIncomingPayment(
  OperationsServiceClient client, {
  required String paymentId,
  required String loanAccountId,
  required String note,
}) {
  return client.incomingPaymentAssign(
    IncomingPaymentAssignRequest(
      paymentId: paymentId,
      loanAccountId: loanAccountId,
      note: note,
    ),
  );
}

/// Re-runs allocation for a matched payment whose allocation did not finish.
Future<PaymentAllocateResponse> allocateIncomingPayment(
  OperationsServiceClient client, {
  required String paymentId,
}) {
  return client.paymentAllocate(PaymentAllocateRequest(paymentId: paymentId));
}
