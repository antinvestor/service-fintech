import 'dart:convert';

import 'package:antinvestor_ui_core/analytics/analytics_models.dart';
import 'package:antinvestor_ui_core/analytics/thesa_analytics_data_source.dart';
import 'package:antinvestor_ui_core/auth/auth_token_provider.dart';
import 'package:http/http.dart' as http;

/// Builds the [AnalyticsTransport] consumed by [SeedAnalyticsDataSource]:
/// JSON POSTs against the Thesa BFF with the caller's bearer token
/// attached. Tenant scoping is injected server-side from the JWT.
AnalyticsTransport seedAnalyticsTransport(
  http.Client client,
  AuthTokenProvider tokenProvider,
  String baseUrl,
) {
  return (String path, {Object? body}) async {
    final token = await tokenProvider.ensureValidAccessToken();
    return client.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: body,
    );
  };
}

/// Seed's analytics data source: the standard ui_core
/// [ThesaAnalyticsDataSource] plus one extension query that spans every
/// org unit (partition) the caller can access.
class SeedAnalyticsDataSource extends ThesaAnalyticsDataSource {
  // Not convertible to a super parameter: the transport is also kept on
  // this class for the partition-wide extension query below.
  // ignore: use_super_parameters
  SeedAnalyticsDataSource(AnalyticsTransport transport)
    : _transport = transport,
      super(transport);

  final AnalyticsTransport _transport;

  /// Grouped query with `partition_ids: ["*"]` so the server widens the
  /// scope to all partitions the caller can access (it validates
  /// accessibility and still injects the tenant filter from the JWT).
  Future<List<DistributionSegment>> queryGroupedAllPartitions({
    required String metric,
    required String groupBy,
    AnalyticsAggregation aggregation = AnalyticsAggregation.sum,
    AnalyticsTimeRange? timeRange,
  }) async {
    final body = <String, dynamic>{
      'metric': metric,
      'aggregation': aggregation.wireName,
      'group_by': groupBy,
      'partition_ids': const ['*'],
      if (timeRange != null)
        'time_range': {
          'start': timeRange.start.toUtc().toIso8601String(),
          'end': timeRange.end.toUtc().toIso8601String(),
        },
    };

    const path = '/api/analytics/query/grouped';
    final response = await _transport(path, body: json.encode(body));
    if (response.statusCode != 200) {
      throw AnalyticsQueryException(
        statusCode: response.statusCode,
        message: _serverError(response),
        path: path,
      );
    }
    final data = json.decode(utf8.decode(response.bodyBytes));
    final segments =
        (data as Map<String, dynamic>)['segments'] as List<dynamic>? ??
        const [];
    return [
      for (final s in segments.cast<Map<String, dynamic>>())
        DistributionSegment(
          label: s['label'] as String,
          value: (s['value'] as num).toDouble(),
        ),
    ];
  }

  static String _serverError(http.Response response) {
    try {
      final parsed = json.decode(utf8.decode(response.bodyBytes));
      final msg = (parsed as Map<String, dynamic>)['error'];
      if (msg is String && msg.isNotEmpty) return msg;
    } catch (_) {
      // Fall through to the generic message.
    }
    return 'HTTP ${response.statusCode}';
  }
}

/// Maps analytics gate failures onto user-facing copy. The gate returns
/// 400 for allowlist/validation rejections, 403 when the JWT carries no
/// tenant claims, and 5xx when the metrics backend is down.
String friendlyAnalyticsMessage(Object error) {
  if (error is AnalyticsQueryException) {
    return switch (error.statusCode) {
      401 || 403 =>
        'You do not have access to analytics for this organisation. '
            'Sign in with a tenant account or contact an administrator.',
      400 => 'The analytics service rejected this query: ${error.message}',
      >= 500 =>
        'The analytics service is temporarily unavailable. Please retry '
            'in a moment.',
      _ => 'Analytics request failed (${error.statusCode}): ${error.message}',
    };
  }
  return 'Could not reach the analytics service. Check your connection '
      'and retry.';
}
