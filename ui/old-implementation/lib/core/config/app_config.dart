/// Environment-aware application configuration.
///
/// Values are injected at build time via `--dart-define` flags.
/// Defaults are set to **development** so `flutter run` works out of the box.
///
/// ## Endpoint resolution
///
/// Each service URL resolves in this priority order:
///   1. Explicit per-service env var (e.g. `LOANS_URL=https://loans.custom.io`)
///   2. Shared base URL + service path  (e.g. `API_BASE_URL=https://api.example.com` → `.../loans`)
///   3. Built-in default               (domain-specific defaults below)
///
/// This means you can:
/// - Set `API_BASE_URL` once to point all services at a single gateway.
/// - Override individual services that live on a different host.
///
/// ```sh
/// # All services behind one gateway:
/// flutter run --dart-define=API_BASE_URL=https://api.example.com
///
/// # Same, but loans service lives elsewhere:
/// flutter run \
///   --dart-define=API_BASE_URL=https://api.example.com \
///   --dart-define=LOANS_URL=https://loans.internal.io
/// ```
///
/// Production build example:
/// ```
/// make ui-build-prod \
///   OIDC_CLIENT_ID=d6qbqdkpf2t52mcunf60 \
///   OIDC_ISSUER=https://oauth2.stawi.org \
///   API_BASE_URL=https://api.stawi.org
/// ```
abstract final class AppConfig {
  // ── OAuth2 ────────────────────────────────────────────────────────────────

  /// OAuth2 client ID for the current environment.
  static const oauthClientId = String.fromEnvironment(
    'OIDC_CLIENT_ID',
    defaultValue: 'd6qbqdkpf2t52mcunf6g', // dev client
  );

  /// OAuth2 issuer URL (OIDC discovery endpoint).
  static const oauthIssuerUrl = String.fromEnvironment(
    'OIDC_ISSUER',
    defaultValue: 'https://oauth2.stawi.org',
  );

  // ── Shared base URL ─────────────────────────────────────────────────────

  /// When set, provides the default base for all service endpoints.
  /// Individual `*_URL` vars take precedence over this.
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.antinvestor.com',
  );

  /// Platform services use a different default base (stawi gateway).
  static const String _platformBaseUrl = String.fromEnvironment(
    'PLATFORM_BASE_URL',
    defaultValue: 'https://api.stawi.org',
  );

  // ── Fintech service endpoints ───────────────────────────────────────────

  static const String _loansExplicit = String.fromEnvironment('LOANS_URL');
  static String get loansBaseUrl =>
      _loansExplicit.isNotEmpty ? _loansExplicit : '$_apiBaseUrl/loans';

  static const String _identityExplicit =
      String.fromEnvironment('IDENTITY_URL');
  static String get identityBaseUrl =>
      _identityExplicit.isNotEmpty ? _identityExplicit : '$_apiBaseUrl/identity';

  static const String _savingsExplicit =
      String.fromEnvironment('SAVINGS_URL');
  static String get savingsBaseUrl =>
      _savingsExplicit.isNotEmpty ? _savingsExplicit : '$_apiBaseUrl/savings';

  static const String _fundingExplicit =
      String.fromEnvironment('FUNDING_URL');
  static String get fundingBaseUrl =>
      _fundingExplicit.isNotEmpty ? _fundingExplicit : '$_apiBaseUrl/funding';

  static const String _operationsExplicit =
      String.fromEnvironment('OPERATIONS_URL');
  static String get operationsBaseUrl => _operationsExplicit.isNotEmpty
      ? _operationsExplicit
      : '$_apiBaseUrl/operations';

  // ── Platform service endpoints (profile, notification, tenancy, geo) ────

  static const String _profileExplicit =
      String.fromEnvironment('PROFILE_URL');
  static String get profileBaseUrl =>
      _profileExplicit.isNotEmpty ? _profileExplicit : '$_platformBaseUrl/profile';

  static const String _notificationExplicit =
      String.fromEnvironment('NOTIFICATION_URL');
  static String get notificationBaseUrl => _notificationExplicit.isNotEmpty
      ? _notificationExplicit
      : '$_platformBaseUrl/notification';

  static const String _tenancyExplicit =
      String.fromEnvironment('TENANCY_URL');
  static String get tenancyBaseUrl =>
      _tenancyExplicit.isNotEmpty ? _tenancyExplicit : '$_platformBaseUrl/tenancy';

  static const String _geolocationExplicit =
      String.fromEnvironment('GEOLOCATION_URL');
  static String get geolocationBaseUrl => _geolocationExplicit.isNotEmpty
      ? _geolocationExplicit
      : '$_platformBaseUrl/geolocation';

  // ── Files service endpoint ─────────────────────────────────────────

  static const String _filesExplicit = String.fromEnvironment('FILES_URL');
  static String get filesBaseUrl =>
      _filesExplicit.isNotEmpty ? _filesExplicit : '$_platformBaseUrl/files';

  // ── All endpoints (for diagnostics) ─────────────────────────────────────

  /// Returns a map of service name → resolved endpoint URL.
  static Map<String, String> get allEndpoints => {
        'loans': loansBaseUrl,
        'identity': identityBaseUrl,
        'savings': savingsBaseUrl,
        'funding': fundingBaseUrl,
        'operations': operationsBaseUrl,
        'profile': profileBaseUrl,
        'notification': notificationBaseUrl,
        'tenancy': tenancyBaseUrl,
        'geolocation': geolocationBaseUrl,
        'files': filesBaseUrl,
      };

  // ── Connection settings ─────────────────────────────────────────────────

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
