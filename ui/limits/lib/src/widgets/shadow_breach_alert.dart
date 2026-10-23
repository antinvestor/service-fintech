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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/audit_providers.dart';

class ShadowBreachAlert extends ConsumerWidget {
  const ShadowBreachAlert({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ask the server for the last 24 hours directly rather than filtering a
    // page client-side: the feed is newest-first and capped, so a client-side
    // window silently reports zero on any busy tenant.
    final since = DateTime.now().subtract(const Duration(hours: 24));
    final async = ref.watch(
      auditSearchProvider(
        AuditSearchParams(actions: const ['limits.breach.shadow'], from: since),
      ),
    );
    final events = async.whenOrNull(data: (e) => e) ?? [];
    final recent = events.length;
    if (recent == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orange.shade400),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$recent${recent == auditPageSize ? '+' : ''} shadow-mode breach '
              'event${recent == 1 ? "" : "s"} '
              'in the last 24 hours. Review for tuning before flipping to enforce.',
              style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
