import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/savings_providers.dart';
import '../utils/money_display.dart';
import '../widgets/async_list_view.dart';

/// Every pending withdrawal in the organization, with approve and cancel
/// actions for callers who hold `withdrawal_manage`.
class WithdrawalApprovalQueueScreen extends ConsumerWidget {
  const WithdrawalApprovalQueueScreen({super.key, required this.canManage});

  /// Whether approve and cancel are offered. Viewers still see the queue.
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationId = ref.watch(tenancyContextProvider).organizationId;
    final queueAsync = ref.watch(
      pendingWithdrawalQueueProvider(organizationId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Withdrawal Approvals',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                key: const Key('queue-refresh'),
                tooltip: 'Refresh',
                onPressed: () => ref.invalidate(
                  pendingWithdrawalQueueProvider(organizationId),
                ),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: AsyncListView<PendingWithdrawal>(
            value: queueAsync,
            onRetry: () =>
                ref.invalidate(pendingWithdrawalQueueProvider(organizationId)),
            emptyTitle: 'Nothing to approve',
            emptyMessage: 'No withdrawal is waiting for a decision.',
            builder: (items) => _QueueList(items: items, canManage: canManage),
          ),
        ),
      ],
    );
  }
}

class _QueueList extends ConsumerWidget {
  const _QueueList({required this.items, required this.canManage});

  final List<PendingWithdrawal> items;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final w = item.withdrawal;
        final account = item.account;
        return Card(
          elevation: 0,
          key: Key('queue-row-${w.id}'),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withAlpha(24),
              child: const Icon(
                Icons.hourglass_top,
                color: Colors.orange,
                size: 20,
              ),
            ),
            title: Text(
              displayMoney(w.amount),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              [
                'Account ${account.id}',
                if (account.ownerId.isNotEmpty) 'Owner ${account.ownerId}',
                if (w.reason.isNotEmpty)
                  w.reason
                else if (w.channel.isNotEmpty)
                  w.channel,
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () => context.go('/savings/${account.id}'),
            trailing: canManage
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton.tonal(
                        key: Key('queue-approve-${w.id}'),
                        onPressed: () => _approve(context, ref, item),
                        child: const Text('Approve'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        key: Key('queue-cancel-${w.id}'),
                        onPressed: () => _cancel(context, ref, item),
                        child: const Text('Cancel'),
                      ),
                    ],
                  )
                : const Chip(label: Text('Pending')),
          ),
        );
      },
    );
  }

  Future<void> _approve(
    BuildContext context,
    WidgetRef ref,
    PendingWithdrawal item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve withdrawal'),
        content: Text(
          'Release ${displayMoney(item.withdrawal.amount)} from account '
          '${item.account.id}? The held funds are paid out and cannot be '
          'recalled from here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep pending'),
          ),
          FilledButton(
            key: const Key('queue-confirm-approve'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(withdrawalNotifierProvider.notifier)
          .approve(item.withdrawal.id, item.account.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Withdrawal approved')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $error')));
      }
    }
  }

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    PendingWithdrawal item,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => _CancelReasonDialog(item: item),
    );
    if (reason == null || !context.mounted) return;

    try {
      await ref
          .read(withdrawalNotifierProvider.notifier)
          .cancel(item.withdrawal.id, item.account.id, reason);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Withdrawal cancelled')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $error')));
      }
    }
  }
}

class _CancelReasonDialog extends StatefulWidget {
  const _CancelReasonDialog({required this.item});

  final PendingWithdrawal item;

  @override
  State<_CancelReasonDialog> createState() => _CancelReasonDialogState();
}

class _CancelReasonDialogState extends State<_CancelReasonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancel withdrawal'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${displayMoney(widget.item.withdrawal.amount)} is returned to '
                'the member\'s available balance immediately.',
              ),
              const SizedBox(height: 12),
              FormFieldCard(
                label: 'Reason',
                isRequired: true,
                child: TextFormField(
                  key: const Key('queue-cancel-reason'),
                  controller: _reasonCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Why is this withdrawal being cancelled?',
                  ),
                  validator: (v) => validateRequired(v, 'Reason'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Keep pending'),
        ),
        FilledButton(
          key: const Key('queue-confirm-cancel'),
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(context, _reasonCtrl.text.trim());
          },
          child: const Text('Cancel withdrawal'),
        ),
      ],
    );
  }
}
