import 'package:flutter/material.dart';

/// The page size a loan list starts at, and the step it grows by.
const kLoanListPageSize = 50;

/// Header action that reveals the rest of a truncated list.
///
/// The list screens read a fixed number of rows, so without this a user who
/// scrolls to the bottom has no way to tell whether they are looking at the
/// whole book or only the first page of it.
class LoadMoreAction extends StatelessWidget {
  const LoadMoreAction({
    super.key,
    required this.loadedCount,
    required this.hasMore,
    required this.isLoading,
    required this.onLoadMore,
  });

  /// How many rows are currently displayed.
  final int loadedCount;

  /// Whether the service had more rows than were asked for.
  final bool hasMore;

  /// Whether the next page is on its way.
  final bool isLoading;

  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Shrinks on a narrow screen rather than pushing the button off.
        Flexible(
          child: Text(
            'Showing first $loadedCount',
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
