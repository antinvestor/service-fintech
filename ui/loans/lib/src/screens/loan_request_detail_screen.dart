import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import '../utils/money_compat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/loan_request_providers.dart';
import '../widgets/loan_request_status_badge.dart';

class LoanRequestDetailScreen extends ConsumerWidget {
  const LoanRequestDetailScreen({
    super.key,
    required this.requestId,
    this.canManage = false,
  });

  final String requestId;

  /// Whether the caller may approve or reject the request
  /// (`loan_request_manage`). Without it the decision buttons are not shown
  /// at all rather than offered and refused by the service.
  final bool canManage;

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
              request.status == LoanRequestStatus.LOAN_REQUEST_STATUS_SUBMITTED)
            _buildActions(context, ref, request),
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
