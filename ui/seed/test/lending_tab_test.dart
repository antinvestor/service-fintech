import 'package:antinvestor_api_loans/antinvestor_api_loans.dart'
    show LoanAccountObject;
import 'package:antinvestor_ui_core/api/stream_helpers.dart' show PagedResult;
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart'
    show loanAccountListProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_ui/features/lending/lending_tab.dart';
import 'package:seed_ui/features/lending/seed_api.dart';

Widget _host({required CreditProfile? profile, required bool canAdmin}) {
  return ProviderScope(
    overrides: [
      creditProfileProvider('client-1').overrideWith((ref) async => profile),
      loanAccountListProvider((
        query: '',
        status: null,
        agentId: '',
        clientId: 'client-1',
        limit: 20,
      )).overrideWith(
        (ref) async =>
            const PagedResult<LoanAccountObject>(items: [], hasMore: false),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: LendingTab(clientId: 'client-1', canAdmin: canAdmin),
      ),
    ),
  );
}

CreditProfile _profile(CreditProfileStatus status) => CreditProfile(
  tier: 2,
  maxLoanAmountMinor: 1250000,
  status: status,
  successfulRepayments: 3,
  outstandingLoanCount: 0,
);

void main() {
  test('minor units read as whole currency', () {
    expect(formatMinor(1250000, 'KES'), 'KES 12,500.00');
    expect(formatMinor(5, 'KES'), 'KES 0.05');
  });

  testWidgets('shows the profile; admin actions only with the permit', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(profile: _profile(CreditProfileStatus.active), canAdmin: false),
    );
    await tester.pumpAndSettle();
    expect(find.text('KES 12,500.00'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.byKey(const Key('lending-suspend')), findsNothing);

    await tester.pumpWidget(
      _host(profile: _profile(CreditProfileStatus.active), canAdmin: true),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lending-suspend')), findsOneWidget);
    expect(find.byKey(const Key('lending-block')), findsOneWidget);
    expect(find.byKey(const Key('lending-reinstate')), findsNothing);
  });

  testWidgets('a suspended profile offers reinstatement, with a reason', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(profile: _profile(CreditProfileStatus.suspended), canAdmin: true),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lending-reinstate')));
    await tester.pumpAndSettle();
    final submit = tester.widget<FilledButton>(
      find.byKey(const Key('lending-reason-submit')),
    );
    expect(submit.onPressed, isNull, reason: 'a reason is required');
  });

  testWidgets('a client without a profile is told when one opens', (
    tester,
  ) async {
    await tester.pumpWidget(_host(profile: null, canAdmin: true));
    await tester.pumpAndSettle();
    expect(find.textContaining('first loan request'), findsOneWidget);
  });
}
