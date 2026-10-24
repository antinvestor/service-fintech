import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_audit/antinvestor_ui_audit.dart';
import 'package:antinvestor_ui_core/auth/tenancy_context.dart';
import 'package:antinvestor_ui_core/widgets/state_badge.dart';
import 'package:antinvestor_ui_geolocation/antinvestor_ui_geolocation.dart'
    show AreaBadge;
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/identity_transport_provider.dart';
import '../providers/org_unit_providers.dart';
import '../providers/organization_providers.dart';
import '../widgets/org_unit_helpers.dart';
import '../widgets/state_helpers.dart';
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart'
    show ProfileInlineManager;
import 'org_unit_form_dialog.dart';
import 'organization_form_wizard.dart';
import 'organizations_screen.dart';
import '../widgets/async_state_views.dart';

class OrganizationDetailScreen extends ConsumerWidget {
  const OrganizationDetailScreen({
    super.key,
    required this.organizationId,
    this.canManage = true,
    this.backRoute = '/organizations',
    this.onPickLogo,
    this.filesBaseUrl,
  });

  final String organizationId;
  final bool canManage;
  final String backRoute;
  final Future<String> Function(Uint8List bytes, String filename)? onPickLogo;
  final String? filesBaseUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationAsync = ref.watch(
      organizationByIdProvider(organizationId),
    );
    return organizationAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => DetailErrorView(
        error: error,
        onRetry: () => ref.invalidate(organizationByIdProvider(organizationId)),
      ),
      data: (organization) {
        return _OrganizationDetailContent(
          organization: organization,
          canManage: canManage,
          backRoute: backRoute,
          onPickLogo: onPickLogo,
          filesBaseUrl: filesBaseUrl,
        );
      },
    );
  }
}

class _OrganizationDetailContent extends ConsumerStatefulWidget {
  const _OrganizationDetailContent({
    required this.organization,
    required this.canManage,
    required this.backRoute,
    this.onPickLogo,
    this.filesBaseUrl,
  });

  final OrganizationObject organization;
  final bool canManage;
  final String backRoute;
  final Future<String> Function(Uint8List bytes, String filename)? onPickLogo;
  final String? filesBaseUrl;

  @override
  ConsumerState<_OrganizationDetailContent> createState() =>
      _OrganizationDetailContentState();
}

