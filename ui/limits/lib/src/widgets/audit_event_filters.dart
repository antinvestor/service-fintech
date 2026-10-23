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

import '../providers/audit_providers.dart';

class AuditEventFilters extends StatelessWidget {
  final AuditSearchParams params;
  final ValueChanged<AuditSearchParams> onChanged;
  const AuditEventFilters({
    super.key,
    required this.params,
    required this.onChanged,
  });

  /// Any filter change resets the keyset cursor: page 2 of the old filter
  /// says nothing about page 1 of the new one.
  void _apply(AuditSearchParams next) => onChanged(next.copyWith(page: ''));

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        SizedBox(
          width: 360,
          child: TextField(
            key: const Key('auditVerbsFilter'),
            decoration: const InputDecoration(
              labelText: 'Verbs (comma-separated; blank = all limits.*)',
              hintText: 'limits.breach.hard, limits.approval.required',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) => _apply(
              params.copyWith(
                actions: v
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList(),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 180,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Entity type',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) => _apply(params.copyWith(entityType: v.trim())),
          ),
        ),
        SizedBox(
          width: 220,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Entity ID',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) => _apply(params.copyWith(entityId: v.trim())),
          ),
        ),
        SizedBox(
          width: 200,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Actor ID',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) => _apply(params.copyWith(actorId: v.trim())),
          ),
        ),
        _dateFilter(
          context,
          label: 'From',
          value: params.from,
          onPicked: (picked) => _apply(
            picked == null
                ? params.copyWith(clearFrom: true)
                : params.copyWith(from: picked),
          ),
        ),
        _dateFilter(
          context,
          label: 'To',
          value: params.to,
          onPicked: (picked) => _apply(
            picked == null
                ? params.copyWith(clearTo: true)
                : params.copyWith(to: picked),
          ),
        ),
      ],
    );
  }

  Widget _dateFilter(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onPicked,
  }) => SizedBox(
    width: 170,
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        suffixIcon: value == null
            ? const Icon(Icons.event, size: 18)
            : IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => onPicked(null),
              ),
      ),
      child: InkWell(
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? now,
            firstDate: DateTime(now.year - 5),
            lastDate: DateTime(now.year + 1),
          );
          if (picked != null) onPicked(picked);
        },
        child: Text(
          value == null ? 'Any' : value.toIso8601String().substring(0, 10),
        ),
      ),
    ),
  );
}
