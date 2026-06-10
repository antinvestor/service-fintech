import 'dart:async';
import 'dart:convert';

import 'package:antinvestor_ui_core/analytics/analytics_provider.dart';
import 'package:antinvestor_ui_core/analytics/thesa_analytics_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:seed_ui/core/data/analytics_data_source.dart';
import 'package:seed_ui/features/dashboard/dashboard_screen.dart';

/// A request captured by the mocked analytics transport.
class RecordedRequest {
  RecordedRequest(this.path, this.body);
  final String path;
  final Map<String, dynamic> body;
}

/// Mocked [AnalyticsTransport] that records every request and replies
/// with canned per-endpoint payloads (or a fixed error).
AnalyticsTransport mockTransport(
  List<RecordedRequest> log, {
  int statusCode = 200,
  String errorMessage = 'boom',
  Map<String, double> scalarByMetric = const {},
  List<Map<String, dynamic>> points = const [],
  List<Map<String, dynamic>> segments = const [],
}) {
  return (String path, {Object? body}) async {
    final decoded = json.decode(body! as String) as Map<String, dynamic>;
    log.add(RecordedRequest(path, decoded));
    if (statusCode != 200) {
      return http.Response(json.encode({'error': errorMessage}), statusCode);
    }
    final Object payload;
    if (path.endsWith('/scalar')) {
      payload = {'value': scalarByMetric[decoded['metric']] ?? 0};
    } else if (path.endsWith('/timeseries')) {
      payload = {'points': points};
    } else if (path.endsWith('/grouped')) {
      payload = {'segments': segments};
    } else {
      payload = {'items': <Object>[]};
    }
    return http.Response(json.encode(payload), 200);
  };
}

Widget app(SeedAnalyticsDataSource ds) {
  return ProviderScope(
    overrides: [analyticsDataSourceProvider.overrideWithValue(ds)],
    child: const MaterialApp(home: Scaffold(body: DashboardScreen())),
  );
}

/// Asserts the deterministic part of a request body matches [expected]
/// exactly, and that the stripped `time_range` is well-formed RFC3339.
void expectBody(RecordedRequest req, Map<String, dynamic> expected) {
  final body = Map<String, dynamic>.of(req.body);
  final timeRange = body.remove('time_range') as Map<String, dynamic>?;
  expect(timeRange, isNotNull, reason: 'time_range missing on ${req.path}');
  expect(DateTime.parse(timeRange!['start'] as String).isUtc, isTrue);
  expect(DateTime.parse(timeRange['end'] as String).isUtc, isTrue);
  expect(body, expected, reason: 'unexpected body for ${req.path}');
}

