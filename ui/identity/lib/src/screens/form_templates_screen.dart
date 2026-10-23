import 'dart:async';

import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/widgets/admin_entity_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/form_template_providers.dart';
import '../widgets/async_state_views.dart';

/// Lists all form templates with search, status filter, and create action.
class FormTemplatesScreen extends ConsumerStatefulWidget {
  const FormTemplatesScreen({super.key, this.onNavigateToDesigner});

  /// Navigates to the template designer, with null meaning "new template".
  ///
  /// This package ships no designer screen and no host route is guaranteed to
  /// exist, so when this is null the create action is hidden and rows open the
  /// inline detail panel instead of navigating nowhere.
  final void Function(String? templateId)? onNavigateToDesigner;

  @override
  ConsumerState<FormTemplatesScreen> createState() =>
      _FormTemplatesScreenState();
}

class _FormTemplatesScreenState extends ConsumerState<FormTemplatesScreen> {
  Timer? _debounce;
  String _query = '';

  FormTemplateListParams get _params => (query: _query, organizationId: '');

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _query = value.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(formTemplateListProvider(_params));
    if (templatesAsync.hasError) {
      return ListErrorView(
        title: 'KYC Form Templates',
        breadcrumbs: const ['Identity', 'Form Templates'],
        error: templatesAsync.error!,
        onRetry: () => ref.invalidate(formTemplateListProvider(_params)),
      );
    }
    if (templatesAsync.isLoading && !templatesAsync.hasValue) {
      return const ListLoadingView(
        title: 'KYC Form Templates',
        breadcrumbs: ['Identity', 'Form Templates'],
      );
    }
    final items = templatesAsync.requireValue;

    return AdminEntityListPage<FormTemplateObject>(
      title: 'KYC Form Templates',
      breadcrumbs: const ['Identity', 'Form Templates'],
      columns: const [
        DataColumn(label: Text('NAME')),
        DataColumn(label: Text('FIELDS')),
        DataColumn(label: Text('VERSION')),
        DataColumn(label: Text('STATUS')),
      ],
      items: items,
      onSearch: _onSearch,
      addLabel: widget.onNavigateToDesigner != null ? 'New Template' : null,
      onAdd: widget.onNavigateToDesigner != null
          ? () => widget.onNavigateToDesigner!(null)
          : null,
      rowBuilder: (template, selected, onSelect) {
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
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.dynamic_form,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(template.name.isNotEmpty ? template.name : '(untitled)'),
                ],
              ),
            ),
            DataCell(Text('${template.fields.length}')),
            DataCell(Text('v${template.version}')),
            DataCell(_StatusBadge(status: template.status)),
          ],
        );
      },
      onRowNavigate: widget.onNavigateToDesigner != null
          ? (template) => widget.onNavigateToDesigner!(template.id)
          : null,
      detailBuilder: (template) => _FormTemplateDetail(template: template),
      exportRow: (template) => [
        template.name,
        '${template.fields.length}',
        'v${template.version}',
        _statusLabel(template.status),
        template.id,
      ],
    );
  }
}

String _statusLabel(FormTemplateStatus status) => switch (status) {
  FormTemplateStatus.FORM_TEMPLATE_STATUS_DRAFT => 'DRAFT',
  FormTemplateStatus.FORM_TEMPLATE_STATUS_PUBLISHED => 'PUBLISHED',
  FormTemplateStatus.FORM_TEMPLATE_STATUS_ARCHIVED => 'ARCHIVED',
  _ => 'UNKNOWN',
};

class _FormTemplateDetail extends StatelessWidget {
  const _FormTemplateDetail({required this.template});
  final FormTemplateObject template;

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
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.dynamic_form, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name.isNotEmpty ? template.name : '(untitled)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    template.id,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            _StatusBadge(status: template.status),
          ],
        ),
        const SizedBox(height: 20),
        _DetailRow(label: 'Fields', value: '${template.fields.length}'),
        _DetailRow(label: 'Version', value: 'v${template.version}'),
        _DetailRow(label: 'Status', value: _statusLabel(template.status)),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final FormTemplateStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      FormTemplateStatus.FORM_TEMPLATE_STATUS_DRAFT => ('DRAFT', Colors.orange),
      FormTemplateStatus.FORM_TEMPLATE_STATUS_PUBLISHED => (
        'PUBLISHED',
        Colors.green,
      ),
      FormTemplateStatus.FORM_TEMPLATE_STATUS_ARCHIVED => (
        'ARCHIVED',
        Colors.grey,
      ),
      _ => ('UNKNOWN', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
