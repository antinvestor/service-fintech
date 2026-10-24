import 'package:antinvestor_api_field/antinvestor_api_field.dart';
import 'package:antinvestor_ui_core/widgets/admin_entity_list_page.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/state_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/client_providers.dart';
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
    if (clientsAsync.hasError) {
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
    final page = clientsAsync.requireValue;
    final clients = page.items;

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
    final draft = await showDialog<ClientObject>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ClientFormDialog(),
    );
    if (draft == null || !context.mounted) return;

    try {
      final notifier = ref.read(clientNotifierProvider.notifier);
      var saved = await notifier.save(draft);
      // A person who already has a profile must consent: the service sends
      // them a code and answers without a client until it is entered.
      while (saved.id.isEmpty && clientConsentPending(saved)) {
        if (!context.mounted) return;
        final code = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const ConsentCodeDialog(),
        );
        if (code == null || !context.mounted) return;
        saved = await notifier.save(withConsentCode(draft, saved, code));
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${saved.name} onboarded')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to onboard client: ${friendlyError(e)}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
