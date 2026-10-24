import 'package:antinvestor_api_savings/antinvestor_api_savings.dart';
import 'package:antinvestor_ui_core/api/api_base.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _savingsUrlFromEnv = String.fromEnvironment('SAVINGS_URL');

/// Base URL of the savings service.
///
/// There is deliberately no public fallback: an embedding app that forgets to
/// point this at its own environment should fail loudly at startup rather than
/// quietly send a tenant's savings traffic to someone else's deployment. Host
/// apps override this (or `savingsTransportProvider`) in their ProviderScope;
/// a `SAVINGS_URL` define is honoured for local development.
final savingsBaseUrlProvider = Provider<String>((ref) {
  if (_savingsUrlFromEnv.isNotEmpty) return _savingsUrlFromEnv;
  throw UnimplementedError(
    'savingsBaseUrlProvider must be overridden by the host app, '
    'or SAVINGS_URL supplied with --dart-define.',
  );
});

final savingsTransportProvider = Provider<Transport>((ref) {
  final tokenProvider = ref.watch(authTokenProviderProvider);
  return createTransport(
    tokenProvider,
    baseUrl: ref.watch(savingsBaseUrlProvider),
  );
});

final savingsServiceClientProvider = Provider<SavingsServiceClient>((ref) {
  final transport = ref.watch(savingsTransportProvider);
  return SavingsServiceClient(transport);
});
