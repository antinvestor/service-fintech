import 'package:antinvestor_api_field/antinvestor_api_field.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:flutter/material.dart';

import '../providers/client_providers.dart';

/// Collects the details a field agent needs to onboard a borrower. Pops with
/// the [ClientObject] to save; the caller performs the save so the list can
/// react to the result.
///
/// `owning_team_id` is left as it was (empty for a new client): the service
/// places a field agent's client in the agent's own team.
class ClientFormDialog extends StatefulWidget {
  const ClientFormDialog({super.key, this.client});

  /// The client being edited, or null to onboard a new one.
  final ClientObject? client;

  @override
  State<ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends State<ClientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _nationalIdCtrl;

  bool get _isEditing => widget.client != null;

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _phoneCtrl = TextEditingController(
      text: c == null ? '' : clientPhoneNumber(c),
    );
    _nationalIdCtrl = TextEditingController(
      text: c == null ? '' : clientNationalId(c),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _nationalIdCtrl.dispose();
    super.dispose();
  }

  static String? _validatePhone(String? value) {
    final cleaned = (value ?? '').replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\+?\d{9,15}$').hasMatch(cleaned)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Start from the existing properties so an edit never drops keys the
    // form does not know about.
    final properties = widget.client?.hasProperties() == true
        ? widget.client!.properties.deepCopy()
        : Struct();
    properties.fields[kClientPhoneNumberKey] = Value(
      stringValue: _phoneCtrl.text.trim().replaceAll(RegExp(r'[\s\-\(\)]'), ''),
    );
    final nationalId = _nationalIdCtrl.text.trim();
    if (nationalId.isNotEmpty) {
      properties.fields[kClientNationalIdKey] = Value(stringValue: nationalId);
    } else {
      properties.fields.remove(kClientNationalIdKey);
    }

    Navigator.pop(
      context,
      ClientObject(
        id: widget.client?.id ?? '',
        agentId: widget.client?.agentId ?? '',
        profileId: widget.client?.profileId ?? '',
        owningTeamId: widget.client?.owningTeamId ?? '',
        name: _nameCtrl.text.trim(),
        state: widget.client?.state ?? STATE.ACTIVE,
        properties: properties,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.person_add_alt_1_outlined,
              color: theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Client' : 'Onboard Client',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _isEditing
                      ? 'Update the client details below.'
                      : 'Register a borrower in your portfolio.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                FormFieldCard(
                  label: 'Full name',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('client-form-name'),
                    controller: _nameCtrl,
                    autofocus: !_isEditing,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Amina Wanjiru',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                ),
                FormFieldCard(
                  label: 'Phone number',
                  description:
                      'The number the client repays from and receives prompts on.',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('client-form-phone'),
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'e.g. +254700000000',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: _validatePhone,
                  ),
                ),
                FormFieldCard(
                  label: 'National ID',
                  description: 'Optional. Verified later under KYC.',
                  child: TextFormField(
                    key: const Key('client-form-national-id'),
                    controller: _nationalIdCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 12345678',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const Key('client-form-submit'),
          onPressed: _submit,
          icon: Icon(_isEditing ? Icons.save : Icons.person_add_alt_1),
          label: Text(_isEditing ? 'Update' : 'Onboard'),
        ),
      ],
    );
  }
}
