import 'dart:async';

import 'package:antinvestor_api_common/antinvestor_api_common.dart' show STATE;
import 'package:antinvestor_api_operations/antinvestor_api_operations.dart'
    hide PageCursor, STATE;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';

import '../utils/money_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transfer_types.dart';
import '../providers/transfer_order_providers.dart';

class TransferOrdersScreen extends ConsumerStatefulWidget {
  const TransferOrdersScreen({super.key});

  @override
  ConsumerState<TransferOrdersScreen> createState() =>
      _TransferOrdersScreenState();
}

class _TransferOrdersScreenState extends ConsumerState<TransferOrdersScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = '';
  int? _orderTypeFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(
      transferOrderListProvider((query: _query, orderType: _orderTypeFilter)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Text(
            'Transfer Orders',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),

        // Search and filter bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by reference, account...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<int?>(
                  initialValue: _orderTypeFilter,
                  // Some type names are long; ellipsize rather than overflow.
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Order Type'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    for (final type in transferTypes)
                      DropdownMenuItem(
                        value: type.value,
                        child: Text(
                          type.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() => _orderTypeFilter = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                onPressed: () {
                  ref.invalidate(
                    transferOrderListProvider((
                      query: _query,
                      orderType: _orderTypeFilter,
                    )),
                  );
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),

        // Results
        Expanded(
          child: ordersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => ref.invalidate(
                      transferOrderListProvider((
                        query: _query,
                        orderType: _orderTypeFilter,
                      )),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (page) {
              final orders = page.orders;
              if (orders.isEmpty) {
                return Center(
                  child: Text(
                    'No transfer orders found',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(140),
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: orders.length + (page.hasMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index >= orders.length) {
                    return _LoadMoreButton(
                      onPressed: () => ref
                          .read(
                            transferOrderListProvider((
                              query: _query,
                              orderType: _orderTypeFilter,
                            )).notifier,
                          )
                          .loadMore(),
                    );
                  }
                  return _TransferOrderCard(order: orders[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TransferOrderCard extends StatelessWidget {
  const _TransferOrderCard({required this.order});

  final TransferOrderObject order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bridged = bridgeState(order.state);
    final stateLabel = _stateLabel(bridged);
    final stateColor = _stateColor(bridged);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.swap_horiz,
                    size: 20,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transferTypeLabel(orderTypeValue(order)),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'ID: ${order.id}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(140),
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: stateColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: stateColor.withAlpha(60)),
                  ),
                  child: Text(
                    stateLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: stateColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    label: 'Amount',
                    value: formatMoney(order.amount),
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    label: 'Debit Account',
                    value: order.debitAccountRef.isNotEmpty
                        ? order.debitAccountRef
                        : '-',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.arrow_forward, size: 16),
                ),
                Expanded(
                  child: _DetailItem(
                    label: 'Credit Account',
                    value: order.creditAccountRef.isNotEmpty
                        ? order.creditAccountRef
                        : '-',
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    label: 'Reference',
                    value: order.reference.isNotEmpty ? order.reference : '-',
                  ),
                ),
              ],
            ),
            if (order.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                order.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(160),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _stateLabel(STATE state) {
    return switch (state) {
      STATE.CREATED => 'Created',
      STATE.CHECKED => 'Checked',
      STATE.ACTIVE => 'Active',
      STATE.INACTIVE => 'Inactive',
      STATE.DELETED => 'Deleted',
      _ => 'Unknown',
    };
  }

  static Color _stateColor(STATE state) {
    return switch (state) {
      STATE.CREATED => Colors.blue,
      STATE.CHECKED => Colors.orange,
      STATE.ACTIVE => Colors.green,
      STATE.INACTIVE => Colors.grey,
      STATE.DELETED => Colors.red,
      _ => Colors.grey,
    };
  }
}

/// Appends the next page of results. Disables itself while the fetch is in
/// flight so a fast double tap cannot request the same page twice.
class _LoadMoreButton extends StatefulWidget {
  const _LoadMoreButton({required this.onPressed});

  final Future<void> Function() onPressed;

  @override
  State<_LoadMoreButton> createState() => _LoadMoreButtonState();
}

class _LoadMoreButtonState extends State<_LoadMoreButton> {
  bool _busy = false;

  Future<void> _handlePressed() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: _busy
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : FilledButton.tonal(
                onPressed: _handlePressed,
                child: const Text('Load more'),
              ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(120),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
