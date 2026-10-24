import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/loan_book_export_provider.dart';

/// Exports the loan book as CSV and hands the file to the user.
///
/// Disabled while an export is running; reports completion and failure
/// through the nearest [ScaffoldMessenger].
class LoanBookExportButton extends ConsumerWidget {
  const LoanBookExportButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<LoanBookExportState>(loanBookExportControllerProvider, (
      previous,
      next,
    ) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      // Each outcome replaces the previous one rather than queueing behind
      // it, so a retry's result is visible immediately.
      switch (next) {
        case LoanBookExportDone(:final filename, :final byteCount):
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('Saved $filename ($byteCount bytes)')),
            );
        case LoanBookExportFailed(:final message):
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('Export failed: $message')));
        case LoanBookExportIdle():
        case LoanBookExportInProgress():
          break;
      }
    });

    final state = ref.watch(loanBookExportControllerProvider);
    final exporting = state is LoanBookExportInProgress;

    return FilledButton.icon(
      onPressed: exporting
          ? null
          : () => ref.read(loanBookExportControllerProvider.notifier).export(),
      icon: exporting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download),
      label: const Text('Export CSV'),
    );
  }
}
