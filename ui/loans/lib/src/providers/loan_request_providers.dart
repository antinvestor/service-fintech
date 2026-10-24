import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'loans_transport_provider.dart';

typedef LoanRequestListParams = ({
  String query,
  int? statusFilter,
  String? sourceService,
  int limit,
});

final loanRequestListProvider =
    FutureProvider.family<
      PagedResult<LoanRequestObject>,
      LoanRequestListParams
    >((ref, params) async {
      final client = ref.watch(loanManagementServiceClientProvider);
      final request = LoanRequestSearchRequest(
        query: params.query,
        cursor: PageCursor(limit: params.limit),
      );
      if (params.statusFilter != null && params.statusFilter! > 0) {
        request.status = LoanRequestStatus.valueOf(params.statusFilter!)!;
      }
      if (params.sourceService != null && params.sourceService!.isNotEmpty) {
        request.sourceService = params.sourceService!;
      }
      return collectStreamPaged(
        client.loanRequestSearch(request),
        extract: (response) => response.data,
      );
    });

final loanRequestDetailProvider =
    FutureProvider.family<LoanRequestObject, String>((ref, requestId) async {
      final client = ref.watch(loanManagementServiceClientProvider);
      final response = await client.loanRequestGet(
        LoanRequestGetRequest(id: requestId),
      );
      return response.data;
    });

/// Notifier for loan request mutations.
class LoanRequestNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<LoanRequestObject> save(LoanRequestObject request) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(loanManagementServiceClientProvider);
      final response = await client.loanRequestSave(
        LoanRequestSaveRequest(data: request),
      );
      state = const AsyncData(null);
      ref.invalidate(loanRequestListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<LoanRequestObject> approve(String id) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(loanManagementServiceClientProvider);
      final response = await client.loanRequestApprove(
        LoanRequestApproveRequest(id: id),
      );
      state = const AsyncData(null);
      ref.invalidate(loanRequestListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<LoanRequestObject> reject(String id, String reason) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(loanManagementServiceClientProvider);
      final response = await client.loanRequestReject(
        LoanRequestRejectRequest(id: id, reason: reason),
      );
      state = const AsyncData(null);
      ref.invalidate(loanRequestListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<LoanRequestObject> cancel(String id, String reason) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(loanManagementServiceClientProvider);
      final response = await client.loanRequestCancel(
        LoanRequestCancelRequest(id: id, reason: reason),
      );
      state = const AsyncData(null);
      ref.invalidate(loanRequestListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final loanRequestNotifierProvider =
    NotifierProvider<LoanRequestNotifier, AsyncValue<void>>(
      LoanRequestNotifier.new,
    );
