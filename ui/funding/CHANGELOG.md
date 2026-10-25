## 0.3.0

- **Breaking:** removes the manual "Absorb Loss" action (`AbsorbLossDialog`,
  `InvestorAccountNotifier.absorbLoss`). A loss now reaches funders only
  through a loan write-off, which posts it to the ledger; the funding service
  refuses `AbsorbLoss` from a person.

## 0.2.0

- **Breaking:** moves to connect-dart 2 and the protobuf 6 runtime:
  `antinvestor_ui_core ^0.6.0`, the protobuf-6 `antinvestor_api_*` SDKs,
  `connectrpc ^2.0.0`, `protobuf ^6.1.0`. Struct maps are passed as entries.

## 0.1.0

- Initial release
- Investor accounts, deposits, withdrawals, and loan funding screens
