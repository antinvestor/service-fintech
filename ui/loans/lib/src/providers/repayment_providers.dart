import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'loans_transport_provider.dart';

final repaymentListProvider =
    FutureProvider.family<List<RepaymentObject>, String>((
      ref,
      loanAccountId,
    ) async {
      final client = ref.watch(loanManagementServiceClientProvider);
      final request = RepaymentSearchRequest(
        loanAccountId: loanAccountId,
        cursor: PageCursor(limit: 50),
      );
      return collectStream(
        client.repaymentSearch(request),
        extract: (response) => response.data,
      );
    });

/// Repayment channels as the service stores them. Every repayment is a
/// payment the borrower made from their own contact; nobody collects cash.
const kRepaymentChannelMobileMoney = 'mobile_money';
const kRepaymentChannelBank = 'bank';
const kRepaymentChannelSavings = 'savings';

String repaymentChannelLabel(String channel) => switch (channel) {
  kRepaymentChannelMobileMoney => 'Mobile money',
  kRepaymentChannelBank => 'Bank transfer',
  kRepaymentChannelSavings => 'Savings account',
  _ => channel,
};
