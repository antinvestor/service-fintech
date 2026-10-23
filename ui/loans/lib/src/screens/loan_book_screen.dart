import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:antinvestor_ui_core/responsive/breakpoints.dart';
import '../utils/money_compat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/loans_transport_provider.dart';
import '../widgets/loan_book_export_button.dart';

class LoanBookScreen extends ConsumerStatefulWidget {
  const LoanBookScreen({super.key});

  @override
  ConsumerState<LoanBookScreen> createState() => _LoanBookScreenState();
}

class _LoanBookScreenState extends ConsumerState<LoanBookScreen> {
  final _searchController = TextEditingController();
  LoanStatus _statusFilter = LoanStatus.LOAN_STATUS_UNSPECIFIED;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = AppBreakpoints.isMobile(constraints.maxWidth);
        final padding = isMobile ? 16.0 : 24.0;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padding, padding, padding, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loan Book',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Browse all loans. Export as CSV for reporting.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const LoanBookExportButton(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padding, 8, padding, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search loans...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<LoanStatus>(
                      value: _statusFilter,
                      items: const [
                        DropdownMenuItem(
                          value: LoanStatus.LOAN_STATUS_UNSPECIFIED,
                          child: Text('All Status'),
                        ),
                        DropdownMenuItem(
                          value: LoanStatus.LOAN_STATUS_ACTIVE,
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: LoanStatus.LOAN_STATUS_DELINQUENT,
                          child: Text('Delinquent'),
                        ),
                        DropdownMenuItem(
                          value: LoanStatus.LOAN_STATUS_DEFAULT,
                          child: Text('Default'),
                        ),
                        DropdownMenuItem(
                          value: LoanStatus.LOAN_STATUS_PAID_OFF,
                          child: Text('Paid Off'),
                        ),
                      ],
                      onChanged: (v) => setState(
                        () => _statusFilter =
                            v ?? LoanStatus.LOAN_STATUS_UNSPECIFIED,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _LoanList(
              query: _searchController.text,
              statusFilter: _statusFilter,
              padding: padding,
            ),
          ],
        );
      },
    );
  }
}

final _loanListProvider =
    FutureProvider.family<List<LoanAccountObject>, LoanAccountSearchRequest>((
      ref,
      request,
    ) async {
      final client = ref.watch(loanManagementServiceClientProvider);
      return collectStream(
        client.loanAccountSearch(request),
        extract: (response) => response.data,
        maxPages: 50,
      );
    });

class _LoanList extends ConsumerWidget {
  const _LoanList({
    required this.query,
    required this.statusFilter,
    required this.padding,
  });

  final String query;
  final LoanStatus statusFilter;
  final double padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = LoanAccountSearchRequest(
      cursor: PageCursor(limit: 200),
      query: query,
    );
    if (statusFilter != LoanStatus.LOAN_STATUS_UNSPECIFIED) {
      request.status = statusFilter;
    }

    final loansAsync = ref.watch(_loanListProvider(request));

    return loansAsync.when(
      data: (loans) {
        if (loans.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                'No loans found',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
          sliver: SliverList.builder(
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final loan = loans[index];
              return _LoanCard(loan: loan);
            },
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) =>
          SliverFillRemaining(child: Center(child: Text('Error: $err'))),
    );
  }
}

class _LoanCard extends StatelessWidget {
  const _LoanCard({required this.loan});

  final LoanAccountObject loan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.go('/loans/${loan.id}'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.id,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatLoanMoney(loan.principalAmount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DPD', style: theme.textTheme.labelSmall),
                    Text(
                      '${loan.daysPastDue}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: loan.daysPastDue > 0
                            ? theme.colorScheme.error
                            : null,
                        fontWeight: loan.daysPastDue > 0
                            ? FontWeight.w600
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: loan.status),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: theme.colorScheme.onSurface.withAlpha(60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final LoanStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      LoanStatus.LOAN_STATUS_ACTIVE => ('Active', Colors.green),
      LoanStatus.LOAN_STATUS_DELINQUENT => ('Delinquent', Colors.orange),
      LoanStatus.LOAN_STATUS_DEFAULT => ('Default', Colors.red),
      LoanStatus.LOAN_STATUS_PAID_OFF => ('Paid Off', Colors.blue),
      LoanStatus.LOAN_STATUS_WRITTEN_OFF => ('Written Off', Colors.grey),
      LoanStatus.LOAN_STATUS_PENDING_DISBURSEMENT => ('Pending', Colors.amber),
      LoanStatus.LOAN_STATUS_RESTRUCTURED => ('Restructured', Colors.purple),
      LoanStatus.LOAN_STATUS_CLOSED => ('Closed', Colors.grey),
      _ => ('Unknown', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
