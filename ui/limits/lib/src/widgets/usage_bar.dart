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

import 'currency_amount_text.dart';

class UsageBar extends StatelessWidget {
  final dynamic currentUsage;
  final dynamic cap;
  const UsageBar({super.key, required this.currentUsage, required this.cap});

  @override
  Widget build(BuildContext context) {
    if (cap == null) return const SizedBox.shrink();

    // Convert both to (units * 1e9 + nanos) for ratio. Use a large
    // intermediate via num so we don't lose precision on int boundaries.
    final int capUnits = (cap.units as dynamic).toInt() as int;
    final int capNanos = cap.nanos as int;
    final capNum = capUnits * 1000000000 + capNanos;
    final usedNum = currentUsage == null
        ? 0
        : ((currentUsage.units as dynamic).toInt() as int) * 1000000000 +
            (currentUsage.nanos as int);
    final ratio = capNum == 0 ? 0.0 : (usedNum / capNum).clamp(0.0, 1.0);

    final color = ratio < 0.7
        ? Colors.green.shade600
        : (ratio < 0.9 ? Colors.orange.shade700 : Colors.red.shade700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.toDouble(),
            color: color,
            backgroundColor: Colors.grey.shade300,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            CurrencyAmountText(amount: currentUsage, style: const TextStyle(fontSize: 11)),
            const Text(' / ', style: TextStyle(fontSize: 11, color: Colors.grey)),
            CurrencyAmountText(amount: cap, style: const TextStyle(fontSize: 11)),
            const Spacer(),
            Text(
              '${(ratio * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
