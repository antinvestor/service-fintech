import 'dart:convert';
import 'dart:math';

import 'package:antinvestor_api_field/antinvestor_api_field.dart';
import 'package:antinvestor_api_identity/antinvestor_api_identity.dart'
    show ClientDataEntryObject, DataVerificationStatus;
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client_data_providers.dart';
import 'client_providers.dart';

/// A borrower registration captured on the device. It is kept until the
/// identity service has registered the client and saved every detail, so
/// nothing an agent captured offline is lost.
///
/// The phone is kept only until the registration reaches the identity
/// service, which hands it to the profile service; it never outlives the
/// entry.
class PendingRegistration {
  const PendingRegistration({
    required this.id,
    required this.name,
    required this.phone,
    required this.nationalId,
    required this.details,
    required this.queuedAt,
    this.clientId = '',
    this.rejection = '',
  });

  factory PendingRegistration.fromJson(Map<String, dynamic> json) =>
      PendingRegistration(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        nationalId: json['national_id'] as String? ?? '',
        details: Map<String, String>.from(
          json['details'] as Map<String, dynamic>? ?? const {},
        ),
        queuedAt: DateTime.parse(json['queued_at'] as String),
        clientId: json['client_id'] as String? ?? '',
        rejection: json['rejection'] as String? ?? '',
      );

  /// Local id; the server never sees it.
  final String id;
  final String name;
  final String phone;
  final String nationalId;

  /// KYC details by field key, saved as COLLECTED entries once the client
  /// exists. Each leaves the map as it is saved.
  final Map<String, String> details;
  final DateTime queuedAt;

  /// Set once the client is registered and only details remain.
  final String clientId;

  /// Why the service refused it; empty while it can still go through.
  final String rejection;

  bool get rejected => rejection.isNotEmpty;

  PendingRegistration copyWith({
    Map<String, String>? details,
    String? clientId,
    String? rejection,
  }) => PendingRegistration(
    id: id,
    name: name,
    phone: phone,
    nationalId: nationalId,
    details: details ?? this.details,
    queuedAt: queuedAt,
    clientId: clientId ?? this.clientId,
    rejection: rejection ?? this.rejection,
  );

  /// The registration as sent to the service. It needs no consent code:
  /// the client is registered CREATED and the person consents when it is
  /// activated, after their KYC is verified.
  ClientObject toClient() {
    final properties = Struct();
    properties.fields[kClientPhoneNumberKey] = Value(stringValue: phone);
    if (nationalId.isNotEmpty) {
      properties.fields[kClientNationalIdKey] = Value(stringValue: nationalId);
    }
    return ClientObject(name: name, properties: properties);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'national_id': nationalId,
    'details': details,
    'queued_at': queuedAt.toUtc().toIso8601String(),
    'client_id': clientId,
    'rejection': rejection,
  };
}

/// Where a submission got to.
enum RegistrationOutcome {
  /// The client is registered and every detail saved.
  registered,

  /// The service could not be reached; it stays on the device.
  queued,

  /// The service refused it; the reason is on the entry.
  rejected,
}

/// Where the registration outbox is kept. The default lives in memory; a
/// host app overrides [registrationOutboxStoreProvider] with persistent,
/// encrypted storage so captured registrations survive a restart.
abstract class RegistrationOutboxStore {
  Future<String?> read();
  Future<void> write(String value);
}

class InMemoryRegistrationOutboxStore implements RegistrationOutboxStore {
  String? _value;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String value) async => _value = value;
}

final registrationOutboxStoreProvider = Provider<RegistrationOutboxStore>(
  (ref) => InMemoryRegistrationOutboxStore(),
);

/// Whether [error] means the request may not have been heard: the network,
/// a timeout or an unavailable service. Anything else is the service's
/// answer.
bool _isTransientFailure(Object error) {
  if (error is ConnectException) {
    return switch (error.code) {
      Code.unavailable ||
      Code.deadlineExceeded ||
      Code.unknown ||
      Code.aborted ||
      Code.canceled => true,
      _ => false,
    };
  }
  // Socket and HTTP client failures never reached the service.
  return true;
}

String _reason(Object error) =>
    error is ConnectException ? error.message : '$error';

