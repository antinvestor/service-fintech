import 'dart:math';

/// Generates the key that makes a money-moving or state-creating request
/// safe to retry. Mint it once per dialog, in `initState`: generating it per
/// submit means a user retrying a request that timed out sends a different
/// key, and the service treats the retry as a second real operation.
String generateIdempotencyKey() {
  final rand = Random.secure();
  final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
