import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'identity_transport_provider.dart';
import 'kyc_requirements_providers.dart';
import 'paged_list.dart';

/// List client data entries for a given client.
final clientDataListProvider =
    FutureProvider.family<List<ClientDataEntryObject>, String>((
      ref,
      clientId,
    ) async {
      final client = ref.watch(identityServiceClientProvider);
      final stream = client.clientDataList(
        ClientDataListRequest(
          clientId: clientId,
          cursor: PageCursor(limit: 50),
        ),
      );
      return collectStream(stream, extract: (response) => response.data);
    });

/// Notifier for client data entry mutations.
class ClientDataNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  IdentityServiceClient get _client => ref.read(identityServiceClientProvider);

  Future<ClientDataEntryObject> save(ClientDataEntryObject entry) async {
    state = const AsyncValue.loading();
    try {
      final resp = await _client.clientDataSave(
        ClientDataSaveRequest(data: entry),
      );
      ref.invalidate(clientDataListProvider);
      ref.invalidate(clientDataPagedListProvider);
      ref.invalidate(clientKycRequirementsProvider);
      state = const AsyncValue.data(null);
      return resp.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// The reviewer is derived from the caller's claims server-side.
  Future<void> verify(String entryId, {String comment = ''}) async {
    state = const AsyncValue.loading();
    try {
      await _client.clientDataVerify(
        ClientDataVerifyRequest(entryId: entryId, comment: comment),
      );
      ref.invalidate(clientDataListProvider);
      ref.invalidate(clientDataPagedListProvider);
      ref.invalidate(clientKycRequirementsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> reject(String entryId, String reason) async {
    state = const AsyncValue.loading();
    try {
      await _client.clientDataReject(
        ClientDataRejectRequest(entryId: entryId, reason: reason),
      );
      ref.invalidate(clientDataListProvider);
      ref.invalidate(clientDataPagedListProvider);
      ref.invalidate(clientKycRequirementsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> requestInfo(String entryId, String comment) async {
    state = const AsyncValue.loading();
    try {
      await _client.clientDataRequestInfo(
        ClientDataRequestInfoRequest(entryId: entryId, comment: comment),
      );
      ref.invalidate(clientDataListProvider);
      ref.invalidate(clientDataPagedListProvider);
      ref.invalidate(clientKycRequirementsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final clientDataNotifierProvider =
    NotifierProvider<ClientDataNotifier, AsyncValue<void>>(
      ClientDataNotifier.new,
    );

/// Get history for a specific client data entry.
final clientDataHistoryProvider =
    FutureProvider.family<List<ClientDataEntryHistoryObject>, String>((
      ref,
      entryId,
    ) async {
      final client = ref.watch(identityServiceClientProvider);
      final resp = await client.clientDataHistory(
        ClientDataHistoryRequest(entryId: entryId),
      );
      return resp.data;
    });

/// A client's data entries, one cursor page at a time.
///
/// ClientDataList streams every remaining page from the cursor's offset, so
/// only the first streamed batch is taken per load; the next load resumes
/// from the offset after it.
class ClientDataPagedList extends PagedListNotifier<ClientDataEntryObject> {
  ClientDataPagedList(this.clientId);

  final String clientId;

  @override
  Future<List<ClientDataEntryObject>> fetchPage(int offset, int limit) {
    final client = ref.read(identityServiceClientProvider);
    return collectStream(
      client.clientDataList(
        ClientDataListRequest(
          clientId: clientId,
          cursor: PageCursor(page: '$offset', limit: limit),
        ),
      ),
      extract: (response) => response.data,
      maxPages: 1,
    );
  }
}

final clientDataPagedListProvider =
    AsyncNotifierProvider.family<
      ClientDataPagedList,
      PagedList<ClientDataEntryObject>,
      String
    >(ClientDataPagedList.new);
