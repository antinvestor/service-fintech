import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/loans_transport_provider.dart';
import '../providers/team_commission_providers.dart';
import '../utils/idempotency_key.dart';
import '../utils/money_compat.dart';

/// A team's commission: what it earned on interest its borrowers repaid,
/// what has been paid out, and, with [canPayout], paying part of it to one
/// of [memberIds]. The money goes to the chosen member's own verified mobile
/// number; nobody types where it goes.
class TeamCommissionSection extends ConsumerWidget {
  const TeamCommissionSection({
    super.key,
    required this.teamId,
    required this.memberIds,
    this.canPayout = false,
  });

  final String teamId;

  /// The team's active members, any of whom may be paid.
  final List<String> memberIds;
  final bool canPayout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final balancesAsync = ref.watch(teamCommissionProvider(teamId));
    final payoutsAsync = ref.watch(teamCommissionPayoutsProvider(teamId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.payments_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Commission',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        balancesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => _Retry(
            message: 'Failed to load commission: $e',
            onRetry: () => ref.invalidate(teamCommissionProvider(teamId)),
          ),
          data: (balances) => balances.isEmpty
              ? Text(
                  'No commission earned yet.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              : Column(
                  children: [
                    for (final b in balances)
                      _BalanceTile(
                        balance: b,
                        onPayout:
                            canPayout &&
                                memberIds.isNotEmpty &&
                                _positive(b.available)
                            ? () => _showPayoutDialog(context, ref, b)
                            : null,
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 8),
        payoutsAsync.maybeWhen(
          data: (payouts) => payouts.isEmpty
              ? const SizedBox.shrink()
              : Card(
                  elevation: 0,
                  child: Column(
                    children: [
                      for (final p in payouts)
                        ListTile(
                          dense: true,
                          key: Key('payout-${p.id}'),
                          title: Text(
                            '${formatLoanMoney(p.amount)} to ${p.memberId}',
                          ),
                          subtitle: Text(
                            [
                              p.reason,
                              if (p.failureReason.isNotEmpty)
                                'Last attempt refused: ${p.failureReason}',
                            ].where((s) => s.isNotEmpty).join(' • '),
                          ),
                          trailing: Text(payoutStatusLabel(p.status)),
                        ),
                    ],
                  ),
                ),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _showPayoutDialog(
    BuildContext context,
    WidgetRef ref,
    TeamCommissionObject balance,
  ) {
    final currency = loanMoneyCurrency(balance.available);
    showDialog<void>(
      context: context,
      builder: (_) => CommissionPayoutDialog(
        available: balance.available,
        memberIds: memberIds,
        onSubmit: (memberId, amount, reason, key) async {
          final client = ref.read(loanManagementServiceClientProvider);
          await client.teamCommissionPayout(
            TeamCommissionPayoutRequest(
              teamId: teamId,
              memberId: memberId,
              amount: loanMoneyFromString(amount, currency),
              reason: reason,
              idempotencyKey: key,
            ),
          );
          ref.invalidate(teamCommissionProvider(teamId));
          ref.invalidate(teamCommissionPayoutsProvider(teamId));
        },
      ),
    );
  }
}

bool _positive(Money? m) => m != null && (m.units.toInt() > 0 || m.nanos > 0);

/// Whether a payout error means nothing moved: the refusal codes of the
/// payout contract.
bool payoutRefused(Object error) =>
    error is ConnectException &&
    const {
      Code.invalidArgument,
      Code.failedPrecondition,
      Code.notFound,
      Code.permissionDenied,
    }.contains(error.code);

/// The label shown for a payout's status.
String payoutStatusLabel(TeamCommissionPayoutStatus status) {
  switch (status) {
    case TeamCommissionPayoutStatus.TEAM_COMMISSION_PAYOUT_STATUS_COMPLETED:
      return 'Paid';
    case TeamCommissionPayoutStatus.TEAM_COMMISSION_PAYOUT_STATUS_PROCESSING:
      return 'Awaiting confirmation';
    case TeamCommissionPayoutStatus.TEAM_COMMISSION_PAYOUT_STATUS_PENDING:
      return 'Not paid';
    default:
      return 'Unknown';
  }
}

class _BalanceTile extends StatelessWidget {
  const _BalanceTile({required this.balance, this.onPayout});

  final TeamCommissionObject balance;
  final VoidCallback? onPayout;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        title: Text('Available ${formatLoanMoney(balance.available)}'),
        subtitle: Text(
          'Earned ${formatLoanMoney(balance.accrued)} • '
          'Paid out ${formatLoanMoney(balance.paidOut)}',
        ),
        trailing: onPayout == null
            ? null
            : FilledButton.icon(
                key: const Key('commission-payout'),
                onPressed: onPayout,
                icon: const Icon(Icons.send_outlined, size: 18),
                label: const Text('Pay out'),
              ),
      ),
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(message)),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

/// Pays part of a team's commission to one member. The key is minted once
/// per dialog, so retrying after a timeout resumes the same payout rather
/// than paying twice; on failure the dialog stays open with the error.
class CommissionPayoutDialog extends StatefulWidget {
  const CommissionPayoutDialog({
    super.key,
    required this.available,
    required this.memberIds,
    required this.onSubmit,
  });

  final Money available;
  final List<String> memberIds;
  final Future<void> Function(
    String memberId,
    String amount,
    String reason,
    String idempotencyKey,
  )
  onSubmit;

  @override
  State<CommissionPayoutDialog> createState() => _CommissionPayoutDialogState();
}

class _CommissionPayoutDialogState extends State<CommissionPayoutDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  final _reasonCtrl = TextEditingController();
  late String _idempotencyKey;
  String? _memberId;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: loanMoneyToAmountString(widget.available),
    );
    _idempotencyKey = generateIdempotencyKey();
    if (widget.memberIds.length == 1) _memberId = widget.memberIds.first;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSubmit(
        _memberId!,
        _amountCtrl.text.trim(),
        _reasonCtrl.text.trim(),
        _idempotencyKey,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = '$e';
          // A refusal moved nothing and closes that payout, so the next try
          // is a new payout. Any other failure may have paid: retry the
          // same one.
          if (payoutRefused(e)) _idempotencyKey = generateIdempotencyKey();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pay out commission'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormFieldCard(
                  label: 'Member',
                  description: 'Paid to their own verified mobile number.',
                  isRequired: true,
                  child: DropdownButtonFormField<String>(
                    key: const Key('payout-member'),
                    initialValue: _memberId,
                    items: [
                      for (final id in widget.memberIds)
                        DropdownMenuItem(value: id, child: Text(id)),
                    ],
                    onChanged: _saving
                        ? null
                        : (v) => setState(() => _memberId = v),
                    validator: (v) => v == null ? 'Choose a member' : null,
                  ),
                ),
                FormFieldCard(
                  label: 'Amount',
                  description:
                      'Up to ${formatLoanMoney(widget.available)} available.',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('payout-amount'),
                    controller: _amountCtrl,
                    enabled: !_saving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: validateAmount,
                  ),
                ),
                FormFieldCard(
                  label: 'Reason',
                  isRequired: true,
                  child: TextFormField(
                    key: const Key('payout-reason'),
                    controller: _reasonCtrl,
                    enabled: !_saving,
                    decoration: const InputDecoration(
                      hintText: 'e.g. October commission',
                    ),
                    validator: (v) => (v ?? '').trim().length < 3
                        ? 'Give a reason (3 characters or more)'
                        : null,
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('payout-submit'),
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Pay out'),
        ),
      ],
    );
  }
}
