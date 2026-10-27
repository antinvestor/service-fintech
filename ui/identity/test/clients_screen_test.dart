import 'package:antinvestor_api_field/antinvestor_api_field.dart';
import 'package:antinvestor_api_identity/antinvestor_api_identity.dart'
    show
        ClientDataEntryObject,
        FormFieldDefinition,
        FormFieldType,
        FormTemplateObject;
import 'package:connectrpc/connect.dart';
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

/// Whether the fake service can be reached.
class _Network {
  bool online = true;
}

class _FailingClientPagedList extends ClientPagedList {
  _FailingClientPagedList(super.params);

  @override
  Future<List<ClientObject>> fetchPage(int offset, int limit) async =>
      throw ConnectException(Code.unavailable, 'offline');
}

class _RecordingClientNotifier extends ClientNotifier {
  _RecordingClientNotifier(this.saved, this.network);

  final List<ClientObject> saved;
  final _Network network;

  @override
  Future<ClientObject> save(ClientObject client) async {
    if (!network.online) {
      throw ConnectException(Code.unavailable, 'offline');
    }
    saved.add(client);
    return client.deepCopy()..id = 'client-new';
  }
}

class _RecordingClientDataNotifier extends ClientDataNotifier {
  _RecordingClientDataNotifier(this.saved);

  final List<ClientDataEntryObject> saved;

  @override
  Future<ClientDataEntryObject> save(ClientDataEntryObject entry) async {
    saved.add(entry);
    return entry;
  }
}

