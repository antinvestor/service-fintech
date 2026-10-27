import 'package:antinvestor_api_savings/antinvestor_api_savings.dart'
    hide PageCursor, STATE;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/savings_providers.dart';
import '../utils/money_display.dart';
import '../widgets/money_amount_dialog.dart';
import 'savings_accounts_screen.dart' show statusInfo;

class SavingsAccountDetailScreen extends ConsumerStatefulWidget {
  const SavingsAccountDetailScreen({
    super.key,
    required this.accountId,
    this.canManageAccount = false,
    this.canWithdraw = false,
  });
  final String accountId;

  /// savings_account_manage: freeze and close.
  final bool canManageAccount;

  /// withdrawal_manage: request a withdrawal, paid to the saver's own
  /// profile. Deposits are never recorded here: they come from the saver's
  /// own payment, matched by the payment rail.
  final bool canWithdraw;

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
    _tabController = TabController(length: 3, vsync: this);
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
              key: const Key('account-detail-retry'),
              onPressed: () => ref.invalidate(
                savingsAccountDetailProvider(widget.accountId),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: _buildAccount,
    );
  }

  Widget _buildAccount(SavingsAccountObject account) {
    final theme = Theme.of(context);
    final (statusLabel, statusColor) = statusInfo(account.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
              _Pill(label: statusLabel, color: statusColor),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: _BalanceCard(accountId: widget.accountId),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: _AccountActions(
            account: account,
            canManageAccount: widget.canManageAccount,
            canWithdraw: widget.canWithdraw,
            onWithdraw: () => _showWithdrawalDialog(account),
            onFreeze: () => _confirmLifecycle(
              account,
              title: 'Freeze account',
              prompt:
                  'Freezing blocks deposits and withdrawals until the account '
                  'is reactivated.',
              confirmLabel: 'Freeze',
              action: (reason) => ref
                  .read(savingsAccountNotifierProvider.notifier)
                  .freeze(account.id, reason),
            ),
            onClose: () => _confirmLifecycle(
              account,
              title: 'Close account',
              prompt:
                  'Closing is permanent. The account must hold no funds and no '
                  'pending withdrawals.',
              confirmLabel: 'Close',
              action: (reason) => ref
                  .read(savingsAccountNotifierProvider.notifier)
                  .close(account.id, reason),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Deposits'),
            Tab(text: 'Withdrawals'),
            Tab(text: 'Interest'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _DepositsTab(accountId: widget.accountId),
              _WithdrawalsTab(account: account),
              _InterestTab(accountId: widget.accountId),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showWithdrawalDialog(SavingsAccountObject account) async {
    final done = await showDialog<bool>(
      context: context,
      builder: (ctx) => MoneyAmountDialog(
        title: 'Request Withdrawal',
        confirmLabel: 'Request',
        currencyCode: account.currencyCode,
        description: 'The amount to withdraw from this savings account.',
        referenceLabel: 'Reason',
        referenceHint: 'Why is this withdrawal being made?',
        onSubmit: (amount, reference, idempotencyKey) => ref
            .read(withdrawalNotifierProvider.notifier)
            .request(
              savingsAccountId: account.id,
              amount: amount,
              currencyCode: account.currencyCode,
              idempotencyKey: idempotencyKey,
              reason: reference,
            ),
      ),
    );
    _notify(done, 'Withdrawal requested');
  }

  Future<void> _confirmLifecycle(
    SavingsAccountObject account, {
    required String title,
    required String prompt,
    required String confirmLabel,
    required Future<void> Function(String reason) action,
  }) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => _ReasonDialog(
        title: title,
        prompt: prompt,
        confirmLabel: confirmLabel,
      ),
    );
    if (reason == null) return;

    try {
      await action(reason);
      _notify(true, '$confirmLabel complete');
    } catch (error) {
      _notify(false, '', error: error);
    }
  }

  void _notify(bool? done, String message, {Object? error}) {
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $error')));
      return;
    }
    if (done != true) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

// ---------------------------------------------------------------------------
// Balance card
// ---------------------------------------------------------------------------

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard({required this.accountId});
  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final balanceAsync = ref.watch(savingsBalanceProvider(accountId));

    return balanceAsync.when(
      loading: () => const Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: Text('Balance unavailable: $error')),
              TextButton(
                key: const Key('balance-retry'),
                onPressed: () =>
                    ref.invalidate(savingsBalanceProvider(accountId)),
                child: const Text('Retry'),
              ),
            ],
          ),
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
                    child: _BalanceFigure(
                      label: 'Available',
                      value: displayMoney(balance.availableBalance),
                      emphasise: true,
                    ),
                  ),
                  Expanded(
                    child: _BalanceFigure(
                      label: 'Total Deposits',
                      value: displayMoney(balance.totalDeposits),
                    ),
                  ),
                  Expanded(
                    child: _BalanceFigure(
                      label: 'Total Withdrawals',
                      value: displayMoney(balance.totalWithdrawals),
                    ),
                  ),
                  Expanded(
                    child: _BalanceFigure(
                      label: 'Total Interest',
                      value: displayMoney(balance.totalInterest),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceFigure extends StatelessWidget {
  const _BalanceFigure({
    required this.label,
    required this.value,
    this.emphasise = false,
  });

  final String label;
  final String value;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
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
          style: emphasise
              ? theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                )
              : theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Actions
// ---------------------------------------------------------------------------

class _AccountActions extends StatelessWidget {
  const _AccountActions({
    required this.account,
    required this.canManageAccount,
    required this.canWithdraw,
    required this.onWithdraw,
    required this.onFreeze,
    required this.onClose,
  });

  final SavingsAccountObject account;
  final bool canManageAccount;
  final bool canWithdraw;
  final VoidCallback onWithdraw;
  final VoidCallback onFreeze;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isActive =
        account.status == SavingsAccountStatus.SAVINGS_ACCOUNT_STATUS_ACTIVE;
    final isClosed =
        account.status == SavingsAccountStatus.SAVINGS_ACCOUNT_STATUS_CLOSED;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (isActive && canWithdraw)
          OutlinedButton.icon(
            key: const Key('action-withdraw'),
            onPressed: onWithdraw,
            icon: const Icon(Icons.remove, size: 18),
            label: const Text('Request Withdrawal'),
          ),
        if (isActive && canManageAccount)
          OutlinedButton.icon(
            key: const Key('action-freeze'),
            onPressed: onFreeze,
            icon: const Icon(Icons.ac_unit, size: 18),
            label: const Text('Freeze'),
          ),
        if (!isClosed && canManageAccount)
          OutlinedButton.icon(
            key: const Key('action-close'),
            onPressed: onClose,
            icon: const Icon(Icons.lock_outline, size: 18),
            label: const Text('Close'),
          ),
        OutlinedButton.icon(
          key: const Key('action-statement'),
          onPressed: () => context.go('/savings/${account.id}/statement'),
          icon: const Icon(Icons.receipt_long_outlined, size: 18),
          label: const Text('Statement'),
        ),
      ],
    );
  }
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({
    required this.title,
    required this.prompt,
    required this.confirmLabel,
  });

  final String title;
  final String prompt;
  final String confirmLabel;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: FormFieldCard(
            label: 'Reason',
            description: widget.prompt,
            isRequired: true,
            child: TextFormField(
              key: const Key('reason-field'),
              controller: _reasonCtrl,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Why?'),
              validator: (v) => validateRequired(v, 'Reason'),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('reason-submit'),
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.of(context).pop(_reasonCtrl.text.trim());
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
// Tabs
// ---------------------------------------------------------------------------

class _TabStates extends StatelessWidget {
  const _TabStates({
    required this.child,
    required this.onRetry,
    required this.error,
    required this.loading,
    required this.empty,
    required this.emptyMessage,
  });

  final Widget child;
  final VoidCallback onRetry;
  final Object? error;
  final bool loading;
  final bool empty;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load: $error'),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (empty) {
      return Center(child: Text(emptyMessage));
    }
    return child;
  }
}

