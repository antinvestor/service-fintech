import 'package:antinvestor_api_field/antinvestor_api_field.dart';
import 'package:antinvestor_api_identity/antinvestor_api_identity.dart'
    show ClientDataEntryObject, DataVerificationStatus;
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:antinvestor_ui_core/widgets/state_badge.dart';
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart'
    show ProfileInlineManager;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/client_data_providers.dart';
import '../providers/client_providers.dart';
import '../providers/kyc_requirements_providers.dart';
import '../widgets/async_state_views.dart';
import '../widgets/client_helpers.dart';
import '../widgets/load_more_action.dart';
import 'client_form_dialog.dart';
import 'consent_code_dialog.dart';

/// One borrower: their profile and the KYC data collected about them.
/// A tab a host app adds to the client screen, after Profile and KYC.
class ClientDetailTab {
  const ClientDetailTab({required this.label, required this.builder});

  final String label;
  final Widget Function(BuildContext context, ClientObject client) builder;
}

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({
    super.key,
    required this.clientId,
    this.canManage = false,
    this.backRoute = '/clients',
    this.extraTabs = const [],
  });

  final String clientId;

  /// Product tabs the host adds (e.g. a lender's credit profile and loans).
  final List<ClientDetailTab> extraTabs;

  /// Whether the caller may edit the client, add KYC data and decide on
  /// collected entries (`client_manage`).
  final bool canManage;

  final String backRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsync = ref.watch(clientDetailProvider(clientId));
    return clientAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(key: Key('client-detail-loading')),
      ),
      error: (e, _) => DetailErrorView(
        error: e,
        onRetry: () => ref.invalidate(clientDetailProvider(clientId)),
      ),
      data: (client) => _ClientDetailContent(
        client: client,
        canManage: canManage,
        backRoute: backRoute,
        extraTabs: extraTabs,
      ),
    );
  }
}

class _ClientDetailContent extends ConsumerStatefulWidget {
  const _ClientDetailContent({
    required this.client,
    required this.canManage,
    required this.backRoute,
    required this.extraTabs,
  });

  final ClientObject client;
  final bool canManage;
  final String backRoute;
  final List<ClientDetailTab> extraTabs;

  @override
  ConsumerState<_ClientDetailContent> createState() =>
      _ClientDetailContentState();
}

class _ClientDetailContentState extends ConsumerState<_ClientDetailContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2 + widget.extraTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  ClientObject get _client => widget.client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(widget.backRoute),
                tooltip: 'Back to Clients',
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _client.name.isNotEmpty ? _client.name : _client.id,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _client.id,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              StateBadge(state: fieldStateToCommon(_client.state)),
              if (widget.canManage && clientAwaitingActivation(_client)) ...[
                const SizedBox(width: 12),
                _ActivateButton(
                  clientId: _client.id,
                  onActivate: () => _activate(context),
                ),
              ],
              if (widget.canManage) ...[
                const SizedBox(width: 12),
                IconButton(
                  key: const Key('client-edit'),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Client',
                  onPressed: () => _edit(context),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: [
            const Tab(text: 'Profile'),
            const Tab(text: 'KYC'),
            for (final tab in widget.extraTabs) Tab(text: tab.label),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _ProfileTab(client: _client),
              _KycTab(clientId: _client.id, canManage: widget.canManage),
              for (final tab in widget.extraTabs) tab.builder(context, _client),
            ],
          ),
        ),
      ],
    );
  }

  /// Activates a client whose KYC is verified. The service sends the
  /// person a code and the agent enters it, confirming they consent to
  /// becoming a client and that the phone is theirs.
  Future<void> _activate(BuildContext context) async {
    final notifier = ref.read(clientNotifierProvider.notifier);
    try {
      var saved = await notifier.save(activationRequest(_client));
      while (clientConsentPending(saved)) {
        if (!context.mounted) return;
        final code = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const ConsentCodeDialog(),
        );
        if (code == null || !context.mounted) return;
        try {
          saved = await notifier.save(
            activationRequest(_client, pending: saved, code: code),
          );
        } catch (e) {
          // A wrong or expired code: say so and let the agent retry, which
          // sends a fresh code.
          if (!context.mounted) return;
          _showError(context, 'Code not accepted: ${friendlyError(e)}');
          return;
        }
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_client.name} is now an active client')),
      );
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, 'Could not activate: ${friendlyError(e)}');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final draft = await showDialog<ClientObject>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ClientFormDialog(client: _client),
    );
    if (draft == null || !context.mounted) return;
    try {
      await ref.read(clientNotifierProvider.notifier).save(draft);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Client updated')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update client: ${friendlyError(e)}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.client});

  final ClientObject client;

  @override
  Widget build(BuildContext context) {
    final nationalId = clientNationalId(client);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _InfoRow(label: 'Client ID', value: client.id),
        _InfoRow(
          label: 'National ID',
          value: nationalId.isNotEmpty ? nationalId : '-',
        ),
        _InfoRow(
          label: 'Owning team',
          value: client.owningTeamId.isNotEmpty ? client.owningTeamId : '-',
        ),
        _InfoRow(
          label: 'Agent',
          value: client.agentId.isNotEmpty ? client.agentId : '-',
        ),
        _InfoRow(
          label: 'Profile',
          value: client.profileId.isNotEmpty ? client.profileId : '-',
        ),
        if (clientAwaitingActivation(client))
          const Padding(
            key: Key('client-activation-hint'),
            padding: EdgeInsets.only(top: 16),
            child: Text(
              'Awaiting activation. Verify the KYC details, then activate: '
              'the borrower receives a code to confirm they agree. Their '
              'profile and contacts show here once they are active.',
            ),
          ),
        // Contacts and addresses belong to the borrower's profile and are
        // managed there, by contact id.
        if (client.profileId.isNotEmpty) ...[
          const SizedBox(height: 16),
          ProfileInlineManager(profileId: client.profileId),
        ],
      ],
    );
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

