import 'package:flutter/foundation.dart' show kReleaseMode;

/// Environment-aware application configuration for Seed.
///
/// Values are injected at build time via `--dart-define` flags. Debug builds
/// fall back to development defaults so `flutter run` works out of the box;
/// release builds have no defaults at all and refuse to start unless the
/// environment was supplied, because a release bundle that quietly points a
/// development client at the production gateway is worse than one that fails.
abstract final class AppConfig {
  // ── Development fallbacks (debug builds only) ───────────────────────────

  static const _devClientId = 'd6qbqdkpf2t52mcunf6g';
  static const _devIssuerUrl = 'https://oauth2.dev.stawi.org';
  static const _devApiBaseUrl = 'http://localhost:8080';

  // ── OAuth2 ────────────────────────────────────────────────────────────────

  static const String _clientIdDefine = String.fromEnvironment(
    'OIDC_CLIENT_ID',
  );
  static const String _issuerDefine = String.fromEnvironment('OIDC_ISSUER');
  static const String _apiBaseDefine = String.fromEnvironment('API_BASE_URL');

  /// OAuth2 client ID for the current environment.
  static String get oauthClientId =>
      _clientIdDefine.isNotEmpty ? _clientIdDefine : _devClientId;

  /// OAuth2 issuer URL (OIDC discovery endpoint).
  static String get oauthIssuerUrl =>
      _issuerDefine.isNotEmpty ? _issuerDefine : _devIssuerUrl;

  // ── Shared base URL ─────────────────────────────────────────────────────

  /// All services are behind the same gateway.
  static String get _apiBaseUrl =>
      _apiBaseDefine.isNotEmpty ? _apiBaseDefine : _devApiBaseUrl;

  /// Names of required defines that were not supplied.
  static List<String> get missingDefines => [
    if (_clientIdDefine.isEmpty) 'OIDC_CLIENT_ID',
    if (_issuerDefine.isEmpty) 'OIDC_ISSUER',
    if (_apiBaseDefine.isEmpty) 'API_BASE_URL',
  ];

  /// Fails a release build at startup when configuration is missing, rather
  /// than letting it run against development defaults. Debug and profile
  /// builds are left alone.
  static void assertConfigured() {
    if (!kReleaseMode) return;
    final missing = missingDefines;
    if (missing.isEmpty) return;
    throw StateError(
      'Seed release build is missing required --dart-define values: '
      '${missing.join(', ')}. Build with `make ui-build-prod`.',
    );
  }

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

  // ── Loans service endpoint ─────────────────────────────────────────

  static const String _loansExplicit = String.fromEnvironment('LOANS_URL');
  static String get loansBaseUrl =>
      _loansExplicit.isNotEmpty ? _loansExplicit : '$_apiBaseUrl/loans';

  // ── Seed service endpoint ──────────────────────────────────────────

  static const String _seedExplicit = String.fromEnvironment('SEED_URL');
  static String get seedBaseUrl =>
      _seedExplicit.isNotEmpty ? _seedExplicit : '$_apiBaseUrl/seed';

  // ── Funding service endpoint ───────────────────────────────────────

  static const String _fundingExplicit = String.fromEnvironment('FUNDING_URL');
  static String get fundingBaseUrl =>
      _fundingExplicit.isNotEmpty ? _fundingExplicit : '$_apiBaseUrl/funding';

  // ── Operations service endpoint ────────────────────────────────────

  static const String _operationsExplicit = String.fromEnvironment(
    'OPERATIONS_URL',
  );
  static String get operationsBaseUrl => _operationsExplicit.isNotEmpty
      ? _operationsExplicit
      : '$_apiBaseUrl/operations';

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
    'loans': loansBaseUrl,
    'seed': seedBaseUrl,
    'funding': fundingBaseUrl,
    'operations': operationsBaseUrl,
    'files': filesBaseUrl,
    'audit': auditBaseUrl,
    'geolocation': geolocationBaseUrl,
    'thesa': thesaBaseUrl,
  };

  // ── Connection settings ─────────────────────────────────────────────────

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
