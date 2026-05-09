import 'package:antinvestor_api_funding/antinvestor_api_funding.dart'
    hide PageCursor, STATE;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';

import '../utils/money_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/funding_providers.dart';

class InvestorAccountsScreen extends ConsumerStatefulWidget {
  const InvestorAccountsScreen({super.key});

  @override
  ConsumerState<InvestorAccountsScreen> createState() =>
      _InvestorAccountsScreenState();
}

class _InvestorAccountsScreenState
    extends ConsumerState<InvestorAccountsScreen> {
  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(
      investorAccountListProvider((investorId: '')),
    );
    final accounts = accountsAsync.whenOrNull(data: (d) => d) ?? [];

    return AdminEntityListPage<InvestorAccountObject>(
      title: 'Investor Accounts',
      breadcrumbs: const ['Funding', 'Accounts'],
      columns: const [
        DataColumn(label: Text('NAME')),
        DataColumn(label: Text('BALANCE')),
        DataColumn(label: Text('DEPLOYED')),
        DataColumn(label: Text('STATE')),
      ],
      items: accounts,
      addLabel: 'New Account',
      onAdd: () => _showCreateDialog(context),
      rowBuilder: (account, selected, onSelect) {
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
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.account_balance_wallet,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(account.accountName.isNotEmpty
                      ? account.accountName
                      : 'Account ${account.id.length > 8 ? account.id.substring(0, 8) : account.id}'),
                ],
              ),
            ),
            DataCell(Text(account.hasAvailableBalance()
                ? formatMoney(account.availableBalance)
                : '-')),
            DataCell(Text(account.hasTotalDeployed()
                ? formatMoney(account.totalDeployed)
                : '-')),
            DataCell(Text(bridgeState(account.state).name)),
          ],
        );
      },
      onRowNavigate: (account) {
        context.go('/funding/accounts/${account.id}');
      },
      detailBuilder: (account) =>
          _InvestorAccountDetail(account: account),
      exportRow: (account) => [
        account.accountName,
        account.hasAvailableBalance()
            ? formatMoney(account.availableBalance)
            : '',
        account.hasTotalDeployed()
            ? formatMoney(account.totalDeployed)
            : '',
        bridgeState(account.state).name,
        account.id,
      ],
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _InvestorAccountCreateDialog(
        onSave: (account) async {
          await ref
              .read(investorAccountNotifierProvider.notifier)
              .save(account);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Investor account created')),
            );
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Account Detail
// ---------------------------------------------------------------------------

class _InvestorAccountDetail extends StatelessWidget {
  const _InvestorAccountDetail({required this.account});
  final InvestorAccountObject account;

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
              child: Icon(Icons.account_balance_wallet,
                  color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.accountName.isNotEmpty
                        ? account.accountName
                        : 'Account ${account.id.length > 8 ? account.id.substring(0, 8) : account.id}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(account.id,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (account.hasAvailableBalance())
          _DetailRow(
              label: 'Balance',
              value: formatMoney(account.availableBalance)),
        if (account.hasTotalDeployed())
          _DetailRow(
              label: 'Deployed',
              value: formatMoney(account.totalDeployed)),
        _DetailRow(label: 'State', value: bridgeState(account.state).name),
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
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Create Dialog
// ---------------------------------------------------------------------------

class _InvestorAccountCreateDialog extends ConsumerStatefulWidget {
  const _InvestorAccountCreateDialog({required this.onSave});

  final Future<void> Function(InvestorAccountObject account) onSave;

  @override
  ConsumerState<_InvestorAccountCreateDialog> createState() =>
      _InvestorAccountCreateDialogState();
}

class _InvestorAccountCreateDialogState
    extends ConsumerState<_InvestorAccountCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _investorIdCtrl = TextEditingController();
  final _minRateCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _investorIdCtrl.dispose();
    _minRateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Investor Account'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormFieldCard(
                label: 'Account Name',
                child: TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Enter account name',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 12),
              FormFieldCard(
                label: 'Investor ID',
                child: TextFormField(
                  controller: _investorIdCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Enter investor ID',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 12),
              FormFieldCard(
                label: 'Minimum Interest Rate (%)',
                child: TextFormField(
                  controller: _minRateCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'e.g. 5.0'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final account = InvestorAccountObject(
        accountName: _nameCtrl.text.trim(),
        investorId: _investorIdCtrl.text.trim(),
        minInterestRate: _minRateCtrl.text.trim(),
      );
      await widget.onSave(account);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
