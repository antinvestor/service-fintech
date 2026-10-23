import 'dart:async';

import 'package:antinvestor_api_savings/antinvestor_api_savings.dart'
    hide PageCursor, STATE;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/savings_providers.dart';
import '../widgets/async_list_view.dart';

/// How long the search box waits before firing a request, so a typed word is
/// one streaming RPC rather than one per keystroke.
const _searchDebounce = Duration(milliseconds: 350);

class SavingsAccountsScreen extends ConsumerStatefulWidget {
  const SavingsAccountsScreen({super.key});

  @override
  ConsumerState<SavingsAccountsScreen> createState() =>
      _SavingsAccountsScreenState();
}

class _SavingsAccountsScreenState extends ConsumerState<SavingsAccountsScreen> {
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      if (!mounted) return;
      setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final organizationId = ref.watch(tenancyContextProvider).organizationId;
    final params = (query: _query, ownerId: '', organizationId: organizationId);
    final accountsAsync = ref.watch(savingsAccountListProvider(params));

    return AsyncListView<SavingsAccountObject>(
      value: accountsAsync,
      onRetry: () => ref.invalidate(savingsAccountListProvider(params)),
      emptyTitle: 'No savings accounts',
      emptyMessage: _query.isEmpty
          ? 'Open an account to start recording deposits.'
          : 'No savings account matches "$_query".',
      builder: (accounts) => _buildList(context, accounts),
    );
  }

  Widget _buildList(BuildContext context, List<SavingsAccountObject> accounts) {
    return AdminEntityListPage<SavingsAccountObject>(
      title: 'Savings Accounts',
      breadcrumbs: const ['Savings', 'Accounts'],
      columns: const [
        DataColumn(label: Text('ACCOUNT ID')),
        DataColumn(label: Text('OWNER')),
        DataColumn(label: Text('CURRENCY')),
        DataColumn(label: Text('STATUS')),
      ],
      items: accounts,
      onSearch: _onSearch,
      addLabel: 'New Account',
      onAdd: () => _showCreateDialog(context),
      rowBuilder: (account, selected, onSelect) {
        final (statusLabel, _) = statusInfo(account.status);
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
                    ).colorScheme.secondaryContainer,
                    child: Icon(
                      Icons.savings,
                      size: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    account.id.length > 16
                        ? '${account.id.substring(0, 16)}...'
                        : account.id,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            DataCell(Text(account.ownerId)),
            DataCell(Text(account.currencyCode)),
            DataCell(Text(statusLabel)),
          ],
        );
      },
      onRowNavigate: (account) => context.go('/savings/${account.id}'),
      detailBuilder: (account) => _SavingsAccountDetail(account: account),
      exportRow: (account) => [
        account.id,
        account.ownerId,
        account.currencyCode,
        statusInfo(account.status).$1,
      ],
    );
  }

  void _showCreateDialog(BuildContext context) {
    final tenancy = ref.read(tenancyContextProvider);
    showDialog<void>(
      context: context,
      builder: (ctx) => SavingsAccountCreateDialog(
        organizationId: tenancy.organizationId,
        branchId: tenancy.branchId,
        onSave: (account) async {
          await ref
              .read(savingsAccountNotifierProvider.notifier)
              .create(account);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Savings account created')),
            );
          }
        },
      ),
    );
  }
}

/// Label and colour for a savings account status. Every value the contract
/// defines is covered so an unfamiliar status never renders as blank.
(String, Color) statusInfo(SavingsAccountStatus status) {
  return switch (status) {
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
    SavingsAccountStatus.SAVINGS_ACCOUNT_STATUS_UNSPECIFIED => (
      'Unspecified',
      Colors.grey,
    ),
    _ => ('Unknown', Colors.grey),
  };
}

// ---------------------------------------------------------------------------
// Savings Account Detail
// ---------------------------------------------------------------------------

