import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';

import '../providers/funding_providers.dart';

/// The two phases of absorbing a loss: collecting the figures, then reading
/// them back for explicit confirmation before any capital is written off.
enum AbsorbLossStep { input, confirm }

/// Collects the loan and the loss amount, asks the operator to confirm the
/// write-off, and submits it exactly once.
///
/// The idempotency key is minted in [initState] and reused across retries of
/// the same dialog, so a timeout followed by a second press absorbs the loss
/// once rather than twice.
class AbsorbLossDialog extends StatefulWidget {
  const AbsorbLossDialog({
    super.key,
    required this.currencyCode,
    required this.onSubmit,
    this.initialLoanRequestId = '',
  });

  final String currencyCode;
  final String initialLoanRequestId;

  /// Called with the loan, the amount and the key identifying this attempt.
  /// Throwing returns the dialog to the confirmation step with the same key.
  final Future<void> Function(
    String loanRequestId,
    String amount,
    String idempotencyKey,
  )
  onSubmit;

  @override
  State<AbsorbLossDialog> createState() => _AbsorbLossDialogState();
}

class _AbsorbLossDialogState extends State<AbsorbLossDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _loanCtrl;
  final _amountCtrl = TextEditingController();
  late final String _idempotencyKey;
  AbsorbLossStep _step = AbsorbLossStep.input;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _idempotencyKey = generateIdempotencyKey();
    _loanCtrl = TextEditingController(text: widget.initialLoanRequestId);
  }

  @override
  void dispose() {
    _loanCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _review() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _step = AbsorbLossStep.confirm);
  }

  void _back() => setState(() => _step = AbsorbLossStep.input);

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(
        _loanCtrl.text.trim(),
        _amountCtrl.text.trim(),
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
      title: Text(switch (_step) {
        AbsorbLossStep.input => 'Absorb Loss',
        AbsorbLossStep.confirm => 'Confirm write-off',
      }),
      content: SizedBox(
        width: 400,
        child: switch (_step) {
          AbsorbLossStep.input => _buildInput(),
          AbsorbLossStep.confirm => _buildConfirm(context),
        },
      ),
      actions: switch (_step) {
        AbsorbLossStep.input => [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('absorb-loss-review'),
            onPressed: _review,
            child: const Text('Review'),
          ),
        ],
        AbsorbLossStep.confirm => [
          TextButton(
            key: const Key('absorb-loss-back'),
            onPressed: _submitting ? null : _back,
            child: const Text('Back'),
          ),
          FilledButton(
            key: const Key('absorb-loss-confirm'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Absorb loss'),
          ),
        ],
      },
    );
  }

  Widget _buildInput() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FormFieldCard(
            label: 'Loan Request ID',
            isRequired: true,
            child: TextFormField(
              key: const Key('absorb-loss-loan-field'),
              controller: _loanCtrl,
              autofocus: widget.initialLoanRequestId.isEmpty,
              decoration: const InputDecoration(
                hintText: 'Enter loan request ID',
              ),
              validator: (v) => validateRequired(v, 'Loan request ID'),
            ),
          ),
          FormFieldCard(
            label: 'Loss amount (${widget.currencyCode})',
            description:
                'Applied to the loan\'s tranches, first-loss capital first.',
            isRequired: true,
            child: TextFormField(
              key: const Key('absorb-loss-amount-field'),
              controller: _amountCtrl,
              autofocus: widget.initialLoanRequestId.isNotEmpty,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(hintText: '0.00'),
              validator: validateAmount,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirm(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This writes ${widget.currencyCode} ${_amountCtrl.text.trim()} off '
          'the capital funding loan ${_loanCtrl.text.trim()}. Investors '
          'absorb it in tranche order and it cannot be undone from here.',
          key: const Key('absorb-loss-summary'),
        ),
        const SizedBox(height: 12),
        Text(
          'Any part the tranches cannot cover is reported back as '
          'unrecoverable.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
