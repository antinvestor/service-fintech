import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
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

/// The repayments the signed-in field agent recorded since local midnight.
/// The service scopes a loan-less search to the caller's own collections.
final myCollectionsTodayProvider = FutureProvider<List<RepaymentObject>>((
  ref,
) async {
  final client = ref.watch(loanManagementServiceClientProvider);
  final now = DateTime.now();
  final midnight = DateTime(now.year, now.month, now.day).toUtc();
  return collectStream(
    client.repaymentSearch(
      RepaymentSearchRequest(
        receivedAfter: midnight.toIso8601String(),
        cursor: PageCursor(limit: 200),
      ),
    ),
    extract: (response) => response.data,
  );
});

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
      ref.invalidate(myCollectionsTodayProvider);
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

/// Repayment channel values the service accepts, as sent on the wire.
const kRepaymentChannelCash = 'cash';
const kRepaymentChannelMobileMoney = 'mobile_money';
const kRepaymentChannelBank = 'bank';
const kRepaymentChannelSavings = 'savings';

const kRepaymentChannels = [
  kRepaymentChannelCash,
  kRepaymentChannelMobileMoney,
  kRepaymentChannelBank,
  kRepaymentChannelSavings,
];

/// Shown under the channel picker when cash is chosen: the collecting agent
/// carries the cash on their own float until it is remitted.
const kCashCollectionNote =
    'Cash is booked against the collecting agent until it is remitted.';

String repaymentChannelLabel(String channel) => switch (channel) {
  kRepaymentChannelCash => 'Cash collected in the field',
  kRepaymentChannelMobileMoney => 'Mobile money',
  kRepaymentChannelBank => 'Bank transfer',
  kRepaymentChannelSavings => 'Savings account',
  _ => channel,
};
