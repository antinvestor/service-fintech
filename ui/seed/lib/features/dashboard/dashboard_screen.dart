import 'package:antinvestor_ui_core/analytics/analytics_models.dart';
import 'package:antinvestor_ui_core/analytics/analytics_provider.dart';
import 'package:antinvestor_ui_core/analytics/distribution_chart.dart';
import 'package:antinvestor_ui_core/analytics/metric_card.dart';
import 'package:antinvestor_ui_core/analytics/time_range_selector.dart';
import 'package:antinvestor_ui_core/analytics/time_series_chart.dart';
import 'package:antinvestor_ui_core/responsive/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/analytics_client.dart';

/// Lending-focused analytics dashboard for Seed.
///
/// Displays business health KPIs, today's snapshot, trend charts,
/// and org unit proportions using the Thesa POST query API.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late AnalyticsTimeRange _timeRange;
  bool _loading = true;
  String? _error;

  // Row 1: Business health KPIs
  double _totalCustomers = 0;
  double _activeLoans = 0;
  double _portfolioValue = 0;
  double _defaultRate = 0;

  // Row 2: Today's snapshot
  double _loansDisbursedToday = 0;
  double _amountDisbursedToday = 0;
  double _amountRepaidToday = 0;
  double _defaultsToday = 0;

  // Row 3: Time series
  List<TimeSeriesPoint> _customerGrowthSeries = const [];
  List<TimeSeriesPoint> _portfolioGrowthSeries = const [];

  // Row 4: Distribution
  List<DistributionSegment> _orgUnitSegments = const [];

  @override
  void initState() {
    super.initState();
    _timeRange = AnalyticsTimeRange.last30Days();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAll());
  }

  RestAnalyticsDataSource get _ds =>
      ref.read(analyticsDataSourceProvider) as RestAnalyticsDataSource;

  AnalyticsTimeRange get _todayRange {
    final now = DateTime.now().toUtc();
    final startOfDay = DateTime.utc(now.year, now.month, now.day);
    return AnalyticsTimeRange(
      start: startOfDay,
      end: now,
      granularity: TimeGranularity.hour,
    );
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ds = _ds;
      final tr = _timeRange;
      final today = _todayRange;

      final results = await Future.wait([
        // 0: Total customers
        ds.queryScalar(
          metric: 'identity_organizations_created_total',
          aggregation: 'sum',
          timeRange: tr,
        ),
        // 1: Loans created
        ds.queryScalar(
          metric: 'loans_created_total',
          aggregation: 'sum',
          timeRange: tr,
        ),
        // 2: Loans closed
        ds.queryScalar(
          metric: 'loans_closed_total',
          aggregation: 'sum',
          timeRange: tr,
        ),
        // 3: Loans defaulted
        ds.queryScalar(
          metric: 'loans_defaulted_total',
          aggregation: 'sum',
          timeRange: tr,
        ),
        // 4: Loans written off
        ds.queryScalar(
          metric: 'loans_written_off_total',
          aggregation: 'sum',
          timeRange: tr,
        ),
        // 5: Disbursed amount
        ds.queryScalar(
          metric: 'loans_disbursed_amount_total',
          aggregation: 'sum',
          timeRange: tr,
        ),
        // 6: Repaid amount
        ds.queryScalar(
          metric: 'loans_repaid_amount_total',
          aggregation: 'sum',
          timeRange: tr,
        ),
        // 7: Default rate (ratio)
        ds.queryScalar(
          numerator: {'metric': 'loans_defaulted_total', 'aggregation': 'sum'},
          denominator: {'metric': 'loans_created_total', 'aggregation': 'sum'},
          timeRange: tr,
        ),
        // 8-11: Today's snapshot
        ds.queryScalar(
          metric: 'loans_disbursed_total',
          aggregation: 'sum',
          timeRange: today,
        ),
        ds.queryScalar(
          metric: 'loans_disbursed_amount_total',
          aggregation: 'sum',
          timeRange: today,
        ),
        ds.queryScalar(
          metric: 'loans_repaid_amount_total',
          aggregation: 'sum',
          timeRange: today,
        ),
        ds.queryScalar(
          metric: 'loans_defaulted_total',
          aggregation: 'sum',
          timeRange: today,
        ),
        // 12: Customer growth time series
        ds.queryTimeSeries(
          metric: 'identity_organizations_created_total',
          timeRange: tr,
        ),
        // 13: Portfolio growth time series
        ds.queryTimeSeries(
          metric: 'loans_disbursed_amount_total',
          timeRange: tr,
        ),
        // 14: Org unit distribution
        ds.queryGrouped(
          metric: 'loans_disbursed_amount_total',
          groupBy: 'partition_id',
          partitionIds: ['*'],
          timeRange: tr,
        ),
      ]);

      if (!mounted) return;

      final loansCreated = results[1] as double;
      final loansClosed = results[2] as double;
      final loansDefaulted = results[3] as double;
      final loansWrittenOff = results[4] as double;
      final disbursedAmount = results[5] as double;
      final repaidAmount = results[6] as double;

      setState(() {
        _totalCustomers = results[0] as double;
        _activeLoans =
            loansCreated - loansClosed - loansDefaulted - loansWrittenOff;
        _portfolioValue = disbursedAmount - repaidAmount;
        _defaultRate = (results[7] as double) * 100; // Convert to percentage
        _loansDisbursedToday = results[8] as double;
        _amountDisbursedToday = results[9] as double;
        _amountRepaidToday = results[10] as double;
        _defaultsToday = results[11] as double;
        _customerGrowthSeries = results[12] as List<TimeSeriesPoint>;
        _portfolioGrowthSeries = results[13] as List<TimeSeriesPoint>;
        _orgUnitSegments = results[14] as List<DistributionSegment>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load dashboard data: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = AppBreakpoints.isDesktop(width);

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
            _ErrorBanner(message: _error!),
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
    Widget buildChart(String title, List<TimeSeriesPoint> points, String key) {
      return _ChartCard(
        title: title,
        loading: _loading,
        child: points.isEmpty && !_loading
            ? SizedBox(
                height: 240,
                child: Center(
                  child: Text(
                    'No data',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
              )
            : TimeSeriesChart(
                series: [TimeSeries(key: key, label: title, points: points)],
                granularity: _timeRange.granularity,
              ),
      );
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
    return _ChartCard(
      title: 'Disbursements by Org Unit',
      loading: _loading,
      child: DistributionChart(segments: _orgUnitSegments),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  MetricCard _kpiMetric(
    String label,
    double value,
    String unit,
    IconData icon,
  ) {
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

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
        ],
      ),
    );
  }
}
