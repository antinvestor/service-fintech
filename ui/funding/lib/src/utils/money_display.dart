/// Currencies without a minor unit, and those with three decimal places, per
/// ISO 4217. Everything else uses two.
const _zeroDecimal = {
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
const _threeDecimal = {'BHD', 'IQD', 'JOD', 'KWD', 'LYD', 'OMR', 'TND'};

int _decimalsFor(String code) {
  final c = code.trim().toUpperCase();
  if (_zeroDecimal.contains(c)) return 0;
  if (_threeDecimal.contains(c)) return 3;
  return 2;
}

int _pow10(int n) {
  var r = 1;
  for (var i = 0; i < n; i++) {
    r *= 10;
  }
  return r;
}

/// Renders a `Money`-shaped proto for display at its ISO 4217 precision, so a
/// yen amount is never shown with phantom cents and a dinar never loses its
/// third decimal.
///
/// A zero balance is a fact, not a gap: it renders as `0.00` rather than the
/// em-dash the shared helper uses, so an account with no money is never
/// confused with one whose balance could not be read. A genuinely absent
/// value still renders as an em-dash.
String displayMoney(dynamic money) {
  try {
    if (money == null) return '—';
    final units = (money.units as dynamic).toInt() as int;
    final nanos = money.nanos as int;
    final currencyCode = money.currencyCode as String;
    final decimals = _decimalsFor(currencyCode);

    // Units and nanos always carry the same sign, per google.type.Money.
    final negative = units < 0 || nanos < 0;
    final buffer = StringBuffer();
    if (negative) buffer.write('-');
    buffer.write(units.abs().toString());
    if (decimals > 0) {
      final fractional = nanos.abs() ~/ _pow10(9 - decimals);
      buffer.write('.');
      buffer.write(fractional.toString().padLeft(decimals, '0'));
    }

    final formatted = buffer.toString();
    return currencyCode.isEmpty ? formatted : '$currencyCode $formatted';
  } catch (_) {
    return '—';
  }
}
