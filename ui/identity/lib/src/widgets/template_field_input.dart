import 'package:antinvestor_api_identity/antinvestor_api_identity.dart'
    show FormFieldDefinition, FormFieldType;
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:flutter/material.dart';

/// Field types captured as a typed value on the onboarding form. Photos,
/// files, signatures and locations need an upload and are added on the
/// client's KYC tab instead.
bool templateFieldCapturedInline(FormFieldDefinition field) =>
    switch (field.fieldType) {
      FormFieldType.FORM_FIELD_TYPE_PHOTO ||
      FormFieldType.FORM_FIELD_TYPE_FILE ||
      FormFieldType.FORM_FIELD_TYPE_SIGNATURE ||
      FormFieldType.FORM_FIELD_TYPE_LOCATION => false,
      _ => true,
    };

/// One field of an organization's client form template, rendered by its
/// type. The value is kept in [controller] as text: dates as YYYY-MM-DD,
/// checkboxes as "true"/"false", multi-selects comma separated.
class TemplateFieldInput extends StatefulWidget {
  const TemplateFieldInput({
    super.key,
    required this.field,
    required this.controller,
  });

  final FormFieldDefinition field;
  final TextEditingController controller;

  @override
  State<TemplateFieldInput> createState() => _TemplateFieldInputState();
}

class _TemplateFieldInputState extends State<TemplateFieldInput> {
  FormFieldDefinition get _field => widget.field;

  String get _label => _field.label.isNotEmpty ? _field.label : _field.key;

  /// A required field is marked, not enforced: what is still missing shows
  /// on the activation checklist, so onboarding never stalls on it. A value
  /// that is given must match the field's pattern and bounds.
  String? _validate(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return null;
    if (_field.minLength > 0 && value.length < _field.minLength) {
      return 'At least ${_field.minLength} characters';
    }
    if (_field.maxLength > 0 && value.length > _field.maxLength) {
      return 'At most ${_field.maxLength} characters';
    }
    if (_field.validationPattern.isNotEmpty &&
        !RegExp(_field.validationPattern).hasMatch(value)) {
      return _field.validationMessage.isNotEmpty
          ? _field.validationMessage
          : 'Not a valid $_label';
    }
    if (_field.fieldType == FormFieldType.FORM_FIELD_TYPE_NUMBER ||
        _field.fieldType == FormFieldType.FORM_FIELD_TYPE_CURRENCY) {
      final number = num.tryParse(value);
      if (number == null) return 'Enter a number';
      final min = num.tryParse(_field.minValue);
      final max = num.tryParse(_field.maxValue);
      if (min != null && number < min) return 'At least ${_field.minValue}';
      if (max != null && number > max) return 'At most ${_field.maxValue}';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final current = DateTime.tryParse(widget.controller.text);
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - 30),
      firstDate: DateTime(now.year - 120),
      lastDate: DateTime(now.year + 50),
    );
    if (picked == null) return;
    setState(() {
      widget.controller.text =
          '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    });
  }

  Widget _input() {
    final key = Key('template-field-${_field.key}');
    final decoration = InputDecoration(
      hintText: _field.placeholder.isNotEmpty ? _field.placeholder : null,
    );
    switch (_field.fieldType) {
      case FormFieldType.FORM_FIELD_TYPE_SELECT:
        final value = widget.controller.text;
        return DropdownButtonFormField<String>(
          key: key,
          initialValue: _field.options.contains(value) ? value : null,
          decoration: decoration,
          items: [
            for (final o in _field.options)
              DropdownMenuItem(value: o, child: Text(o)),
          ],
          onChanged: (v) => widget.controller.text = v ?? '',
        );
      case FormFieldType.FORM_FIELD_TYPE_CHECKBOX:
        return CheckboxListTile(
          key: key,
          contentPadding: EdgeInsets.zero,
          value: widget.controller.text == 'true',
          title: Text(_label),
          onChanged: (v) =>
              setState(() => widget.controller.text = '${v ?? false}'),
        );
      case FormFieldType.FORM_FIELD_TYPE_DATE:
        return TextFormField(
          key: key,
          controller: widget.controller,
          readOnly: true,
          onTap: _pickDate,
          decoration: decoration.copyWith(
            hintText: 'YYYY-MM-DD',
            prefixIcon: const Icon(Icons.event_outlined),
          ),
        );
      default:
        return TextFormField(
          key: key,
          controller: widget.controller,
          keyboardType: switch (_field.fieldType) {
            FormFieldType.FORM_FIELD_TYPE_NUMBER ||
            FormFieldType.FORM_FIELD_TYPE_CURRENCY =>
              const TextInputType.numberWithOptions(decimal: true),
            FormFieldType.FORM_FIELD_TYPE_PHONE => TextInputType.phone,
            FormFieldType.FORM_FIELD_TYPE_EMAIL => TextInputType.emailAddress,
            FormFieldType.FORM_FIELD_TYPE_TEXTAREA => TextInputType.multiline,
            _ => TextInputType.text,
          },
          maxLines: _field.fieldType == FormFieldType.FORM_FIELD_TYPE_TEXTAREA
              ? 3
              : 1,
          textInputAction:
              _field.fieldType == FormFieldType.FORM_FIELD_TYPE_TEXTAREA
              ? TextInputAction.newline
              : TextInputAction.next,
          decoration: decoration,
          validator: _validate,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_field.fieldType == FormFieldType.FORM_FIELD_TYPE_CHECKBOX) {
      return _input();
    }
    return FormFieldCard(
      label: _label,
      description: _field.description.isNotEmpty
          ? _field.description
          : (_field.required
                ? 'Required before the client is activated.'
                : null),
      isRequired: _field.required,
      child: _input(),
    );
  }
}
