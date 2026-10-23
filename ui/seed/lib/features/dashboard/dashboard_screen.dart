import 'package:antinvestor_ui_core/analytics/analytics_models.dart';
import 'package:antinvestor_ui_core/analytics/analytics_provider.dart';
import 'package:antinvestor_ui_core/analytics/distribution_chart.dart';
import 'package:antinvestor_ui_core/analytics/metric_card.dart';
import 'package:antinvestor_ui_core/analytics/time_range_selector.dart';
import 'package:antinvestor_ui_core/analytics/time_series_chart.dart';
import 'package:antinvestor_ui_core/responsive/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/analytics_data_source.dart';

/// Lending-focused analytics dashboard for Seed.
///
/// Displays business health KPIs, today's snapshot, trend charts,
/// and org unit proportions using the standardized Thesa analytics
/// gate (ui_core's ThesaAnalyticsDataSource). Tenant scoping is
/// injected server-side from the JWT; no tenant filters are sent.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late AnalyticsTimeRange _timeRange;
  bool _loading = true;
  String? _error;

  // Every tile below is nullable: a metric whose query failed shows as
  // unavailable while the rest of the dashboard keeps working. One bad
  // query used to blank the whole page.

  // Row 1: Business health KPIs
  double? _totalCustomers;
  double? _activeLoans;
  double? _portfolioValue;
  double? _defaultRate;

  // Row 2: Today's snapshot
  double? _loansDisbursedToday;
  double? _amountDisbursedToday;
  double? _amountRepaidToday;
  double? _defaultsToday;

  // Row 3: Time series
  List<TimeSeriesPoint>? _customerGrowthSeries;
  List<TimeSeriesPoint>? _portfolioGrowthSeries;

  // Row 4: Distribution
  List<DistributionSegment>? _orgUnitSegments;

  @override
  void initState() {
    super.initState();
    _timeRange = AnalyticsTimeRange.last30Days();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAll());
  }

  SeedAnalyticsDataSource get _ds =>
      ref.read(analyticsDataSourceProvider) as SeedAnalyticsDataSource;

  AnalyticsTimeRange get _todayRange {
    final now = DateTime.now().toUtc();
    final startOfDay = DateTime.utc(now.year, now.month, now.day);
    return AnalyticsTimeRange(
      start: startOfDay,
      end: now,
      granularity: TimeGranularity.hour,
    );
  }

  /// Runs [query] and reports failure instead of propagating it, so one
  /// unavailable metric cannot take the page down with it.
  Future<T?> _settle<T>(Future<T> query, List<Object> failures) async {
    try {
      return await query;
    } on Exception catch (e) {
      failures.add(e);
      return null;
    }
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final ds = _ds;
    final tr = _timeRange;
    final today = _todayRange;
    final failures = <Object>[];

    Future<double?> scalar(String metric, AnalyticsTimeRange range) =>
        _settle(ds.queryScalar(metric: metric, timeRange: range), failures);

    final totalCustomers = scalar('identity_organizations_created_total', tr);
    final loansCreated = scalar('loans_created_total', tr);
    final loansClosed = scalar('loans_closed_total', tr);
    final loansDefaulted = scalar('loans_defaulted_total', tr);
    final loansWrittenOff = scalar('loans_written_off_total', tr);
    final disbursedAmount = scalar('loans_disbursed_amount_total', tr);
    final repaidAmount = scalar('loans_repaid_amount_total', tr);
    final disbursedToday = scalar('loans_disbursed_total', today);
    final amountDisbursedToday = scalar('loans_disbursed_amount_total', today);
    final amountRepaidToday = scalar('loans_repaid_amount_total', today);
    final defaultsToday = scalar('loans_defaulted_total', today);
    final customerGrowth = _settle(
      ds.queryTimeSeries(
        metric: 'identity_organizations_created_total',
        timeRange: tr,
      ),
      failures,
    );
    final portfolioGrowth = _settle(
      ds.queryTimeSeries(metric: 'loans_disbursed_amount_total', timeRange: tr),
      failures,
    );
    final orgUnits = _settle(
      ds.queryGroupedAllPartitions(
        metric: 'loans_disbursed_amount_total',
        groupBy: 'partition_id',
        timeRange: tr,
      ),
      failures,
    );

    final created = await loansCreated;
    final closed = await loansClosed;
    final defaulted = await loansDefaulted;
    final writtenOff = await loansWrittenOff;
    final disbursed = await disbursedAmount;
    final repaid = await repaidAmount;

    final resolved = (
      totalCustomers: await totalCustomers,
      activeLoans:
          (created == null ||
              closed == null ||
              defaulted == null ||
              writtenOff == null)
          ? null
          : created - closed - defaulted - writtenOff,
      portfolioValue: (disbursed == null || repaid == null)
          ? null
          : disbursed - repaid,
      // Default rate is computed client-side from the scalars above; the
      // standard gate contract has no ratio query.
      defaultRate: (created == null || defaulted == null)
          ? null
          : (created > 0 ? (defaulted / created) * 100 : 0.0),
      disbursedToday: await disbursedToday,
      amountDisbursedToday: await amountDisbursedToday,
      amountRepaidToday: await amountRepaidToday,
      defaultsToday: await defaultsToday,
      customerGrowth: await customerGrowth,
      portfolioGrowth: await portfolioGrowth,
      orgUnits: await orgUnits,
    );

    if (!mounted) return;

    setState(() {
      _totalCustomers = resolved.totalCustomers;
      _activeLoans = resolved.activeLoans;
      _portfolioValue = resolved.portfolioValue;
      _defaultRate = resolved.defaultRate;
      _loansDisbursedToday = resolved.disbursedToday;
      _amountDisbursedToday = resolved.amountDisbursedToday;
      _amountRepaidToday = resolved.amountRepaidToday;
      _defaultsToday = resolved.defaultsToday;
      _customerGrowthSeries = resolved.customerGrowth;
      _portfolioGrowthSeries = resolved.portfolioGrowth;
      _orgUnitSegments = resolved.orgUnits;
      _error = failures.isEmpty
          ? null
          : friendlyAnalyticsMessage(failures.first);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Breakpoints are measured against the content pane, not the window: the
    // sidebar takes 260px, so MediaQuery would apply the desktop 4-across
    // layout to a pane far narrower than it assumes.
    return LayoutBuilder(
      builder: (context, constraints) => _buildBody(
        context,
        theme,
        cs,
        AppBreakpoints.isDesktop(constraints.maxWidth),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    bool isDesktop,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + time range
          Row(
            children: [
              Expanded(
                child: Text(
                  'Lending Dashboard',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: _fetchAll,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: TimeRangeSelector(
              value: _timeRange,
              onChanged: (range) {
                setState(() => _timeRange = range);
                _fetchAll();
              },
            ),
          ),
          const SizedBox(height: 24),

          if (_error != null) ...[
            _ErrorBanner(
              message: 'Some metrics are unavailable: ${_error!}',
              onRetry: _fetchAll,
            ),
            const SizedBox(height: 16),
          ],

          // Row 1: Business health KPIs
          _SectionLabel(label: 'Business Health'),
          const SizedBox(height: 12),
          _buildKpiGrid(isDesktop, cs, theme),
          const SizedBox(height: 24),

          // Row 2: Today's snapshot
          _SectionLabel(label: "Today's Snapshot"),
          const SizedBox(height: 12),
          _buildTodayGrid(isDesktop, cs, theme),
          const SizedBox(height: 24),

          // Row 3: Trend charts
          _SectionLabel(label: 'Trends'),
          const SizedBox(height: 12),
          _buildTrendCharts(isDesktop, cs, theme),
          const SizedBox(height: 24),

          // Row 4: Org unit proportions
          _SectionLabel(label: 'Disbursements by Org Unit'),
          const SizedBox(height: 12),
          _buildDistributionSection(cs, theme),
        ],
      ),
    );
  }

  // ── Row 1: Business Health KPIs ──────────────────────────────────────

  Widget _buildKpiGrid(bool isDesktop, ColorScheme cs, ThemeData theme) {
    final cards = [
      _kpiMetric(
        'Total Customers',
        _totalCustomers,
        'count',
        Icons.people_outlined,
      ),
      _kpiMetric(
        'Active Loans',
        _activeLoans,
        'count',
        Icons.receipt_long_outlined,
      ),
      _kpiMetric(
        'Portfolio Value',
        _portfolioValue,
        'currency',
        Icons.account_balance_wallet_outlined,
      ),
      _kpiMetric(
        'Default Rate',
        _defaultRate,
        'percent',
        Icons.warning_amber_outlined,
      ),
    ];

    return _ResponsiveCardRow(
      isDesktop: isDesktop,
      loading: _loading,
      children: cards,
    );
  }

  // ── Row 2: Today's Snapshot ──────────────────────────────────────────

  Widget _buildTodayGrid(bool isDesktop, ColorScheme cs, ThemeData theme) {
    final cards = [
      _kpiMetric(
        'Loans Disbursed Today',
        _loansDisbursedToday,
        'count',
        Icons.send_outlined,
      ),
      _kpiMetric(
        'Amount Disbursed Today',
        _amountDisbursedToday,
        'currency',
        Icons.payments_outlined,
      ),
      _kpiMetric(
        'Amount Repaid Today',
        _amountRepaidToday,
        'currency',
        Icons.savings_outlined,
      ),
      _kpiMetric(
        'Defaults Today',
        _defaultsToday,
        'count',
        Icons.error_outline,
      ),
    ];

    return _ResponsiveCardRow(
      isDesktop: isDesktop,
      loading: _loading,
      children: cards,
    );
  }

  // ── Row 3: Trend Charts ──────────────────────────────────────────────

  Widget _buildTrendCharts(bool isDesktop, ColorScheme cs, ThemeData theme) {
    Widget buildChart(String title, List<TimeSeriesPoint>? points, String key) {
      Widget body;
      if (points == null) {
        body = _ChartPlaceholder(
          message: 'Unavailable',
          color: cs.onSurfaceVariant,
        );
      } else if (points.isEmpty) {
        body = _ChartPlaceholder(
          message: 'No data',
          color: cs.onSurfaceVariant,
        );
      } else {
        body = TimeSeriesChart(
          series: [TimeSeries(key: key, label: title, points: points)],
          granularity: _timeRange.granularity,
        );
      }
      return _ChartCard(title: title, loading: _loading, child: body);
    }

    final customerChart = buildChart(
      'Customer Growth',
      _customerGrowthSeries,
      'customer_growth',
    );
    final portfolioChart = buildChart(
      'Portfolio Growth',
      _portfolioGrowthSeries,
      'portfolio_growth',
    );

    if (!isDesktop) {
      return Column(
        children: [customerChart, const SizedBox(height: 16), portfolioChart],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: customerChart),
          const SizedBox(width: 16),
          Expanded(child: portfolioChart),
        ],
      ),
    );
  }

  // ── Row 4: Distribution ──────────────────────────────────────────────

  Widget _buildDistributionSection(ColorScheme cs, ThemeData theme) {
    final segments = _orgUnitSegments;
    return _ChartCard(
      title: 'Disbursements by Org Unit',
      loading: _loading,
      child: segments == null
          ? _ChartPlaceholder(
              message: 'Unavailable',
              color: cs.onSurfaceVariant,
            )
          : DistributionChart(segments: segments),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Widget _kpiMetric(String label, double? value, String unit, IconData icon) {
    if (value == null) return _UnavailableMetric(label: label, icon: icon);
    return MetricCard(
      compact: true,
      metric: MetricValue(
        key: label,
        label: label,
        value: value,
        unit: unit,
        icon: icon,
      ),
    );
  }
}

// ── Reusable internal widgets ──────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _ResponsiveCardRow extends StatelessWidget {
  const _ResponsiveCardRow({
    required this.isDesktop,
    required this.loading,
    required this.children,
  });

  final bool isDesktop;
  final bool loading;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _SkeletonRow(count: children.length, isDesktop: isDesktop);
    }

    if (!isDesktop) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final child in children)
            SizedBox(width: double.infinity, child: child),
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.count, required this.isDesktop});
  final int count;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final placeholder = Container(
      height: 100,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );

    if (!isDesktop) {
      return Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            placeholder,
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: placeholder),
        ],
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.loading,
    required this.child,
  });

  final String title;
  final bool loading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            child,
        ],
      ),
    );
  }
}

/// Placeholder for a single metric whose query failed. The tile keeps its
/// place in the grid so the layout does not shift when a metric is missing.
class _UnavailableMetric extends StatelessWidget {
  const _UnavailableMetric({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Unavailable',
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Center(
        child: Text(message, style: TextStyle(color: color)),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: cs.error, fontSize: 13),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
