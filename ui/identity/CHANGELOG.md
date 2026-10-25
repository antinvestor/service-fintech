## 0.5.0

- KYC requirements come from each organization's published client form
  template. Onboarding renders that form (`TemplateFieldInput`), cached for
  offline use (`onboardingTemplateProvider`, `onboardingFormCacheProvider`);
  without one the usual details are asked for.
- The client's KYC tab lists what the organization requires and where each
  field stands (`clientKycRequirementsProvider`); "Activate" is enabled only
  when all of it is verified.
- Requires `antinvestor_api_identity ^0.8.0`.

## 0.4.0

- Consent moves from registration to activation. Registering a borrower
  never asks for a code: the client starts CREATED. Once their KYC is
  verified, "Activate" on the client sends the borrower a code; entering it
  makes them ACTIVE and confirms the phone is theirs. Loans are approved
  only for active clients.
- An awaiting-activation client shows no profile or contacts.
- **Breaking:** `withConsentCode` is replaced by `activationRequest`;
  `clientAwaitingActivation` is added. The registration outbox no longer
  tracks consent (`RegistrationOutcome.awaitingConsent`,
  `RegistrationOutbox.resendConsent` and `submit(code:)` are removed), and
  `PendingRegistrationsPanel` takes no `onSend`.

## 0.3.0

- Onboarding works offline. Every registration is stored on the device
  first (`registrationOutboxProvider`), then sent; one that cannot reach
  the service is sent on the next `flush()`. A host app persists it by
  overriding `registrationOutboxStoreProvider` with encrypted storage.
- **Breaking:** onboarding with `ClientFormDialog` pops a
  `ClientRegistrationDraft` instead of a `ClientObject`. The form now also
  captures date of birth, residential address, occupation and any other
  named detail; each is saved as a COLLECTED KYC entry once the client
  exists, along with the national ID.
- A person who already has a profile can give their consent code later:
  the registration waits on the device with "Enter code" and "Resend code".
- The clients page stays usable for onboarding when the list cannot load.

## 0.2.0

- **Breaking:** moves to connect-dart 2 and the protobuf 6 runtime:
  `antinvestor_ui_core ^0.6.0`, the protobuf-6 `antinvestor_api_*` SDKs,
  `connectrpc ^2.0.0`, `protobuf ^6.1.0`. Struct maps are passed as entries.
- Borrower contacts are shown and managed on the profile
  (`ProfileInlineManager`); the client list and detail no longer show a
  stored phone. The phone is asked for only when onboarding, to find or
  create the profile, and is not validated or reformatted here.
- Onboarding someone who already has a profile asks for the consent code
  sent to them (`ConsentCodeDialog`, `clientConsentPending`,
  `withConsentCode`).
- `myClientAccessScopeProvider`: the signed-in user's client access scope
  (own client, workforce member id, served clients).

## 0.1.0

- Initial release
- Organization, org unit, branch, investor management screens and providers
- Workforce member listing, detail, and registration screens
- Access role assignment management
- Form template listing with status badges
- Client data entry providers (verify, reject, request info)
- Roles & Permissions reference matrix screen
- All providers use plain FutureProvider / NotifierProvider (no codegen)
