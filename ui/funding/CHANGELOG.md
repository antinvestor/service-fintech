## 0.5.0

- **Breaking:** capital is never recorded by hand. Removed the Deposit
  action and `InvestorAccountNotifier.deposit`. The account screen shows
  how capital arrives: the investor pays from their own account, quoting
  the account id, and the payment rail credits it.
- **Breaking:** removed Fund Loan (`InvestorAccountDetailScreen.canFund`,
  `InvestorAccountNotifier.fundLoan`). A loan is funded from the whole pool
  when its account opens; the dialog implied it drew on this account.
- `InvestorStatementCard` on the account page: what moved the account's
  capital over the last 30 days, this month, last month or the year to
  date, with totals, and "Download CSV" (`statementCsv`,
  `investorStatementProvider`). Needs `antinvestor_api_funding` 0.5.3.

## 0.4.0

- `FundingRouteModule`: routes (`/funding/accounts`, `/funding/accounts/:accountId`),
  navigation and the `service_funding` permission manifest for host apps.
- `InvestorAccountsScreen.canManage` and `InvestorAccountDetailScreen.canManage`
  / `canFund`: opening an account, deposits and withdrawals are offered only
  with `investor_account_manage`, and Fund Loan only with `fund_manage`.
  Both default to false.
- Requires `antinvestor_api_funding ^0.5.0`.

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
