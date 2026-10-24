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
import 'package:go_router/go_router.dart';

import '../capabilities.dart';
import '../providers/limits_transport_provider.dart';
import '../providers/policy_providers.dart';
import '../utils/duration_format.dart';
import '../utils/enum_labels.dart';
import '../utils/formatting.dart';
import '../widgets/approver_tiers_editor.dart';
import '../widgets/attribute_filter_editor.dart';
import '../widgets/cap_amount_field.dart';
import '../widgets/window_duration_field.dart';

/// The shortest approval window the service accepts. Anything shorter creates
/// requests the reaper expires before a human can act on them.
const _minApprovalTtlSeconds = 15 * 60;

/// Builds a proto Timestamp from a local date the operator picked.
Timestamp timestampFromDateTime(DateTime value) =>
    Timestamp.fromDateTime(value.toUtc());

class PolicyEditorScreen extends ConsumerStatefulWidget {
  final String? policyId; // null → create, non-null → edit
  const PolicyEditorScreen({super.key, this.policyId});

  @override
  ConsumerState<PolicyEditorScreen> createState() => _PolicyEditorScreenState();
}

class _PolicyEditorScreenState extends ConsumerState<PolicyEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late PolicyObject _draft;
  bool _loading = false;
  bool _saving = false;
  String? _loadError;

  /// Validation messages for the sub-editors, which are not FormFields.
  String? _capError;
  String? _windowError;
  String? _tiersError;

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

  /// Loads the policy through the client directly rather than a cached
  /// provider: a failed load here must be retryable, and a provider would
  /// cache the failure for the life of the screen.
  Future<void> _loadExisting() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final client = ref.read(limitsAdminServiceClientProvider);
      final response = await client.policyGet(
        PolicyGetRequest(id: widget.policyId!),
      );
      if (!mounted) return;
      setState(() {
        // A deep copy so edits never mutate a provider-cached message.
        _draft = response.data.deepCopy();
        _loading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = '$e';
      });
    }
  }

  bool get _isRolling =>
      _draft.limitKind == LimitKind.LIMIT_KIND_ROLLING_WINDOW_AMOUNT ||
      _draft.limitKind == LimitKind.LIMIT_KIND_ROLLING_WINDOW_COUNT;

  bool get _isCountKind =>
      _draft.limitKind == LimitKind.LIMIT_KIND_ROLLING_WINDOW_COUNT;

  /// Validates the parts of the form that are not FormFields. Returns true
  /// when the draft is safe to send.
  bool _validateDraft() {
    String? capError;
    String? windowError;
    String? tiersError;

    if (_isCountKind) {
      if (_draft.capCount <= Int64.ZERO) {
        capError = 'Cap count must be greater than zero';
      }
    } else if (!moneyIsPositive(
      _draft.hasCapAmount() ? _draft.capAmount : null,
    )) {
      // A zero cap on a maximum breaches every amount, blocking the action
      // outright instead of limiting it.
      capError = 'Cap must be greater than zero';
    }

    if (_isRolling &&
        (!_draft.hasWindow() || _draft.window.seconds <= Int64.ZERO)) {
      windowError = 'Rolling-window policies need a window (e.g. 24h, 7d)';
    }

    tiersError = validateApproverTiers(_draft.approverTiers);

    if (hasTimestamp(_draft.hasEffectiveTo() ? _draft.effectiveTo : null) &&
        hasTimestamp(_draft.hasEffectiveFrom() ? _draft.effectiveFrom : null) &&
        !_draft.effectiveTo.toDateTime().isAfter(
          _draft.effectiveFrom.toDateTime(),
        )) {
      _showError('Effective to must be after effective from');
      return false;
    }

    setState(() {
      _capError = capError;
      _windowError = windowError;
      _tiersError = tiersError;
    });

    final fieldsValid = _formKey.currentState?.validate() ?? true;
    return fieldsValid &&
        capError == null &&
        windowError == null &&
        tiersError == null;
  }

  Future<void> _save() async {
    if (!_validateDraft()) return;

    // Enforce mode denies real transactions the moment it is saved, so it is
    // never a silent side effect of pressing Save.
    if (_draft.mode == PolicyMode.POLICY_MODE_ENFORCE &&
        !await _confirmEnforce()) {
      return;
    }
    if (!mounted) return;

    setState(() => _saving = true);
    try {
      final saved = await ref
          .read(policyMutationProvider.notifier)
          .save(_draft);
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved policy ${saved.id} (v${saved.version})')),
      );
      _leave();
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError('Save failed: $e');
    }
  }

  Future<bool> _confirmEnforce() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enable enforcement?'),
        content: const Text(
          'In ENFORCE mode this policy blocks transactions that breach it, '
          'as soon as it is saved. Shadow mode records the same verdicts '
          'without blocking anything.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Enforce'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Returns to wherever the operator came from. The editor is reached by a
  /// push from the list or detail screen; when it is opened directly by URL
  /// there is nothing to pop, so fall back to the list.
  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/limits/policies');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.policyId != null;
    final canManage = ref.watch(limitsCapabilitiesProvider).policyManage;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(isUpdate ? 'Edit policy' : 'New policy')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(isUpdate ? 'Edit policy' : 'New policy')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load: $_loadError'),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: _loadExisting,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Edit policy' : 'New policy'),
        leading: BackButton(onPressed: _leave),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _actionField(),
            const SizedBox(height: 12),
            _scopeField(),
            const SizedBox(height: 12),
            if (_draft.scope == PolicyScope.POLICY_SCOPE_ORG_UNIT) ...[
              TextFormField(
                initialValue: _draft.orgUnitId,
                decoration: const InputDecoration(labelText: 'Org unit ID'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Org-unit scope needs an org unit ID'
                    : null,
                onChanged: (v) => _draft.orgUnitId = v.trim(),
              ),
              const SizedBox(height: 12),
            ],
            _subjectTypeField(),
            const SizedBox(height: 12),
            _limitKindField(),
            const SizedBox(height: 12),
            _modeField(),
            const SizedBox(height: 12),
            ..._capFields(),
            ..._windowFields(),
            ApproverTiersEditor(
              initial: _draft.approverTiers,
              errorText: _tiersError,
              onChanged: (tiers) => setState(() {
                _draft.approverTiers
                  ..clear()
                  ..addAll(tiers);
                _tiersError = null;
              }),
            ),
            const SizedBox(height: 12),
            _approvalTtlField(),
            const SizedBox(height: 12),
            _effectiveRangeFields(),
            const SizedBox(height: 16),
            AttributeFilterEditor(
              initial: _draft.hasAttributeFilter()
                  ? _draft.attributeFilter
                  : null,
              onChanged: (s) => setState(() {
                if (s == null) {
                  _draft.clearAttributeFilter();
                } else {
                  _draft.attributeFilter = s;
                }
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _draft.notes,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
              onChanged: (v) => _draft.notes = v,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _saving ? null : _leave,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                if (canManage)
                  ElevatedButton.icon(
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(isUpdate ? 'Save' : 'Create'),
                    onPressed: _saving ? null : _save,
                  )
                else
                  const Tooltip(
                    message: 'You do not have limits_policy_manage',
                    child: Text(
                      'Read-only',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionField() => DropdownButtonFormField<LimitAction>(
    initialValue: _draft.action,
    decoration: const InputDecoration(labelText: 'Action'),
    items: LimitAction.values
        .where((a) => a != LimitAction.LIMIT_ACTION_UNSPECIFIED)
        .map(
          (a) => DropdownMenuItem(value: a, child: Text(limitActionLabel(a))),
        )
        .toList(),
    onChanged: (v) => setState(() => _draft.action = v ?? _draft.action),
  );

  Widget _scopeField() => DropdownButtonFormField<PolicyScope>(
    initialValue: _draft.scope,
    decoration: const InputDecoration(labelText: 'Scope'),
    items: PolicyScope.values
        .where((s) => s != PolicyScope.POLICY_SCOPE_UNSPECIFIED)
        .map(
          (s) => DropdownMenuItem(value: s, child: Text(policyScopeLabel(s))),
        )
        .toList(),
    onChanged: (v) => setState(() => _draft.scope = v ?? _draft.scope),
  );

  Widget _subjectTypeField() => DropdownButtonFormField<SubjectType>(
    initialValue: _draft.subjectType,
    decoration: const InputDecoration(labelText: 'Subject type'),
    items: SubjectType.values
        .where((s) => s != SubjectType.SUBJECT_TYPE_UNSPECIFIED)
        .map(
          (s) => DropdownMenuItem(value: s, child: Text(subjectTypeLabel(s))),
        )
        .toList(),
    onChanged: (v) =>
        setState(() => _draft.subjectType = v ?? _draft.subjectType),
  );

  Widget _limitKindField() => DropdownButtonFormField<LimitKind>(
    initialValue: _draft.limitKind,
    decoration: const InputDecoration(labelText: 'Kind'),
    items: LimitKind.values
        .where((k) => k != LimitKind.LIMIT_KIND_UNSPECIFIED)
        .map((k) => DropdownMenuItem(value: k, child: Text(limitKindLabel(k))))
        .toList(),
    onChanged: (v) => setState(() {
      _draft.limitKind = v ?? _draft.limitKind;
      _capError = null;
      _windowError = null;
    }),
  );

  Widget _modeField() => DropdownButtonFormField<PolicyMode>(
    initialValue: _draft.mode,
    decoration: const InputDecoration(labelText: 'Mode'),
    items: PolicyMode.values
        .where((m) => m != PolicyMode.POLICY_MODE_UNSPECIFIED)
        .map((m) => DropdownMenuItem(value: m, child: Text(policyModeLabel(m))))
        .toList(),
    onChanged: (v) => setState(() => _draft.mode = v ?? _draft.mode),
  );

  List<Widget> _capFields() {
    if (_isCountKind) {
      return [
        TextFormField(
          key: const Key('capCountField'),
          initialValue: _draft.capCount == Int64.ZERO
              ? ''
              : _draft.capCount.toString(),
          decoration: InputDecoration(
            labelText: 'Cap count',
            errorText: _capError,
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) => setState(() {
            _draft.capCount = Int64.tryParseInt(v.trim()) ?? Int64.ZERO;
            _capError = null;
          }),
        ),
        const SizedBox(height: 12),
      ];
    }
    return [
      CapAmountField(
        initialAmount: _draft.hasCapAmount()
            ? moneyToEditString(_draft.capAmount)
            : null,
        initialCurrency: moneyCurrency(
          _draft.hasCapAmount() ? _draft.capAmount : null,
          _draft.currencyCode.isNotEmpty ? _draft.currencyCode : 'KES',
        ),
        errorText: _capError,
        onChanged: (amount, currency) {
          setState(() {
            _capError = null;
            _draft.currencyCode = currency;
            if (amount == null || amount.isEmpty) {
              _draft.clearCapAmount();
            } else {
              setMoneyFields(_draft.ensureCapAmount(), amount, currency);
            }
          });
        },
      ),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _windowFields() {
    if (!_isRolling) return const [];
    return [
      WindowDurationField(
        initialSeconds: _draft.hasWindow() ? _draft.window.seconds.toInt() : 0,
        errorText: _windowError,
        onChanged: (seconds) => setState(() {
          _windowError = null;
          if (seconds <= 0) {
            _draft.clearWindow();
          } else {
            _draft.ensureWindow().seconds = Int64(seconds);
          }
        }),
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _approvalTtlField() => TextFormField(
    key: const Key('approvalTtlField'),
    initialValue: _draft.hasApprovalTtl()
        ? formatDuration(_draft.approvalTtl.seconds.toInt())
        : '',
    decoration: const InputDecoration(
      labelText: 'Approval TTL',
      hintText: 'e.g. 24h, 72h — blank uses the service default',
    ),
    validator: (v) {
      final raw = (v ?? '').trim();
      if (raw.isEmpty) return null;
      final seconds = parseDuration(raw);
      if (seconds == null || seconds <= 0) {
        return 'Enter a duration such as 24h or 72h';
      }
      if (seconds < _minApprovalTtlSeconds) {
        return 'Approval TTL must be at least 15m';
      }
      return null;
    },
    onChanged: (v) {
      final seconds = parseDuration(v.trim());
      setState(() {
        if (seconds == null || seconds <= 0) {
          _draft.clearApprovalTtl();
        } else {
          _draft.ensureApprovalTtl().seconds = Int64(seconds);
        }
      });
    },
  );

  Widget _effectiveRangeFields() => Row(
    children: [
      Expanded(
        child: _dateField(
          label: 'Effective from',
          value:
              hasTimestamp(
                _draft.hasEffectiveFrom() ? _draft.effectiveFrom : null,
              )
              ? _draft.effectiveFrom.toDateTime().toLocal()
              : null,
          onPicked: (picked) => setState(() {
            if (picked == null) {
              _draft.clearEffectiveFrom();
            } else {
              _draft.effectiveFrom = timestampFromDateTime(picked);
            }
          }),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _dateField(
          label: 'Effective to',
          value:
              hasTimestamp(_draft.hasEffectiveTo() ? _draft.effectiveTo : null)
              ? _draft.effectiveTo.toDateTime().toLocal()
              : null,
          onPicked: (picked) => setState(() {
            if (picked == null) {
              _draft.clearEffectiveTo();
            } else {
              _draft.effectiveTo = timestampFromDateTime(picked);
            }
          }),
        ),
      ),
    ],
  );

  Widget _dateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onPicked,
  }) => InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: value == null
          ? const Icon(Icons.event)
          : IconButton(
              icon: const Icon(Icons.clear),
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
          lastDate: DateTime(now.year + 10),
        );
        if (picked != null) onPicked(picked);
      },
      child: Text(
        value == null ? 'Not set' : value.toIso8601String().substring(0, 10),
      ),
    ),
  );
}
