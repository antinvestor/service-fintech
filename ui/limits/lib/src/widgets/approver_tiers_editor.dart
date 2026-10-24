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
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';

/// The approver-count bound the service enforces on every tier.
const int maxApproverCount = 11;

/// Validates an approver ladder against the rules the service applies, so the
/// operator sees the problem here rather than as a raw invalid_argument.
/// Returns null when the ladder is acceptable (including when it is empty).
String? validateApproverTiers(List<ApproverTier> tiers) {
  if (tiers.isEmpty) return null;
  final bounds = <Int64>{};
  var catchAll = 0;
  for (final tier in tiers) {
    if (tier.role.trim().isEmpty) {
      return 'Every tier needs a role';
    }
    if (tier.approvers < 1 || tier.approvers > maxApproverCount) {
      return 'Approver count must be between 1 and $maxApproverCount';
    }
    if (tier.upTo < Int64.ZERO) {
      return 'Up-to cannot be negative';
    }
    if (tier.upTo == Int64.ZERO) {
      catchAll++;
      if (catchAll > 1) return 'Only one catch-all tier is allowed';
      continue;
    }
    if (!bounds.add(tier.upTo)) {
      return 'Two tiers share the same up-to bound';
    }
  }
  return null;
}

class ApproverTiersEditor extends StatefulWidget {
  final List<ApproverTier> initial;
  final ValueChanged<List<ApproverTier>> onChanged;
  final String? errorText;

  const ApproverTiersEditor({
    super.key,
    required this.initial,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<ApproverTiersEditor> createState() => _ApproverTiersEditorState();
}

class _ApproverTiersEditorState extends State<ApproverTiersEditor> {
  late List<ApproverTier> _tiers;

  @override
  void initState() {
    super.initState();
    _tiers = [for (final tier in widget.initial) tier.deepCopy()];
  }

  void _addTier() {
    setState(() {
      _tiers.add(
        ApproverTier()
          ..upTo = Int64.ZERO
          ..role = ''
          ..approvers = 1,
      );
    });
    widget.onChanged(_tiers);
  }

  void _removeTier(int index) {
    setState(() => _tiers.removeAt(index));
    widget.onChanged(_tiers);
  }

  void _updateTier(int index, ApproverTier updated) {
    setState(() => _tiers[index] = updated);
    widget.onChanged(_tiers);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Approver tiers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        for (var i = 0; i < _tiers.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  key: Key('tierUpTo$i'),
                  initialValue: _tiers[i].upTo == Int64.ZERO
                      ? ''
                      : _tiers[i].upTo.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Up to (minor units, blank = catch-all)',
                  ),
                  keyboardType: TextInputType.number,
                  // tryParseInt, never parseInt: a stray "-" or a pasted
                  // "1,000" must not throw out of onChanged.
                  validator: (v) {
                    final raw = (v ?? '').trim();
                    if (raw.isEmpty) return null;
                    final parsed = Int64.tryParseInt(raw);
                    if (parsed == null) return 'Whole number of minor units';
                    if (parsed < Int64.ZERO) return 'Cannot be negative';
                    return null;
                  },
                  onChanged: (v) {
                    final raw = v.trim();
                    final parsed = raw.isEmpty
                        ? Int64.ZERO
                        : Int64.tryParseInt(raw);
                    if (parsed == null) return;
                    _updateTier(i, _tiers[i].deepCopy()..upTo = parsed);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  key: Key('tierRole$i'),
                  initialValue: _tiers[i].role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Role is required'
                      : null,
                  onChanged: (v) =>
                      _updateTier(i, _tiers[i].deepCopy()..role = v.trim()),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 96,
                child: TextFormField(
                  key: Key('tierCount$i'),
                  initialValue: '${_tiers[i].approvers}',
                  decoration: const InputDecoration(labelText: 'Count'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final parsed = int.tryParse((v ?? '').trim());
                    if (parsed == null ||
                        parsed < 1 ||
                        parsed > maxApproverCount) {
                      return '1–$maxApproverCount';
                    }
                    return null;
                  },
                  onChanged: (v) {
                    final parsed = int.tryParse(v.trim());
                    if (parsed == null) return;
                    _updateTier(i, _tiers[i].deepCopy()..approvers = parsed);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _removeTier(i),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add tier'),
          onPressed: _addTier,
        ),
      ],
    );
  }
}
