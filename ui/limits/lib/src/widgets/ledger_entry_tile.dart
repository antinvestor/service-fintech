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
import '../utils/formatting.dart';

class LedgerEntryTile extends StatelessWidget {
  final LedgerEntryObject entry;
  const LedgerEntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final reversed = entry.hasReversedAt();
    return Card(
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                limitActionLabel(entry.action),
                style: TextStyle(
                  decoration: reversed ? TextDecoration.lineThrough : null,
                  color: reversed ? Colors.grey : null,
                ),
              ),
            ),
            CurrencyAmountText(
              amount: entry.amount,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: reversed ? TextDecoration.lineThrough : null,
                color: reversed ? Colors.grey : null,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                '${subjectTypeLabel(entry.subjectType)}: ${entry.subjectId}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Committed: ${formatTimestamp(entry.hasCommittedAt() ? entry.committedAt : null)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (reversed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade400),
                  ),
                  child: Text(
                    'REVERSED ${formatTimestamp(entry.hasReversedAt() ? entry.reversedAt : null)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
