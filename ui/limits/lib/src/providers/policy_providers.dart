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

class PolicySearchParams {
  final String query;
  final LimitAction action;
  final SubjectType subjectType;
  final PolicyMode mode;

  const PolicySearchParams({
    this.query = '',
    this.action = LimitAction.LIMIT_ACTION_UNSPECIFIED,
    this.subjectType = SubjectType.SUBJECT_TYPE_UNSPECIFIED,
    this.mode = PolicyMode.POLICY_MODE_UNSPECIFIED,
  });

  @override
  bool operator ==(Object other) =>
      other is PolicySearchParams &&
      other.query == query &&
      other.action == action &&
      other.subjectType == subjectType &&
      other.mode == mode;

  @override
  int get hashCode => Object.hash(query, action, subjectType, mode);
}

/// How many policies one page holds. The server returns a single page, so
/// this is the ceiling on what the list shows for a given filter.
const int policyPageSize = 200;

/// One page of matching policies. Cached by params for navigation back/forward.
final policyListProvider =
    FutureProvider.family<List<PolicyObject>, PolicySearchParams>((
      ref,
      params,
    ) async {
      final client = ref.watch(limitsAdminServiceClientProvider);
      final request = PolicySearchRequest(
        query: params.query,
        action: params.action,
        subjectType: params.subjectType,
        mode: params.mode,
        cursor: PageCursor(limit: policyPageSize),
      );
      return collectStream(
        client.policySearch(request),
        extract: (response) => response.data,
      );
    });

final policyDetailProvider = FutureProvider.family<PolicyObject, String>((
  ref,
  id,
) async {
  final client = ref.watch(limitsAdminServiceClientProvider);
  final response = await client.policyGet(PolicyGetRequest(id: id));
  return response.data;
});

class PolicyMutationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  LimitsAdminServiceClient get _client =>
      ref.read(limitsAdminServiceClientProvider);

  Future<PolicyObject> save(PolicyObject policy) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.policySave(
        PolicySaveRequest(data: policy),
      );
      state = const AsyncValue.data(null);
      ref.invalidate(policyListProvider);
      if (response.data.id.isNotEmpty) {
        ref.invalidate(policyDetailProvider(response.data.id));
      }
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    try {
      await _client.policyDelete(PolicyDeleteRequest(id: id));
      state = const AsyncValue.data(null);
      ref.invalidate(policyListProvider);
      ref.invalidate(policyDetailProvider(id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final policyMutationProvider =
    NotifierProvider<PolicyMutationNotifier, AsyncValue<void>>(
      PolicyMutationNotifier.new,
    );
