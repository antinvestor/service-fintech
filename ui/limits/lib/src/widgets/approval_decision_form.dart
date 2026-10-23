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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/approval_providers.dart';

class ApprovalDecisionForm extends ConsumerStatefulWidget {
  final String approvalId;
  final VoidCallback? onSuccess;
  const ApprovalDecisionForm({
    super.key,
    required this.approvalId,
    this.onSuccess,
  });

  @override
  ConsumerState<ApprovalDecisionForm> createState() =>
      _ApprovalDecisionFormState();
}

class _ApprovalDecisionFormState extends ConsumerState<ApprovalDecisionForm> {
  String _decision = 'approve';
  final _noteCtrl = TextEditingController();

  Future<void> _submit() async {
    try {
      await ref
          .read(approvalDecisionProvider.notifier)
          .decide(
            id: widget.approvalId,
            decision: _decision,
            note: _noteCtrl.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Decision recorded')));
      widget.onSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Decide failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(approvalDecisionProvider);
    final loading = state.isLoading;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Decision',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _decision,
              onChanged: (v) => setState(() => _decision = v ?? _decision),
              child: Row(
                children: [
                  const Radio<String>(value: 'approve'),
                  const Text('Approve'),
                  const SizedBox(width: 16),
                  const Radio<String>(value: 'reject'),
                  const Text('Reject'),
                ],
              ),
            ),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'Required for reject; optional for approve.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _decision == 'approve'
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  loading
                      ? 'Submitting…'
                      : (_decision == 'approve' ? 'Approve' : 'Reject'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }
}
