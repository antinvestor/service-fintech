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
/// may suspend, block or reinstate borrowing, always with a reason.
class LendingTab extends ConsumerWidget {
  const LendingTab({super.key, required this.clientId, this.canAdmin = false});

  final String clientId;
  final bool canAdmin;

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
  });

  final String clientId;
  final CreditProfile profile;
  final bool canAdmin;

  Future<void> _change(
    BuildContext context,
    WidgetRef ref,
    CreditProfileAction action,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ReasonDialog(action: action),
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
                  formatMinor(profile.maxLoanAmountMinor, seedCurrency),
                ),
                _Fact('Loans repaid', '${profile.successfulRepayments}'),
                _Fact('Loans running', '${profile.outstandingLoanCount}'),
              ],
            ),
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
  const _ReasonDialog({required this.action});
  final CreditProfileAction action;

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

  String get _title => switch (widget.action) {
    CreditProfileAction.suspend => 'Suspend borrowing',
    CreditProfileAction.block => 'Block borrowing',
    CreditProfileAction.reinstate => 'Reinstate borrowing',
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_title),
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
