import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'loans_transport_provider.dart';

final disbursementListProvider =
    FutureProvider.family<List<DisbursementObject>, String>((
      ref,
      loanAccountId,
    ) async {
      final client = ref.watch(loanManagementServiceClientProvider);
      final request = DisbursementSearchRequest(
        loanAccountId: loanAccountId,
        cursor: PageCursor(limit: 50),
      );
      return collectStream(
        client.disbursementSearch(request),
        extract: (response) => response.data,
      );
    });

/// Notifier for disbursement mutations.
class DisbursementNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<DisbursementObject> create({
    required String loanAccountId,
    required String channel,
    required String recipientReference,
    required String idempotencyKey,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(loanManagementServiceClientProvider);
      final response = await client.disbursementCreate(
        DisbursementCreateRequest(
          loanAccountId: loanAccountId,
          channel: channel,
          recipientReference: recipientReference,
          idempotencyKey: idempotencyKey,
        ),
      );
      state = const AsyncData(null);
      ref.invalidate(disbursementListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final disbursementNotifierProvider =
    NotifierProvider<DisbursementNotifier, AsyncValue<void>>(
      DisbursementNotifier.new,
    );
