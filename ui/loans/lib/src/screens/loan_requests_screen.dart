import 'dart:async';

import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/widgets/admin_entity_list_page.dart';
import '../utils/money_compat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/loan_request_providers.dart';
import '../widgets/list_state_view.dart';
import '../widgets/load_more_action.dart';
import '../widgets/loan_request_status_badge.dart';

class LoanRequestsScreen extends ConsumerStatefulWidget {
  const LoanRequestsScreen({super.key, this.pendingOnly = false});

  final bool pendingOnly;

  @override
  ConsumerState<LoanRequestsScreen> createState() => _LoanRequestsScreenState();
}

class _LoanRequestsScreenState extends ConsumerState<LoanRequestsScreen> {
  Timer? _debounce;
  String _query = '';
  int _limit = kLoanListPageSize;
  LoanRequestStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    if (widget.pendingOnly) {
      _statusFilter = LoanRequestStatus.LOAN_REQUEST_STATUS_SUBMITTED;
    }
  }

  static const _filterableStatuses = [
    LoanRequestStatus.LOAN_REQUEST_STATUS_DRAFT,
    LoanRequestStatus.LOAN_REQUEST_STATUS_SUBMITTED,
    LoanRequestStatus.LOAN_REQUEST_STATUS_APPROVED,
    LoanRequestStatus.LOAN_REQUEST_STATUS_REJECTED,
    LoanRequestStatus.LOAN_REQUEST_STATUS_CANCELLED,
    LoanRequestStatus.LOAN_REQUEST_STATUS_LOAN_CREATED,
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
      statusFilter: _statusFilter?.value,
      sourceService: null as String?,
      limit: _limit,
    );
    final requestsAsync = ref.watch(loanRequestListProvider(params));
    return ListStateView<LoanRequestObject>(
      title: widget.pendingOnly ? 'Pending Loan Requests' : 'Loan Requests',
      value: requestsAsync,
      onRetry: () => ref.invalidate(loanRequestListProvider(params)),
      builder: (page) {
        final requests = page.items;
        return AdminEntityListPage<LoanRequestObject>(
          title: widget.pendingOnly ? 'Pending Loan Requests' : 'Loan Requests',
          breadcrumbs: const ['Loans', 'Requests'],
          columns: const [
            DataColumn(label: Text('CLIENT')),
            DataColumn(label: Text('AMOUNT')),
            DataColumn(label: Text('TERM')),
            DataColumn(label: Text('STATUS')),
          ],
          items: requests,
          onSearch: _onSearch,
          actions: [
            DropdownButton<LoanRequestStatus?>(
              value: _statusFilter,
              hint: const Text('All statuses'),
              underline: const SizedBox.shrink(),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                for (final s in _filterableStatuses)
                  DropdownMenuItem(
                    value: s,
                    child: Text(loanRequestStatusLabel(s)),
                  ),
              ],
              onChanged: (v) => setState(() {
                _statusFilter = v;
                _limit = kLoanListPageSize;
              }),
            ),
            LoadMoreAction(
              loadedCount: requests.length,
              hasMore: page.hasMore,
              isLoading: requestsAsync.isLoading,
              onLoadMore: () => setState(() => _limit += kLoanListPageSize),
            ),
          ],
          rowBuilder: (request, selected, onSelect) {
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
                          Icons.description_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(request.clientId),
                    ],
                  ),
                ),
                DataCell(Text(formatLoanMoney(request.requestedAmount))),
                DataCell(Text('${request.requestedTermDays} days')),
                DataCell(LoanRequestStatusBadge(status: request.status)),
              ],
            );
          },
          onRowNavigate: (request) {
            context.go('/loans/requests/${request.id}');
          },
          detailBuilder: (request) => _LoanRequestDetail(request: request),
          exportRow: (request) => [
            request.clientId,
            formatLoanMoney(request.requestedAmount),
            '${request.requestedTermDays}',
            loanRequestStatusLabel(request.status),
            request.id,
          ],
        );
      },
    );
  }
}

class _LoanRequestDetail extends StatelessWidget {
  const _LoanRequestDetail({required this.request});
  final LoanRequestObject request;

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
                Icons.description_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.clientId,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    request.id,
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
          label: 'Amount',
          value: formatLoanMoney(request.requestedAmount),
        ),
        _DetailRow(label: 'Term', value: '${request.requestedTermDays} days'),
        _DetailRow(
          label: 'Status',
          value: loanRequestStatusLabel(request.status),
        ),
        if (request.sourceService.isNotEmpty)
          _DetailRow(label: 'Source', value: request.sourceService),
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
