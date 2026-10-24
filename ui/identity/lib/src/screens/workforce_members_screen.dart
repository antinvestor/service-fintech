import 'package:antinvestor_api_identity/antinvestor_api_identity.dart'
    as common;
import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/widgets/admin_entity_list_page.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/org_unit_providers.dart';
import '../providers/organization_providers.dart';
import '../providers/workforce_member_providers.dart';
import '../widgets/org_unit_helpers.dart';
import '../widgets/async_state_views.dart';
import '../widgets/load_more_action.dart';

class WorkforceMembersScreen extends ConsumerStatefulWidget {
  const WorkforceMembersScreen({
    super.key,
    this.canManage = true,
    this.onNavigateToCreate,
    this.onNavigateToDetail,
  });

  final bool canManage;
  final VoidCallback? onNavigateToCreate;
  final void Function(String memberId)? onNavigateToDetail;

  @override
  ConsumerState<WorkforceMembersScreen> createState() =>
      _WorkforceMembersScreenState();
}

class _WorkforceMembersScreenState
    extends ConsumerState<WorkforceMembersScreen> {
  String _searchQuery = '';
  String _orgFilter = '';

  WorkforceMemberListParams get _params =>
      (query: _searchQuery, organizationId: _orgFilter, homeOrgUnitId: '');

  void _onSearch(String value) {
    setState(() => _searchQuery = value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final provider = workforceMemberPagedListProvider(_params);
    final membersAsync = ref.watch(provider);
    if (membersAsync.hasError) {
      return ListErrorView(
        title: 'Workforce Members',
        breadcrumbs: const ['Identity', 'Workforce Members'],
        error: membersAsync.error!,
        onRetry: () => ref.invalidate(provider),
      );
    }
    if (membersAsync.isLoading && !membersAsync.hasValue) {
      return const ListLoadingView(
        title: 'Workforce Members',
        breadcrumbs: ['Identity', 'Workforce Members'],
      );
    }
    final page = membersAsync.requireValue;
    final members = page.items;
    final orgsAsync = ref.watch(organizationListProvider(''));

    return AdminEntityListPage<WorkforceMemberObject>(
      title: 'Workforce Members',
      breadcrumbs: const ['Identity', 'Workforce Members'],
      columns: const [
        DataColumn(label: Text('NAME / PROFILE')),
        DataColumn(label: Text('ENGAGEMENT')),
        DataColumn(label: Text('ORG UNIT')),
        DataColumn(label: Text('STATE')),
      ],
      items: members,
      onSearch: _onSearch,
      addLabel: widget.canManage ? 'Register Member' : null,
      onAdd: widget.canManage
          ? () {
              if (widget.onNavigateToCreate != null) {
                widget.onNavigateToCreate!();
              } else {
                _showMemberDialog(context);
              }
            }
          : null,
      actions: [
        _buildFilters(orgsAsync),
        const SizedBox(width: 8),
        LoadMoreAction(
          loadedCount: members.length,
          hasMore: page.hasMore,
          isLoading: page.isLoadingMore,
          errorMessage: page.loadMoreError == null
              ? null
              : friendlyError(page.loadMoreError!),
          onLoadMore: () => ref.read(provider.notifier).loadMore(),
        ),
      ],
      rowBuilder: (member, selected, onSelect) {
        final name =
            member.hasProperties() &&
                member.properties.fields.containsKey('name')
            ? member.properties.fields['name']!.stringValue
            : member.profileId;

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
                      Icons.badge_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(name),
                ],
              ),
            ),
            DataCell(Text(engagementLabel(member.engagementType))),
            DataCell(
              Text(
                member.homeOrgUnitId.isNotEmpty ? member.homeOrgUnitId : '-',
              ),
            ),
            DataCell(Text(member.state.name)),
          ],
        );
      },
      onRowNavigate: (member) {
        if (widget.onNavigateToDetail != null) {
          widget.onNavigateToDetail!(member.id);
        } else {
          context.go('/workforce/${member.id}');
        }
      },
      detailBuilder: (member) => _MemberDetail(
        member: member,
        canManage: widget.canManage,
        onEdit: () => _showMemberDialog(context, member: member),
      ),
      exportRow: (member) => [
        member.profileId,
        engagementLabel(member.engagementType),
        member.homeOrgUnitId,
        member.state.name,
        member.id,
      ],
    );
  }

  Widget _buildFilters(AsyncValue<List<OrganizationObject>> orgsAsync) {
    // A failed org lookup only empties this filter; the list itself already
    // renders its own error state.
    final orgs = orgsAsync.value ?? const <OrganizationObject>[];
    return DropdownButton<String>(
      value: _orgFilter,
      hint: const Text('All Orgs'),
      underline: const SizedBox.shrink(),
      items: [
        const DropdownMenuItem(value: '', child: Text('All Organizations')),
        ...orgs.map(
          (o) => DropdownMenuItem(
            value: o.id,
            child: Text(o.name.isNotEmpty ? o.name : o.id),
          ),
        ),
      ],
      onChanged: (value) => setState(() => _orgFilter = value ?? ''),
    );
  }

  Future<void> _showMemberDialog(
    BuildContext context, {
    WorkforceMemberObject? member,
  }) async {
    final result = await showDialog<WorkforceMemberObject>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MemberFormDialog(member: member),
    );

    if (result != null && context.mounted) {
      try {
        await ref.read(workforceMemberNotifierProvider.notifier).save(result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                member == null
                    ? 'Member registered successfully'
                    : 'Member updated successfully',
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}

class _MemberDetail extends StatelessWidget {
  const _MemberDetail({
    required this.member,
    required this.canManage,
    required this.onEdit,
  });
  final WorkforceMemberObject member;
  final bool canManage;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name =
        member.hasProperties() && member.properties.fields.containsKey('name')
        ? member.properties.fields['name']!.stringValue
        : member.profileId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.badge_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    member.id,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            if (canManage)
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
          ],
        ),
        const SizedBox(height: 20),
        _DetailRow(label: 'Profile ID', value: member.profileId),
        _DetailRow(
          label: 'Engagement',
          value: engagementLabel(member.engagementType),
        ),
        _DetailRow(
          label: 'Org Unit',
          value: member.homeOrgUnitId.isNotEmpty ? member.homeOrgUnitId : '-',
        ),
        _DetailRow(label: 'State', value: member.state.name),
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

class _MemberFormDialog extends ConsumerStatefulWidget {
  const _MemberFormDialog({this.member});
  final WorkforceMemberObject? member;

  @override
  ConsumerState<_MemberFormDialog> createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends ConsumerState<_MemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _profileIdController;
  late final TextEditingController _geoIdController;
  late String _selectedOrgId;
  late String _selectedOrgUnitId;
  late final TextEditingController _engagementTypeCtrl;
  late common.STATE _state;

  bool get _isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    _profileIdController = TextEditingController(text: m?.profileId ?? '');
    _geoIdController = TextEditingController(text: m?.geoId ?? '');
    _selectedOrgId = m?.organizationId ?? '';
    _selectedOrgUnitId = m?.homeOrgUnitId ?? '';
    _engagementTypeCtrl = TextEditingController(
      text: m?.engagementType ?? 'employee',
    );
    _state = m?.state ?? common.STATE.CREATED;
  }

  @override
  void dispose() {
    _profileIdController.dispose();
    _geoIdController.dispose();
    _engagementTypeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orgsAsync = ref.watch(organizationListProvider(''));
    final orgUnitsAsync = ref.watch(
      orgUnitListProvider((
        organizationId: _selectedOrgId,
        query: '',
        parentId: '',
        rootOnly: false,
        type: OrgUnitType.ORG_UNIT_TYPE_UNSPECIFIED,
      )),
    );

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
              Icons.badge_outlined,
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
                  _isEditing ? 'Edit Member' : 'New Workforce Member',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _isEditing
                      ? 'Update the member details below.'
                      : 'Register a new employee, contractor, or service account.',
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
        width: 520,
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
                  label: 'Profile ID',
                  description:
                      'The platform profile identifier linking this member to their user account.',
                  isRequired: true,
                  child: TextFormField(
                    controller: _profileIdController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. d75qclkpf2t1uum8ij3g',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Profile ID is required'
                        : null,
                  ),
                ),
                FormFieldCard(
                  label: 'Engagement Type',
                  description:
                      'How this member is engaged with the organization.',
                  isRequired: true,
                  child: TextFormField(
                    controller: _engagementTypeCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. employee, contractor, agent',
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Engagement type is required'
                        : null,
                  ),
                ),
                FormFieldCard(
                  label: 'Organization',
                  description: 'The organization this member belongs to.',
                  isRequired: true,
                  child: orgsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Failed to load: $e'),
                    data: (orgs) => DropdownButtonFormField<String>(
                      initialValue:
                          _selectedOrgId.isNotEmpty &&
                              orgs.any((o) => o.id == _selectedOrgId)
                          ? _selectedOrgId
                          : null,
                      decoration: const InputDecoration(
                        hintText: 'Select organization',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                      items: orgs
                          .map(
                            (o) => DropdownMenuItem(
                              value: o.id,
                              child: Text(o.name.isNotEmpty ? o.name : o.id),
                            ),
                          )
                          .toList(),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Organization is required'
                          : null,
                      onChanged: (v) => setState(() {
                        _selectedOrgId = v ?? '';
                        _selectedOrgUnitId = '';
                      }),
                    ),
                  ),
                ),
                FormFieldCard(
                  label: 'Home Org Unit',
                  description:
                      'Optional. The org unit where this member is primarily based.',
                  child: orgUnitsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Failed to load: $e'),
                    data: (units) {
                      if (_selectedOrgId.isEmpty) {
                        return const Text(
                          'Select an organization first',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      return DropdownButtonFormField<String>(
                        initialValue:
                            _selectedOrgUnitId.isNotEmpty &&
                                units.any((u) => u.id == _selectedOrgUnitId)
                            ? _selectedOrgUnitId
                            : null,
                        decoration: const InputDecoration(
                          hintText: 'Select org unit',
                          prefixIcon: Icon(Icons.account_tree_outlined),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('None'),
                          ),
                          ...units.map(
                            (u) => DropdownMenuItem(
                              value: u.id,
                              child: Text(u.name.isNotEmpty ? u.name : u.id),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedOrgUnitId = v ?? ''),
                      );
                    },
                  ),
                ),
                FormFieldCard(
                  label: 'Geographic ID',
                  description:
                      "Optional geographic area identifier for this member's territory.",
                  child: TextFormField(
                    controller: _geoIdController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. KE-NBI-EAST',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                ),
                FormFieldCard(
                  label: 'State',
                  description: 'The current status of this member.',
                  isRequired: true,
                  child: DropdownButtonFormField<common.STATE>(
                    initialValue: _state,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.toggle_on_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: common.STATE.CREATED,
                        child: Text('Created'),
                      ),
                      DropdownMenuItem(
                        value: common.STATE.ACTIVE,
                        child: Text('Active'),
                      ),
                      DropdownMenuItem(
                        value: common.STATE.INACTIVE,
                        child: Text('Inactive'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _state = v);
                    },
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
          onPressed: _submit,
          icon: Icon(_isEditing ? Icons.save : Icons.add),
          label: Text(_isEditing ? 'Update' : 'Register Member'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      WorkforceMemberObject(
        id: widget.member?.id ?? '',
        profileId: _profileIdController.text.trim(),
        organizationId: _selectedOrgId,
        homeOrgUnitId: _selectedOrgUnitId,
        engagementType: _engagementTypeCtrl.text.trim(),
        geoId: _geoIdController.text.trim(),
        state: _state,
        // Properties carry the display name and the platform role; rebuilding
        // the object without them would wipe both on every edit.
        properties: widget.member?.properties,
      ),
    );
  }
}
