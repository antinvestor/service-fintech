import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:antinvestor_ui_core/permissions/permission_provider.dart';
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';
import 'package:antinvestor_ui_funding/antinvestor_ui_funding.dart'
    show FundingRouteModule;
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart'
    show LoansRouteModule;
import 'package:antinvestor_ui_operations/antinvestor_ui_operations.dart'
    show OperationsRouteModule;
import 'package:antinvestor_ui_savings/antinvestor_ui_savings.dart'
    show SavingsRouteModule;

import 'package:antinvestor_ui_core/auth/tenancy_context.dart';
import 'package:antinvestor_ui_core/logging/app_logger.dart';
import '../core/api/file_upload_helper.dart';
import '../core/auth/permission_checker.dart';
import '../core/auth/permission_provider.dart';
import '../core/auth/tenancy_bootstrap.dart';
import '../core/config/app_config.dart';
import '../core/navigation/nav_items.dart';
import '../core/responsive/seed_shell.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/auth_state_provider.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/lending/lending_tab.dart';
import '../features/limits/limits_feature.dart';
import '../features/operations/loan_picker_dialog.dart';

/// Notifier that triggers a router refresh when the session or the caller's
/// capabilities change. Permissions gate routes, so a late-arriving
/// capability answer has to re-run the redirect.
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(Ref ref) {
    ref.listen(authStateProvider, (previous, next) => notifyListeners());
    ref.listen(
      permissionResolutionProvider,
      (previous, next) => notifyListeners(),
    );
  }
}

final authChangeProvider = Provider<AuthChangeNotifier>((ref) {
  return AuthChangeNotifier(ref);
});

/// Decides where a navigation should land.
///
/// Extracted from the GoRouter callback so the rules — unauthenticated users
/// go to /login, authenticated users never sit on /login, and a
/// permission-gated location is unreachable without the grant — are testable
/// without a browser or an IdP.
///
/// Returns null to allow the navigation, or the location to redirect to.
Future<String?> resolveRedirect({
  required String location,
  required Future<bool> Function() isLoggedIn,
  required Future<PermissionResolution> Function() permissions,
  Future<void> Function()? onAuthenticated,
}) async {
  const loginRoute = '/login';
  const home = '/';
  final isAuthCallback = location == '/auth/callback';

  final loggedIn = await isLoggedIn();

  if (isAuthCallback) return loggedIn ? home : null;
  if (!loggedIn) return location == loginRoute ? null : loginRoute;
  if (location == loginRoute) return home;

  if (onAuthenticated != null) await onAuthenticated();

  // Permission-gated routes are guarded here as well as hidden from the
  // sidebar: hiding a link does not stop anyone typing the URL. The
  // requirement comes from the same nav tree the sidebar filters, so the two
  // can never drift apart.
  final required = requiredPermissionsForRoute(location);
  if (required.isEmpty) return null;

  final resolution = await permissions();
  return resolution.hasAny(required) ? null : home;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final authChangeNotifier = ref.watch(authChangeProvider);
  final tenancyBootstrap = ref.watch(tenancyBootstrapProvider);

  Future<void> ensureTenancyInitialized() async {
    if (tenancyBootstrap.isInitialized) return;
    tenancyBootstrap.markInitialized();
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
    redirect: (context, state) => resolveRedirect(
      location: state.matchedLocation,
      isLoggedIn: () async =>
          authRepository.isLoggedInSync ?? await authRepository.isLoggedIn(),
      onAuthenticated: ensureTenancyInitialized,
      permissions: () => resolvePermissions(ref),
    ),
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
            path: '/form-templates',
            builder: (context, state) => Consumer(
              builder: (context, ref, _) => FormTemplatesScreen(
                onNavigateToDesigner: (id) =>
                    context.go('/form-templates/${id ?? 'new'}'),
              ),
            ),
            routes: [
              GoRoute(
                path: ':templateId',
                builder: (context, state) {
                  final id = state.pathParameters['templateId']!;
                  return Consumer(
                    builder: (context, ref, _) => FormTemplateDesignerScreen(
                      key: ValueKey(id),
                      templateId: id == 'new' ? null : id,
                      canManage: ref.watch(
                        hasPermissionProvider('form_template_manage'),
                      ),
                      onSaved: (savedId) =>
                          context.go('/form-templates/$savedId'),
                    ),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/access-roles',
            builder: (context, state) => const AccessRolesScreen(),
          ),
          GoRoute(
            path: '/clients',
            builder: (context, state) => Consumer(
              builder: (context, ref, _) => ClientsScreen(
                canManage: ref.watch(hasPermissionProvider('client_manage')),
              ),
            ),
            routes: [
              GoRoute(
                path: ':clientId',
                builder: (context, state) => Consumer(
                  builder: (context, ref, _) => ClientDetailScreen(
                    clientId: state.pathParameters['clientId']!,
                    canManage: ref.watch(
                      hasPermissionProvider('client_manage'),
                    ),
                    canAssignStaff: ref.watch(
                      hasPermissionProvider('client_relationship_manage'),
                    ),
                    canVerifyData: ref.watch(
                      hasPermissionProvider('client_data_verify'),
                    ),
                    extraTabs: [
                      if (ref.watch(
                        hasPermissionProvider('seed_credit_profile_view'),
                      ))
                        ClientDetailTab(
                          label: 'Lending',
                          builder: (context, client) => LendingTab(
                            clientId: client.id,
                            canAdmin: ref.watch(
                              hasPermissionProvider(
                                'seed_credit_profile_admin',
                              ),
                            ),
                            canCap: ref.watch(
                              hasPermissionProvider('seed_credit_profile_cap'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ...LimitsFeature.routes(),
          ...LoansRouteModule().buildRoutes(),
          ...FundingRouteModule().buildRoutes(),
          ...SavingsRouteModule().buildRoutes(),
          ...OperationsRouteModule(pickLoan: pickLoanAccount).buildRoutes(),
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
      AppLogger.warning('Failed to initialize tenancy: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
