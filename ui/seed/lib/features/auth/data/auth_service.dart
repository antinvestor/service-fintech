import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:openid_client/openid_client.dart';

import '../../../core/config/auth_constants.dart';
import 'package:antinvestor_ui_core/logging/app_logger.dart';
import 'platform/auth_platform.dart';
import 'platform/auth_platform_stub.dart'
    if (dart.library.io) 'platform/auth_platform_io.dart'
    if (dart.library.js_interop) 'platform/auth_platform_web.dart';

class AuthService {
  AuthService(
    this._storage, {
    required String issuerUrl,
    required String clientId,
    http.Client? httpClient,
  }) : _issuerUrl = issuerUrl,
       _activeClientId = clientId,
       _defaultClientId = clientId,
       _httpClient = httpClient ?? http.Client();

  final FlutterSecureStorage _storage;
  final String _issuerUrl;
  final String _defaultClientId;
  final http.Client _httpClient;
  String _activeClientId;
  final AuthPlatform _platform = getAuthPlatform();

  static const _defaultTokenLifetime = Duration(hours: 1);

  // ── In-memory cache ──────────────────────────────────────────────────────
  bool? _cachedIsAuthenticated;
  String? _cachedAccessToken;
  DateTime? _cachedExpiresAt;
  Timer? _refreshTimer;

  Completer<bool>? _redirectCompleter;
  Completer<TokenResponse?>? _refreshCompleter;

  // ── Initialization ───────────────────────────────────────────────────────

  Future<void> _ensureInitialized() async {
    await _platform.initialize(_issuerUrl, _activeClientId);
  }

  Future<void> switchClient(String clientId) async {
    if (clientId == _activeClientId) return;
    if (!clientIdPattern.hasMatch(clientId)) {
      AppLogger.warning('Invalid clientId format rejected: $clientId');
      return;
    }
    _activeClientId = clientId;
    _platform.reset();
    await _storage.write(key: 'selected_client_id', value: clientId);
  }

  Future<void> restoreSelectedClient() async {
    final stored = await _storage.read(key: 'selected_client_id');
    if (stored != null && stored.isNotEmpty) {
      _activeClientId = stored;
    }
  }

  String get activeClientId => _activeClientId;

  // ── Authentication ───────────────────────────────────────────────────────

  Future<TokenResponse?> authenticate() async {
    try {
      await _ensureInitialized();

      final token = await _platform.authenticate([
        'openid',
        'profile',
        'offline_access',
      ]);

      if (token != null) {
        if (token.accessToken == null || token.accessToken!.isEmpty) {
          throw Exception('Authentication failed: No access token received');
        }
        await _saveTokens(token);
        return token;
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Authentication failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> cancelAuthentication() async {
    try {
      await _platform.cancelAuthentication();
    } catch (_) {}
  }

  // ── Token storage ────────────────────────────────────────────────────────

  Future<void> _saveTokens(TokenResponse token) async {
    final expiresAt =
        token.expiresAt ?? DateTime.now().add(_defaultTokenLifetime);

    _cachedAccessToken = token.accessToken;
    _cachedExpiresAt = expiresAt;
    _cachedIsAuthenticated = true;

    // On web the access token is never written to storage: it lives for one
    // page lifetime and is re-minted from the refresh token after a reload,
    // so an XSS read of browser storage cannot lift a usable bearer token.
    if (!kIsWeb) {
      await _storage.write(key: 'access_token', value: token.accessToken);
    }
    await _storage.write(key: 'refresh_token', value: token.refreshToken);
    try {
      await _storage.write(
        key: 'id_token',
        value: token.idToken.toCompactSerialization(),
      );
    } catch (_) {}
    await _storage.write(
      key: 'token_expires_at',
      value: expiresAt.millisecondsSinceEpoch.toString(),
    );

    _scheduleRefresh(expiresAt);
  }

  void _scheduleRefresh(DateTime expiresAt) {
    _refreshTimer?.cancel();
    final refreshAt = expiresAt
        .subtract(const Duration(minutes: 2))
        .difference(DateTime.now());
    if (refreshAt.isNegative) {
      refreshToken();
      return;
    }
    _refreshTimer = Timer(refreshAt, () {
      refreshToken();
    });
  }

  // ── Token reads (cache-first) ────────────────────────────────────────────

  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    if (kIsWeb) return null;
    final token = await _storage.read(key: 'access_token');
    _cachedAccessToken = token;
    return token;
  }

  Future<String?> getRefreshToken() async =>
      _storage.read(key: 'refresh_token');

  Future<String?> getIdToken() async => _storage.read(key: 'id_token');

  bool _isTokenExpiredSync() {
    if (_cachedExpiresAt == null) return true;
    return DateTime.now().isAfter(
      _cachedExpiresAt!.subtract(const Duration(minutes: 2)),
    );
  }

  Future<bool> isTokenExpired({
    Duration buffer = const Duration(minutes: 2),
  }) async {
    if (_cachedExpiresAt != null) {
      return DateTime.now().isAfter(_cachedExpiresAt!.subtract(buffer));
    }
    final expiresAtStr = await _storage.read(key: 'token_expires_at');
    if (expiresAtStr == null) return true;
    try {
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        int.parse(expiresAtStr),
      );
      _cachedExpiresAt = expiresAt;
      return DateTime.now().isAfter(expiresAt.subtract(buffer));
    } catch (_) {
      return true;
    }
  }

  // ── Token refresh ────────────────────────────────────────────────────────

  Future<TokenResponse?> refreshToken() async {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<TokenResponse?>();

    try {
      final refreshTokenValue = await getRefreshToken();
      if (refreshTokenValue == null) {
        _refreshCompleter!.complete(null);
        return null;
      }

      await _ensureInitialized();

      if (_platform.client == null) {
        _refreshCompleter!.complete(null);
        return null;
      }

      final credential = _platform.client!.createCredential(
        accessToken: await getAccessToken(),
        refreshToken: refreshTokenValue,
      );

      final newCredential = await credential
          .getTokenResponse(true)
          .timeout(const Duration(seconds: 30));

      if (newCredential.accessToken == null ||
          newCredential.accessToken!.isEmpty) {
        _refreshCompleter!.complete(null);
        return null;
      }

      await _saveTokens(newCredential);
      _refreshCompleter!.complete(newCredential);
      return newCredential;
    } catch (e, stackTrace) {
      AppLogger.error('Token refresh failed', error: e, stackTrace: stackTrace);

      final errorStr = e.toString().toLowerCase();
      final isPermanent = _isPermanentRefreshError(errorStr);

      if (isPermanent) {
        await logout();
      }

      _refreshCompleter!.complete(null);
      return null;
    } finally {
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(null);
      }
      _refreshCompleter = null;
    }
  }

