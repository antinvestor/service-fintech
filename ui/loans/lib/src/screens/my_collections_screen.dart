import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
