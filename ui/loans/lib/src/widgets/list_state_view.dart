import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders a list screen's loading and error states, and hands the loaded page
/// to [builder] otherwise.
///
/// Collapsing an error into an empty list tells the user their loan book is
/// empty when in fact the request failed — and offers them no way to retry.
/// Failure and emptiness read differently here.
class ListStateView<T> extends StatelessWidget {
  const ListStateView({
    super.key,
    required this.title,
    required this.value,
    required this.onRetry,
    required this.builder,
  });

  /// Page title, kept on screen while loading or after a failure so the user
  /// knows where they are.
  final String title;
  final AsyncValue<PagedResult<T>> value;
  final VoidCallback onRetry;
  final Widget Function(PagedResult<T> page) builder;

  @override
  Widget build(BuildContext context) {
    final page = value.value;
    if (page != null) {
      return builder(page);
    }

    if (value.hasError) {
      return _ListErrorState(
        title: title,
        message: friendlyError(value.error!),
        onRetry: onRetry,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ListErrorState extends StatelessWidget {
  const _ListErrorState({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
