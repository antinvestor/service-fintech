import 'dart:async';

import 'package:antinvestor_api_savings/antinvestor_api_savings.dart'
    hide PageCursor, STATE;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/savings_providers.dart';
import '../utils/money_bridge.dart';
import '../utils/money_display.dart';
import '../widgets/async_list_view.dart';

const _searchDebounce = Duration(milliseconds: 350);

class SavingsProductsScreen extends ConsumerStatefulWidget {
  const SavingsProductsScreen({super.key});

  @override
  ConsumerState<SavingsProductsScreen> createState() =>
      _SavingsProductsScreenState();
}

class _SavingsProductsScreenState extends ConsumerState<SavingsProductsScreen> {
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
    final params = (query: _query, organizationId: organizationId);
    final productsAsync = ref.watch(savingsProductListProvider(params));

    return AsyncListView<SavingsProductObject>(
      value: productsAsync,
      onRetry: () => ref.invalidate(savingsProductListProvider(params)),
      emptyTitle: 'No savings products',
      emptyMessage: _query.isEmpty
          ? 'Define a product before opening savings accounts.'
          : 'No savings product matches "$_query".',
      builder: (products) => _buildList(context, products),
    );
  }

  Widget _buildList(BuildContext context, List<SavingsProductObject> products) {
    return AdminEntityListPage<SavingsProductObject>(
      title: 'Savings Products',
      breadcrumbs: const ['Savings', 'Products'],
      columns: const [
        DataColumn(label: Text('NAME')),
        DataColumn(label: Text('CODE')),
        DataColumn(label: Text('RATE')),
        DataColumn(label: Text('STATE')),
      ],
      items: products,
      onSearch: _onSearch,
      addLabel: 'New Product',
      onAdd: () => _showCreateDialog(context),
      rowBuilder: (product, selected, onSelect) {
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
                    product.name.isNotEmpty
                        ? product.name
                        : 'Product ${product.id}',
                  ),
                ],
              ),
            ),
            DataCell(Text(product.code)),
            DataCell(Text('${product.interestRate}%')),
            DataCell(Text(bridgeState(product.state).name)),
          ],
        );
      },
      detailBuilder: (product) => _SavingsProductDetail(product: product),
      exportRow: (product) => [
        product.name,
        product.code,
        product.interestRate,
        bridgeState(product.state).name,
        product.id,
      ],
    );
  }

  void _showCreateDialog(BuildContext context) {
    final organizationId = ref.read(tenancyContextProvider).organizationId;
    showDialog<void>(
      context: context,
      builder: (ctx) => SavingsProductCreateDialog(
        organizationId: organizationId,
        onSave: (product) async {
          await ref.read(savingsProductNotifierProvider.notifier).save(product);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Savings product created')),
            );
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Product Detail
// ---------------------------------------------------------------------------

class _SavingsProductDetail extends StatelessWidget {
  const _SavingsProductDetail({required this.product});
  final SavingsProductObject product;

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
                    product.name.isNotEmpty
                        ? product.name
                        : 'Product ${product.id}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    product.id,
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
        _DetailRow(label: 'Code', value: product.code),
        _DetailRow(label: 'Currency', value: product.currencyCode),
        _DetailRow(label: 'Interest rate', value: '${product.interestRate}%'),
        _DetailRow(label: 'Period', value: periodTypeLabel(product.periodType)),
        _DetailRow(
          label: 'Compounding',
          value: compoundingLabel(product.compoundingFrequency),
        ),
        _DetailRow(
          label: 'Min deposit',
          value: displayMoney(product.minDeposit),
        ),
        _DetailRow(
          label: 'Max deposit',
          value: displayMoney(product.maxDeposit),
        ),
        _DetailRow(
          label: 'Description',
          value: product.description.isNotEmpty
              ? product.description
              : 'No description',
        ),
        _DetailRow(label: 'State', value: bridgeState(product.state).name),
      ],
    );
  }
}

/// Human label for every savings period the contract defines.
String periodTypeLabel(SavingsPeriodType type) {
  return switch (type) {
    SavingsPeriodType.SAVINGS_PERIOD_TYPE_DAILY => 'Daily',
    SavingsPeriodType.SAVINGS_PERIOD_TYPE_WEEKLY => 'Weekly',
    SavingsPeriodType.SAVINGS_PERIOD_TYPE_BIWEEKLY => 'Fortnightly',
    SavingsPeriodType.SAVINGS_PERIOD_TYPE_MONTHLY => 'Monthly',
    SavingsPeriodType.SAVINGS_PERIOD_TYPE_QUARTERLY => 'Quarterly',
    SavingsPeriodType.SAVINGS_PERIOD_TYPE_UNSPECIFIED => 'Unspecified',
    _ => 'Unknown',
  };
}

