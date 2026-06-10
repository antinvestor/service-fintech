import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';

import 'package:antinvestor_ui_core/auth/tenancy_context.dart';
import '../core/api/file_upload_helper.dart';
import '../core/config/app_config.dart';
import '../core/responsive/seed_shell.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/auth_state_provider.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/limits/limits_feature.dart';

/// Notifier that triggers router refresh when auth state changes.
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(Ref ref) {
    ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final authChangeProvider = Provider<AuthChangeNotifier>((ref) {
  return AuthChangeNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final authChangeNotifier = ref.watch(authChangeProvider);
  bool tenancyInitialized = false;

  Future<void> ensureTenancyInitialized() async {
    if (tenancyInitialized) return;
    tenancyInitialized = true;
    try {
      final partitionId = await authRepository.getCurrentPartitionId();
      final tenancy = ref.read(tenancyContextProvider);
      if (!tenancy.hasPartition && partitionId != null) {
        final loginContext = await authRepository.getStoredLoginContext();
        if (loginContext != null) {
          tenancy.initializeFromLogin(
            loginContext.level,
            partitionId: partitionId,
            orgId: loginContext.orgId,
            orgName: loginContext.orgName,
            branchId: loginContext.branchId,
            branchName: loginContext.branchName,
          );
        } else {
          tenancy.initializeFromLogin(
            LoginLevel.root,
            partitionId: partitionId,
          );
        }
      }
    } catch (_) {}
  }

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authChangeNotifier,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isLoginRoute = location == '/login';
      final isAuthCallback = location == '/auth/callback';

      final cachedAuth = authRepository.isLoggedInSync;
      if (cachedAuth == null) {
        return authRepository.isLoggedIn().then((isLoggedIn) {
          if (isLoggedIn) ensureTenancyInitialized();
          if (isAuthCallback) return isLoggedIn ? '/' : null;
          if (!isLoggedIn && !isLoginRoute) return '/login';
          if (isLoggedIn && isLoginRoute) return '/';
          return null;
        });
      }

      final isLoggedIn = cachedAuth;
      if (isLoggedIn) ensureTenancyInitialized();
      if (isAuthCallback) return isLoggedIn ? '/' : null;
      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/auth/callback',
        builder: (context, state) => const _AuthCallbackScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => SeedShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/organizations',
            builder: (context, state) => Consumer(
              builder: (context, ref, _) => OrganizationsScreen(
                filesBaseUrl: AppConfig.filesBaseUrl,
                onPickLogo: (bytes, filename) async {
                  final result = await uploadPublicImageFull(
                    ref,
                    bytes,
                    filename,
                  );
                  return result.mxcUri;
                },
              ),
            ),
            routes: [
              GoRoute(
                path: ':organizationId',
                builder: (context, state) => Consumer(
                  builder: (context, ref, _) => OrganizationDetailScreen(
                    organizationId: state.pathParameters['organizationId']!,
                    backRoute: '/organizations',
                    onPickLogo: (bytes, filename) async {
                      final result = await uploadPublicImageFull(
                        ref,
                        bytes,
                        filename,
                      );
                      return result.mxcUri;
                    },
                    filesBaseUrl: AppConfig.filesBaseUrl,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/org-units',
            builder: (context, state) => const OrgUnitsScreen(),
            routes: [
              GoRoute(
                path: ':orgUnitId',
                builder: (context, state) => OrgUnitDetailScreen(
                  orgUnitId: state.pathParameters['orgUnitId']!,
                  organizationId: '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/departments',
            builder: (context, state) => const DepartmentsScreen(),
            routes: [
              GoRoute(
                path: ':departmentId',
                builder: (context, state) => DepartmentDetailScreen(
                  departmentId: state.pathParameters['departmentId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/investors',
            builder: (context, state) => const InvestorsScreen(),
          ),
          GoRoute(
            path: '/workforce',
            builder: (context, state) => const WorkforceMembersScreen(),
            routes: [
              GoRoute(
                path: ':memberId',
                builder: (context, state) => WorkforceMemberDetailScreen(
                  memberId: state.pathParameters['memberId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/teams',
            builder: (context, state) => const TeamsScreen(),
            routes: [
              GoRoute(
                path: ':teamId',
                builder: (context, state) =>
                    TeamDetailScreen(teamId: state.pathParameters['teamId']!),
              ),
            ],
          ),
          GoRoute(
            path: '/access-roles',
            builder: (context, state) => const AccessRolesScreen(),
          ),
          ...LimitsFeature.routes(),
        ],
      ),
    ],
  );
});

/// Handles the OAuth callback: shows a loading spinner while the token
/// exchange completes, then redirects to '/'.
class _AuthCallbackScreen extends ConsumerStatefulWidget {
  const _AuthCallbackScreen();

  @override
  ConsumerState<_AuthCallbackScreen> createState() =>
      _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<_AuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _processCallback();
  }

  Future<void> _processCallback() async {
    final authRepo = ref.read(authRepositoryProvider);

    final loggedIn = await authRepo.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      await _initializeTenancyFromJwt(ref);

      if (!mounted) return;

      ref.invalidate(authStateProvider);
    }

    context.go('/');
  }

  Future<void> _initializeTenancyFromJwt(WidgetRef ref) async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final partitionId = await authRepo.getCurrentPartitionId();
      final tenancy = ref.read(tenancyContextProvider);
      final loginContext = await authRepo.getStoredLoginContext();

      if (loginContext != null) {
        tenancy.initializeFromLogin(
          loginContext.level,
          partitionId: partitionId,
          orgId: loginContext.orgId,
          orgName: loginContext.orgName,
          branchId: loginContext.branchId,
          branchName: loginContext.branchName,
        );
      } else {
        tenancy.initializeFromLogin(LoginLevel.root, partitionId: partitionId);
      }
    } catch (e) {
      debugPrint('Failed to initialize tenancy: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
