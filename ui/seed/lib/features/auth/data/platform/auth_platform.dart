import 'package:openid_client/openid_client.dart';

/// Abstract class for platform-specific authentication logic
abstract class AuthPlatform {
  Future<void> initialize(String issuerUrl, String clientId);
  Future<TokenResponse?> authenticate(List<String> scopes);
  Future<TokenResponse?> getRedirectResult();
  Future<void> cancelAuthentication() async {}
  Client? get client;

  /// Returns true if the current URL contains OAuth callback parameters.
  /// This is a fast, synchronous check that doesn't require network access.
  bool hasRedirectResult() => false;

  /// Reset the platform client so the next initialize() uses a fresh client_id.
  void reset() {}

  /// Where the IdP should send the browser after an RP-initiated logout, or
  /// null when this platform has nowhere to come back to.
  Uri? get postLogoutRedirectUri => null;

  /// Send the user to the OIDC `end_session_endpoint` so the IdP session is
  /// terminated, not just the local one.
  Future<void> navigateToEndSession(Uri uri) async {}
}
