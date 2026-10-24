import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:antinvestor_ui_core/auth/tenancy_context.dart';
import '../../../core/config/app_config.dart';
import 'auth_service.dart';

part 'auth_repository.g.dart';

/// Stores the login context (level + selected org/branch) for session restoration.
class StoredLoginContext {
  const StoredLoginContext({
    required this.level,
    this.orgId,
    this.orgName,
    this.branchId,
    this.branchName,
  });

  factory StoredLoginContext.fromJson(Map<String, dynamic> json) {
    return StoredLoginContext(
      level: LoginLevel.values.firstWhere(
        (l) => l.name == json['level'],
        orElse: () => LoginLevel.root,
      ),
      orgId: json['org_id'] as String?,
      orgName: json['org_name'] as String?,
      branchId: json['branch_id'] as String?,
      branchName: json['branch_name'] as String?,
    );
  }

  final LoginLevel level;
  final String? orgId;
  final String? orgName;
  final String? branchId;
  final String? branchName;

  Map<String, dynamic> toJson() => {
    'level': level.name,
    'org_id': orgId,
    'org_name': orgName,
    'branch_id': branchId,
    'branch_name': branchName,
  };
}

class AuthRepository {
  AuthRepository(this._authService, this._ready);

  final AuthService _authService;

  /// Completes once the stored client selection has been restored. Every
  /// entry point awaits it so the service is never initialised against the
  /// default client while the stored one is still loading.
  final Future<void> _ready;

  Future<void> login({String? clientId}) async {
    await _ready;
    if (clientId != null) {
      await _authService.switchClient(clientId);
    }
    await _authService.authenticate();
  }

  Future<void> logout() async => _authService.logout();

  bool? get isLoggedInSync => _authService.isAuthenticatedSync;

  Future<bool> isLoggedIn() async {
    final cached = _authService.isAuthenticatedSync;
    if (cached != null) return cached;
    await _ready;
    return _authService.isAuthenticated();
  }

  Future<String?> getAccessToken() async {
    await _ready;
    return _authService.getAccessToken();
  }

  Future<String?> ensureValidAccessToken() async {
    await _ready;
    return _authService.ensureValidAccessToken();
  }

  Future<String?> forceRefreshAccessToken() async {
    await _ready;
    return _authService.forceRefreshAccessToken();
  }

  Future<Map<String, dynamic>?> getUserInfo() async =>
      _authService.getUserInfo();

  Future<String?> getCurrentProfileId() async {
    final claims = await getUserInfo();
    return claims?['sub'] as String?;
  }

  Future<String?> getCurrentContactId() async {
    final claims = await getUserInfo();
    return claims?['contact_id'] as String? ?? claims?['email'] as String?;
  }

  Future<String?> getCurrentSessionId() async {
    final claims = await getUserInfo();
    return claims?['sid'] as String? ?? claims?['session_state'] as String?;
  }

  Future<List<String>> getUserRoles() async => _authService.getUserRoles();

  Future<String?> getCurrentTenantId() async {
    final claims = await getUserInfo();
    return claims?['tenant_id'] as String?;
  }

  Future<String?> getCurrentPartitionId() async {
    final claims = await getUserInfo();
    return claims?['partition_id'] as String?;
  }

  Future<String?> getDisplayName() async {
    final claims = await getUserInfo();
    return claims?['name'] as String? ??
        claims?['preferred_username'] as String?;
  }

  Future<void> storeLoginContext(StoredLoginContext context) async {
    await _authService.storeLoginContext(jsonEncode(context.toJson()));
  }

  Future<StoredLoginContext?> getStoredLoginContext() async {
    final json = await _authService.getStoredLoginContext();
    if (json == null) return null;
    try {
      return StoredLoginContext.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Web storage settings for the token store.
///
/// `flutter_secure_storage` on web wraps values in localStorage with a key
/// that also lives in localStorage, so it is obfuscation rather than
/// protection. Session storage at least scopes the refresh token to a single
/// browser tab and drops it when that tab closes; the access token is never
/// written at all (see AuthService._saveTokens).
const _secureStorage = FlutterSecureStorage(
  webOptions: WebOptions(
    dbName: 'seed_ui_secure_storage',
    publicKey: 'seed_ui',
    useSessionStorage: true,
  ),
);

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final issuerUrl = AppConfig.oauthIssuerUrl;
  final clientId = AppConfig.oauthClientId;

  final authService = AuthService(
    _secureStorage,
    issuerUrl: issuerUrl,
    clientId: clientId,
  );

  return AuthRepository(authService, authService.restoreSelectedClient());
}

@Riverpod(keepAlive: true)
Future<String?> currentProfileId(Ref ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getCurrentProfileId();
}

@Riverpod(keepAlive: true)
Future<List<String>> userRoles(Ref ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getUserRoles();
}

@Riverpod(keepAlive: true)
Future<String?> currentTenantId(Ref ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getCurrentTenantId();
}

@Riverpod(keepAlive: true)
Future<String?> currentPartitionId(Ref ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getCurrentPartitionId();
}

@Riverpod(keepAlive: true)
Future<String?> currentDisplayName(Ref ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getDisplayName();
}
