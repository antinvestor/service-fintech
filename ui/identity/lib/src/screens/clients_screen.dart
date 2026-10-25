import 'package:antinvestor_api_field/antinvestor_api_field.dart';
import 'package:antinvestor_ui_core/widgets/admin_entity_list_page.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/state_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/client_providers.dart';
import '../providers/paged_list.dart';
import '../providers/registration_outbox.dart';
import '../widgets/async_state_views.dart';
import '../widgets/client_helpers.dart';
import '../widgets/load_more_action.dart';
import 'client_form_dialog.dart';
import 'consent_code_dialog.dart';

/// The borrowers a field agent (or their supervisors) can see, with
/// onboarding for callers who may manage clients.
class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({
    super.key,
    this.canManage = false,
    this.onNavigateToDetail,
  });

  /// Whether the caller may onboard clients (`client_manage`).
  final bool canManage;

  /// Overrides the default navigation to `/clients/:id`.
  final void Function(String clientId)? onNavigateToDetail;

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  static const _title = 'Clients';
  static const _breadcrumbs = ['Field', 'Clients'];

  String _searchQuery = '';

  ClientListParams get _params =>
      (query: _searchQuery, agentId: '', owningTeamId: '');

  @override
  Widget build(BuildContext context) {
    final provider = clientPagedListProvider(_params);
    final clientsAsync = ref.watch(provider);
    // An agent who can onboard keeps the page when the list cannot load:
    // registrations are captured offline and sent later.
    if (clientsAsync.hasError && !widget.canManage) {
      return ListErrorView(
        title: _title,
        breadcrumbs: _breadcrumbs,
        error: clientsAsync.error!,
        onRetry: () => ref.invalidate(provider),
      );
    }
    if (clientsAsync.isLoading && !clientsAsync.hasValue) {
      return const ListLoadingView(title: _title, breadcrumbs: _breadcrumbs);
    }
    final page = clientsAsync.hasValue
        ? clientsAsync.requireValue
        : const PagedList<ClientObject>(items: [], nextPage: null);
    final clients = page.items;
    final loadError = clientsAsync.hasError ? clientsAsync.error : null;

    return AdminEntityListPage<ClientObject>(
      title: _title,
      breadcrumbs: _breadcrumbs,
      columns: const [
        DataColumn(label: Text('NAME')),
        DataColumn(label: Text('TEAM')),
        DataColumn(label: Text('STATE')),
      ],
      items: clients,
      onSearch: (value) => setState(() => _searchQuery = value.trim()),
      searchHint: 'Search by name or phone',
      filters: widget.canManage
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (loadError != null)
                  ListTile(
                    key: const Key('clients-offline'),
                    leading: const Icon(Icons.cloud_off_outlined),
                    title: Text(friendlyError(loadError)),
                    subtitle: const Text(
                      'You can still onboard clients; they are sent when '
                      'you are back online.',
                    ),
                    trailing: TextButton(
                      onPressed: () => ref.invalidate(provider),
                      child: const Text('Retry'),
                    ),
                  ),
                PendingRegistrationsPanel(
                  onSend: (item, submission) =>
                      _send(context, item.id, item.name, submission),
                ),
              ],
            )
          : null,
      addLabel: widget.canManage ? 'Onboard client' : null,
      onAdd: widget.canManage ? () => _onboard(context) : null,
      actions: [
        LoadMoreAction(
          loadedCount: clients.length,
          hasMore: page.hasMore,
          isLoading: page.isLoadingMore,
          errorMessage: page.loadMoreError == null
              ? null
              : friendlyError(page.loadMoreError!),
          onLoadMore: () => ref.read(provider.notifier).loadMore(),
        ),
      ],
      rowBuilder: (client, selected, onSelect) {
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
                      Icons.person_outline,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(client.name.isNotEmpty ? client.name : client.id),
                ],
              ),
            ),
            DataCell(
              Text(client.owningTeamId.isNotEmpty ? client.owningTeamId : '-'),
            ),
            DataCell(StateBadge(state: fieldStateToCommon(client.state))),
          ],
        );
      },
      onRowNavigate: (client) {
        if (widget.onNavigateToDetail != null) {
          widget.onNavigateToDetail!(client.id);
        } else {
          context.go('/clients/${client.id}');
        }
      },
      exportRow: (client) => [
        client.name,
        clientNationalId(client),
        client.owningTeamId,
        client.state.name,
        client.id,
      ],
    );
  }

  Future<void> _onboard(BuildContext context) async {
    final draft = await showDialog<ClientRegistrationDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ClientFormDialog(),
    );
    if (draft == null || !context.mounted) return;

    // Stored on the device first, then sent: a dropped connection keeps the
    // registration for the next sync instead of losing what was captured.
    final outbox = ref.read(registrationOutboxProvider.notifier);
    final id = await outbox.capture(
      name: draft.name,
      phone: draft.phone,
      nationalId: draft.nationalId,
      details: draft.details,
    );
    if (!context.mounted) return;
    await _send(context, id, draft.name, outbox.submit(id));
  }

  /// Reports how a submission of registration [id] went, asking for the
  /// person's consent code while they are still with the agent.
  Future<void> _send(
    BuildContext context,
    String id,
    String name,
    Future<RegistrationOutcome> submission,
  ) async {
    final outbox = ref.read(registrationOutboxProvider.notifier);
    try {
      var outcome = await submission;
      while (outcome == RegistrationOutcome.awaitingConsent) {
        if (!context.mounted) return;
        final code = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const ConsentCodeDialog(),
        );
        if (!context.mounted) return;
        if (code == null) {
          _show(context, '$name is waiting for their consent code');
          return;
        }
        outcome = await outbox.submit(id, code: code);
      }
      if (!context.mounted) return;
      _show(context, switch (outcome) {
        RegistrationOutcome.registered => '$name onboarded',
        RegistrationOutcome.queued =>
          'Saved on this device. $name is registered when you are online.',
        _ => 'Could not onboard $name; see pending registrations',
      }, error: outcome == RegistrationOutcome.rejected);
    } catch (e) {
      if (!context.mounted) return;
      _show(
        context,
        'Failed to onboard client: ${friendlyError(e)}',
        error: true,
      );
    }
  }

  void _show(BuildContext context, String message, {bool error = false}) {
    // The newest outcome replaces any earlier one still on screen.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }
}

