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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:antinvestor_api_limits/antinvestor_api_limits.dart';
import '../utils/formatting.dart';

class AuditEventTile extends StatelessWidget {
  final LimitsAuditEventObject event;
  const AuditEventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _verbColor(event.action);
    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color),
              ),
              child: Text(
                event.action,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                event.reason.isEmpty ? '(no reason)' : event.reason,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 8,
            children: [
              Text(
                '${event.entityType}: ${event.entityId}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (event.actorId.isNotEmpty)
                Text(
                  'by ${event.actorId}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              Text(
                formatTimestamp(
                  event.hasOccurredAt() ? event.occurredAt : null,
                ),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                _prettyMetadata(event),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _verbColor(String action) {
    if (action.startsWith('limits.breach.')) return Colors.red.shade700;
    if (action.startsWith('limits.approval.')) return Colors.orange.shade700;
    if (action.startsWith('limits.reservation.')) return Colors.green.shade700;
    return Colors.blueGrey.shade600;
  }

  String _prettyMetadata(LimitsAuditEventObject ev) {
    if (!ev.hasMetadata()) return '(no metadata)';
    final asMap = <String, dynamic>{};
    ev.metadata.fields.forEach((k, v) {
      asMap[k] = _valueToDart(v);
    });
    return const JsonEncoder.withIndent('  ').convert(asMap);
  }

  dynamic _valueToDart(Value v) {
    if (v.hasStringValue()) return v.stringValue;
    if (v.hasNumberValue()) return v.numberValue;
    if (v.hasBoolValue()) return v.boolValue;
    if (v.hasListValue()) return v.listValue.values.map(_valueToDart).toList();
    if (v.hasStructValue()) {
      return {
        for (final e in v.structValue.fields.entries)
          e.key: _valueToDart(e.value),
      };
    }
    return null;
  }
}
