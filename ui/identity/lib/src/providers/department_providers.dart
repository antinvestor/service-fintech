import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'identity_transport_provider.dart';

// ---------------------------------------------------------------------------
// Department providers
// ---------------------------------------------------------------------------

typedef DepartmentListParams = ({
  String query,
  String organizationId,
  String parentId,
  DepartmentKind kind,
});

final departmentListProvider =
    FutureProvider.family<List<DepartmentObject>, DepartmentListParams>((
      ref,
      params,
    ) async {
      final client = ref.watch(identityServiceClientProvider);
      final request = DepartmentSearchRequest(
        query: params.query,
        organizationId: params.organizationId,
        cursor: PageCursor(limit: 50),
      );
      if (params.parentId.isNotEmpty) request.parentId = params.parentId;
      if (params.kind != DepartmentKind.DEPARTMENT_KIND_UNSPECIFIED) {
        request.kind = params.kind;
      }
      return collectStream(
        client.departmentSearch(request),
        extract: (response) => response.data,
      );
    });

class DepartmentNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<DepartmentObject> save(DepartmentObject department) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(identityServiceClientProvider);
      final response = await client.departmentSave(
        DepartmentSaveRequest(data: department),
      );
      ref.invalidate(departmentListProvider);
      state = const AsyncValue.data(null);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final departmentNotifierProvider =
    NotifierProvider<DepartmentNotifier, AsyncValue<void>>(
      DepartmentNotifier.new,
    );

// ---------------------------------------------------------------------------
// Position providers
// ---------------------------------------------------------------------------

typedef PositionListParams = ({
  String query,
  String organizationId,
  String orgUnitId,
  String departmentId,
  String reportsToPositionId,
});

final positionListProvider =
    FutureProvider.family<List<PositionObject>, PositionListParams>((
      ref,
      params,
    ) async {
      final client = ref.watch(identityServiceClientProvider);
      final request = PositionSearchRequest(
        query: params.query,
        organizationId: params.organizationId,
        cursor: PageCursor(limit: 50),
      );
      if (params.orgUnitId.isNotEmpty) request.orgUnitId = params.orgUnitId;
      if (params.departmentId.isNotEmpty) {
        request.departmentId = params.departmentId;
      }
      if (params.reportsToPositionId.isNotEmpty) {
        request.reportsToPositionId = params.reportsToPositionId;
      }
      return collectStream(
        client.positionSearch(request),
        extract: (response) => response.data,
      );
    });

class PositionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<PositionObject> save(PositionObject position) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(identityServiceClientProvider);
      final response = await client.positionSave(
        PositionSaveRequest(data: position),
      );
      ref.invalidate(positionListProvider);
      state = const AsyncValue.data(null);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final positionNotifierProvider =
    NotifierProvider<PositionNotifier, AsyncValue<void>>(PositionNotifier.new);

// ---------------------------------------------------------------------------
// Position assignment providers
// ---------------------------------------------------------------------------

typedef PositionAssignmentListParams = ({String memberId, String positionId});

final positionAssignmentListProvider =
    FutureProvider.family<
      List<PositionAssignmentObject>,
      PositionAssignmentListParams
    >((ref, params) async {
      final client = ref.watch(identityServiceClientProvider);
      final request = PositionAssignmentSearchRequest(
        cursor: PageCursor(limit: 50),
      );
      if (params.memberId.isNotEmpty) request.memberId = params.memberId;
      if (params.positionId.isNotEmpty) request.positionId = params.positionId;
      return collectStream(
        client.positionAssignmentSearch(request),
        extract: (response) => response.data,
      );
    });

class PositionAssignmentNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<PositionAssignmentObject> save(
    PositionAssignmentObject assignment,
  ) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(identityServiceClientProvider);
      final response = await client.positionAssignmentSave(
        PositionAssignmentSaveRequest(data: assignment),
      );
      ref.invalidate(positionAssignmentListProvider);
      state = const AsyncValue.data(null);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final positionAssignmentNotifierProvider =
    NotifierProvider<PositionAssignmentNotifier, AsyncValue<void>>(
      PositionAssignmentNotifier.new,
    );

/// Load a single department by id.
final departmentByIdProvider = FutureProvider.family<DepartmentObject, String>((
  ref,
  id,
) async {
  final client = ref.watch(identityServiceClientProvider);
  final response = await client.departmentGet(DepartmentGetRequest(id: id));
  return response.data;
});
