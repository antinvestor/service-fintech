import 'package:antinvestor_api_field/antinvestor_api_field.dart';
import 'package:antinvestor_api_identity/antinvestor_api_identity.dart'
    show ClientDataEntryObject;
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Service {
  Object? clientFailure;
  final failingKeys = <String, Object>{};
  final clients = <ClientObject>[];
  final details = <ClientDataEntryObject>[];
}

class _ClientNotifier extends ClientNotifier {
  _ClientNotifier(this.service);

  final _Service service;

  @override
  Future<ClientObject> save(ClientObject client) async {
    if (service.clientFailure != null) throw service.clientFailure!;
    service.clients.add(client);
    return client.deepCopy()..id = 'client-1';
  }
}

class _ClientDataNotifier extends ClientDataNotifier {
  _ClientDataNotifier(this.service);

  final _Service service;

  @override
  Future<ClientDataEntryObject> save(ClientDataEntryObject entry) async {
    final failure = service.failingKeys[entry.fieldKey];
    if (failure != null) throw failure;
    service.details.add(entry);
    return entry;
  }
}

ProviderContainer _container(_Service service, RegistrationOutboxStore store) {
  final container = ProviderContainer(
    overrides: [
      registrationOutboxStoreProvider.overrideWithValue(store),
      clientNotifierProvider.overrideWith(() => _ClientNotifier(service)),
      clientDataNotifierProvider.overrideWith(
        () => _ClientDataNotifier(service),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('a capture survives a restart and is sent on flush', () async {
    final store = InMemoryRegistrationOutboxStore();
    final service = _Service()
      ..clientFailure = ConnectException(Code.unavailable, 'offline');

    final first = _container(service, store);
    final outbox = first.read(registrationOutboxProvider.notifier);
    final id = await outbox.capture(
      name: 'Amina',
      phone: '+254700000001',
      nationalId: '123',
      details: {'national_id': '123', 'occupation': 'Trader', ' ': 'x'},
    );
    expect(await outbox.submit(id), RegistrationOutcome.queued);

    // The app restarts with the network back.
    service.clientFailure = null;
    final second = _container(service, store);
    final restored = await second.read(registrationOutboxProvider.future);
    expect(restored.single.details, {
      'national_id': '123',
      'occupation': 'Trader',
    });

    expect(await second.read(registrationOutboxProvider.notifier).flush(), 1);
    expect(service.clients.single.name, 'Amina');
    expect(service.details.map((d) => d.fieldKey), [
      'national_id',
      'occupation',
    ]);
    expect(await second.read(registrationOutboxProvider.future), isEmpty);
  });

  test('a detail is not resent once saved', () async {
    final service = _Service()
      ..failingKeys['occupation'] = ConnectException(Code.unavailable, 'x');
    final container = _container(service, InMemoryRegistrationOutboxStore());
    final outbox = container.read(registrationOutboxProvider.notifier);
    final id = await outbox.capture(
      name: 'Amina',
      phone: '+254700000001',
      details: {'national_id': '123', 'occupation': 'Trader'},
    );

    expect(await outbox.submit(id), RegistrationOutcome.queued);
    final pending = (await container.read(
      registrationOutboxProvider.future,
    )).single;
    expect(pending.clientId, 'client-1');
    expect(pending.details, {'occupation': 'Trader'});

    service.failingKeys.clear();
    expect(await outbox.flush(), 1);
    expect(service.clients, hasLength(1), reason: 'the client is sent once');
    expect(service.details.map((d) => d.fieldKey), [
      'national_id',
      'occupation',
    ]);
  });

  test('a refusal is kept with its reason and not retried', () async {
    final service = _Service()
      ..clientFailure = ConnectException(
        Code.invalidArgument,
        'phone number is invalid',
      );
    final container = _container(service, InMemoryRegistrationOutboxStore());
    final outbox = container.read(registrationOutboxProvider.notifier);
    final id = await outbox.capture(name: 'Amina', phone: 'abc');

    expect(await outbox.submit(id), RegistrationOutcome.rejected);
    final item = (await container.read(
      registrationOutboxProvider.future,
    )).single;
    expect(item.rejection, 'phone number is invalid');

    service.clientFailure = null;
    expect(await outbox.flush(), 0);
    expect(service.clients, isEmpty);

    await outbox.dismiss(id);
    expect(await container.read(registrationOutboxProvider.future), isEmpty);
  });

  test('the chosen owning team survives a restart and is sent', () async {
    final store = InMemoryRegistrationOutboxStore();
    final service = _Service()
      ..clientFailure = ConnectException(Code.unavailable, 'offline');

    final first = _container(service, store);
    final id = await first
        .read(registrationOutboxProvider.notifier)
        .capture(
          name: 'Baraka',
          phone: '+254700000002',
          owningTeamId: 'team-9',
        );
    expect(
      await first.read(registrationOutboxProvider.notifier).submit(id),
      RegistrationOutcome.queued,
    );

    service.clientFailure = null;
    final second = _container(service, store);
    expect(await second.read(registrationOutboxProvider.notifier).flush(), 1);
    expect(service.clients.single.owningTeamId, 'team-9');
  });
}
