import 'package:antinvestor_ui_core/responsive/breakpoints.dart';
import 'package:antinvestor_ui_core/theme/design_tokens.dart';
import '../utils/money_compat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/portfolio_providers.dart';

class PortfolioSummaryScreen extends ConsumerStatefulWidget {
  const PortfolioSummaryScreen({super.key});

  @override
  ConsumerState<PortfolioSummaryScreen> createState() =>
      _PortfolioSummaryScreenState();
}

class _PortfolioSummaryScreenState
    extends ConsumerState<PortfolioSummaryScreen> {
  String _organizationId = '';
  String _branchId = '';
  String _agentId = '';
  String _productId = '';

  PortfolioParams get _params => (
    organizationId: _organizationId,
    branchId: _branchId,
    agentId: _agentId,
    productId: _productId,
    clientId: '',
    currencyCode: '',
  );

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(portfolioSummaryProvider(_params));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = AppBreakpoints.isMobile(constraints.maxWidth);
        final padding = isMobile ? 16.0 : 24.0;
        final crossAxisCount = isMobile
            ? 2
            : (constraints.maxWidth > 900 ? 3 : 2);

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(portfolioSummaryProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(padding, padding, padding, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Portfolio Summary',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Aggregated financial metrics across your loan portfolio.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: _FilterBar(
                    organizationId: _organizationId,
                    branchId: _branchId,
                    agentId: _agentId,
                    productId: _productId,
                    onClear: () => setState(() {
                      _organizationId = '';
                      _branchId = '';
                      _agentId = '';
                      _productId = '';
                    }),
                  ),
                ),
              ),
              summaryAsync.when(
                data: (response) {
                  final s = response.data;
                  return SliverPadding(
                    padding: EdgeInsets.all(padding),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 110,
                      ),
                      delegate: SliverChildListDelegate([
                        _MetricCard(
                          label: 'Total Loans',
                          value: '${s.totalLoans}',
                          icon: Icons.folder_outlined,
                          accentColor: Colors.blue,
                        ),
                        _MetricCard(
                          label: 'Active Loans',
                          value: '${s.activeLoans}',
                          icon: Icons.check_circle_outline,
                          accentColor: Colors.green,
                        ),
                        _MetricCard(
                          label: 'Delinquent',
                          value: '${s.delinquentLoans}',
                          icon: Icons.warning_amber_outlined,
                          accentColor: Colors.orange,
                        ),
                        _MetricCard(
                          label: 'Default',
                          value: '${s.defaultLoans}',
                          icon: Icons.error_outline,
                          accentColor: Colors.red,
                        ),
                        _MoneyCard(
                          label: 'Total Disbursed',
                          money: s.totalDisbursed,
                          accentColor: Colors.indigo,
                        ),
                        _MoneyCard(
                          label: 'Total Outstanding',
                          money: s.totalOutstanding,
                          accentColor: Colors.deepOrange,
                        ),
                        _MoneyCard(
                          label: 'Total Collected',
                          money: s.totalCollected,
                          accentColor: Colors.teal,
                        ),
                        _MetricCard(
                          label: 'Collection Rate',
                          value: '${s.collectionRate}%',
                          icon: Icons.trending_up,
                          accentColor: Colors.green.shade700,
                        ),
                        _MetricCard(
                          label: 'PAR 30',
                          value: '${s.par30}%',
                          icon: Icons.show_chart,
                          accentColor: Colors.red.shade700,
                        ),
                        _MoneyCard(
                          label: 'Principal Outstanding',
                          money: s.principalOutstanding,
                          accentColor: Colors.blue.shade700,
                        ),
                        _MoneyCard(
                          label: 'Interest Outstanding',
                          money: s.interestOutstanding,
                          accentColor: Colors.purple,
                        ),
                        _MoneyCard(
                          label: 'Fees Outstanding',
                          money: s.feesOutstanding,
                          accentColor: Colors.brown,
                        ),
                      ]),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load portfolio summary',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: () =>
                              ref.invalidate(portfolioSummaryProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.organizationId,
    required this.branchId,
    required this.agentId,
    required this.productId,
    required this.onClear,
  });

  final String organizationId;
  final String branchId;
  final String agentId;
  final String productId;
  final VoidCallback onClear;

  bool get _hasFilters =>
      organizationId.isNotEmpty ||
      branchId.isNotEmpty ||
      agentId.isNotEmpty ||
      productId.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasFilters) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (organizationId.isNotEmpty)
            Chip(label: Text('Organization: $organizationId')),
          if (branchId.isNotEmpty) Chip(label: Text('Branch: $branchId')),
          if (agentId.isNotEmpty) Chip(label: Text('Agent: $agentId')),
          if (productId.isNotEmpty) Chip(label: Text('Product: $productId')),
          ActionChip(label: const Text('Clear'), onPressed: onClear),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Row(
        children: [
          Container(
            width: DesignTokens.accentBarWidth,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 22, color: accentColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          value,
                          style: GoogleFonts.manrope(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({
    required this.label,
    required this.money,
    required this.accentColor,
  });

  final String label;
  final dynamic money;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return _MetricCard(
      label: label,
      value: formatLoanMoney(money),
      icon: Icons.monetization_on_outlined,
      accentColor: accentColor,
    );
  }
}
