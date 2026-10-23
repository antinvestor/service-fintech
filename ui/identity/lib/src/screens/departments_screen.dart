import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/widgets/admin_entity_list_page.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/department_providers.dart';
import '../providers/organization_providers.dart';
import '../widgets/async_state_views.dart';

// ---------------------------------------------------------------------------
// Department & Position hierarchy helpers
// ---------------------------------------------------------------------------

String departmentKindLabel(DepartmentKind kind) => switch (kind) {
  DepartmentKind.DEPARTMENT_KIND_FUNCTION => 'Function',
  DepartmentKind.DEPARTMENT_KIND_DEPARTMENT => 'Department',
  _ => 'Unspecified',
};

IconData departmentKindIcon(DepartmentKind kind) => switch (kind) {
  DepartmentKind.DEPARTMENT_KIND_FUNCTION => Icons.hub_outlined,
  DepartmentKind.DEPARTMENT_KIND_DEPARTMENT => Icons.folder_outlined,
  _ => Icons.folder_open_outlined,
};

// ---------------------------------------------------------------------------
// Departments list screen
// ---------------------------------------------------------------------------

class DepartmentsScreen extends ConsumerStatefulWidget {
  const DepartmentsScreen({super.key, this.canManage = true});
  final bool canManage;

  @override
  ConsumerState<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends ConsumerState<DepartmentsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final depsAsync = ref.watch(
      departmentListProvider((
        query: _query,
        organizationId: '',
        parentId: '',
        kind: DepartmentKind.DEPARTMENT_KIND_UNSPECIFIED,
      )),
    );
    if (depsAsync.hasError) {
      return ListErrorView(
        title: 'Departments & Functions',
        breadcrumbs: const ['Identity', 'Departments'],
        error: depsAsync.error!,
        onRetry: () => ref.invalidate(
          departmentListProvider((
            query: _query,
            organizationId: '',
            parentId: '',
            kind: DepartmentKind.DEPARTMENT_KIND_UNSPECIFIED,
          )),
        ),
      );
    }
    if (depsAsync.isLoading && !depsAsync.hasValue) {
      return const ListLoadingView(
        title: 'Departments & Functions',
        breadcrumbs: ['Identity', 'Departments'],
      );
    }
    final departments = depsAsync.requireValue;

