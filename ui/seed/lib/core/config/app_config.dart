/// Environment-aware application configuration for Seed.
///
/// Values are injected at build time via `--dart-define` flags.
/// Defaults are set to **development** so `flutter run` works out of the box.
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

  /// All services are behind the same gateway.
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.stawi.org',
  );

  // ── Identity service endpoint ───────────────────────────────────────────

  static const String _identityExplicit = String.fromEnvironment(
    'IDENTITY_URL',
  );
  static String get identityBaseUrl => _identityExplicit.isNotEmpty
      ? _identityExplicit
      : '$_apiBaseUrl/identity';

  // ── Platform service endpoints (profile, tenancy) ──────────────────────

  static const String _profileExplicit = String.fromEnvironment('PROFILE_URL');
  static String get profileBaseUrl =>
      _profileExplicit.isNotEmpty ? _profileExplicit : '$_apiBaseUrl/profile';

  static const String _tenancyExplicit = String.fromEnvironment('TENANCY_URL');
  static String get tenancyBaseUrl =>
      _tenancyExplicit.isNotEmpty ? _tenancyExplicit : '$_apiBaseUrl/tenancy';

  // ── Files service endpoint ─────────────────────────────────────────

  static const String _filesExplicit = String.fromEnvironment('FILES_URL');
  static String get filesBaseUrl =>
      _filesExplicit.isNotEmpty ? _filesExplicit : '$_apiBaseUrl/files';

  // ── Audit service endpoint ─────────────────────────────────────────

  static const String _auditExplicit = String.fromEnvironment('AUDIT_URL');
  static String get auditBaseUrl =>
      _auditExplicit.isNotEmpty ? _auditExplicit : '$_apiBaseUrl/audit';

  // ── Geolocation service endpoint ──────────────────────────────────

  static const String _geolocationExplicit = String.fromEnvironment(
    'GEOLOCATION_URL',
  );
  static String get geolocationBaseUrl => _geolocationExplicit.isNotEmpty
      ? _geolocationExplicit
      : '$_apiBaseUrl/geolocation';

  // ── Thesa analytics service endpoint ────────────────────────────────────

  static const String _thesaExplicit = String.fromEnvironment('THESA_BASE_URL');
  static String get thesaBaseUrl =>
      _thesaExplicit.isNotEmpty ? _thesaExplicit : '$_apiBaseUrl/thesa';

  // ── All endpoints (for diagnostics) ─────────────────────────────────────

  static Map<String, String> get allEndpoints => {
    'identity': identityBaseUrl,
    'profile': profileBaseUrl,
    'tenancy': tenancyBaseUrl,
    'files': filesBaseUrl,
    'audit': auditBaseUrl,
    'geolocation': geolocationBaseUrl,
    'thesa': thesaBaseUrl,
  };

  // ── Connection settings ─────────────────────────────────────────────────

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
