// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:antinvestor_api_limits/antinvestor_api_limits.dart';
import 'package:antinvestor_ui_limits/antinvestor_ui_limits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Pumps the policy editor inside a router so `context.pop`/`context.go`
/// resolve, and with the given capabilities.
Future<GoRouter> _pumpEditor(
  WidgetTester tester, {
  LimitsCapabilities capabilities = const LimitsCapabilities.all(),
}) async {
  // The editor is a tall form; give the test surface room so the action row
  // at the bottom is laid out rather than scrolled out of the tree.
  tester.view.physicalSize = const Size(1400, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: '/limits/policies',
    routes: [
      GoRoute(
        path: '/limits/policies',
        builder: (context, state) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => context.push('/limits/policies/new'),
              child: const Text('open editor'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/limits/policies/new',
        builder: (context, state) => const PolicyEditorScreen(),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [limitsCapabilitiesProvider.overrideWithValue(capabilities)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.tap(find.text('open editor'));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('a per-txn-max policy cannot be saved without a cap', (
    tester,
  ) async {
    await _pumpEditor(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pumpAndSettle();

    // A zero cap on a maximum breaches every amount, so the editor must
    // refuse it rather than let the operator block the whole action.
    expect(find.text('Cap must be greater than zero'), findsOneWidget);
  });

  testWidgets('a valid cap clears the cap error', (tester) async {
    await _pumpEditor(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pumpAndSettle();
    expect(find.text('Cap must be greater than zero'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('capAmountField')), '5000');
    await tester.pumpAndSettle();
    expect(find.text('Cap must be greater than zero'), findsNothing);
  });

  testWidgets('a rolling-window policy demands a window', (tester) async {
    await _pumpEditor(tester);

    await tester.tap(find.byType(DropdownButtonFormField<LimitKind>));
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .text(limitKindLabel(LimitKind.LIMIT_KIND_ROLLING_WINDOW_AMOUNT))
          .last,
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('capAmountField')), '5000');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pumpAndSettle();

    expect(
      find.text('Rolling-window policies need a window (e.g. 24h, 7d)'),
      findsOneWidget,
    );
  });

  testWidgets('an approval TTL below the service minimum is refused', (
    tester,
  ) async {
    await _pumpEditor(tester);

    await tester.enterText(find.byKey(const Key('approvalTtlField')), '1m');
    await tester.pumpAndSettle();

    expect(find.text('Approval TTL must be at least 15m'), findsOneWidget);
  });

  testWidgets('switching to enforce mode asks for confirmation before saving', (
    tester,
  ) async {
    await _pumpEditor(tester);

    await tester.enterText(find.byKey(const Key('capAmountField')), '5000');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<PolicyMode>));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(policyModeLabel(PolicyMode.POLICY_MODE_ENFORCE)).last,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pumpAndSettle();

    expect(find.text('Enable enforcement?'), findsOneWidget);

    // Cancelling the confirmation must not save.
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Enable enforcement?'), findsNothing);
  });

  testWidgets('cancel returns to the list', (tester) async {
    final router = await _pumpEditor(tester);
    expect(find.byType(PolicyEditorScreen), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(
      find.byType(PolicyEditorScreen),
      findsNothing,
      reason: 'Cancel must actually leave the editor',
    );
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/limits/policies',
    );
  });

  testWidgets('an operator without policy_manage gets no Save button', (
    tester,
  ) async {
    await _pumpEditor(
      tester,
      capabilities: const LimitsCapabilities(
        policyManage: false,
        approvalAct: false,
      ),
    );

    expect(find.widgetWithText(ElevatedButton, 'Create'), findsNothing);
    expect(find.text('Read-only'), findsOneWidget);
  });
}
