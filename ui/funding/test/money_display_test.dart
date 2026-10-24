import 'package:antinvestor_api_common/antinvestor_api_common.dart';
import 'package:antinvestor_ui_funding/antinvestor_ui_funding.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('displayMoney', () {
    test('renders a zero balance as zero, not as a gap', () {
      final zero = Money(currencyCode: 'KES', units: Int64.ZERO, nanos: 0);
      expect(displayMoney(zero), 'KES 0.00');
    });

    test('renders a fractional amount to two places', () {
      final amount = Money(
        currencyCode: 'KES',
        units: Int64(1234),
        nanos: 500000000,
      );
      expect(displayMoney(amount), 'KES 1234.50');
    });

    test('renders a zero-decimal currency without phantom cents', () {
      final yen = Money(currencyCode: 'JPY', units: Int64(1500), nanos: 0);
      expect(displayMoney(yen), 'JPY 1500');
    });

    test('renders a three-decimal currency at full precision', () {
      final dinar = Money(
        currencyCode: 'KWD',
        units: Int64(12),
        nanos: 345000000,
      );
      expect(displayMoney(dinar), 'KWD 12.345');
    });

    test('keeps the sign on a negative amount', () {
      final owed = Money(
        currencyCode: 'KES',
        units: Int64(-7),
        nanos: -250000000,
      );
      expect(displayMoney(owed), 'KES -7.25');
    });

    test('renders an absent amount as an em-dash', () {
      expect(displayMoney(null), '—');
    });

    test('omits the currency when the code is empty', () {
      final amount = Money(units: Int64(5), nanos: 0);
      expect(displayMoney(amount), '5.00');
    });
  });
}
