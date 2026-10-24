import 'package:antinvestor_api_loans/antinvestor_api_loans.dart';
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({required bool canManage}) {
  return ProviderScope(
    overrides: [
      loanRequestDetailProvider.overrideWith(
        (ref, id) async => LoanRequestObject(
          id: id,
          clientId: 'client-1',
          status: LoanRequestStatus.LOAN_REQUEST_STATUS_SUBMITTED,
          requestedTermDays: 30,
        ),
      ),
    ],
    child: MaterialApp(
      home: LoanRequestDetailScreen(requestId: 'req-1', canManage: canManage),
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
}
