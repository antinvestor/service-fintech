import 'dart:convert';
import 'dart:typed_data';

import 'package:antinvestor_api_funding/antinvestor_api_funding.dart';
import 'package:antinvestor_api_funding/src/common/v1/money.pb.dart' as money;
import 'package:antinvestor_ui_funding/antinvestor_ui_funding.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

money.Money _kes(int units) =>
    money.Money(currencyCode: 'KES', units: Int64(units));

InvestorStatementResponse _statement() => InvestorStatementResponse(
  entries: [
    InvestorStatementEntry(
      occurredAt: '2026-10-01T09:00:00Z',
      type: InvestorStatementEntryType.INVESTOR_STATEMENT_ENTRY_TYPE_DEPOSIT,
      amount: _kes(1000),
      reference: 'mv-1',
    ),
    InvestorStatementEntry(
      occurredAt: '2026-10-05T09:00:00Z',
      type: InvestorStatementEntryType
          .INVESTOR_STATEMENT_ENTRY_TYPE_INTEREST_EARNED,
      amount: _kes(72),
      interestGross: _kes(90),
      platformFee: _kes(5),
      withholdingTax: _kes(13),
      loanRequestId: 'lr-1',
      reference: 'repayment:r1',
    ),
  ],
  totals: InvestorStatementTotals(
    deposits: _kes(1000),
    interestEarned: _kes(72),
  ),
);

class _RecordingSaver implements FileSaver {
  String? filename;
  String? body;

  @override
  Future<void> save({
    required Uint8List bytes,
    required String filename,
    required String contentType,
  }) async {
    this.filename = filename;
    body = utf8.decode(bytes);
  }
}

void main() {
  test('a statement exports one row per entry and its totals', () {
    final csv = statementCsv(_statement());
    final lines = csv.trim().split('\n');
    expect(lines.first, startsWith('Date,Type,Amount'));
    expect(lines[1], contains('Deposit'));
    expect(lines[2], contains('Interest earned (net)'));
    expect(lines[2], contains('lr-1'));
    expect(csv, contains('Totals'));
  });

  test('last month runs from its first day to the first of this month', () {
    final (from, to) = statementRangePeriod(
      StatementRange.lastMonth,
      DateTime(2026, 1, 15),
    );
    expect(from, DateTime(2025, 12));
    expect(to, DateTime(2026, 1));
  });

  testWidgets('the statement shows its entries and downloads as CSV', (
    tester,
  ) async {
    final saver = _RecordingSaver();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          investorStatementProvider.overrideWith(
            (ref, period) async => _statement(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: InvestorStatementCard(
                accountId: 'acc-1',
                fileSaver: saver,
                clock: () => DateTime(2026, 10, 20),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Deposit'), findsOneWidget);
    expect(find.text('Interest earned (net)'), findsWidgets);

    await tester.tap(find.byKey(const Key('statement-download')));
    await tester.pumpAndSettle();
    expect(saver.filename, 'statement-acc-1-2026-09-21.csv');
    expect(saver.body, contains('repayment:r1'));
  });
}