class _DepositsTab extends ConsumerWidget {
  const _DepositsTab({required this.accountId});
  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(depositListProvider(accountId));
    final deposits = async.asData?.value ?? const <DepositObject>[];

    return _TabStates(
      loading: async.isLoading && !async.hasValue,
      error: async.hasError ? async.error : null,
      empty: deposits.isEmpty,
      emptyMessage: 'No deposits recorded',
      onRetry: () => ref.invalidate(depositListProvider(accountId)),
      child: ListView.separated(
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
                displayMoney(d.amount),
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
              trailing: _Pill(
                label: depositStatusLabel(d.status).$1,
                color: depositStatusLabel(d.status).$2,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Label and colour for every deposit status the contract defines.
(String, Color) depositStatusLabel(DepositStatus status) {
  return switch (status) {
    DepositStatus.DEPOSIT_STATUS_PENDING => ('Pending', Colors.orange),
    DepositStatus.DEPOSIT_STATUS_COMPLETED => ('Completed', Colors.green),
    DepositStatus.DEPOSIT_STATUS_REVERSED => ('Reversed', Colors.red),
    DepositStatus.DEPOSIT_STATUS_UNSPECIFIED => ('Unspecified', Colors.grey),
    _ => ('Unknown', Colors.grey),
  };
}

class _WithdrawalsTab extends ConsumerWidget {
  const _WithdrawalsTab({required this.account});
  final SavingsAccountObject account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(withdrawalListProvider(account.id));
    final withdrawals = async.asData?.value ?? const <WithdrawalObject>[];

    return _TabStates(
      loading: async.isLoading && !async.hasValue,
      error: async.hasError ? async.error : null,
      empty: withdrawals.isEmpty,
      emptyMessage: 'No withdrawals recorded',
      onRetry: () => ref.invalidate(withdrawalListProvider(account.id)),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: withdrawals.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final w = withdrawals[index];
          final pending =
              w.status == WithdrawalStatus.WITHDRAWAL_STATUS_PENDING;
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
                displayMoney(w.amount),
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (pending) ...[
                    TextButton(
                      key: Key('withdrawal-approve-${w.id}'),
                      onPressed: () => _approve(context, ref, w),
                      child: const Text('Approve'),
                    ),
                    TextButton(
                      key: Key('withdrawal-cancel-${w.id}'),
                      onPressed: () => _cancel(context, ref, w),
                      child: const Text('Cancel'),
                    ),
                  ],
                  _Pill(
                    label: withdrawalStatusLabel(w.status).$1,
                    color: withdrawalStatusLabel(w.status).$2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _approve(
    BuildContext context,
    WidgetRef ref,
    WithdrawalObject withdrawal,
  ) async {
    try {
      await ref
          .read(withdrawalNotifierProvider.notifier)
          .approve(withdrawal.id, account.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Withdrawal approved')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $error')));
      }
    }
  }

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    WithdrawalObject withdrawal,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => const _ReasonDialog(
        title: 'Cancel withdrawal',
        prompt: 'The held funds are returned to the member immediately.',
        confirmLabel: 'Cancel withdrawal',
      ),
    );
    if (reason == null) return;

    try {
      await ref
          .read(withdrawalNotifierProvider.notifier)
          .cancel(withdrawal.id, account.id, reason);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Withdrawal cancelled')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $error')));
      }
    }
  }
}

