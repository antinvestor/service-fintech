import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/widgets/admin_entity_list_page.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/organization_providers.dart';
import '../providers/team_providers.dart';
import '../widgets/org_unit_helpers.dart'
    show teamTypeLabel, teamTypeIcon, membershipRoleLabel;
import '../widgets/async_state_views.dart';
import '../widgets/load_more_action.dart';

// ---------------------------------------------------------------------------
// Team type helpers
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Teams list screen
// ---------------------------------------------------------------------------

class TeamsScreen extends ConsumerStatefulWidget {
  const TeamsScreen({super.key, this.canManage = true});
  final bool canManage;

  @override
  ConsumerState<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends ConsumerState<TeamsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final provider = internalTeamPagedListProvider((
      query: _query,
      organizationId: '',
    ));
    final teamsAsync = ref.watch(provider);
    if (teamsAsync.hasError) {
      return ListErrorView(
        title: 'Teams',
        breadcrumbs: const ['Identity', 'Teams'],
        error: teamsAsync.error!,
        onRetry: () => ref.invalidate(provider),
      );
    }
    if (teamsAsync.isLoading && !teamsAsync.hasValue) {
      return const ListLoadingView(
        title: 'Teams',
        breadcrumbs: ['Identity', 'Teams'],
      );
    }
    final page = teamsAsync.requireValue;
    final teams = page.items;

    return AdminEntityListPage<InternalTeamObject>(
      title: 'Teams',
      breadcrumbs: const ['Identity', 'Teams'],
      columns: const [
        DataColumn(label: Text('NAME')),
        DataColumn(label: Text('TYPE')),
        DataColumn(label: Text('CODE')),
        DataColumn(label: Text('OBJECTIVE')),
        DataColumn(label: Text('STATE')),
      ],
      items: teams,
      onSearch: (value) => setState(() => _query = value.trim()),
      actions: [
        LoadMoreAction(
          loadedCount: teams.length,
          hasMore: page.hasMore,
          isLoading: page.isLoadingMore,
          errorMessage: page.loadMoreError == null
              ? null
              : friendlyError(page.loadMoreError!),
          onLoadMore: () => ref.read(provider.notifier).loadMore(),
        ),
      ],
      addLabel: widget.canManage ? 'Create Team' : null,
      onAdd: widget.canManage ? () => _showTeamDialog(context) : null,
      rowBuilder: (team, selected, onSelect) {
        return DataRow(
          selected: selected,
          onSelectChanged: (_) => onSelect(),
          cells: [
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    teamTypeIcon(team.teamType),
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(team.name),
                ],
              ),
            ),
            DataCell(Text(teamTypeLabel(team.teamType))),
            DataCell(Text(team.code)),
            DataCell(
              Text(
                team.objective.length > 50
                    ? '${team.objective.substring(0, 50)}...'
                    : team.objective,
              ),
            ),
            DataCell(_StatePill(team.state)),
          ],
        );
      },
      onRowNavigate: (team) => context.go('/teams/${team.id}'),
      detailBuilder: (team) => _TeamInlineDetail(team: team),
      exportRow: (team) => [
        team.name,
        teamTypeLabel(team.teamType),
        team.code,
        team.objective,
        team.state.name,
        team.id,
      ],
    );
  }

  void _showTeamDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TeamFormDialog(
        onSave: (team) async {
          await ref.read(internalTeamNotifierProvider.notifier).save(team);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Team created successfully')),
            );
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inline detail panel (used by AdminEntityListPage)
// ---------------------------------------------------------------------------

class _TeamInlineDetail extends StatelessWidget {
  const _TeamInlineDetail({required this.team});
  final InternalTeamObject team;

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
                teamTypeIcon(team.teamType),
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    team.id,
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
        _DetailRow(label: 'Type', value: teamTypeLabel(team.teamType)),
        if (team.code.isNotEmpty) _DetailRow(label: 'Code', value: team.code),
        if (team.objective.isNotEmpty)
          _DetailRow(label: 'Objective', value: team.objective),
        if (team.organizationId.isNotEmpty)
          _DetailRow(label: 'Organization', value: team.organizationId),
        if (team.homeOrgUnitId.isNotEmpty)
          _DetailRow(label: 'Home Unit', value: team.homeOrgUnitId),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  'State',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              _StatePill(team.state),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Team detail screen (full page)
// ---------------------------------------------------------------------------

/// Builds a section another product adds to a team's page, such as its
/// commission. It is given the team and the ids of its active members.
typedef TeamSectionBuilder =
    Widget Function(
      BuildContext context,
      InternalTeamObject team,
      List<String> activeMemberIds,
    );

class TeamDetailScreen extends ConsumerWidget {
  const TeamDetailScreen({
    super.key,
    required this.teamId,
    this.canManage = true,
    this.sections = const [],
  });

  final String teamId;
  final bool canManage;

  /// Sections other products add below the team's details.
  final List<TeamSectionBuilder> sections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(internalTeamByIdProvider(teamId));
    return teamAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => DetailErrorView(
        error: error,
        onRetry: () => ref.invalidate(internalTeamByIdProvider(teamId)),
      ),
      data: (team) => _TeamDetailContent(
        team: team,
        canManage: canManage,
        sections: sections,
      ),
    );
  }
}

