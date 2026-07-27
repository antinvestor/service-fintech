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

  // ── Shared platform apex ────────────────────────────────────────────────

  /// Platform apex (`https://stawi.org`) or legacy gateway (`https://api.stawi.org`).
  /// Service endpoints resolve as `https://{service}.{apex}`.
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://stawi.org',
  );

  static String _serviceUrl(String service) {
    final uri = Uri.parse(_apiBaseUrl);
    var host = uri.host;
    if (host.startsWith('api.')) host = host.substring(4);
    if (host.isEmpty) host = 'stawi.org';
    return 'https://$service.$host';
  }

  // ── Identity service endpoint ───────────────────────────────────────────

  static const String _identityExplicit = String.fromEnvironment(
    'IDENTITY_URL',
  );
  static String get identityBaseUrl => _identityExplicit.isNotEmpty
      ? _identityExplicit
      : _serviceUrl('identity');

  // ── Platform service endpoints (profile, tenancy) ──────────────────────

  static const String _profileExplicit = String.fromEnvironment('PROFILE_URL');
  static String get profileBaseUrl =>
      _profileExplicit.isNotEmpty ? _profileExplicit : _serviceUrl('profile');

  static const String _tenancyExplicit = String.fromEnvironment('TENANCY_URL');
  static String get tenancyBaseUrl =>
      _tenancyExplicit.isNotEmpty ? _tenancyExplicit : _serviceUrl('tenancy');

  // ── Files service endpoint ─────────────────────────────────────────

  static const String _filesExplicit = String.fromEnvironment('FILES_URL');
  static String get filesBaseUrl =>
      _filesExplicit.isNotEmpty ? _filesExplicit : _serviceUrl('files');

  // ── Audit service endpoint ─────────────────────────────────────────

  static const String _auditExplicit = String.fromEnvironment('AUDIT_URL');
  static String get auditBaseUrl =>
      _auditExplicit.isNotEmpty ? _auditExplicit : _serviceUrl('audit');

  // ── Geolocation service endpoint ──────────────────────────────────

  static const String _geolocationExplicit = String.fromEnvironment(
    'GEOLOCATION_URL',
  );
  static String get geolocationBaseUrl => _geolocationExplicit.isNotEmpty
      ? _geolocationExplicit
      : _serviceUrl('geolocation');

  // ── Thesa analytics service endpoint ────────────────────────────────────

  static const String _thesaExplicit = String.fromEnvironment('THESA_BASE_URL');
  static String get thesaBaseUrl =>
      _thesaExplicit.isNotEmpty ? _thesaExplicit : _serviceUrl('thesa');

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
