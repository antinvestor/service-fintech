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

import 'package:antinvestor_api_limits/antinvestor_api_limits.dart';
import 'package:flutter/material.dart';

import '../providers/ledger_providers.dart';
import '../utils/enum_labels.dart';

class LedgerSearchFilters extends StatelessWidget {
  final LedgerSearchParams params;
  final ValueChanged<LedgerSearchParams> onChanged;
  const LedgerSearchFilters({
    super.key,
    required this.params,
    required this.onChanged,
  });

  void _emit(LedgerSearchParams next) => onChanged(next);

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

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<LimitAction>(
            initialValue: params.action,
            decoration: const InputDecoration(
              labelText: 'Action',
              isDense: true,
            ),
            items: LimitAction.values
                .map(
                  (a) => DropdownMenuItem(
                    value: a,
                    child: Text(limitActionLabel(a)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) {
                _emit(params.copyWith(action: v));
              }
            },
          ),
        ),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<SubjectType>(
            initialValue: params.subjectType,
            decoration: const InputDecoration(
              labelText: 'Subject',
              isDense: true,
            ),
            items: SubjectType.values
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(subjectTypeLabel(s)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) {
                _emit(params.copyWith(subjectType: v));
              }
            },
          ),
        ),
        SizedBox(
          width: 220,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Subject ID',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) => _emit(params.copyWith(subjectId: v.trim())),
          ),
        ),
        SizedBox(
          width: 120,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Currency',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) =>
                _emit(params.copyWith(currencyCode: v.trim().toUpperCase())),
          ),
        ),
        _dateFilter(
          context,
          label: 'From',
          value: params.from,
          onPicked: (picked) => _emit(
            picked == null
                ? params.copyWith(clearFrom: true)
                : params.copyWith(from: picked),
          ),
        ),
        _dateFilter(
          context,
          label: 'To',
          value: params.to,
          onPicked: (picked) => _emit(
            picked == null
                ? params.copyWith(clearTo: true)
                : params.copyWith(to: picked),
          ),
        ),
      ],
    );
  }
}
