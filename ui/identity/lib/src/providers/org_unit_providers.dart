import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'identity_transport_provider.dart';
import 'paged_list.dart';

/// Search org units with optional filters.
///
/// Use named parameters via a record key:
/// ```dart
/// ref.watch(orgUnitListProvider((
///   query: '',
///   organizationId: 'abc',
///   parentId: '',
///   rootOnly: false,
///   type: OrgUnitType.ORG_UNIT_TYPE_UNSPECIFIED,
/// )));
/// ```
typedef OrgUnitListParams = ({
  String query,
  String organizationId,
  String parentId,
  bool rootOnly,
  OrgUnitType type,
});

final orgUnitListProvider =
    FutureProvider.family<List<OrgUnitObject>, OrgUnitListParams>((
      ref,
      params,
    ) async {
      final client = ref.watch(identityServiceClientProvider);
      final stream = client.orgUnitSearch(
        OrgUnitSearchRequest(
          query: params.query,
          organizationId: params.organizationId,
          parentId: params.parentId,
          rootOnly: params.rootOnly,
          type: params.type,
          cursor: PageCursor(limit: 50),
        ),
      );
      return collectStream(stream, extract: (response) => response.data);
    });

/// Notifier for org unit mutations.
class OrgUnitNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  IdentityServiceClient get _client => ref.read(identityServiceClientProvider);

  Future<void> save(OrgUnitObject orgUnit) async {
    state = const AsyncValue.loading();
    try {
      await _client.orgUnitSave(OrgUnitSaveRequest(data: orgUnit));
      ref.invalidate(orgUnitListProvider);
      ref.invalidate(orgUnitPagedListProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final orgUnitNotifierProvider =
    NotifierProvider<OrgUnitNotifier, AsyncValue<void>>(OrgUnitNotifier.new);

/// Load a single org unit by id.
final orgUnitByIdProvider = FutureProvider.family<OrgUnitObject, String>((
  ref,
  id,
) async {
  final client = ref.watch(identityServiceClientProvider);
  final response = await client.orgUnitGet(OrgUnitGetRequest(id: id));
  return response.data;
});

/// Org units matching [params], one cursor page at a time.
class OrgUnitPagedList extends PagedListNotifier<OrgUnitObject> {
  OrgUnitPagedList(this.params);

  final OrgUnitListParams params;

  @override
  Future<List<OrgUnitObject>> fetchPage(int offset, int limit) {
    final client = ref.read(identityServiceClientProvider);
    return collectStream(
      client.orgUnitSearch(
        OrgUnitSearchRequest(
          query: params.query,
          organizationId: params.organizationId,
          parentId: params.parentId,
          rootOnly: params.rootOnly,
          type: params.type,
          cursor: PageCursor(page: '$offset', limit: limit),
        ),
      ),
      extract: (response) => response.data,
    );
  }
}

final orgUnitPagedListProvider =
    AsyncNotifierProvider.family<
      OrgUnitPagedList,
      PagedList<OrgUnitObject>,
      OrgUnitListParams
    >(OrgUnitPagedList.new);
