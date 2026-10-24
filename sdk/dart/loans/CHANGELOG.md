## 0.5.0

- **Breaking:** regenerated with protoc_plugin 25.1 (`buf.build/protocolbuffers/dart:v25.1.0`)
  and connect-dart 2.0 (`buf.build/connectrpc/dart:v2.0.0`); requires
  `protobuf ^6.1.0`, `connectrpc ^2.0.0`, `fixnum ^1.1.1`,
  `antinvestor_api_common ^2.0.0` and Dart `^3.7.0`.
- Well-known types (`Struct`, `Timestamp`, ...) now come from
  `package:protobuf/well_known_types/...`; the vendored copies and empty
  `.pbserver.dart` files are gone. Map fields take entries in generated
  constructors.
- `RepaymentObject.collected_by`; `RepaymentSearchRequest.collected_by`,
  `received_after`, `received_before`; `LoanRequestObject.submitted_by`,
  `decided_by`.
- `InitiateCollectionRequest.contact_id` (a profile contact id);
  `phone_number` is deprecated and refused by the server.
- `payment_account_ref` is the borrower's payout contact id, never a number.

## 0.4.0

- Add loan_view_own permission
- Add InitiateCollectionRequest.collection_amount (Money); amount deprecated
- Add PortfolioSummary.pending_disbursement_loans
- LoanRequestObject.status documented server-only
- Regenerated from latest proto definitions

## 0.3.0

- Money fields use common.v1.Money (was google.type.Money); the barrel exports the common Money type
- Regenerated from latest proto definitions (portfolio, collection and client product access RPCs)

## 0.1.0

- Generated Dart SDK from proto definitions

