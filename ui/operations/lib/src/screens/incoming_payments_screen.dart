import 'dart:async';

import 'package:antinvestor_api_operations/antinvestor_api_operations.dart'
    hide PageCursor, STATE;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/incoming_payment_providers.dart';
import '../providers/operations_transport_provider.dart';

/// Lets the host offer a loan search in the assign dialog. Returns the chosen
/// loan account id, or null when the person backed out.
typedef LoanPicker = Future<String?> Function(BuildContext context);

/// Payments the rail received. Staff use it to find the ones that matched
/// nobody and say which loan each was meant for; the amount is always the
/// rail's.
class IncomingPaymentsScreen extends ConsumerStatefulWidget {
  const IncomingPaymentsScreen({
    super.key,
    this.canAssign = false,
    this.pickLoan,
  });

  /// Whether the caller holds payment_allocate.
  final bool canAssign;

  final LoanPicker? pickLoan;

  @override
  ConsumerState<IncomingPaymentsScreen> createState() =>
      _IncomingPaymentsScreenState();
}

class _IncomingPaymentsScreenState
    extends ConsumerState<IncomingPaymentsScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = '';
  bool _unmatchedOnly = true;

  IncomingPaymentFilter get _filter =>
      (query: _query, unmatchedOnly: _unmatchedOnly);

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

  void _refresh() => ref.invalidate(incomingPaymentListProvider(_filter));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paymentsAsync = ref.watch(incomingPaymentListProvider(_filter));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Text(
            'Incoming Payments',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 360,
                child: TextField(
                  key: const Key('incoming-payments-search'),
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Search transaction, reference or payer name',
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              FilterChip(
                key: const Key('incoming-payments-unmatched'),
                label: const Text('Unmatched only'),
                selected: _unmatchedOnly,
                onSelected: (value) => setState(() => _unmatchedOnly = value),
              ),
              FilledButton.tonalIcon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        Expanded(
          child: paymentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Could not load payments: $error'),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (page) {
              if (page.payments.isEmpty) {
                return Center(
                  child: Text(
                    _unmatchedOnly
                        ? 'Every payment received has been matched'
                        : 'No payments received',
                    style: theme.textTheme.bodyLarge,
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: page.payments.length + (page.hasMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index >= page.payments.length) {
                    return Center(
                      child: TextButton(
                        onPressed: () => ref
                            .read(incomingPaymentListProvider(_filter).notifier)
                            .loadMore(),
                        child: const Text('Load more'),
                      ),
                    );
                  }
                  final payment = page.payments[index];
                  return _PaymentCard(
                    payment: payment,
                    canAssign: widget.canAssign,
                    onAssign: () => _assign(payment),
                    onAllocate: () => _allocate(payment),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _assign(IncomingPaymentObject payment) async {
    final done = await showDialog<bool>(
      context: context,
      builder: (_) =>
          AssignPaymentDialog(payment: payment, pickLoan: widget.pickLoan),
    );
    if (done == true && mounted) {
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment applied to the loan')),
      );
    }
  }

  Future<void> _allocate(IncomingPaymentObject payment) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await allocateIncomingPayment(
        ref.read(operationsServiceClientProvider),
        paymentId: payment.id,
      );
      _refresh();
      messenger.showSnackBar(
        const SnackBar(content: Text('Payment allocated')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not allocate: ${friendlyError(e)}')),
      );
    }
  }
}

/// Whether a matched payment still has money allocation has not applied,
/// typically because the run after the assignment did not finish.
bool awaitsAllocation(IncomingPaymentObject payment) =>
    payment.matched &&
    (payment.unallocated.units.toInt() > 0 || payment.unallocated.nanos > 0);

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.payment,
    required this.canAssign,
    required this.onAssign,
    required this.onAllocate,
  });

  final IncomingPaymentObject payment;
  final bool canAssign;
  final VoidCallback onAssign;
  final VoidCallback onAllocate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final received = payment.hasReceivedAt()
        ? payment.receivedAt.toDateTime().toLocal().toString().substring(0, 16)
        : '-';
    final status = payment.matched
        ? (payment.identificationStrategy == 'staff_assigned'
              ? 'Assigned'
              : 'Matched')
        : 'Unmatched';
    final statusColor = payment.matched ? Colors.green : Colors.orange;

    return Card(
      key: Key('incoming-payment-${payment.id}'),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatMoney(payment.amount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Chip(
                  label: Text(status),
                  backgroundColor: statusColor.withAlpha(24),
                  side: BorderSide(color: statusColor.withAlpha(80)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _Field('Payer', payment.payerName),
                _Field('Reference quoted', payment.reference),
                _Field('Received', received),
                _Field('Transaction', payment.transactionId),
                if (payment.loanAccountId.isNotEmpty)
                  _Field('Loan', payment.loanAccountId),
                if (payment.assignmentNote.isNotEmpty)
                  _Field('Note', payment.assignmentNote),
              ],
            ),
            if (canAssign && (!payment.matched || awaitsAllocation(payment)))
              Align(
                alignment: Alignment.centerRight,
                child: payment.matched
                    ? OutlinedButton.icon(
                        key: Key('incoming-payment-allocate-${payment.id}'),
                        onPressed: onAllocate,
                        icon: const Icon(Icons.playlist_add_check, size: 18),
                        label: const Text('Allocate'),
                      )
                    : FilledButton.icon(
                        key: Key('incoming-payment-assign-${payment.id}'),
                        onPressed: onAssign,
                        icon: const Icon(Icons.link, size: 18),
                        label: const Text('Assign to loan'),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        Text(value.isEmpty ? '-' : value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

/// Asks which loan an unmatched payment belongs to and why, then applies it.
/// There is no amount field: the payment is applied in full, as received.
class AssignPaymentDialog extends ConsumerStatefulWidget {
  const AssignPaymentDialog({super.key, required this.payment, this.pickLoan});

  final IncomingPaymentObject payment;
  final LoanPicker? pickLoan;

  @override
  ConsumerState<AssignPaymentDialog> createState() =>
      _AssignPaymentDialogState();
}

class _AssignPaymentDialogState extends ConsumerState<AssignPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _loanCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _loanCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final picked = await widget.pickLoan!(context);
    if (picked != null && mounted) setState(() => _loanCtrl.text = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await assignIncomingPayment(
        ref.read(operationsServiceClientProvider),
        paymentId: widget.payment.id,
        loanAccountId: _loanCtrl.text.trim(),
        note: _noteCtrl.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = friendlyError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign payment to a loan'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${formatMoney(widget.payment.amount)} from '
                '${widget.payment.payerName.isEmpty ? 'an unknown payer' : widget.payment.payerName} '
                'is applied in full to the loan you choose.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('assign-payment-loan'),
                controller: _loanCtrl,
                decoration: InputDecoration(
                  labelText: 'Loan account ID',
                  suffixIcon: widget.pickLoan == null
                      ? null
                      : IconButton(
                          tooltip: 'Find loan',
                          icon: const Icon(Icons.search),
                          onPressed: _submitting ? null : _pick,
                        ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Choose the loan' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('assign-payment-note'),
                controller: _noteCtrl,
                maxLength: 500,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Why this payment belongs to this loan',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'A note is required'
                    : null,
              ),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('assign-payment-submit'),
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Assign'),
        ),
      ],
    );
  }
}