void main() {
  testWidgets('dashboard issues the exact standardized analytics queries', (
    tester,
  ) async {
    final log = <RecordedRequest>[];
    final ds = SeedAnalyticsDataSource(
      mockTransport(
        log,
        scalarByMetric: {
          'identity_organizations_created_total': 120,
          'loans_created_total': 100,
          'loans_closed_total': 30,
          'loans_defaulted_total': 5,
          'loans_written_off_total': 2,
          'loans_disbursed_amount_total': 500000,
          'loans_repaid_amount_total': 200000,
          'loans_disbursed_total': 9,
        },
        points: [
          {'timestamp': '2026-06-01T00:00:00Z', 'value': 4},
          {'timestamp': '2026-06-02T00:00:00Z', 'value': 6},
        ],
        segments: [
          {'label': 'unit-a', 'value': 300000},
          {'label': 'unit-b', 'value': 200000},
        ],
      ),
    );

    await tester.pumpWidget(app(ds));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final scalars = log
        .where((r) => r.path == '/api/analytics/query/scalar')
        .toList();
    final series = log
        .where((r) => r.path == '/api/analytics/query/timeseries')
        .toList();
    final grouped = log
        .where((r) => r.path == '/api/analytics/query/grouped')
        .toList();
    expect(scalars, hasLength(11));
    expect(series, hasLength(2));
    expect(grouped, hasLength(1));

    // Business-health KPIs (30-day range) — one scalar per metric.
    const rangeMetrics = [
      'identity_organizations_created_total',
      'loans_created_total',
      'loans_closed_total',
      'loans_defaulted_total',
      'loans_written_off_total',
      'loans_disbursed_amount_total',
      'loans_repaid_amount_total',
    ];
    for (var i = 0; i < rangeMetrics.length; i++) {
      expectBody(scalars[i], {'metric': rangeMetrics[i], 'aggregation': 'sum'});
    }

    // Today's snapshot scalars.
    const todayMetrics = [
      'loans_disbursed_total',
      'loans_disbursed_amount_total',
      'loans_repaid_amount_total',
      'loans_defaulted_total',
    ];
    for (var i = 0; i < todayMetrics.length; i++) {
      expectBody(scalars[7 + i], {
        'metric': todayMetrics[i],
        'aggregation': 'sum',
      });
    }

    // Trend charts: time series with the range's day step.
    expectBody(series[0], {
      'metric': 'identity_organizations_created_total',
      'aggregation': 'sum',
      'step': 'day',
    });
    expectBody(series[1], {
      'metric': 'loans_disbursed_amount_total',
      'aggregation': 'sum',
      'step': 'day',
    });

    // Org unit distribution spans all accessible partitions; the client
    // must never send tenant_id/partition_id filters.
    expectBody(grouped[0], {
      'metric': 'loans_disbursed_amount_total',
      'aggregation': 'sum',
      'group_by': 'partition_id',
      'partition_ids': ['*'],
    });
    for (final req in log) {
      final filters = req.body['filters'] as Map<String, dynamic>?;
      expect(filters?.containsKey('tenant_id') ?? false, isFalse);
      expect(filters?.containsKey('partition_id') ?? false, isFalse);
    }

    // Data rendered: KPI labels and computed values.
    expect(find.text('Total Customers'), findsOneWidget);
    expect(find.text('Active Loans'), findsOneWidget);
    // 100 - 30 - 5 - 2 = 63 active loans.
    expect(find.text('63'), findsOneWidget);
    // Default rate 5/100 = 5.0%.
    expect(find.textContaining('5.0%'), findsOneWidget);
    expect(find.text('unit-a'), findsOneWidget);
  });

  testWidgets('shows loading skeletons while queries are in flight', (
    tester,
  ) async {
    // A transport whose responses never arrive (no pending timers).
    final pending = Completer<http.Response>();
    final ds = SeedAnalyticsDataSource(
      (String path, {Object? body}) => pending.future,
    );

    await tester.pumpWidget(app(ds));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('tenant-scope 403 renders the access message, not a crash', (
    tester,
  ) async {
    final log = <RecordedRequest>[];
    final ds = SeedAnalyticsDataSource(
      mockTransport(
        log,
        statusCode: 403,
        errorMessage: 'analytics queries require tenant scope',
      ),
    );

    await tester.pumpWidget(app(ds));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.textContaining('do not have access to analytics'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('allowlist 400 renders the rejected-query message', (
    tester,
  ) async {
    final log = <RecordedRequest>[];
    final ds = SeedAnalyticsDataSource(
      mockTransport(
        log,
        statusCode: 400,
        errorMessage: 'metric not allowed: "loans_created_total"',
      ),
    );

    await tester.pumpWidget(app(ds));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('rejected this query'), findsOneWidget);
    expect(
      find.textContaining('metric not allowed: "loans_created_total"'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('backend 503 renders the unavailable message', (tester) async {
    final log = <RecordedRequest>[];
    final ds = SeedAnalyticsDataSource(mockTransport(log, statusCode: 503));

    await tester.pumpWidget(app(ds));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('temporarily unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty series and segments render the empty chart state', (
    tester,
  ) async {
    final log = <RecordedRequest>[];
    final ds = SeedAnalyticsDataSource(mockTransport(log));

    await tester.pumpWidget(app(ds));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Both trend charts and the distribution chart fall back to "No data".
    expect(find.text('No data'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  test('queryGroupedAllPartitions strips reserved scope filters', () async {
    final log = <RecordedRequest>[];
    final ds = SeedAnalyticsDataSource(mockTransport(log));

    // The inherited standard queries must sanitize reserved labels too.
    await ds.queryScalar(
      metric: 'loans_created_total',
      filters: {'tenant.id': 'spoof', 'status': 'active'},
    );
    expect(log.single.body['filters'], {'status': 'active'});
  });
}
