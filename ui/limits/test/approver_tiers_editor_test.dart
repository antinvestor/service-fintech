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
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ApproverTier _tier({int upTo = 0, String role = 'cfo', int approvers = 2}) =>
    ApproverTier()
      ..upTo = Int64(upTo)
      ..role = role
      ..approvers = approvers;

Future<List<ApproverTier>> _pumpEditor(
  WidgetTester tester,
  List<ApproverTier> initial,
) async {
  var latest = initial;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ApproverTiersEditor(
          initial: initial,
          onChanged: (tiers) => latest = tiers,
        ),
      ),
    ),
  );
  return latest;
}

void main() {
  group('validateApproverTiers', () {
    test('accepts an empty ladder', () {
      expect(validateApproverTiers([]), isNull);
    });

    test('rejects a tier without a role', () {
      expect(
        validateApproverTiers([_tier(upTo: 100, role: '')]),
        'Every tier needs a role',
      );
    });

    test('rejects an approver count outside the service bound', () {
      expect(
        validateApproverTiers([_tier(approvers: 0)]),
        'Approver count must be between 1 and $maxApproverCount',
      );
      expect(
        validateApproverTiers([_tier(approvers: maxApproverCount + 1)]),
        'Approver count must be between 1 and $maxApproverCount',
      );
    });

    test('rejects duplicate up-to bounds', () {
      expect(
        validateApproverTiers([
          _tier(upTo: 100, role: 'branch_manager', approvers: 1),
          _tier(upTo: 100, role: 'cfo'),
        ]),
        'Two tiers share the same up-to bound',
      );
    });

    test('rejects more than one catch-all tier', () {
      expect(
        validateApproverTiers([
          _tier(role: 'branch_manager', approvers: 1),
          _tier(role: 'cfo'),
        ]),
        'Only one catch-all tier is allowed',
      );
    });

    test('accepts a well-formed ladder', () {
      expect(
        validateApproverTiers([
          _tier(upTo: 100000, role: 'branch_manager', approvers: 1),
          _tier(role: 'cfo'),
        ]),
        isNull,
      );
    });
  });

  testWidgets('a partial minus sign does not throw out of the up-to field', (
    tester,
  ) async {
    await _pumpEditor(tester, [_tier(upTo: 100)]);

    // Int64.parseInt throws on "-"; the field must tolerate an operator
    // part-way through typing a value rather than red-screening the app.
    await tester.enterText(find.byKey(const Key('tierUpTo0')), '-');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('a pasted grouped number does not throw', (tester) async {
    await _pumpEditor(tester, [_tier(upTo: 100)]);

    await tester.enterText(find.byKey(const Key('tierUpTo0')), '1,000');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty role is reported on the field', (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: ApproverTiersEditor(
              initial: [_tier(upTo: 100, role: '')],
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    formKey.currentState!.validate();
    await tester.pumpAndSettle();

    expect(find.text('Role is required'), findsOneWidget);
  });

  testWidgets('an out-of-range approver count is reported on the field', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: ApproverTiersEditor(
              initial: [_tier(upTo: 100, role: 'cfo', approvers: 1)],
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('tierCount0')), '99');
    formKey.currentState!.validate();
    await tester.pumpAndSettle();

    expect(find.text('1–$maxApproverCount'), findsOneWidget);
  });

  testWidgets('editing a tier never mutates the caller\'s list', (
    tester,
  ) async {
    final original = [_tier(upTo: 100, role: 'branch_manager', approvers: 1)];
    await _pumpEditor(tester, original);

    await tester.enterText(find.byKey(const Key('tierRole0')), 'cfo');
    await tester.pumpAndSettle();

    expect(
      original.single.role,
      'branch_manager',
      reason: 'the editor works on its own copy',
    );
  });
}
