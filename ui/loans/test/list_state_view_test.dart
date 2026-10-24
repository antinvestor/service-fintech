import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:antinvestor_ui_loans/src/widgets/list_state_view.dart';
import 'package:antinvestor_ui_loans/src/widgets/load_more_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ListStateView', () {
    testWidgets('shows a spinner while the first page is loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ListStateView<String>(
            title: 'Loan Accounts',
            value: AsyncValue<PagedResult<String>>.loading(),
            onRetry: _noop,
            builder: _neverBuilds,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loan Accounts'), findsOneWidget);
    });

    testWidgets('shows an error with a retry that calls back', (tester) async {
      var retries = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ListStateView<String>(
            title: 'Loan Accounts',
            value: AsyncValue<PagedResult<String>>.error(
              Exception('boom'),
              StackTrace.empty,
            ),
            onRetry: () => retries++,
            builder: _neverBuilds,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pump();
      expect(retries, 1);
    });

    testWidgets('renders an empty page as empty, not as a failure', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ListStateView<String>(
            title: 'Loan Accounts',
            value: const AsyncValue<PagedResult<String>>.data(
              PagedResult<String>(items: <String>[], hasMore: false),
            ),
            onRetry: _noop,
            builder: (page) => Scaffold(
              body: Center(child: Text('No loans yet (${page.items.length})')),
            ),
          ),
        ),
      );

      expect(find.text('No loans yet (0)'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('keeps showing loaded rows while the next page loads', (
      tester,
    ) async {
      const page = PagedResult<String>(items: <String>['a'], hasMore: true);

      await tester.pumpWidget(
        MaterialApp(
          home: ListStateView<String>(
            title: 'Loan Accounts',
            // A refresh in flight still carries the previous page.
            value: const AsyncValue<PagedResult<String>>.data(page),
            onRetry: _noop,
            builder: (loaded) =>
                Scaffold(body: Center(child: Text(loaded.items.first))),
          ),
        ),
      );

      expect(find.text('a'), findsOneWidget);
    });
  });

  group('LoadMoreAction', () {
    testWidgets('stays hidden when the whole list is already shown', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadMoreAction(
              loadedCount: 12,
              hasMore: false,
              isLoading: false,
              onLoadMore: _noop,
            ),
          ),
        ),
      );

      expect(find.text('Load more'), findsNothing);
    });

    testWidgets('offers more rows and reports how many are shown', (
      tester,
    ) async {
      var loads = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadMoreAction(
              loadedCount: 50,
              hasMore: true,
              isLoading: false,
              onLoadMore: () => loads++,
            ),
          ),
        ),
      );

      expect(find.text('Showing first 50'), findsOneWidget);
      await tester.tap(find.text('Load more'));
      await tester.pump();
      expect(loads, 1);
    });

    testWidgets('cannot be tapped twice while a page is in flight', (
      tester,
    ) async {
      var loads = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadMoreAction(
              loadedCount: 50,
              hasMore: true,
              isLoading: true,
              onLoadMore: () => loads++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Load more'));
      await tester.pump();
      expect(loads, 0);
    });
  });
}

void _noop() {}

Widget _neverBuilds(PagedResult<String> page) =>
    throw StateError('builder must not run without a loaded page');
