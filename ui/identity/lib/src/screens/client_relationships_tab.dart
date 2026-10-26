import 'package:antinvestor_api_field/antinvestor_api_field.dart' hide STATE;
import 'package:antinvestor_api_identity/antinvestor_api_identity.dart'
    show InternalTeamObject, WorkforceMemberObject;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/client_providers.dart';
import '../providers/identity_transport_provider.dart';
import '../providers/team_providers.dart';
import '../providers/workforce_member_providers.dart';

/// The staff members assigned to a client.
final clientRelationshipsProvider =
    FutureProvider.family<List<ClientRelationshipObject>, String>((
      ref,
      clientId,
    ) {
      final client = ref.watch(fieldServiceClientProvider);
      return collectStream(
        client.clientRelationshipSearch(
          ClientRelationshipSearchRequest(
            clientId: clientId,
            cursor: PageCursor(limit: 50),
          ),
        ),
        extract: (response) => response.data,
      );
    });

/// A member's name from their properties, or their profile id.
String memberLabel(WorkforceMemberObject member) =>
    member.hasProperties() && member.properties.fields.containsKey('name')
    ? member.properties.fields['name']!.stringValue
    : member.profileId;

/// Who looks after a client: the team that owns them, and the staff
/// members assigned to them. When an agent leaves or a portfolio moves,
/// staff transfer the client to another team (client_manage) and assign
/// members (client_relationship_manage).
class ClientRelationshipsTab extends ConsumerWidget {
  const ClientRelationshipsTab({
    super.key,
    required this.client,
    this.canTransfer = false,
    this.canAssign = false,
  });

  final ClientObject client;
  final bool canTransfer;
  final bool canAssign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final relationships = ref.watch(clientRelationshipsProvider(client.id));
    final teamId = client.owningTeamId;
    final team = teamId.isEmpty
        ? null
        : ref.watch(internalTeamByIdProvider(teamId));

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Owning team', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          child: ListTile(
            key: const Key('client-owning-team'),
            leading: const Icon(Icons.groups_outlined),
            title: Text(
              team == null
                  ? 'No team'
                  : team.when(
                      data: (t) => t.name.isNotEmpty ? t.name : t.id,
                      loading: () => teamId,
                      error: (_, _) => teamId,
                    ),
            ),
            trailing: canTransfer
                ? OutlinedButton(
                    key: const Key('client-transfer'),
                    onPressed: () => _transfer(context, ref),
                    child: const Text('Transfer'),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text('Assigned staff', style: theme.textTheme.titleMedium),
            const Spacer(),
            if (canAssign)
              FilledButton.tonalIcon(
                key: const Key('client-assign-member'),
                onPressed: () => _assign(context, ref),
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Assign'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        relationships.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Could not load staff: ${friendlyError(e)}'),
          data: (list) => list.isEmpty
              ? const Text('Nobody is assigned yet.')
              : Column(
                  children: [
                    for (final r in list)
                      Card(
                        elevation: 0,
                        child: ListTile(
                          key: Key('client-relationship-${r.id}'),
                          leading: Icon(
                            r.isPrimary ? Icons.star : Icons.person_outline,
                          ),
                          title: Text(r.name.isNotEmpty ? r.name : r.memberId),
                          subtitle: Text(
                            r.isPrimary
                                ? 'Primary · ${r.memberId}'
                                : r.memberId,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _transfer(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<({String teamId, String reason})>(
      context: context,
      builder: (_) => const _TransferDialog(),
    );
    if (result == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(fieldServiceClientProvider)
          .clientOwnershipTransfer(
            ClientOwnershipTransferRequest(
              clientId: client.id,
              newOwningTeamId: result.teamId,
              reason: result.reason,
            ),
          );
      ref.invalidate(clientDetailProvider(client.id));
      messenger.showSnackBar(
        const SnackBar(content: Text('Client transferred')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not transfer: ${friendlyError(e)}')),
      );
    }
  }

  Future<void> _assign(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<ClientRelationshipObject>(
      context: context,
      builder: (_) => _AssignDialog(clientId: client.id),
    );
    if (result == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(fieldServiceClientProvider)
          .clientRelationshipSave(ClientRelationshipSaveRequest(data: result));
      ref.invalidate(clientRelationshipsProvider(client.id));
      messenger.showSnackBar(const SnackBar(content: Text('Member assigned')));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not assign: ${friendlyError(e)}')),
      );
    }
  }
}

class _TransferDialog extends ConsumerStatefulWidget {
  const _TransferDialog();

  @override
  ConsumerState<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends ConsumerState<_TransferDialog> {
  final _reason = TextEditingController();
  String? _teamId;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(
      internalTeamListProvider((query: '', organizationId: '')),
    );
    return AlertDialog(
      title: const Text('Transfer client'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            teams.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) =>
                  Text('Could not load teams: ${friendlyError(e)}'),
              data: (list) => DropdownButtonFormField<String>(
                key: const Key('client-transfer-team'),
                initialValue: _teamId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'New owning team'),
                items: [
                  for (final InternalTeamObject t in list)
                    DropdownMenuItem(
                      value: t.id,
                      child: Text(t.name.isNotEmpty ? t.name : t.id),
                    ),
                ],
                onChanged: (v) => setState(() => _teamId = v),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('client-transfer-reason'),
              controller: _reason,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Reason (kept on record)',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('client-transfer-submit'),
          onPressed: _teamId == null || _reason.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, (
                  teamId: _teamId!,
                  reason: _reason.text.trim(),
                )),
          child: const Text('Transfer'),
        ),
      ],
    );
  }
}

class _AssignDialog extends ConsumerStatefulWidget {
  const _AssignDialog({required this.clientId});
  final String clientId;

  @override
  ConsumerState<_AssignDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends ConsumerState<_AssignDialog> {
  final _role = TextEditingController(text: 'Loan officer');
  String? _memberId;
  bool _primary = true;

  @override
  void dispose() {
    _role.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(
      workforceMemberListProvider((
        query: '',
        organizationId: '',
        homeOrgUnitId: '',
      )),
    );
    return AlertDialog(
      title: const Text('Assign a staff member'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            members.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) =>
                  Text('Could not load staff: ${friendlyError(e)}'),
              data: (list) => DropdownButtonFormField<String>(
                key: const Key('client-assign-member-pick'),
                initialValue: _memberId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Staff member'),
                items: [
                  for (final m in list)
                    DropdownMenuItem(value: m.id, child: Text(memberLabel(m))),
                ],
                onChanged: (v) => setState(() => _memberId = v),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('client-assign-role'),
              controller: _role,
              decoration: const InputDecoration(
                labelText: 'Role with this client',
              ),
              onChanged: (_) => setState(() {}),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Primary contact'),
              value: _primary,
              onChanged: (v) => setState(() => _primary = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('client-assign-submit'),
          onPressed: _memberId == null || _role.text.trim().isEmpty
              ? null
              : () => Navigator.pop(
                  context,
                  ClientRelationshipObject(
                    clientId: widget.clientId,
                    memberId: _memberId!,
                    name: _role.text.trim(),
                    isPrimary: _primary,
                  ),
                ),
          child: const Text('Assign'),
        ),
      ],
    );
  }
}
