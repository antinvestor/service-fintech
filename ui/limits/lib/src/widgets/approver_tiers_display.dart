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
import 'package:fixnum/fixnum.dart';

class ApproverTiersDisplay extends StatelessWidget {
  final List<ApproverTier> tiers;
  const ApproverTiersDisplay({super.key, required this.tiers});

  @override
  Widget build(BuildContext context) {
    if (tiers.isEmpty) {
      return const Text(
        'No approval required',
        style: TextStyle(color: Colors.grey),
      );
    }
    return DataTable(
      columns: const [
        DataColumn(label: Text('Up to')),
        DataColumn(label: Text('Role')),
        DataColumn(label: Text('Approvers')),
      ],
      rows: [
        for (final t in tiers)
          DataRow(
            cells: [
              DataCell(Text(t.upTo == Int64.ZERO ? '∞' : t.upTo.toString())),
              DataCell(Text(t.role)),
              DataCell(Text('${t.approvers}')),
            ],
          ),
      ],
    );
  }
}
