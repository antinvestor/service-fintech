import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'identity_transport_provider.dart';

/// Where the onboarding form template is cached, so an agent can onboard a
/// borrower with the right form while offline. The default lives in
/// memory; a host app overrides [onboardingFormCacheProvider] with
/// persistent storage.
abstract class OnboardingFormCache {
  Future<String?> read();
  Future<void> write(String value);
}

class InMemoryOnboardingFormCache implements OnboardingFormCache {
  String? _value;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String value) async => _value = value;
}

final onboardingFormCacheProvider = Provider<OnboardingFormCache>(
  (ref) => InMemoryOnboardingFormCache(),
);

/// The organization's client form: what an agent captures when onboarding
/// and, through its required fields, what must be verified before the
/// client is activated. Fetched for the agent's own team and cached; when
/// the service cannot be reached the cached form is used. Null when the
/// organization has not published one and none is cached.
final onboardingTemplateProvider = FutureProvider<FormTemplateObject?>((
  ref,
) async {
  final cache = ref.read(onboardingFormCacheProvider);
  try {
    final response = await ref
        .read(identityServiceClientProvider)
        .clientKYCRequirements(ClientKYCRequirementsRequest());
    if (response.hasTemplate()) {
      await cache.write(response.template.writeToJson());
      return response.template;
    }
  } on ConnectException catch (e) {
    // The organization has no published form: nothing to cache.
    if (e.code == Code.failedPrecondition || e.code == Code.invalidArgument) {
      return null;
    }
  } catch (_) {
    // Offline: fall back to the cached form below.
  }
  final cached = await cache.read();
  if (cached == null || cached.isEmpty) return null;
  return FormTemplateObject.fromJson(cached);
});

/// What the client's organization requires and where each required field
/// stands; the client is activated only when it is complete.
final clientKycRequirementsProvider =
    FutureProvider.family<ClientKYCRequirementsResponse, String>(
      (ref, clientId) => ref
          .watch(identityServiceClientProvider)
          .clientKYCRequirements(
            ClientKYCRequirementsRequest(clientId: clientId),
          ),
    );
