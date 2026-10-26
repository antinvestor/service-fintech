import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/form_template_providers.dart';
import '../providers/organization_providers.dart';

/// Field types a template may collect. Phone and email are absent on
/// purpose: contacts live on the client's profile, and the identity service
/// refuses a template that asks for them.
const designerFieldTypes = <FormFieldType, String>{
  FormFieldType.FORM_FIELD_TYPE_TEXT: 'Text',
  FormFieldType.FORM_FIELD_TYPE_TEXTAREA: 'Long text',
  FormFieldType.FORM_FIELD_TYPE_NUMBER: 'Number',
  FormFieldType.FORM_FIELD_TYPE_CURRENCY: 'Amount',
  FormFieldType.FORM_FIELD_TYPE_DATE: 'Date',
  FormFieldType.FORM_FIELD_TYPE_SELECT: 'Choice',
  FormFieldType.FORM_FIELD_TYPE_MULTI_SELECT: 'Multiple choice',
  FormFieldType.FORM_FIELD_TYPE_CHECKBOX: 'Yes / no',
  FormFieldType.FORM_FIELD_TYPE_PHOTO: 'Photo',
  FormFieldType.FORM_FIELD_TYPE_FILE: 'Document',
  FormFieldType.FORM_FIELD_TYPE_LOCATION: 'Location',
  FormFieldType.FORM_FIELD_TYPE_SIGNATURE: 'Signature',
};

/// Entity types a template can serve. KYC for borrowers reads "client".
const designerEntityTypes = <String, String>{
  'client': 'Client KYC',
  'investor': 'Investor KYC',
  'group': 'Group registration',
  'loan_request': 'Loan application',
};

/// A machine key derived from a label: lower case, underscores.
String fieldKeyFromLabel(String label) {
  final key = label
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return key;
}

bool _isChoice(FormFieldType type) =>
    type == FormFieldType.FORM_FIELD_TYPE_SELECT ||
    type == FormFieldType.FORM_FIELD_TYPE_MULTI_SELECT;

/// Builds and edits a form template.
///
/// A draft is edited in place and published when ready. A published template
/// is never changed: clients already filled it in. "New version" copies it
/// into a fresh draft, and publishing that draft makes it the version KYC
/// asks for.
class FormTemplateDesignerScreen extends ConsumerStatefulWidget {
  const FormTemplateDesignerScreen({
    super.key,
    this.templateId,
    this.canManage = false,
    this.onSaved,
  });

  /// The template to open; null starts a new one.
  final String? templateId;

  /// Whether the caller holds form_template_manage.
  final bool canManage;

  /// Called with the template's id after a save or publish, so the host can
  /// move to the template's own route.
  final void Function(String templateId)? onSaved;

  @override
  ConsumerState<FormTemplateDesignerScreen> createState() =>
      _FormTemplateDesignerScreenState();
}

class _FormTemplateDesignerScreenState
    extends ConsumerState<FormTemplateDesignerScreen> {
  FormTemplateObject? _draft;

  @override
  Widget build(BuildContext context) {
    final id = widget.templateId;
    if (_draft == null && id != null) {
      final loaded = ref.watch(formTemplateDetailProvider(id));
      return loaded.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Could not load the template: ${friendlyError(e)}'),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(formTemplateDetailProvider(id)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (template) => _TemplateEditor(
          key: ValueKey('${template.id}-${template.status}'),
          template: template.deepCopy(),
          canManage: widget.canManage,
          onSaved: widget.onSaved,
          onNewVersion: _startNewVersion,
        ),
      );
    }
    return _TemplateEditor(
      key: ValueKey(_draft?.hashCode ?? 'new'),
      template:
          _draft ??
          FormTemplateObject(
            entityType: 'client',
            status: FormTemplateStatus.FORM_TEMPLATE_STATUS_DRAFT,
          ),
      canManage: widget.canManage,
      onSaved: widget.onSaved,
      onNewVersion: _startNewVersion,
    );
  }

  void _startNewVersion(FormTemplateObject published) {
    setState(() {
      _draft = published.deepCopy()
        ..clearId()
        ..status = FormTemplateStatus.FORM_TEMPLATE_STATUS_DRAFT;
    });
  }
}

