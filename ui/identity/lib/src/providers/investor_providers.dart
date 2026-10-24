import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'identity_transport_provider.dart';

/// Search investors by query.
final investorListProvider =
    FutureProvider.family<List<InvestorObject>, String>((ref, query) async {
      final client = ref.watch(identityServiceClientProvider);
      final stream = client.investorSearch(
        InvestorSearchRequest(query: query, cursor: PageCursor(limit: 50)),
      );
      return collectStream(stream, extract: (response) => response.data);
    });

/// Notifier for investor mutations.
class InvestorNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  IdentityServiceClient get _client => ref.read(identityServiceClientProvider);

  Future<InvestorObject> save(InvestorObject investor) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.investorSave(
        InvestorSaveRequest(data: investor),
      );
      ref.invalidate(investorListProvider);
      state = const AsyncValue.data(null);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final investorNotifierProvider =
    NotifierProvider<InvestorNotifier, AsyncValue<void>>(InvestorNotifier.new);
