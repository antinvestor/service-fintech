import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers FormTemplateSave by echoing the template with an id, and records
/// what was sent.
class _TemplateTransport implements Transport {
  final saved = <FormTemplateObject>[];

  @override
  Future<UnaryResponse<I, O>> unary<I extends Object, O extends Object>(
    Spec<I, O> spec,
    I input, [
    CallOptions? options,
  ]) async {
    if (input is FormTemplateSaveRequest) {
      saved.add(input.data);
      final out = input.data.deepCopy()
        ..id = 'tmpl-1'
        ..status = FormTemplateStatus.FORM_TEMPLATE_STATUS_DRAFT;
      return UnaryResponse(
        spec,
        Headers(),
        FormTemplateSaveResponse(data: out) as O,
        Headers(),
      );
    }
    throw ConnectException(Code.unimplemented, 'not in this test');
  }

  @override
  Future<StreamResponse<I, O>> stream<I extends Object, O extends Object>(
    Spec<I, O> spec,
    Stream<I> input, [
    CallOptions? options,
  ]) async {
    throw ConnectException(Code.unimplemented, 'not in this test');
  }
}

Widget _host({
  required Transport transport,
  String? templateId,
  FormTemplateObject? stored,
}) {
  return ProviderScope(
    overrides: [
      identityServiceClientProvider.overrideWithValue(
        IdentityServiceClient(transport),
      ),
      organizationListProvider('').overrideWith(
        (ref) async => [OrganizationObject(id: 'org-1', name: 'Acme')],
      ),
      if (stored != null)
        formTemplateDetailProvider(
          stored.id,
        ).overrideWith((ref) async => stored),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: FormTemplateDesignerScreen(
          templateId: templateId,
          canManage: true,
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(1400, 2400);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  test('keys are derived from labels', () {
    expect(fieldKeyFromLabel('National ID number'), 'national_id_number');
    expect(fieldKeyFromLabel('  Next of kin (name) '), 'next_of_kin_name');
  });

  test('phone and email are never offered as field types', () {
    expect(
      designerFieldTypes.keys,
      isNot(contains(FormFieldType.FORM_FIELD_TYPE_PHONE)),
    );
    expect(
      designerFieldTypes.keys,
      isNot(contains(FormFieldType.FORM_FIELD_TYPE_EMAIL)),
    );
  });

  testWidgets('builds a draft and saves it', (tester) async {
    final transport = _TemplateTransport();
    await tester.pumpWidget(_host(transport: transport));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('form-designer-name')),
      'Borrower KYC',
    );
    await tester.tap(find.byKey(const Key('form-designer-organization')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Acme').last);
    await tester.pumpAndSettle();

    // A template with no fields is not saved.
    await tester.tap(find.byKey(const Key('form-designer-save')));
    await tester.pumpAndSettle();
    expect(find.text('Add at least one field'), findsOneWidget);
    expect(transport.saved, isEmpty);

    await tester.tap(find.byKey(const Key('form-designer-add-field')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('field-dialog-label')),
      'National ID number',
    );
    await tester.tap(find.byKey(const Key('field-dialog-submit')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('form-designer-field-national_id_number')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('form-designer-save')));
    await tester.pumpAndSettle();
    expect(transport.saved, hasLength(1));
    final sent = transport.saved.single;
    expect(sent.name, 'Borrower KYC');
    expect(sent.organizationId, 'org-1');
    expect(sent.entityType, 'client');
    expect(sent.fields.single.key, 'national_id_number');
    expect(sent.fields.single.required, isTrue);
    expect(sent.fields.single.order, 1);
  });

  testWidgets('a published template is read-only and offers a new version', (
    tester,
  ) async {
    final transport = _TemplateTransport();
    final published = FormTemplateObject(
      id: 'tmpl-pub',
      name: 'Borrower KYC',
      organizationId: 'org-1',
      entityType: 'client',
      version: 2,
      status: FormTemplateStatus.FORM_TEMPLATE_STATUS_PUBLISHED,
      fields: [
        FormFieldDefinition(
          key: 'national_id',
          label: 'National ID',
          fieldType: FormFieldType.FORM_FIELD_TYPE_TEXT,
        ),
      ],
    );
    await tester.pumpWidget(
      _host(transport: transport, templateId: 'tmpl-pub', stored: published),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('form-designer-save')), findsNothing);
    expect(find.byKey(const Key('form-designer-add-field')), findsNothing);

    await tester.tap(find.byKey(const Key('form-designer-new-version')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('form-designer-save')), findsOneWidget);

    await tester.tap(find.byKey(const Key('form-designer-save')));
    await tester.pumpAndSettle();
    final sent = transport.saved.single;
    expect(sent.hasId(), isFalse, reason: 'a new version is a new template');
    expect(sent.version, 2);
    expect(sent.fields.single.key, 'national_id');
  });
}