class _SavingsAccountDetail extends StatelessWidget {
  const _SavingsAccountDetail({required this.account});
  final SavingsAccountObject account;

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
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(Icons.savings, color: theme.colorScheme.secondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
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
        _DetailRow(label: 'Owner', value: account.ownerId),
        _DetailRow(label: 'Product', value: account.productId),
        _DetailRow(label: 'Currency', value: account.currencyCode),
        _DetailRow(label: 'Status', value: statusInfo(account.status).$1),
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
// Savings Account create dialog
// ---------------------------------------------------------------------------

/// Collects the fields needed to open a savings account.
///
/// The organization and branch come from the signed-in tenancy context rather
/// than from the operator: a caller cannot open an account under an
/// organization they are not working in. The ledger routing is derived by the
/// server, so it is deliberately absent here.
class SavingsAccountCreateDialog extends StatefulWidget {
  const SavingsAccountCreateDialog({
    super.key,
    required this.onSave,
    required this.organizationId,
    this.branchId = '',
  });

  final Future<void> Function(SavingsAccountObject account) onSave;
  final String organizationId;
  final String branchId;

  @override
  State<SavingsAccountCreateDialog> createState() =>
      _SavingsAccountCreateDialogState();
}

class _SavingsAccountCreateDialogState
    extends State<SavingsAccountCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clientIdCtrl = TextEditingController();
  final _productIdCtrl = TextEditingController();
  final _currencyCodeCtrl = TextEditingController(text: 'KES');
  SavingsAccountOwnerType _ownerType =
      SavingsAccountOwnerType.SAVINGS_ACCOUNT_OWNER_TYPE_INDIVIDUAL;
  bool _saving = false;

  static const _ownerTypes = [
    SavingsAccountOwnerType.SAVINGS_ACCOUNT_OWNER_TYPE_INDIVIDUAL,
    SavingsAccountOwnerType.SAVINGS_ACCOUNT_OWNER_TYPE_GROUP,
  ];

  static String _ownerTypeLabel(SavingsAccountOwnerType type) {
    return switch (type) {
      SavingsAccountOwnerType.SAVINGS_ACCOUNT_OWNER_TYPE_INDIVIDUAL =>
        'Individual',
      SavingsAccountOwnerType.SAVINGS_ACCOUNT_OWNER_TYPE_GROUP => 'Group',
      _ => 'Unspecified',
    };
  }

  @override
  void dispose() {
    _clientIdCtrl.dispose();
    _productIdCtrl.dispose();
    _currencyCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (widget.organizationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select an organization before opening an account'),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final account = SavingsAccountObject(
      ownerId: _clientIdCtrl.text.trim(),
      productId: _productIdCtrl.text.trim(),
      ownerType: _ownerType,
      organizationId: widget.organizationId,
      currencyCode: _currencyCodeCtrl.text.trim().toUpperCase(),
    );
    if (widget.branchId.isNotEmpty) {
      account.branchId = widget.branchId;
    }

    try {
      await widget.onSave(account);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Savings Account'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormFieldCard(
                  label: 'Client ID',
                  description:
                      'The unique identifier of the account owner (client or group)',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('account-client-id'),
                    controller: _clientIdCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter the client ID',
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) => validateRequired(v, 'Client ID'),
                  ),
                ),
                FormFieldCard(
                  label: 'Owner Type',
                  description:
                      'Whether the account is owned by an individual or a group',
                  isRequired: true,
                  child: DropdownButtonFormField<SavingsAccountOwnerType>(
                    initialValue: _ownerType,
                    items: _ownerTypes
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(_ownerTypeLabel(t)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _ownerType = v);
                    },
                  ),
                ),
                FormFieldCard(
                  label: 'Savings Product ID',
                  description:
                      'The savings product that defines the terms for this account',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('account-product-id'),
                    controller: _productIdCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter the savings product ID',
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) => validateRequired(v, 'Savings Product ID'),
                  ),
                ),
                FormFieldCard(
                  label: 'Currency Code',
                  description:
                      'ISO 4217 currency code; must match the product currency',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('account-currency-code'),
                    controller: _currencyCodeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(hintText: 'e.g. KES'),
                    textInputAction: TextInputAction.done,
                    validator: (v) => validateCurrency(v?.toUpperCase()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('account-create-submit'),
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
