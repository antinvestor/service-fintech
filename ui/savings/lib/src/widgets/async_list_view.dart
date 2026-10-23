import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders the three states a remote list can be in, distinctly.
///
/// Collapsing an [AsyncValue] to an empty list hides the difference between
/// "the server said there is nothing", "we are still asking" and "the request
/// failed", which is how a permanently blank table ends up looking like a
/// legitimately empty one. This widget keeps them apart and always offers a
/// way back from a failure.
class AsyncListView<T> extends StatelessWidget {
  const AsyncListView({
    super.key,
    required this.value,
    required this.builder,
    required this.onRetry,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage = 'No records match the current filters.',
  });

  final AsyncValue<List<T>> value;
  final Widget Function(List<T> items) builder;
  final VoidCallback onRetry;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(
        key: Key('async-list-loading'),
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => _AsyncListError(error: error, onRetry: onRetry),
      data: (items) {
        if (items.isEmpty) {
          return _AsyncListEmpty(title: emptyTitle, message: emptyMessage);
        }
        return builder(items);
      },
    );
  }
}

class _AsyncListError extends StatelessWidget {
  const _AsyncListError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      key: const Key('async-list-error'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 36),
            const SizedBox(height: 12),
            Text(
              'Could not load this list',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('async-list-retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AsyncListEmpty extends StatelessWidget {
  const _AsyncListEmpty({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      key: const Key('async-list-empty'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 36,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