/// The KYC data collected about a client, with the verification lifecycle
/// actions a reviewer may take on each entry.
/// Activation is offered once every field the organization requires is
/// verified; until then the button says what is missing.
class _ActivateButton extends ConsumerWidget {
  const _ActivateButton({required this.clientId, required this.onActivate});

  final String clientId;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reqs = ref.watch(clientKycRequirementsProvider(clientId)).value;
    final ready = reqs?.complete ?? false;
    final missing = reqs == null
        ? 'Checking KYC requirements'
        : '${reqs.requirements.where((r) => r.status != DataVerificationStatus.DATA_VERIFICATION_STATUS_VERIFIED).length} '
              'required KYC field(s) still to verify';
    return Tooltip(
      message: ready ? 'Send the borrower their activation code' : missing,
      child: FilledButton.icon(
        key: const Key('client-activate'),
        onPressed: ready ? onActivate : null,
        icon: const Icon(Icons.verified_user_outlined),
        label: const Text('Activate'),
      ),
    );
  }
}

/// What the client's organization requires, and where each field stands.
class _RequirementsChecklist extends ConsumerWidget {
  const _RequirementsChecklist({required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(clientKycRequirementsProvider(clientId));
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Padding(
        key: const Key('kyc-requirements-error'),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        child: Text(
          friendlyError(e),
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ),
      data: (reqs) => Padding(
        key: const Key('kyc-requirements'),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reqs.complete
                  ? 'All required KYC is verified'
                  : 'Required before activation',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final r in reqs.requirements)
                  Chip(
                    key: Key('kyc-requirement-${r.fieldKey}'),
                    avatar: Icon(
                      r.status ==
                              DataVerificationStatus
                                  .DATA_VERIFICATION_STATUS_VERIFIED
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: verificationStatusColor(r.status),
                    ),
                    label: Text(
                      '${r.label.isNotEmpty ? r.label : r.fieldKey}: '
                      '${r.status == DataVerificationStatus.DATA_VERIFICATION_STATUS_UNSPECIFIED ? 'Missing' : verificationStatusLabel(r.status)}',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KycTab extends ConsumerWidget {
  const _KycTab({required this.clientId, required this.canManage});

  final String clientId;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = clientDataPagedListProvider(clientId);
    final entriesAsync = ref.watch(provider);
    final theme = Theme.of(context);

    return Column(
      children: [
        _RequirementsChecklist(clientId: clientId),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              Text('Collected data', style: theme.textTheme.titleMedium),
              const Spacer(),
              if (entriesAsync.hasValue)
                LoadMoreAction(
                  loadedCount: entriesAsync.requireValue.items.length,
                  hasMore: entriesAsync.requireValue.hasMore,
                  isLoading: entriesAsync.requireValue.isLoadingMore,
                  onLoadMore: () => ref.read(provider.notifier).loadMore(),
                ),
              if (canManage) ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  key: const Key('kyc-add'),
                  onPressed: () => _addEntry(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add data'),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: entriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => DetailErrorView(
              error: e,
              onRetry: () => ref.invalidate(provider),
            ),
            data: (page) {
              if (page.items.isEmpty) {
                return const Center(
                  child: Text(
                    'No KYC data collected yet',
                    key: Key('kyc-empty'),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: page.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _KycEntryCard(
                  entry: page.items[index],
                  canManage: canManage,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _addEntry(BuildContext context, WidgetRef ref) async {
    final entry = await showDialog<ClientDataEntryObject>(
      context: context,
      builder: (_) => _KycEntryFormDialog(clientId: clientId),
    );
    if (entry == null || !context.mounted) return;
    await _run(
      context,
      () => ref.read(clientDataNotifierProvider.notifier).save(entry),
      'Data saved',
    );
  }
}

Future<void> _run(
  BuildContext context,
  Future<void> Function() action,
  String success,
) async {
  try {
    await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(success)));
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(friendlyError(e)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

class _KycEntryCard extends ConsumerWidget {
  const _KycEntryCard({required this.entry, required this.canManage});

  final ClientDataEntryObject entry;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = verificationStatusColor(entry.verificationStatus);
    final open = canManage && verificationIsOpen(entry.verificationStatus);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.fieldKey,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    verificationStatusLabel(entry.verificationStatus),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(entry.value, style: theme.textTheme.bodyMedium),
            if (entry.reviewerComment.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Reviewer: ${entry.reviewerComment}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (open) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if (verificationAwaitsReviewer(entry.verificationStatus))
                    OutlinedButton.icon(
                      key: Key('kyc-start-review-${entry.id}'),
                      onPressed: () => _run(
                        context,
                        () => ref
                            .read(clientDataNotifierProvider.notifier)
                            .startReview(entry.id),
                        'You are reviewing this entry',
                      ),
                      icon: const Icon(Icons.assignment_ind_outlined, size: 18),
                      label: const Text('Start review'),
                    ),
                  FilledButton.tonalIcon(
                    key: Key('kyc-verify-${entry.id}'),
                    onPressed: () => _run(
                      context,
                      () => ref
                          .read(clientDataNotifierProvider.notifier)
                          .verify(entry.id),
                      'Entry verified',
                    ),
                    icon: const Icon(Icons.verified_outlined, size: 18),
                    label: const Text('Verify'),
                  ),
                  OutlinedButton.icon(
                    key: Key('kyc-request-info-${entry.id}'),
                    onPressed: () => _withReason(
                      context,
                      title: 'Request more information',
                      hint: 'What is missing or unclear?',
                      action: 'Request',
                      onConfirm: (comment) => ref
                          .read(clientDataNotifierProvider.notifier)
                          .requestInfo(entry.id, comment),
                      success: 'Information requested',
                    ),
                    icon: const Icon(Icons.help_outline, size: 18),
                    label: const Text('Request info'),
                  ),
                  OutlinedButton.icon(
                    key: Key('kyc-reject-${entry.id}'),
                    onPressed: () => _withReason(
                      context,
                      title: 'Reject entry',
                      hint: 'Why is this entry being rejected?',
                      action: 'Reject',
                      onConfirm: (reason) => ref
                          .read(clientDataNotifierProvider.notifier)
                          .reject(entry.id, reason),
                      success: 'Entry rejected',
                    ),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _withReason(
    BuildContext context, {
    required String title,
    required String hint,
    required String action,
    required Future<void> Function(String) onConfirm,
    required String success,
  }) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ReasonDialog(title: title, hint: hint, action: action),
    );
    if (reason == null || reason.isEmpty || !context.mounted) return;
    await _run(context, () => onConfirm(reason), success);
  }
}

/// Asks for the free-text reason a reviewer attaches to a decision. Pops
/// with the trimmed text, or null when cancelled.
class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({
    required this.title,
    required this.hint,
    required this.action,
  });

  final String title;
  final String hint;
  final String action;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const Key('kyc-reason'),
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(hintText: widget.hint),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('kyc-reason-confirm'),
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(widget.action),
        ),
      ],
    );
  }
}

/// Collects one KYC field. Entries start as COLLECTED; the service moves
/// them through review.
class _KycEntryFormDialog extends StatefulWidget {
  const _KycEntryFormDialog({required this.clientId});

  final String clientId;

  @override
  State<_KycEntryFormDialog> createState() => _KycEntryFormDialogState();
}

class _KycEntryFormDialogState extends State<_KycEntryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _keyCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();

  static const _suggestedKeys = [
    'national_id',
    'date_of_birth',
    'residential_address',
    'business_location',
    'next_of_kin_phone',
  ];

  @override
  void dispose() {
    _keyCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      ClientDataEntryObject(
        clientId: widget.clientId,
        fieldKey: _keyCtrl.text.trim(),
        value: _valueCtrl.text.trim(),
        valueType: 'string',
        verificationStatus:
            DataVerificationStatus.DATA_VERIFICATION_STATUS_COLLECTED,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add KYC data'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormFieldCard(
                label: 'Field',
                description: 'What this value is, e.g. national_id.',
                isRequired: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      key: const Key('kyc-form-key'),
                      controller: _keyCtrl,
                      decoration: const InputDecoration(
                        hintText: 'e.g. national_id',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Field is required'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final key in _suggestedKeys)
                          ActionChip(
                            label: Text(key),
                            onPressed: () => _keyCtrl.text = key,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              FormFieldCard(
                label: 'Value',
                isRequired: true,
                child: TextFormField(
                  key: const Key('kyc-form-value'),
                  controller: _valueCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Value is required'
                      : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
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
          key: const Key('kyc-form-submit'),
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
