import 'dart:async';

import 'package:antinvestor_ui_core/antinvestor_ui_core.dart'
    show formatMoney, friendlyError;
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart'
    show LoanStatusBadge, loanAccountListProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Searches loan accounts so staff can say which loan an unmatched payment
/// belongs to. Returns the chosen loan account id.
Future<String?> pickLoanAccount(BuildContext context) => showDialog<String>(
  context: context,
  builder: (_) => const LoanPickerDialog(),
);

class LoanPickerDialog extends ConsumerStatefulWidget {
  const LoanPickerDialog({super.key});

  @override
  ConsumerState<LoanPickerDialog> createState() => _LoanPickerDialogState();
}

class _LoanPickerDialogState extends ConsumerState<LoanPickerDialog> {
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loans = ref.watch(
      loanAccountListProvider((
        query: _query,
        status: null,
        agentId: '',
        clientId: '',
        limit: 20,
      )),
    );
    return AlertDialog(
      title: const Text('Find loan'),
      content: SizedBox(
        width: 480,
        height: 420,
        child: Column(
          children: [
            TextField(
              key: const Key('loan-picker-search'),
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by loan or client',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 350), () {
                  if (mounted) setState(() => _query = value.trim());
                });
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: loans.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(friendlyError(e))),
                data: (page) => page.items.isEmpty
                    ? const Center(child: Text('No loans match'))
                    : ListView(
                        children: [
                          for (final loan in page.items)
                            ListTile(
                              key: Key('loan-picker-${loan.id}'),
                              title: Text(loan.id),
                              subtitle: Text(
                                'Client ${loan.clientId} · '
                                '${formatMoney(loan.principalAmount)}',
                              ),
                              trailing: LoanStatusBadge(status: loan.status),
                              onTap: () => Navigator.of(context).pop(loan.id),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
