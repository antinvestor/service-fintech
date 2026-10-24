import 'dart:typed_data';

import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/file_saver.dart';
import 'loans_transport_provider.dart';

/// Default name when the server does not supply one.
const defaultLoanBookFilename = 'loan_book.csv';

/// State of the loan-book export action.
sealed class LoanBookExportState {
  const LoanBookExportState();
}

class LoanBookExportIdle extends LoanBookExportState {
  const LoanBookExportIdle();
}

class LoanBookExportInProgress extends LoanBookExportState {
  const LoanBookExportInProgress();
}

class LoanBookExportDone extends LoanBookExportState {
  const LoanBookExportDone({required this.filename, required this.byteCount});

  final String filename;
  final int byteCount;
}

class LoanBookExportFailed extends LoanBookExportState {
  const LoanBookExportFailed(this.message);

  final String message;
}

/// The [FileSaver] the export hands its bytes to. Overridden in tests.
final fileSaverProvider = Provider<FileSaver>(
  (ref) => const PlatformFileSaver(),
);

/// Issues the export RPC. The generated client is an extension type over the
/// transport and cannot be substituted, so the call is exposed as a function
/// that tests override.
typedef LoanBookExporter =
    Future<PortfolioExportResponse> Function(PortfolioExportRequest request);

final loanBookExporterProvider = Provider<LoanBookExporter>((ref) {
  final client = ref.watch(loanManagementServiceClientProvider);
  return (request) => client.portfolioExport(request);
});

/// Runs the export RPC and delivers the file. A user action, so it is a
/// notifier rather than a cached future: a failed attempt is never retained
/// and the next tap issues a fresh request.
class LoanBookExportController extends Notifier<LoanBookExportState> {
  @override
  LoanBookExportState build() => const LoanBookExportIdle();

  Future<void> export({PortfolioExportRequest? request}) async {
    if (state is LoanBookExportInProgress) return;
    state = const LoanBookExportInProgress();

    try {
      final response = await ref.read(loanBookExporterProvider)(
        request ?? PortfolioExportRequest(format: 'CSV'),
      );
      final filename = response.filename.isEmpty
          ? defaultLoanBookFilename
          : response.filename;
      final contentType = response.contentType.isEmpty
          ? 'text/csv'
          : response.contentType;

      await ref
          .read(fileSaverProvider)
          .save(
            bytes: Uint8List.fromList(response.data),
            filename: filename,
            contentType: contentType,
          );

      if (!ref.mounted) return;
      state = LoanBookExportDone(
        filename: filename,
        byteCount: response.data.length,
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = LoanBookExportFailed(_describe(error));
    }
  }

  void reset() => state = const LoanBookExportIdle();

  static String _describe(Object error) => switch (error) {
    ConnectException(:final message) when message.isNotEmpty => message,
    _ => error.toString(),
  };
}

final loanBookExportControllerProvider =
    NotifierProvider<LoanBookExportController, LoanBookExportState>(
      LoanBookExportController.new,
    );