Widget _host({
  required List<int> calls,
  required List<ClientObject> saved,
  bool canManage = false,
  List<ClientDataEntryObject>? details,
  _Network? network,
  bool listFails = false,
  FormTemplateObject? template,
}) {
  final net = network ?? _Network();
  return ProviderScope(
    overrides: [
      onboardingTemplateProvider.overrideWith((ref) async => template),
      clientPagedListProvider.overrideWith2(
        (params) => listFails
            ? _FailingClientPagedList(params)
            : _FakeClientPagedList(params, calls),
      ),
      clientNotifierProvider.overrideWith(
        () => _RecordingClientNotifier(saved, net),
      ),
      clientDataNotifierProvider.overrideWith(
        () => _RecordingClientDataNotifier(details ?? []),
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
    expect(
      find.text('+25470000'),
      findsNothing,
      reason: 'contacts live on the profile',
    );
    expect(find.byKey(const Key('load-more-action')), findsOneWidget);

    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();

    expect(calls, [0, kIdentityListPageSize]);
    expect(find.byKey(const Key('load-more-action')), findsNothing);
    expect(find.byKey(const Key('list-error-view')), findsNothing);
  });

  // On a phone the table's columns do not fit: clients are tappable tiles,
  // and onboarding stays one tap away.
  testWidgets('a phone lists clients as tiles and keeps onboarding', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host(calls: [], saved: [], canManage: true));
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsNothing);
    expect(find.text('Client 0'), findsOneWidget);
    expect(find.byKey(const Key('compact-list-add')), findsOneWidget);
    expect(find.byKey(const Key('load-more-action')), findsOneWidget);
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
    final details = <ClientDataEntryObject>[];
    await tester.pumpWidget(
      _host(calls: [], saved: saved, canManage: true, details: details),
    );
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
    await tester.enterText(
      find.byKey(const Key('client-form-occupation')),
      'Market trader',
    );
    await tester.ensureVisible(find.byKey(const Key('client-form-add-detail')));
    await tester.tap(find.byKey(const Key('client-form-add-detail')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('client-form-extra-key-0')),
      'next_of_kin',
    );
    await tester.enterText(
      find.byKey(const Key('client-form-extra-value-0')),
      'Juma Wanjiru',
    );
    await tester.tap(find.byKey(const Key('client-form-submit')));
    await tester.pumpAndSettle();

    expect(saved, hasLength(1));
    final client = saved.single;
    expect(client.id, isEmpty);
    expect(client.owningTeamId, isEmpty, reason: 'server assigns the team');
    expect(client.name, 'Amina Wanjiru');
    expect(
      clientProperty(client, kClientPhoneNumberKey),
      '+254 700 000 001',
      reason: 'passed to the profile service as typed',
    );
    expect(clientNationalId(client), '12345678');
    expect(
      {for (final d in details) d.fieldKey: d.value},
      {
        'national_id': '12345678',
        'occupation': 'Market trader',
        'next_of_kin': 'Juma Wanjiru',
      },
    );
    expect(details.map((d) => d.clientId).toSet(), {'client-new'});
    expect(
      find.text(
        'Amina Wanjiru registered. Activate them once their KYC is verified.',
      ),
      findsOneWidget,
    );
    expect(
      client.state,
      isNot(STATE.ACTIVE),
      reason: 'a client is activated later, not at registration',
    );
    expect(find.byKey(const Key('registration-outbox')), findsNothing);
  });

  testWidgets('a registration captured offline is sent on the next sync', (
    tester,
  ) async {
    _wide(tester);
    final saved = <ClientObject>[];
    final network = _Network()..online = false;
    await tester.pumpWidget(
      _host(calls: [], saved: saved, canManage: true, network: network),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Onboard client'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('client-form-name')),
      'Amina Wanjiru',
    );
    await tester.enterText(
      find.byKey(const Key('client-form-phone')),
      '+254700000001',
    );
    await tester.tap(find.byKey(const Key('client-form-submit')));
    await tester.pumpAndSettle();

    expect(saved, isEmpty);
    expect(
      find.text(
        'Saved on this device. Amina Wanjiru is registered when you are '
        'online.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('registration-outbox')), findsOneWidget);
    expect(find.text('Waiting for a connection'), findsOneWidget);

    network.online = true;
    await tester.tap(find.byKey(const Key('registration-outbox-sync')));
    await tester.pumpAndSettle();

    expect(saved.single.name, 'Amina Wanjiru');
    expect(find.byKey(const Key('registration-outbox')), findsNothing);
  });

  testWidgets('an agent can still onboard when the list cannot load', (
    tester,
  ) async {
    _wide(tester);
    await tester.pumpWidget(
      _host(calls: [], saved: [], canManage: true, listFails: true),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('clients-offline')), findsOneWidget);
    expect(find.text('Onboard client'), findsOneWidget);
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

  testWidgets('onboarding asks for the organization\'s own client form', (
    tester,
  ) async {
    _wide(tester);
    final saved = <ClientObject>[];
    final details = <ClientDataEntryObject>[];
    await tester.pumpWidget(
      _host(
        calls: [],
        saved: saved,
        canManage: true,
        details: details,
        template: FormTemplateObject(
          organizationId: 'org-1',
          entityType: 'client',
          fields: [
            FormFieldDefinition(
              key: 'national_id',
              label: 'National ID',
              required: true,
              order: 1,
            ),
            FormFieldDefinition(
              key: 'county',
              label: 'County',
              fieldType: FormFieldType.FORM_FIELD_TYPE_SELECT,
              options: ['Nairobi', 'Kiambu'],
              order: 2,
            ),
            FormFieldDefinition(
              key: 'id_photo',
              label: 'ID photo',
              fieldType: FormFieldType.FORM_FIELD_TYPE_PHOTO,
              required: true,
              order: 3,
            ),
            FormFieldDefinition(key: 'phone_number', label: 'Phone'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Onboard client'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('client-form-no-template')), findsNothing);
    expect(find.byKey(const Key('client-form-occupation')), findsNothing);
    expect(find.byKey(const Key('template-field-phone_number')), findsNothing);
    expect(find.byKey(const Key('template-field-id_photo')), findsNothing);
    expect(find.byKey(const Key('client-form-uploads-later')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('client-form-name')), 'Amina');
    await tester.enterText(
      find.byKey(const Key('client-form-phone')),
      '+254700000001',
    );
    await tester.enterText(
      find.byKey(const Key('template-field-national_id')),
      '998877',
    );
    await tester.tap(find.byKey(const Key('template-field-county')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kiambu').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('client-form-submit')));
    await tester.pumpAndSettle();

    expect(clientNationalId(saved.single), '998877');
    expect(
      {for (final d in details) d.fieldKey: d.value},
      {'national_id': '998877', 'county': 'Kiambu'},
    );
  });
}
