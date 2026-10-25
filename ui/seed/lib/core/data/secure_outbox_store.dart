import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart'
    show RegistrationOutboxStore;
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart'
    show OutboxStore;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps an outbox in the device's secure storage under [_key], so work
/// recorded offline survives the app closing.
class SecureOutboxStore implements OutboxStore, RegistrationOutboxStore {
  const SecureOutboxStore(this._storage, {String key = repayments})
    : _key = key;

  /// Repayments recorded while offline.
  static const repayments = 'loans.repayment_outbox';

  /// Borrower registrations captured while offline.
  static const registrations = 'identity.registration_outbox';

  final FlutterSecureStorage _storage;
  final String _key;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
}
