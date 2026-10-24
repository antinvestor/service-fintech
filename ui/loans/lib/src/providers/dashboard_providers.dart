import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'loans_transport_provider.dart';
import 'portfolio_providers.dart';

/// How many rows a counting query asks the service for. A count needs to see
/// every matching row, so the page has to be large: the previous limit of one
/// meant every dashboard tile rendered 0 or 1 regardless of the real figure.
const kLoanCountPageSize = 500;

/// How many pages a count consumes before it stops and reports what it has.
const kLoanCountMaxPages = 40;

Future<int> _countLoanRequests(Ref ref, LoanRequestStatus status) async {
  final client = ref.watch(loanManagementServiceClientProvider);
  final request = LoanRequestSearchRequest(
    cursor: PageCursor(limit: kLoanCountPageSize),
  );
  request.status = status;

  return countStream(
    client.loanRequestSearch(request),
    count: (response) => response.data.length,
    maxPages: kLoanCountMaxPages,
  );
}

Future<int> _countLoanAccounts(Ref ref, LoanStatus status) async {
  final client = ref.watch(loanManagementServiceClientProvider);
  final request = LoanAccountSearchRequest(
    cursor: PageCursor(limit: kLoanCountPageSize),
  );
  request.status = status;

  return countStream(
    client.loanAccountSearch(request),
    count: (response) => response.data.length,
    maxPages: kLoanCountMaxPages,
  );
}

/// Counts loan requests in a given status.
final loanRequestCountByStatusProvider =
    FutureProvider.family<int, LoanRequestStatus>(_countLoanRequests);

/// Counts loan accounts in a given status.
final loanCountByStatusProvider = FutureProvider.family<int, LoanStatus>(
  _countLoanAccounts,
);

/// Convenience providers for specific dashboard metrics.
final pendingApprovalCountProvider = FutureProvider<int>(
  (ref) =>
      _countLoanRequests(ref, LoanRequestStatus.LOAN_REQUEST_STATUS_SUBMITTED),
);

final approvedRequestsCountProvider = FutureProvider<int>(
  (ref) =>
      _countLoanRequests(ref, LoanRequestStatus.LOAN_REQUEST_STATUS_APPROVED),
);

/// Active and delinquent counts come from the portfolio summary, which the
/// service aggregates in one query rather than by streaming every loan.
final activeLoansCountProvider = FutureProvider<int>((ref) async {
  final summary = await ref.watch(
    portfolioSummaryProvider(emptyPortfolioParams).future,
  );
  return summary.data.activeLoans;
});

final delinquentLoansCountProvider = FutureProvider<int>((ref) async {
  final summary = await ref.watch(
    portfolioSummaryProvider(emptyPortfolioParams).future,
  );
  return summary.data.delinquentLoans;
});

final pendingDisbursementCountProvider = FutureProvider<int>(
  (ref) => _countLoanAccounts(ref, LoanStatus.LOAN_STATUS_PENDING_DISBURSEMENT),
);
