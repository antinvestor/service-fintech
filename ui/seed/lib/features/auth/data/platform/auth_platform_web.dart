import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:openid_client/openid_client.dart';
import 'package:web/web.dart' as web;

import 'auth_platform.dart';

AuthPlatform getAuthPlatform() => AuthPlatformWeb();

class AuthPlatformWeb implements AuthPlatform {
  static const String _stateKey = 'openid_client:state';
  static const String _codeVerifierKey = 'openid_client:code_verifier';
  static const String _timestampKey = 'openid_client:timestamp';
  static const Duration _stateExpiry = Duration(minutes: 10);
  static const Duration _tokenExchangeTimeout = Duration(seconds: 30);

  Issuer? _issuer;
  Client? _client;
  Completer<void>? _initCompleter;

  @override
  Client? get client => _client;

  @override
  void reset() {
    _client = null;
    _initCompleter = null;
  }

  @override
  Future<void> initialize(String issuerUrl, String clientId) async {
    if (_issuer != null && _client != null) return;
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      return _initCompleter!.future;
    }
    _initCompleter = Completer<void>();
    try {
      _issuer = await Issuer.discover(
        Uri.parse(issuerUrl),
      ).timeout(const Duration(seconds: 15));
      _client = Client(_issuer!, clientId);
      _initCompleter!.complete();
    } catch (e) {
      _initCompleter!.complete();
      _initCompleter = null;
      rethrow;
    }
  }

  @override
  Future<TokenResponse?> authenticate(List<String> scopes) async {
    if (_client == null) {
      throw StateError('AuthPlatformWeb not initialized');
    }

    _cleanupStaleState();

    final currentUri = Uri.parse(web.window.location.href);
    if (currentUri.scheme.isEmpty || currentUri.host.isEmpty) {
      throw StateError('Cannot determine redirect URI: invalid page location');
    }
    final redirectUri = Uri(
      scheme: currentUri.scheme,
      host: currentUri.host,
      port: currentUri.port,
      path: '/auth/callback',
    );

    final codeVerifier = _generateCodeVerifier();
    final flow =
        Flow.authorizationCodeWithPKCE(_client!, codeVerifier: codeVerifier)
          ..scopes.addAll(scopes)
          ..redirectUri = redirectUri;

    web.window.sessionStorage.setItem(_stateKey, flow.state);
    web.window.sessionStorage.setItem(_codeVerifierKey, codeVerifier);
    web.window.sessionStorage.setItem(
      _timestampKey,
      DateTime.now().millisecondsSinceEpoch.toString(),
    );

    web.window.location.href = flow.authenticationUri.toString();
    await Completer<void>().future;
    return null;
  }

  @override
  Future<TokenResponse?> getRedirectResult() async {
    if (_client == null) return null;

    final uri = Uri.parse(web.window.location.href);
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];
    final error = uri.queryParameters['error'];
    final errorDescription = uri.queryParameters['error_description'];

    if (error != null) {
      _clearAuthState();
      _cleanUrl(uri);
      throw Exception('Authentication failed: ${errorDescription ?? error}');
    }

    if (code == null || state == null) return null;

    final storedState = web.window.sessionStorage.getItem(_stateKey);
    final storedCodeVerifier = web.window.sessionStorage.getItem(
      _codeVerifierKey,
    );
    final storedTimestamp = web.window.sessionStorage.getItem(_timestampKey);

    if (storedState != state || storedCodeVerifier == null) {
      _clearAuthState();
      _cleanUrl(uri);
      return null;
    }

    if (storedTimestamp != null) {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(storedTimestamp) ?? 0,
      );
      if (DateTime.now().difference(timestamp) > _stateExpiry) {
        _clearAuthState();
        _cleanUrl(uri);
        return null;
      }
    }

    try {
      if (uri.scheme.isEmpty || uri.host.isEmpty) {
        _clearAuthState();
        return null;
      }
      final redirectUri = Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.port,
        path: '/auth/callback',
      );

      final flow = Flow.authorizationCodeWithPKCE(
        _client!,
        state: storedState,
        codeVerifier: storedCodeVerifier,
      )..redirectUri = redirectUri;

      final credential = await flow
          .callback({'code': code, 'state': state})
          .timeout(_tokenExchangeTimeout);

      final tokenResponse = await credential.getTokenResponse().timeout(
        _tokenExchangeTimeout,
      );

      _clearAuthState();
      _cleanUrl(uri);
      return tokenResponse;
    } catch (e) {
      _clearAuthState();
      _cleanUrl(uri);
      rethrow;
    }
  }

  void _cleanUrl(Uri uri) {
    final cleanUri = Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      path: uri.path,
    );
    web.window.history.replaceState(null, '', cleanUri.toString());
  }

  void _clearAuthState() {
    web.window.sessionStorage.removeItem(_stateKey);
    web.window.sessionStorage.removeItem(_codeVerifierKey);
    web.window.sessionStorage.removeItem(_timestampKey);
  }

  void _cleanupStaleState() {
    final storedTimestamp = web.window.sessionStorage.getItem(_timestampKey);
    if (storedTimestamp != null) {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(storedTimestamp) ?? 0,
      );
      if (DateTime.now().difference(timestamp) > _stateExpiry) {
        _clearAuthState();
      }
    }
  }

  @override
  bool hasRedirectResult() {
    final uri = Uri.parse(web.window.location.href);
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];
    return code != null && state != null;
  }

  @override
  Future<void> cancelAuthentication() async {
    _clearAuthState();
  }

  @override
  Uri? get postLogoutRedirectUri {
    final current = Uri.parse(web.window.location.href);
    if (current.scheme.isEmpty || current.host.isEmpty) return null;
    return Uri(
      scheme: current.scheme,
      host: current.host,
      port: current.port,
      path: '/login',
    );
  }

  @override
  Future<void> navigateToEndSession(Uri uri) async {
    web.window.location.href = uri.toString();
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }
}
