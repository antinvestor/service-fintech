import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../features/auth/data/auth_repository.dart';
import '../config/app_config.dart';
import 'permission_checker.dart';

/// The caller's resolved capabilities, or [PermissionResolution.unavailable]
/// when the capability service could not answer.
///
/// Everything that gates on permissions — sidebar filtering, route guards —
/// reads this rather than a bare granted set, so an unreachable backend
/// denies instead of silently granting. The provider never completes with an
/// error: an unknown permission set is a value, not an exception, and callers
/// must not be able to accidentally swallow it into "no filtering".
final permissionResolutionProvider = FutureProvider<PermissionResolution>((
  ref,
) async {
  final client = http.Client();
  ref.onDispose(client.close);

  try {
    final authRepo = ref.watch(authRepositoryProvider);
    final token = await authRepo.ensureValidAccessToken();
    if (token == null || token.isEmpty) {
      return const PermissionResolution.unavailable();
    }

    final checker = PermissionBatchChecker(client, AppConfig.identityBaseUrl);
    return await checker.checkAll(token);
  } on Exception {
    return const PermissionResolution.unavailable();
  }
});

/// How long an unavailable capability answer is allowed to stand before the
/// next permission gate retries it.
const permissionRetryCooldown = Duration(seconds: 15);

/// Throttles how often a failed capability resolution is discarded.
///
/// Without it, discarding on every gate check would turn a router refresh into
/// a tight retry loop against a backend that is already failing.
class PermissionRetryGate {
  DateTime? _lastRetryAt;

  /// Reports whether the cached failure should be discarded now, recording the
  /// attempt when it says yes.
  bool shouldRetry(
    DateTime now, {
    Duration cooldown = permissionRetryCooldown,
  }) {
    final last = _lastRetryAt;
    if (last != null && now.difference(last) < cooldown) {
      return false;
    }
    _lastRetryAt = now;
    return true;
  }
}

final permissionRetryGateProvider = Provider<PermissionRetryGate>(
  (ref) => PermissionRetryGate(),
);

/// Resolves the caller's capabilities for a permission gate.
///
/// The answer stays fail-closed — an unavailable resolution grants nothing —
/// but it is never *kept*. The keep-alive provider used to cache a single
/// transient failure for the whole session, silently locking every gated route
/// until the user logged out. An unavailable answer is therefore discarded so
/// the next navigation re-runs the request, throttled by
/// [permissionRetryCooldown] so a backend that stays down is not hammered.
Future<PermissionResolution> resolvePermissions(Ref ref) async {
  final resolution = await ref.read(permissionResolutionProvider.future);
  if (!resolution.available &&
      ref.read(permissionRetryGateProvider).shouldRetry(DateTime.now())) {
    ref.invalidate(permissionResolutionProvider);
  }
  return resolution;
}
