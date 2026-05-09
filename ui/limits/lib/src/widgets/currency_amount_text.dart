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

const _zeroDecimal = {
  'BIF', 'CLP', 'DJF', 'GNF', 'ISK', 'JPY', 'KMF', 'KRW',
  'PYG', 'RWF', 'UGX', 'UYI', 'VND', 'VUV', 'XAF', 'XOF', 'XPF',
};
const _threeDecimal = {'BHD', 'IQD', 'JOD', 'KWD', 'LYD', 'OMR', 'TND'};

int _decimalsFor(String code) {
  final c = code.trim().toUpperCase();
  if (_zeroDecimal.contains(c)) return 0;
  if (_threeDecimal.contains(c)) return 3;
  return 2;
}

/// Renders a `Money`-shaped value (any generated proto Money) with the
/// right ISO 4217 precision.
class CurrencyAmountText extends StatelessWidget {
  final dynamic amount;
  final TextStyle? style;
  final bool showCurrency;

  const CurrencyAmountText({
    super.key,
    required this.amount,
    this.style,
    this.showCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    if (amount == null) return Text('—', style: style);
    final String code = amount.currencyCode as String;
    final decimals = _decimalsFor(code);
    final units = (amount.units as dynamic).toInt() as int;
    final int nanos = amount.nanos as int;

    // Sign: units and nanos always agree per google.type.Money semantics.
    final negative = units < 0 || nanos < 0;
    final absUnits = units.abs();
    final absNanos = nanos.abs();

    final buffer = StringBuffer();
    if (negative) buffer.write('-');
    buffer.write(absUnits.toString());

    if (decimals > 0) {
      // Convert nanos (10^-9) to the target precision.
      // 1 nano = 10^-9 unit; 1 minor unit at decimals=2 = 10^-2 unit = 10^7 nanos.
      // To extract `decimals` fractional digits from nanos: divide by 10^(9-decimals).
      final divisor = _pow10(9 - decimals);
      final fractional = absNanos ~/ divisor;
      buffer.write('.');
      buffer.write(fractional.toString().padLeft(decimals, '0'));
    }

    if (showCurrency) {
      buffer.write(' ');
      buffer.write(code);
    }
    return Text(buffer.toString(), style: style);
  }
}

int _pow10(int n) {
  var r = 1;
  for (var i = 0; i < n; i++) {
    r *= 10;
  }
  return r;
}
