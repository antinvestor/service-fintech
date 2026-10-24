import 'package:antinvestor_ui_loans/src/utils/money_compat.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stand-in for the Money message. The helpers read it dynamically, exactly
/// as they do the two structurally identical Money classes in the real app.
class _Money {
  const _Money(this.units, this.nanos, this.currencyCode);
  final int units;
  final int nanos;
  final String currencyCode;
}

void main() {
  group('formatLoanMoney', () {
    test('renders a zero balance as zero, not as a dash', () {
      expect(formatLoanMoney(const _Money(0, 0, 'KES')), 'KES 0.00');
    });

    test('renders a whole and fractional amount', () {
      expect(
        formatLoanMoney(const _Money(1234, 560000000, 'KES')),
        'KES 1234.56',
      );
    });

    test('renders a negative amount with a single leading sign', () {
      expect(formatLoanMoney(const _Money(-5, -500000000, 'KES')), 'KES -5.50');
    });

    test('honours a zero-decimal currency', () {
      expect(formatLoanMoney(const _Money(1500, 0, 'JPY')), 'JPY 1500');
    });

    test('rounds a fraction into the unit for a zero-decimal currency', () {
      expect(formatLoanMoney(const _Money(1500, 600000000, 'JPY')), 'JPY 1501');
    });

    test('keeps all three digits of a three-decimal currency', () {
      expect(formatLoanMoney(const _Money(12, 345000000, 'KWD')), 'KWD 12.345');
    });

    test('omits the currency when the message carries none', () {
      expect(formatLoanMoney(const _Money(7, 250000000, '')), '7.25');
    });

    test('falls back to a placeholder for a null or unreadable amount', () {
      expect(formatLoanMoney(null), '—');
      expect(formatLoanMoney(Object()), '—');
    });
  });

  group('loanMoneyToAmountString', () {
    test('drops the currency but keeps the value', () {
      expect(
        loanMoneyToAmountString(const _Money(1234, 560000000, 'KES')),
        '1234.56',
      );
    });

    test('returns zero for a zero amount', () {
      expect(loanMoneyToAmountString(const _Money(0, 0, 'KES')), '0.00');
    });

    test('returns an empty string when there is no amount at all', () {
      expect(loanMoneyToAmountString(null), '');
    });
  });

  group('loanMoneyCurrency', () {
    test('returns the currency code', () {
      expect(loanMoneyCurrency(const _Money(1, 0, 'UGX')), 'UGX');
    });

    test('falls back when the message has no currency', () {
      expect(loanMoneyCurrency(const _Money(1, 0, ''), 'KES'), 'KES');
      expect(loanMoneyCurrency(null, 'KES'), 'KES');
    });
  });

  group('loanCurrencyDecimals', () {
    test('defaults to two digits', () {
      expect(loanCurrencyDecimals('KES'), 2);
      expect(loanCurrencyDecimals('USD'), 2);
    });

    test('knows the zero- and three-decimal currencies', () {
      expect(loanCurrencyDecimals('JPY'), 0);
      expect(loanCurrencyDecimals('ugx'), 0);
      expect(loanCurrencyDecimals('KWD'), 3);
    });
  });

  group('validateAmount', () {
    test('rejects an empty, zero or negative amount', () {
      expect(validateAmount(null), isNotNull);
      expect(validateAmount('  '), isNotNull);
      expect(validateAmount('0'), isNotNull);
      expect(validateAmount('-5'), isNotNull);
      expect(validateAmount('abc'), isNotNull);
    });

    test('accepts a positive amount', () {
      expect(validateAmount('1500.50'), isNull);
    });
  });
}
