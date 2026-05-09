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

import '../utils/enum_labels.dart';
import 'currency_amount_text.dart';
import 'policy_mode_badge.dart';
import 'policy_scope_badge.dart';

class PolicyListTile extends StatelessWidget {
  final PolicyObject policy;
  final VoidCallback? onTap;
  const PolicyListTile({super.key, required this.policy, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(policy.notes.isEmpty ? policy.id : policy.notes),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(limitActionLabel(policy.action), style: const TextStyle(fontSize: 12)),
              Text(
                '· ${subjectTypeLabel(policy.subjectType)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (policy.limitKind != LimitKind.LIMIT_KIND_ROLLING_WINDOW_COUNT &&
                  policy.hasCapAmount())
                CurrencyAmountText(
                  amount: policy.capAmount,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              if (policy.limitKind == LimitKind.LIMIT_KIND_ROLLING_WINDOW_COUNT)
                Text(
                  '${policy.capCount} txn',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              PolicyScopeBadge(scope: policy.scope),
              PolicyModeBadge(mode: policy.mode),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
