import 'package:antinvestor_api_funding/antinvestor_api_funding.dart'
    hide PageCursor, STATE;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/funding_providers.dart';
import '../utils/money_bridge.dart';
import '../utils/money_display.dart';
import '../widgets/absorb_loss_dialog.dart';
import '../widgets/money_amount_dialog.dart';
import 'investor_accounts_screen.dart' show accountLabel;

class InvestorAccountDetailScreen extends ConsumerWidget {
  const InvestorAccountDetailScreen({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(investorAccountDetailProvider(accountId));
    final theme = Theme.of(context);

    return accountAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load this account: $err'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () =>
                  ref.invalidate(investorAccountDetailProvider(accountId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (account) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accountLabel(account),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${account.id}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              StateBadge(state: bridgeState(account.state)),
            ],
          ),
          const SizedBox(height: 24),

          // Balance Cards
          _BalanceSummary(account: account),
          const SizedBox(height: 24),

          // Actions
          _ActionButtons(
            accountId: accountId,
            currencyCode: moneyCurrency(account.availableBalance, 'KES'),
          ),
          const SizedBox(height: 24),

          // Details
          _AccountDetailsCard(account: account),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Balance summary grid
// ---------------------------------------------------------------------------

class _BalanceSummary extends StatelessWidget {
  const _BalanceSummary({required this.account});
  final InvestorAccountObject account;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _MetricCard(
              label: 'Available',
              value: displayMoney(account.availableBalance),
              icon: Icons.account_balance_wallet,
              color: Colors.green,
            ),
            _MetricCard(
              label: 'Reserved',
              value: displayMoney(account.reservedBalance),
              icon: Icons.lock_outline,
              color: Colors.orange,
            ),
            _MetricCard(
              label: 'Total Deployed',
              value: displayMoney(account.totalDeployed),
              icon: Icons.trending_up,
              color: Colors.blue,
            ),
            _MetricCard(
              label: 'Total Returned',
              value: displayMoney(account.totalReturned),
              icon: Icons.trending_down,
              color: Colors.purple,
            ),
            _MetricCard(
              label: 'Max Exposure',
              value: displayMoney(account.maxExposure),
              icon: Icons.shield_outlined,
              color: Colors.red,
            ),
            _MetricCard(
              label: 'Min Interest Rate',
              value: account.minInterestRate.isNotEmpty
                  ? '${account.minInterestRate}%'
                  : '0.00%',
              icon: Icons.percent,
              color: Colors.teal,
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.accountId, required this.currencyCode});
  final String accountId;
  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          key: const Key('funding-action-deposit'),
          onPressed: () => _showDepositDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Deposit'),
        ),
        OutlinedButton.icon(
          key: const Key('funding-action-withdraw'),
          onPressed: () => _showWithdrawDialog(context, ref),
          icon: const Icon(Icons.remove),
          label: const Text('Withdraw'),
        ),
        OutlinedButton.icon(
          key: const Key('funding-action-fund-loan'),
          onPressed: () => _showFundLoanDialog(context, ref),
          icon: const Icon(Icons.send),
          label: const Text('Fund Loan'),
        ),
        OutlinedButton.icon(
          key: const Key('funding-action-absorb-loss'),
          onPressed: () => _showAbsorbLossDialog(context, ref),
          icon: const Icon(Icons.trending_down),
          label: const Text('Absorb Loss'),
        ),
      ],
    );
  }

  Future<void> _showDepositDialog(BuildContext context, WidgetRef ref) async {
    final done = await showDialog<bool>(
      context: context,
      builder: (ctx) => MoneyAmountDialog(
        title: 'Deposit Funds',
        confirmLabel: 'Deposit',
        currencyCode: currencyCode,
        description: 'Capital added to this investor account.',
        onSubmit: (amount, _, idempotencyKey) => ref
            .read(investorAccountNotifierProvider.notifier)
            .deposit(
              accountId: accountId,
              amount: amount,
              currencyCode: currencyCode,
              idempotencyKey: idempotencyKey,
            ),
      ),
    );
    if (!context.mounted) return;
    _toast(context, done, 'Deposit recorded');
  }

  Future<void> _showWithdrawDialog(BuildContext context, WidgetRef ref) async {
    final done = await showDialog<bool>(
      context: context,
      builder: (ctx) => MoneyAmountDialog(
        title: 'Withdraw Funds',
        confirmLabel: 'Withdraw',
        currencyCode: currencyCode,
        description: 'Capital returned out of this investor account.',
        onSubmit: (amount, _, idempotencyKey) => ref
            .read(investorAccountNotifierProvider.notifier)
            .withdraw(
              accountId: accountId,
              amount: amount,
              currencyCode: currencyCode,
              idempotencyKey: idempotencyKey,
            ),
      ),
    );
    if (!context.mounted) return;
    _toast(context, done, 'Withdrawal processed');
  }

  Future<void> _showFundLoanDialog(BuildContext context, WidgetRef ref) async {
    final loanRequestId = await showDialog<String>(
      context: context,
      builder: (ctx) =>
          const _LoanRequestDialog(title: 'Fund Loan', confirmLabel: 'Fund'),
    );
    if (loanRequestId == null || !context.mounted) return;

    try {
      final result = await ref
          .read(investorAccountNotifierProvider.notifier)
          .fundLoan(loanRequestId: loanRequestId, accountId: accountId);
      if (!context.mounted) return;
      final message = result.fullyFunded
          ? 'Loan fully funded (${displayMoney(result.totalAllocated)})'
          : 'Partially funded, deficit ${displayMoney(result.deficit)}';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!context.mounted) return;
      _toast(context, false, '', error: error);
    }
  }

  Future<void> _showAbsorbLossDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    AbsorbLossResponse? outcome;
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AbsorbLossDialog(
        currencyCode: currencyCode,
        onSubmit: (loanRequestId, amount, idempotencyKey) async {
          outcome = await ref
              .read(investorAccountNotifierProvider.notifier)
              .absorbLoss(
                loanRequestId: loanRequestId,
                amount: amount,
                currencyCode: currencyCode,
                idempotencyKey: idempotencyKey,
                accountId: accountId,
              );
        },
      ),
    );

    final result = outcome;
    if (result == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Absorbed ${displayMoney(result.absorbed)}, '
          'unrecoverable ${displayMoney(result.unrecoverable)}',
        ),
      ),
    );
  }

  void _toast(
    BuildContext context,
    bool? done,
    String message, {
    Object? error,
  }) {
    if (!context.mounted) return;
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

/// Asks for the loan request an action applies to.
class _LoanRequestDialog extends StatefulWidget {
  const _LoanRequestDialog({required this.title, required this.confirmLabel});

  final String title;
  final String confirmLabel;

  @override
  State<_LoanRequestDialog> createState() => _LoanRequestDialogState();
}

class _LoanRequestDialogState extends State<_LoanRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: FormFieldCard(
            label: 'Loan Request ID',
            isRequired: true,
            child: TextFormField(
              key: const Key('loan-request-id-field'),
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Enter loan request ID',
              ),
              validator: (v) => validateRequired(v, 'Loan request ID'),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('loan-request-submit'),
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(context, _controller.text.trim());
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Account details card
// ---------------------------------------------------------------------------

class _AccountDetailsCard extends StatelessWidget {
  const _AccountDetailsCard({required this.account});
  final InvestorAccountObject account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Details',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Account ID', value: account.id),
            _DetailRow(label: 'Investor ID', value: account.investorId),
            _DetailRow(label: 'Account Name', value: account.accountName),
            if (account.minInterestRate.isNotEmpty)
              _DetailRow(
                label: 'Min Interest Rate',
                value: '${account.minInterestRate}%',
              ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
