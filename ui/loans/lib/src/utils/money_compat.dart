// Money compatibility helpers.
//
// The loans SDK bundles its own copy of Money and common proto types, which
// are different Dart classes from antinvestor_api_common despite having
// identical proto structure. These helpers use dynamic dispatch to bridge
// the gap.

import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:fixnum/fixnum.dart';

/// Placeholder shown when there is genuinely no amount to show — a null or
/// unreadable message. A zero balance is a real amount and renders as zero.
const _noAmount = '\u2014';

const _nanosPerUnit = 1000000000;

/// ISO-4217 minor-unit digits for the currencies that are not two-decimal.
/// Rendering a JPY amount with two decimals overstates it by a factor of a
/// hundred to the reader; a KWD amount with two hides a real digit.
const _currencyDecimals = <String, int>{
  'BHD': 3,
  'BIF': 0,
  'CLP': 0,
  'DJF': 0,
  'GNF': 0,
  'IQD': 3,
  'ISK': 0,
  'JOD': 3,
  'JPY': 0,
  'KMF': 0,
  'KRW': 0,
  'KWD': 3,
  'LYD': 3,
  'OMR': 3,
  'PYG': 0,
  'RWF': 0,
  'TND': 3,
  'UGX': 0,
  'UYI': 0,
  'VND': 0,
  'VUV': 0,
  'XAF': 0,
  'XOF': 0,
  'XPF': 0,
};

/// Number of fraction digits a currency is written with.
int loanCurrencyDecimals(String currencyCode) =>
    _currencyDecimals[currencyCode.toUpperCase()] ?? 2;

/// Parsed view of a Money-like message, in whole units and nanos.
class _MoneyParts {
  const _MoneyParts(this.units, this.nanos, this.currency);
  final int units;
  final int nanos;
  final String currency;
}

_MoneyParts? _parseMoney(dynamic money) {
  if (money == null) return null;
  try {
    final units = (money.units as dynamic).toInt() as int;
    final nanos = money.nanos as int;
    final currency = (money.currencyCode as String?) ?? '';
    return _MoneyParts(units, nanos, currency);
  } catch (_) {
    return null;
  }
}

/// Renders a Money-like message as a decimal string, without the currency.
/// Handles negatives (units and nanos carry the same sign) and honours the
/// currency's own number of fraction digits.
String _formatParts(_MoneyParts parts) {
  final decimals = loanCurrencyDecimals(parts.currency);
  final negative = parts.units < 0 || parts.nanos < 0;
  final absUnits = parts.units.abs();
  final absNanos = parts.nanos.abs();

  final sign = negative ? '-' : '';
  if (decimals == 0) {
    // Round the fraction into the unit so a 0-decimal currency never shows
    // a value that is silently a whole unit short.
    final rounded = absNanos * 2 >= _nanosPerUnit ? absUnits + 1 : absUnits;
    return '$sign$rounded';
  }

  final scale = _pow10(decimals);
  final fraction = (absNanos * scale) ~/ _nanosPerUnit;
  return '$sign$absUnits.${fraction.toString().padLeft(decimals, '0')}';
}

int _pow10(int exponent) {
  var value = 1;
  for (var i = 0; i < exponent; i++) {
    value *= 10;
  }
  return value;
}

/// Formats a Money proto message for display. Accepts any Money-like object.
/// A zero amount renders as zero, not as a dash: a paid-off loan owes
/// "KES 0.00", and showing a dash there reads as missing data.
String formatLoanMoney(dynamic money) {
  final parts = _parseMoney(money);
  if (parts == null) return _noAmount;

  final formatted = _formatParts(parts);
  if (parts.currency.isEmpty) return formatted;
  return '${parts.currency} $formatted';
}

/// Extracts the amount string from a Money proto message, without a currency.
String loanMoneyToAmountString(dynamic money) {
  final parts = _parseMoney(money);
  if (parts == null) return '';
  return _formatParts(parts);
}

/// Extracts the currency code from a Money proto message.
String loanMoneyCurrency(dynamic money, [String fallback = '']) {
  final parts = _parseMoney(money);
  if (parts == null || parts.currency.isEmpty) return fallback;
  return parts.currency;
}

/// Validates an amount string.
String? validateAmount(String? value) {
  if (value == null || value.trim().isEmpty) return 'Amount is required';
  final parsed = double.tryParse(value.trim());
  if (parsed == null || parsed <= 0) return 'Enter a valid positive amount';
  return null;
}

/// Validates a required field.
String? validateRequired(String? value, [String field = 'This field']) {
  if (value == null || value.trim().isEmpty) return '$field is required';
  return null;
}

/// Creates a loans-SDK Money from a decimal amount string and currency code.
Money loanMoneyFromString(String amount, String currencyCode) {
  final money = Money();
  money.currencyCode = currencyCode;
  final cleaned = amount.trim();
  if (cleaned.isEmpty) return money;
  final parts = cleaned.split('.');
  money.units = Int64(int.tryParse(parts[0]) ?? 0);
  if (parts.length > 1) {
    final fractional = parts[1].padRight(9, '0').substring(0, 9);
    money.nanos = int.tryParse(fractional) ?? 0;
  }
  return money;
}
