import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import '../utils/money_compat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/loan_account_providers.dart';
import '../providers/loan_request_providers.dart';
import '../widgets/loan_request_status_badge.dart';

class LoanRequestDetailScreen extends ConsumerWidget {
  const LoanRequestDetailScreen({
    super.key,
    required this.requestId,
    this.canManage = false,
    this.canOpenAccount = false,
  });

  final String requestId;

  /// Whether the caller may approve or reject the request
  /// (`loan_request_manage`). Without it the decision buttons are not shown
  /// at all rather than offered and refused by the service.
  final bool canManage;

  /// Whether the caller may open the loan account for an approved request
  /// (`loan_manage`).
  final bool canOpenAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestAsync = ref.watch(loanRequestDetailProvider(requestId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Loan Request')),
      body: requestAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (request) => _buildDetail(context, ref, theme, request),
      ),
    );
  }

  Widget _buildDetail(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    LoanRequestObject request,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LoanRequestStatusBadge(status: request.status),
              const Spacer(),
              if (request.sourceService.isNotEmpty)
                Chip(label: Text('Source: ${request.sourceService}')),
            ],
          ),
          const SizedBox(height: 24),
          _sectionHeader(theme, 'Client'),
          _infoRow('Client ID', Text(request.clientId)),
          if (request.agentId.isNotEmpty)
            _infoRow('Agent ID', Text(request.agentId)),
          if (request.organizationId.isNotEmpty)
            _infoRow('Organization', Text(request.organizationId)),
          const Divider(height: 32),
          _sectionHeader(theme, 'Loan Terms'),
          _infoRow(
            'Requested Amount',
            Text(formatLoanMoney(request.requestedAmount)),
          ),
          _infoRow('Requested Term', Text('${request.requestedTermDays} days')),
          if (request.approvedAmount.units > 0 ||
              request.approvedAmount.nanos > 0)
            _infoRow(
              'Approved Amount',
              Text(formatLoanMoney(request.approvedAmount)),
            ),
          if (request.approvedTermDays > 0)
            _infoRow('Approved Term', Text('${request.approvedTermDays} days')),
          if (request.interestRate.isNotEmpty)
            _infoRow('Interest Rate', Text('${request.interestRate}%')),
          if (request.purpose.isNotEmpty)
            _infoRow('Purpose', Text(request.purpose)),
          const Divider(height: 32),
          _sectionHeader(theme, 'Timeline'),
          if (request.submittedAt.isNotEmpty)
            _infoRow('Submitted', Text(request.submittedAt)),
          if (request.decidedAt.isNotEmpty)
            _infoRow('Decided', Text(request.decidedAt)),
          if (request.rejectionReason.isNotEmpty)
            _infoRow('Rejection Reason', Text(request.rejectionReason)),
          if (request.loanAccountId.isNotEmpty) ...[
            const Divider(height: 32),
            _infoRow('Loan Account', Text(request.loanAccountId)),
          ],
          const SizedBox(height: 24),
          if (canManage &&
              request.status ==
                  LoanRequestStatus.LOAN_REQUEST_STATUS_SUBMITTED) ...[
            SwitchListTile(
              key: const Key('loan-request-kyc-verified'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Client data verified'),
              subtitle: const Text(
                'Confirm the client\'s KYC forms were checked. Products that '
                'require verification cannot be approved without it.',
              ),
              value: dataVerified(request),
              onChanged: (v) => _setDataVerified(context, ref, request, v),
            ),
            const SizedBox(height: 12),
            _buildActions(context, ref, request),
          ],
          if (canOpenAccount &&
              request.status ==
                  LoanRequestStatus.LOAN_REQUEST_STATUS_APPROVED &&
              request.loanAccountId.isEmpty)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('loan-request-open-account'),
                onPressed: () => _openAccount(context, ref, request.id),
                icon: const Icon(Icons.account_balance_wallet_outlined),
                label: const Text('Open loan account'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    LoanRequestObject request,
  ) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _approve(context, ref, request.id),
            icon: const Icon(Icons.check),
            label: const Text('Approve'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _reject(context, ref, request.id),
            icon: const Icon(Icons.close),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
        ),
      ],
    );
  }

  /// Whether staff confirmed the client's data on this request.
  static bool dataVerified(LoanRequestObject request) =>
      request.hasProperties() &&
      (request.properties.fields['data_verification_confirmed']?.boolValue ??
          false);

  Future<void> _setDataVerified(
    BuildContext context,
    WidgetRef ref,
    LoanRequestObject request,
    bool verified,
  ) async {
    final updated = request.deepCopy();
    updated.ensureProperties().fields['data_verification_confirmed'] = Value(
      boolValue: verified,
    );
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(loanRequestNotifierProvider.notifier).save(updated);
      ref.invalidate(loanRequestDetailProvider(request.id));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not update the request: $e')),
      );
    }
  }

  Future<void> _openAccount(
    BuildContext context,
    WidgetRef ref,
    String requestId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.maybeOf(context);
    try {
      final account = await ref
          .read(loanAccountNotifierProvider.notifier)
          .createFromRequest(requestId);
      ref.invalidate(loanRequestDetailProvider(requestId));
      messenger.showSnackBar(
        const SnackBar(content: Text('Loan account opened')),
      );
      router?.go('/loans/${account.id}');
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not open the loan account: $e')),
      );
    }
  }

  Future<void> _approve(BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(loanRequestNotifierProvider.notifier).approve(id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Loan request approved')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to approve: $e')));
      }
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref, String id) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Reject Loan Request'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Reason'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
    if (reason == null || reason.isEmpty) return;
    try {
      await ref.read(loanRequestNotifierProvider.notifier).reject(id, reason);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Loan request rejected')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to reject: $e')));
      }
    }
  }

  Widget _sectionHeader(ThemeData theme, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: theme.textTheme.titleMedium),
  );

  Widget _infoRow(String label, Widget value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(color: Colors.grey)),
        ),
        Expanded(child: value),
      ],
    ),
  );
}
