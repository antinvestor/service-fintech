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

class PolicyScopeBadge extends StatelessWidget {
  final PolicyScope scope;
  const PolicyScopeBadge({super.key, required this.scope});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (scope) {
      case PolicyScope.POLICY_SCOPE_PLATFORM:
        color = Colors.blue.shade700;
        break;
      case PolicyScope.POLICY_SCOPE_ORG:
        color = Colors.teal.shade700;
        break;
      case PolicyScope.POLICY_SCOPE_ORG_UNIT:
        color = Colors.indigo.shade700;
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
        policyScopeLabel(scope).toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
