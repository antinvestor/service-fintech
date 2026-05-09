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
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/policy_providers.dart';
import '../utils/enum_labels.dart';
import '../widgets/approver_tiers_editor.dart';
import '../widgets/attribute_filter_editor.dart';
import '../widgets/cap_amount_field.dart';
import '../widgets/window_duration_field.dart';

class PolicyEditorScreen extends ConsumerStatefulWidget {
  final String? policyId; // null → create, non-null → edit
  const PolicyEditorScreen({super.key, this.policyId});

  @override
  ConsumerState<PolicyEditorScreen> createState() => _PolicyEditorScreenState();
}

class _PolicyEditorScreenState extends ConsumerState<PolicyEditorScreen> {
  late PolicyObject _draft;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _draft = PolicyObject()
      ..scope = PolicyScope.POLICY_SCOPE_ORG
      ..mode = PolicyMode.POLICY_MODE_SHADOW
      ..limitKind = LimitKind.LIMIT_KIND_PER_TXN_MAX
      ..action = LimitAction.LIMIT_ACTION_LOAN_DISBURSEMENT
      ..subjectType = SubjectType.SUBJECT_TYPE_CLIENT
      ..currencyCode = 'KES';
    if (widget.policyId != null) {
      _loading = true;
      Future.microtask(_loadExisting);
    }
  }

  Future<void> _loadExisting() async {
    try {
      final loaded =
          await ref.read(policyDetailProvider(widget.policyId!).future);
      if (mounted) {
        setState(() {
          _draft = loaded;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    final notifier = ref.read(policyMutationProvider.notifier);
    try {
      final saved = await notifier.save(_draft);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved policy ${saved.id} (v${saved.version})'),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool get _isRolling =>
      _draft.limitKind == LimitKind.LIMIT_KIND_ROLLING_WINDOW_AMOUNT ||
      _draft.limitKind == LimitKind.LIMIT_KIND_ROLLING_WINDOW_COUNT;

  bool get _isCountKind =>
      _draft.limitKind == LimitKind.LIMIT_KIND_ROLLING_WINDOW_COUNT;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isUpdate = widget.policyId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isUpdate ? 'Edit policy' : 'New policy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Action
          DropdownButtonFormField<LimitAction>(
            initialValue: _draft.action,
            decoration: const InputDecoration(labelText: 'Action'),
            items: LimitAction.values
                .where((a) => a != LimitAction.LIMIT_ACTION_UNSPECIFIED)
                .map(
                  (a) => DropdownMenuItem(
                    value: a,
                    child: Text(limitActionLabel(a)),
                  ),
                )
                .toList(),
            onChanged: (v) =>
                setState(() => _draft.action = v ?? _draft.action),
          ),
          const SizedBox(height: 12),

          // Scope
          DropdownButtonFormField<PolicyScope>(
            initialValue: _draft.scope,
            decoration: const InputDecoration(labelText: 'Scope'),
            items: PolicyScope.values
                .where((s) => s != PolicyScope.POLICY_SCOPE_UNSPECIFIED)
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(policyScopeLabel(s)),
                  ),
                )
                .toList(),
            onChanged: (v) =>
                setState(() => _draft.scope = v ?? _draft.scope),
          ),
          const SizedBox(height: 12),

          // Org unit ID — only visible for ORG_UNIT scope
          if (_draft.scope == PolicyScope.POLICY_SCOPE_ORG_UNIT) ...[
            TextFormField(
              initialValue: _draft.orgUnitId,
              decoration: const InputDecoration(labelText: 'Org unit ID'),
              onChanged: (v) => setState(() => _draft.orgUnitId = v),
            ),
            const SizedBox(height: 12),
          ],

          // Subject type
          DropdownButtonFormField<SubjectType>(
            initialValue: _draft.subjectType,
            decoration: const InputDecoration(labelText: 'Subject type'),
            items: SubjectType.values
                .where((s) => s != SubjectType.SUBJECT_TYPE_UNSPECIFIED)
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(subjectTypeLabel(s)),
                  ),
                )
                .toList(),
            onChanged: (v) =>
                setState(() => _draft.subjectType = v ?? _draft.subjectType),
          ),
          const SizedBox(height: 12),

          // Limit kind
          DropdownButtonFormField<LimitKind>(
            initialValue: _draft.limitKind,
            decoration: const InputDecoration(labelText: 'Kind'),
            items: LimitKind.values
                .where((k) => k != LimitKind.LIMIT_KIND_UNSPECIFIED)
                .map(
                  (k) => DropdownMenuItem(
                    value: k,
                    child: Text(limitKindLabel(k)),
                  ),
                )
                .toList(),
            onChanged: (v) =>
                setState(() => _draft.limitKind = v ?? _draft.limitKind),
          ),
          const SizedBox(height: 12),

          // Mode
          DropdownButtonFormField<PolicyMode>(
            initialValue: _draft.mode,
            decoration: const InputDecoration(labelText: 'Mode'),
            items: PolicyMode.values
                .where((m) => m != PolicyMode.POLICY_MODE_UNSPECIFIED)
                .map(
                  (m) => DropdownMenuItem(
                    value: m,
                    child: Text(policyModeLabel(m)),
                  ),
                )
                .toList(),
            onChanged: (v) =>
                setState(() => _draft.mode = v ?? _draft.mode),
          ),
          const SizedBox(height: 12),

          // Cap: amount field for non-count kinds, count field for count kind.
          if (!_isCountKind) ...[
            CapAmountField(
              initialAmount: _draft.hasCapAmount()
                  ? moneyToAmountString(_draft.capAmount)
                  : null,
              initialCurrency: moneyCurrency(
                _draft.hasCapAmount() ? _draft.capAmount : null,
                _draft.currencyCode.isNotEmpty ? _draft.currencyCode : 'KES',
              ),
              onChanged: (amount, currency) {
                setState(() {
                  if (amount == null) {
                    _draft.clearCapAmount();
                  } else {
                    setMoneyFields(_draft.ensureCapAmount(), amount, currency);
                    _draft.currencyCode = currency;
                  }
                });
              },
            ),
            const SizedBox(height: 12),
          ],
          if (_isCountKind) ...[
            TextFormField(
              initialValue: _draft.capCount == Int64.ZERO
                  ? ''
                  : _draft.capCount.toString(),
              decoration: const InputDecoration(labelText: 'Cap count'),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                setState(
                  () =>
                      _draft.capCount = Int64.tryParseInt(v) ?? Int64.ZERO,
                );
              },
            ),
            const SizedBox(height: 12),
          ],

          // Window — only for rolling kinds.
          // Uses ensureWindow() to avoid importing the internal Duration type.
          if (_isRolling) ...[
            WindowDurationField(
              initialSeconds: _draft.hasWindow()
                  ? _draft.window.seconds.toInt()
                  : 0,
              onChanged: (s) => setState(() {
                _draft.ensureWindow().seconds = Int64(s);
              }),
            ),
            const SizedBox(height: 16),
          ],

          // Approver tiers
          ApproverTiersEditor(
            initial: _draft.approverTiers,
            onChanged: (tiers) => setState(() {
              _draft.approverTiers
                ..clear()
                ..addAll(tiers);
            }),
          ),
          const SizedBox(height: 16),

          // Attribute filter
          AttributeFilterEditor(
            initial:
                _draft.hasAttributeFilter() ? _draft.attributeFilter : null,
            onChanged: (s) => setState(() {
              if (s == null) {
                _draft.clearAttributeFilter();
              } else {
                _draft.attributeFilter = s;
              }
            }),
          ),
          const SizedBox(height: 16),

          // Notes
          TextFormField(
            initialValue: _draft.notes,
            decoration: const InputDecoration(labelText: 'Notes'),
            maxLines: 3,
            onChanged: (v) => setState(() => _draft.notes = v),
          ),
          const SizedBox(height: 24),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(isUpdate ? 'Save' : 'Create'),
                onPressed: _save,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
