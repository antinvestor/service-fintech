import 'dart:convert';

import 'package:antinvestor_ui_core/permissions/permission_registry.dart';
import 'package:http/http.dart' as http;

/// Performs a batch permission check against the backend.
///
/// Collects all permission manifests from registered service UI libraries
/// and checks them all in a single request. Falls back to extracting
/// permissions from JWT roles if the batch endpoint is unavailable.
class PermissionBatchChecker {
  PermissionBatchChecker(this._httpClient, this._baseUrl);

  final http.Client _httpClient;
  final String _baseUrl;

  /// Check all registered permissions for the current user.
  /// Returns the set of permission keys the user has been granted.
  Future<Set<String>> checkAll(String accessToken) async {
    final registry = PermissionRegistry.instance;
    final permsByNamespace = registry.permissionsByNamespace;

    if (permsByNamespace.isEmpty) {
      return const <String>{};
    }

    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/ui/capabilities/batch-check'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'checks': permsByNamespace.entries
              .map((e) => {'namespace': e.key, 'permissions': e.value.toList()})
              .toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final granted = data['granted'] as List?;
        if (granted != null) {
          return granted.map((e) => e.toString()).toSet();
        }
      }
    } catch (_) {
      // Batch endpoint unavailable — fall through to fallback.
    }

    return _fallbackCheck(accessToken);
  }

  /// Fallback: use the existing GET /ui/capabilities endpoint.
  Future<Set<String>> _fallbackCheck(String accessToken) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/ui/capabilities'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode != 200) return const <String>{};

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final user = data['user'] as Map<String, dynamic>?;
      if (user != null) {
        final permissions = user['permissions'] as List?;
        if (permissions != null) {
          return permissions.map((e) => e.toString()).toSet();
        }
      }

      final capabilities = data['capabilities'] as Map<String, dynamic>?;
      if (capabilities != null) {
        return capabilities.entries
            .where((e) {
              final v = e.value;
              if (v is Map) return v['enabled'] == true;
              if (v is bool) return v;
              return false;
            })
            .map((e) => e.key)
            .toSet();
      }
    } catch (_) {
      // Both endpoints failed — return empty permissions.
    }

    return const <String>{};
  }
}
