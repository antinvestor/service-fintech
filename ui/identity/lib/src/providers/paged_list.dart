import 'package:flutter/foundation.dart' show immutable, protected;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/load_more_action.dart';

/// The rows loaded so far from a cursor-paged list RPC, and where the next
/// page starts.
@immutable
class PagedList<T> {
  const PagedList({
    required this.items,
    required this.nextPage,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<T> items;

  /// Offset the next page starts at, or null once a short page proved the
  /// list is exhausted.
  final int? nextPage;

  /// Whether a further page is currently being appended.
  final bool isLoadingMore;

  /// The failure of the last append, if it failed. The rows already loaded
  /// stay on screen; the user can retry.
  final Object? loadMoreError;

  bool get hasMore => nextPage != null;

  PagedList<T> copyWith({
    List<T>? items,
    int? nextPage,
    bool clearNextPage = false,
    bool? isLoadingMore,
    Object? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return PagedList<T>(
      items: items ?? this.items,
      nextPage: clearNextPage ? null : (nextPage ?? this.nextPage),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: clearLoadMoreError
          ? null
          : (loadMoreError ?? this.loadMoreError),
    );
  }
}

/// Reads a list one page at a time through the server's offset cursor.
///
/// The first page is the notifier's initial state; [loadMore] appends the
/// next one. A page shorter than [pageSize] marks the list as exhausted,
/// which is also how a failed or empty append leaves the loaded rows intact.
abstract class PagedListNotifier<T> extends AsyncNotifier<PagedList<T>> {
  /// Rows requested per page. The server clamps at 200; 50 keeps each append
  /// to one streamed batch.
  int get pageSize => kIdentityListPageSize;

  /// Reads the page starting at [offset]. Implementations pass the offset as
  /// `PageCursor.page` and [limit] as `PageCursor.limit`.
  @protected
  Future<List<T>> fetchPage(int offset, int limit);

  @override
  Future<PagedList<T>> build() => _loadFrom(0, const []);

  Future<PagedList<T>> _loadFrom(int offset, List<T> loaded) async {
    final page = await fetchPage(offset, pageSize);
    final exhausted = page.length < pageSize;
    return PagedList<T>(
      items: List.unmodifiable([...loaded, ...page]),
      nextPage: exhausted ? null : offset + page.length,
    );
  }

  /// Appends the next page. A no-op while the first page is loading, while an
  /// append is in flight, or once the list is exhausted.
  Future<void> loadMore() async {
    final current = state.value;
    final next = current?.nextPage;
    if (current == null || next == null || current.isLoadingMore) return;

    state = AsyncData(
      current.copyWith(isLoadingMore: true, clearLoadMoreError: true),
    );
    try {
      final grown = await _loadFrom(next, current.items);
      if (!ref.mounted) return;
      state = AsyncData(grown);
    } catch (e) {
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreError: e),
      );
    }
  }
}
