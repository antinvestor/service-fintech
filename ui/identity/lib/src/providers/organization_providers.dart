import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'identity_transport_provider.dart';
import 'paged_list.dart';

/// Search organizations by query string.
final organizationListProvider =
    FutureProvider.family<List<OrganizationObject>, String>((ref, query) async {
      final client = ref.watch(identityServiceClientProvider);
      final request = SearchRequest(
        query: query,
        cursor: PageCursor(limit: 50),
      );
      return collectStream(
        client.organizationSearch(request),
        extract: (response) => response.data,
      );
    });

/// Parameters for filtered organization search.
typedef OrganizationSearchParams = ({String query, String parentId});

/// Search organizations with extras filter (e.g. parent_id).
final filteredOrganizationListProvider =
    FutureProvider.family<List<OrganizationObject>, OrganizationSearchParams>((
      ref,
      params,
    ) async {
      final client = ref.watch(identityServiceClientProvider);
      final extras = <String, Value>{};
      if (params.parentId.isNotEmpty) {
        extras['parent_id'] = Value(stringValue: params.parentId);
      }
      final request = SearchRequest(
        query: params.query,
        cursor: PageCursor(limit: 50),
        extras: extras.isNotEmpty ? Struct(fields: extras) : null,
      );
      return collectStream(
        client.organizationSearch(request),
        extract: (response) => response.data,
      );
    });

/// Notifier for organization mutations (create, update).
class OrganizationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  IdentityServiceClient get _client => ref.read(identityServiceClientProvider);

  Future<OrganizationObject> save(OrganizationObject organization) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.organizationSave(
        OrganizationSaveRequest(data: organization),
      );
      ref.invalidate(organizationListProvider);
      ref.invalidate(organizationPagedListProvider);
      state = const AsyncValue.data(null);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final organizationNotifierProvider =
    NotifierProvider<OrganizationNotifier, AsyncValue<void>>(
      OrganizationNotifier.new,
    );

/// Load a single organization by id. Detail screens watch this instead of
/// building a Future in build(), which would refire the RPC on every rebuild.
final organizationByIdProvider =
    FutureProvider.family<OrganizationObject, String>((ref, id) async {
      final client = ref.watch(identityServiceClientProvider);
      final response = await client.organizationGet(
        OrganizationGetRequest(id: id),
      );
      return response.data;
    });

/// Organizations matching a query, one cursor page at a time. The list screen
/// watches this and appends through [PagedListNotifier.loadMore]; pickers that
/// need every organization keep using [organizationListProvider].
class OrganizationPagedList extends PagedListNotifier<OrganizationObject> {
  OrganizationPagedList(this.query);

  final String query;

  @override
  Future<List<OrganizationObject>> fetchPage(int offset, int limit) {
    final client = ref.read(identityServiceClientProvider);
    return collectStream(
      client.organizationSearch(
        SearchRequest(
          query: query,
          cursor: PageCursor(page: '$offset', limit: limit),
        ),
      ),
      extract: (response) => response.data,
    );
  }
}

final organizationPagedListProvider =
    AsyncNotifierProvider.family<
      OrganizationPagedList,
      PagedList<OrganizationObject>,
      String
    >(OrganizationPagedList.new);
