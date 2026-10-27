## 0.3.0

- **Breaking:** removes "Record Deposit" (`DepositNotifier`,
  `depositNotifierProvider`). A deposit is the saver's own mobile-money
  payment, matched to their account by the payment rail; the savings service
  refuses a deposit recorded by a person.
- Actions are offered only with the permission the service checks:
  `SavingsAccountDetailScreen.canManageAccount` (freeze, close),
  `canWithdraw` (request a withdrawal, paid to the saver's own profile),
  `SavingsAccountsScreen.canManage` and `SavingsProductsScreen.canManage`
  (create). All default to false; `SavingsRouteModule` wires them.

## 0.2.0

- **Breaking:** moves to connect-dart 2 and the protobuf 6 runtime:
  `antinvestor_ui_core ^0.6.0`, the protobuf-6 `antinvestor_api_*` SDKs,
  `connectrpc ^2.0.0`, `protobuf ^6.1.0`. Struct maps are passed as entries.

## 0.1.0

- Initial release
- Savings accounts, products, deposits, and withdrawals screens
