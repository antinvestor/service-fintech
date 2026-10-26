import 'package:flutter/material.dart';

/// The page size an identity list starts at, and the step it grows by. The
/// server clamps a single page at 200, so growth happens through the cursor,
/// never by asking for a larger page.
const kIdentityListPageSize = 50;

/// Header action that reveals the next page of a cursor-paged list.
///
/// Without it a user who reaches the bottom of a table cannot tell whether
/// they are looking at the whole set or only its first page.
class LoadMoreAction extends StatelessWidget {
  const LoadMoreAction({
    super.key,
    required this.loadedCount,
    required this.hasMore,
    required this.isLoading,
    required this.onLoadMore,
    this.errorMessage,
  });

  /// How many rows are currently loaded.
  final int loadedCount;

  /// Whether the service may hold rows beyond the loaded ones.
  final bool hasMore;

  /// Whether the next page is on its way.
  final bool isLoading;

  /// Why the last page failed to load, if it did. The action stays enabled so
  /// the user can try again.
  final String? errorMessage;

  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Row(
      key: const Key('load-more-action'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Shrinks on a narrow screen rather than pushing the button off.
        Flexible(
          child: Text(
            errorMessage ?? 'Showing first $loadedCount',
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: errorMessage == null
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.error,
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: isLoading ? null : onLoadMore,
          icon: isLoading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.expand_more, size: 18),
          label: const Text('Load more'),
        ),
      ],
    );
  }
}
