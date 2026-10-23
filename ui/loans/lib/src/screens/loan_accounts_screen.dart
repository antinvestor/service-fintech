import 'dart:async';

import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/widgets/admin_entity_list_page.dart';
import '../utils/money_compat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/loan_account_providers.dart';
import '../widgets/list_state_view.dart';
import '../widgets/load_more_action.dart';
import '../widgets/loan_status_badge.dart';

class LoanAccountsScreen extends ConsumerStatefulWidget {
  const LoanAccountsScreen({super.key});

  @override
  ConsumerState<LoanAccountsScreen> createState() => _LoanAccountsScreenState();
}

class _LoanAccountsScreenState extends ConsumerState<LoanAccountsScreen> {
  Timer? _debounce;
  String _query = '';
  LoanStatus? _statusFilter;
  int _limit = kLoanListPageSize;

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
    final params = (
      query: _query,
      status: _statusFilter,
      agentId: '',
      clientId: '',
      limit: _limit,
    );
    final loansAsync = ref.watch(loanAccountListProvider(params));
    return ListStateView<LoanAccountObject>(
      title: 'Loan Accounts',
      value: loansAsync,
      onRetry: () => ref.invalidate(loanAccountListProvider(params)),
      builder: (page) {
        final loans = page.items;
        return AdminEntityListPage<LoanAccountObject>(
          title: 'Loan Accounts',
          breadcrumbs: const ['Loans', 'Accounts'],
          columns: const [
            DataColumn(label: Text('CLIENT')),
            DataColumn(label: Text('PRINCIPAL')),
            DataColumn(label: Text('TERM')),
            DataColumn(label: Text('STATUS')),
          ],
          items: loans,
          onSearch: _onSearch,
          actions: [
            DropdownButton<LoanStatus?>(
              value: _statusFilter,
              hint: const Text('All Statuses'),
              underline: const SizedBox.shrink(),
              items: [
                const DropdownMenuItem<LoanStatus?>(
                  value: null,
                  child: Text('All Statuses'),
                ),
                ..._filterableStatuses.map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(loanStatusLabel(s)),
                  ),
                ),
              ],
              onChanged: (value) => setState(() {
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
          ],
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
