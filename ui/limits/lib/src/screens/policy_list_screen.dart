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

import '../capabilities.dart';
import '../providers/policy_providers.dart';
import '../utils/enum_labels.dart';
import '../widgets/policy_list_tile.dart';

class PolicyListScreen extends ConsumerStatefulWidget {
  const PolicyListScreen({super.key});

  @override
  ConsumerState<PolicyListScreen> createState() => _PolicyListScreenState();
}

class _PolicyListScreenState extends ConsumerState<PolicyListScreen> {
  PolicySearchParams _params = const PolicySearchParams();

  void _setAction(LimitAction a) {
    setState(
      () => _params = PolicySearchParams(
        query: _params.query,
        action: a,
        subjectType: _params.subjectType,
        mode: _params.mode,
      ),
    );
  }

  void _setMode(PolicyMode m) {
    setState(
      () => _params = PolicySearchParams(
        query: _params.query,
        action: _params.action,
        subjectType: _params.subjectType,
        mode: m,
      ),
    );
  }

  void _setSubject(SubjectType s) {
    setState(
      () => _params = PolicySearchParams(
        query: _params.query,
        action: _params.action,
        subjectType: s,
        mode: _params.mode,
      ),
    );
  }

  void _setQuery(String q) {
    setState(
      () => _params = PolicySearchParams(
        query: q,
        action: _params.action,
        subjectType: _params.subjectType,
        mode: _params.mode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(policyListProvider(_params));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Policies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(policyListProvider(_params)),
          ),
        ],
      ),
      floatingActionButton: ref.watch(limitsCapabilitiesProvider).policyManage
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/limits/policies/new'),
              icon: const Icon(Icons.add),
              label: const Text('New policy'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by notes',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: _setQuery,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _actionDropdown(),
                    _subjectDropdown(),
                    _modeDropdown(),
                  ],
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
                          ref.invalidate(policyListProvider(_params)),
                    ),
                  ],
                ),
              ),
              data: (policies) {
                if (policies.isEmpty) {
                  return const Center(
                    child: Text('No policies match. Click + to create one.'),
                  );
                }
                return ListView.builder(
                  itemCount:
                      policies.length +
                      (policies.length < policyPageSize ? 0 : 1),
                  itemBuilder: (_, i) => i == policies.length
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Showing the first $policyPageSize policies. '
                            'Narrow the filters to see the rest.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        )
                      : PolicyListTile(
                          policy: policies[i],
                          onTap: () => context.push(
                            '/limits/policies/${policies[i].id}',
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionDropdown() => SizedBox(
    width: 220,
    child: DropdownButtonFormField<LimitAction>(
      initialValue: _params.action,
      decoration: const InputDecoration(labelText: 'Action', isDense: true),
      items: LimitAction.values
          .map(
            (a) => DropdownMenuItem(value: a, child: Text(limitActionLabel(a))),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) _setAction(v);
      },
    ),
  );

  Widget _subjectDropdown() => SizedBox(
    width: 200,
    child: DropdownButtonFormField<SubjectType>(
      initialValue: _params.subjectType,
      decoration: const InputDecoration(labelText: 'Subject', isDense: true),
      items: SubjectType.values
          .map(
            (s) => DropdownMenuItem(value: s, child: Text(subjectTypeLabel(s))),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) _setSubject(v);
      },
    ),
  );

  Widget _modeDropdown() => SizedBox(
    width: 180,
    child: DropdownButtonFormField<PolicyMode>(
      initialValue: _params.mode,
      decoration: const InputDecoration(labelText: 'Mode', isDense: true),
      items: PolicyMode.values
          .map(
            (m) => DropdownMenuItem(value: m, child: Text(policyModeLabel(m))),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) _setMode(v);
      },
    ),
  );
}
