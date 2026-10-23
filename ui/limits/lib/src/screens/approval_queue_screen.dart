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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/approval_providers.dart';
import '../utils/enum_labels.dart';
import '../widgets/approval_request_tile.dart';

class ApprovalQueueScreen extends ConsumerStatefulWidget {
  const ApprovalQueueScreen({super.key});

  @override
  ConsumerState<ApprovalQueueScreen> createState() =>
      _ApprovalQueueScreenState();
}

class _ApprovalQueueScreenState extends ConsumerState<ApprovalQueueScreen> {
  ApprovalListParams _params = const ApprovalListParams();

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(approvalListProvider(_params));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(approvalListProvider(_params)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<ApprovalStatus>(
                    initialValue: _params.status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      isDense: true,
                    ),
                    items: ApprovalStatus.values
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(approvalStatusLabel(s)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(
                          () => _params = ApprovalListParams(
                            status: v,
                            requiredRole: _params.requiredRole,
                          ),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Required role',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (v) => setState(
                      () => _params = ApprovalListParams(
                        status: _params.status,
                        requiredRole: v,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: asyncList.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Failed: $e'),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: () =>
                          ref.invalidate(approvalListProvider(_params)),
                    ),
                  ],
                ),
              ),
              data: (rows) {
                if (rows.isEmpty) {
                  return const Center(
                    child: Text('No approval requests match.'),
                  );
                }
                return ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (_, i) => ApprovalRequestTile(
                    request: rows[i],
                    onTap: () =>
                        context.push('/limits/approvals/${rows[i].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
