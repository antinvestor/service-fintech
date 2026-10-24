import 'package:antinvestor_api_identity/antinvestor_api_identity.dart'
    as common;
import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/widgets/admin_entity_list_page.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:antinvestor_ui_core/widgets/state_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/access_role_providers.dart';
import '../widgets/org_unit_helpers.dart';
import '../widgets/state_helpers.dart';
import '../widgets/async_state_views.dart';

const _selectableStates = [
  common.STATE.CREATED,
  common.STATE.CHECKED,
  common.STATE.ACTIVE,
  common.STATE.INACTIVE,
  common.STATE.DELETED,
];

class AccessRolesScreen extends ConsumerStatefulWidget {
  const AccessRolesScreen({super.key, this.canManage = true});

  final bool canManage;

  @override
  ConsumerState<AccessRolesScreen> createState() => _AccessRolesScreenState();
}

class _AccessRolesScreenState extends ConsumerState<AccessRolesScreen> {
  String _searchQuery = '';
  String _roleKeyFilter = '';

  AccessRoleAssignmentListParams get _params =>
      (query: _searchQuery, roleKey: _roleKeyFilter, scopeId: '');

  void _onSearch(String value) {
    setState(() => _searchQuery = value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(
      accessRoleAssignmentListProvider(_params),
    );
    if (assignmentsAsync.hasError) {
      return ListErrorView(
        title: 'Access Roles',
        breadcrumbs: const ['Identity', 'Access Roles'],
        error: assignmentsAsync.error!,
        onRetry: () =>
            ref.invalidate(accessRoleAssignmentListProvider(_params)),
      );
    }
    if (assignmentsAsync.isLoading && !assignmentsAsync.hasValue) {
      return const ListLoadingView(
        title: 'Access Roles',
        breadcrumbs: ['Identity', 'Access Roles'],
      );
    }
    final assignments = assignmentsAsync.requireValue;

    return AdminEntityListPage<AccessRoleAssignmentObject>(
      title: 'Access Roles',
      breadcrumbs: const ['Identity', 'Access Roles'],
      columns: const [
        DataColumn(label: Text('ROLE KEY')),
        DataColumn(label: Text('MEMBER')),
        DataColumn(label: Text('SCOPE')),
        DataColumn(label: Text('STATE')),
      ],
      items: assignments,
      onSearch: _onSearch,
      addLabel: widget.canManage ? 'Add Role Assignment' : null,
      onAdd: widget.canManage ? () => _showAssignmentDialog(context) : null,
      actions: [_buildFilters()],
      rowBuilder: (assignment, selected, onSelect) {
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
                      Icons.security_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(accessRoleLabel(assignment.roleKey)),
                ],
              ),
            ),
            DataCell(
              Text(assignment.memberId.isNotEmpty ? assignment.memberId : '-'),
            ),
            DataCell(
              Text(
                '${scopeLabel(assignment.scopeType)}'
                '${assignment.scopeId.isNotEmpty ? ': ${assignment.scopeId}' : ''}',
              ),
            ),
            DataCell(Text(assignment.state.name)),
          ],
        );
      },
      detailBuilder: (assignment) => _AssignmentDetail(
        assignment: assignment,
        canManage: widget.canManage,
        onEdit: () => _showAssignmentDialog(context, assignment: assignment),
      ),
      exportRow: (assignment) => [
        accessRoleLabel(assignment.roleKey),
        assignment.memberId,
        '${scopeLabel(assignment.scopeType)}: ${assignment.scopeId}',
        assignment.state.name,
        assignment.id,
      ],
    );
  }

  Widget _buildFilters() {
    return DropdownButton<String>(
      value: _roleKeyFilter,
      underline: const SizedBox.shrink(),
      icon: const Icon(Icons.filter_list, size: 20),
      items: [
        const DropdownMenuItem(value: '', child: Text('All Roles')),
        for (final key in selectableRoleKeys)
          DropdownMenuItem(value: key, child: Text(accessRoleLabel(key))),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _roleKeyFilter = value);
        }
      },
    );
  }

  Future<void> _showAssignmentDialog(
    BuildContext context, {
    AccessRoleAssignmentObject? assignment,
  }) async {
    final result = await showDialog<AccessRoleAssignmentObject>(
      context: context,
      builder: (context) => _AssignmentDialog(assignment: assignment),
    );

    if (result == null || !mounted) return;

    try {
      await ref
          .read(accessRoleAssignmentNotifierProvider.notifier)
          .save(result);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            assignment == null
                ? 'Role assignment created successfully'
                : 'Role assignment updated successfully',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }
}

