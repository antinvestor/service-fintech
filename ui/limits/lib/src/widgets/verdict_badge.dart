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

class VerdictBadge extends StatelessWidget {
  final CheckResponse check;
  const VerdictBadge({super.key, required this.check});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    if (check.allowed && !check.requiresApproval) {
      label = 'ALLOWED';
      color = Colors.green.shade700;
    } else if (check.requiresApproval) {
      label = 'REQUIRES APPROVAL';
      color = Colors.orange.shade700;
    } else {
      label = 'BLOCKED';
      color = Colors.red.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