    return AdminEntityListPage<DepartmentObject>(
      title: 'Departments & Functions',
      breadcrumbs: const ['Identity', 'Departments'],
      columns: const [
        DataColumn(label: Text('NAME')),
        DataColumn(label: Text('KIND')),
        DataColumn(label: Text('CODE')),
        DataColumn(label: Text('STATE')),
      ],
      items: departments,
      onSearch: (value) => setState(() => _query = value.trim()),
      addLabel: widget.canManage ? 'Add Department' : null,
      onAdd: widget.canManage ? () => _showDepartmentDialog(context) : null,
      rowBuilder: (dep, selected, onSelect) {
        return DataRow(
          selected: selected,
          onSelectChanged: (_) => onSelect(),
          cells: [
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    departmentKindIcon(dep.kind),
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(dep.name),
                ],
              ),
            ),
            DataCell(Text(departmentKindLabel(dep.kind))),
            DataCell(Text(dep.code)),
            DataCell(_StatePill(dep.state)),
          ],
        );
      },
      onRowNavigate: (dep) => context.go('/departments/${dep.id}'),
      detailBuilder: (dep) => _DepartmentInlineDetail(department: dep),
      exportRow: (dep) => [
        dep.name,
        departmentKindLabel(dep.kind),
        dep.code,
        dep.state.name,
        dep.id,
      ],
    );
  }

  void _showDepartmentDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DepartmentFormDialog(
        onSave: (dep) async {
          await ref.read(departmentNotifierProvider.notifier).save(dep);
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Department created')));
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inline detail
// ---------------------------------------------------------------------------

class _DepartmentInlineDetail extends StatelessWidget {
  const _DepartmentInlineDetail({required this.department});
  final DepartmentObject department;

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
                departmentKindIcon(department.kind),
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    department.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    department.id,
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
        _DetailRow(label: 'Kind', value: departmentKindLabel(department.kind)),
        if (department.code.isNotEmpty)
          _DetailRow(label: 'Code', value: department.code),
        if (department.organizationId.isNotEmpty)
          _DetailRow(label: 'Organization', value: department.organizationId),
        if (department.parentId.isNotEmpty)
          _DetailRow(label: 'Parent', value: department.parentId),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Department detail screen
// ---------------------------------------------------------------------------

class DepartmentDetailScreen extends ConsumerWidget {
  const DepartmentDetailScreen({
    super.key,
    required this.departmentId,
    this.canManage = true,
  });

  final String departmentId;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentAsync = ref.watch(departmentByIdProvider(departmentId));
    return departmentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => DetailErrorView(
        error: error,
        onRetry: () => ref.invalidate(departmentByIdProvider(departmentId)),
      ),
      data: (dep) =>
          _DepartmentDetailContent(department: dep, canManage: canManage),
    );
  }
}

class _DepartmentDetailContent extends ConsumerStatefulWidget {
  const _DepartmentDetailContent({
    required this.department,
    required this.canManage,
  });
  final DepartmentObject department;
  final bool canManage;

  @override
  ConsumerState<_DepartmentDetailContent> createState() =>
      _DepartmentDetailContentState();
}

class _DepartmentDetailContentState
    extends ConsumerState<_DepartmentDetailContent> {
  late DepartmentObject _department;
  String _positionFilter = '';

  @override
  void initState() {
    super.initState();
    _department = widget.department;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Child departments (same parent)
    final childDepsAsync = ref.watch(
      departmentListProvider((
        query: '',
        organizationId: _department.organizationId,
        parentId: _department.id,
        kind: DepartmentKind.DEPARTMENT_KIND_UNSPECIFIED,
      )),
    );

    // Positions in this department
    final positionsAsync = ref.watch(
      positionListProvider((
        query: '',
        organizationId: _department.organizationId,
        orgUnitId: '',
        departmentId: _department.id,
        reportsToPositionId: '',
      )),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/departments'),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withAlpha(80),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        departmentKindIcon(_department.kind),
                        size: 24,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _department.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '${departmentKindLabel(_department.kind)}${_department.code.isNotEmpty ? ' \u2022 ${_department.code}' : ''}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(140),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatePill(_department.state),
                    if (widget.canManage) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                        onPressed: () => _editDepartment(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Info card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withAlpha(38),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoTile(
                          label: 'Kind',
                          value: departmentKindLabel(_department.kind),
                        ),
                        if (_department.code.isNotEmpty)
                          _InfoTile(label: 'Code', value: _department.code),
                        if (_department.organizationId.isNotEmpty)
                          _InfoTile(
                            label: 'Organization',
                            value: _department.organizationId,
                          ),
                        if (_department.parentId.isNotEmpty)
                          _InfoTile(
                            label: 'Parent Department',
                            value: _department.parentId,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Child departments
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sub-Departments',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (widget.canManage)
                      FilledButton.icon(
                        onPressed: () => _showChildDepartmentDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Sub-Department'),
                      ),
                  ],
                ),
              ),
            ),
            childDepsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error: $e'),
                ),
              ),
              data: (children) {
                if (children.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Text('No sub-departments'),
                    ),
                  );
                }
                return SliverList.builder(
                  itemCount: children.length,
                  itemBuilder: (context, i) {
                    final child = children[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                      child: Card(
                        child: ListTile(
                          leading: Icon(departmentKindIcon(child.kind)),
                          title: Text(child.name),
                          subtitle: Text(departmentKindLabel(child.kind)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go('/departments/${child.id}'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Positions section with filter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Positions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (widget.canManage)
                      FilledButton.icon(
                        onPressed: () => _showPositionDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Position'),
                      ),
                  ],
                ),
              ),
            ),
            // Positions filter - preserves departmentId constraint
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Filter positions...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (v) => setState(() => _positionFilter = v.trim()),
                ),
              ),
            ),
            positionsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error: $e'),
                ),
              ),
              data: (positions) {
                // Client-side filter preserving departmentId constraint
                final filtered = _positionFilter.isEmpty
                    ? positions
                    : positions.where((p) {
                        final q = _positionFilter.toLowerCase();
                        return p.name.toLowerCase().contains(q) ||
                            p.code.toLowerCase().contains(q);
                      }).toList();

                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 40,
                              color: theme.colorScheme.onSurface.withAlpha(60),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _positionFilter.isNotEmpty
                                  ? 'No positions matching "$_positionFilter"'
                                  : 'No positions defined yet',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withAlpha(38),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: DataTable(
                        showCheckboxColumn: false,
                        columns: const [
                          DataColumn(label: Text('POSITION')),
                          DataColumn(label: Text('CODE')),
                          DataColumn(label: Text('REPORTS TO')),
                          DataColumn(label: Text('STATE')),
                        ],
                        rows: filtered.map((pos) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.work_outline,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(pos.name),
                                  ],
                                ),
                              ),
                              DataCell(Text(pos.code)),
                              DataCell(
                                Text(
                                  pos.reportsToPositionId.isNotEmpty
                                      ? pos.reportsToPositionId
                                      : '\u2014',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              DataCell(_StatePill(pos.state)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editDepartment(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DepartmentFormDialog(
        department: _department,
        onSave: (dep) async {
          final saved = await ref
              .read(departmentNotifierProvider.notifier)
              .save(dep);
          if (mounted) setState(() => _department = saved);
        },
      ),
    );
  }

  void _showChildDepartmentDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DepartmentFormDialog(
        fixedOrganizationId: _department.organizationId,
        fixedParentId: _department.id,
        onSave: (dep) async {
          await ref.read(departmentNotifierProvider.notifier).save(dep);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sub-department created')),
            );
          }
        },
      ),
    );
  }

  void _showPositionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PositionFormDialog(
        departmentId: _department.id,
        organizationId: _department.organizationId,
        onSave: (pos) async {
          await ref.read(positionNotifierProvider.notifier).save(pos);
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Position created')));
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Department form dialog
// ---------------------------------------------------------------------------

class DepartmentFormDialog extends ConsumerStatefulWidget {
  const DepartmentFormDialog({
    super.key,
    this.department,
    this.fixedOrganizationId,
    this.fixedParentId,
    required this.onSave,
  });

  final DepartmentObject? department;
  final String? fixedOrganizationId;
  final String? fixedParentId;
  final Future<void> Function(DepartmentObject dep) onSave;

  @override
  ConsumerState<DepartmentFormDialog> createState() =>
      _DepartmentFormDialogState();
}

class _DepartmentFormDialogState extends ConsumerState<DepartmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late DepartmentKind _kind;
  late String _orgId;
  bool _saving = false;

  bool get _isEditing => widget.department != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.department?.name ?? '');
    _codeCtrl = TextEditingController(text: widget.department?.code ?? '');
    _kind =
        widget.department?.kind ?? DepartmentKind.DEPARTMENT_KIND_DEPARTMENT;
    _orgId =
        widget.fixedOrganizationId ?? widget.department?.organizationId ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final dep = DepartmentObject(
      id: widget.department?.id,
      name: _nameCtrl.text.trim(),
      code: _codeCtrl.text.trim(),
      kind: _kind,
      organizationId: _orgId,
      parentId: widget.fixedParentId ?? widget.department?.parentId ?? '',
      state: widget.department?.state ?? STATE.CREATED,
      properties: widget.department?.properties,
    );
    try {
      await widget.onSave(dep);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgsAsync = ref.watch(organizationListProvider(''));
    final orgs = orgsAsync.value ?? const <OrganizationObject>[];

    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(
              icon: Icons.folder_outlined,
              title: _isEditing ? 'Edit Department' : 'New Department',
              subtitle:
                  'Define a functional area or department in the organization.',
              onClose: _saving ? null : () => Navigator.pop(context),
            ),
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    children: [
                      FormFieldCard(
                        label: 'Name',
                        isRequired: true,
                        child: TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Operations',
                            prefixIcon: Icon(Icons.label_outlined),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      FormFieldCard(
                        label: 'Code',
                        isRequired: true,
                        child: TextFormField(
                          controller: _codeCtrl,
                          decoration: const InputDecoration(
                            hintText: 'e.g. OPS',
                            prefixIcon: Icon(Icons.tag),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      FormFieldCard(
                        label: 'Kind',
                        description:
                            'Function = top-level business function. Department = nested grouping.',
                        isRequired: true,
                        child: DropdownButtonFormField<DepartmentKind>(
                          initialValue: _kind,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: DepartmentKind.DEPARTMENT_KIND_FUNCTION,
                              child: Text('Function'),
                            ),
                            DropdownMenuItem(
                              value: DepartmentKind.DEPARTMENT_KIND_DEPARTMENT,
                              child: Text('Department'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _kind = v);
                          },
                        ),
                      ),
                      if (widget.fixedOrganizationId == null)
                        FormFieldCard(
                          label: 'Organization',
                          child: DropdownButtonFormField<String>(
                            initialValue: _orgId.isNotEmpty ? _orgId : null,
                            decoration: const InputDecoration(
                              hintText: 'Select organization',
                              prefixIcon: Icon(Icons.business_outlined),
                            ),
                            items: orgs
                                .map(
                                  (o) => DropdownMenuItem(
                                    value: o.id,
                                    child: Text(o.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _orgId = v ?? ''),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            _DialogActions(
              saving: _saving,
              isEditing: _isEditing,
              entityLabel: 'Department',
              onCancel: () => Navigator.pop(context),
              onSave: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Position form dialog
// ---------------------------------------------------------------------------

class PositionFormDialog extends StatefulWidget {
  const PositionFormDialog({
    super.key,
    required this.departmentId,
    required this.organizationId,
    this.position,
    required this.onSave,
  });

  final String departmentId;
  final String organizationId;
  final PositionObject? position;
  final Future<void> Function(PositionObject pos) onSave;

  @override
  State<PositionFormDialog> createState() => _PositionFormDialogState();
}

class _PositionFormDialogState extends State<PositionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _reportsToCtrl;
  late final TextEditingController _orgUnitCtrl;
  bool _saving = false;

  bool get _isEditing => widget.position != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.position?.name ?? '');
    _codeCtrl = TextEditingController(text: widget.position?.code ?? '');
    _reportsToCtrl = TextEditingController(
      text: widget.position?.reportsToPositionId ?? '',
    );
    _orgUnitCtrl = TextEditingController(
      text: widget.position?.orgUnitId ?? '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _reportsToCtrl.dispose();
    _orgUnitCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final pos = PositionObject(
      id: widget.position?.id,
      name: _nameCtrl.text.trim(),
      code: _codeCtrl.text.trim(),
      departmentId: widget.departmentId,
      organizationId: widget.organizationId,
      orgUnitId: _orgUnitCtrl.text.trim(),
      reportsToPositionId: _reportsToCtrl.text.trim(),
      state: widget.position?.state ?? STATE.CREATED,
      properties: widget.position?.properties,
    );
    try {
      await widget.onSave(pos);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(
              icon: Icons.work_outline,
              title: _isEditing ? 'Edit Position' : 'New Position',
              subtitle:
                  'Define a reporting seat in the organizational structure.',
              onClose: _saving ? null : () => Navigator.pop(context),
            ),
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    children: [
                      FormFieldCard(
                        label: 'Position Title',
                        isRequired: true,
                        child: TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Branch Manager',
                            prefixIcon: Icon(Icons.work_outline),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      FormFieldCard(
                        label: 'Code',
                        isRequired: true,
                        child: TextFormField(
                          controller: _codeCtrl,
                          decoration: const InputDecoration(
                            hintText: 'e.g. BM',
                            prefixIcon: Icon(Icons.tag),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      FormFieldCard(
                        label: 'Reports To (Position ID)',
                        description:
                            'The position this role reports to in the hierarchy. Leave empty for top-level.',
                        child: TextFormField(
                          controller: _reportsToCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Position ID of supervisor',
                            prefixIcon: Icon(Icons.arrow_upward),
                          ),
                        ),
                      ),
                      FormFieldCard(
                        label: 'Org Unit ID',
                        description:
                            'The org unit where this position is located.',
                        child: TextFormField(
                          controller: _orgUnitCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Org unit ID',
                            prefixIcon: Icon(Icons.account_tree_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _DialogActions(
              saving: _saving,
              isEditing: _isEditing,
              entityLabel: 'Position',
              onCancel: () => Navigator.pop(context),
              onSave: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared dialog widgets
// ---------------------------------------------------------------------------

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onClose,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(60),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onClose != null)
            IconButton(icon: const Icon(Icons.close), onPressed: onClose),
        ],
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  const _DialogActions({
    required this.saving,
    required this.isEditing,
    required this.entityLabel,
    required this.onCancel,
    required this.onSave,
  });

  final bool saving;
  final bool isEditing;
  final String entityLabel;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(60),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: saving ? null : onCancel,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(isEditing ? Icons.save : Icons.add, size: 18),
            label: Text(isEditing ? 'Update' : 'Create $entityLabel'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
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
        theme.colorScheme.tertiary,
      ),
      'CREATED' => (
        theme.colorScheme.secondary.withAlpha(20),
        theme.colorScheme.secondary,
      ),
      'INACTIVE' || 'DELETED' => (
        theme.colorScheme.error.withAlpha(20),
        theme.colorScheme.error,
      ),
      _ => (theme.colorScheme.outline.withAlpha(20), theme.colorScheme.outline),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