class _AssignmentDetail extends StatelessWidget {
  const _AssignmentDetail({
    required this.assignment,
    required this.canManage,
    required this.onEdit,
  });
  final AccessRoleAssignmentObject assignment;
  final bool canManage;
  final VoidCallback onEdit;

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
                Icons.security_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accessRoleLabel(assignment.roleKey),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    assignment.id,
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
        _DetailRow(label: 'Role Key', value: assignment.roleKey),
        _DetailRow(
          label: 'Member',
          value: assignment.memberId.isNotEmpty ? assignment.memberId : '-',
        ),
        _DetailRow(
          label: 'Scope',
          value:
              '${scopeLabel(assignment.scopeType)}'
              '${assignment.scopeId.isNotEmpty ? ': ${assignment.scopeId}' : ''}',
        ),
        _DetailRow(label: 'State', value: assignment.state.name),
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

class _AssignmentDialog extends ConsumerStatefulWidget {
  const _AssignmentDialog({this.assignment});

  final AccessRoleAssignmentObject? assignment;

  @override
  ConsumerState<_AssignmentDialog> createState() => _AssignmentDialogState();
}

class _AssignmentDialogState extends ConsumerState<_AssignmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _memberIdController;
  late final TextEditingController _scopeIdController;
  late String _selectedRoleKey;
  late AccessScopeType _selectedScopeType;
  late common.STATE _selectedState;

  bool get _isEditing => widget.assignment != null;

  @override
  void initState() {
    super.initState();
    _memberIdController = TextEditingController(
      text: widget.assignment?.memberId ?? '',
    );
    _scopeIdController = TextEditingController(
      text: widget.assignment?.scopeId ?? '',
    );
    _selectedRoleKey =
        widget.assignment?.roleKey ?? AccessRoleKeys.approvalVerifier;
    _selectedScopeType =
        widget.assignment?.scopeType ??
        AccessScopeType.ACCESS_SCOPE_TYPE_ORGANIZATION;
    _selectedState = widget.assignment?.state ?? common.STATE.CREATED;
  }

  @override
  void dispose() {
    _memberIdController.dispose();
    _scopeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Role Assignment' : 'Add Role Assignment'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormFieldCard(
                  label: 'Workforce Member ID',
                  description:
                      'The ID of the workforce member to assign this role to.',
                  isRequired: true,
                  child: TextFormField(
                    controller: _memberIdController,
                    decoration: const InputDecoration(
                      hintText: 'Enter member ID',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Member ID is required';
                      }
                      return null;
                    },
                  ),
                ),
                FormFieldCard(
                  label: 'Role',
                  description: 'The access role to assign to this member.',
                  isRequired: true,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedRoleKey,
                    items: [
                      for (final key in selectableRoleKeys)
                        DropdownMenuItem(
                          value: key,
                          child: Text(accessRoleLabel(key)),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedRoleKey = value);
                      }
                    },
                  ),
                ),
                FormFieldCard(
                  label: 'Scope Type',
                  description: 'The scope at which this role applies.',
                  isRequired: true,
                  child: DropdownButtonFormField<AccessScopeType>(
                    initialValue: _selectedScopeType,
                    items: const [
                      DropdownMenuItem(
                        value: AccessScopeType.ACCESS_SCOPE_TYPE_GLOBAL,
                        child: Text('Global'),
                      ),
                      DropdownMenuItem(
                        value: AccessScopeType.ACCESS_SCOPE_TYPE_ORGANIZATION,
                        child: Text('Organization'),
                      ),
                      DropdownMenuItem(
                        value: AccessScopeType.ACCESS_SCOPE_TYPE_ORG_UNIT,
                        child: Text('Org Unit'),
                      ),
                      DropdownMenuItem(
                        value: AccessScopeType.ACCESS_SCOPE_TYPE_TEAM,
                        child: Text('Team'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedScopeType = value);
                      }
                    },
                  ),
                ),
                FormFieldCard(
                  label: 'Scope ID',
                  description:
                      'The ID of the org, org unit, or team this role is scoped to. '
                      'Leave empty for global scope.',
                  child: TextFormField(
                    controller: _scopeIdController,
                    decoration: const InputDecoration(
                      hintText: 'Enter scope ID (optional for global)',
                    ),
                  ),
                ),
                FormFieldCard(
                  label: 'State',
                  description: 'The current lifecycle state.',
                  isRequired: true,
                  child: DropdownButtonFormField<common.STATE>(
                    initialValue: _selectedState,
                    items: [
                      for (final state in _selectableStates)
                        DropdownMenuItem(
                          value: state,
                          child: Text(stateLabel(toCommonState(state))),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedState = value);
                      }
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _onSave,
          child: Text(_isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final assignment = AccessRoleAssignmentObject(
      id: widget.assignment?.id,
      memberId: _memberIdController.text.trim(),
      roleKey: _selectedRoleKey,
      scopeType: _selectedScopeType,
      scopeId: _scopeIdController.text.trim(),
      state: _selectedState,
    );

    Navigator.of(context).pop(assignment);
  }
}
