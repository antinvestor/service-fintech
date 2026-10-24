import 'dart:async';
import 'dart:typed_data';

import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_loans/src/providers/loan_book_export_provider.dart';
import 'package:antinvestor_ui_loans/src/utils/file_saver.dart';
import 'package:antinvestor_ui_loans/src/widgets/loan_book_export_button.dart';
import 'package:connectrpc/connect.dart' as connect;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records export requests and answers them with the supplied handler.
class _FakeLoansClient {
  _FakeLoansClient(this.onExport);

  final Future<PortfolioExportResponse> Function(PortfolioExportRequest)
  onExport;
  final requests = <PortfolioExportRequest>[];

  Future<PortfolioExportResponse> call(PortfolioExportRequest request) {
    requests.add(request);
    return onExport(request);
  }
}

class _RecordingFileSaver implements FileSaver {
  _RecordingFileSaver({this.failWith});

  final Object? failWith;
  final saved = <({Uint8List bytes, String filename, String contentType})>[];

  @override
  Future<void> save({
    required Uint8List bytes,
    required String filename,
    required String contentType,
  }) async {
    if (failWith case final error?) throw error;
    saved.add((bytes: bytes, filename: filename, contentType: contentType));
  }
}

Widget _harness({required _FakeLoansClient client, required FileSaver saver}) {
  return ProviderScope(
    overrides: [
      loanBookExporterProvider.overrideWithValue(client.call),
      fileSaverProvider.overrideWithValue(saver),
    ],
    child: const MaterialApp(
      home: Scaffold(body: Center(child: LoanBookExportButton())),
    ),
  );
}

FilledButton _button(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton));

void main() {
  group('LoanBookExportButton', () {
    testWidgets('starts idle with an enabled export action', (tester) async {
      final client = _FakeLoansClient((_) async => PortfolioExportResponse());
      await tester.pumpWidget(
        _harness(client: client, saver: _RecordingFileSaver()),
      );

      expect(find.text('Export CSV'), findsOneWidget);
      expect(_button(tester).onPressed, isNotNull);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(client.requests, isEmpty);
    });

    testWidgets('disables itself and shows progress while exporting', (
      tester,
    ) async {
      final pending = Completer<PortfolioExportResponse>();
      final client = _FakeLoansClient((_) => pending.future);
      final saver = _RecordingFileSaver();
      await tester.pumpWidget(_harness(client: client, saver: saver));

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(_button(tester).onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(client.requests.single.format, 'CSV');

      // A second tap while running must not issue a second request.
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pump();
      expect(client.requests, hasLength(1));

      pending.complete(PortfolioExportResponse());
      await tester.pumpAndSettle();
    });

    testWidgets('hands the bytes to the file saver and reports completion', (
      tester,
    ) async {
      final client = _FakeLoansClient(
        (_) async => PortfolioExportResponse(
          data: [104, 105],
          filename: 'book-2026-09.csv',
          contentType: 'text/csv; charset=utf-8',
        ),
      );
      final saver = _RecordingFileSaver();
      await tester.pumpWidget(_harness(client: client, saver: saver));

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      final saved = saver.saved.single;
      expect(saved.filename, 'book-2026-09.csv');
      expect(saved.contentType, 'text/csv; charset=utf-8');
      expect(saved.bytes, Uint8List.fromList([104, 105]));

      expect(find.text('Saved book-2026-09.csv (2 bytes)'), findsOneWidget);
      expect(_button(tester).onPressed, isNotNull);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('falls back to a default filename and content type', (
      tester,
    ) async {
      final client = _FakeLoansClient(
        (_) async => PortfolioExportResponse(data: [1]),
      );
      final saver = _RecordingFileSaver();
      await tester.pumpWidget(_harness(client: client, saver: saver));

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(saver.saved.single.filename, defaultLoanBookFilename);
      expect(saver.saved.single.contentType, 'text/csv');
    });

    testWidgets('surfaces an RPC failure and allows a retry', (tester) async {
      var attempts = 0;
      final client = _FakeLoansClient((_) async {
        attempts++;
        if (attempts == 1) {
          throw connect.ConnectException(
            connect.Code.permissionDenied,
            'portfolio_export required',
          );
        }
        return PortfolioExportResponse(data: [1]);
      });
      final saver = _RecordingFileSaver();
      await tester.pumpWidget(_harness(client: client, saver: saver));

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Export failed: portfolio_export required'),
        findsOneWidget,
      );
      expect(saver.saved, isEmpty);
      expect(_button(tester).onPressed, isNotNull);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(saver.saved, hasLength(1));
      expect(find.textContaining('Saved '), findsOneWidget);
    });

    testWidgets('a failing file saver is reported as an export failure', (
      tester,
    ) async {
      final client = _FakeLoansClient(
        (_) async => PortfolioExportResponse(data: [1]),
      );
      final saver = _RecordingFileSaver(failWith: StateError('disk full'));
      await tester.pumpWidget(_harness(client: client, saver: saver));

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.textContaining('Export failed:'), findsOneWidget);
      expect(find.textContaining('disk full'), findsOneWidget);
      expect(_button(tester).onPressed, isNotNull);
    });
  });
}
