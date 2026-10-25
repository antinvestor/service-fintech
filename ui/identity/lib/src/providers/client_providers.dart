import 'package:antinvestor_api_field/antinvestor_api_field.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'identity_transport_provider.dart';
import 'paged_list.dart';

/// Property keys the onboarding form writes into `ClientObject.properties`.
const kClientPhoneNumberKey = 'phone_number';
const kClientNationalIdKey = 'national_id';

/// Reads a string property off a client, or '' when absent.
String clientProperty(ClientObject client, String key) {
  if (!client.hasProperties()) return '';
  final value = client.properties.fields[key];
  if (value == null || !value.hasStringValue()) return '';
  return value.stringValue;
}

/// Consent handshake keys. Registration asks for no code: a client starts
/// CREATED. Activating it (once its KYC is verified) answers with
/// [kClientConsentVerificationIdKey] and status pending after a code is sent
/// to the person; the activation is resubmitted with the code they received.
const kClientConsentVerificationIdKey = 'consent_verification_id';
const kClientConsentCodeKey = 'consent_code';
const kClientConsentStatusKey = 'consent_status';

/// Whether a save answered with a pending consent request.
bool clientConsentPending(ClientObject client) =>
    clientProperty(client, kClientConsentStatusKey) == 'pending' &&
    clientProperty(client, kClientConsentVerificationIdKey).isNotEmpty;

/// Whether [client] is registered but not yet activated.
bool clientAwaitingActivation(ClientObject client) =>
    client.state == STATE.CREATED;

/// [client] asked to become ACTIVE, answering the consent challenge in
/// [pending] with [code] when given.
ClientObject activationRequest(
  ClientObject client, {
  ClientObject? pending,
  String code = '',
}) {
  final next = client.deepCopy()..state = STATE.ACTIVE;
  if (!next.hasProperties()) next.properties = Struct();
  if (pending != null && code.isNotEmpty) {
    next.properties.fields[kClientConsentVerificationIdKey] = Value(
      stringValue: clientProperty(pending, kClientConsentVerificationIdKey),
    );
    next.properties.fields[kClientConsentCodeKey] = Value(stringValue: code);
  }
  return next;
}

String clientNationalId(ClientObject client) =>
    clientProperty(client, kClientNationalIdKey);

/// Search clients with optional filters. An empty [agentId] or
/// [owningTeamId] leaves that filter off; the service scopes the result to
/// what the caller may see.
typedef ClientListParams = ({
  String query,
  String agentId,
  String owningTeamId,
});

/// Clients matching [params], one cursor page at a time.
class ClientPagedList extends PagedListNotifier<ClientObject> {
  ClientPagedList(this.params);

  final ClientListParams params;

  @override
  Future<List<ClientObject>> fetchPage(int offset, int limit) {
    final client = ref.read(fieldServiceClientProvider);
    return collectStream(
      client.clientSearch(
        ClientSearchRequest(
          query: params.query,
          agentId: params.agentId,
          owningTeamId: params.owningTeamId,
          cursor: PageCursor(page: '$offset', limit: limit),
        ),
      ),
      extract: (response) => response.data,
    );
  }
}

final clientPagedListProvider =
    AsyncNotifierProvider.family<
      ClientPagedList,
      PagedList<ClientObject>,
      ClientListParams
    >(ClientPagedList.new);

final clientDetailProvider = FutureProvider.family<ClientObject, String>((
  ref,
  clientId,
) async {
  final client = ref.watch(fieldServiceClientProvider);
  final response = await client.clientGet(ClientGetRequest(id: clientId));
  return response.data;
});

/// Notifier for client mutations.
class ClientNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Creates or updates a client. A field agent may leave `owning_team_id`
  /// empty: the service places the client in the agent's own team.
  Future<ClientObject> save(ClientObject client) async {
    state = const AsyncValue.loading();
    try {
      final response = await ref
          .read(fieldServiceClientProvider)
          .clientSave(ClientSaveRequest(data: client));
      ref.invalidate(clientPagedListProvider);
      ref.invalidate(clientDetailProvider);
      state = const AsyncValue.data(null);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final clientNotifierProvider =
    NotifierProvider<ClientNotifier, AsyncValue<void>>(ClientNotifier.new);

/// What the signed-in user may act for as a client: their own client as a
/// borrower and, as a field agent, their workforce member id and the clients
/// they serve.
final myClientAccessScopeProvider = FutureProvider<ClientAccessScopeResponse>(
  (ref) => ref
      .watch(fieldServiceClientProvider)
      .clientAccessScope(ClientAccessScopeRequest()),
);
