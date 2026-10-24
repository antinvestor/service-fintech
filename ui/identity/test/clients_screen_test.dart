import 'package:antinvestor_api_field/antinvestor_api_field.dart';
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeClientPagedList extends ClientPagedList {
  _FakeClientPagedList(super.params, this.calls);

  final List<int> calls;

  @override
  Future<List<ClientObject>> fetchPage(int offset, int limit) async {
    calls.add(offset);
    final count = offset == 0 ? limit : 3;
    return [
      for (var i = offset; i < offset + count; i++)
        ClientObject(
          id: 'client-$i',
          name: 'Client $i',
          state: STATE.ACTIVE,
          properties: Struct(
            fields: {
              kClientPhoneNumberKey: Value(stringValue: '+2547000$i'),
            }.entries,
          ),
        ),
    ];
  }
}

class _RecordingClientNotifier extends ClientNotifier {
  _RecordingClientNotifier(this.saved);

  final List<ClientObject> saved;

  @override
  Future<ClientObject> save(ClientObject client) async {
    saved.add(client);
    return client.deepCopy()..id = 'client-new';
  }
}

Widget _host({
  required List<int> calls,
  required List<ClientObject> saved,
  bool canManage = false,
}) {
  return ProviderScope(
    overrides: [
      clientPagedListProvider.overrideWith2(
        (params) => _FakeClientPagedList(params, calls),
      ),
      clientNotifierProvider.overrideWith(
        () => _RecordingClientNotifier(saved),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(body: ClientsScreen(canManage: canManage)),
    ),
  );
}

void _wide(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('clients append the next page through the cursor', (
    tester,
  ) async {
    _wide(tester);
    final calls = <int>[];
    await tester.pumpWidget(_host(calls: calls, saved: []));
    await tester.pumpAndSettle();

    expect(find.text('Client 0'), findsOneWidget);
    expect(find.text('+25470000'), findsOneWidget);
    expect(find.byKey(const Key('load-more-action')), findsOneWidget);

    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();

    expect(calls, [0, kIdentityListPageSize]);
    expect(find.byKey(const Key('load-more-action')), findsNothing);
    expect(find.byKey(const Key('list-error-view')), findsNothing);
  });

  testWidgets('onboarding is hidden without client_manage', (tester) async {
    _wide(tester);
    await tester.pumpWidget(_host(calls: [], saved: []));
    await tester.pumpAndSettle();

    expect(find.text('Onboard client'), findsNothing);
  });

  testWidgets('onboarding saves name, phone and national id as properties', (
    tester,
  ) async {
    _wide(tester);
    final saved = <ClientObject>[];
    await tester.pumpWidget(_host(calls: [], saved: saved, canManage: true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Onboard client'));
    await tester.pumpAndSettle();
    expect(find.byType(ClientFormDialog), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('client-form-name')),
      'Amina Wanjiru',
    );
    await tester.enterText(
      find.byKey(const Key('client-form-phone')),
      '+254 700 000 001',
    );
    await tester.enterText(
      find.byKey(const Key('client-form-national-id')),
      '12345678',
    );
    await tester.tap(find.byKey(const Key('client-form-submit')));
    await tester.pumpAndSettle();

    expect(saved, hasLength(1));
    final client = saved.single;
    expect(client.id, isEmpty);
    expect(client.owningTeamId, isEmpty, reason: 'server assigns the team');
    expect(client.name, 'Amina Wanjiru');
    expect(client.state, STATE.ACTIVE);
    expect(clientPhoneNumber(client), '+254700000001');
    expect(clientNationalId(client), '12345678');
    expect(find.text('Amina Wanjiru onboarded'), findsOneWidget);
  });

  testWidgets('onboarding refuses a missing phone number', (tester) async {
    _wide(tester);
    final saved = <ClientObject>[];
    await tester.pumpWidget(_host(calls: [], saved: saved, canManage: true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Onboard client'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('client-form-name')), 'A');
    await tester.tap(find.byKey(const Key('client-form-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Phone number is required'), findsOneWidget);
    expect(saved, isEmpty);
    expect(find.byType(ClientFormDialog), findsOneWidget);
  });
}
