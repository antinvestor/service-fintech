## 0.4.5

- `TransferOrderType.TRANSFER_ORDER_TYPE_AGENT_COMMISSION` (50): a
  product's commission accrued to the serving team's payable.

## 0.4.4

- `TransferOrderType.TRANSFER_ORDER_TYPE_INVESTOR_WITHDRAWAL` (49): investor
  capital paid out to the investor's own mobile money.

## 0.4.3

- `OperationsService.OperationsJobRun` (`OperationsJob`, permission
  `operations_job_run`): the scheduler's settle run for individuals'
  payments. Service accounts only.

## 0.4.2

- `IncomingPaymentObject.savings_account_id`: the saver's account a payment
  was deposited to.
- `IncomingPaymentAssignRequest.savings_account_id`: staff may tie an
  unmatched payment to a savings account instead of a loan (exactly one).

## 0.4.1

- `OperationsService.IncomingPaymentSearch` lists received payments
  (`IncomingPaymentObject`), optionally only those that matched nobody.
- `OperationsService.IncomingPaymentAssign` ties an unmatched payment to its
  loan and allocates it; the amount is the rail's.
- New permission `payment_view`.
- Exports `Money`.

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

- Add TransferOrderSearchResponse.next_cursor
- Add TransferOrderType enum and transfer_type field; int order_type deprecated
- Regenerated from latest proto definitions

## 0.2.0

- Money fields use common.v1.Money
- Regenerated from latest proto definitions

## 0.1.0

- Generated Dart SDK from proto definitions

