import 'package:antinvestor_api_identity/antinvestor_api_identity.dart'
    as common;
import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/widgets/profile_badge.dart';
import 'package:antinvestor_ui_core/widgets/state_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/identity_transport_provider.dart';
import '../providers/team_providers.dart';
import '../providers/workforce_member_providers.dart';
import '../widgets/org_unit_helpers.dart';
import '../widgets/state_helpers.dart';

class WorkforceMemberDetailScreen extends ConsumerWidget {
  const WorkforceMemberDetailScreen({
    super.key,
    required this.memberId,
    this.canManage = true,
    this.backRoute = '/workforce',
  });

  final String memberId;
  final bool canManage;
  final String backRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<WorkforceMemberObject>(
      future: _loadMember(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final member = snapshot.data;
        if (member == null) {
          return const Center(child: Text('Member not found'));
        }
        return _MemberDetailContent(
          member: member,
          canManage: canManage,
          backRoute: backRoute,
        );
      },
    );
  }

  Future<WorkforceMemberObject> _loadMember(WidgetRef ref) async {
    final client = ref.read(identityServiceClientProvider);
    final response = await client.workforceMemberGet(
      WorkforceMemberGetRequest(id: memberId),
    );
    return response.data;
  }
}

class _MemberDetailContent extends ConsumerStatefulWidget {
  const _MemberDetailContent({
    required this.member,
    required this.canManage,
    required this.backRoute,
  });

  final WorkforceMemberObject member;
  final bool canManage;
  final String backRoute;

  @override
  ConsumerState<_MemberDetailContent> createState() =>
      _MemberDetailContentState();
}

class _MemberDetailContentState extends ConsumerState<_MemberDetailContent> {
  late WorkforceMemberObject _member;

  @override
  void initState() {
    super.initState();
    _member = widget.member;
  }

  String get _memberName {
    if (_member.hasProperties() &&
        _member.properties.fields.containsKey('name')) {
      return _member.properties.fields['name']!.stringValue;
    }
    return _member.profileId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final membershipsAsync = ref.watch(
      teamMembershipListProvider((teamId: '', memberId: _member.id)),
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go(widget.backRoute),
                  tooltip: 'Back to Workforce Members',
                ),
                const SizedBox(width: 8),
                ProfileBadge(
                  profileId: _member.profileId,
                  name: _memberName,
                  description: engagementLabel(_member.engagementType),
                  avatarSize: 48,
                  trailing: const SizedBox.shrink(),
                ),
                const Spacer(),
                StateBadge(state: toCommonState(_member.state)),
                if (widget.canManage) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit Member',
                    onPressed: () => _editMember(context),
                  ),
                ],
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Member Details',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Member ID', value: _member.id),
                    _InfoRow(label: 'Profile ID', value: _member.profileId),
                    _InfoRow(
                      label: 'Organization',
                      value: _member.organizationId,
                    ),
                    _InfoRow(
                      label: 'Engagement',
                      value: engagementLabel(_member.engagementType),
                    ),
                    if (_member.homeOrgUnitId.isNotEmpty)
                      _InfoRow(
                        label: 'Home Org Unit',
                        value: _member.homeOrgUnitId,
                      ),
                    if (_member.geoId.isNotEmpty)
                      _InfoRow(label: 'Geo ID', value: _member.geoId),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                Icon(
                  Icons.groups_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Team Memberships',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        membershipsAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (error, _) => SliverToBoxAdapter(
            child: Center(child: Text('Failed to load: $error')),
          ),
          data: (memberships) {
            if (memberships.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.groups_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurface.withAlpha(80),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No team memberships',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(140),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final m = memberships[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.group_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text('Team: ${m.teamId}'),
                      subtitle: Text(
                        '${membershipRoleLabel(m.membershipRole)}'
                        '${m.isPrimaryTeam ? ' (Primary)' : ''}',
                      ),
                      trailing: StateBadge(state: toCommonState(m.state)),
                    ),
                  );
                }, childCount: memberships.length),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _editMember(BuildContext context) async {
    final result = await showDialog<WorkforceMemberObject>(
      context: context,
      builder: (context) => _MemberEditDialog(member: _member),
    );
    if (result == null || !mounted) return;

    try {
      await ref.read(workforceMemberNotifierProvider.notifier).save(result);
      if (!mounted) return;
      setState(() => _member = result);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member updated successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '\u2014',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberEditDialog extends StatefulWidget {
  const _MemberEditDialog({required this.member});
  final WorkforceMemberObject member;

  @override
  State<_MemberEditDialog> createState() => _MemberEditDialogState();
}

class _MemberEditDialogState extends State<_MemberEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _geoIdController;
  late common.STATE _selectedState;
  late final TextEditingController _engagementTypeCtrl;

  @override
  void initState() {
    super.initState();
    _geoIdController = TextEditingController(text: widget.member.geoId);
    _selectedState = widget.member.state;
    _engagementTypeCtrl = TextEditingController(
      text: widget.member.engagementType,
    );
  }

  @override
  void dispose() {
    _geoIdController.dispose();
    _engagementTypeCtrl.dispose();
    super.dispose();
  }

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
                  'Edit Member',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Update the member details below.',
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
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              const SizedBox(height: 8),
              TextFormField(
                controller: _engagementTypeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Engagement Type',
                  hintText: 'e.g. employee, contractor, agent',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Engagement type is required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _geoIdController,
                decoration: const InputDecoration(
                  labelText: 'Geographic ID',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<common.STATE>(
                initialValue: _selectedState,
                decoration: const InputDecoration(
                  labelText: 'State',
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
                  if (v != null) {
                    setState(() => _selectedState = v);
                  }
                },
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
        FilledButton(onPressed: _onSave, child: const Text('Update')),
      ],
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final updated = WorkforceMemberObject(
      id: widget.member.id,
      organizationId: widget.member.organizationId,
      profileId: widget.member.profileId,
      homeOrgUnitId: widget.member.homeOrgUnitId,
      engagementType: _engagementTypeCtrl.text.trim(),
      geoId: _geoIdController.text.trim(),
      state: _selectedState,
      // Properties carry the display name and the platform role; rebuilding
      // the object without them would wipe both on every edit.
      properties: widget.member.properties,
    );

    Navigator.pop(context, updated);
  }
}
