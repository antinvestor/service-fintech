import 'dart:convert';

import 'package:antinvestor_ui_core/analytics/analytics_models.dart';
import 'package:antinvestor_ui_core/analytics/analytics_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// REST analytics data source that talks to Thesa's POST query API.
///
/// Calls `{baseUrl}/api/analytics/query/*` endpoints with JSON POST bodies.
/// Supports scalar, time-series, grouped, and top-N queries.
class RestAnalyticsDataSource implements AnalyticsDataSource {
  RestAnalyticsDataSource(this._httpClient, this._baseUrl);

  final http.Client _httpClient;
  final String _baseUrl;

  // ── Direct query methods (new Thesa POST API) ──────────────────────────

  /// Query a single scalar value (sum, count, avg, etc.).
  ///
  /// For ratio queries, pass [numerator] and [denominator] instead of [metric].
  Future<double> queryScalar({
    String? metric,
    String aggregation = 'sum',
    Map<String, String>? filters,
    List<String>? partitionIds,
    Map<String, dynamic>? numerator,
    Map<String, dynamic>? denominator,
    required AnalyticsTimeRange timeRange,
  }) async {
    final body = <String, dynamic>{
      if (metric != null) 'metric': metric,
      'aggregation': aggregation,
      if (filters != null) 'filters': filters,
      if (partitionIds != null) 'partition_ids': partitionIds,
      if (numerator != null) 'numerator': numerator,
      if (denominator != null) 'denominator': denominator,
      ..._timeRangeBody(timeRange),
    };

    try {
      final response = await _post('/api/analytics/query/scalar', body);
      if (response.statusCode != 200) return 0;
      final data = json.decode(response.body) as Map<String, dynamic>;
      return (data['value'] as num?)?.toDouble() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Query time-series data points for a metric.
  Future<List<TimeSeriesPoint>> queryTimeSeries({
    required String metric,
    String aggregation = 'sum',
    Map<String, String>? filters,
    List<String>? partitionIds,
    required AnalyticsTimeRange timeRange,
    String? step,
  }) async {
    final body = <String, dynamic>{
      'metric': metric,
      'aggregation': aggregation,
      if (filters != null) 'filters': filters,
      if (partitionIds != null) 'partition_ids': partitionIds,
      if (step != null) 'step': step,
      ..._timeRangeBody(timeRange),
    };

    try {
      final response = await _post('/api/analytics/query/timeseries', body);
      if (response.statusCode != 200) return const [];
      final data = json.decode(response.body) as Map<String, dynamic>;
      final points = data['points'] as List<dynamic>? ?? [];
      return points.map((p) {
        final pm = p as Map<String, dynamic>;
        return TimeSeriesPoint(
          timestamp: DateTime.parse(pm['timestamp'] as String),
          value: (pm['value'] as num).toDouble(),
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Query grouped/distribution data for a metric.
  Future<List<DistributionSegment>> queryGrouped({
    required String metric,
    String aggregation = 'sum',
    required String groupBy,
    Map<String, String>? filters,
    List<String>? partitionIds,
    required AnalyticsTimeRange timeRange,
  }) async {
    final body = <String, dynamic>{
      'metric': metric,
      'aggregation': aggregation,
      'group_by': groupBy,
      if (filters != null) 'filters': filters,
      if (partitionIds != null) 'partition_ids': partitionIds,
      ..._timeRangeBody(timeRange),
    };

    try {
      final response = await _post('/api/analytics/query/grouped', body);
      if (response.statusCode != 200) return const [];
      final data = json.decode(response.body) as Map<String, dynamic>;
      final segments = data['segments'] as List<dynamic>? ?? [];
      return segments.map((s) {
        final map = s as Map<String, dynamic>;
        return DistributionSegment(
          label: map['label'] as String,
          value: (map['value'] as num).toDouble(),
          color: map['color'] != null
              ? Color(
                  int.parse((map['color'] as String).replaceFirst('#', '0xFF')),
                )
              : null,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  // ── AnalyticsDataSource interface (bridges old widgets) ────────────────

  @override
  Future<List<MetricValue>> getMetrics(
    String service, {
    AnalyticsTimeRange? timeRange,
  }) async {
    // Not used by the new dashboard; kept for interface compatibility.
    return const [];
  }

  @override
  Future<List<TimeSeries>> getTimeSeries(
    String service,
    String metric, {
    AnalyticsTimeRange? timeRange,
  }) async {
    final range = timeRange ?? AnalyticsTimeRange.last30Days();
    final points = await queryTimeSeries(metric: metric, timeRange: range);
    return [TimeSeries(key: metric, label: metric, points: points)];
  }

  @override
  Future<List<DistributionSegment>> getDistribution(
    String service,
    String metric,
    String groupBy, {
    AnalyticsTimeRange? timeRange,
  }) async {
    final range = timeRange ?? AnalyticsTimeRange.last30Days();
    return queryGrouped(metric: metric, groupBy: groupBy, timeRange: range);
  }

  @override
  Future<List<TopNItem>> getTopN(
    String service,
    String metric, {
    int limit = 10,
    AnalyticsTimeRange? timeRange,
  }) async {
    final range = timeRange ?? AnalyticsTimeRange.last30Days();
    final body = <String, dynamic>{
      'metric': metric,
      'aggregation': 'sum',
      'limit': limit,
      ..._timeRangeBody(range),
    };

    try {
      final response = await _post('/api/analytics/query/topn', body);
      if (response.statusCode != 200) return const [];
      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      return items.map((item) {
        final map = item as Map<String, dynamic>;
        return TopNItem(
          label: map['label'] as String,
          value: (map['value'] as num).toDouble(),
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Future<http.Response> _post(String path, Map<String, dynamic> body) {
    final uri = Uri.parse('$_baseUrl$path');
    return _httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
  }

  Map<String, dynamic> _timeRangeBody(AnalyticsTimeRange timeRange) => {
    'start': timeRange.start.toUtc().toIso8601String(),
    'end': timeRange.end.toUtc().toIso8601String(),
    if (timeRange.granularity != null)
      'granularity': timeRange.granularity!.name,
  };
}
