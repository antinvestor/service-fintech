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

class PolicyModeBadge extends StatelessWidget {
  final PolicyMode mode;
  const PolicyModeBadge({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (mode) {
      case PolicyMode.POLICY_MODE_ENFORCE:
        color = Colors.red.shade700;
        break;
      case PolicyMode.POLICY_MODE_SHADOW:
        color = Colors.orange.shade700;
        break;
      case PolicyMode.POLICY_MODE_OFF:
        color = Colors.grey.shade600;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        policyModeLabel(mode).toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
