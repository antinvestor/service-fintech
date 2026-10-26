import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import '../utils/money_compat.dart';
import 'package:antinvestor_ui_core/widgets/profile_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/disbursement_providers.dart';
import '../providers/loan_account_providers.dart';
import '../providers/loans_transport_provider.dart';
import '../providers/penalty_providers.dart';
import '../providers/repayment_providers.dart';
import '../providers/restructure_providers.dart';
import '../providers/schedule_providers.dart';
import '../providers/statement_providers.dart';
import '../utils/idempotency_key.dart';
import '../widgets/loan_status_badge.dart';

class LoanAccountDetailScreen extends ConsumerStatefulWidget {
  const LoanAccountDetailScreen({
    super.key,
    required this.loanId,
    this.canManage = false,
    this.canCollectPayment = false,
    this.canDisburse = false,
    this.canWaivePenalty = false,
    this.canDecideRestructure = false,
  });

  final String loanId;

  /// Whether the current user can perform management actions (disburse, restructure, etc.).
  /// Host app should set this based on its own authorization logic.
  final bool canManage;

  /// Whether the current user can prompt the borrower to pay from their own
  /// contact (`collection_manage`). Nobody records a payment by hand: the
  /// borrower pays and the payment rail applies it.
  final bool canCollectPayment;

  /// Whether the current user can move money out on this loan.
  final bool canDisburse;

  /// Whether the current user can waive penalties (`penalty_manage`).
  final bool canWaivePenalty;

  /// Whether the current user can approve or reject restructure requests
  /// (`restructure_manage`). Requesting one stays under [canManage].
  final bool canDecideRestructure;

  @override
  ConsumerState<LoanAccountDetailScreen> createState() =>
      _LoanAccountDetailScreenState();
}

