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
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/limits_transport_provider.dart';
import '../utils/enum_labels.dart';
import '../widgets/cap_amount_field.dart';
import '../widgets/verdict_detail_card.dart';

class PolicyVerdictPlaygroundScreen extends ConsumerStatefulWidget {
  const PolicyVerdictPlaygroundScreen({super.key});

  @override
  ConsumerState<PolicyVerdictPlaygroundScreen> createState() =>
      _PolicyVerdictPlaygroundScreenState();
}

class _PolicyVerdictPlaygroundScreenState
    extends ConsumerState<PolicyVerdictPlaygroundScreen> {
  LimitAction _action = LimitAction.LIMIT_ACTION_LOAN_DISBURSEMENT;
  String _tenantId = '';
  String _orgUnitId = '';
  String? _amountText;
  String _amountCurrency = 'KES';
  String _makerId = '';

  // Subjects are appended as (type, id) pairs.
  final List<_SubjectDraft> _subjects = [
    _SubjectDraft(type: SubjectType.SUBJECT_TYPE_CLIENT, id: ''),
  ];

  CheckResponse? _result;
  String? _error;
  bool _loading = false;

  Future<void> _runCheck() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final intent = LimitIntent(
        action: _action,
        tenantId: _tenantId,
        orgUnitId: _orgUnitId,
        makerId: _makerId,
        subjects: _subjects
            .where((s) => s.id.isNotEmpty)
            .map((s) => SubjectRef(type: s.type, id: s.id))
            .toList(),
      );
      if (_amountText != null && _amountText!.isNotEmpty) {
        setMoneyFields(intent.ensureAmount(), _amountText!, _amountCurrency);
      }
      final client = ref.read(limitsServiceClientProvider);
      final resp = await client.check(CheckRequest(intent: intent));
      setState(() {
        _result = resp;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _addSubject() {
    setState(() {
      _subjects.add(_SubjectDraft(type: SubjectType.SUBJECT_TYPE_CLIENT, id: ''));
    });
  }

  void _removeSubject(int i) {
    setState(() => _subjects.removeAt(i));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verdict playground')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Construct a LimitIntent and call Check to preview what '
                'would happen if a real action of this shape arrived. '
                'Read-only — no state changes on the server.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<LimitAction>(
            initialValue: _action,
            decoration: const InputDecoration(labelText: 'Action'),
            items: LimitAction.values
                .where((a) => a != LimitAction.LIMIT_ACTION_UNSPECIFIED)
                .map((a) => DropdownMenuItem(value: a, child: Text(limitActionLabel(a))))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _action = v);
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Tenant ID'),
            onChanged: (v) => _tenantId = v,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Org unit ID (optional)'),
            onChanged: (v) => _orgUnitId = v,
          ),
          const SizedBox(height: 12),
          CapAmountField(
            label: 'Amount',
            onChanged: (amount, currency) => setState(() {
              _amountText = amount;
              _amountCurrency = currency;
            }),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Maker (workforce member ID)'),
            onChanged: (v) => _makerId = v,
          ),
          const SizedBox(height: 16),
          const Text('Subjects', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          for (var i = 0; i < _subjects.length; i++) ...[
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<SubjectType>(
                    initialValue: _subjects[i].type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: SubjectType.values
                        .where((s) => s != SubjectType.SUBJECT_TYPE_UNSPECIFIED)
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(subjectTypeLabel(s))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _subjects[i].type = v);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: _subjects[i].id,
                    decoration: const InputDecoration(labelText: 'ID'),
                    onChanged: (v) => _subjects[i].id = v,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _subjects.length > 1 ? () => _removeSubject(i) : null,
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add subject'),
            onPressed: _addSubject,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Check'),
            onPressed: _loading ? null : _runCheck,
          ),
          const SizedBox(height: 16),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text('Error: $_error', style: TextStyle(color: Colors.red.shade900)),
              ),
            ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            VerdictDetailCard(check: _result!),
          ],
        ],
      ),
    );
  }
}

class _SubjectDraft {
  SubjectType type;
  String id;
  _SubjectDraft({required this.type, required this.id});
}
