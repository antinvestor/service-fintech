import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'loans_transport_provider.dart';

final penaltyListProvider = FutureProvider.family<List<PenaltyObject>, String>((
  ref,
  loanAccountId,
) async {
  final client = ref.watch(loanManagementServiceClientProvider);
  final request = PenaltySearchRequest(
    loanAccountId: loanAccountId,
    cursor: PageCursor(limit: 50),
  );
  return collectStream(
    client.penaltySearch(request),
    extract: (response) => response.data,
  );
});

/// Notifier for penalty mutations.
class PenaltyNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<PenaltyObject> save(PenaltyObject penalty) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(loanManagementServiceClientProvider);
      final response = await client.penaltySave(
        PenaltySaveRequest(data: penalty),
      );
      state = const AsyncData(null);
      ref.invalidate(penaltyListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<PenaltyObject> waive({
    required String id,
    required String reason,
    String? waivedBy,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(loanManagementServiceClientProvider);
      final response = await client.penaltyWaive(
        PenaltyWaiveRequest(id: id, reason: reason),
      );
      if (waivedBy != null && waivedBy.isNotEmpty) {
        final penalty = response.data;
        penalty.waivedBy = waivedBy;
        await client.penaltySave(PenaltySaveRequest(data: penalty));
      }
      state = const AsyncData(null);
      ref.invalidate(penaltyListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final penaltyNotifierProvider =
    NotifierProvider<PenaltyNotifier, AsyncValue<void>>(PenaltyNotifier.new);
