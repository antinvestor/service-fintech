## 0.3.0

- `IncomingPaymentsScreen`: payments the rail received, filtered to the ones
  that matched nobody by default. With `canAssign` (`payment_allocate`) an
  unmatched payment is assigned to its loan with a note, and applied in full
  as received; there is no amount field. A matched payment whose allocation
  did not finish offers Allocate.
- `OperationsRouteModule`: `/operations/payments` and `/operations/transfers`,
  navigation and the `service_operations` permission manifest. A host may
  pass `pickLoan` to offer a loan search in the assign dialog.
- Requires `antinvestor_api_operations ^0.4.1`.

## 0.2.0

- **Breaking:** moves to connect-dart 2 and the protobuf 6 runtime:
  `antinvestor_ui_core ^0.6.0`, the protobuf-6 `antinvestor_api_*` SDKs,
  `connectrpc ^2.0.0`, `protobuf ^6.1.0`. Struct maps are passed as entries.

## 0.1.0

- Initial release
- Transfer orders, disbursement queue, and notification templates screens
