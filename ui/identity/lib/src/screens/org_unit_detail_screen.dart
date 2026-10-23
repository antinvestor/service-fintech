import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_audit/antinvestor_ui_audit.dart';
import 'package:antinvestor_ui_core/auth/tenancy_context.dart';
import 'package:antinvestor_ui_core/widgets/profile_badge.dart';
import 'package:antinvestor_ui_core/widgets/state_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart'
    show ProfileInlineManager;
import '../providers/identity_transport_provider.dart';
import '../providers/org_unit_providers.dart';
import '../providers/organization_providers.dart';
import '../providers/workforce_member_providers.dart';
import '../widgets/org_unit_helpers.dart';
import '../widgets/state_helpers.dart';
import 'org_unit_form_dialog.dart';
import '../widgets/async_state_views.dart';

class OrgUnitDetailScreen extends ConsumerWidget {
  const OrgUnitDetailScreen({
    super.key,
    required this.orgUnitId,
    this.organizationId = '',
    this.canManage = true,
  });

  final String orgUnitId;
  final String organizationId;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgUnitAsync = ref.watch(orgUnitByIdProvider(orgUnitId));
    return orgUnitAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => DetailErrorView(
        error: error,
        onRetry: () => ref.invalidate(orgUnitByIdProvider(orgUnitId)),
      ),
      data: (orgUnit) {
        return _OrgUnitDetailContent(
          orgUnit: orgUnit,
          organizationId: organizationId,
          canManage: canManage,
        );
      },
    );
  }
}

class _OrgUnitDetailContent extends ConsumerStatefulWidget {
  const _OrgUnitDetailContent({
    required this.orgUnit,
    required this.organizationId,
    required this.canManage,
  });

  final OrgUnitObject orgUnit;
  final String organizationId;
  final bool canManage;

  @override
  ConsumerState<_OrgUnitDetailContent> createState() =>
      _OrgUnitDetailContentState();
}

class _OrgUnitDetailContentState extends ConsumerState<_OrgUnitDetailContent> {
  late OrgUnitObject _orgUnit;

  @override
  void initState() {
    super.initState();
    _orgUnit = widget.orgUnit;
  }

  String _prop(String key) {
    if (!_orgUnit.hasProperties()) return '';
    final field = _orgUnit.properties.fields[key];
    if (field == null || !field.hasStringValue()) return '';
    return field.stringValue;
  }

