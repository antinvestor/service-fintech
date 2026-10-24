import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'loans_transport_provider.dart';

/// The loan's statement: every disbursement, charge and repayment with the
/// running balance, as the loans service computes it.
final loanStatementProvider =
    FutureProvider.family<LoanStatementResponse, String>((
      ref,
      loanAccountId,
    ) async {
      final client = ref.watch(loanManagementServiceClientProvider);
      return client.loanStatement(
        LoanStatementRequest(loanAccountId: loanAccountId),
      );
    });