/// Label and colour for every withdrawal status the contract defines.
(String, Color) withdrawalStatusLabel(WithdrawalStatus status) {
  return switch (status) {
    WithdrawalStatus.WITHDRAWAL_STATUS_PENDING => ('Pending', Colors.orange),
    WithdrawalStatus.WITHDRAWAL_STATUS_APPROVED => ('Approved', Colors.blue),
    WithdrawalStatus.WITHDRAWAL_STATUS_COMPLETED => ('Completed', Colors.green),
    WithdrawalStatus.WITHDRAWAL_STATUS_REJECTED => ('Rejected', Colors.red),
    WithdrawalStatus.WITHDRAWAL_STATUS_REVERSED => ('Reversed', Colors.grey),
    WithdrawalStatus.WITHDRAWAL_STATUS_UNSPECIFIED => (
      'Unspecified',
      Colors.grey,
    ),
    _ => ('Unknown', Colors.grey),
  };
}

class _InterestTab extends ConsumerWidget {
  const _InterestTab({required this.accountId});
  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(interestAccrualListProvider(accountId));
    final accruals = async.asData?.value ?? const <InterestAccrualObject>[];

    return _TabStates(
      loading: async.isLoading && !async.hasValue,
      error: async.hasError ? async.error : null,
      empty: accruals.isEmpty,
      emptyMessage: 'No interest accrued yet',
      onRetry: () => ref.invalidate(interestAccrualListProvider(accountId)),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: accruals.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final accrual = accruals[index];
          return Card(
            elevation: 0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.withAlpha(20),
                child: const Icon(Icons.percent, color: Colors.teal, size: 20),
              ),
              title: Text(
                displayMoney(accrual.amount),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${accrual.periodStart} → ${accrual.periodEnd} '
                'at ${accrual.rateApplied}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
