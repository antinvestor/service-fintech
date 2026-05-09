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

import 'policy_mode_badge.dart';
import 'usage_bar.dart';
import 'verdict_badge.dart';

class VerdictDetailCard extends StatelessWidget {
  final CheckResponse check;
  const VerdictDetailCard({super.key, required this.check});

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
                VerdictBadge(check: check),
                const Spacer(),
                if (check.requiresApproval)
                  Text(
                    'Requires ${check.requiredApprovers} '
                    '${check.requiredApprovers == 1 ? "approver" : "approvers"}'
                    '${check.requiredRole.isEmpty ? "" : " (${check.requiredRole})"}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Per-policy verdicts', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            if (check.verdicts.isEmpty)
              const Text(
                'No matching policies — the action is unrestricted at this scope.',
                style: TextStyle(color: Colors.grey),
              ),
            for (final v in check.verdicts) ...[
              const Divider(),
              _verdictRow(v),
            ],
          ],
        ),
      ),
    );
  }

  Widget _verdictRow(PolicyVerdict v) {
    final statusText = v.breached
        ? 'BREACHED'
        : (v.wouldRequireApproval ? 'NEEDS APPROVAL' : 'MATCHED OK');
    final statusColor = v.breached
        ? Colors.red.shade700
        : (v.wouldRequireApproval ? Colors.orange.shade700 : Colors.green.shade700);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  v.policyId,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              Text('v${v.policyVersion}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(width: 8),
              PolicyModeBadge(mode: v.mode),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 11),
              ),
            ],
          ),
          if (v.reason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(v.reason, style: const TextStyle(fontSize: 12)),
            ),
          if (v.hasCapAmount() || v.hasCurrentUsage())
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: UsageBar(
                currentUsage: v.currentUsage,
                cap: v.capAmount,
              ),
            ),
          if (v.capCount.toInt() > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${v.currentCount} / ${v.capCount} transactions',
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
