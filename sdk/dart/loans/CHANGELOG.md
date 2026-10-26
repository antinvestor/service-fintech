## 0.6.6

- `PayoutFailedApply` (`payout_outcome_apply`, operations only): undoes this
  service's record of a payout the payment rail failed after accepting it.

## 0.6.5

- Team commission: `TeamCommissionSearch` and `TeamCommissionPayoutSearch`
  (`commission_view`), and `TeamCommissionPayout` (`commission_payout`),
  which pays part of a team's balance to an active member's own verified
  mobile money.

## 0.6.4

- `LoanProductObject.agent_commission_percent`: the share of each
  repayment's interest credited to the field team serving the borrower.

## 0.6.3

- `LoanManagementService.LoanAccountCancel`: closes a loan that was never
  disbursed and releases its funding (`loan_manage`).
- ROLE_OPERATOR holds `collection_manage`.

## 0.6.2

- `LoanJob.LOAN_JOB_PAID_OFF_NOTICES`: the scheduler retries pay-off notices
  that did not reach downstream products.

## 0.6.1

- `RepaymentObject.collected_by` and `RepaymentSearchRequest.collected_by`
  are deprecated: nobody collects repayments on a borrower's behalf.
  `RepaymentRecord` is applied by the payment rail only.

## 0.6.0

- `LoanManagementService.LoanJobRun` and the `LoanJob` enum: one bounded batch of a periodic job (delinquency scan, due reminders, funder settlement, offer expiry), called by the platform scheduler.

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

