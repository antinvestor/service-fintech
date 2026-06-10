import 'package:antinvestor_ui_audit/antinvestor_ui_audit.dart'
    show auditTransportProvider;
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart'
    show profileTransportProvider;
import 'package:antinvestor_ui_geolocation/antinvestor_ui_geolocation.dart'
    show geolocationTransportProvider;
import 'package:antinvestor_ui_core/analytics/analytics_provider.dart';
import 'package:antinvestor_ui_core/api/api_base.dart';
import 'package:antinvestor_ui_core/auth/role_provider.dart';
import 'package:antinvestor_ui_core/permissions/permission_provider.dart';
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart'
    show identityTransportProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'app/router.dart';
import 'core/auth/auth_bridge.dart';
import 'core/data/analytics_data_source.dart';
import 'core/auth/permission_checker.dart';
import 'core/auth/permission_manifests.dart';
import 'core/config/app_config.dart';
import 'core/config/url_strategy.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();

  // Register permission manifests before app starts.
  registerPermissionManifests();

  runApp(
    ProviderScope(
      overrides: [
        // Bridge auth → ui_core AuthTokenProvider.
        authTokenProviderProvider.overrideWith((ref) {
          final authRepo = ref.watch(authRepositoryProvider);
          return LenderAuthTokenBridge(authRepo);
        }),

        // Bridge JWT roles → ui_core string-based roles.
        currentUserRolesProvider.overrideWith((ref) async {
          final authRepo = ref.watch(authRepositoryProvider);
          final roles = await authRepo.getUserRoles();
          return roles.toSet();
        }),

        // Batch permission check at startup.
        userPermissionsProvider.overrideWith((ref) async {
          final authRepo = ref.watch(authRepositoryProvider);
          final token = await authRepo.getAccessToken();
          if (token == null || token.isEmpty) return const <String>{};

          final checker = PermissionBatchChecker(
            http.Client(),
            AppConfig.identityBaseUrl,
          );
          return checker.checkAll(token);
        }),

        // Analytics data source for dashboard (Thesa POST query API).
        // Standard ui_core ThesaAnalyticsDataSource over an authenticated
        // transport; the server injects tenant scope from the JWT.
        analyticsDataSourceProvider.overrideWith((ref) {
          final auth = ref.watch(authTokenProviderProvider);
          return SeedAnalyticsDataSource(
            seedAnalyticsTransport(http.Client(), auth, AppConfig.thesaBaseUrl),
          );
        }),

        // ── Library endpoint overrides ──────────────────────────────
        identityTransportProvider.overrideWith((ref) {
          final auth = ref.watch(authTokenProviderProvider);
          return createTransport(auth, baseUrl: AppConfig.identityBaseUrl);
        }),

        auditTransportProvider.overrideWith((ref) {
          final auth = ref.watch(authTokenProviderProvider);
          return createTransport(auth, baseUrl: AppConfig.auditBaseUrl);
        }),

        profileTransportProvider.overrideWith((ref) {
          final auth = ref.watch(authTokenProviderProvider);
          return createTransport(auth, baseUrl: AppConfig.profileBaseUrl);
        }),

        geolocationTransportProvider.overrideWith((ref) {
          final auth = ref.watch(authTokenProviderProvider);
          return createTransport(auth, baseUrl: AppConfig.geolocationBaseUrl);
        }),
      ],
      child: const SeedApp(),
    ),
  );
}

class SeedApp extends ConsumerWidget {
  const SeedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AntInvestor Seed',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
