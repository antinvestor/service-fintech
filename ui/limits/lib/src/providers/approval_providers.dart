// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:antinvestor_api_limits/antinvestor_api_limits.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'limits_transport_provider.dart';

class ApprovalListParams {
  final ApprovalStatus status;
  final String requiredRole;

  const ApprovalListParams({
    this.status = ApprovalStatus.APPROVAL_STATUS_PENDING,
    this.requiredRole = '',
  });

  @override
  bool operator ==(Object other) =>
      other is ApprovalListParams &&
      other.status == status &&
      other.requiredRole == requiredRole;

  @override
  int get hashCode => Object.hash(status, requiredRole);
}

final approvalListProvider =
    FutureProvider.family<List<ApprovalRequestObject>, ApprovalListParams>((
      ref,
      params,
    ) async {
      final client = ref.watch(limitsAdminServiceClientProvider);
      final request = ApprovalRequestListRequest(
        status: params.status,
        requiredRole: params.requiredRole,
        cursor: PageCursor(limit: 50),
      );
      return collectStream(
        client.approvalRequestList(request),
        extract: (response) => response.data,
      );
    });

final approvalDetailProvider =
    FutureProvider.family<ApprovalRequestObject, String>((ref, id) async {
      final client = ref.watch(limitsAdminServiceClientProvider);
      final response = await client.approvalRequestGet(
        ApprovalRequestGetRequest(id: id),
      );
      return response.data;
    });

class ApprovalDecisionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  LimitsAdminServiceClient get _client =>
      ref.read(limitsAdminServiceClientProvider);

  Future<ApprovalRequestObject> decide({
    required String id,
    required String decision, // 'approve' | 'reject'
    required String note,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.approvalRequestDecide(
        ApprovalRequestDecideRequest(id: id, decision: decision, note: note),
      );
      state = const AsyncValue.data(null);
      ref.invalidate(approvalListProvider);
      ref.invalidate(approvalDetailProvider(id));
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final approvalDecisionProvider =
    NotifierProvider<ApprovalDecisionNotifier, AsyncValue<void>>(
      ApprovalDecisionNotifier.new,
    );