class _LoanAccountDetailScreenState
    extends ConsumerState<LoanAccountDetailScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loanAsync = ref.watch(loanAccountDetailProvider(widget.loanId));
    final balanceAsync = ref.watch(loanBalanceDetailProvider(widget.loanId));

    return loanAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load loan: $error',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () =>
                  ref.invalidate(loanAccountDetailProvider(widget.loanId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (loan) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/loans'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loan ${loan.id}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Client: ${loan.clientId}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (loan.agentId.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ProfileAvatar(
                              profileId: loan.agentId,
                              name: loan.agentId,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Agent',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                LoanStatusBadge(status: loan.status),
              ],
            ),
          ),

          // Days past due banner
          if (loan.daysPastDue > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withAlpha(60),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${loan.daysPastDue} days past due',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (loan.maturityDate.isNotEmpty) ...[
                      const Spacer(),
                      Text(
                        'Maturity: ${loan.maturityDate}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Balance card
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: balanceAsync.when(
              loading: () => const Card(
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Failed to load balance: $e'),
                ),
              ),
              data: (balance) => _BalanceCard(
                balance: balance,
                currencyCode: loanMoneyCurrency(loan.principalAmount),
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (loan.status ==
                        LoanStatus.LOAN_STATUS_PENDING_DISBURSEMENT &&
                    widget.canDisburse)
                  FilledButton.icon(
                    onPressed: () => _showDisbursementDialog(context, loan),
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Disburse'),
                  ),
                if (loan.status == LoanStatus.LOAN_STATUS_ACTIVE ||
                    loan.status == LoanStatus.LOAN_STATUS_DELINQUENT) ...[
                  if (widget.canCollectPayment)
                    FilledButton.tonalIcon(
                      onPressed: () => _showCollectPaymentDialog(context, loan),
                      icon: const Icon(Icons.phone_android, size: 18),
                      label: const Text('Collect Payment'),
                    ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Schedule'),
              Tab(text: 'Statement'),
              Tab(text: 'Transactions'),
              Tab(text: 'Penalties'),
              Tab(text: 'Restructuring'),
              Tab(text: 'History'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ScheduleTab(loanAccountId: widget.loanId),
                _StatementTab(loanAccountId: widget.loanId),
                _TransactionsTab(loanAccountId: widget.loanId),
                _PenaltiesTab(
                  loanAccountId: widget.loanId,
                  canManage: widget.canWaivePenalty,
                ),
                _RestructuringTab(
                  loanAccountId: widget.loanId,
                  canManage: widget.canManage,
                  canDecide: widget.canDecideRestructure,
                ),
                _HistoryTab(loanAccountId: widget.loanId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDisbursementDialog(BuildContext context, LoanAccountObject loan) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _DisbursementFormDialog(
        loan: loan,
        onSave: (idempotencyKey) async {
          try {
            await ref
                .read(disbursementNotifierProvider.notifier)
                .create(
                  loanAccountId: loan.id,
                  channel: 'mobile_money',
                  recipientReference: '',
                  idempotencyKey: idempotencyKey,
                );
            ref.invalidate(loanAccountDetailProvider(widget.loanId));
            ref.invalidate(loanBalanceDetailProvider(widget.loanId));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Disbursement initiated successfully'),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to disburse: $e'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showCollectPaymentDialog(BuildContext context, LoanAccountObject loan) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _CollectPaymentFormDialog(
        loanAccountId: loan.id,
        currencyCode: loanMoneyCurrency(loan.principalAmount),
        onSave: (amount, idempotencyKey) async {
          try {
            final client = ref.read(loanManagementServiceClientProvider);
            await client.initiateCollection(
              InitiateCollectionRequest(
                loanAccountId: loan.id,
                // No contact is named: the prompt goes to the borrower's
                // profile, whose contacts the profile service owns.
                collectionAmount: loanMoneyFromString(
                  amount,
                  loanMoneyCurrency(loan.principalAmount),
                ),
                idempotencyKey: idempotencyKey,
              ),
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Collection prompt sent successfully'),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to initiate collection: $e'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Balance Card
// ---------------------------------------------------------------------------

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance, required this.currencyCode});

  final LoanBalanceObject balance;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paid = _moneyToDouble(balance.totalPaid);
    final outstanding = _moneyToDouble(balance.totalOutstanding);
    final total = paid + outstanding;
    final progress = total > 0 ? paid / total : 0.0;
    final percentText = '${(progress * 100).toStringAsFixed(1)}%';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Balance Summary',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '$percentText repaid',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: progress >= 0.8
                        ? Colors.green
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.green.withAlpha(20),
                valueColor: AlwaysStoppedAnimation(
                  progress >= 0.8
                      ? Colors.green
                      : progress >= 0.5
                      ? Colors.orange
                      : Colors.red,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _BalanceItem(
                    label: 'Principal Outstanding',
                    value: formatLoanMoney(balance.principalOutstanding),
                  ),
                ),
                Expanded(
                  child: _BalanceItem(
                    label: 'Interest Accrued',
                    value: formatLoanMoney(balance.interestAccrued),
                  ),
                ),
                Expanded(
                  child: _BalanceItem(
                    label: 'Fees Outstanding',
                    value: formatLoanMoney(balance.feesOutstanding),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _BalanceItem(
                    label: 'Penalties Outstanding',
                    value: formatLoanMoney(balance.penaltiesOutstanding),
                  ),
                ),
                Expanded(
                  child: _BalanceItem(
                    label: 'Total Outstanding',
                    value: formatLoanMoney(balance.totalOutstanding),
                    isBold: true,
                  ),
                ),
                Expanded(
                  child: _BalanceItem(
                    label: 'Total Paid',
                    value: formatLoanMoney(balance.totalPaid),
                    isBold: true,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _moneyToDouble(dynamic money) {
    if (money == null) return 0;
    try {
      final units = money.units.toInt();
      final nanos = money.nanos.toInt();
      return units + nanos / 1e9;
    } catch (_) {
      return 0;
    }
  }
}

class _BalanceItem extends StatelessWidget {
  const _BalanceItem({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(140),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Schedule Tab
// ---------------------------------------------------------------------------

class _ScheduleTab extends ConsumerWidget {
  const _ScheduleTab({required this.loanAccountId});
  final String loanAccountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheduleAsync = ref.watch(
      repaymentScheduleDetailProvider(loanAccountId),
    );

    return scheduleAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load schedule: $e'),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => ref.invalidate(
                repaymentScheduleDetailProvider(loanAccountId),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (schedule) {
        if (schedule.entries.isEmpty) {
          return const Center(child: Text('No schedule entries'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingTextStyle: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              dataTextStyle: theme.textTheme.bodySmall,
              columnSpacing: 16,
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Due Date')),
                DataColumn(label: Text('Principal Due'), numeric: true),
                DataColumn(label: Text('Interest Due'), numeric: true),
                DataColumn(label: Text('Total Due'), numeric: true),
                DataColumn(label: Text('Total Paid'), numeric: true),
                DataColumn(label: Text('Outstanding'), numeric: true),
                DataColumn(label: Text('Status')),
              ],
              rows: schedule.entries.map((entry) {
                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>((_) {
                    return switch (entry.status) {
                      ScheduleEntryStatus.SCHEDULE_ENTRY_STATUS_PAID =>
                        Colors.green.withAlpha(8),
                      ScheduleEntryStatus.SCHEDULE_ENTRY_STATUS_OVERDUE =>
                        Colors.red.withAlpha(12),
                      ScheduleEntryStatus.SCHEDULE_ENTRY_STATUS_PARTIAL =>
                        Colors.amber.withAlpha(10),
                      _ => null,
                    };
                  }),
                  cells: [
                    DataCell(Text('${entry.installmentNumber}')),
                    DataCell(Text(entry.dueDate)),
                    DataCell(Text(formatLoanMoney(entry.principalDue))),
                    DataCell(Text(formatLoanMoney(entry.interestDue))),
                    DataCell(Text(formatLoanMoney(entry.totalDue))),
                    DataCell(Text(formatLoanMoney(entry.totalPaid))),
                    DataCell(Text(formatLoanMoney(entry.outstanding))),
                    DataCell(_ScheduleEntryStatusChip(status: entry.status)),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _ScheduleEntryStatusChip extends StatelessWidget {
  const _ScheduleEntryStatusChip({required this.status});
  final ScheduleEntryStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ScheduleEntryStatus.SCHEDULE_ENTRY_STATUS_UPCOMING => (
        'Upcoming',
        Colors.blue,
      ),
      ScheduleEntryStatus.SCHEDULE_ENTRY_STATUS_DUE => ('Due', Colors.orange),
      ScheduleEntryStatus.SCHEDULE_ENTRY_STATUS_PAID => ('Paid', Colors.green),
      ScheduleEntryStatus.SCHEDULE_ENTRY_STATUS_PARTIAL => (
        'Partial',
        Colors.amber,
      ),
      ScheduleEntryStatus.SCHEDULE_ENTRY_STATUS_OVERDUE => (
        'Overdue',
        Colors.red,
      ),
      ScheduleEntryStatus.SCHEDULE_ENTRY_STATUS_WAIVED => (
        'Waived',
        Colors.grey,
      ),
      _ => ('Unknown', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transactions Tab (Disbursements + Repayments)
// ---------------------------------------------------------------------------

class _TransactionsTab extends ConsumerWidget {
  const _TransactionsTab({required this.loanAccountId});
  final String loanAccountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final disbursementsAsync = ref.watch(
      disbursementListProvider(loanAccountId),
    );
    final repaymentsAsync = ref.watch(repaymentListProvider(loanAccountId));

    if (disbursementsAsync.isLoading || repaymentsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (disbursementsAsync.hasError) {
      return Center(child: Text('Error: ${disbursementsAsync.error}'));
    }
    if (repaymentsAsync.hasError) {
      return Center(child: Text('Error: ${repaymentsAsync.error}'));
    }

    final disbursements = disbursementsAsync.value ?? [];
    final repayments = repaymentsAsync.value ?? [];

    final items = <_TransactionItem>[];
    for (final d in disbursements) {
      items.add(
        _TransactionItem(
          date: d.disbursedAt,
          type: 'Disbursement',
          amount: loanMoneyToAmountString(d.amount),
          currency: loanMoneyCurrency(d.amount),
          reference: d.paymentReference,
          status: _disbursementStatusLabel(d.status),
          statusColor: _disbursementStatusColor(d.status),
          icon: Icons.arrow_upward,
          iconColor: Colors.red,
        ),
      );
    }
    for (final r in repayments) {
      items.add(
        _TransactionItem(
          date: r.receivedAt,
          type: 'Repayment',
          amount: loanMoneyToAmountString(r.amount),
          currency: loanMoneyCurrency(r.amount),
          reference: r.paymentReference,
          status: _repaymentStatusLabel(r.status),
          statusColor: _repaymentStatusColor(r.status),
          icon: Icons.arrow_downward,
          iconColor: Colors.green,
        ),
      );
    }
    items.sort((a, b) => b.date.compareTo(a.date));

    if (items.isEmpty) {
      return const Center(child: Text('No transactions'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            leading: CircleAvatar(
              backgroundColor: item.iconColor.withAlpha(20),
              child: Icon(item.icon, color: item.iconColor, size: 20),
            ),
            title: Text(
              '${item.type}: ${item.currency} ${item.amount}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Ref: ${item.reference}  |  ${item.date}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(160),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: item.statusColor.withAlpha(20),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: item.statusColor.withAlpha(60)),
              ),
              child: Text(
                item.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: item.statusColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static String _disbursementStatusLabel(DisbursementStatus s) {
    return switch (s) {
      DisbursementStatus.DISBURSEMENT_STATUS_PENDING => 'Pending',
      DisbursementStatus.DISBURSEMENT_STATUS_PROCESSING => 'Processing',
      DisbursementStatus.DISBURSEMENT_STATUS_COMPLETED => 'Completed',
      DisbursementStatus.DISBURSEMENT_STATUS_FAILED => 'Failed',
      DisbursementStatus.DISBURSEMENT_STATUS_REVERSED => 'Reversed',
      _ => 'Unknown',
    };
  }

  static Color _disbursementStatusColor(DisbursementStatus s) {
    return switch (s) {
      DisbursementStatus.DISBURSEMENT_STATUS_PENDING => Colors.orange,
      DisbursementStatus.DISBURSEMENT_STATUS_PROCESSING => Colors.blue,
      DisbursementStatus.DISBURSEMENT_STATUS_COMPLETED => Colors.green,
      DisbursementStatus.DISBURSEMENT_STATUS_FAILED => Colors.red,
      DisbursementStatus.DISBURSEMENT_STATUS_REVERSED => Colors.grey,
      _ => Colors.grey,
    };
  }

  static String _repaymentStatusLabel(RepaymentStatus s) {
    return switch (s) {
      RepaymentStatus.REPAYMENT_STATUS_PENDING => 'Pending',
      RepaymentStatus.REPAYMENT_STATUS_MATCHED => 'Matched',
      RepaymentStatus.REPAYMENT_STATUS_PARTIAL => 'Partial',
      RepaymentStatus.REPAYMENT_STATUS_OVERPAYMENT => 'Overpayment',
      RepaymentStatus.REPAYMENT_STATUS_REVERSED => 'Reversed',
      _ => 'Unknown',
    };
  }

  static Color _repaymentStatusColor(RepaymentStatus s) {
    return switch (s) {
      RepaymentStatus.REPAYMENT_STATUS_PENDING => Colors.orange,
      RepaymentStatus.REPAYMENT_STATUS_MATCHED => Colors.green,
      RepaymentStatus.REPAYMENT_STATUS_PARTIAL => Colors.amber,
      RepaymentStatus.REPAYMENT_STATUS_OVERPAYMENT => Colors.blue,
      RepaymentStatus.REPAYMENT_STATUS_REVERSED => Colors.grey,
      _ => Colors.grey,
    };
  }
}

class _TransactionItem {
  _TransactionItem({
    required this.date,
    required this.type,
    required this.amount,
    required this.currency,
    required this.reference,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.iconColor,
  });

  final String date;
  final String type;
  final String amount;
  final String currency;
  final String reference;
  final String status;
  final Color statusColor;
  final IconData icon;
  final Color iconColor;
}

// ---------------------------------------------------------------------------
// Penalties Tab
// ---------------------------------------------------------------------------

class _StatementTab extends ConsumerWidget {
  const _StatementTab({required this.loanAccountId});

  final String loanAccountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statementAsync = ref.watch(loanStatementProvider(loanAccountId));

    return statementAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $e'),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () =>
                  ref.invalidate(loanStatementProvider(loanAccountId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (statement) {
        if (statement.entries.isEmpty) {
          return const Center(child: Text('No statement entries yet'));
        }
        return ListView.separated(
          key: const Key('loan-statement'),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: statement.entries.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final entry = statement.entries[index];
            final isCredit =
                entry.hasCredit() &&
                (entry.credit.units > 0 || entry.credit.nanos > 0);
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(entry.description),
              subtitle: Text(
                [
                  entry.date,
                  if (entry.reference.isNotEmpty) entry.reference,
                ].join(' · '),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isCredit
                        ? '- ${formatLoanMoney(entry.credit)}'
                        : formatLoanMoney(entry.debit),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isCredit ? Colors.green.shade700 : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Balance ${formatLoanMoney(entry.balance)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PenaltiesTab extends ConsumerWidget {
  const _PenaltiesTab({required this.loanAccountId, required this.canManage});

  final String loanAccountId;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final penaltiesAsync = ref.watch(penaltyListProvider(loanAccountId));

    return penaltiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $e'),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () =>
                  ref.invalidate(penaltyListProvider(loanAccountId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (penalties) {
        if (penalties.isEmpty) {
          return const Center(child: Text('No penalties'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: penalties.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final penalty = penalties[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: CircleAvatar(
                  backgroundColor: penalty.isWaived
                      ? Colors.grey.withAlpha(20)
                      : Colors.red.withAlpha(20),
                  child: Icon(
                    Icons.warning_amber,
                    color: penalty.isWaived ? Colors.grey : Colors.red,
                    size: 20,
                  ),
                ),
                title: Text(
                  '${_penaltyTypeLabel(penalty.penaltyType)}: ${penalty.amount}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: penalty.isWaived
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: Text(
                  penalty.isWaived
                      ? 'Waived: ${penalty.waivedReason}'
                      : penalty.reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(160),
                  ),
                ),
                trailing: (!penalty.isWaived && canManage)
                    ? TextButton(
                        onPressed: () =>
                            _showWaiveDialog(context, ref, penalty),
                        child: const Text('Waive'),
                      )
                    : penalty.isWaived
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.withAlpha(60)),
                        ),
                        child: const Text(
                          'Waived',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  void _showWaiveDialog(
    BuildContext context,
    WidgetRef ref,
    PenaltyObject penalty,
  ) {
    final reasonCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Waive Penalty'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormFieldCard(
                  label: 'Reason',
                  description: 'Justification for waiving this penalty.',
                  isRequired: true,
                  child: TextFormField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(hintText: 'Enter reason'),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final reason = reasonCtrl.text.trim();
                if (reason.isEmpty) return;
                try {
                  await ref
                      .read(penaltyNotifierProvider.notifier)
                      .waive(id: penalty.id, reason: reason);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Penalty waived successfully'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to waive penalty: $e'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('Waive'),
            ),
          ],
        );
      },
    );
  }

  static String _penaltyTypeLabel(PenaltyType type) {
    return switch (type) {
      PenaltyType.PENALTY_TYPE_LATE_PAYMENT => 'Late Payment',
      PenaltyType.PENALTY_TYPE_DEFAULT => 'Default',
      PenaltyType.PENALTY_TYPE_EARLY_REPAYMENT => 'Early Repayment',
      PenaltyType.PENALTY_TYPE_BOUNCED_PAYMENT => 'Bounced Payment',
      _ => 'Unknown',
    };
  }
}

// ---------------------------------------------------------------------------
// Restructuring tab
// ---------------------------------------------------------------------------

class _RestructuringTab extends ConsumerWidget {
  const _RestructuringTab({
    required this.loanAccountId,
    required this.canManage,
    required this.canDecide,
  });

  final String loanAccountId;

  /// May request a restructure.
  final bool canManage;

  /// May approve or reject a pending restructure.
  final bool canDecide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final restructuresAsync = ref.watch(restructureListProvider(loanAccountId));

    return Column(
      children: [
        if (canManage)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _showCreateRestructureDialog(context, ref),
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: const Text('Request Restructure'),
                ),
              ],
            ),
          ),
        Expanded(
          child: restructuresAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (items) {
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_note_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurface.withAlpha(100),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No restructuring requests',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(140),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final r = items[index];
                  return _RestructureCard(
                    restructure: r,
                    canManage: canDecide,
                    onApprove: () async {
                      try {
                        await ref
                            .read(restructureNotifierProvider.notifier)
                            .approve(r.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Restructure approved'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to approve: $e'),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                    onReject: () => _showRejectDialog(context, ref, r.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCreateRestructureDialog(BuildContext context, WidgetRef ref) {
    final reasonCtrl = TextEditingController();
    final newRateCtrl = TextEditingController();
    final newTermCtrl = TextEditingController();
    var type = RestructureType.RESTRUCTURE_TYPE_RESCHEDULE;
    var saving = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Request Restructure'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormFieldCard(
                  label: 'Restructure Type',
                  description:
                      'The kind of restructuring to apply to this loan.',
                  isRequired: true,
                  child: DropdownButtonFormField<RestructureType>(
                    initialValue: type,
                    decoration: const InputDecoration(hintText: 'Select type'),
                    items: RestructureType.values
                        .where(
                          (t) =>
                              t != RestructureType.RESTRUCTURE_TYPE_UNSPECIFIED,
                        )
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(_restructureTypeLabel(t)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() => type = v ?? type),
                  ),
                ),
                FormFieldCard(
                  label: 'New Interest Rate (%)',
                  description: 'The revised annual interest rate for the loan.',
                  child: TextField(
                    controller: newRateCtrl,
                    decoration: const InputDecoration(hintText: 'e.g. 12.5'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                FormFieldCard(
                  label: 'New Term (days)',
                  description: 'The new repayment period in days.',
                  child: TextField(
                    controller: newTermCtrl,
                    decoration: const InputDecoration(hintText: 'e.g. 365'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                FormFieldCard(
                  label: 'Reason',
                  description: 'Why this restructuring is being requested.',
                  isRequired: true,
                  child: TextField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(hintText: 'Enter reason'),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      setDialogState(() => saving = true);
                      try {
                        final data = LoanRestructureObject(
                          loanAccountId: loanAccountId,
                          restructureType: type,
                          newInterestRate: newRateCtrl.text.trim(),
                          newTermDays:
                              int.tryParse(newTermCtrl.text.trim()) ?? 0,
                          reason: reasonCtrl.text.trim(),
                        );
                        await ref
                            .read(restructureNotifierProvider.notifier)
                            .create(data);
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Restructure request created'),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => saving = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed: $e'),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, String id) {
    final reasonCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Restructure'),
        content: SizedBox(
          width: 400,
          child: FormFieldCard(
            label: 'Reason',
            description:
                'Explain why this restructure request is being rejected.',
            isRequired: true,
            child: TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(hintText: 'Enter reason'),
              maxLines: 2,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref
                    .read(restructureNotifierProvider.notifier)
                    .reject(id, reasonCtrl.text.trim());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Restructure rejected')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  static String _restructureTypeLabel(RestructureType type) {
    return switch (type) {
      RestructureType.RESTRUCTURE_TYPE_RESCHEDULE => 'Reschedule',
      RestructureType.RESTRUCTURE_TYPE_REFINANCE => 'Refinance',
      RestructureType.RESTRUCTURE_TYPE_RATE_CHANGE => 'Rate Change',
      RestructureType.RESTRUCTURE_TYPE_PARTIAL_WAIVER => 'Partial Waiver',
      RestructureType.RESTRUCTURE_TYPE_WRITE_OFF => 'Write Off',
      _ => 'Unknown',
    };
  }
}

class _RestructureCard extends StatelessWidget {
  const _RestructureCard({
    required this.restructure,
    required this.canManage,
    required this.onApprove,
    required this.onReject,
  });

  final LoanRestructureObject restructure;
  final bool canManage;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending =
        restructure.state == STATE.CREATED ||
        restructure.state == STATE.CHECKED;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _typeColor(
                      restructure.restructureType,
                    ).withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _RestructuringTab._restructureTypeLabel(
                      restructure.restructureType,
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _typeColor(restructure.restructureType),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPending
                        ? Colors.orange.withAlpha(30)
                        : restructure.state == STATE.ACTIVE
                        ? Colors.green.withAlpha(30)
                        : Colors.red.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isPending
                        ? 'Pending'
                        : restructure.state == STATE.ACTIVE
                        ? 'Approved'
                        : 'Rejected',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isPending
                          ? Colors.orange
                          : restructure.state == STATE.ACTIVE
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
                const Spacer(),
                if (isPending && canManage) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        tooltip: 'Approve',
                        onPressed: onApprove,
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: 'Reject',
                        onPressed: onReject,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (restructure.reason.isNotEmpty) ...[
              Text(
                'Reason: ${restructure.reason}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                if (restructure.newInterestRate.isNotEmpty)
                  _DetailChip(
                    label: 'New Rate',
                    value: '${restructure.newInterestRate}%',
                  ),
                if (restructure.newTermDays > 0)
                  _DetailChip(
                    label: 'New Term',
                    value: '${restructure.newTermDays} days',
                  ),
                if (restructure.requestedBy.isNotEmpty)
                  _DetailChip(
                    label: 'Requested by',
                    value: restructure.requestedBy,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(RestructureType type) {
    return switch (type) {
      RestructureType.RESTRUCTURE_TYPE_RESCHEDULE => Colors.blue,
      RestructureType.RESTRUCTURE_TYPE_REFINANCE => Colors.indigo,
      RestructureType.RESTRUCTURE_TYPE_RATE_CHANGE => Colors.teal,
      RestructureType.RESTRUCTURE_TYPE_PARTIAL_WAIVER => Colors.orange,
      RestructureType.RESTRUCTURE_TYPE_WRITE_OFF => Colors.red,
      _ => Colors.grey,
    };
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(100),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status history tab
// ---------------------------------------------------------------------------

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab({required this.loanAccountId});
  final String loanAccountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final client = ref.watch(loanManagementServiceClientProvider);

    return FutureBuilder<List<LoanStatusChangeObject>>(
      future: _fetchStatusChanges(client, loanAccountId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final changes = snapshot.data ?? [];
        if (changes.isEmpty) {
          return const Center(child: Text('No status changes'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: changes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final change = changes[index];
            final fromLabel = _statusLabelFromInt(change.fromStatus);
            final toLabel = _statusLabelFromInt(change.toStatus);
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.tertiaryContainer,
                  child: Icon(
                    Icons.swap_horiz,
                    color: theme.colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                ),
                title: Text(
                  '$fromLabel  ->  $toLabel',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${change.changedAt}  |  By: ${change.changedBy}'
                  '${change.reason.isNotEmpty ? '  |  ${change.reason}' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(160),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<List<LoanStatusChangeObject>> _fetchStatusChanges(
    dynamic client,
    String loanAccountId,
  ) async {
    final results = <LoanStatusChangeObject>[];
    var pages = 0;
    await for (final response in client.loanStatusChangeSearch(
      LoanStatusChangeSearchRequest(
        loanAccountId: loanAccountId,
        cursor: PageCursor(limit: 100),
      ),
    )) {
      results.addAll(response.data);
      if (++pages >= 10 || response.data.isEmpty) break;
    }
    return results;
  }

  static String _statusLabelFromInt(int status) {
    return switch (status) {
      1 => 'Pending Disbursement',
      2 => 'Active',
      3 => 'Delinquent',
      4 => 'Default',
      5 => 'Paid Off',
      6 => 'Restructured',
      7 => 'Written Off',
      8 => 'Closed',
      _ => 'Unknown',
    };
  }
}

// ---------------------------------------------------------------------------
// Disbursement Form Dialog
// ---------------------------------------------------------------------------

class _DisbursementFormDialog extends StatefulWidget {
  const _DisbursementFormDialog({required this.loan, required this.onSave});

  final LoanAccountObject loan;
  final Future<void> Function(String idempotencyKey) onSave;

  @override
  State<_DisbursementFormDialog> createState() =>
      _DisbursementFormDialogState();
}

/// Confirms a disbursement. Staff choose nothing about where the money goes:
/// the principal is paid to the borrower's own verified mobile-money contact
/// on the loan, by the payment rail.
class _DisbursementFormDialogState extends State<_DisbursementFormDialog> {
  late final String _idempotencyKey;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _idempotencyKey = generateIdempotencyKey();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await widget.onSave(_idempotencyKey);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loan = widget.loan;
    final hasDestination = loan.paymentAccountRef.isNotEmpty;
    return AlertDialog(
      title: const Text('Disburse loan'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${formatLoanMoney(loan.principalAmount)} is paid to the '
              'borrower\'s own mobile-money number on this loan.',
            ),
            const SizedBox(height: 8),
            if (!hasDestination)
              Text(
                'This loan has no payout contact, so it cannot be disbursed.',
                key: const Key('disburse-no-destination'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('disburse-confirm'),
          onPressed: _saving || !hasDestination ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Disburse'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Record Payment Form Dialog
// ---------------------------------------------------------------------------

class _CollectPaymentFormDialog extends StatefulWidget {
  const _CollectPaymentFormDialog({
    required this.loanAccountId,
    required this.currencyCode,
    required this.onSave,
  });

  final String loanAccountId;
  final String currencyCode;
  final Future<void> Function(String amount, String idempotencyKey) onSave;

  @override
  State<_CollectPaymentFormDialog> createState() =>
      _CollectPaymentFormDialogState();
}

class _CollectPaymentFormDialogState extends State<_CollectPaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final String _idempotencyKey;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
    _idempotencyKey = generateIdempotencyKey();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(_amountCtrl.text.trim(), _idempotencyKey);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Collect Payment (${widget.currencyCode})'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormFieldCard(
                label: 'Amount',
                description: 'The amount to collect from the borrower.',
                isRequired: true,
                child: TextFormField(
                  controller: _amountCtrl,
                  decoration: const InputDecoration(hintText: '0.00'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: validateAmount,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'The prompt is sent to the borrower\'s registered mobile '
                  'number on their profile.',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send Prompt'),
        ),
      ],
    );
  }
}
