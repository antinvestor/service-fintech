import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'loans_transport_provider.dart';

final restructureListProvider =
    FutureProvider.family<List<LoanRestructureObject>, String>((
      ref,
      loanAccountId,
    ) async {
      final client = ref.watch(loanManagementServiceClientProvider);
      final request = LoanRestructureSearchRequest(
        loanAccountId: loanAccountId,
        cursor: PageCursor(limit: 50),
      );
      return collectStream(
        client.loanRestructureSearch(request),
        extract: (response) => response.data,
      );
    });

/// Notifier for restructure mutations.
class RestructureNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<LoanRestructureObject> create(LoanRestructureObject data) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(loanManagementServiceClientProvider);
      final response = await client.loanRestructureCreate(
        LoanRestructureCreateRequest(data: data),
      );
      state = const AsyncData(null);
      ref.invalidate(restructureListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<LoanRestructureObject> approve(String id) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(loanManagementServiceClientProvider);
      final response = await client.loanRestructureApprove(
        LoanRestructureApproveRequest(id: id),
      );
      state = const AsyncData(null);
      ref.invalidate(restructureListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<LoanRestructureObject> reject(String id, String reason) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(loanManagementServiceClientProvider);
      final response = await client.loanRestructureReject(
        LoanRestructureRejectRequest(id: id, reason: reason),
      );
      state = const AsyncData(null);
      ref.invalidate(restructureListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final restructureNotifierProvider =
    NotifierProvider<RestructureNotifier, AsyncValue<void>>(
      RestructureNotifier.new,
    );
