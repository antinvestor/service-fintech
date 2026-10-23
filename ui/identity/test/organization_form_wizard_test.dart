import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_api_profile/antinvestor_api_profile.dart'
    show ProfileServiceClient;
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A transport whose every call fails, so the wizard never reaches the network
/// in a widget test.
class _OfflineTransport implements Transport {
  @override
  Future<UnaryResponse<I, O>> unary<I extends Object, O extends Object>(
    Spec<I, O> spec,
    I input, [
    CallOptions? options,
  ]) async {
    throw ConnectException(Code.unavailable, 'offline');
  }

  @override
  Future<StreamResponse<I, O>> stream<I extends Object, O extends Object>(
    Spec<I, O> spec,
    Stream<I> input, [
    CallOptions? options,
  ]) async {
    throw ConnectException(Code.unavailable, 'offline');
  }
}

Widget _host({
  required Future<void> Function(OrganizationWizardResult) onSave,
  OrganizationObject? organization,
}) {
  final transport = _OfflineTransport();
  return ProviderScope(
    overrides: [
      profileServiceClientProvider.overrideWithValue(
        ProfileServiceClient(transport),
      ),
      identityServiceClientProvider.overrideWithValue(
        IdentityServiceClient(transport),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: OrganizationFormWizard(
          organization: organization,
          onSave: onSave,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('refuses to advance past the contact step without a contact', (
    tester,
  ) async {
    var saved = 0;
    await tester.pumpWidget(_host(onSave: (_) async => saved++));
    await tester.pumpAndSettle();

    expect(find.text('Contact'), findsWidgets);

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Enter a contact to search'), findsOneWidget);
    expect(saved, 0);
  });

  testWidgets('asks for a name before creating a profile for a new contact', (
    tester,
  ) async {
    var saved = 0;
    await tester.pumpWidget(_host(onSave: (_) async => saved++));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Organization email or phone'),
      'new.org@example.com',
    );
    // The lookup fails offline, which is the "no profile yet" path.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Enter a name to create the profile'), findsOneWidget);
    expect(saved, 0);
  });

  testWidgets('offers every organization type in the details step', (
    tester,
  ) async {
    await tester.pumpWidget(_host(onSave: (_) async {}));
    await tester.pumpAndSettle();

    final items = tester
        .widgetList<DropdownMenuItem<OrganizationType>>(
          find.byType(DropdownMenuItem<OrganizationType>, skipOffstage: false),
        )
        .map((item) => item.value)
        .toSet();
    expect(items, equals(OrganizationType.values.toSet()));
  });
}
