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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/approval_providers.dart';
import '../utils/enum_labels.dart';
import '../widgets/approval_decision_form.dart';
import '../widgets/approval_decision_timeline.dart';
import '../widgets/currency_amount_text.dart';

class ApprovalRequestDetailScreen extends ConsumerWidget {
  final String requestId;
  const ApprovalRequestDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncReq = ref.watch(approvalDetailProvider(requestId));
    return Scaffold(
      appBar: AppBar(title: const Text('Approval request')),
      body: asyncReq.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (req) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _kv('Reservation', req.reservationId),
                      _kv('Action', limitActionLabel(req.action)),
                      _kvWidget(
                        'Amount',
                        CurrencyAmountText(amount: req.amount),
                      ),
                      _kv(
                        'Triggering policy',
                        '${req.triggeringPolicyId} (v${req.policyVersion})',
                      ),
                      _kv('Required role', req.requiredRole),
                      _kv('Required count', '${req.requiredCount}'),
                      _kv('Maker', req.makerId),
                      _kv('Status', approvalStatusLabel(req.status)),
                      _kv(
                        'Submitted',
                        req.submittedAt
                            .toDateTime()
                            .toLocal()
                            .toString()
                            .substring(0, 19),
                      ),
                      _kv(
                        'Expires',
                        req.expiresAt
                            .toDateTime()
                            .toLocal()
                            .toString()
                            .substring(0, 19),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Decisions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ApprovalDecisionTimeline(decisions: req.decisions),
                ),
              ),
              if (req.status == ApprovalStatus.APPROVAL_STATUS_PENDING) ...[
                const SizedBox(height: 16),
                ApprovalDecisionForm(approvalId: req.id),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(String key, String value) => _kvWidget(key, Text(value));

  Widget _kvWidget(String key, Widget value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                key,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ),
            Expanded(child: value),
          ],
        ),
      );
}
