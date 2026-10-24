import 'package:antinvestor_ui_funding/antinvestor_ui_funding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpList(
  WidgetTester tester,
  AsyncValue<List<String>> value, {
  VoidCallback? onRetry,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AsyncListView<String>(
          value: value,
          onRetry: onRetry ?? () {},
          builder: (items) => Column(children: items.map(Text.new).toList()),
        ),
      ),
    ),
  );
}

void main() {
  group('AsyncListView', () {
    testWidgets('shows a spinner while loading', (tester) async {
      await pumpList(tester, const AsyncValue.loading());
      expect(find.byKey(const Key('async-list-loading')), findsOneWidget);
      expect(find.byKey(const Key('async-list-empty')), findsNothing);
    });

    testWidgets('shows the error with a working retry', (tester) async {
      var retries = 0;
      await pumpList(
        tester,
        AsyncValue.error(Exception('server said no'), StackTrace.empty),
        onRetry: () => retries++,
      );

      expect(find.byKey(const Key('async-list-error')), findsOneWidget);
      expect(find.textContaining('server said no'), findsOneWidget);

      await tester.tap(find.byKey(const Key('async-list-retry')));
      await tester.pump();
      expect(retries, 1);
    });

    testWidgets('distinguishes empty from failed', (tester) async {
      await pumpList(tester, const AsyncValue.data(<String>[]));
      expect(find.byKey(const Key('async-list-empty')), findsOneWidget);
      expect(find.byKey(const Key('async-list-error')), findsNothing);
    });

    testWidgets('renders the items when there are some', (tester) async {
      await pumpList(tester, const AsyncValue.data(['alpha', 'beta']));
      expect(find.text('alpha'), findsOneWidget);
      expect(find.text('beta'), findsOneWidget);
      expect(find.byKey(const Key('async-list-empty')), findsNothing);
    });
  });
}