/// Registrations still on the device: waiting for a connection, for the
/// person's consent code, or refused by the service.
class PendingRegistrationsPanel extends ConsumerWidget {
  const PendingRegistrationsPanel({super.key, required this.onSend});

  /// Sends a registration, optionally with a code, and reports the outcome.
  final void Function(
    PendingRegistration item,
    Future<RegistrationOutcome> submission,
  )
  onSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(registrationOutboxProvider).value ?? const [];
    if (items.isEmpty) return const SizedBox.shrink();
    final outbox = ref.read(registrationOutboxProvider.notifier);
    final theme = Theme.of(context);
    return Card(
      key: const Key('registration-outbox'),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${items.length} registration'
                    '${items.length == 1 ? '' : 's'} on this device',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                TextButton(
                  key: const Key('registration-outbox-sync'),
                  onPressed: () async {
                    final sent = await outbox.flush();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('$sent registered')));
                  },
                  child: const Text('Sync now'),
                ),
              ],
            ),
            for (final item in items)
              ListTile(
                key: Key('registration-${item.id}'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(item.name),
                subtitle: Text(_status(item)),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    if (item.awaitingConsent) ...[
                      TextButton(
                        key: Key('registration-code-${item.id}'),
                        onPressed: () => onSend(item, outbox.submit(item.id)),
                        child: const Text('Enter code'),
                      ),
                      TextButton(
                        key: Key('registration-resend-${item.id}'),
                        onPressed: () =>
                            onSend(item, outbox.resendConsent(item.id)),
                        child: const Text('Resend code'),
                      ),
                    ],
                    if (item.rejected)
                      IconButton(
                        key: Key('registration-dismiss-${item.id}'),
                        tooltip: 'Dismiss',
                        icon: const Icon(Icons.close),
                        onPressed: () => outbox.dismiss(item.id),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _status(PendingRegistration item) {
    if (item.rejected) {
      return item.clientId.isEmpty
          ? 'Refused: ${item.rejection}'
          : 'Registered, but a detail was refused: ${item.rejection}. '
                'Re-enter it on the client\'s KYC tab.';
    }
    if (item.awaitingConsent) {
      return 'Already known: waiting for their consent code';
    }
    if (item.clientId.isNotEmpty) {
      return 'Registered; ${item.details.length} detail(s) still to send';
    }
    return 'Waiting for a connection';
  }
}
