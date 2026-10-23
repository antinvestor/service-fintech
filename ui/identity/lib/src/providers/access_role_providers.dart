import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'identity_transport_provider.dart';

/// Well-known role keys matching the backend constants.
class AccessRoleKeys {
  static const approvalVerifier = 'approval_verifier';
  static const approvalApprover = 'approval_approver';
  static const identityAdministrator = 'identity_administrator';
}

/// Human-readable label for a role key.
String accessRoleLabel(String roleKey) => switch (roleKey) {
  AccessRoleKeys.approvalVerifier => 'Verifier',
  AccessRoleKeys.approvalApprover => 'Approver',
  AccessRoleKeys.identityAdministrator => 'Administrator',
  _ => roleKey,
};

/// All selectable role keys for dropdowns.
const selectableRoleKeys = [
  AccessRoleKeys.approvalVerifier,
  AccessRoleKeys.approvalApprover,
  AccessRoleKeys.identityAdministrator,
];

/// Search access role assignments with optional filters.
typedef AccessRoleAssignmentListParams = ({
  String query,
  String roleKey,
  String scopeId,
});

final accessRoleAssignmentListProvider =
    FutureProvider.family<
      List<AccessRoleAssignmentObject>,
      AccessRoleAssignmentListParams
    >((ref, params) async {
      final client = ref.watch(identityServiceClientProvider);
      final request = AccessRoleAssignmentSearchRequest(
        query: params.query,
        roleKey: params.roleKey,
        scopeId: params.scopeId,
        cursor: PageCursor(limit: 50),
      );

      return collectStream(
        client.accessRoleAssignmentSearch(request),
        extract: (response) => response.data,
      );
    });

/// Notifier for access role assignment mutations.
class AccessRoleAssignmentNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  IdentityServiceClient get _client => ref.read(identityServiceClientProvider);

  Future<AccessRoleAssignmentObject> save(
    AccessRoleAssignmentObject assignment,
  ) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.accessRoleAssignmentSave(
        AccessRoleAssignmentSaveRequest(data: assignment),
      );
      ref.invalidate(accessRoleAssignmentListProvider);
      state = const AsyncValue.data(null);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final accessRoleAssignmentNotifierProvider =
    NotifierProvider<AccessRoleAssignmentNotifier, AsyncValue<void>>(
      AccessRoleAssignmentNotifier.new,
    );
