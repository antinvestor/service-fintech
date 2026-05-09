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

const _commonCurrencies = ['KES', 'USD', 'EUR', 'GBP', 'UGX', 'TZS', 'JPY', 'KWD'];

/// Edits a money-cap value as a free-text amount + currency dropdown.
///
/// Emits the raw `(amount, currency)` strings on every change so the
/// caller can populate any service-specific Money proto via
/// `setMoneyFields(target, amount, currency)`. Emits `(null, currency)`
/// when the field is cleared.
class CapAmountField extends StatefulWidget {
  final String? initialAmount;
  final String? initialCurrency;
  final void Function(String? amount, String currency) onChanged;
  final String label;
  const CapAmountField({
    super.key,
    this.initialAmount,
    this.initialCurrency,
    required this.onChanged,
    this.label = 'Cap',
  });

  @override
  State<CapAmountField> createState() => _CapAmountFieldState();
}

class _CapAmountFieldState extends State<CapAmountField> {
  late TextEditingController _amountCtrl;
  late String _currency;

  @override
  void initState() {
    super.initState();
    _currency = widget.initialCurrency?.isNotEmpty == true
        ? widget.initialCurrency!
        : 'KES';
    _amountCtrl = TextEditingController(text: widget.initialAmount ?? '');
  }

  void _emit() {
    final raw = _amountCtrl.text.trim();
    widget.onChanged(raw.isEmpty ? null : raw, _currency);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: widget.label),
            onChanged: (_) => _emit(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            initialValue: _currency,
            decoration: const InputDecoration(labelText: 'Currency'),
            items: _commonCurrencies
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _currency = v);
                _emit();
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }
}
