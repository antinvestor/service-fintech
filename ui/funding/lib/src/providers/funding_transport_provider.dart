import 'package:antinvestor_api_funding/antinvestor_api_funding.dart';
import 'package:antinvestor_ui_core/api/api_base.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _fundingUrlFromEnv = String.fromEnvironment('FUNDING_URL');

/// Base URL of the funding service.
///
/// There is deliberately no public fallback: an embedding app that forgets to
/// point this at its own environment should fail loudly at startup rather than
/// quietly send investor capital traffic to someone else's deployment. Host
/// apps override this (or `fundingTransportProvider`) in their ProviderScope;
/// a `FUNDING_URL` define is honoured for local development.
final fundingBaseUrlProvider = Provider<String>((ref) {
  if (_fundingUrlFromEnv.isNotEmpty) return _fundingUrlFromEnv;
  throw UnimplementedError(
    'fundingBaseUrlProvider must be overridden by the host app, '
    'or FUNDING_URL supplied with --dart-define.',
  );
});

final fundingTransportProvider = Provider<Transport>((ref) {
  final tokenProvider = ref.watch(authTokenProviderProvider);
  return createTransport(
    tokenProvider,
    baseUrl: ref.watch(fundingBaseUrlProvider),
  );
});

final fundingServiceClientProvider = Provider<FundingServiceClient>((ref) {
  final transport = ref.watch(fundingTransportProvider);
  return FundingServiceClient(transport);
});
