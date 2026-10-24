import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'loans_transport_provider.dart';

/// One page of loan accounts. [limit] is how many rows the caller is willing
/// to hold; the screen raises it to load more. Without it the list stopped at
/// the first fifty accounts with nothing to say so.
typedef LoanAccountListParams = ({
  String query,
  LoanStatus? status,
  String agentId,
  String clientId,
  int limit,
});

final loanAccountListProvider =
    FutureProvider.family<
      PagedResult<LoanAccountObject>,
      LoanAccountListParams
    >((ref, params) async {
      final client = ref.watch(loanManagementServiceClientProvider);
      final request = LoanAccountSearchRequest(
        query: params.query,
        cursor: PageCursor(limit: params.limit),
      );
      if (params.status != null) {
        request.status = params.status!;
      }
      if (params.agentId.isNotEmpty) {
        request.agentId = params.agentId;
      }
      if (params.clientId.isNotEmpty) {
        request.clientId = params.clientId;
      }
      return collectStreamPaged(
        client.loanAccountSearch(request),
        extract: (response) => response.data,
      );
    });

final loanAccountDetailProvider =
    FutureProvider.family<LoanAccountObject, String>((ref, id) async {
      final client = ref.watch(loanManagementServiceClientProvider);
      final response = await client.loanAccountGet(
        LoanAccountGetRequest(id: id),
      );
      return response.data;
    });

final loanBalanceDetailProvider =
    FutureProvider.family<LoanBalanceObject, String>((
      ref,
      loanAccountId,
    ) async {
      final client = ref.watch(loanManagementServiceClientProvider);
      final response = await client.loanBalanceGet(
        LoanBalanceGetRequest(loanAccountId: loanAccountId),
      );
      return response.data;
    });

/// Notifier for loan account mutations. Use via [loanAccountNotifierProvider].
class LoanAccountNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<LoanAccountObject> createFromRequest(String loanRequestId) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(loanManagementServiceClientProvider);
      final response = await client.loanAccountCreate(
        LoanAccountCreateRequest(loanRequestId: loanRequestId),
      );
      state = const AsyncData(null);
      ref.invalidate(loanAccountListProvider);
      return response.data;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final loanAccountNotifierProvider =
    NotifierProvider<LoanAccountNotifier, AsyncValue<void>>(
      LoanAccountNotifier.new,
    );
