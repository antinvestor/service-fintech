import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'loans_transport_provider.dart';

final repaymentListProvider =
    FutureProvider.family<List<RepaymentObject>, String>(
  (ref, loanAccountId) async {
    final client = ref.watch(loanManagementServiceClientProvider);
    final request = RepaymentSearchRequest(
      loanAccountId: loanAccountId,
      cursor: PageCursor(limit: 50),
    );
    return collectStream(
      client.repaymentSearch(request),
      extract: (response) => response.data,
    );
  },
);

/// Notifier for repayment mutations.
class RepaymentNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<RepaymentObject> record({
    required String loanAccountId,
    required String amount,
    required String currencyCode,
    required String paymentReference,
    required String channel,
    required String payerReference,
    required String idempotencyKey,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(loanManagementServiceClientProvider);
      final req = RepaymentRecordRequest(
        loanAccountId: loanAccountId,
        paymentReference: paymentReference,
        channel: channel,
        payerReference: payerReference,
        idempotencyKey: idempotencyKey,
      );
      setMoneyFields(req.ensureAmount(), amount, currencyCode);
      final response = await client.repaymentRecord(req);
      state = const AsyncData(null);
      ref.invalidate(repaymentListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final repaymentNotifierProvider =
    NotifierProvider<RepaymentNotifier, AsyncValue<void>>(
  RepaymentNotifier.new,
);
