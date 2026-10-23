import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/page_header.dart';
import 'package:flutter/material.dart';

/// Full page error state with a retry action.
///
/// List screens must never render a failed load as an empty table: an expired
/// session and "no records" look identical that way.
class ListErrorView extends StatelessWidget {
  const ListErrorView({
    super.key,
    required this.title,
    required this.breadcrumbs,
    required this.error,
    required this.onRetry,
  });

  final String title;
  final List<String> breadcrumbs;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: title, breadcrumbs: breadcrumbs),
          const SizedBox(height: 32),
          Center(
            child: Column(
              key: const Key('list-error-view'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 40,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  friendlyError(error),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full page loading state shown while a list has no data to display yet.
class ListLoadingView extends StatelessWidget {
  const ListLoadingView({
    super.key,
    required this.title,
    required this.breadcrumbs,
  });

  final String title;
  final List<String> breadcrumbs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: title, breadcrumbs: breadcrumbs),
          const SizedBox(height: 32),
          const Center(
            child: CircularProgressIndicator(key: Key('list-loading-view')),
          ),
        ],
      ),
    );
  }
}

/// Compact error state with a retry action, for detail screens that render
/// inside an already-headed shell.
class DetailErrorView extends StatelessWidget {
  const DetailErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        key: const Key('detail-error-view'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            friendlyError(error),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
