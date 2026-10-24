import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/loan_account_providers.dart';
import '../providers/loan_product_providers.dart';
import '../providers/loan_request_providers.dart';
import '../utils/idempotency_key.dart';
import '../utils/money_compat.dart';
import '../widgets/load_more_action.dart';

/// Collects a new loan application and submits it through
/// [loanRequestNotifierProvider]. Pops with the saved request on success.
///
/// The idempotency key is minted once when the dialog opens, so a retry
/// after a timeout reaches the service as the same application.
class LoanRequestFormDialog extends ConsumerStatefulWidget {
  const LoanRequestFormDialog({super.key, this.initialClientId = ''});

  /// Pre-fills the client when the dialog is opened from a client's page.
  final String initialClientId;

  @override
  ConsumerState<LoanRequestFormDialog> createState() =>
      _LoanRequestFormDialogState();
}

class _LoanRequestFormDialogState extends ConsumerState<LoanRequestFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _clientIdCtrl;
  final _amountCtrl = TextEditingController();
  final _termCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  late final String _idempotencyKey;
  LoanProductObject? _product;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _clientIdCtrl = TextEditingController(text: widget.initialClientId);
    _idempotencyKey = generateIdempotencyKey();
  }

  @override
  void dispose() {
    _clientIdCtrl.dispose();
    _amountCtrl.dispose();
    _termCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  String get _currency {
    final code = _product?.currencyCode ?? '';
    if (code.isNotEmpty) return code;
    return loanMoneyCurrency(_product?.minAmount, 'KES');
  }

  String? _validateTerm(String? value) {
    final days = int.tryParse(value?.trim() ?? '');
    if (days == null || days <= 0) return 'Enter the term in whole days';
    final product = _product;
    if (product != null) {
      if (product.minTermDays > 0 && days < product.minTermDays) {
        return 'Minimum term is ${product.minTermDays} days';
      }
      if (product.maxTermDays > 0 && days > product.maxTermDays) {
        return 'Maximum term is ${product.maxTermDays} days';
      }
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final product = _product!;
    setState(() {
      _saving = true;
      _error = null;
    });
    final request = LoanRequestObject(
      productId: product.id,
      clientId: _clientIdCtrl.text.trim(),
      organizationId: product.organizationId,
      status: LoanRequestStatus.LOAN_REQUEST_STATUS_SUBMITTED,
      requestedAmount: loanMoneyFromString(_amountCtrl.text, _currency),
      requestedTermDays: int.parse(_termCtrl.text.trim()),
      currencyCode: _currency,
      purpose: _purposeCtrl.text.trim(),
      idempotencyKey: _idempotencyKey,
    );
    try {
      final saved = await ref
          .read(loanRequestNotifierProvider.notifier)
          .save(request);
      if (mounted) Navigator.of(context).pop(saved);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = friendlyError(e);
        });
      }
    }
  }

  Future<void> _pickClient() async {
    final picked = await showDialog<String>(
      context: context,
      builder: (_) => const _ClientPickerDialog(),
    );
    if (picked != null && mounted) {
      setState(() => _clientIdCtrl.text = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(
      loanProductListProvider((query: '', limit: kLoanListPageSize)),
    );

    return AlertDialog(
      title: const Text('New application'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormFieldCard(
                  label: 'Product',
                  description: 'The loan product the client is applying for.',
                  isRequired: true,
                  child: productsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text(
                      friendlyError(e),
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    data: (page) => DropdownButtonFormField<LoanProductObject>(
                      key: const Key('loan-request-product'),
                      initialValue: _product,
                      decoration: const InputDecoration(
                        hintText: 'Select product',
                      ),
                      items: [
                        for (final p in page.items)
                          DropdownMenuItem(
                            value: p,
                            child: Text(p.name.isNotEmpty ? p.name : p.id),
                          ),
                      ],
                      validator: (v) =>
                          v == null ? 'Product is required' : null,
                      onChanged: (v) => setState(() => _product = v),
                    ),
                  ),
                ),
                FormFieldCard(
                  label: 'Client',
                  description: 'The borrower this application is for.',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('loan-request-client'),
                    controller: _clientIdCtrl,
                    decoration: InputDecoration(
                      hintText: 'Client id',
                      suffixIcon: IconButton(
                        key: const Key('loan-request-pick-client'),
                        tooltip: 'Find client',
                        icon: const Icon(Icons.person_search_outlined),
                        onPressed: _saving ? null : _pickClient,
                      ),
                    ),
                    validator: (v) => validateRequired(v, 'Client'),
                  ),
                ),
                FormFieldCard(
                  label: 'Amount ($_currency)',
                  description: _product == null
                      ? 'Select a product to see its limits.'
                      : 'Between ${formatLoanMoney(_product!.minAmount)} '
                            'and ${formatLoanMoney(_product!.maxAmount)}.',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('loan-request-amount'),
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: validateAmount,
                  ),
                ),
                FormFieldCard(
                  label: 'Term (days)',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('loan-request-term'),
                    controller: _termCtrl,
                    keyboardType: TextInputType.number,
                    validator: _validateTerm,
                  ),
                ),
                FormFieldCard(
                  label: 'Purpose',
                  description: 'What the client will use the loan for.',
                  child: TextFormField(
                    key: const Key('loan-request-purpose'),
                    controller: _purposeCtrl,
                    maxLines: 2,
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _error!,
                      key: const Key('loan-request-error'),
                      style: TextStyle(color: theme.colorScheme.error),
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
        FilledButton.icon(
          key: const Key('loan-request-submit'),
          onPressed: _saving ? null : _submit,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_outlined),
          label: const Text('Submit'),
        ),
      ],
    );
  }
}

/// Finds a client by the id shown on the loan book: the loans service only
/// knows client ids, so the picker searches existing loan accounts and offers
/// the distinct client ids it finds.
class _ClientPickerDialog extends ConsumerStatefulWidget {
  const _ClientPickerDialog();

  @override
  ConsumerState<_ClientPickerDialog> createState() =>
      _ClientPickerDialogState();
}

class _ClientPickerDialogState extends ConsumerState<_ClientPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final params = (
      query: _query,
      status: null as LoanStatus?,
      agentId: '',
      clientId: '',
      limit: kLoanListPageSize,
    );
    final loansAsync = ref.watch(loanAccountListProvider(params));
    return AlertDialog(
      title: const Text('Find client'),
      content: SizedBox(
        width: 420,
        height: 360,
        child: Column(
          children: [
            TextField(
              key: const Key('client-picker-search'),
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by client id',
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: loansAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(friendlyError(e))),
                data: (page) {
                  final ids = {for (final l in page.items) l.clientId}
                    ..remove('');
                  if (ids.isEmpty) {
                    return const Center(child: Text('No clients found'));
                  }
                  final list = ids.toList()..sort();
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.person_outline),
                      title: Text(list[index]),
                      onTap: () => Navigator.of(context).pop(list[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
