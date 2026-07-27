import 'dart:typed_data';

import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/auth/tenancy_context.dart';
import 'package:antinvestor_ui_core/widgets/admin_entity_list_page.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/organization_providers.dart';
import 'organization_form_wizard.dart';

// ---------------------------------------------------------------------------
// Public helpers
// ---------------------------------------------------------------------------

/// Human-readable label for OrganizationType.
String orgTypeLabel(OrganizationType type) => switch (type) {
      OrganizationType.ORGANIZATION_TYPE_UNSPECIFIED => 'Not specified',
      OrganizationType.ORGANIZATION_TYPE_BANK => 'Bank',
      OrganizationType.ORGANIZATION_TYPE_MICROFINANCE => 'Microfinance',
      OrganizationType.ORGANIZATION_TYPE_SACCO => 'SACCO',
      OrganizationType.ORGANIZATION_TYPE_FINTECH => 'Fintech',
      OrganizationType.ORGANIZATION_TYPE_COOPERATIVE => 'Cooperative',
      OrganizationType.ORGANIZATION_TYPE_NGO => 'NGO',
      OrganizationType.ORGANIZATION_TYPE_GOVERNMENT => 'Government',
      OrganizationType.ORGANIZATION_TYPE_OTHER => 'Other',
      _ => type.name,
    };

// ---------------------------------------------------------------------------
// Organizations list screen
// ---------------------------------------------------------------------------

class OrganizationsScreen extends ConsumerStatefulWidget {
  const OrganizationsScreen({
    super.key,
    this.canManage = true,
    this.onNavigate,
    this.onPickLogo,
    this.filesBaseUrl,
  });

  final bool canManage;
  final void Function(String id)? onNavigate;

  /// Callback to upload logo bytes. Passed through to [OrganizationFormWizard].
  final Future<String> Function(Uint8List bytes, String filename)? onPickLogo;

  /// Base URL for the files service (e.g. https://api.stawi.org/files).
  /// Used to convert mxc:// URIs to HTTP download URLs for storage.
  final String? filesBaseUrl;

  @override
  ConsumerState<OrganizationsScreen> createState() =>
      _OrganizationsScreenState();
}

class _OrganizationsScreenState extends ConsumerState<OrganizationsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final organizationsAsync = ref.watch(organizationListProvider(_query));
    final organizations = organizationsAsync.whenOrNull(data: (d) => d) ?? [];

    return AdminEntityListPage<OrganizationObject>(
      title: 'Organizations',
      breadcrumbs: const ['Identity', 'Organizations'],
      columns: const [
        DataColumn(label: Text('NAME')),
        DataColumn(label: Text('TYPE')),
        DataColumn(label: Text('STATE')),
      ],
      items: organizations,
      onSearch: (value) => setState(() => _query = value.trim()),
      addLabel: widget.canManage ? 'Add Organization' : null,
      onAdd: widget.canManage
          ? () => _showOrganizationDialog(context, ref)
          : null,
      rowBuilder: (org, selected, onSelect) {
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
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.account_balance,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(org.name),
                ],
              ),
            ),
            DataCell(Text(orgTypeLabel(org.organizationType))),
            DataCell(_StatePill(org.state)),
          ],
        );
      },
      onRowNavigate: (org) {
        if (widget.onNavigate != null) {
          widget.onNavigate!(org.id);
        } else {
          context.go('/organizations/${org.id}');
        }
      },
      detailBuilder: (org) => _OrganizationDetail(organization: org),
      exportRow: (org) => [
        org.name,
        orgTypeLabel(org.organizationType),
        org.state.name,
        org.id,
      ],
    );
  }

  void _showOrganizationDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => OrganizationFormWizard(
        onPickLogo: widget.onPickLogo,
        onSave: (result) async {
          try {
            final tenancy = ref.read(tenancyContextProvider);
            final org = result.organization;
            org.profileId = result.profileId;
            if (org.partitionId.isEmpty) {
              org.partitionId = tenancy.partitionId;
            }

            await ref
                .read(organizationNotifierProvider.notifier)
                .save(org);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Organization created successfully')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(friendlyError(e)),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
            rethrow;
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inline detail (used by AdminEntityListPage)
// ---------------------------------------------------------------------------

class _OrganizationDetail extends StatelessWidget {
  const _OrganizationDetail({required this.organization});
  final OrganizationObject organization;

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
              child: Icon(Icons.account_balance,
                  color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(organization.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(organization.id,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _DetailRow(
            label: 'Type',
            value: orgTypeLabel(organization.organizationType)),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text('State',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant)),
              ),
              _StatePill(organization.state),
            ],
          ),
        ),
        if (organization.code.isNotEmpty)
          _DetailRow(label: 'Code', value: organization.code),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Small shared widgets
// ---------------------------------------------------------------------------

class _StatePill extends StatelessWidget {
  const _StatePill(this.state);
  final dynamic state;

  @override
  Widget build(BuildContext context) {
    final label = state.name as String;
    final theme = Theme.of(context);
    final (Color bg, Color fg) = switch (label) {
      'ACTIVE' => (
          theme.colorScheme.tertiary.withAlpha(20),
          theme.colorScheme.tertiary
        ),
      'CREATED' => (
          theme.colorScheme.secondary.withAlpha(20),
          theme.colorScheme.secondary
        ),
      'INACTIVE' || 'DELETED' => (
          theme.colorScheme.error.withAlpha(20),
          theme.colorScheme.error
        ),
      _ => (
          theme.colorScheme.outline.withAlpha(20),
          theme.colorScheme.outline
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
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
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
