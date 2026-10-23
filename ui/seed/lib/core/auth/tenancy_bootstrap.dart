import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether tenancy has been seeded for the current session.
///
/// Held in a provider rather than a router closure so that logging out and
/// back in as a different user re-initialises it, instead of inheriting the
/// previous user's partition and organisation.
class TenancyBootstrap {
  bool _initialized = false;

  bool get isInitialized => _initialized;

  void markInitialized() => _initialized = true;

  void reset() => _initialized = false;
}

final tenancyBootstrapProvider = Provider<TenancyBootstrap>(
  (ref) => TenancyBootstrap(),
);
