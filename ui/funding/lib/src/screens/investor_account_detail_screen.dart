import 'package:antinvestor_api_funding/antinvestor_api_funding.dart'
    hide PageCursor, STATE;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/funding_providers.dart';
import '../utils/money_bridge.dart';
import '../utils/money_display.dart';
import '../widgets/investor_statement_card.dart';
import '../widgets/money_amount_dialog.dart';
import 'investor_accounts_screen.dart' show accountLabel;

class InvestorAccountDetailScreen extends ConsumerWidget {
  const InvestorAccountDetailScreen({
    super.key,
    required this.accountId,
    this.canManage = false,
  });

  final String accountId;

  /// investor_account_manage: withdraw. Capital arrives only when the
  /// investor pays, quoting this account; nobody records it by hand.
  final bool canManage;

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
          _DepositInstructions(accountId: accountId),
          const SizedBox(height: 16),
          if (canManage) ...[
            _ActionButtons(
              accountId: accountId,
              currencyCode: moneyCurrency(account.availableBalance, 'KES'),
              canManage: canManage,
            ),
            const SizedBox(height: 24),
          ],

          InvestorStatementCard(accountId: accountId),
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
// Deposits
// ---------------------------------------------------------------------------

/// How capital reaches this account: the investor pays from their own
/// mobile money or bank, quoting the account, and the payment rail records
/// it. Staff never record a deposit.
class _DepositInstructions extends StatelessWidget {
  const _DepositInstructions({required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('funding-deposit-instructions'),
      elevation: 0,
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('Adding capital'),
        subtitle: SelectableText(
          'The investor pays from their own account, quoting $accountId as '
          'the reference. The payment is credited here when it arrives.',
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({
    required this.accountId,
    required this.currencyCode,
    required this.canManage,
  });
  final String accountId;
  final String currencyCode;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        if (canManage) ...[
          OutlinedButton.icon(
            key: const Key('funding-action-withdraw'),
            onPressed: () => _showWithdrawDialog(context, ref),
            icon: const Icon(Icons.remove),
            label: const Text('Withdraw'),
          ),
        ],
      ],
    );
  }

  Future<void> _showWithdrawDialog(BuildContext context, WidgetRef ref) async {
    final done = await showDialog<bool>(
      context: context,
      builder: (ctx) => MoneyAmountDialog(
        title: 'Withdraw Funds',
        confirmLabel: 'Withdraw',
        currencyCode: currencyCode,
        description: "Paid to the investor's own verified mobile-money number.",
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