class _TemplateEditor extends ConsumerStatefulWidget {
  const _TemplateEditor({
    super.key,
    required this.template,
    required this.canManage,
    required this.onSaved,
    required this.onNewVersion,
  });

  final FormTemplateObject template;
  final bool canManage;
  final void Function(String templateId)? onSaved;
  final void Function(FormTemplateObject published) onNewVersion;

  @override
  ConsumerState<_TemplateEditor> createState() => _TemplateEditorState();
}

class _TemplateEditorState extends ConsumerState<_TemplateEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late String _organizationId;
  late String _entityType;
  late List<String> _sections;
  late List<FormFieldDefinition> _fields;
  bool _busy = false;
  String? _error;

  FormTemplateObject get _template => widget.template;

  bool get _isDraft =>
      _template.status == FormTemplateStatus.FORM_TEMPLATE_STATUS_DRAFT ||
      _template.status == FormTemplateStatus.FORM_TEMPLATE_STATUS_UNSPECIFIED;

  bool get _editable => widget.canManage && _isDraft;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: _template.name);
    _description = TextEditingController(text: _template.description);
    _organizationId = _template.organizationId;
    _entityType = _template.entityType.isEmpty
        ? 'client'
        : _template.entityType;
    _sections = [..._template.sections];
    _fields = [for (final f in _template.fields) f.deepCopy()];
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  FormTemplateObject _build() {
    final out = FormTemplateObject(
      name: _name.text.trim(),
      description: _description.text.trim(),
      organizationId: _organizationId,
      entityType: _entityType,
      version: _template.version,
      sections: _sections,
      fields: [
        for (var i = 0; i < _fields.length; i++) _fields[i]..order = i + 1,
      ],
    );
    if (_template.hasId() && _template.id.isNotEmpty) out.id = _template.id;
    return out;
  }

  String? _validateFields() {
    if (_fields.isEmpty) return 'Add at least one field';
    final keys = <String>{};
    for (final f in _fields) {
      if (f.label.trim().isEmpty) return 'Every field needs a label';
      if (f.key.isEmpty) return 'Field "${f.label}" needs a key';
      if (!keys.add(f.key)) return 'Two fields share the key "${f.key}"';
      if (_isChoice(f.fieldType) && f.options.isEmpty) {
        return 'Field "${f.label}" needs at least one option';
      }
    }
    return null;
  }

  Future<FormTemplateObject?> _save() async {
    if (!_formKey.currentState!.validate()) return null;
    final fieldError = _validateFields();
    if (fieldError != null) {
      setState(() => _error = fieldError);
      return null;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final saved = await ref
          .read(formTemplateNotifierProvider.notifier)
          .save(_build());
      if (!mounted) return saved;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Draft saved')));
      widget.onSaved?.call(saved.id);
      return saved;
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = friendlyError(e);
        });
      }
      return null;
    }
  }

  Future<void> _publish() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publish this template?'),
        content: const Text(
          'Once published it cannot be changed. New clients are asked for '
          'these fields; changes later go into a new version.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('form-designer-publish-confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Publish'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final saved = await _save();
    if (saved == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final published = await ref
          .read(formTemplateNotifierProvider.notifier)
          .publish(saved.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Published as version ${published.version}')),
      );
      widget.onSaved?.call(published.id);
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editField([int? index]) async {
    final edited = await showDialog<FormFieldDefinition>(
      context: context,
      builder: (_) => FieldDefinitionDialog(
        field: index == null ? null : _fields[index],
        sections: _sections,
        takenKeys: {
          for (var i = 0; i < _fields.length; i++)
            if (i != index) _fields[i].key,
        },
      ),
    );
    if (edited == null) return;
    setState(() {
      if (index == null) {
        _fields.add(edited);
      } else {
        _fields[index] = edited;
      }
    });
  }

  Future<void> _addSection() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add section'),
        content: TextField(
          key: const Key('form-designer-section-name'),
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Section name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || _sections.contains(name)) return;
    setState(() => _sections.add(name));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orgs = ref.watch(organizationListProvider(''));

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _template.hasId() && _template.id.isNotEmpty
                      ? 'Form template · v${_template.version}'
                      : 'New form template',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!_isDraft)
                Chip(
                  label: Text(
                    _template.status ==
                            FormTemplateStatus.FORM_TEMPLATE_STATUS_PUBLISHED
                        ? 'Published'
                        : 'Archived',
                  ),
                ),
            ],
          ),
          if (!_isDraft) ...[
            const SizedBox(height: 8),
            Text(
              'A published template cannot be changed. Start a new version to '
              'change what clients are asked for.',
              style: theme.textTheme.bodyMedium,
            ),
            if (widget.canManage)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    key: const Key('form-designer-new-version'),
                    onPressed: () => widget.onNewVersion(_template),
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text('New version'),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('form-designer-name'),
            controller: _name,
            enabled: _editable,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'A name is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _description,
            enabled: _editable,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 320,
                child: orgs.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) =>
                      Text('Could not load organizations: ${friendlyError(e)}'),
                  data: (list) => DropdownButtonFormField<String>(
                    key: const Key('form-designer-organization'),
                    initialValue:
                        list.any((o) => o.id == _organizationId) ||
                            _organizationId.isEmpty
                        ? (_organizationId.isEmpty ? null : _organizationId)
                        : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Organization',
                    ),
                    items: [
                      for (final org in list)
                        DropdownMenuItem(value: org.id, child: Text(org.name)),
                    ],
                    onChanged: _editable
                        ? (v) => setState(() => _organizationId = v ?? '')
                        : null,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Choose the organization'
                        : null,
                  ),
                ),
              ),
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<String>(
                  key: const Key('form-designer-entity'),
                  initialValue: designerEntityTypes.containsKey(_entityType)
                      ? _entityType
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Used for'),
                  items: [
                    for (final e in designerEntityTypes.entries)
                      DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ],
                  onChanged: _editable
                      ? (v) => setState(() => _entityType = v ?? 'client')
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Sections', style: theme.textTheme.titleMedium),
              const Spacer(),
              if (_editable)
                TextButton.icon(
                  key: const Key('form-designer-add-section'),
                  onPressed: _addSection,
                  icon: const Icon(Icons.add),
                  label: const Text('Add section'),
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: [
              if (_sections.isEmpty)
                Text(
                  'No sections: all fields show on one page.',
                  style: theme.textTheme.bodySmall,
                ),
              for (final section in _sections)
                InputChip(
                  label: Text(section),
                  onDeleted: _editable
                      ? () => setState(() {
                          _sections.remove(section);
                          for (final f in _fields) {
                            if (f.section == section) f.section = '';
                          }
                        })
                      : null,
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Fields (${_fields.length})',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              if (_editable)
                FilledButton.tonalIcon(
                  key: const Key('form-designer-add-field'),
                  onPressed: () => _editField(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add field'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _fields.length; i++)
            Card(
              key: Key('form-designer-field-${_fields[i].key}'),
              elevation: 0,
              child: ListTile(
                title: Text(
                  '${_fields[i].label}${_fields[i].required ? ' *' : ''}',
                ),
                subtitle: Text(
                  [
                    designerFieldTypes[_fields[i].fieldType] ??
                        _fields[i].fieldType.name,
                    _fields[i].key,
                    if (_fields[i].section.isNotEmpty) _fields[i].section,
                  ].join(' · '),
                ),
                onTap: _editable ? () => _editField(i) : null,
                trailing: _editable
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Move up',
                            icon: const Icon(Icons.arrow_upward),
                            onPressed: i == 0
                                ? null
                                : () => setState(() {
                                    final f = _fields.removeAt(i);
                                    _fields.insert(i - 1, f);
                                  }),
                          ),
                          IconButton(
                            tooltip: 'Remove',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                setState(() => _fields.removeAt(i)),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              key: const Key('form-designer-error'),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          if (_editable) ...[
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                OutlinedButton(
                  key: const Key('form-designer-save'),
                  onPressed: _busy ? null : _save,
                  child: const Text('Save draft'),
                ),
                FilledButton(
                  key: const Key('form-designer-publish'),
                  onPressed: _busy ? null : _publish,
                  child: const Text('Publish'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Edits one field definition.
class FieldDefinitionDialog extends StatefulWidget {
  const FieldDefinitionDialog({
    super.key,
    this.field,
    required this.sections,
    required this.takenKeys,
  });

  final FormFieldDefinition? field;
  final List<String> sections;
  final Set<String> takenKeys;

  @override
  State<FieldDefinitionDialog> createState() => _FieldDefinitionDialogState();
}

class _FieldDefinitionDialogState extends State<FieldDefinitionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _label;
  late final TextEditingController _key;
  late final TextEditingController _help;
  late final TextEditingController _options;
  late FormFieldType _type;
  late bool _required;
  late String _section;
  late bool _keyTouched;

  @override
  void initState() {
    super.initState();
    final f = widget.field;
    _label = TextEditingController(text: f?.label ?? '');
    _key = TextEditingController(text: f?.key ?? '');
    _help = TextEditingController(text: f?.description ?? '');
    _options = TextEditingController(text: f?.options.join(', ') ?? '');
    _type = f != null && designerFieldTypes.containsKey(f.fieldType)
        ? f.fieldType
        : FormFieldType.FORM_FIELD_TYPE_TEXT;
    _required = f?.required ?? true;
    _section = widget.sections.contains(f?.section) ? f!.section : '';
    _keyTouched = f != null;
  }

  @override
  void dispose() {
    _label.dispose();
    _key.dispose();
    _help.dispose();
    _options.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final options = _options.text
        .split(',')
        .map((o) => o.trim())
        .where((o) => o.isNotEmpty)
        .toList();
    Navigator.of(context).pop(
      FormFieldDefinition(
        key: _key.text.trim(),
        label: _label.text.trim(),
        fieldType: _type,
        required: _required,
        description: _help.text.trim(),
        section: _section,
        options: _isChoice(_type) ? options : const <String>[],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.field == null ? 'Add field' : 'Edit field'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const Key('field-dialog-label'),
                  controller: _label,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Label'),
                  onChanged: (v) {
                    if (!_keyTouched) _key.text = fieldKeyFromLabel(v);
                  },
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'A label is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('field-dialog-key'),
                  controller: _key,
                  decoration: const InputDecoration(
                    labelText: 'Key',
                    helperText: 'Stored with the answer; lower case and _',
                  ),
                  onChanged: (_) => _keyTouched = true,
                  validator: (v) {
                    final key = v?.trim() ?? '';
                    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(key)) {
                      return 'Use lower case letters, digits and _';
                    }
                    if (widget.takenKeys.contains(key)) {
                      return 'Another field already uses this key';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<FormFieldType>(
                  key: const Key('field-dialog-type'),
                  initialValue: _type,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: [
                    for (final t in designerFieldTypes.entries)
                      DropdownMenuItem(value: t.key, child: Text(t.value)),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? _type),
                ),
                if (_isChoice(_type)) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('field-dialog-options'),
                    controller: _options,
                    decoration: const InputDecoration(
                      labelText: 'Options, separated by commas',
                    ),
                    validator: (v) =>
                        (v == null ||
                            v.split(',').every((o) => o.trim().isEmpty))
                        ? 'Give at least one option'
                        : null,
                  ),
                ],
                if (widget.sections.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _section,
                    decoration: const InputDecoration(labelText: 'Section'),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('None')),
                      for (final s in widget.sections)
                        DropdownMenuItem(value: s, child: Text(s)),
                    ],
                    onChanged: (v) => setState(() => _section = v ?? ''),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _help,
                  decoration: const InputDecoration(labelText: 'Help text'),
                ),
                SwitchListTile(
                  key: const Key('field-dialog-required'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Required'),
                  value: _required,
                  onChanged: (v) => setState(() => _required = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('field-dialog-submit'),
          onPressed: _submit,
          child: const Text('Done'),
        ),
      ],
    );
  }
}
