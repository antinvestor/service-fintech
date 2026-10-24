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
import '../widgets/audit_event_filters.dart';
import '../widgets/audit_event_tile.dart';
import '../widgets/shadow_breach_alert.dart';

class AuditFeedScreen extends ConsumerStatefulWidget {
  const AuditFeedScreen({super.key});

  @override
  ConsumerState<AuditFeedScreen> createState() => _AuditFeedScreenState();
}

class _AuditFeedScreenState extends ConsumerState<AuditFeedScreen> {
  AuditSearchParams _params = const AuditSearchParams();

  /// The cursor of each page the operator has walked back through, so "newer"
  /// can return to where they were.
  final List<String> _pageStack = [];

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(auditSearchProvider(_params));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(auditSearchProvider(_params)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const ShadowBreachAlert(),
          AuditEventFilters(
            params: _params,
            onChanged: (p) => setState(() {
              _params = p;
              _pageStack.clear();
            }),
          ),
          const Divider(height: 24),
          asyncList.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('Failed: $e'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: () =>
                        ref.invalidate(auditSearchProvider(_params)),
                  ),
                ],
              ),
            ),
            data: (events) {
              if (events.isEmpty) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No audit events match.'),
                    ),
                    if (_pageStack.isNotEmpty) _pager(events),
                  ],
                );
              }
              return Column(
                children: [
                  for (final e in events) AuditEventTile(event: e),
                  const SizedBox(height: 12),
                  _pager(events),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _pager(List<dynamic> events) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      TextButton.icon(
        icon: const Icon(Icons.chevron_left),
        label: const Text('Newer'),
        onPressed: _pageStack.isEmpty
            ? null
            : () => setState(() {
                _pageStack.removeLast();
                _params = _params.copyWith(
                  page: _pageStack.isEmpty ? '' : _pageStack.last,
                );
              }),
      ),
      const SizedBox(width: 16),
      TextButton.icon(
        icon: const Icon(Icons.chevron_right),
        label: const Text('Older'),
        onPressed: events.length < auditPageSize
            ? null
            : () => setState(() {
                final lastId = events.last.id as String;
                _pageStack.add(lastId);
                _params = _params.copyWith(page: lastId);
              }),
      ),
    ],
  );
}
