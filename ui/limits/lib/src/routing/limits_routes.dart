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

import 'package:go_router/go_router.dart';

import '../screens/approval_queue_screen.dart';
import '../screens/approval_request_detail_screen.dart';
import '../screens/audit_feed_screen.dart';
import '../screens/ledger_search_screen.dart';
import '../screens/policy_detail_screen.dart';
import '../screens/policy_editor_screen.dart';
import '../screens/policy_list_screen.dart';
import '../screens/policy_verdict_playground_screen.dart';

/// Returns the go_router routes for the limits operator surface.
/// Mount via `routes: [...limitsRoutes()]` in the host's GoRouter config.
List<GoRoute> limitsRoutes() => [
  GoRoute(path: '/limits', redirect: (context, state) => '/limits/policies'),
  GoRoute(
    path: '/limits/policies',
    builder: (context, state) => const PolicyListScreen(),
  ),
  GoRoute(
    path: '/limits/policies/new',
    builder: (context, state) => const PolicyEditorScreen(),
  ),
  GoRoute(
    path: '/limits/policies/:id',
    builder: (context, state) =>
        PolicyDetailScreen(policyId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/limits/policies/:id/edit',
    builder: (context, state) =>
        PolicyEditorScreen(policyId: state.pathParameters['id']),
  ),
  GoRoute(
    path: '/limits/playground',
    builder: (context, state) => const PolicyVerdictPlaygroundScreen(),
  ),
  GoRoute(
    path: '/limits/approvals',
    builder: (context, state) => const ApprovalQueueScreen(),
  ),
  GoRoute(
    path: '/limits/approvals/:id',
    builder: (context, state) =>
        ApprovalRequestDetailScreen(requestId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/limits/ledger',
    builder: (context, state) => const LedgerSearchScreen(),
  ),
  GoRoute(
    path: '/limits/audit',
    builder: (context, state) => const AuditFeedScreen(),
  ),
];