String _localId() {
  final random = Random.secure();
  return List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

/// Registrations captured on the device and waiting to reach the identity
/// service. Every registration goes through here, online or not: it is
/// stored first and submitted second, so a dropped connection or a closed
/// app never loses what the agent captured.
///
/// Replaying is safe: the service answers a second registration of the same
/// person with the client it already made, and a detail is saved per field
/// key.
class RegistrationOutbox extends AsyncNotifier<List<PendingRegistration>> {
  @override
  Future<List<PendingRegistration>> build() async {
    final raw = await ref.read(registrationOutboxStoreProvider).read();
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return [
      for (final item in decoded)
        PendingRegistration.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<void> _store(List<PendingRegistration> items) async {
    await ref
        .read(registrationOutboxStoreProvider)
        .write(jsonEncode([for (final i in items) i.toJson()]));
    state = AsyncData(items);
  }

  Future<void> _replace(PendingRegistration item) async {
    await _store([for (final i in await future) i.id == item.id ? item : i]);
  }

  Future<void> _remove(String id) async {
    await _store([
      for (final i in await future)
        if (i.id != id) i,
    ]);
  }

  PendingRegistration? _find(List<PendingRegistration> items, String id) {
    for (final i in items) {
      if (i.id == id) return i;
    }
    return null;
  }

  /// Stores a captured registration and returns its local id.
  Future<String> capture({
    required String name,
    required String phone,
    String nationalId = '',
    Map<String, String> details = const {},
  }) async {
    final item = PendingRegistration(
      id: _localId(),
      name: name,
      phone: phone,
      nationalId: nationalId,
      details: {
        for (final e in details.entries)
          if (e.key.trim().isNotEmpty && e.value.trim().isNotEmpty)
            e.key.trim(): e.value.trim(),
      },
      queuedAt: DateTime.now(),
    );
    await _store([...await future, item]);
    return item.id;
  }

  /// Sends the registration [id]: the client first, then each detail.
  Future<RegistrationOutcome> submit(String id) async {
    var item = _find(await future, id);
    if (item == null) return RegistrationOutcome.registered;
    if (item.rejected) return RegistrationOutcome.rejected;

    if (item.clientId.isEmpty) {
      final ClientObject saved;
      try {
        saved = await ref
            .read(clientNotifierProvider.notifier)
            .save(item.toClient());
      } catch (e) {
        if (_isTransientFailure(e)) return RegistrationOutcome.queued;
        await _replace(item.copyWith(rejection: _reason(e)));
        return RegistrationOutcome.rejected;
      }
      item = item.copyWith(clientId: saved.id);
      await _replace(item);
    }

    final remaining = Map<String, String>.of(item.details);
    for (final entry in item.details.entries) {
      try {
        await ref
            .read(clientDataNotifierProvider.notifier)
            .save(
              ClientDataEntryObject(
                clientId: item.clientId,
                fieldKey: entry.key,
                value: entry.value,
                valueType: 'string',
                verificationStatus:
                    DataVerificationStatus.DATA_VERIFICATION_STATUS_COLLECTED,
              ),
            );
      } catch (e) {
        if (_isTransientFailure(e)) {
          await _replace(item.copyWith(details: remaining));
          return RegistrationOutcome.queued;
        }
        // The client is registered; a refused detail is left for the
        // agent to re-enter on the client's KYC tab.
        await _replace(
          item.copyWith(
            details: remaining,
            rejection: '${entry.key}: ${_reason(e)}',
          ),
        );
        return RegistrationOutcome.rejected;
      }
      remaining.remove(entry.key);
    }
    await _remove(id);
    return RegistrationOutcome.registered;
  }

  /// Submits every registration not refused: new ones and ones with
  /// details left to save. Refused ones stay for the agent. Returns how
  /// many were registered.
  Future<int> flush() async {
    var registered = 0;
    for (final item in [...await future]) {
      if (item.rejected) continue;
      if (await submit(item.id) == RegistrationOutcome.registered) {
        registered++;
      }
    }
    return registered;
  }

  /// Drops a registration once the agent has dealt with it.
  Future<void> dismiss(String id) => _remove(id);
}

final registrationOutboxProvider =
    AsyncNotifierProvider<RegistrationOutbox, List<PendingRegistration>>(
      RegistrationOutbox.new,
    );
