## 0.4.1

- `PayoutFailedApply` (`payout_outcome_apply`, operations only): undoes this
  service's record of a payout the payment rail failed after accepting it.
- `SavingsJobRun` (`SavingsJob.SAVINGS_JOB_ACCRUE_INTEREST`, `savings_job_run`):
  the scheduler's daily interest accrual. Service accounts only.

## 0.4.0

- **Breaking:** regenerated with protoc_plugin 25.1 (`buf.build/protocolbuffers/dart:v25.1.0`)
  and connect-dart 2.0 (`buf.build/connectrpc/dart:v2.0.0`); requires
  `protobuf ^6.1.0`, `connectrpc ^2.0.0`, `fixnum ^1.1.1`,
  `antinvestor_api_common ^2.0.0` and Dart `^3.7.0`.
- Well-known types (`Struct`, `Timestamp`, ...) now come from
  `package:protobuf/well_known_types/...`; the vendored copies and empty
  `.pbserver.dart` files are gone. Map fields take entries in generated
  constructors.
- `recipient_reference` on withdrawals is the owner's payout contact id,
  never a number.

## 0.3.0

- Add SavingsStatementRequest.cursor and SavingsStatementResponse.next_cursor
- Add SAVINGS_PERIOD_TYPE_ANNUALLY
- WithdrawalSearchRequest.savings_account_id optional (cross-account queues)
- Regenerated from latest proto definitions

## 0.1.0

- Generated Dart SDK from proto definitions

