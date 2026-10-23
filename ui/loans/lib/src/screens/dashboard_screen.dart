import 'package:antinvestor_ui_core/responsive/breakpoints.dart';
import 'package:antinvestor_ui_core/theme/design_tokens.dart';
import '../utils/money_compat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/dashboard_providers.dart';
import '../providers/portfolio_providers.dart';

/// Dashboard variant determines which metrics and actions are shown.
/// The host app chooses which variant to display based on its own
/// authorization/role logic.
enum DashboardVariant { agent, creditTeam, manager }

class LoansDashboardScreen extends ConsumerWidget {
  const LoansDashboardScreen({
    super.key,
    this.variant = DashboardVariant.manager,
  });

  /// The dashboard variant to render. Host app sets this based on user roles.
  final DashboardVariant variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = AppBreakpoints.isMobile(constraints.maxWidth);
        final padding = isMobile ? 16.0 : 24.0;
        final crossAxisCount = isMobile
            ? 2
            : (constraints.maxWidth > 900 ? 3 : 2);

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(pendingApprovalCountProvider);
            ref.invalidate(approvedRequestsCountProvider);
            ref.invalidate(pendingDisbursementCountProvider);
            ref.invalidate(activeLoansCountProvider);
            ref.invalidate(delinquentLoansCountProvider);
            if (variant == DashboardVariant.manager) {
              ref.invalidate(portfolioSummaryProvider);
            }
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
                        _greetingTitle(variant),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _greetingSubtitle(variant),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(padding),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 110,
                  ),
                  delegate: SliverChildListDelegate(
                    _buildMetricCards(context, ref, variant),
                  ),
                ),
              ),
              if (variant == DashboardVariant.manager) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(padding, 8, padding, 12),
                    child: const _SectionLabel(label: 'PORTFOLIO HEALTH'),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(padding, 0, padding, 16),
                  sliver: SliverToBoxAdapter(child: _PortfolioHealthRow()),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(padding, 8, padding, 16),
                  child: const _SectionLabel(label: 'QUICK ACTIONS'),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 1 : crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 100,
                  ),
                  delegate: SliverChildListDelegate(
                    _buildQuickActions(context, variant),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _greetingTitle(DashboardVariant variant) {
    return switch (variant) {
      DashboardVariant.agent => 'Field Dashboard',
      DashboardVariant.creditTeam => 'Credit Team Dashboard',
      DashboardVariant.manager => 'Management Dashboard',
    };
  }

  String _greetingSubtitle(DashboardVariant variant) {
    return switch (variant) {
      DashboardVariant.agent => 'Your clients, applications, and active loans.',
      DashboardVariant.creditTeam =>
        'Your verification and underwriting queue.',
      DashboardVariant.manager =>
        'Overview of lending operations and portfolio health.',
    };
  }

  List<Widget> _buildMetricCards(
    BuildContext context,
    WidgetRef ref,
    DashboardVariant variant,
  ) {
    return switch (variant) {
      DashboardVariant.agent => [
        _MetricCard(
          label: 'Active Loans',
          icon: Icons.account_balance_wallet_outlined,
          accentColor: Colors.green,
          countAsync: ref.watch(activeLoansCountProvider),
          onTap: () => context.go('/loans'),
        ),
        _MetricCard(
          label: 'Pending Disbursement',
          icon: Icons.payments_outlined,
          accentColor: Colors.orange,
          countAsync: ref.watch(pendingDisbursementCountProvider),
          onTap: () => context.go('/loans'),
        ),
        _MetricCard(
          label: 'Delinquent Loans',
          icon: Icons.warning_amber_outlined,
          accentColor: Colors.red,
          countAsync: ref.watch(delinquentLoansCountProvider),
          onTap: () => context.go('/loans'),
        ),
        _MetricCard(
          label: 'Offer Pending',
          icon: Icons.local_offer_outlined,
          accentColor: Colors.teal,
          countAsync: ref.watch(pendingDisbursementCountProvider),
          onTap: () => context.go('/loans/requests'),
        ),
      ],
      DashboardVariant.creditTeam => [
        _MetricCard(
          label: 'Pending Verification',
          icon: Icons.verified_user_outlined,
          accentColor: Colors.purple,
          countAsync: ref.watch(pendingApprovalCountProvider),
          onTap: () => context.go('/loans/requests/pending'),
        ),
        _MetricCard(
          label: 'Pending Underwriting',
          icon: Icons.gavel_outlined,
          accentColor: Colors.indigo,
          countAsync: ref.watch(approvedRequestsCountProvider),
          onTap: () => context.go('/loans/requests/pending'),
        ),
        _MetricCard(
          label: 'Offer Pending',
          icon: Icons.local_offer_outlined,
          accentColor: Colors.teal,
          countAsync: ref.watch(pendingDisbursementCountProvider),
          onTap: () => context.go('/loans/requests'),
        ),
        _MetricCard(
          label: 'Active Loans',
          icon: Icons.account_balance_wallet_outlined,
          accentColor: Colors.green,
          countAsync: ref.watch(activeLoansCountProvider),
          onTap: () => context.go('/loans'),
        ),
      ],
      DashboardVariant.manager => [
        _MetricCard(
          label: 'Pending Verification',
          icon: Icons.verified_user_outlined,
          accentColor: Colors.purple,
          countAsync: ref.watch(pendingApprovalCountProvider),
          onTap: () => context.go('/loans/requests'),
        ),
        _MetricCard(
          label: 'Pending Underwriting',
          icon: Icons.gavel_outlined,
          accentColor: Colors.indigo,
          countAsync: ref.watch(approvedRequestsCountProvider),
          onTap: () => context.go('/loans/requests'),
        ),
        _MetricCard(
          label: 'Offer Pending',
          icon: Icons.local_offer_outlined,
          accentColor: Colors.teal,
          countAsync: ref.watch(pendingDisbursementCountProvider),
          onTap: () => context.go('/loans/requests'),
        ),
        _MetricCard(
          label: 'Active Loans',
          icon: Icons.account_balance_wallet_outlined,
          accentColor: Colors.green,
          countAsync: ref.watch(activeLoansCountProvider),
          onTap: () => context.go('/loans'),
        ),
        _MetricCard(
          label: 'Pending Disbursement',
          icon: Icons.payments_outlined,
          accentColor: Colors.orange,
          countAsync: ref.watch(pendingDisbursementCountProvider),
          onTap: () => context.go('/loans'),
        ),
        _MetricCard(
          label: 'Delinquent Loans',
          icon: Icons.warning_amber_outlined,
          accentColor: Colors.red,
          countAsync: ref.watch(delinquentLoansCountProvider),
          onTap: () => context.go('/loans'),
        ),
      ],
    };
  }

  List<Widget> _buildQuickActions(
    BuildContext context,
    DashboardVariant variant,
  ) {
    return switch (variant) {
      DashboardVariant.agent => [
        _QuickActionCard(
          icon: Icons.description_outlined,
          label: 'Applications',
          subtitle: 'Create and track applications',
          onTap: () => context.go('/loans/requests'),
        ),
        _QuickActionCard(
          icon: Icons.credit_score_outlined,
          label: 'Loan Accounts',
          subtitle: 'View active loans',
          onTap: () => context.go('/loans'),
        ),
      ],
      DashboardVariant.creditTeam => [
        _QuickActionCard(
          icon: Icons.assignment_late_outlined,
          label: 'Pending Cases',
          subtitle: 'Cases requiring your action',
          onTap: () => context.go('/loans/requests/pending'),
        ),
        _QuickActionCard(
          icon: Icons.description_outlined,
          label: 'All Applications',
          subtitle: 'Browse & manage applications',
          onTap: () => context.go('/loans/requests'),
        ),
        _QuickActionCard(
          icon: Icons.credit_score_outlined,
          label: 'Loan Accounts',
          subtitle: 'View loan accounts',
          onTap: () => context.go('/loans'),
        ),
      ],
      DashboardVariant.manager => [
        _QuickActionCard(
          icon: Icons.assignment_late_outlined,
          label: 'Pending Cases',
          subtitle: 'View all cases requiring action',
          onTap: () => context.go('/loans/requests/pending'),
        ),
        _QuickActionCard(
          icon: Icons.description_outlined,
          label: 'All Applications',
          subtitle: 'Browse & manage applications',
          onTap: () => context.go('/loans/requests'),
        ),
        _QuickActionCard(
          icon: Icons.credit_score_outlined,
          label: 'Loan Accounts',
          subtitle: 'Manage active loan accounts',
          onTap: () => context.go('/loans'),
        ),
        _QuickActionCard(
          icon: Icons.pie_chart_outline,
          label: 'Portfolio Summary',
          subtitle: 'Portfolio health & metrics',
          onTap: () => context.go('/reports/portfolio'),
        ),
      ],
    };
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Metric card
// ---------------------------------------------------------------------------

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.countAsync,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
  final AsyncValue<int> countAsync;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: DesignTokens.borderRadiusAll,
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
                          countAsync.when(
                            data: (count) => Text(
                              '$count',
                              style: GoogleFonts.manrope(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: count > 0 ? accentColor : null,
                              ),
                            ),
                            loading: () => const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            error: (_, _) => Icon(
                              Icons.error_outline,
                              size: 20,
                              color: theme.colorScheme.error,
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
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: theme.colorScheme.onSurface.withAlpha(60),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick action card
// ---------------------------------------------------------------------------

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: DesignTokens.borderRadiusAll,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 24, color: theme.colorScheme.secondary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: theme.colorScheme.onSurface.withAlpha(80),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Portfolio health row
// ---------------------------------------------------------------------------

class _PortfolioHealthRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(
      portfolioSummaryProvider(emptyPortfolioParams),
    );

    return summaryAsync.when(
      data: (response) {
        final s = response.data;
        return Row(
          children: [
            Expanded(
              child: _HealthCard(
                label: 'Total Outstanding',
                value: formatLoanMoney(s.totalOutstanding),
                icon: Icons.account_balance_wallet,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HealthCard(
                label: 'Collection Rate',
                value: '${s.collectionRate}%',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HealthCard(
                label: 'PAR 30',
                value: '${s.par30}%',
                icon: Icons.warning_amber,
                color: Colors.red,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const SizedBox(
        height: 80,
        child: Center(child: Text('Portfolio data unavailable')),
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
