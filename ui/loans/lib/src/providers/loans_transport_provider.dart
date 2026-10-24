import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_core/api/api_base.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _loansUrl = String.fromEnvironment(
  'LOANS_URL',
  defaultValue: 'https://api.antinvestor.com/loans',
);

final loansTransportProvider = Provider<Transport>((ref) {
  final tokenProvider = ref.watch(authTokenProviderProvider);
  return createTransport(tokenProvider, baseUrl: _loansUrl);
});

final loanManagementServiceClientProvider =
    Provider<LoanManagementServiceClient>((ref) {
      final transport = ref.watch(loansTransportProvider);
      return LoanManagementServiceClient(transport);
    });
