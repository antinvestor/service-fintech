import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:flutter/material.dart';

/// Asks the field agent for the code the borrower received, proving the
/// borrower consents to being activated as a client. Pops with the code, or
/// null when cancelled.
class ConsentCodeDialog extends StatefulWidget {
  const ConsentCodeDialog({super.key});

  @override
  State<ConsentCodeDialog> createState() => _ConsentCodeDialogState();
}

class _ConsentCodeDialogState extends State<ConsentCodeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _codeCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Borrower consent'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: FormFieldCard(
            label: 'Consent code',
            description:
                'A code was sent to the borrower\'s mobile number. Enter it '
                'to confirm they agree to become a client.',
            isRequired: true,
            child: TextFormField(
              controller: _codeCtrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter the code' : null,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Confirm')),
      ],
    );
  }
}
