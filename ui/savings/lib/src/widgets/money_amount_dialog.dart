import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';

import '../providers/savings_providers.dart';

/// A dialog that collects one money amount and submits it exactly once.
///
/// The idempotency key is minted in [initState], not at submit time: if the
/// first attempt times out and the user presses the button again, the retry
/// carries the same key and the server resolves it to the original movement
/// instead of moving the money twice.
class MoneyAmountDialog extends StatefulWidget {
  const MoneyAmountDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.currencyCode,
    required this.onSubmit,
    this.description,
    this.referenceLabel,
    this.referenceHint,
  });

  final String title;
  final String confirmLabel;
  final String currencyCode;
  final String? description;
  final String? referenceLabel;
  final String? referenceHint;

  /// Called with the entered amount, the optional reference, and the key that
  /// identifies this attempt. Throwing keeps the dialog open so the user can
  /// retry with the same key.
  final Future<void> Function(
    String amount,
    String reference,
    String idempotencyKey,
  )
  onSubmit;

  @override
  State<MoneyAmountDialog> createState() => _MoneyAmountDialogState();
}

class _MoneyAmountDialogState extends State<MoneyAmountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  late final String _idempotencyKey;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _idempotencyKey = generateIdempotencyKey();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(
        _amountCtrl.text.trim(),
        _referenceCtrl.text.trim(),
        _idempotencyKey,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormFieldCard(
                label: 'Amount (${widget.currencyCode})',
                description: widget.description,
                isRequired: true,
                child: TextFormField(
                  key: const Key('money-amount-field'),
                  controller: _amountCtrl,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(hintText: '0.00'),
                  validator: validateAmount,
                ),
              ),
              if (widget.referenceLabel != null)
                FormFieldCard(
                  label: widget.referenceLabel!,
                  child: TextFormField(
                    key: const Key('money-reference-field'),
                    controller: _referenceCtrl,
                    decoration: InputDecoration(hintText: widget.referenceHint),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('money-submit-button'),
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
