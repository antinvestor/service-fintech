import 'package:antinvestor_ui_core/antinvestor_ui_core.dart'
    show formatMoney, friendlyError;
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart'
    show LoanStatusBadge, loanAccountListProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'seed_api.dart';

/// Formats seed's minor units (two decimals) for display.
String formatMinor(int minor, String currency) {
  final whole = minor ~/ 100;
  final cents = (minor % 100).toString().padLeft(2, '0');
  final digits = whole.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$currency $digits.$cents';
}

/// The client's lending with this lender: their Seed credit profile (tier,
/// limit, standing) and their loans. Staff holding seed_credit_profile_admin
/// may suspend, block or reinstate borrowing, always with a reason. The
/// serving agent or staff holding seed_credit_profile_cap may lower the limit
/// for a while with a temporary cap.
class LendingTab extends ConsumerWidget {
  const LendingTab({
    super.key,
    required this.clientId,
    this.canAdmin = false,
    this.canCap = false,
  });

  final String clientId;
  final bool canAdmin;
  final bool canCap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(creditProfileProvider(clientId));
    final loans = ref.watch(
      loanAccountListProvider((
        query: '',
        status: null,
        agentId: '',
        clientId: clientId,
        limit: 20,
      )),
    );
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Credit profile', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        profile.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) =>
              Text('Could not load the profile: ${friendlyError(e)}'),
          data: (p) => p == null
              ? const Text(
                  'No credit profile yet: one is opened with the first loan request.',
                )
              : _ProfileCard(
                  clientId: clientId,
                  profile: p,
                  canAdmin: canAdmin,
                  canCap: canCap,
                ),
        ),
        const SizedBox(height: 24),
        Text('Loans', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        loans.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Could not load loans: ${friendlyError(e)}'),
          data: (page) => page.items.isEmpty
              ? const Text('No loans yet.')
              : Column(
                  children: [
                    for (final loan in page.items)
                      Card(
                        elevation: 0,
                        child: ListTile(
                          key: Key('lending-loan-${loan.id}'),
                          title: Text(formatMoney(loan.principalAmount)),
                          subtitle: Text(loan.id),
                          trailing: LoanStatusBadge(status: loan.status),
                          onTap: () => context.go('/loans/${loan.id}'),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard({
    required this.clientId,
    required this.profile,
    required this.canAdmin,
    required this.canCap,
  });

  final String clientId;
  final CreditProfile profile;
  final bool canAdmin;
  final bool canCap;

  Future<void> _setCap(BuildContext context, WidgetRef ref) async {
    final cap = await showDialog<({int amountMinor, int days, String reason})>(
      context: context,
      builder: (_) => _CapDialog(limitMinor: profile.maxLoanAmountMinor),
    );
    if (cap == null || !context.mounted) return;
    await _run(
      context,
      ref,
      () => ref
          .read(seedApiProvider)
          .setCap(
            clientId,
            seedCurrency,
            amountMinor: cap.amountMinor,
            expiresAt: DateTime.now().add(Duration(days: cap.days)),
            reason: cap.reason,
          ),
      'Temporary cap set',
    );
  }

  Future<void> _liftCap(BuildContext context, WidgetRef ref) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _ReasonDialog(title: 'Lift temporary cap'),
    );
    if (reason == null || !context.mounted) return;
    await _run(
      context,
      ref,
      () => ref.read(seedApiProvider).clearCap(clientId, seedCurrency, reason),
      'Temporary cap lifted',
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<CreditProfile> Function() call,
    String done,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await call();
      ref.invalidate(creditProfileProvider(clientId));
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not update: ${friendlyError(e)}')),
      );
    }
  }

  Future<void> _change(
    BuildContext context,
    WidgetRef ref,
    CreditProfileAction action,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ReasonDialog(title: _actionTitle(action)),
    );
    if (reason == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(seedApiProvider)
          .setStatus(clientId, seedCurrency, action, reason);
      ref.invalidate(creditProfileProvider(clientId));
      messenger.showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not update: ${friendlyError(e)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = profile.status == CreditProfileStatus.active;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 32,
              runSpacing: 12,
              children: [
                _Fact('Standing', profile.status.label),
                _Fact('Tier', '${profile.tier}'),
                _Fact(
                  'Can borrow up to',
                  formatMinor(profile.borrowLimitMinor, seedCurrency),
                ),
                if (profile.capActive)
                  _Fact(
                    'Temporary cap',
                    '${formatMinor(profile.tempCapMinor, seedCurrency)} until '
                        '${profile.tempCapExpiresAt!.toLocal().toString().split(' ').first}'
                        '${profile.tempCapReason.isEmpty ? '' : ' (${profile.tempCapReason})'}',
                  ),
                _Fact('Loans repaid', '${profile.successfulRepayments}'),
                _Fact('Loans running', '${profile.outstandingLoanCount}'),
              ],
            ),
            if (canCap) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                children: [
                  OutlinedButton(
                    key: const Key('lending-cap-set'),
                    onPressed: () => _setCap(context, ref),
                    child: Text(
                      profile.capActive
                          ? 'Change temporary cap'
                          : 'Set temporary cap',
                    ),
                  ),
                  if (profile.capActive)
                    TextButton(
                      key: const Key('lending-cap-lift'),
                      onPressed: () => _liftCap(context, ref),
                      child: const Text('Lift cap'),
                    ),
                ],
              ),
            ],
            if (canAdmin) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                children: [
                  if (active) ...[
                    OutlinedButton(
                      key: const Key('lending-suspend'),
                      onPressed: () =>
                          _change(context, ref, CreditProfileAction.suspend),
                      child: const Text('Suspend borrowing'),
                    ),
                    OutlinedButton(
                      key: const Key('lending-block'),
                      onPressed: () =>
                          _change(context, ref, CreditProfileAction.block),
                      child: const Text('Block borrowing'),
                    ),
                  ] else
                    FilledButton(
                      key: const Key('lending-reinstate'),
                      onPressed: () =>
                          _change(context, ref, CreditProfileAction.reinstate),
                      child: const Text('Reinstate'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);
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
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({required this.title});
  final String title;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const Key('lending-reason'),
        controller: _reason,
        autofocus: true,
        maxLines: 2,
        decoration: const InputDecoration(labelText: 'Reason (kept on record)'),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('lending-reason-submit'),
          onPressed: _reason.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, _reason.text.trim()),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

String _actionTitle(CreditProfileAction action) => switch (action) {
  CreditProfileAction.suspend => 'Suspend borrowing',
  CreditProfileAction.block => 'Block borrowing',
  CreditProfileAction.reinstate => 'Reinstate borrowing',
};

/// Asks for a temporary cap below the tier limit, how long it lasts and why.
class _CapDialog extends StatefulWidget {
  const _CapDialog({required this.limitMinor});
  final int limitMinor;

  @override
  State<_CapDialog> createState() => _CapDialogState();
}

class _CapDialogState extends State<_CapDialog> {
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  int _days = 14;

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  /// The cap in minor units, or null when it is not a lowering of the limit.
  int? get _amountMinor {
    final major = double.tryParse(_amount.text.trim().replaceAll(',', ''));
    if (major == null || major <= 0) return null;
    final minor = (major * 100).round();
    return minor < widget.limitMinor ? minor : null;
  }

  @override
  Widget build(BuildContext context) {
    final valid = _amountMinor != null && _reason.text.trim().isNotEmpty;
    return AlertDialog(
      title: const Text('Temporary cap'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Below the tier limit of '
              '${formatMinor(widget.limitMinor, seedCurrency)}; it lapses on its own.',
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('lending-cap-amount'),
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: 'Cap ($seedCurrency)'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              key: const Key('lending-cap-days'),
              initialValue: _days,
              decoration: const InputDecoration(labelText: 'For'),
              items: [
                for (final d in const [7, 14, 30, 60, 90])
                  DropdownMenuItem(value: d, child: Text('$d days')),
              ],
              onChanged: (v) => setState(() => _days = v ?? _days),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('lending-cap-reason'),
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
          key: const Key('lending-cap-submit'),
          onPressed: valid
              ? () => Navigator.pop(context, (
                  amountMinor: _amountMinor!,
                  days: _days,
                  reason: _reason.text.trim(),
                ))
              : null,
          child: const Text('Set cap'),
        ),
      ],
    );
  }
}
