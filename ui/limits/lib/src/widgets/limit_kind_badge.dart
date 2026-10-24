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

class LimitKindBadge extends StatelessWidget {
  final LimitKind kind;
  const LimitKindBadge({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (kind) {
      case LimitKind.LIMIT_KIND_PER_TXN_MIN:
      case LimitKind.LIMIT_KIND_PER_TXN_MAX:
        color = Colors.blueGrey.shade600;
        break;
      case LimitKind.LIMIT_KIND_ROLLING_WINDOW_AMOUNT:
        color = Colors.green.shade700;
        break;
      case LimitKind.LIMIT_KIND_ROLLING_WINDOW_COUNT:
        color = Colors.purple.shade700;
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
        limitKindLabel(kind).toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
