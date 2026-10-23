import 'dart:async';
import 'dart:convert';

import 'package:antinvestor_ui_core/permissions/permission_registry.dart';
import 'package:http/http.dart' as http;

/// Outcome of resolving the caller's capabilities.
///
/// [available] distinguishes "the backend answered and the user holds no
/// grants" from "the backend could not be reached". The two must never be
/// conflated: the first is a legitimate empty permission set, the second is
/// an unknown one, and an unknown permission set must deny.
class PermissionResolution {
  const PermissionResolution._({
    required this.available,
    required this.granted,
  });

  /// The capability service answered; [granted] is authoritative.
  const PermissionResolution.resolved(Set<String> granted)
    : this._(available: true, granted: granted);

  /// The capability service could not be reached or returned an error.
  /// Nothing is known about the caller, so nothing gated is permitted.
  const PermissionResolution.unavailable()
    : this._(available: false, granted: const <String>{});

  final bool available;
  final Set<String> granted;

  bool has(String permission) => available && granted.contains(permission);

  bool hasAny(Set<String> permissions) =>
      permissions.isEmpty ||
      (available && granted.intersection(permissions).isNotEmpty);
}

/// Resolves the caller's capabilities against the identity service.
///
/// Endpoints (both served by identity, both requiring a bearer token):
///
///   POST {base}/ui/capabilities/batch-check
///     {"checks":[{"namespace":"service_identity","permissions":["org_view"]}]}
///   → 200 {"granted":["org_view", ...]}
///
///   GET {base}/ui/capabilities
///   → 200 {"user":{"permissions":["org_view", ...]}}
///     or  {"capabilities":{"org_view":{"enabled":true}}}
///
/// Any other status, a transport failure or a malformed body yields
/// [PermissionResolution.unavailable] so callers fail closed.
class PermissionBatchChecker {
  PermissionBatchChecker(
    this._httpClient,
    this._baseUrl, {
    Duration timeout = const Duration(seconds: 10),
  }) : _timeout = timeout;

  final http.Client _httpClient;
  final String _baseUrl;
  final Duration _timeout;

  /// Check all registered permissions for the current user.
  Future<PermissionResolution> checkAll(String accessToken) async {
    final permsByNamespace = PermissionRegistry.instance.permissionsByNamespace;

    if (permsByNamespace.isEmpty) {
      return const PermissionResolution.resolved(<String>{});
    }

    try {
      final response = await _httpClient
          .post(
            Uri.parse('$_baseUrl/ui/capabilities/batch-check'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'checks': permsByNamespace.entries
                  .map(
                    (e) => {
                      'namespace': e.key,
                      'permissions': e.value.toList(),
                    },
                  )
                  .toList(),
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final granted = _grantedFromBatchBody(response.body);
        if (granted != null) {
          return PermissionResolution.resolved(granted);
        }
      }
    } on Exception {
      // Fall through to the single-shot endpoint.
    }

    return _fallbackCheck(accessToken);
  }

  Set<String>? _grantedFromBatchBody(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final granted = data['granted'] as List?;
      if (granted == null) return null;
      return granted.map((e) => e.toString()).toSet();
    } on Exception {
      return null;
    }
  }

  /// Fallback: the single-shot GET /ui/capabilities endpoint.
  Future<PermissionResolution> _fallbackCheck(String accessToken) async {
    http.Response response;
    try {
      response = await _httpClient
          .get(
            Uri.parse('$_baseUrl/ui/capabilities'),
            headers: {'Authorization': 'Bearer $accessToken'},
          )
          .timeout(_timeout);
    } on Exception {
      return const PermissionResolution.unavailable();
    }

    if (response.statusCode != 200) {
      return const PermissionResolution.unavailable();
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final user = data['user'] as Map<String, dynamic>?;
      final permissions = user?['permissions'] as List?;
      if (permissions != null) {
        return PermissionResolution.resolved(
          permissions.map((e) => e.toString()).toSet(),
        );
      }

      final capabilities = data['capabilities'] as Map<String, dynamic>?;
      if (capabilities != null) {
        return PermissionResolution.resolved(
          capabilities.entries
              .where((e) => _isEnabled(e.value))
              .map((e) => e.key)
              .toSet(),
        );
      }
    } on Exception {
      return const PermissionResolution.unavailable();
    }

    // A 200 whose shape we do not understand tells us nothing.
    return const PermissionResolution.unavailable();
  }

  static bool _isEnabled(Object? value) {
    if (value is Map) return value['enabled'] == true;
    if (value is bool) return value;
    return false;
  }
}
