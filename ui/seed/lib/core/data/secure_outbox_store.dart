import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart'
    show OnboardingFormCache, RegistrationOutboxStore;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps an outbox in the device's secure storage under [_key], so work
/// recorded offline survives the app closing.
class SecureOutboxStore
    implements RegistrationOutboxStore, OnboardingFormCache {
  const SecureOutboxStore(this._storage, {required String key}) : _key = key;

  /// Where repayments recorded offline used to be queued. Nobody records a
  /// repayment by hand any more, so anything left there is discarded.
  static const retiredRepayments = 'loans.repayment_outbox';

  /// Borrower registrations captured while offline.
  static const registrations = 'identity.registration_outbox';

  /// The organization's client form, so onboarding offline asks for it.
  static const onboardingForm = 'identity.onboarding_form';

  final FlutterSecureStorage _storage;
  final String _key;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
}