/// Human label for every compounding frequency the contract defines.
String compoundingLabel(CompoundingFrequency frequency) {
  return switch (frequency) {
    CompoundingFrequency.COMPOUNDING_FREQUENCY_DAILY => 'Daily',
    CompoundingFrequency.COMPOUNDING_FREQUENCY_WEEKLY => 'Weekly',
    CompoundingFrequency.COMPOUNDING_FREQUENCY_MONTHLY => 'Monthly',
    CompoundingFrequency.COMPOUNDING_FREQUENCY_QUARTERLY => 'Quarterly',
    CompoundingFrequency.COMPOUNDING_FREQUENCY_ANNUALLY => 'Annually',
    CompoundingFrequency.COMPOUNDING_FREQUENCY_UNSPECIFIED => 'Unspecified',
    _ => 'Unknown',
  };
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
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

/// Collects a full savings product definition.
///
/// The organization comes from the tenancy context; the code, currency,
/// period, compounding frequency and deposit bounds are all captured here
/// because the server has no sane default for any of them.
class SavingsProductCreateDialog extends StatefulWidget {
  const SavingsProductCreateDialog({
    super.key,
    required this.onSave,
    required this.organizationId,
  });

  final Future<void> Function(SavingsProductObject product) onSave;
  final String organizationId;

  @override
  State<SavingsProductCreateDialog> createState() =>
      _SavingsProductCreateDialogState();
}

class _SavingsProductCreateDialogState
    extends State<SavingsProductCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController(text: 'KES');
  final _minDepositCtrl = TextEditingController();
  final _maxDepositCtrl = TextEditingController();
  SavingsPeriodType _periodType = SavingsPeriodType.SAVINGS_PERIOD_TYPE_MONTHLY;
  CompoundingFrequency _compounding =
      CompoundingFrequency.COMPOUNDING_FREQUENCY_MONTHLY;
  bool _saving = false;

  static const _periodTypes = [
    SavingsPeriodType.SAVINGS_PERIOD_TYPE_DAILY,
    SavingsPeriodType.SAVINGS_PERIOD_TYPE_WEEKLY,
    SavingsPeriodType.SAVINGS_PERIOD_TYPE_BIWEEKLY,
    SavingsPeriodType.SAVINGS_PERIOD_TYPE_MONTHLY,
    SavingsPeriodType.SAVINGS_PERIOD_TYPE_QUARTERLY,
  ];

  static const _compoundingOptions = [
    CompoundingFrequency.COMPOUNDING_FREQUENCY_DAILY,
    CompoundingFrequency.COMPOUNDING_FREQUENCY_WEEKLY,
    CompoundingFrequency.COMPOUNDING_FREQUENCY_MONTHLY,
    CompoundingFrequency.COMPOUNDING_FREQUENCY_QUARTERLY,
    CompoundingFrequency.COMPOUNDING_FREQUENCY_ANNUALLY,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _rateCtrl.dispose();
    _currencyCtrl.dispose();
    _minDepositCtrl.dispose();
    _maxDepositCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Savings Product'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormFieldCard(
                  label: 'Product Name',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('product-name'),
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter product name',
                    ),
                    validator: (v) => validateRequired(v, 'Product name'),
                  ),
                ),
                FormFieldCard(
                  label: 'Product Code',
                  description: 'Unique short code used across the platform',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('product-code'),
                    controller: _codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(hintText: 'e.g. SAV-STD'),
                    validator: (v) => validateRequired(v, 'Product code'),
                  ),
                ),
                FormFieldCard(
                  label: 'Currency Code',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('product-currency'),
                    controller: _currencyCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(hintText: 'e.g. KES'),
                    validator: (v) => validateCurrency(v?.toUpperCase()),
                  ),
                ),
                FormFieldCard(
                  label: 'Interest Rate (%)',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('product-rate'),
                    controller: _rateCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(hintText: 'e.g. 3.50'),
                    validator: _validateRate,
                  ),
                ),
                FormFieldCard(
                  label: 'Period',
                  child: DropdownButtonFormField<SavingsPeriodType>(
                    initialValue: _periodType,
                    items: _periodTypes
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(periodTypeLabel(t)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _periodType = v);
                    },
                  ),
                ),
                FormFieldCard(
                  label: 'Compounding Frequency',
                  child: DropdownButtonFormField<CompoundingFrequency>(
                    initialValue: _compounding,
                    items: _compoundingOptions
                        .map(
                          (f) => DropdownMenuItem(
                            value: f,
                            child: Text(compoundingLabel(f)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _compounding = v);
                    },
                  ),
                ),
                FormFieldCard(
                  label: 'Minimum Deposit',
                  description: 'Leave blank for no minimum',
                  child: TextFormField(
                    key: const Key('product-min-deposit'),
                    controller: _minDepositCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(hintText: '0.00'),
                    validator: _validateOptionalAmount,
                  ),
                ),
                FormFieldCard(
                  label: 'Maximum Deposit',
                  description: 'Leave blank for no maximum',
                  child: TextFormField(
                    key: const Key('product-max-deposit'),
                    controller: _maxDepositCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(hintText: '0.00'),
                    validator: _validateOptionalAmount,
                  ),
                ),
                FormFieldCard(
                  label: 'Description',
                  child: TextFormField(
                    controller: _descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Product description',
                    ),
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
          key: const Key('product-create-submit'),
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

  static String? _validateRate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Interest rate is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid number';
    if (parsed < 0) return 'Interest rate cannot be negative';
    return null;
  }

  static String? _validateOptionalAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return validateAmount(value);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (widget.organizationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select an organization before creating a product'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final currency = _currencyCtrl.text.trim().toUpperCase();
    try {
      final product = SavingsProductObject(
        organizationId: widget.organizationId,
        name: _nameCtrl.text.trim(),
        code: _codeCtrl.text.trim().toUpperCase(),
        description: _descCtrl.text.trim(),
        currencyCode: currency,
        interestRate: _rateCtrl.text.trim(),
        periodType: _periodType,
        compoundingFrequency: _compounding,
      );
      _applyDeposit(product.ensureMinDeposit(), _minDepositCtrl.text, currency);
      _applyDeposit(product.ensureMaxDeposit(), _maxDepositCtrl.text, currency);

      await widget.onSave(product);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  void _applyDeposit(dynamic target, String raw, String currency) {
    setMoneyFields(target, raw.trim(), currency);
  }
}
