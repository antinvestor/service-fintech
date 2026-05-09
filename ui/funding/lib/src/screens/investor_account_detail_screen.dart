import 'package:antinvestor_api_funding/antinvestor_api_funding.dart'
    hide PageCursor, STATE;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';

import '../utils/money_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/funding_providers.dart';

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
            Text('Error: $err'),
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
                      account.accountName.isNotEmpty
                          ? account.accountName
                          : 'Investor Account',
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
              value: account.hasAvailableBalance()
                  ? formatMoney(account.availableBalance)
                  : '-',
              icon: Icons.account_balance_wallet,
              color: Colors.green,
            ),
            _MetricCard(
              label: 'Reserved',
              value: account.hasReservedBalance()
                  ? formatMoney(account.reservedBalance)
                  : '-',
              icon: Icons.lock_outline,
              color: Colors.orange,
            ),
            _MetricCard(
              label: 'Total Deployed',
              value: account.hasTotalDeployed()
                  ? formatMoney(account.totalDeployed)
                  : '-',
              icon: Icons.trending_up,
              color: Colors.blue,
            ),
            _MetricCard(
              label: 'Total Returned',
              value: account.hasTotalReturned()
                  ? formatMoney(account.totalReturned)
                  : '-',
              icon: Icons.trending_down,
              color: Colors.purple,
            ),
            _MetricCard(
              label: 'Max Exposure',
              value: account.hasMaxExposure()
                  ? formatMoney(account.maxExposure)
                  : '-',
              icon: Icons.shield_outlined,
              color: Colors.red,
            ),
            _MetricCard(
              label: 'Min Interest Rate',
              value: account.minInterestRate.isNotEmpty
                  ? '${account.minInterestRate}%'
                  : '-',
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
          onPressed: () => _showDepositDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Deposit'),
        ),
        OutlinedButton.icon(
          onPressed: () => _showWithdrawDialog(context, ref),
          icon: const Icon(Icons.remove),
          label: const Text('Withdraw'),
        ),
        OutlinedButton.icon(
          onPressed: () => _showFundLoanDialog(context, ref),
          icon: const Icon(Icons.send),
          label: const Text('Fund Loan'),
        ),
      ],
    );
  }

  void _showDepositDialog(BuildContext context, WidgetRef ref) {
    final amountCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deposit Funds'),
        content: SizedBox(
          width: 380,
          child: FormFieldCard(
            label: 'Amount',
            child: TextFormField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '0.00'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final amount = amountCtrl.text.trim();
              Navigator.pop(ctx);
              try {
                await ref
                    .read(investorAccountNotifierProvider.notifier)
                    .deposit(
                      accountId: accountId,
                      amount: amount,
                      currencyCode: currencyCode,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deposit recorded')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, WidgetRef ref) {
    final amountCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Funds'),
        content: SizedBox(
          width: 380,
          child: FormFieldCard(
            label: 'Amount',
            child: TextFormField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '0.00'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final amount = amountCtrl.text.trim();
              Navigator.pop(ctx);
              try {
                await ref
                    .read(investorAccountNotifierProvider.notifier)
                    .withdraw(
                      accountId: accountId,
                      amount: amount,
                      currencyCode: currencyCode,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Withdrawal processed')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  void _showFundLoanDialog(BuildContext context, WidgetRef ref) {
    final loanReqCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fund Loan'),
        content: SizedBox(
          width: 380,
          child: FormFieldCard(
            label: 'Loan Request ID',
            child: TextFormField(
              controller: loanReqCtrl,
              decoration: const InputDecoration(
                hintText: 'Enter loan request ID to fund',
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final loanRequestId = loanReqCtrl.text.trim();
              if (loanRequestId.isEmpty) return;
              Navigator.pop(ctx);
              try {
                final result = await ref
                    .read(investorAccountNotifierProvider.notifier)
                    .fundLoan(
                      loanRequestId: loanRequestId,
                      accountId: accountId,
                    );
                if (context.mounted) {
                  final msg = result.fullyFunded
                      ? 'Loan fully funded (${formatMoney(result.totalAllocated)})'
                      : 'Partially funded (deficit: ${formatMoney(result.deficit)})';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg)),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
            child: const Text('Fund'),
          ),
        ],
      ),
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
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
