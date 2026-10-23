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

import 'ledger_entry_tile.dart';

class LedgerTimeline extends StatelessWidget {
  final List<LedgerEntryObject> entries;
  const LedgerTimeline({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No ledger entries match.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Group by subject id; preserve original order within each group.
    final bySubject = <String, List<LedgerEntryObject>>{};
    for (final e in entries) {
      final key = '${e.subjectType.value}:${e.subjectId}';
      bySubject.putIfAbsent(key, () => []).add(e);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in bySubject.entries) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              entry.key,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          for (final e in entry.value) LedgerEntryTile(entry: e),
        ],
      ],
    );
  }
}