  /// Classifies a refresh failure from the structured OAuth2 `error` code
  /// (RFC 6749 §5.2) rather than from substrings of the message. Matching on
  /// free text mistook any error whose message happened to contain "dns" or
  /// "500" for a transient one and kept revoked sessions alive.
  static final _oauthErrorPattern = RegExp(
    r'\b(invalid_grant|invalid_client|unauthorized_client|invalid_request|'
    r'unsupported_grant_type|invalid_scope|access_denied)\b',
  );

  bool _isPermanentRefreshError(String errorStr) =>
      _oauthErrorPattern.hasMatch(errorStr);

  Future<String?> ensureValidAccessToken() async {
    final accessToken = _cachedAccessToken ?? await getAccessToken();
    if (accessToken != null && !_isTokenExpiredSync()) {
      return accessToken;
    }

    if (accessToken != null && _cachedExpiresAt == null) {
      final expired = await isTokenExpired();
      if (!expired) return accessToken;
    }

    final refreshTokenValue = await getRefreshToken();
    if (refreshTokenValue == null) return null;

    // A failed refresh means there is no valid token; returning the stale
    // one would send a request that is certain to 401.
    final result = await refreshToken();
    return result?.accessToken;
  }

  Future<String?> forceRefreshAccessToken() async {
    _cachedAccessToken = null;
    _cachedExpiresAt = null;
    final result = await refreshToken();
    return result?.accessToken;
  }

  // ── Auth state check (cached) ────────────────────────────────────────────

  bool? get isAuthenticatedSync => _cachedIsAuthenticated;

  /// Whether the session is usable right now.
  ///
  /// A stored token string is not a session: an expired access token whose
  /// refresh token the IdP has revoked must report unauthenticated so the
  /// router sends the user to login, rather than rendering an app in which
  /// every call 401s. So this resolves to true only when a non-expired
  /// access token exists or a refresh actually produces one.
  Future<bool> isAuthenticated() async {
    if (_cachedIsAuthenticated != null) return _cachedIsAuthenticated!;

    if (_platform.hasRedirectResult()) {
      await _handleRedirectResult();
      if (_cachedIsAuthenticated == true) return true;
    }

    final accessToken = await getAccessToken();
    if (accessToken != null && !await isTokenExpired()) {
      _cachedIsAuthenticated = true;
      if (_cachedExpiresAt != null) {
        _scheduleRefresh(_cachedExpiresAt!);
      }
      _ensureInitialized().ignore();
      return true;
    }

    final refreshTokenValue = await getRefreshToken();
    if (refreshTokenValue == null) {
      _cachedIsAuthenticated = false;
      return false;
    }

    await _ensureInitialized();
    final refreshed = await refreshToken();
    _cachedIsAuthenticated = refreshed?.accessToken?.isNotEmpty ?? false;
    return _cachedIsAuthenticated!;
  }

