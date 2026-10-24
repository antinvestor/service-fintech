import 'package:antinvestor_api_field/antinvestor_api_field.dart';
import 'package:antinvestor_api_identity/antinvestor_api_identity.dart'
    show ClientDataEntryObject, DataVerificationStatus;
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeKycList extends ClientDataPagedList {
  _FakeKycList(super.clientId, this.entries);

  final List<ClientDataEntryObject> entries;

  @override
  Future<List<ClientDataEntryObject>> fetchPage(int offset, int limit) async =>
      offset == 0 ? entries : const [];
}

class _RecordingClientDataNotifier extends ClientDataNotifier {
  _RecordingClientDataNotifier(this.log);

  final List<String> log;

  @override
  Future<void> verify(String entryId, {String comment = ''}) async {
    log.add('verify:$entryId');
  }

  @override
  Future<void> reject(String entryId, String reason) async {
    log.add('reject:$entryId:$reason');
  }

  @override
  Future<void> requestInfo(String entryId, String comment) async {
    log.add('info:$entryId:$comment');
  }

  @override
  Future<ClientDataEntryObject> save(ClientDataEntryObject entry) async {
    log.add('save:${entry.fieldKey}=${entry.value}');
    return entry;
  }
}

ClientDataEntryObject _entry(String id, DataVerificationStatus status) =>
    ClientDataEntryObject(
      id: id,
      clientId: 'client-1',
      fieldKey: 'national_id',
      value: '12345678',
      verificationStatus: status,
    );

Widget _host({
  required List<ClientDataEntryObject> entries,
  required List<String> log,
  bool canManage = false,
}) {
  return ProviderScope(
    overrides: [
      clientDetailProvider.overrideWith(
        (ref, id) async => ClientObject(
          id: id,
          name: 'Amina Wanjiru',
          state: STATE.ACTIVE,
          owningTeamId: 'team-1',
          properties: Struct(
            fields: {
              kClientPhoneNumberKey: Value(stringValue: '+254700000001'),
            }.entries,
          ),
        ),
      ),
      clientDataPagedListProvider.overrideWith2(
        (clientId) => _FakeKycList(clientId, entries),
      ),
      clientDataNotifierProvider.overrideWith(
        () => _RecordingClientDataNotifier(log),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: ClientDetailScreen(clientId: 'client-1', canManage: canManage),
      ),
    ),
  );
}

void _wide(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _openKyc(WidgetTester tester) async {
  await tester.tap(find.text('KYC'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the client header and profile', (tester) async {
    _wide(tester);
    await tester.pumpWidget(_host(entries: const [], log: []));
    await tester.pumpAndSettle();

    expect(find.text('Amina Wanjiru'), findsOneWidget);
    expect(find.text('+254700000001'), findsWidgets);
    expect(find.text('team-1'), findsOneWidget);
    expect(find.byKey(const Key('client-edit')), findsNothing);
  });

  testWidgets('KYC tab lists entries without actions for a viewer', (
    tester,
  ) async {
    _wide(tester);
    await tester.pumpWidget(
      _host(
        entries: [
          _entry(
            'e1',
            DataVerificationStatus.DATA_VERIFICATION_STATUS_COLLECTED,
          ),
        ],
        log: [],
      ),
    );
    await tester.pumpAndSettle();
    await _openKyc(tester);

    expect(find.text('national_id'), findsOneWidget);
    expect(find.text('Collected'), findsOneWidget);
    expect(find.byKey(const Key('kyc-verify-e1')), findsNothing);
    expect(find.byKey(const Key('kyc-add')), findsNothing);
  });

  testWidgets('a manager can verify a collected entry but not a verified one', (
    tester,
  ) async {
    _wide(tester);
    final log = <String>[];
    await tester.pumpWidget(
      _host(
        entries: [
          _entry(
            'e1',
            DataVerificationStatus.DATA_VERIFICATION_STATUS_COLLECTED,
          ),
          _entry(
            'e2',
            DataVerificationStatus.DATA_VERIFICATION_STATUS_VERIFIED,
          ),
        ],
        log: log,
        canManage: true,
      ),
    );
    await tester.pumpAndSettle();
    await _openKyc(tester);

    expect(find.byKey(const Key('kyc-verify-e1')), findsOneWidget);
    expect(find.byKey(const Key('kyc-verify-e2')), findsNothing);

    await tester.tap(find.byKey(const Key('kyc-verify-e1')));
    await tester.pumpAndSettle();
    expect(log, ['verify:e1']);
    expect(find.text('Entry verified'), findsOneWidget);
  });

  testWidgets('rejecting asks for a reason and sends it', (tester) async {
    _wide(tester);
    final log = <String>[];
    await tester.pumpWidget(
      _host(
        entries: [
          _entry(
            'e1',
            DataVerificationStatus.DATA_VERIFICATION_STATUS_UNDER_REVIEW,
          ),
        ],
        log: log,
        canManage: true,
      ),
    );
    await tester.pumpAndSettle();
    await _openKyc(tester);

    await tester.tap(find.byKey(const Key('kyc-reject-e1')));
    await tester.pumpAndSettle();
    // An empty reason is not a rejection.
    await tester.tap(find.byKey(const Key('kyc-reason-confirm')));
    await tester.pumpAndSettle();
    expect(log, isEmpty);

    await tester.tap(find.byKey(const Key('kyc-reject-e1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('kyc-reason')), 'Blurry scan');
    await tester.tap(find.byKey(const Key('kyc-reason-confirm')));
    await tester.pumpAndSettle();

    expect(log, ['reject:e1:Blurry scan']);
  });

  testWidgets('adding data saves a COLLECTED entry for the client', (
    tester,
  ) async {
    _wide(tester);
    final log = <String>[];
    await tester.pumpWidget(
      _host(entries: const [], log: log, canManage: true),
    );
    await tester.pumpAndSettle();
    await _openKyc(tester);
    expect(find.byKey(const Key('kyc-empty')), findsOneWidget);

    await tester.tap(find.byKey(const Key('kyc-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('kyc-form-key')),
      'date_of_birth',
    );
    await tester.enterText(
      find.byKey(const Key('kyc-form-value')),
      '1990-01-01',
    );
    await tester.tap(find.byKey(const Key('kyc-form-submit')));
    await tester.pumpAndSettle();

    expect(log, ['save:date_of_birth=1990-01-01']);
  });
}
