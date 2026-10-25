import 'package:antinvestor_api_field/antinvestor_api_field.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:flutter/material.dart';

import '../providers/client_providers.dart';

/// KYC fields the onboarding form offers by name; any other detail the
/// agent captures is added as a free field.
const kClientDateOfBirthKey = 'date_of_birth';
const kClientResidentialAddressKey = 'residential_address';
const kClientOccupationKey = 'occupation';

/// Everything an agent captures when onboarding a borrower. It is stored
/// on the device before anything is sent, so it can be captured offline.
class ClientRegistrationDraft {
  const ClientRegistrationDraft({
    required this.name,
    required this.phone,
    this.nationalId = '',
    this.details = const {},
  });

  final String name;

  /// Passed to the profile service to find or create the borrower's
  /// profile; never kept on the client.
  final String phone;
  final String nationalId;

  /// KYC details by field key, saved as COLLECTED for later verification.
  final Map<String, String> details;
}

/// Collects a borrower's details. Onboarding pops with a
/// [ClientRegistrationDraft]; editing pops with the [ClientObject] to save.
/// The caller performs the save so the list can react to the result.
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
  final _dobCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _extra = <({TextEditingController key, TextEditingController value})>[];

  bool get _isEditing => widget.client != null;

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    // Contacts live on the borrower's profile: the phone is captured only
    // to find or create that profile at onboarding, never edited here.
    _phoneCtrl = TextEditingController();
    _nationalIdCtrl = TextEditingController(
      text: c == null ? '' : clientNationalId(c),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _nationalIdCtrl.dispose();
    _dobCtrl.dispose();
    _addressCtrl.dispose();
    _occupationCtrl.dispose();
    for (final row in _extra) {
      row.key.dispose();
      row.value.dispose();
    }
    super.dispose();
  }

  // The profile service validates the number; only presence is checked.
  static String? _validatePhone(String? value) =>
      (value ?? '').trim().isEmpty ? 'Phone number is required' : null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEditing) {
      _submitRegistration();
      return;
    }

    // Start from the existing properties so an edit never drops keys the
    // form does not know about.
    final properties = widget.client?.hasProperties() == true
        ? widget.client!.properties.deepCopy()
        : Struct();
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

  void _submitRegistration() {
    final nationalId = _nationalIdCtrl.text.trim();
    final details = <String, String>{
      kClientNationalIdKey: nationalId,
      kClientDateOfBirthKey: _dobCtrl.text.trim(),
      kClientResidentialAddressKey: _addressCtrl.text.trim(),
      kClientOccupationKey: _occupationCtrl.text.trim(),
      for (final row in _extra) row.key.text.trim(): row.value.text.trim(),
    }..removeWhere((k, v) => k.isEmpty || v.isEmpty);
    Navigator.pop(
      context,
      ClientRegistrationDraft(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        nationalId: nationalId,
        details: details,
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 30),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 18, now.month, now.day),
    );
    if (picked == null) return;
    _dobCtrl.text =
        '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
  }

  List<Widget> _detailFields() => [
    FormFieldCard(
      label: 'Date of birth',
      description: 'Optional. Verified later under KYC.',
      child: TextFormField(
        key: const Key('client-form-dob'),
        controller: _dobCtrl,
        readOnly: true,
        onTap: _pickDateOfBirth,
        decoration: const InputDecoration(
          hintText: 'YYYY-MM-DD',
          prefixIcon: Icon(Icons.cake_outlined),
        ),
      ),
    ),
    FormFieldCard(
      label: 'Residential address',
      description: 'Optional. Verified later under KYC.',
      child: TextFormField(
        key: const Key('client-form-address'),
        controller: _addressCtrl,
        decoration: const InputDecoration(
          hintText: 'e.g. Kahawa West, Nairobi',
          prefixIcon: Icon(Icons.home_outlined),
        ),
        textInputAction: TextInputAction.next,
      ),
    ),
    FormFieldCard(
      label: 'Occupation',
      description: 'Optional. Verified later under KYC.',
      child: TextFormField(
        key: const Key('client-form-occupation'),
        controller: _occupationCtrl,
        decoration: const InputDecoration(
          hintText: 'e.g. Market trader',
          prefixIcon: Icon(Icons.work_outline),
        ),
        textInputAction: TextInputAction.next,
      ),
    ),
    for (final (i, row) in _extra.indexed)
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                key: Key('client-form-extra-key-$i'),
                controller: row.key,
                decoration: const InputDecoration(labelText: 'Detail'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty && row.value.text.trim().isNotEmpty
                    ? 'Name the detail'
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                key: Key('client-form-extra-value-$i'),
                controller: row.value,
                decoration: const InputDecoration(labelText: 'Value'),
              ),
            ),
            IconButton(
              tooltip: 'Remove',
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _extra.removeAt(i);
                row.key.dispose();
                row.value.dispose();
              }),
            ),
          ],
        ),
      ),
    Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        key: const Key('client-form-add-detail'),
        onPressed: () => setState(
          () => _extra.add((
            key: TextEditingController(),
            value: TextEditingController(),
          )),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add another detail'),
      ),
    ),
  ];

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
                      : 'Register a borrower in your portfolio. Works '
                            'offline: it is sent when you are back online.',
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
                if (!_isEditing)
                  FormFieldCard(
                    label: 'Phone number',
                    description:
                        'Used to find or create the borrower\'s profile; their '
                        'contacts are then managed on the profile.',
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
                    textInputAction: _isEditing
                        ? TextInputAction.done
                        : TextInputAction.next,
                    onFieldSubmitted: _isEditing ? (_) => _submit() : null,
                  ),
                ),
                if (!_isEditing) ..._detailFields(),
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
