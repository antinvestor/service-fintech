import 'dart:async';

import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/widgets/admin_entity_list_page.dart';
import '../utils/money_compat.dart';
import 'package:antinvestor_ui_core/responsive/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/current_agent_provider.dart';
import '../providers/loan_account_providers.dart';
import '../widgets/compact_entity_list.dart';
import '../widgets/list_state_view.dart';
import '../widgets/load_more_action.dart';
import '../widgets/loan_status_badge.dart';

class LoanAccountsScreen extends ConsumerStatefulWidget {
  const LoanAccountsScreen({super.key});

  @override
  ConsumerState<LoanAccountsScreen> createState() => _LoanAccountsScreenState();
}

/// Orders [loans] by days past due, worst first. Ties keep their service
/// order so a page never reshuffles between loads.
List<LoanAccountObject> sortByDaysPastDue(List<LoanAccountObject> loans) {
  final indexed = loans.indexed.toList()
    ..sort((a, b) {
      final byDpd = b.$2.daysPastDue.compareTo(a.$2.daysPastDue);
      return byDpd != 0 ? byDpd : a.$1.compareTo(b.$1);
    });
  return [for (final (_, loan) in indexed) loan];
}

class _LoanAccountsScreenState extends ConsumerState<LoanAccountsScreen> {
  Timer? _debounce;
  String _query = '';
  LoanStatus? _statusFilter;
  int _limit = kLoanListPageSize;
  bool _myPortfolio = false;
  bool _delinquentOnly = false;

  static const _filterableStatuses = [
    LoanStatus.LOAN_STATUS_PENDING_DISBURSEMENT,
    LoanStatus.LOAN_STATUS_ACTIVE,
    LoanStatus.LOAN_STATUS_DELINQUENT,
    LoanStatus.LOAN_STATUS_DEFAULT,
    LoanStatus.LOAN_STATUS_PAID_OFF,
    LoanStatus.LOAN_STATUS_RESTRUCTURED,
    LoanStatus.LOAN_STATUS_WRITTEN_OFF,
    LoanStatus.LOAN_STATUS_CLOSED,
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _query = value.trim();
          _limit = kLoanListPageSize;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final agentId = ref.watch(currentAgentIdProvider) ?? '';
    final filterMine = _myPortfolio && agentId.isNotEmpty;
    final params = (
      query: _query,
      status: _delinquentOnly
          ? LoanStatus.LOAN_STATUS_DELINQUENT
          : _statusFilter,
      agentId: filterMine ? agentId : '',
      clientId: '',
      limit: _limit,
    );
    final loansAsync = ref.watch(loanAccountListProvider(params));
    return ListStateView<LoanAccountObject>(
      title: 'Loan Accounts',
      value: loansAsync,
      onRetry: () => ref.invalidate(loanAccountListProvider(params)),
      builder: (page) {
        final loans = _delinquentOnly
            ? sortByDaysPastDue(page.items)
            : page.items;
        final actions = <Widget>[
          Tooltip(
            message: agentId.isEmpty
                ? 'Your agent id is not known in this session'
                : 'Only loans you originated',
            child: FilterChip(
              key: const Key('my-portfolio-filter'),
              label: const Text('My portfolio'),
              selected: filterMine,
              onSelected: agentId.isEmpty
                  ? null
                  : (v) => setState(() {
                      _myPortfolio = v;
                      _limit = kLoanListPageSize;
                    }),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Delinquent loans, most overdue first',
            child: FilterChip(
              key: const Key('delinquent-filter'),
              label: const Text('Delinquent'),
              selected: _delinquentOnly,
              onSelected: (v) => setState(() {
                _delinquentOnly = v;
                _limit = kLoanListPageSize;
              }),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<LoanStatus?>(
            value: _delinquentOnly
                ? LoanStatus.LOAN_STATUS_DELINQUENT
                : _statusFilter,
            hint: const Text('All Statuses'),
            underline: const SizedBox.shrink(),
            items: [
              const DropdownMenuItem<LoanStatus?>(
                value: null,
                child: Text('All Statuses'),
              ),
              ..._filterableStatuses.map(
                (s) =>
                    DropdownMenuItem(value: s, child: Text(loanStatusLabel(s))),
              ),
            ],
            onChanged: _delinquentOnly
                ? null
                : (value) => setState(() {
                    _statusFilter = value;
                    _limit = kLoanListPageSize;
                  }),
          ),
          LoadMoreAction(
            loadedCount: loans.length,
            hasMore: page.hasMore,
            isLoading: loansAsync.isLoading,
            onLoadMore: () => setState(() => _limit += kLoanListPageSize),
          ),
        ];
        return LayoutBuilder(
          builder: (context, constraints) {
            if (AppBreakpoints.isMobile(constraints.maxWidth)) {
              return CompactEntityList<LoanAccountObject>(
                title: 'Loan Accounts',
                items: loans,
                onSearch: _onSearch,
                searchHint: 'Search loans',
                actions: actions,
                tileBuilder: (loan) => ListTile(
                  key: Key('loan-tile-${loan.id}'),
                  title: Text(loan.clientId),
                  subtitle: Text(
                    '${formatLoanMoney(loan.principalAmount)} · '
                    '${loan.termDays} days',
                  ),
                  trailing: LoanStatusBadge(status: loan.status),
                ),
                onTap: (loan) => context.go('/loans/${loan.id}'),
              );
            }
            return AdminEntityListPage<LoanAccountObject>(
              title: 'Loan Accounts',
              breadcrumbs: const ['Loans', 'Accounts'],
              columns: [
                const DataColumn(label: Text('CLIENT')),
                const DataColumn(label: Text('PRINCIPAL')),
                const DataColumn(label: Text('TERM')),
                const DataColumn(label: Text('STATUS')),
                if (_delinquentOnly)
                  const DataColumn(label: Text('DAYS PAST DUE'), numeric: true),
              ],
              items: loans,
              onSearch: _onSearch,
              actions: actions,
              rowBuilder: (loan, selected, onSelect) {
                return DataRow(
                  selected: selected,
                  onSelectChanged: (_) => onSelect(),
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(loan.clientId),
                        ],
                      ),
                    ),
                    DataCell(Text(formatLoanMoney(loan.principalAmount))),
                    DataCell(Text('${loan.termDays} days')),
                    DataCell(LoanStatusBadge(status: loan.status)),
                    if (_delinquentOnly)
                      DataCell(
                        Text('${loan.daysPastDue}', key: Key('dpd-${loan.id}')),
                      ),
                  ],
                );
              },
              onRowNavigate: (loan) {
                context.go('/loans/${loan.id}');
              },
              detailBuilder: (loan) => _LoanAccountDetail(loan: loan),
              exportRow: (loan) => [
                loan.clientId,
                formatLoanMoney(loan.principalAmount),
                '${loan.termDays}',
                loanStatusLabel(loan.status),
                loan.id,
              ],
            );
          },
        );
      },
    );
  }
}

class _LoanAccountDetail extends StatelessWidget {
  const _LoanAccountDetail({required this.loan});
  final LoanAccountObject loan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loan.clientId,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    loan.id,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _DetailRow(
          label: 'Principal',
          value: formatLoanMoney(loan.principalAmount),
        ),
        _DetailRow(label: 'Term', value: '${loan.termDays} days'),
        _DetailRow(label: 'Status', value: loanStatusLabel(loan.status)),
        if (loan.daysPastDue > 0)
          _DetailRow(label: 'Days Past Due', value: '${loan.daysPastDue}'),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