class _TeamDetailContent extends ConsumerStatefulWidget {
  const _TeamDetailContent({
    required this.team,
    required this.canManage,
    this.sections = const [],
  });
  final InternalTeamObject team;
  final bool canManage;
  final List<TeamSectionBuilder> sections;

  @override
  ConsumerState<_TeamDetailContent> createState() => _TeamDetailContentState();
}

class _TeamDetailContentState extends ConsumerState<_TeamDetailContent> {
  late InternalTeamObject _team;
  String _memberSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _team = widget.team;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final membershipsAsync = ref.watch(
      teamMembershipListProvider((teamId: _team.id, memberId: '')),
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
                      onPressed: () => context.go('/teams'),
                      tooltip: 'Back to Teams',
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
                        teamTypeIcon(_team.teamType),
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
                            _team.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '${teamTypeLabel(_team.teamType)}${_team.code.isNotEmpty ? ' \u2022 ${_team.code}' : ''}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(140),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatePill(_team.state),
                    if (widget.canManage) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit Team',
                        onPressed: () => _editTeam(context),
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
                child: _buildInfoCard(theme),
              ),
            ),

            // Sections other products add, e.g. commission
            for (final section in widget.sections)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: section(
                    context,
                    _team,
                    membershipsAsync.maybeWhen(
                      data: (memberships) => [
                        for (final m in memberships)
                          if (m.state == STATE.ACTIVE) m.memberId,
                      ],
                      orElse: () => const <String>[],
                    ),
                  ),
                ),
              ),

            // Team members section with search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Team Members',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (widget.canManage)
                      FilledButton.icon(
                        onPressed: () => _showAddMemberDialog(context),
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text('Add Member'),
                      ),
                  ],
                ),
              ),
            ),

            // Member search (filters within loaded members)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Filter members...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (v) =>
                      setState(() => _memberSearchQuery = v.trim()),
                ),
              ),
            ),

            // Members list
            membershipsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Failed to load members: $e'),
                ),
              ),
              data: (memberships) {
                // Client-side filter that preserves the teamId constraint
                final filtered = _memberSearchQuery.isEmpty
                    ? memberships
                    : memberships.where((m) {
                        final q = _memberSearchQuery.toLowerCase();
                        return m.memberId.toLowerCase().contains(q) ||
                            m.membershipRole.toLowerCase().contains(q);
                      }).toList();

                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 40,
                              color: theme.colorScheme.onSurface.withAlpha(60),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _memberSearchQuery.isNotEmpty
                                  ? 'No members matching "$_memberSearchQuery"'
                                  : 'No team members yet',
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
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
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
                          DataColumn(label: Text('MEMBER')),
                          DataColumn(label: Text('ROLE')),
                          DataColumn(label: Text('PRIMARY')),
                          DataColumn(label: Text('STATE')),
                        ],
                        rows: filtered.map((m) {
                          return DataRow(
                            onSelectChanged: (_) =>
                                context.go('/workforce/${m.memberId}'),
                            cells: [
                              DataCell(Text(m.memberId)),
                              DataCell(_RolePill(m.membershipRole)),
                              DataCell(
                                m.isPrimaryTeam
                                    ? Icon(
                                        Icons.star,
                                        size: 18,
                                        color: theme.colorScheme.tertiary,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              DataCell(_StatePill(m.state)),
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

  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(38)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final items = <Widget>[
              _InfoTile(label: 'Type', value: teamTypeLabel(_team.teamType)),
              if (_team.code.isNotEmpty)
                _InfoTile(label: 'Code', value: _team.code),
              if (_team.objective.isNotEmpty)
                _InfoTile(label: 'Objective', value: _team.objective),
              if (_team.organizationId.isNotEmpty)
                _InfoTile(label: 'Organization', value: _team.organizationId),
              if (_team.homeOrgUnitId.isNotEmpty)
                _InfoTile(label: 'Home Org Unit', value: _team.homeOrgUnitId),
              if (_team.geoId.isNotEmpty)
                _InfoTile(label: 'Coverage Area', value: _team.geoId),
            ];
            if (constraints.maxWidth >= 480 && items.length > 2) {
              final mid = (items.length / 2).ceil();
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items.sublist(0, mid),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items.sublist(mid),
                    ),
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items,
            );
          },
        ),
      ),
    );
  }

  Future<void> _editTeam(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TeamFormDialog(
        team: _team,
        onSave: (team) async {
          final saved = await ref
              .read(internalTeamNotifierProvider.notifier)
              .save(team);
          if (mounted) setState(() => _team = saved);
        },
      ),
    );
  }

  Future<void> _showAddMemberDialog(BuildContext context) async {
    final result = await showDialog<TeamMembershipObject>(
      context: context,
      builder: (context) => _AddTeamMemberDialog(teamId: _team.id),
    );
    if (result == null || !context.mounted) return;

    try {
      await ref.read(teamMembershipNotifierProvider.notifier).save(result);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Member added to team')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Team form dialog
// ---------------------------------------------------------------------------

class TeamFormDialog extends ConsumerStatefulWidget {
  const TeamFormDialog({super.key, this.team, required this.onSave});
  final InternalTeamObject? team;
  final Future<void> Function(InternalTeamObject team) onSave;

  @override
  ConsumerState<TeamFormDialog> createState() => _TeamFormDialogState();
}

class _TeamFormDialogState extends ConsumerState<TeamFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _objectiveCtrl;
  late final TextEditingController _teamTypeCtrl;
  late String _selectedOrgId;
  late String _selectedOrgUnitId;
  bool _saving = false;

  bool get _isEditing => widget.team != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.team?.name ?? '');
    _codeCtrl = TextEditingController(text: widget.team?.code ?? '');
    _objectiveCtrl = TextEditingController(text: widget.team?.objective ?? '');
    _teamTypeCtrl = TextEditingController(
      text: widget.team?.teamType ?? 'portfolio',
    );
    _selectedOrgId = widget.team?.organizationId ?? '';
    _selectedOrgUnitId = widget.team?.homeOrgUnitId ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _objectiveCtrl.dispose();
    _teamTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final team = InternalTeamObject(
      id: widget.team?.id,
      name: _nameCtrl.text.trim(),
      code: _codeCtrl.text.trim(),
      objective: _objectiveCtrl.text.trim(),
      teamType: _teamTypeCtrl.text.trim(),
      organizationId: _selectedOrgId,
      homeOrgUnitId: _selectedOrgUnitId,
      state: widget.team?.state ?? STATE.CREATED,
      properties: widget.team?.properties,
    );
    try {
      await widget.onSave(team);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orgsAsync = ref.watch(organizationListProvider(''));
    final orgs = orgsAsync.value ?? const <OrganizationObject>[];

    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
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
                    child: Icon(
                      Icons.groups_outlined,
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
                          _isEditing ? 'Edit Team' : 'New Team',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Define an execution team with a clear objective.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _saving ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    children: [
                      FormFieldCard(
                        label: 'Team Name',
                        isRequired: true,
                        child: TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Western Kenya Portfolio',
                            prefixIcon: Icon(Icons.groups_outlined),
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
                            hintText: 'e.g. WK-PORT',
                            prefixIcon: Icon(Icons.tag),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      FormFieldCard(
                        label: 'Team Type',
                        description:
                            'The operational purpose this team serves.',
                        isRequired: true,
                        child: TextFormField(
                          controller: _teamTypeCtrl,
                          decoration: const InputDecoration(
                            hintText: 'e.g. portfolio, collections, sales',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      FormFieldCard(
                        label: 'Objective',
                        description:
                            'The business objective this team works towards.',
                        child: TextFormField(
                          controller: _objectiveCtrl,
                          decoration: const InputDecoration(
                            hintText:
                                'e.g. Manage portfolio for Western region',
                            prefixIcon: Icon(Icons.flag_outlined),
                          ),
                          maxLines: 2,
                        ),
                      ),
                      FormFieldCard(
                        label: 'Organization',
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedOrgId.isNotEmpty
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
                                  child: Text(o.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedOrgId = v ?? ''),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
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
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _saving ? null : _submit,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(_isEditing ? Icons.save : Icons.add, size: 18),
                    label: Text(_isEditing ? 'Update' : 'Create Team'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add team member dialog
// ---------------------------------------------------------------------------

class _AddTeamMemberDialog extends StatefulWidget {
  const _AddTeamMemberDialog({required this.teamId});
  final String teamId;

  @override
  State<_AddTeamMemberDialog> createState() => _AddTeamMemberDialogState();
}

class _AddTeamMemberDialogState extends State<_AddTeamMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _memberIdCtrl = TextEditingController();
  final _roleCtrl = TextEditingController(text: 'member');
  bool _isPrimary = false;

  @override
  void dispose() {
    _memberIdCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.person_add, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Add Team Member'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _memberIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Workforce Member ID',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  hintText: 'e.g. lead, member, supervisor',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Primary team'),
                subtitle: const Text('Mark this as the member\'s primary team'),
                value: _isPrimary,
                onChanged: (v) => setState(() => _isPrimary = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              TeamMembershipObject(
                teamId: widget.teamId,
                memberId: _memberIdCtrl.text.trim(),
                membershipRole: _roleCtrl.text.trim(),
                isPrimaryTeam: _isPrimary,
                state: STATE.ACTIVE,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
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

class _RolePill extends StatelessWidget {
  const _RolePill(this.role);
  final String role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (role) {
      'lead' => theme.colorScheme.primary,
      'deputy' => theme.colorScheme.tertiary,
      _ => theme.colorScheme.onSurfaceVariant,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        membershipRoleLabel(role),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
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
