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

import 'package:protobuf/protobuf.dart' show GeneratedMessage;

const _zeroDecimalCurrencies = {
  'BIF',
  'CLP',
  'DJF',
  'GNF',
  'ISK',
  'JPY',
  'KMF',
  'KRW',
  'PYG',
  'RWF',
  'UGX',
  'UYI',
  'VND',
  'VUV',
  'XAF',
  'XOF',
  'XPF',
};
const _threeDecimalCurrencies = {
  'BHD',
  'IQD',
  'JOD',
  'KWD',
  'LYD',
  'OMR',
  'TND',
};

/// ISO 4217 fractional digits for [code]. Amounts must never assume 2:
/// a KWD cap of 1.234 loses its last digit and a JPY cap gains two.
int currencyDecimals(String code) {
  final c = code.trim().toUpperCase();
  if (_zeroDecimalCurrencies.contains(c)) return 0;
  if (_threeDecimalCurrencies.contains(c)) return 3;
  return 2;
}

/// Renders a `Money`-shaped proto as the plain decimal string an operator
/// edits, at the currency's own precision.
String moneyToEditString(dynamic money) {
  if (money == null) return '';
  final int units = (money.units as dynamic).toInt() as int;
  final int nanos = money.nanos as int;
  final decimals = currencyDecimals(money.currencyCode as String);
  final negative = units < 0 || nanos < 0;
  final absUnits = units.abs();
  final absNanos = nanos.abs();
  if (decimals == 0) return '${negative ? '-' : ''}$absUnits';
  var divisor = 1;
  for (var i = 0; i < 9 - decimals; i++) {
    divisor *= 10;
  }
  final fractional = absNanos ~/ divisor;
  final frac = fractional.toString().padLeft(decimals, '0');
  return '${negative ? '-' : ''}$absUnits.$frac';
}

/// Whether a `Money`-shaped proto carries a strictly positive amount.
bool moneyIsPositive(dynamic money) {
  if (money == null) return false;
  final int units = (money.units as dynamic).toInt() as int;
  final int nanos = money.nanos as int;
  return units > 0 || (units == 0 && nanos > 0);
}

/// Formats a `google.protobuf.Timestamp` for display, or returns [placeholder]
/// when it is unset. An unset timestamp otherwise renders as 1970-01-01, which
/// reads as real data.
String formatTimestamp(
  GeneratedMessage? timestamp, {
  String placeholder = '—',
  bool includeTime = true,
}) {
  if (timestamp == null) return placeholder;
  final seconds = ((timestamp as dynamic).seconds as dynamic).toInt() as int;
  final nanos = (timestamp as dynamic).nanos as int;
  if (seconds == 0 && nanos == 0) return placeholder;
  final local = (timestamp as dynamic).toDateTime().toLocal() as DateTime;
  final iso = local.toIso8601String();
  return includeTime
      ? iso.substring(0, 19).replaceFirst('T', ' ')
      : iso.substring(0, 10);
}

/// Whether a `google.protobuf.Timestamp` carries a real value.
bool hasTimestamp(dynamic timestamp) {
  if (timestamp == null) return false;
  final seconds = (timestamp.seconds as dynamic).toInt() as int;
  return seconds != 0 || (timestamp.nanos as int) != 0;
}
