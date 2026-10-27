import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({
  required bool canManage,
  bool canOpenAccount = false,
  LoanRequestStatus status = LoanRequestStatus.LOAN_REQUEST_STATUS_SUBMITTED,
  bool verified = false,
  String? me,
  String submittedBy = '',
}) {
  return ProviderScope(
    overrides: [
      currentProfileIdProvider.overrideWithValue(me),
      loanRequestDetailProvider.overrideWith(
        (ref, id) async => LoanRequestObject(
          id: id,
          clientId: 'client-1',
          status: status,
          requestedTermDays: 30,
          submittedBy: submittedBy,
          properties: Struct(
            fields: {
              'data_verification_confirmed': Value(boolValue: verified),
            }.entries,
          ),
        ),
      ),
    ],
    child: MaterialApp(
      home: LoanRequestDetailScreen(
        requestId: 'req-1',
        canManage: canManage,
        canOpenAccount: canOpenAccount,
      ),
    ),
  );
}

void main() {
  testWidgets('a submitted request shows no decision buttons without '
      'loan_request_manage', (tester) async {
    await tester.pumpWidget(_host(canManage: false));
    await tester.pumpAndSettle();

    expect(find.text('client-1'), findsOneWidget);
    expect(find.text('Approve'), findsNothing);
    expect(find.text('Reject'), findsNothing);
  });

  testWidgets('a submitted request offers approve and reject with '
      'loan_request_manage', (tester) async {
    await tester.pumpWidget(_host(canManage: true));
    await tester.pumpAndSettle();

    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
  });

  // Maker/checker: whoever submitted the request cannot decide it, so they
  // are told so instead of offered buttons the service refuses.
  testWidgets('the submitter is not offered a decision on their request', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(canManage: true, me: 'profile-maker', submittedBy: 'profile-maker'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Submitted by'), findsOneWidget);
    expect(find.text('Approve'), findsNothing);
    expect(
      find.byKey(const Key('loan-request-own-submission')),
      findsOneWidget,
    );

    await tester.pumpWidget(
      _host(
        canManage: true,
        me: 'profile-checker',
        submittedBy: 'profile-maker',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Approve'), findsOneWidget);
  });

  testWidgets('staff confirm the client data on a submitted request', (
    tester,
  ) async {
    await tester.pumpWidget(_host(canManage: true, verified: true));
    await tester.pumpAndSettle();

    final toggle = tester.widget<SwitchListTile>(
      find.byKey(const Key('loan-request-kyc-verified')),
    );
    expect(toggle.value, isTrue);

    await tester.pumpWidget(_host(canManage: false));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('loan-request-kyc-verified')), findsNothing);
  });

  testWidgets('an approved request offers Open loan account only with '
      'loan_manage', (tester) async {
    await tester.pumpWidget(
      _host(
        canManage: true,
        status: LoanRequestStatus.LOAN_REQUEST_STATUS_APPROVED,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('loan-request-open-account')), findsNothing);
    expect(find.text('Approve'), findsNothing);

    await tester.pumpWidget(
      _host(
        canManage: true,
        canOpenAccount: true,
        status: LoanRequestStatus.LOAN_REQUEST_STATUS_APPROVED,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('loan-request-open-account')), findsOneWidget);
  });
}
