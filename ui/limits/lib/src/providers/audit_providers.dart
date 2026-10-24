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

/// How many audit events one page holds. The server orders newest-first and
/// returns a single page, so this is what the feed actually shows.
const int auditPageSize = 100;

class AuditSearchParams {
  final List<String> actions;
  final String entityType;
  final String entityId;
  final String actorId;

  /// Inclusive lower bound on occurred_at.
  final DateTime? from;

  /// Exclusive upper bound on occurred_at.
  final DateTime? to;

  /// Keyset cursor: the id of the last event of the previous page.
  final String page;

  const AuditSearchParams({
    this.actions = const [],
    this.entityType = '',
    this.entityId = '',
    this.actorId = '',
    this.from,
    this.to,
    this.page = '',
  });

  AuditSearchParams copyWith({
    List<String>? actions,
    String? entityType,
    String? entityId,
    String? actorId,
    DateTime? from,
    DateTime? to,
    String? page,
    bool clearFrom = false,
    bool clearTo = false,
  }) => AuditSearchParams(
    actions: actions ?? this.actions,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    actorId: actorId ?? this.actorId,
    from: clearFrom ? null : (from ?? this.from),
    to: clearTo ? null : (to ?? this.to),
    page: page ?? this.page,
  );

  @override
  bool operator ==(Object other) =>
      other is AuditSearchParams &&
      _listEquals(other.actions, actions) &&
      other.entityType == entityType &&
      other.entityId == entityId &&
      other.actorId == actorId &&
      other.from == from &&
      other.to == to &&
      other.page == page;

  @override
  int get hashCode => Object.hashAll([
    ...actions,
    entityType,
    entityId,
    actorId,
    from,
    to,
    page,
  ]);
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// One page of audit events, newest first. The server orders by id descending
/// and returns a single page; the feed asks for the next page by passing the
/// last id it saw, rather than draining the whole table.
final auditSearchProvider =
    FutureProvider.family<List<LimitsAuditEventObject>, AuditSearchParams>((
      ref,
      params,
    ) async {
      final client = ref.watch(limitsAdminServiceClientProvider);
      final request = LimitsAuditSearchRequest(
        actions: params.actions,
        entityType: params.entityType,
        entityId: params.entityId,
        actorId: params.actorId,
        cursor: PageCursor(limit: auditPageSize, page: params.page),
      );
      if (params.from != null) {
        request.from = Timestamp.fromDateTime(params.from!.toUtc());
      }
      if (params.to != null) {
        request.to = Timestamp.fromDateTime(params.to!.toUtc());
      }
      return collectStream(
        client.limitsAuditSearch(request),
        extract: (response) => response.data,
      );
    });
