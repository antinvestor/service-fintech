import 'package:antinvestor_api_funding/antinvestor_api_funding.dart'
    hide PageCursor, STATE;

import 'money_display.dart';

/// The label a statement entry is shown and exported with.
String statementEntryLabel(InvestorStatementEntryType type) {
  switch (type) {
    case InvestorStatementEntryType.INVESTOR_STATEMENT_ENTRY_TYPE_DEPOSIT:
      return 'Deposit';
    case InvestorStatementEntryType.INVESTOR_STATEMENT_ENTRY_TYPE_WITHDRAWAL:
      return 'Withdrawal';
    case InvestorStatementEntryType.INVESTOR_STATEMENT_ENTRY_TYPE_DEPLOYMENT:
      return 'Lent to a loan';
    case InvestorStatementEntryType.INVESTOR_STATEMENT_ENTRY_TYPE_RELEASE:
      return 'Released (loan not disbursed)';
    case InvestorStatementEntryType
        .INVESTOR_STATEMENT_ENTRY_TYPE_PRINCIPAL_RETURNED:
      return 'Principal returned';
    case InvestorStatementEntryType
        .INVESTOR_STATEMENT_ENTRY_TYPE_INTEREST_EARNED:
      return 'Interest earned (net)';
    case InvestorStatementEntryType.INVESTOR_STATEMENT_ENTRY_TYPE_LOSS:
      return 'Loss on a written-off loan';
    case InvestorStatementEntryType.INVESTOR_STATEMENT_ENTRY_TYPE_RECOVERY:
      return 'Recovered after write-off';
    default:
      return 'Other';
  }
}

String _cell(String value) {
  if (value.contains(RegExp('[",\n]'))) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

/// Renders a statement as CSV: one row per entry, oldest first, then the
/// period's totals.
String statementCsv(InvestorStatementResponse statement) {
  final rows = <List<String>>[
    [
      'Date',
      'Type',
      'Amount',
      'Loan request',
      'Gross interest',
      'Platform fee',
      'Withholding tax',
      'Pending',
      'Reference',
    ],
    for (final e in statement.entries)
      [
        e.occurredAt,
        statementEntryLabel(e.type),
        displayMoney(e.amount),
        e.loanRequestId,
        e.hasInterestGross() ? displayMoney(e.interestGross) : '',
        e.hasPlatformFee() ? displayMoney(e.platformFee) : '',
        e.hasWithholdingTax() ? displayMoney(e.withholdingTax) : '',
        e.pending ? 'yes' : '',
        e.reference,
      ],
    [],
    ['Totals'],
    for (final t in statementTotals(statement.totals))
      [t.$1, displayMoney(t.$2)],
  ];
  return '${rows.map((r) => r.map(_cell).join(',')).join('\n')}\n';
}

/// The totals a statement shows, in order.
List<(String, dynamic)> statementTotals(InvestorStatementTotals t) => [
  ('Deposits', t.deposits),
  ('Withdrawals', t.withdrawals),
  ('Lent to loans', t.deployed),
  ('Released', t.released),
  ('Principal returned', t.principalReturned),
  ('Interest earned (net)', t.interestEarned),
  ('Platform fees', t.platformFees),
  ('Withholding tax', t.withholdingTax),
  ('Losses', t.losses),
  ('Recoveries', t.recoveries),
];
