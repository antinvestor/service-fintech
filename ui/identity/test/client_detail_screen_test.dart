import 'package:antinvestor_api_field/antinvestor_api_field.dart';
import 'package:antinvestor_api_identity/antinvestor_api_identity.dart'
    show
        ClientDataEntryObject,
        ClientKYCRequirementStatus,
        ClientKYCRequirementsResponse,
        DataVerificationStatus;
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';
import 'package:connectrpc/connect.dart';
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
  Future<void> startReview(String entryId) async {
    log.add('review:$entryId');
  }

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

/// Answers activation like the identity service: KYC first, then a code,
/// then ACTIVE.
class _ActivatingClientNotifier extends ClientNotifier {
  _ActivatingClientNotifier(this.saved, {this.kycVerified = true});

  final List<ClientObject> saved;
  final bool kycVerified;

  @override
  Future<ClientObject> save(ClientObject client) async {
    saved.add(client);
    if (!kycVerified) {
      throw ConnectException(
        Code.failedPrecondition,
        "the client's KYC must be fully verified before they are activated",
      );
    }
    final code = clientProperty(client, kClientConsentCodeKey);
    if (code.isEmpty) {
      return client.deepCopy()
        ..state = STATE.CREATED
        ..properties = Struct(
          fields: {
            kClientConsentVerificationIdKey: Value(stringValue: 'ch-1'),
            kClientConsentStatusKey: Value(stringValue: 'pending'),
          }.entries,
        );
    }
    if (code != '123456') {
      throw ConnectException(Code.failedPrecondition, 'code is wrong');
    }
    return client.deepCopy()..state = STATE.ACTIVE;
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
  bool canVerifyData = false,
  STATE state = STATE.ACTIVE,
  ClientNotifier Function()? clientNotifier,
  bool kycComplete = true,
}) {
  return ProviderScope(
    overrides: [
      clientKycRequirementsProvider.overrideWith(
        (ref, id) async => ClientKYCRequirementsResponse(
          complete: kycComplete,
          requirements: [
            ClientKYCRequirementStatus(
              fieldKey: 'national_id',
              label: 'National ID',
              status: kycComplete
                  ? DataVerificationStatus.DATA_VERIFICATION_STATUS_VERIFIED
                  : DataVerificationStatus.DATA_VERIFICATION_STATUS_UNSPECIFIED,
            ),
          ],
        ),
      ),
      if (clientNotifier != null)
        clientNotifierProvider.overrideWith(clientNotifier),
      clientDetailProvider.overrideWith(
        (ref, id) async => ClientObject(
          id: id,
          name: 'Amina Wanjiru',
          state: state,
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
        body: ClientDetailScreen(
          clientId: 'client-1',
          canManage: canManage,
          canVerifyData: canVerifyData,
        ),
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
    expect(
      find.text('+254700000001'),
      findsNothing,
      reason: 'a stored phone is never shown; contacts live on the profile',
    );
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
        canVerifyData: true,
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

  testWidgets('a reviewer can take a collected entry, not one under review', (
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
            DataVerificationStatus.DATA_VERIFICATION_STATUS_UNDER_REVIEW,
          ),
        ],
        log: log,
        canVerifyData: true,
      ),
    );
    await tester.pumpAndSettle();
    await _openKyc(tester);

    expect(find.byKey(const Key('kyc-start-review-e1')), findsOneWidget);
    expect(find.byKey(const Key('kyc-start-review-e2')), findsNothing);
    expect(find.byKey(const Key('kyc-verify-e2')), findsOneWidget);

    await tester.tap(find.byKey(const Key('kyc-start-review-e1')));
    await tester.pumpAndSettle();
    expect(log, ['review:e1']);
    expect(find.text('You are reviewing this entry'), findsOneWidget);
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
        canVerifyData: true,
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

  testWidgets('an active client offers no activation', (tester) async {
    _wide(tester);
    await tester.pumpWidget(_host(entries: const [], log: [], canManage: true));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('client-activate')), findsNothing);
    expect(find.byKey(const Key('client-activation-hint')), findsNothing);
  });

  testWidgets('activating asks for the borrower\'s code, then activates', (
    tester,
  ) async {
    _wide(tester);
    final saved = <ClientObject>[];
    await tester.pumpWidget(
      _host(
        entries: const [],
        log: [],
        canManage: true,
        state: STATE.CREATED,
        clientNotifier: () => _ActivatingClientNotifier(saved),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('client-activation-hint')), findsOneWidget);

    await tester.tap(find.byKey(const Key('client-activate')));
    await tester.pumpAndSettle();
    expect(saved.single.state, STATE.ACTIVE, reason: 'asks to become ACTIVE');
    expect(clientProperty(saved.single, kClientConsentCodeKey), isEmpty);

    expect(find.byType(ConsentCodeDialog), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).last, '123456');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(saved, hasLength(2));
    expect(clientProperty(saved.last, kClientConsentVerificationIdKey), 'ch-1');
    expect(clientProperty(saved.last, kClientConsentCodeKey), '123456');
    expect(find.text('Amina Wanjiru is now an active client'), findsOneWidget);
  });

  testWidgets('a wrong code is reported and nothing is activated', (
    tester,
  ) async {
    _wide(tester);
    final saved = <ClientObject>[];
    await tester.pumpWidget(
      _host(
        entries: const [],
        log: [],
        canManage: true,
        state: STATE.CREATED,
        clientNotifier: () => _ActivatingClientNotifier(saved),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('client-activate')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, '000000');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Code not accepted'), findsOneWidget);
    expect(find.text('Amina Wanjiru is now an active client'), findsNothing);
  });

  testWidgets('activation waits until the required KYC is verified', (
    tester,
  ) async {
    _wide(tester);
    final saved = <ClientObject>[];
    await tester.pumpWidget(
      _host(
        entries: const [],
        log: [],
        canManage: true,
        state: STATE.CREATED,
        kycComplete: false,
        clientNotifier: () => _ActivatingClientNotifier(saved),
      ),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<ButtonStyleButton>(
      find.byKey(const Key('client-activate')),
    );
    expect(button.onPressed, isNull, reason: 'nothing to activate yet');

    await _openKyc(tester);
    expect(find.text('Required before activation'), findsOneWidget);
    expect(find.text('National ID: Missing'), findsOneWidget);
    expect(saved, isEmpty);
  });

  testWidgets('a refused activation is reported', (tester) async {
    _wide(tester);
    final saved = <ClientObject>[];
    await tester.pumpWidget(
      _host(
        entries: const [],
        log: [],
        canManage: true,
        state: STATE.CREATED,
        clientNotifier: () =>
            _ActivatingClientNotifier(saved, kycVerified: false),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('client-activate')));
    await tester.pumpAndSettle();

    expect(find.byType(ConsentCodeDialog), findsNothing);
    expect(find.textContaining('Could not activate'), findsOneWidget);
  });

  testWidgets('client_manage alone cannot decide on KYC entries', (
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
        log: <String>[],
        canManage: true,
      ),
    );
    await tester.pumpAndSettle();
    await _openKyc(tester);

    expect(find.byKey(const Key('kyc-verify-e1')), findsNothing);
    expect(find.byKey(const Key('kyc-start-review-e1')), findsNothing);
  });
}
