import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:antinvestor_ui_core/auth/tenancy_context.dart';
import 'package:antinvestor_ui_core/logging/app_logger.dart';

import '../../../core/auth/permission_provider.dart';
import '../../../core/auth/tenancy_bootstrap.dart';
import 'auth_repository.dart';

part 'auth_state_provider.g.dart';

enum AuthState { authenticated, unauthenticated, loading }

@Riverpod(keepAlive: true)
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  Future<AuthState> build() async {
    final authRepo = ref.watch(authRepositoryProvider);
    final isLoggedIn = await authRepo.isLoggedIn();

    if (!isLoggedIn) return AuthState.unauthenticated;

    // A session with no obtainable access token is not a session. Reporting
    // it as authenticated leaves the user inside a fully rendered app where
    // every request 401s and nothing sends them back to login.
    final token = await authRepo.ensureValidAccessToken();
    return token == null || token.isEmpty
        ? AuthState.unauthenticated
        : AuthState.authenticated;
  }

  Future<void> login({String? clientId}) async {
    state = const AsyncValue.loading();

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.login(clientId: clientId);

      if (!ref.mounted) return;

      final isLoggedIn = await authRepo.isLoggedIn();
      if (!isLoggedIn) {
        state = const AsyncValue.data(AuthState.unauthenticated);
        return;
      }

      state = const AsyncValue.data(AuthState.authenticated);
      AppLogger.info('Login successful');
    } catch (e, stack) {
      AppLogger.error('Login failed', error: e, stackTrace: stack);
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.logout();

      if (!ref.mounted) return;

      // Drop every piece of the previous user's session so signing in as a
      // different user does not inherit their tenancy or capabilities.
      ref.read(tenancyContextProvider).clear();
      ref.read(tenancyBootstrapProvider).reset();
      ref.invalidate(permissionResolutionProvider);

      state = const AsyncValue.data(AuthState.unauthenticated);
      AppLogger.info('Logout successful');
    } catch (e, stack) {
      AppLogger.error('Logout failed', error: e, stackTrace: stack);
      if (ref.mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }
}
