import 'package:antinvestor_api_operations/antinvestor_api_operations.dart';
import 'package:antinvestor_ui_core/api/api_base.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _operationsUrl = String.fromEnvironment(
  'OPERATIONS_URL',
  defaultValue: 'https://api.antinvestor.com/operations',
);

final operationsTransportProvider = Provider<Transport>((ref) {
  final tokenProvider = ref.watch(authTokenProviderProvider);
  return createTransport(tokenProvider, baseUrl: _operationsUrl);
});

final operationsServiceClientProvider = Provider<OperationsServiceClient>((
  ref,
) {
  final transport = ref.watch(operationsTransportProvider);
  return OperationsServiceClient(transport);
});
