import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:flutter/material.dart';

/// Displays a colored badge for loan request status.
class LoanRequestStatusBadge extends StatelessWidget {
  const LoanRequestStatusBadge({super.key, required this.status});

  final LoanRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _statusInfo(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  static (String, Color) _statusInfo(LoanRequestStatus status) {
    return switch (status) {
      LoanRequestStatus.LOAN_REQUEST_STATUS_DRAFT => ('Draft', Colors.grey),
      LoanRequestStatus.LOAN_REQUEST_STATUS_SUBMITTED => (
        'Submitted',
        Colors.blue,
      ),
      LoanRequestStatus.LOAN_REQUEST_STATUS_APPROVED => (
        'Approved',
        Colors.green,
      ),
      LoanRequestStatus.LOAN_REQUEST_STATUS_REJECTED => (
        'Rejected',
        Colors.red,
      ),
      LoanRequestStatus.LOAN_REQUEST_STATUS_CANCELLED => (
        'Cancelled',
        Colors.red,
      ),
      LoanRequestStatus.LOAN_REQUEST_STATUS_EXPIRED => ('Expired', Colors.red),
      LoanRequestStatus.LOAN_REQUEST_STATUS_LOAN_CREATED => (
        'Loan Created',
        Colors.green,
      ),
      _ => ('Unknown', Colors.grey),
    };
  }
}

/// Returns a human-readable label for a LoanRequestStatus.
String loanRequestStatusLabel(LoanRequestStatus status) {
  return switch (status) {
    LoanRequestStatus.LOAN_REQUEST_STATUS_DRAFT => 'Draft',
    LoanRequestStatus.LOAN_REQUEST_STATUS_SUBMITTED => 'Submitted',
    LoanRequestStatus.LOAN_REQUEST_STATUS_APPROVED => 'Approved',
    LoanRequestStatus.LOAN_REQUEST_STATUS_REJECTED => 'Rejected',
    LoanRequestStatus.LOAN_REQUEST_STATUS_CANCELLED => 'Cancelled',
    LoanRequestStatus.LOAN_REQUEST_STATUS_EXPIRED => 'Expired',
    LoanRequestStatus.LOAN_REQUEST_STATUS_LOAN_CREATED => 'Loan Created',
    _ => 'Unknown',
  };
}