  // Contacts are now managed via ProfileInlineManager using the profile service.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final childrenAsync = ref.watch(
      orgUnitListProvider((
        parentId: _orgUnit.id,
        organizationId: _orgUnit.organizationId,
        query: '',
        rootOnly: false,
        type: OrgUnitType.ORG_UNIT_TYPE_UNSPECIFIED,
      )),
    );
    final organizationsAsync = ref.watch(organizationListProvider(''));
    final membersAsync = ref.watch(
      workforceMemberListProvider((
        query: '',
        homeOrgUnitId: _orgUnit.id,
        organizationId: '',
      )),
    );
    final tenancy = ref.watch(tenancyContextProvider);
    final isActiveBranch = tenancy.branchId == _orgUnit.id;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: CustomScrollView(
          slivers: [
            // -- Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go(
                        widget.organizationId.isNotEmpty
                            ? '/organizations/${widget.organizationId}'
                            : '/org-units',
                      ),
                      tooltip: 'Back',
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
                        _orgUnit.type == OrgUnitType.ORG_UNIT_TYPE_BRANCH
                            ? Icons.store_outlined
                            : Icons.account_tree_outlined,
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
                            _orgUnit.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '${orgUnitTypeLabel(_orgUnit.type)}${_orgUnit.code.isNotEmpty ? ' \u2022 ${_orgUnit.code}' : ''}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(140),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StateBadge(state: toCommonState(_orgUnit.state)),
                    if (_orgUnit.state == STATE.ACTIVE) ...[
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _setAsActiveContext(context),
                        icon: Icon(
                          isActiveBranch
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          size: 18,
                        ),
                        label: Text(isActiveBranch ? 'Active' : 'Set Active'),
                        style: isActiveBranch
                            ? OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.tertiary,
                                side: BorderSide(
                                  color: theme.colorScheme.tertiary,
                                ),
                              )
                            : null,
                      ),
                    ],
                    if (widget.canManage) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit Org Unit',
                        onPressed: () => _editOrgUnit(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // -- Info card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: _buildInfoCard(theme),
              ),
            ),

            // -- Profile contacts & addresses (inline management)
            if (_orgUnit.profileId.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: ProfileInlineManager(profileId: _orgUnit.profileId),
                ),
              ),

            // -- Login URL
            if (_orgUnit.clientId.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withAlpha(38),
                      ),
                    ),
                    color: theme.colorScheme.primaryContainer.withAlpha(40),
                    child: ListTile(
                      leading: Icon(
                        Icons.link,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Client ID'),
                      subtitle: SelectableText(
                        _orgUnit.clientId,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: _orgUnit.clientId),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Client ID copied')),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

            // -- Child Org Units
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_tree_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Child Org Units',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (widget.canManage)
                      FilledButton.icon(
                        onPressed: () => _showChildDialog(
                          context,
                          organizationsAsync.value ?? const [],
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Child'),
                      ),
                  ],
                ),
              ),
            ),
            childrenAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Failed to load child org units: $error'),
                ),
              ),
              data: (children) {
                if (children.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Text('No child org units yet'),
                    ),
                  );
                }
                return SliverList.builder(
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                      child: Card(
                        child: ListTile(
                          leading: Icon(
                            child.type == OrgUnitType.ORG_UNIT_TYPE_BRANCH
                                ? Icons.store_outlined
                                : Icons.account_tree_outlined,
                          ),
                          title: Text(child.name),
                          subtitle: Text(orgUnitTypeLabel(child.type)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go(
                            '/organizations/${_orgUnit.organizationId}/org-units/${child.id}',
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // -- Workforce Members
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Workforce Members',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            membersAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Failed to load members: $error'),
                ),
              ),
              data: (members) {
                if (members.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 40,
                              color: theme.colorScheme.onSurface.withAlpha(60),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No members assigned to this unit',
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
                      child: Column(
                        children: members.map((member) {
                          final name =
                              member.hasProperties() &&
                                  member.properties.fields.containsKey('name')
                              ? member.properties.fields['name']!.stringValue
                              : member.profileId;
                          return ListTile(
                            leading: ProfileAvatar(
                              profileId: member.profileId,
                              name: name,
                              size: 36,
                            ),
                            title: Text(name),
                            subtitle: Text(
                              engagementLabel(member.engagementType),
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: StateBadge(
                              state: toCommonState(member.state),
                            ),
                            onTap: () => context.go('/workforce/${member.id}'),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),

            // -- Audit Trail
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: ObjectAuditTrail(
                  resourceType: 'org_unit',
                  resourceId: _orgUnit.id,
                  maxEntries: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- Info card
  Widget _buildInfoCard(ThemeData theme) {
    final description = _prop('description');
    final phone = _prop('phone');
    final email = _prop('email');
    final addressParts = [
      _prop('address_street'),
      _prop('address_city'),
      _prop('address_country'),
      _prop('address_postal_code'),
    ].where((s) => s.isNotEmpty);

    final leftItems = <Widget>[
      _InfoTile(label: 'Type', value: orgUnitTypeLabel(_orgUnit.type)),
      if (_orgUnit.code.isNotEmpty)
        _InfoTile(label: 'Code', value: _orgUnit.code),
      if (_orgUnit.geoId.isNotEmpty)
        _InfoTile(label: 'Coverage Area', value: _orgUnit.geoId),
      if (description.isNotEmpty)
        _InfoTile(label: 'Description', value: description),
    ];

    final rightItems = <Widget>[
      if (addressParts.isNotEmpty)
        _InfoTile(label: 'Address', value: addressParts.join(', ')),
      if (phone.isNotEmpty) _InfoTile(label: 'Phone', value: phone),
      if (email.isNotEmpty) _InfoTile(label: 'Email', value: email),
      if (_orgUnit.partitionId.isNotEmpty)
        _InfoTile(label: 'Partition', value: _orgUnit.partitionId),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(38)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 480 && rightItems.isNotEmpty) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: leftItems,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: rightItems,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [...leftItems, ...rightItems],
                );
              },
            ),
            // Contacts managed via ProfileInlineManager above.
          ],
        ),
      ),
    );
  }

  // -- Actions
  void _setAsActiveContext(BuildContext context) {
    final tenancy = ref.read(tenancyContextProvider);
    if (_orgUnit.type == OrgUnitType.ORG_UNIT_TYPE_BRANCH) {
      tenancy.selectBranch(
        _orgUnit.id,
        _orgUnit.name,
        partitionId: _orgUnit.partitionId.isNotEmpty
            ? _orgUnit.partitionId
            : null,
      );
    }
    tenancy.selectOrganization(
      _orgUnit.organizationId,
      '',
      partitionId: _orgUnit.partitionId.isNotEmpty
          ? _orgUnit.partitionId
          : null,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_orgUnit.name} set as active context'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _editOrgUnit(BuildContext context) async {
    final organizations =
        ref.read(organizationListProvider('')).value ??
        const <OrganizationObject>[];
    final result = await showDialog<OrgUnitObject>(
      context: context,
      builder: (context) =>
          OrgUnitFormDialog(orgUnit: _orgUnit, organizations: organizations),
    );
    if (result == null || !context.mounted) return;
    await _saveOrgUnit(
      context,
      result,
      successMessage: 'Org unit updated successfully',
    );
  }

  Future<void> _showChildDialog(
    BuildContext context,
    List<OrganizationObject> organizations,
  ) async {
    final result = await showDialog<OrgUnitObject>(
      context: context,
      builder: (context) => OrgUnitFormDialog(
        organizations: organizations,
        fixedOrganizationId: _orgUnit.organizationId,
        fixedParentId: _orgUnit.id,
      ),
    );
    if (result == null || !context.mounted) return;
    await _saveOrgUnit(
      context,
      result,
      successMessage: 'Child org unit created successfully',
    );
  }

  Future<void> _saveOrgUnit(
    BuildContext context,
    OrgUnitObject orgUnit, {
    required String successMessage,
  }) async {
    try {
      await ref.read(orgUnitNotifierProvider.notifier).save(orgUnit);
      ref.invalidate(
        orgUnitListProvider((
          parentId: _orgUnit.id,
          organizationId: _orgUnit.organizationId,
          query: '',
          rootOnly: false,
          type: OrgUnitType.ORG_UNIT_TYPE_UNSPECIFIED,
        )),
      );
      final client = ref.read(identityServiceClientProvider);
      final response = await client.orgUnitGet(
        OrgUnitGetRequest(id: _orgUnit.id),
      );
      if (mounted) {
        setState(() => _orgUnit = response.data);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
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