  Future<bool> _handleRedirectResult() async {
    if (_redirectCompleter != null && !_redirectCompleter!.isCompleted) {
      return _redirectCompleter!.future;
    }

    _redirectCompleter = Completer<bool>();

    try {
      await _ensureInitialized();
      final token = await _platform.getRedirectResult();
      if (token != null) {
        await _saveTokens(token);
        _redirectCompleter!.complete(true);
        return true;
      }
      _redirectCompleter!.complete(false);
      return false;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Redirect result handling failed',
        error: e,
        stackTrace: stackTrace,
      );
      _redirectCompleter!.complete(false);
      return false;
    } finally {
      if (_redirectCompleter != null && !_redirectCompleter!.isCompleted) {
        _redirectCompleter!.complete(false);
      }
    }
  }

  // ── User info ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUserInfo() async {
    final idToken = await getIdToken();
    if (idToken == null) return null;

    try {
      final parts = idToken.split('.');
      if (parts.length != 3) return null;
      final normalized = base64.normalize(parts[1]);
      final decoded = utf8.decode(base64.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> getUserRoles() async {
    final claims = await getUserInfo();
    if (claims == null) return [];

    final roles = claims['roles'] ?? claims['realm_access']?['roles'];
    if (roles is List) {
      return roles.cast<String>();
    }
    return [];
  }

  // ── Logout ───────────────────────────────────────────────────────────────

  /// Ends the session everywhere it exists.
  ///
  /// Clearing local storage alone leaves the IdP cookie standing (the next
  /// "Sign in" silently re-authenticates the same user on a shared browser)
  /// and leaves the refresh token valid at the IdP. So this revokes the
  /// refresh token, then hands the browser to the `end_session_endpoint`.
  Future<void> logout() async {
    final refreshTokenValue = await getRefreshToken();
    final idToken = await getIdToken();
    final clientId = _activeClientId;

    Uri? endSession;
    Uri? revocation;
    try {
      await _ensureInitialized();
      final metadata = _platform.client?.issuer.metadata;
      endSession = metadata?.endSessionEndpoint;
      revocation = metadata?.revocationEndpoint;
    } on Exception catch (e) {
      AppLogger.warning('Could not read issuer metadata for logout: $e');
    }

    if (revocation != null && refreshTokenValue != null) {
      await _revokeToken(revocation, clientId, refreshTokenValue);
    }

    _refreshTimer?.cancel();
    _cachedIsAuthenticated = false;
    _cachedAccessToken = null;
    _cachedExpiresAt = null;

    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'id_token');
    await _storage.delete(key: 'token_expires_at');
    await _storage.delete(key: 'selected_client_id');
    await _storage.delete(key: 'login_context');
    _activeClientId = _defaultClientId;
    _platform.reset();

    if (endSession != null) {
      await _platform.navigateToEndSession(
        _buildEndSessionUri(endSession, clientId, idToken),
      );
    }
  }

  Uri _buildEndSessionUri(Uri endpoint, String clientId, String? idToken) {
    final params = <String, String>{
      ...endpoint.queryParameters,
      'client_id': clientId,
    };
    if (idToken != null && idToken.isNotEmpty) {
      params['id_token_hint'] = idToken;
    }
    final postLogout = _platform.postLogoutRedirectUri;
    if (postLogout != null) {
      params['post_logout_redirect_uri'] = postLogout.toString();
    }
    return endpoint.replace(queryParameters: params);
  }

  Future<void> _revokeToken(Uri endpoint, String clientId, String token) async {
    try {
      final response = await _httpClient
          .post(
            endpoint,
            headers: const {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {
              'token': token,
              'token_type_hint': 'refresh_token',
              'client_id': clientId,
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 400) {
        AppLogger.warning('Token revocation returned ${response.statusCode}');
      }
    } on Exception catch (e) {
      // Local sign-out must still complete if the IdP is unreachable.
      AppLogger.warning('Token revocation failed: $e');
    }
  }

  Future<void> storeLoginContext(String json) async {
    await _storage.write(key: 'login_context', value: json);
  }

  Future<String?> getStoredLoginContext() async {
    return _storage.read(key: 'login_context');
  }
}