class _OrganizationDetailContentState
    extends ConsumerState<_OrganizationDetailContent> {
  late OrganizationObject _organization;

  @override
  void initState() {
    super.initState();
    _organization = widget.organization;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orgUnitsAsync = ref.watch(
      orgUnitListProvider((
        organizationId: _organization.id,
        rootOnly: true,
        query: '',
        parentId: '',
        type: OrgUnitType.ORG_UNIT_TYPE_UNSPECIFIED,
      )),
    );
    final childOrgsAsync = ref.watch(
      filteredOrganizationListProvider((query: '', parentId: _organization.id)),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: CustomScrollView(
          slivers: [
            // -- Header -----------------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go(widget.backRoute),
                      tooltip: 'Back to Organizations',
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _organization.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Code: ${_organization.code}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(140),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StateBadge(state: toCommonState(_organization.state)),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _setAsActiveOrganization(context),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Set Active'),
                    ),
                    if (widget.canManage) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit Organization',
                        onPressed: () => _editOrganization(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // -- Profile header (avatar, name, type, description) -------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: _ProfileSection(
                  profileId: _organization.profileId,
                  organizationName: _organization.name,
                  organizationType: _organization.organizationType,
                  description: _prop('description'),
                  logoContentUri: _prop('logo_content_uri'),
                  filesBaseUrl: widget.filesBaseUrl,
                  state: _organization.state,
                ),
              ),
            ),

            // -- Organization info card -------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: _buildInfoCard(theme),
              ),
            ),

            // -- Coverage area badge ------------------------------------------------
            if (_organization.geoId.isNotEmpty)
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            'Coverage Area',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AreaBadge(areaId: _organization.geoId),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // -- Profile contacts & addresses (inline management) -------------------
            if (_organization.profileId.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: ProfileInlineManager(
                    profileId: _organization.profileId,
                  ),
                ),
              ),

            // -- Client ID card ---------------------------------------------------
            if (_organization.clientId.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: _buildClientIdCard(theme),
                ),
              ),

            // -- Sub-Organizations (always shown, with create button) ---------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  children: [
                    _SectionHeader(
                      icon: Icons.corporate_fare,
                      title: 'Sub-Organizations',
                    ),
                    const Spacer(),
                    if (widget.canManage)
                      FilledButton.icon(
                        onPressed: () => _showChildOrgWizard(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Child Org'),
                      ),
                  ],
                ),
              ),
            ),
            childOrgsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Failed to load: $error'),
                ),
              ),
              data: (childOrgs) {
                if (childOrgs.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Text('No sub-organizations yet'),
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: _DataTableCard(
                      columns: const ['NAME', 'TYPE', 'CODE', 'STATE'],
                      rows: childOrgs
                          .map(
                            (child) => DataRow(
                              onSelectChanged: (_) =>
                                  context.go('/organizations/${child.id}'),
                              cells: [
                                DataCell(Text(child.name)),
                                DataCell(
                                  Text(orgTypeLabel(child.organizationType)),
                                ),
                                DataCell(Text(child.code)),
                                DataCell(
                                  StateBadge(state: toCommonState(child.state)),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            ),

            // -- Org Units -------------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  children: [
                    _SectionHeader(
                      icon: Icons.account_tree_outlined,
                      title: 'Top-Level Org Units',
                    ),
                    const Spacer(),
                    if (widget.canManage)
                      FilledButton.icon(
                        onPressed: () => _showOrgUnitDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Org Unit'),
                      ),
                  ],
                ),
              ),
            ),
            orgUnitsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Failed to load org units: $error'),
                ),
              ),
              data: (orgUnits) {
                if (orgUnits.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Text('No org units yet'),
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: _DataTableCard(
                      columns: const ['ID', 'NAME', 'TYPE', 'CODE', 'STATE'],
                      rows: orgUnits.map((orgUnit) {
                        final shortId = orgUnit.id.length > 12
                            ? '${orgUnit.id.substring(0, 12)}\u2026'
                            : orgUnit.id;
                        return DataRow(
                          onSelectChanged: (_) =>
                              context.go('/org-units/${orgUnit.id}'),
                          cells: [
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SelectableText(
                                    shortId,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(text: orgUnit.id),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('ID copied'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.copy,
                                      size: 14,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(orgUnit.name)),
                            DataCell(Text(orgUnitTypeLabel(orgUnit.type))),
                            DataCell(Text(orgUnit.code)),
                            DataCell(
                              StateBadge(state: toCommonState(orgUnit.state)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),

            // -- Audit Trail -------------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: ObjectAuditTrail(
                  resourceType: 'organization',
                  resourceId: _organization.id,
                  maxEntries: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- Info card (org-specific metadata, not profile data) ----------------------

  Widget _buildInfoCard(ThemeData theme) {
    final items = <_InfoTile>[];
    items.add(
      _InfoTile(
        label: 'Organization Type',
        value: orgTypeLabel(_organization.organizationType),
      ),
    );
    if (_organization.code.isNotEmpty) {
      items.add(_InfoTile(label: 'Code', value: _organization.code));
    }
    if (_organization.domain.isNotEmpty) {
      items.add(_InfoTile(label: 'Domain', value: _organization.domain));
    }
    // Coverage area is displayed via AreaBadge widget below the info grid.
    if (_organization.profileId.isNotEmpty) {
      items.add(_InfoTile(label: 'Profile ID', value: _organization.profileId));
    }

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

  Widget _buildClientIdCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(38)),
      ),
      color: theme.colorScheme.primaryContainer.withAlpha(40),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(Icons.link, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Client ID',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    _organization.clientId,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Copy client ID',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _organization.clientId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Client ID copied')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // -- Property helpers -------------------------------------------------------

  String _prop(String key) {
    if (!_organization.hasProperties()) return '';
    final field = _organization.properties.fields[key];
    if (field == null || !field.hasStringValue()) return '';
    return field.stringValue;
  }

  // -- Actions ----------------------------------------------------------------

  void _setAsActiveOrganization(BuildContext context) {
    final tenancy = ref.read(tenancyContextProvider);
    tenancy.selectOrganization(
      _organization.id,
      _organization.name,
      partitionId: _organization.partitionId,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_organization.name} set as active organization'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showChildOrgWizard(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => OrganizationFormWizard(
        onPickLogo: widget.onPickLogo,
        onSave: (result) async {
          final org = result.organization;
          org.parentId = _organization.id;
          org.profileId = result.profileId;
          if (org.partitionId.isEmpty) {
            org.partitionId = _organization.partitionId;
          }
          await ref.read(organizationNotifierProvider.notifier).save(org);
          // Refresh child list
          ref.invalidate(filteredOrganizationListProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Child organization created')),
            );
          }
        },
      ),
    );
  }

  Future<void> _editOrganization(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => OrganizationFormWizard(
        organization: _organization,
        onPickLogo: widget.onPickLogo,
        onSave: (result) async {
          final org = result.organization;
          org.profileId = result.profileId;

          await ref.read(organizationNotifierProvider.notifier).save(org);

          // Reload from server to get complete response.
          if (mounted) {
            final client = ref.read(identityServiceClientProvider);
            final response = await client.organizationGet(
              OrganizationGetRequest(id: _organization.id),
            );
            setState(() => _organization = response.data);
          }
        },
      ),
    );
  }

  Future<void> _showOrgUnitDialog(BuildContext context) async {
    final result = await showDialog<OrgUnitObject>(
      context: context,
      builder: (context) => OrgUnitFormDialog(
        organizations: [_organization],
        fixedOrganizationId: _organization.id,
      ),
    );
    if (result == null || !context.mounted) return;

    try {
      await ref.read(orgUnitNotifierProvider.notifier).save(result);
      ref.invalidate(
        orgUnitListProvider((
          organizationId: _organization.id,
          rootOnly: true,
          query: '',
          parentId: '',
          type: OrgUnitType.ORG_UNIT_TYPE_UNSPECIFIED,
        )),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Org unit created successfully')),
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

// ---------------------------------------------------------------------------
// Profile section - uses profile UI widgets for contacts & addresses
// ---------------------------------------------------------------------------

class _ProfileSection extends ConsumerWidget {
  const _ProfileSection({
    required this.profileId,
    required this.organizationName,
    required this.organizationType,
    required this.description,
    required this.logoContentUri,
    required this.state,
    this.filesBaseUrl,
  });

  final String profileId;
  final String organizationName;
  final OrganizationType organizationType;
  final String description;
  final String logoContentUri;
  final dynamic state;
  final String? filesBaseUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final initial = organizationName.isNotEmpty
        ? organizationName[0].toUpperCase()
        : '?';

    // Convert mxc:// to HTTP for display.
    var displayLogoUri = logoContentUri;
    if (displayLogoUri.startsWith('mxc://') && filesBaseUrl != null) {
      final parts = displayLogoUri.substring(6).split('/');
      if (parts.length >= 2) {
        displayLogoUri =
            '$filesBaseUrl/v1/media/download/${parts[0]}/${parts[1]}';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile card with avatar, name, type, description
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withAlpha(38),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: displayLogoUri.isNotEmpty
                      ? NetworkImage(displayLogoUri)
                      : null,
                  child: displayLogoUri.isNotEmpty
                      ? null
                      : Text(
                          initial,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        organizationName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          orgTypeLabel(organizationType),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                StateBadge(state: toCommonState(state)),
              ],
            ),
          ),
        ),

        // Contacts and addresses are managed via ProfileInlineManager above.
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DataTableCard extends StatelessWidget {
  const _DataTableCard({required this.columns, required this.rows});
  final List<String> columns;
  final List<DataRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(38)),
      ),
      clipBehavior: Clip.antiAlias,
      child: DataTable(
        showCheckboxColumn: false,
        columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
        rows: rows,
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
