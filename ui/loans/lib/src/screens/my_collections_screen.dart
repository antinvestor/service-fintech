import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/repayment_outbox.dart';
import '../providers/repayment_providers.dart';
import '../utils/money_compat.dart';

/// What the signed-in field agent collected today: every repayment they
/// recorded since local midnight, with the total per currency, so the cash
/// they carry can be checked before remitting it.
class MyCollectionsScreen extends ConsumerWidget {
  const MyCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final collections = ref.watch(myCollectionsTodayProvider);
    final outbox = ref.watch(repaymentOutboxProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('My collections today')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(myCollectionsTodayProvider.future),
        child: collections.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text('Could not load collections: $e'),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: () =>
                          ref.invalidate(myCollectionsTodayProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          data: (repayments) {
            final totals = collectionTotals(repayments);
            return ListView(
              key: const Key('my-collections'),
              padding: const EdgeInsets.all(16),
              children: [
                if (outbox.isNotEmpty) _OutboxBanner(items: outbox),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${repayments.length} collection'
                          '${repayments.length == 1 ? '' : 's'}',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        if (totals.isEmpty)
                          const Text('Nothing collected yet today')
                        else
                          for (final total in totals.values)
                            Text(
                              formatLoanMoney(total),
                              style: theme.textTheme.headlineSmall,
                            ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                for (final r in repayments)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      r.channel == kRepaymentChannelCash
                          ? Icons.payments_outlined
                          : Icons.phone_android,
                    ),
                    title: Text(formatLoanMoney(r.amount)),
                    subtitle: Text(
                      '${repaymentChannelLabel(r.channel)} · ${r.receivedAt}',
                    ),
                    onTap: () => context.go('/loans/${r.loanAccountId}'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Repayments saved offline: how many wait to be sent, which the service
/// refused, and a way to send them now.
class _OutboxBanner extends ConsumerWidget {
  const _OutboxBanner({required this.items});

  final List<PendingRepayment> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final waiting = items.where((i) => !i.rejected).length;
    return Card(
      key: const Key('repayment-outbox'),
      elevation: 0,
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_upload_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('$waiting saved offline, waiting to be sent'),
                ),
                TextButton(
                  onPressed: waiting == 0
                      ? null
                      : () async {
                          final sent = await ref
                              .read(repaymentOutboxProvider.notifier)
                              .flush();
                          ref.invalidate(myCollectionsTodayProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$sent sent')),
                            );
                          }
                        },
                  child: const Text('Send now'),
                ),
              ],
            ),
            for (final item in items.where((i) => i.rejected))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                ),
                title: Text('${item.currencyCode} ${item.amount} refused'),
                subtitle: Text(item.rejection),
                trailing: IconButton(
                  tooltip: 'Dismiss',
                  icon: const Icon(Icons.close),
                  onPressed: () => ref
                      .read(repaymentOutboxProvider.notifier)
                      .dismiss(item.idempotencyKey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Totals per currency, summed exactly in units and nanos.
Map<String, Money> collectionTotals(List<RepaymentObject> repayments) {
  const nanosPerUnit = 1000000000;
  final units = <String, Int64>{};
  final nanos = <String, int>{};
  for (final r in repayments) {
    final code = r.amount.currencyCode;
    units[code] = (units[code] ?? Int64.ZERO) + r.amount.units;
    nanos[code] = (nanos[code] ?? 0) + r.amount.nanos;
  }
  return {
    for (final code in units.keys)
      code: Money(
        currencyCode: code,
        units: units[code]! + Int64(nanos[code]! ~/ nanosPerUnit),
        nanos: nanos[code]! % nanosPerUnit,
      ),
  };
}
