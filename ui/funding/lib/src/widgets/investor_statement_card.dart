import 'dart:convert';

import 'package:antinvestor_api_funding/antinvestor_api_funding.dart'
    hide PageCursor, STATE;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/funding_providers.dart';
import '../utils/file_saver.dart';
import '../utils/money_display.dart';
import '../utils/statement_csv.dart';

/// The statement periods offered.
enum StatementRange { last30Days, thisMonth, lastMonth, yearToDate }

String _rangeLabel(StatementRange r) => switch (r) {
  StatementRange.last30Days => 'Last 30 days',
  StatementRange.thisMonth => 'This month',
  StatementRange.lastMonth => 'Last month',
  StatementRange.yearToDate => 'Year to date',
};

/// The period a range covers as of [now]: from inclusive, to exclusive.
(DateTime, DateTime) statementRangePeriod(StatementRange r, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  switch (r) {
    case StatementRange.last30Days:
      return (tomorrow.subtract(const Duration(days: 30)), tomorrow);
    case StatementRange.thisMonth:
      return (DateTime(now.year, now.month), tomorrow);
    case StatementRange.lastMonth:
      return (DateTime(now.year, now.month - 1), DateTime(now.year, now.month));
    case StatementRange.yearToDate:
      return (DateTime(now.year), tomorrow);
  }
}

/// What moved an investor account's capital over a chosen period, with its
/// totals and a CSV download.
class InvestorStatementCard extends ConsumerStatefulWidget {
  const InvestorStatementCard({
    super.key,
    required this.accountId,
    this.fileSaver = const PlatformFileSaver(),
    this.clock = DateTime.now,
  });

  final String accountId;
  final FileSaver fileSaver;
  final DateTime Function() clock;

  @override
  ConsumerState<InvestorStatementCard> createState() =>
      _InvestorStatementCardState();
}

class _InvestorStatementCardState extends ConsumerState<InvestorStatementCard> {
  StatementRange _range = StatementRange.last30Days;
  late StatementPeriod _period;

  @override
  void initState() {
    super.initState();
    _period = _periodFor(_range);
  }

  StatementPeriod _periodFor(StatementRange r) {
    final (from, to) = statementRangePeriod(r, widget.clock());
    return (accountId: widget.accountId, from: from, to: to);
  }

  Future<void> _download(InvestorStatementResponse statement) async {
    final day = _period.from.toIso8601String().substring(0, 10);
    await widget.fileSaver.save(
      bytes: utf8.encode(statementCsv(statement)),
      filename: 'statement-${widget.accountId}-$day.csv',
      contentType: 'text/csv',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statementAsync = ref.watch(investorStatementProvider(_period));

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Statement',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (statementAsync.hasValue)
                  TextButton.icon(
                    key: const Key('statement-download'),
                    onPressed: () => _download(statementAsync.requireValue),
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Download CSV'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final r in StatementRange.values)
                  ChoiceChip(
                    label: Text(_rangeLabel(r)),
                    selected: r == _range,
                    onSelected: (_) => setState(() {
                      _range = r;
                      _period = _periodFor(r);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            statementAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Row(
                children: [
                  Expanded(child: Text('Could not load the statement: $e')),
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(investorStatementProvider(_period)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
              data: (statement) => _StatementBody(statement: statement),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatementBody extends StatelessWidget {
  const _StatementBody({required this.statement});

  final InvestorStatementResponse statement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 24,
          runSpacing: 8,
          children: [
            for (final (label, amount) in statementTotals(statement.totals))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: muted),
                  Text(displayMoney(amount)),
                ],
              ),
          ],
        ),
        if (statement.truncated)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'This period holds more entries than one statement shows; '
              'choose a shorter period.',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        const SizedBox(height: 12),
        if (statement.entries.isEmpty)
          Text('Nothing moved in this period.', style: muted)
        else
          for (final e in statement.entries.reversed)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${statementEntryLabel(e.type)}${e.pending ? ' (awaiting confirmation)' : ''}',
              ),
              subtitle: Text(
                [
                  e.occurredAt.length >= 10
                      ? e.occurredAt.substring(0, 10)
                      : e.occurredAt,
                  if (e.loanRequestId.isNotEmpty) 'Loan ${e.loanRequestId}',
                  if (e.hasInterestGross())
                    'Gross ${displayMoney(e.interestGross)}, fee '
                        '${displayMoney(e.platformFee)}, tax '
                        '${displayMoney(e.withholdingTax)}',
                ].join(' • '),
              ),
              trailing: Text(displayMoney(e.amount)),
            ),
      ],
    );
  }
}
