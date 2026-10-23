import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'loans_transport_provider.dart';

/// Parameters for portfolio queries.
typedef PortfolioParams = ({
  String organizationId,
  String branchId,
  String agentId,
  String productId,
  String clientId,
  String currencyCode,
});

/// Default (empty) portfolio params.
const emptyPortfolioParams = (
  organizationId: '',
  branchId: '',
  agentId: '',
  productId: '',
  clientId: '',
  currencyCode: '',
);

/// Fetches the portfolio summary with optional filters.
final portfolioSummaryProvider =
    FutureProvider.family<PortfolioSummaryResponse, PortfolioParams>((
      ref,
      params,
    ) async {
      final client = ref.watch(loanManagementServiceClientProvider);
      final request = PortfolioSummaryRequest(
        organizationId: params.organizationId,
        branchId: params.branchId,
        agentId: params.agentId,
        productId: params.productId,
        clientId: params.clientId,
        currencyCode: params.currencyCode,
      );
      return client.portfolioSummary(request);
    });

/// Exports the loan book with optional filters.
final portfolioExportProvider =
    FutureProvider.family<
      PortfolioExportResponse,
      ({PortfolioParams params, String format})
    >((ref, args) async {
      final client = ref.watch(loanManagementServiceClientProvider);
      final request = PortfolioExportRequest(
        organizationId: args.params.organizationId,
        branchId: args.params.branchId,
        agentId: args.params.agentId,
        productId: args.params.productId,
        clientId: args.params.clientId,
        currencyCode: args.params.currencyCode,
        format: args.format,
      );
      return client.portfolioExport(request);
    });
