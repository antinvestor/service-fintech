import 'package:antinvestor_ui_savings/antinvestor_ui_savings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('generateIdempotencyKey', () {
    test('produces a 32-character hex key', () {
      final key = generateIdempotencyKey();
      expect(key, matches(RegExp(r'^[0-9a-f]{32}$')));
    });

    test('produces a distinct key per call', () {
      final keys = List.generate(50, (_) => generateIdempotencyKey());
      expect(keys.toSet().length, 50);
    });
  });
}
