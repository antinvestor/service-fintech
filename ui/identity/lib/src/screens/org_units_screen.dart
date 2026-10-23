import 'dart:async';

import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/widgets/admin_entity_list_page.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/org_unit_providers.dart';
import '../providers/organization_providers.dart';
import '../widgets/org_unit_helpers.dart';
import 'org_unit_form_dialog.dart';
import '../widgets/async_state_views.dart';
import '../widgets/load_more_action.dart';

class OrgUnitsScreen extends ConsumerStatefulWidget {
  const OrgUnitsScreen({super.key, this.canManage = true, this.onNavigate});

  final bool canManage;
  final void Function(String id)? onNavigate;

  @override
  ConsumerState<OrgUnitsScreen> createState() => _OrgUnitsScreenState();
}

class _OrgUnitsScreenState extends ConsumerState<OrgUnitsScreen> {
  String _searchQuery = '';
  String _selectedOrganizationId = '';
  OrgUnitType _selectedType = OrgUnitType.ORG_UNIT_TYPE_UNSPECIFIED;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _searchQuery = value.trim());
      }
    });
  }

  OrgUnitListParams get _params => (
    query: _searchQuery,
    organizationId: _selectedOrganizationId,
    type: _selectedType,
    parentId: '',
    rootOnly: false,
  );

  @override
  Widget build(BuildContext context) {
    final provider = orgUnitPagedListProvider(_params);
    final orgUnitsAsync = ref.watch(provider);
    if (orgUnitsAsync.hasError) {
      return ListErrorView(
        title: 'Org Units',
        breadcrumbs: const ['Identity', 'Org Units'],
        error: orgUnitsAsync.error!,
        onRetry: () => ref.invalidate(provider),
      );
    }
    if (orgUnitsAsync.isLoading && !orgUnitsAsync.hasValue) {
      return const ListLoadingView(
        title: 'Org Units',
        breadcrumbs: ['Identity', 'Org Units'],
      );
    }
    final page = orgUnitsAsync.requireValue;
    final orgUnits = page.items;
    final organizationsAsync = ref.watch(organizationListProvider(''));
    final organizations =
        organizationsAsync.value ?? const <OrganizationObject>[];

    return AdminEntityListPage<OrgUnitObject>(
      title: 'Org Units',
      breadcrumbs: const ['Identity', 'Org Units'],
      columns: const [
        DataColumn(label: Text('NAME')),
        DataColumn(label: Text('TYPE')),
        DataColumn(label: Text('CODE')),
        DataColumn(label: Text('STATE')),
      ],
      items: orgUnits,
      onSearch: _onSearch,
      addLabel: widget.canManage ? 'Add Org Unit' : null,
      onAdd: widget.canManage
          ? () => _showOrgUnitDialog(context, organizations: organizations)
          : null,
      actions: [
        _buildFilters(organizations),
        const SizedBox(width: 8),
        LoadMoreAction(
          loadedCount: orgUnits.length,
          hasMore: page.hasMore,
          isLoading: page.isLoadingMore,
          errorMessage: page.loadMoreError == null
              ? null
              : friendlyError(page.loadMoreError!),
          onLoadMore: () => ref.read(provider.notifier).loadMore(),
        ),
      ],
      rowBuilder: (orgUnit, selected, onSelect) {
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
                      orgUnit.type == OrgUnitType.ORG_UNIT_TYPE_BRANCH
                          ? Icons.store_outlined
                          : Icons.account_tree_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(orgUnit.name),
                ],
              ),
            ),
            DataCell(Text(orgUnitTypeLabel(orgUnit.type))),
            DataCell(Text(orgUnit.code)),
            DataCell(Text(orgUnit.state.name)),
          ],
        );
      },
      onRowNavigate: (orgUnit) {
        if (widget.onNavigate != null) {
          widget.onNavigate!(orgUnit.id);
        } else {
          context.go('/org-units/${orgUnit.id}');
        }
      },
      detailBuilder: (orgUnit) => _OrgUnitDetail(
        orgUnit: orgUnit,
        organizationName: {
          for (final org in organizations) org.id: org.name,
        }[orgUnit.organizationId],
      ),
      exportRow: (orgUnit) => [
        orgUnit.name,
        orgUnitTypeLabel(orgUnit.type),
        orgUnit.code,
        orgUnit.state.name,
        orgUnit.id,
      ],
    );
  }

  Widget _buildFilters(List<OrganizationObject> organizations) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<String>(
          value: _selectedOrganizationId,
          underline: const SizedBox.shrink(),
          items: [
            const DropdownMenuItem(value: '', child: Text('All Organizations')),
            ...organizations.map(
              (org) => DropdownMenuItem(value: org.id, child: Text(org.name)),
            ),
          ],
          onChanged: (value) =>
              setState(() => _selectedOrganizationId = value ?? ''),
        ),
        const SizedBox(width: 8),
        DropdownButton<OrgUnitType>(
          value: _selectedType,
          underline: const SizedBox.shrink(),
          items: [
            const DropdownMenuItem(
              value: OrgUnitType.ORG_UNIT_TYPE_UNSPECIFIED,
              child: Text('All Types'),
            ),
            ...editableOrgUnitTypes.map(
              (type) => DropdownMenuItem(
                value: type,
                child: Text(orgUnitTypeLabel(type)),
              ),
            ),
          ],
          onChanged: (value) => setState(
            () =>
                _selectedType = value ?? OrgUnitType.ORG_UNIT_TYPE_UNSPECIFIED,
          ),
        ),
      ],
    );
  }

  Future<void> _showOrgUnitDialog(
    BuildContext context, {
    OrgUnitObject? orgUnit,
    required List<OrganizationObject> organizations,
  }) async {
    final result = await showDialog<OrgUnitObject>(
      context: context,
      builder: (context) =>
          OrgUnitFormDialog(orgUnit: orgUnit, organizations: organizations),
    );
    if (result == null || !mounted) return;

    try {
      await ref.read(orgUnitNotifierProvider.notifier).save(result);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            orgUnit == null
                ? 'Org unit created successfully'
                : 'Org unit updated successfully',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save org unit: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class _OrgUnitDetail extends StatelessWidget {
  const _OrgUnitDetail({required this.orgUnit, this.organizationName});
  final OrgUnitObject orgUnit;
  final String? organizationName;

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
              child: Icon(
                orgUnit.type == OrgUnitType.ORG_UNIT_TYPE_BRANCH
                    ? Icons.store_outlined
                    : Icons.account_tree_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orgUnit.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    orgUnit.id,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _DetailRow(label: 'Type', value: orgUnitTypeLabel(orgUnit.type)),
        _DetailRow(label: 'Code', value: orgUnit.code),
        _DetailRow(label: 'State', value: orgUnit.state.name),
        if (organizationName != null && organizationName!.isNotEmpty)
          _DetailRow(label: 'Organization', value: organizationName!),
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
