import 'dart:async';

import 'package:antinvestor_api_funding/antinvestor_api_funding.dart'
    hide PageCursor, STATE;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/funding_providers.dart';
import '../utils/money_bridge.dart';
import '../utils/money_display.dart';
import '../widgets/async_list_view.dart';

const _searchDebounce = Duration(milliseconds: 350);

class InvestorAccountsScreen extends ConsumerStatefulWidget {
  const InvestorAccountsScreen({super.key, this.canManage = false});

  /// Whether the caller holds investor_account_manage. Without it the
  /// "New Account" action is not offered rather than refused afterwards.
  final bool canManage;

  @override
  ConsumerState<InvestorAccountsScreen> createState() =>
      _InvestorAccountsScreenState();
}

class _InvestorAccountsScreenState
    extends ConsumerState<InvestorAccountsScreen> {
  String _investorId = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// The search box filters by investor id. It is optional: an empty value
  /// lists every account the caller may see.
  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      if (!mounted) return;
      setState(() => _investorId = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = (investorId: _investorId, currencyCode: '');
    final accountsAsync = ref.watch(investorAccountListProvider(params));

    return AsyncListView<InvestorAccountObject>(
      value: accountsAsync,
      onRetry: () => ref.invalidate(investorAccountListProvider(params)),
      emptyTitle: 'No investor accounts',
      emptyMessage: _investorId.isEmpty
          ? 'Open an investor account to start deploying capital.'
          : 'No account belongs to investor "$_investorId".',
      builder: (accounts) => _buildList(context, accounts),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<InvestorAccountObject> accounts,
  ) {
    return AdminEntityListPage<InvestorAccountObject>(
      title: 'Investor Accounts',
      breadcrumbs: const ['Funding', 'Accounts'],
      searchHint: 'Filter by investor ID',
      onSearch: _onSearch,
      columns: const [
        DataColumn(label: Text('NAME')),
        DataColumn(label: Text('AVAILABLE')),
        DataColumn(label: Text('DEPLOYED')),
        DataColumn(label: Text('STATE')),
      ],
      items: accounts,
      addLabel: 'New Account',
      onAdd: widget.canManage ? () => _showCreateDialog(context) : null,
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
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(accountLabel(account)),
                ],
              ),
            ),
            DataCell(Text(displayMoney(account.availableBalance))),
            DataCell(Text(displayMoney(account.totalDeployed))),
            DataCell(Text(bridgeState(account.state).name)),
          ],
        );
      },
      onRowNavigate: (account) => context.go('/funding/accounts/${account.id}'),
      detailBuilder: (account) => _InvestorAccountDetail(account: account),
      exportRow: (account) => [
        account.accountName,
        displayMoney(account.availableBalance),
        displayMoney(account.totalDeployed),
        bridgeState(account.state).name,
        account.id,
      ],
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => InvestorAccountCreateDialog(
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

/// A readable name for an account, falling back to a truncated id.
String accountLabel(InvestorAccountObject account) {
  if (account.accountName.isNotEmpty) return account.accountName;
  final id = account.id;
  return 'Account ${id.length > 8 ? id.substring(0, 8) : id}';
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
              child: Icon(
                Icons.account_balance_wallet,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accountLabel(account),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    account.id,
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
          label: 'Available',
          value: displayMoney(account.availableBalance),
        ),
        _DetailRow(
          label: 'Reserved',
          value: displayMoney(account.reservedBalance),
        ),
        _DetailRow(
          label: 'Deployed',
          value: displayMoney(account.totalDeployed),
        ),
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

// ---------------------------------------------------------------------------
// Create Dialog
// ---------------------------------------------------------------------------

/// Collects a new investor account's mandate.
///
/// The currency is captured here because the server derives the account's
/// denomination from it, and an account without one can never take a deposit.
/// Balances are deliberately absent: capital only enters through a deposit.
class InvestorAccountCreateDialog extends StatefulWidget {
  const InvestorAccountCreateDialog({super.key, required this.onSave});

  final Future<void> Function(InvestorAccountObject account) onSave;

  @override
  State<InvestorAccountCreateDialog> createState() =>
      _InvestorAccountCreateDialogState();
}

class _InvestorAccountCreateDialogState
    extends State<InvestorAccountCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _investorIdCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController(text: 'KES');
  final _minRateCtrl = TextEditingController();
  final _maxExposureCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _investorIdCtrl.dispose();
    _currencyCtrl.dispose();
    _minRateCtrl.dispose();
    _maxExposureCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Investor Account'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormFieldCard(
                  label: 'Account Name',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('investor-account-name'),
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter account name',
                    ),
                    validator: (v) => validateRequired(v, 'Account name'),
                  ),
                ),
                FormFieldCard(
                  label: 'Investor ID',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('investor-id'),
                    controller: _investorIdCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter investor ID',
                    ),
                    validator: (v) => validateRequired(v, 'Investor ID'),
                  ),
                ),
                FormFieldCard(
                  label: 'Currency Code',
                  description:
                      'The account holds capital in this currency only',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('investor-currency'),
                    controller: _currencyCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(hintText: 'e.g. KES'),
                    validator: (v) => validateCurrency(v?.toUpperCase()),
                  ),
                ),
                FormFieldCard(
                  label: 'Minimum Interest Rate (%)',
                  description: 'Loans below this rate are not funded',
                  child: TextFormField(
                    key: const Key('investor-min-rate'),
                    controller: _minRateCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(hintText: 'e.g. 12.50'),
                    validator: _validateOptionalRate,
                  ),
                ),
                FormFieldCard(
                  label: 'Maximum Exposure',
                  description: 'Leave blank for no cap',
                  child: TextFormField(
                    key: const Key('investor-max-exposure'),
                    controller: _maxExposureCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(hintText: '0.00'),
                    validator: _validateOptionalAmount,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('investor-create-submit'),
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

  static String? _validateOptionalRate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid number';
    if (parsed < 0) return 'Rate cannot be negative';
    return null;
  }

  static String? _validateOptionalAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return validateAmount(value);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final currency = _currencyCtrl.text.trim().toUpperCase();
    try {
      final account = InvestorAccountObject(
        accountName: _nameCtrl.text.trim(),
        investorId: _investorIdCtrl.text.trim(),
        minInterestRate: _minRateCtrl.text.trim().isEmpty
            ? '0.00'
            : _minRateCtrl.text.trim(),
      );
      // available_balance carries the account's denomination on the wire; the
      // server ignores its value and only reads the currency.
      setMoneyFields(account.ensureAvailableBalance(), '0', currency);
      setMoneyFields(
        account.ensureMaxExposure(),
        _maxExposureCtrl.text.trim(),
        currency,
      );

      await widget.onSave(account);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }
}
