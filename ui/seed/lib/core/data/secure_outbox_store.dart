import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart'
    show OutboxStore;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the repayment outbox in the device's secure storage, so repayments
/// recorded offline survive the app closing.
class SecureOutboxStore implements OutboxStore {
  const SecureOutboxStore(this._storage);

  static const _key = 'loans.repayment_outbox';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
}
