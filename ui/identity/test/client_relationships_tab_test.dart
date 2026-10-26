import 'package:antinvestor_api_field/antinvestor_api_field.dart';
import 'package:antinvestor_api_identity/antinvestor_api_identity.dart'
    show InternalTeamObject;
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({required bool canTransfer, required bool canAssign}) {
  return ProviderScope(
    overrides: [
      clientRelationshipsProvider('client-1').overrideWith(
        (ref) async => [
          ClientRelationshipObject(
            id: 'rel-1',
            clientId: 'client-1',
            memberId: 'member-7',
            name: 'Loan officer',
            isPrimary: true,
          ),
        ],
      ),
      internalTeamByIdProvider('team-a').overrideWith(
        (ref) async => InternalTeamObject(id: 'team-a', name: 'Kibera team'),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: ClientRelationshipsTab(
          client: ClientObject(id: 'client-1', owningTeamId: 'team-a'),
          canTransfer: canTransfer,
          canAssign: canAssign,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the owning team and assigned staff', (tester) async {
    await tester.pumpWidget(_host(canTransfer: false, canAssign: false));
    await tester.pumpAndSettle();
    expect(find.text('Kibera team'), findsOneWidget);
    expect(find.text('Loan officer'), findsOneWidget);
    expect(find.textContaining('Primary'), findsOneWidget);
    expect(find.byKey(const Key('client-transfer')), findsNothing);
    expect(find.byKey(const Key('client-assign-member')), findsNothing);
  });

  testWidgets('offers transfer and assign only with the permits', (
    tester,
  ) async {
    await tester.pumpWidget(_host(canTransfer: true, canAssign: false));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('client-transfer')), findsOneWidget);
    expect(find.byKey(const Key('client-assign-member')), findsNothing);

    await tester.pumpWidget(_host(canTransfer: false, canAssign: true));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('client-transfer')), findsNothing);
    expect(find.byKey(const Key('client-assign-member')), findsOneWidget);
  });
}
