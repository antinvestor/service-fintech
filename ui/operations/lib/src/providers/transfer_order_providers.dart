import 'package:antinvestor_api_operations/antinvestor_api_operations.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'operations_transport_provider.dart';

/// Page size for the transfer order list. The backend clamps a caller-supplied
/// limit to 200, so anything larger would be silently truncated.
const int transferOrderPageSize = 50;

/// Filters the transfer order list is scoped by.
typedef TransferOrderFilter = ({String query, int? orderType});

/// A page of transfer orders plus whether more may follow.
class TransferOrderPage {
  const TransferOrderPage({required this.orders, required this.hasMore});

  final List<TransferOrderObject> orders;

  /// True while the last fetch filled a whole page, so another one may exist.
  final bool hasMore;
}

/// Paginated transfer order list.
///
/// The first page is loaded by the provider; [loadMore] appends subsequent
/// pages through a direct client call so a failure mid-scroll never replaces
/// the rows already on screen with an error state.
class TransferOrderList extends AsyncNotifier<TransferOrderPage> {
  TransferOrderList(this.filter);

  /// Query and order type this list is scoped by.
  final TransferOrderFilter filter;

  bool _loadingMore = false;

  @override
  Future<TransferOrderPage> build() async {
    final orders = await _fetchPage(offset: 0);
    return TransferOrderPage(
      orders: orders,
      hasMore: orders.length >= transferOrderPageSize,
    );
  }

  Future<List<TransferOrderObject>> _fetchPage({required int offset}) {
    final client = ref.read(operationsServiceClientProvider);
    final request = TransferOrderSearchRequest(
      cursor: PageCursor(limit: transferOrderPageSize, page: '$offset'),
    );
    if (filter.query.isNotEmpty) {
      request.query = filter.query;
    }
    if (filter.orderType != null) {
      // The integer field stays until the operations service consumes the
      // enum from the published SDK; both carry the same value.
      // ignore: deprecated_member_use
      request.orderType = filter.orderType!;
      request.transferType =
          TransferOrderType.valueOf(filter.orderType!) ??
          TransferOrderType.TRANSFER_ORDER_TYPE_UNSPECIFIED;
    }

    return collectStream(
      client.transferOrderSearch(request),
      extract: (response) => response.data,
    );
  }

  /// Whether a load-more request is currently in flight.
  bool get isLoadingMore => _loadingMore;

  /// Appends the next page. Safe to call repeatedly: overlapping calls and
  /// calls made once the end has been reached are ignored.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || _loadingMore) {
      return;
    }

    _loadingMore = true;
    try {
      final next = await _fetchPage(offset: current.orders.length);
      state = AsyncData(
        TransferOrderPage(
          orders: [...current.orders, ...next],
          hasMore: next.length >= transferOrderPageSize,
        ),
      );
    } finally {
      _loadingMore = false;
    }
  }
}

/// List transfer orders, optionally filtered by query and order type.
final transferOrderListProvider =
    AsyncNotifierProvider.family<
      TransferOrderList,
      TransferOrderPage,
      TransferOrderFilter
    >(TransferOrderList.new);
