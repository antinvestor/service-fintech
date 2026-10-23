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

/// Converts a `Money`-shaped proto to a double for ratio arithmetic.
double _asDouble(dynamic money) {
  if (money == null) return 0;
  final units = ((money.units as dynamic).toInt() as int).toDouble();
  final nanos = (money.nanos as int).toDouble();
  return units + nanos / 1000000000.0;
}

class UsageBar extends StatelessWidget {
  final dynamic currentUsage;
  final dynamic cap;
  const UsageBar({super.key, required this.currentUsage, required this.cap});

  @override
  Widget build(BuildContext context) {
    if (cap == null) return const SizedBox.shrink();

    // Ratio in doubles, not scaled integers: on web an int is a 53-bit
    // double, so units * 1e9 silently loses precision above ~9M major units
    // and the bar reads wrong for exactly the large caps that matter.
    final capValue = _asDouble(cap);
    final usedValue = _asDouble(currentUsage);
    final ratio = capValue == 0 ? 0.0 : (usedValue / capValue).clamp(0.0, 1.0);

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
            CurrencyAmountText(
              amount: currentUsage,
              style: const TextStyle(fontSize: 11),
            ),
            const Text(
              ' / ',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            CurrencyAmountText(
              amount: cap,
              style: const TextStyle(fontSize: 11),
            ),
            const Spacer(),
            Text(
              '${(ratio * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
