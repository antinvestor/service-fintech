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
import 'currency_amount_text.dart';

class ApprovalRequestTile extends StatelessWidget {
  final ApprovalRequestObject request;
  final VoidCallback? onTap;
  const ApprovalRequestTile({super.key, required this.request, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(request.status);
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Row(
          children: [
            Expanded(child: Text(limitActionLabel(request.action))),
            CurrencyAmountText(
              amount: request.amount,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'Maker: ${request.makerId}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Role: ${request.requiredRole} (${request.requiredCount})',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Submitted: ${request.submittedAt.toDateTime().toLocal().toString().substring(0, 19)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  approvalStatusLabel(request.status).toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Color _statusColor(ApprovalStatus s) {
    switch (s) {
      case ApprovalStatus.APPROVAL_STATUS_PENDING:
        return Colors.orange.shade700;
      case ApprovalStatus.APPROVAL_STATUS_APPROVED:
        return Colors.green.shade700;
      case ApprovalStatus.APPROVAL_STATUS_REJECTED:
      case ApprovalStatus.APPROVAL_STATUS_AUTO_REJECTED_ON_RECHECK:
        return Colors.red.shade700;
      case ApprovalStatus.APPROVAL_STATUS_EXPIRED:
        return Colors.grey.shade600;
      default:
        return Colors.grey;
    }
  }
}
