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
    show
        identityTransportProvider,
        myClientAccessScopeProvider,
        onboardingFormCacheProvider,
        registrationOutboxProvider,
        registrationOutboxStoreProvider;
import 'package:antinvestor_ui_limits/antinvestor_ui_limits.dart'
    show LimitsCapabilities, limitsCapabilitiesProvider;
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart'
    show currentAgentIdProvider, loansTransportProvider;
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart'
    as loans
    show currentProfileIdProvider;
import 'package:antinvestor_ui_funding/antinvestor_ui_funding.dart'
    show fundingTransportProvider;
import 'package:antinvestor_ui_operations/antinvestor_ui_operations.dart'
    show operationsTransportProvider;
import 'package:antinvestor_ui_savings/antinvestor_ui_savings.dart'
    show savingsTransportProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'app/router.dart';
import 'core/auth/auth_bridge.dart';
import 'core/auth/permission_manifests.dart';
import 'core/auth/permission_provider.dart';
import 'core/data/analytics_data_source.dart';
import 'core/data/secure_outbox_store.dart';
import 'core/config/app_config.dart';
import 'core/config/url_strategy.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';

// Unlike the auth tokens, the outboxes must outlive the tab.
const _outboxStorage = FlutterSecureStorage(
  webOptions: WebOptions(dbName: 'seed_ui_outbox', publicKey: 'seed_ui_outbox'),
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.assertConfigured();

  // Typefaces ship in assets/google_fonts. Refusing the runtime fetch keeps
  // the app off fonts.googleapis.com entirely, which the CSP in web/index.html
  // blocks anyway, and turns a missing font file into a loud failure instead
  // of a silent third-party request.
  GoogleFonts.config.allowRuntimeFetching = false;

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

        // Batch permission check at startup. An unresolved capability set
        // yields no grants, so every permission-gated surface denies.
        userPermissionsProvider.overrideWith((ref) async {
          final resolution = await ref.watch(
            permissionResolutionProvider.future,
          );
          return resolution.available ? resolution.granted : const <String>{};
        }),

        // The limits screens gate their mutating affordances on the same
        // resolved grants. An unreachable capability service leaves the
        // screens read-only rather than offering calls the server refuses.
        limitsCapabilitiesProvider.overrideWith((ref) {
          final resolution = ref.watch(permissionResolutionProvider);
          final grants = resolution.asData?.value;
          if (grants == null || !grants.available) {
            return const LimitsCapabilities.none();
          }
          return LimitsCapabilities(
            policyManage: grants.has('limits_policy_manage'),
            approvalAct: grants.has('limits_approval_act'),
          );
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

        // A field agent's workforce member id enables "My portfolio" on the
        // loan book; anyone else leaves it off.
        currentAgentIdProvider.overrideWith((ref) {
          final memberId = ref
              .watch(myClientAccessScopeProvider)
              .value
              ?.memberId;
          return (memberId == null || memberId.isEmpty) ? null : memberId;
        }),

        // The signed-in profile, so the loan request screen does not offer
        // its submitter a decision the service would refuse.
        loans.currentProfileIdProvider.overrideWith(
          (ref) => ref.watch(currentProfileIdProvider).value,
        ),

        // Registrations captured offline are kept on the device.
        registrationOutboxStoreProvider.overrideWithValue(
          const SecureOutboxStore(
            _outboxStorage,
            key: SecureOutboxStore.registrations,
          ),
        ),
        onboardingFormCacheProvider.overrideWithValue(
          const SecureOutboxStore(
            _outboxStorage,
            key: SecureOutboxStore.onboardingForm,
          ),
        ),

        // ── Library endpoint overrides ──────────────────────────────
        identityTransportProvider.overrideWith((ref) {
          final auth = ref.watch(authTokenProviderProvider);
          return createTransport(auth, baseUrl: AppConfig.identityBaseUrl);
        }),

        loansTransportProvider.overrideWith((ref) {
          final auth = ref.watch(authTokenProviderProvider);
          return createTransport(auth, baseUrl: AppConfig.loansBaseUrl);
        }),

        fundingTransportProvider.overrideWith((ref) {
          final auth = ref.watch(authTokenProviderProvider);
          return createTransport(auth, baseUrl: AppConfig.fundingBaseUrl);
        }),

        savingsTransportProvider.overrideWith((ref) {
          final auth = ref.watch(authTokenProviderProvider);
          return createTransport(auth, baseUrl: AppConfig.savingsBaseUrl);
        }),

        operationsTransportProvider.overrideWith((ref) {
          final auth = ref.watch(authTokenProviderProvider);
          return createTransport(auth, baseUrl: AppConfig.operationsBaseUrl);
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

class SeedApp extends ConsumerStatefulWidget {
  const SeedApp({super.key});

  @override
  ConsumerState<SeedApp> createState() => _SeedAppState();
}

class _SeedAppState extends ConsumerState<SeedApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Registrations saved offline are sent when the app comes back to the
    // foreground; a resend is harmless.
    _lifecycle = AppLifecycleListener(onResume: _flushOutbox);
    WidgetsBinding.instance.addPostFrameCallback((_) => _flushOutbox());
    _discardRetiredRepaymentOutbox();
  }

  Future<void> _flushOutbox() async {
    try {
      await ref.read(registrationOutboxProvider.notifier).flush();
    } catch (_) {
      // Still offline or not signed in: the next resume tries again.
    }
  }

  Future<void> _discardRetiredRepaymentOutbox() async {
    try {
      await _outboxStorage.delete(key: SecureOutboxStore.retiredRepayments);
    } catch (_) {
      // Storage unavailable; nothing reads the key any more either way.
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
