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
import 'package:antinvestor_api_limits/antinvestor_api_limits.dart';

import '../utils/duration_format.dart';
import '../utils/enum_labels.dart';
import 'approver_tiers_display.dart';
import 'attribute_filter_display.dart';
import 'currency_amount_text.dart';
import 'limit_kind_badge.dart';
import 'policy_mode_badge.dart';
import 'policy_scope_badge.dart';

class PolicyDetailCard extends StatelessWidget {
  final PolicyObject policy;
  const PolicyDetailCard({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    policy.id.isEmpty ? '(unsaved)' : policy.id,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
                Text('v${policy.version}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                PolicyScopeBadge(scope: policy.scope),
                PolicyModeBadge(mode: policy.mode),
                LimitKindBadge(kind: policy.limitKind),
              ],
            ),
            const SizedBox(height: 12),
            _kv('Action', limitActionLabel(policy.action)),
            _kv('Subject type', subjectTypeLabel(policy.subjectType)),
            if (policy.scope == PolicyScope.POLICY_SCOPE_ORG_UNIT)
              _kv('Org unit', policy.orgUnitId),
            if (policy.limitKind == LimitKind.LIMIT_KIND_ROLLING_WINDOW_COUNT)
              _kv('Cap count', policy.capCount.toString())
            else
              _kvWidget(
                'Cap',
                CurrencyAmountText(amount: policy.capAmount),
              ),
            if (policy.window.seconds.toInt() > 0)
              _kv('Window', formatDuration(policy.window.seconds.toInt())),
            const Divider(),
            const Text('Approver tiers', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ApproverTiersDisplay(tiers: policy.approverTiers),
            const SizedBox(height: 12),
            const Text('Attribute filter', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            AttributeFilterDisplay(
              filter: policy.hasAttributeFilter() ? policy.attributeFilter : null,
            ),
            if (policy.notes.isNotEmpty) ...[
              const Divider(),
              const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(policy.notes),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kv(String key, String value) => _kvWidget(key, Text(value));

  Widget _kvWidget(String key, Widget value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(
                key,
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54),
              ),
            ),
            Expanded(child: value),
          ],
        ),
      );
}
