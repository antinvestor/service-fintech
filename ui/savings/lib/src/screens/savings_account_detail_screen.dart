import 'package:antinvestor_api_savings/antinvestor_api_savings.dart'
    hide PageCursor, STATE;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/savings_providers.dart';

class SavingsAccountDetailScreen extends ConsumerStatefulWidget {
  const SavingsAccountDetailScreen({super.key, required this.accountId});
  final String accountId;

  @override
  ConsumerState<SavingsAccountDetailScreen> createState() =>
      _SavingsAccountDetailScreenState();
}

class _SavingsAccountDetailScreenState
    extends ConsumerState<SavingsAccountDetailScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountAsync = ref.watch(
      savingsAccountDetailProvider(widget.accountId),
    );
    final balanceAsync = ref.watch(savingsBalanceProvider(widget.accountId));

    return accountAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load account: $error'),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => ref.invalidate(
                savingsAccountDetailProvider(widget.accountId),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (account) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/savings'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Savings Account',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        children: [
                          EntityChip(
                            config: const EntityChipConfig(
                              icon: Icons.person_outline,
                              color: Colors.indigo,
                            ),
                            id: account.ownerId,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: account.status),
              ],
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
                  child: Text('Balance unavailable: $e'),
                ),
              ),
              data: (balance) => Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  formatMoney(balance.availableBalance),
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Deposits',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  formatMoney(balance.totalDeposits),
                                  style: theme.textTheme.bodyLarge?.copyWith(
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
                                Text(
                                  'Total Withdrawals',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  formatMoney(balance.totalWithdrawals),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (account.status ==
                    SavingsAccountStatus.SAVINGS_ACCOUNT_STATUS_ACTIVE) ...[
                  FilledButton.icon(
                    onPressed: () => _showDepositDialog(context, account),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Record Deposit'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showWithdrawalDialog(context, account),
                    icon: const Icon(Icons.remove, size: 18),
                    label: const Text('Request Withdrawal'),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Deposits'),
              Tab(text: 'Withdrawals'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _DepositsTab(accountId: widget.accountId),
                _WithdrawalsTab(accountId: widget.accountId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositDialog(BuildContext context, SavingsAccountObject account) {
    final amountCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    var saving = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Record Deposit'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormFieldCard(
                  label: 'Amount',
                  description:
                      'The amount to deposit into this savings account.',
                  isRequired: true,
                  child: TextField(
                    controller: amountCtrl,
                    decoration: const InputDecoration(hintText: '0.00'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                FormFieldCard(
                  label: 'Payment Reference',
                  description:
                      'Optional description or reason for this transaction.',
                  child: TextField(
                    controller: refCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. TXN-12345',
                    ),
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
                        await ref
                            .read(depositNotifierProvider.notifier)
                            .record(
                              savingsAccountId: account.id,
                              amount: amountCtrl.text.trim(),
                              currencyCode: account.currencyCode,
                              paymentReference: refCtrl.text.trim(),
                            );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Deposit recorded')),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => saving = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                        }
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Record'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawalDialog(
    BuildContext context,
    SavingsAccountObject account,
  ) {
    final amountCtrl = TextEditingController();
    var saving = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Request Withdrawal'),
          content: SizedBox(
            width: 400,
            child: FormFieldCard(
              label: 'Amount',
              description: 'The amount to withdraw from this savings account.',
              isRequired: true,
              child: TextField(
                controller: amountCtrl,
                decoration: const InputDecoration(hintText: '0.00'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
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
                        await ref
                            .read(withdrawalNotifierProvider.notifier)
                            .request(
                              savingsAccountId: account.id,
                              amount: amountCtrl.text.trim(),
                              currencyCode: account.currencyCode,
                            );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Withdrawal requested'),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => saving = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                        }
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Request'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final SavingsAccountStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      SavingsAccountStatus.SAVINGS_ACCOUNT_STATUS_ACTIVE => (
        'Active',
        Colors.green,
      ),
      SavingsAccountStatus.SAVINGS_ACCOUNT_STATUS_FROZEN => (
        'Frozen',
        Colors.blue,
      ),
      SavingsAccountStatus.SAVINGS_ACCOUNT_STATUS_CLOSED => (
        'Closed',
        Colors.grey,
      ),
      _ => ('Unknown', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Deposits Tab
// ---------------------------------------------------------------------------

class _DepositsTab extends ConsumerWidget {
  const _DepositsTab({required this.accountId});
  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final depositsAsync = ref.watch(depositListProvider(accountId));

    return depositsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (deposits) {
        if (deposits.isEmpty) {
          return const Center(child: Text('No deposits recorded'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: deposits.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final d = deposits[index];
            return Card(
              elevation: 0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withAlpha(20),
                  child: const Icon(
                    Icons.arrow_downward,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                title: Text(
                  formatMoney(d.amount),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Ref: ${d.paymentReference}  |  ${d.channel}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: _DepositStatusChip(status: d.status),
              ),
            );
          },
        );
      },
    );
  }
}

class _DepositStatusChip extends StatelessWidget {
  const _DepositStatusChip({required this.status});
  final DepositStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      DepositStatus.DEPOSIT_STATUS_PENDING => ('Pending', Colors.orange),
      DepositStatus.DEPOSIT_STATUS_COMPLETED => ('Completed', Colors.green),
      DepositStatus.DEPOSIT_STATUS_REVERSED => ('Reversed', Colors.red),
      _ => ('Unknown', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
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
// Withdrawals Tab
// ---------------------------------------------------------------------------

class _WithdrawalsTab extends ConsumerWidget {
  const _WithdrawalsTab({required this.accountId});
  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final withdrawalsAsync = ref.watch(withdrawalListProvider(accountId));

    return withdrawalsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (withdrawals) {
        if (withdrawals.isEmpty) {
          return const Center(child: Text('No withdrawals recorded'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: withdrawals.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final w = withdrawals[index];
            return Card(
              elevation: 0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.withAlpha(20),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                title: Text(
                  formatMoney(w.amount),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  w.reason.isNotEmpty ? w.reason : w.channel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: _WithdrawalStatusChip(status: w.status),
              ),
            );
          },
        );
      },
    );
  }
}

class _WithdrawalStatusChip extends StatelessWidget {
  const _WithdrawalStatusChip({required this.status});
  final WithdrawalStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      WithdrawalStatus.WITHDRAWAL_STATUS_PENDING => ('Pending', Colors.orange),
      WithdrawalStatus.WITHDRAWAL_STATUS_APPROVED => ('Approved', Colors.blue),
      WithdrawalStatus.WITHDRAWAL_STATUS_COMPLETED => (
        'Completed',
        Colors.green,
      ),
      WithdrawalStatus.WITHDRAWAL_STATUS_REJECTED => ('Rejected', Colors.red),
      WithdrawalStatus.WITHDRAWAL_STATUS_REVERSED => ('Reversed', Colors.grey),
      _ => ('Unknown', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
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
