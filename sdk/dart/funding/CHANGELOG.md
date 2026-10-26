## 0.5.2

- `FundingService.LoanRecoveryApply`: principal recovered from a written-off
  loan returned to its funders, most senior tranche first. Internal callers
  only.

## 0.5.1

- `FundingService.FundingRelease`: returns the capital reserved for a loan
  cancelled before disbursement. Internal callers only.

## 0.5.0

- `FundingService.LoanRepaymentApply`: shares a loan repayment out to its funders (`RepaymentShareObject`).
- `AbsorbLossRequest.product_id` and `AbsorbLossResponse.settled`: an absorbed loss is posted to funders' capital.

## 0.4.0

- **Breaking:** regenerated with protoc_plugin 25.1 (`buf.build/protocolbuffers/dart:v25.1.0`)
  and connect-dart 2.0 (`buf.build/connectrpc/dart:v2.0.0`); requires
  `protobuf ^6.1.0`, `connectrpc ^2.0.0`, `fixnum ^1.1.1`,
  `antinvestor_api_common ^2.0.0` and Dart `^3.7.0`.
- Well-known types (`Struct`, `Timestamp`, ...) now come from
  `package:protobuf/well_known_types/...`; the vendored copies and empty
  `.pbserver.dart` files are gone. Map fields take entries in generated
  constructors.

## 0.3.0

- Add buf.validate rules on funding requests
- Add InvestorAccountObject.currency_code, InvestorAccountSearchResponse.next_cursor, AbsorbLossRequest.loss_reference
- Add optional body idempotency_key on deposit/withdraw
- Regenerated from latest proto definitions

## 0.1.0

- Generated Dart SDK from proto definitions

