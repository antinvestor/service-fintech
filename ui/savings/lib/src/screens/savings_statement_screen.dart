import 'package:antinvestor_api_savings/antinvestor_api_savings.dart'
    hide PageCursor, STATE;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/savings_providers.dart';
import '../utils/money_display.dart';

/// Entries shown per page. The RPC returns the whole window in one response
/// on the current contract, so paging is over that result; when the contract
/// gains a cursor the same control moves to the server.
const statementPageSize = 25;

/// A standalone statement for one savings account: a date window, every
/// completed movement in it, and the balance carried after each line.
class SavingsStatementScreen extends ConsumerStatefulWidget {
  const SavingsStatementScreen({
    super.key,
    required this.accountId,
    this.initialRange,
  });

  final String accountId;

  /// Window to open with. Null asks the server for its default window.
  final DateTimeRange? initialRange;

  @override
  ConsumerState<SavingsStatementScreen> createState() =>
      _SavingsStatementScreenState();
}

class _SavingsStatementScreenState
    extends ConsumerState<SavingsStatementScreen> {
  DateTimeRange? _range;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _range = widget.initialRange;
  }

  ({String accountId, String fromDate, String toDate}) get _params => (
    accountId: widget.accountId,
    fromDate: _range == null ? '' : _range!.start.toUtc().toIso8601String(),
    // The picker yields the start of the last day; the window runs to its end.
    toDate: _range == null
        ? ''
        : _range!.end
              .add(const Duration(days: 1))
              .subtract(const Duration(milliseconds: 1))
              .toUtc()
              .toIso8601String(),
  );

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
      initialDateRange:
          _range ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 90)),
            end: now,
          ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _range = picked;
      _page = 0;
    });
  }

  void _clearRange() => setState(() {
    _range = null;
    _page = 0;
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final params = _params;
    final statementAsync = ref.watch(savingsStatementProvider(params));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              IconButton(
                key: const Key('statement-back'),
                tooltip: 'Back to account',
                onPressed: () => context.go('/savings/${widget.accountId}'),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Statement',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.accountId,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                key: const Key('statement-range'),
                onPressed: _pickRange,
                icon: const Icon(Icons.date_range, size: 18),
                label: Text(_rangeLabel(_range)),
              ),
              if (_range != null)
                IconButton(
                  key: const Key('statement-range-clear'),
                  tooltip: 'Use the default window',
                  onPressed: _clearRange,
                  icon: const Icon(Icons.close),
                ),
              IconButton(
                key: const Key('statement-refresh'),
                tooltip: 'Refresh',
                onPressed: () =>
                    ref.invalidate(savingsStatementProvider(params)),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: statementAsync.when(
            loading: () => const Center(
              key: Key('statement-loading'),
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => Center(
              key: const Key('statement-error'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 36,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text('Could not load the statement: $error'),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    key: const Key('statement-retry'),
                    onPressed: () =>
                        ref.invalidate(savingsStatementProvider(params)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (statement) => _StatementBody(
              statement: statement,
              page: _page,
              onPageChanged: (page) => setState(() => _page = page),
            ),
          ),
        ),
      ],
    );
  }
}

String _rangeLabel(DateTimeRange? range) {
  if (range == null) return 'Last 90 days';
  return '${_ymd(range.start)} – ${_ymd(range.end)}';
}

String _ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

class _StatementBody extends StatelessWidget {
  const _StatementBody({
    required this.statement,
    required this.page,
    required this.onPageChanged,
  });

  final SavingsStatementResponse statement;
  final int page;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = statement.entries;
    if (entries.isEmpty) {
      return Center(
        key: const Key('statement-empty'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 36,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No movements in this period',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Current balance: '
              '${displayMoney(statement.balance.availableBalance)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final pageCount =
        (entries.length + statementPageSize - 1) ~/ statementPageSize;
    final safePage = page.clamp(0, pageCount - 1);
    final start = safePage * statementPageSize;
    final end = (start + statementPageSize).clamp(0, entries.length);
    final visible = entries.sublist(start, end);
    final closing = displayMoney(entries.last.balance);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _SummaryRow(statement: statement, closing: closing),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    key: const Key('statement-table'),
                    columns: const [
                      DataColumn(label: Text('DATE')),
                      DataColumn(label: Text('DESCRIPTION')),
                      DataColumn(label: Text('REFERENCE')),
                      DataColumn(label: Text('DEBIT'), numeric: true),
                      DataColumn(label: Text('CREDIT'), numeric: true),
                      DataColumn(label: Text('BALANCE'), numeric: true),
                    ],
                    rows: [
                      for (final entry in visible)
                        DataRow(
                          cells: [
                            DataCell(Text(_shortDate(entry.date))),
                            DataCell(Text(entry.description)),
                            DataCell(
                              Text(
                                entry.reference,
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                            DataCell(Text(_movement(entry.debit))),
                            DataCell(Text(_movement(entry.credit))),
                            DataCell(
                              Text(
                                displayMoney(entry.balance),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // The pager stays put beneath the scrolling table so a long page
        // never hides the way to the next one.
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Showing ${start + 1}–$end of ${entries.length}',
                key: const Key('statement-page-label'),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 12),
              IconButton(
                key: const Key('statement-prev'),
                tooltip: 'Previous page',
                onPressed: safePage > 0
                    ? () => onPageChanged(safePage - 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                key: const Key('statement-next'),
                tooltip: 'Next page',
                onPressed: safePage < pageCount - 1
                    ? () => onPageChanged(safePage + 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A debit or credit column shows a blank, not a zero, on the side of the
/// ledger the movement did not touch. The service-typed Money is read
/// dynamically, the same way [displayMoney] does.
String _movement(dynamic money) {
  if (money == null) return '';
  if ((money.units as dynamic).toInt() == 0 && money.nanos == 0) return '';
  return displayMoney(money);
}

String _shortDate(String rfc3339) {
  final parsed = DateTime.tryParse(rfc3339);
  return parsed == null ? rfc3339 : _ymd(parsed.toLocal());
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.statement, required this.closing});

  final SavingsStatementResponse statement;
  final String closing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _SummaryTile(
          label: 'Closing balance',
          value: closing,
          icon: Icons.account_balance,
        ),
        _SummaryTile(
          label: 'Current balance',
          value: displayMoney(statement.balance.availableBalance),
          icon: Icons.account_balance_wallet_outlined,
        ),
        _SummaryTile(
          label: 'Movements',
          value: '${statement.entries.length}',
          icon: Icons.swap_vert,
        ),
        _SummaryTile(
          label: 'Currency',
          value: statement.account.currencyCode,
          icon: Icons.currency_exchange,
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
