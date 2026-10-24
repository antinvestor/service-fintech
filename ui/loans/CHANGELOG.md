## 0.2.0

- **Breaking:** moves to connect-dart 2 and the protobuf 6 runtime:
  `antinvestor_ui_core ^0.6.0`, the protobuf-6 `antinvestor_api_*` SDKs,
  `connectrpc ^2.0.0`, `protobuf ^6.1.0`. Struct maps are passed as entries.
- Collection prompts go to the borrower's profile; the dialog no longer
  takes a phone number, and `validatePhone` is removed.

## 0.1.0

- Initial release
- Loan management UI: products, requests, accounts, disbursements, repayments,
  penalties, schedules, restructuring
- Portfolio reporting: summary and loan book screens
- Dashboard with injectable metrics
- Status badge widgets for loans and loan requests
