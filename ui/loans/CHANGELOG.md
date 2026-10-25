## 0.3.0

- **Breaking:** field agents and staff no longer record repayments. The
  borrower pays from their own contact and the payment rail applies it.
  Removed: the Record Payment action and dialog,
  `LoanAccountDetailScreen.canRecordPayment`, `RepaymentNotifier`,
  `repaymentNotifierProvider`, the offline repayment outbox
  (`PendingRepayment`, `OutboxStore`, `outboxStoreProvider`,
  `repaymentOutboxProvider`), `MyCollectionsScreen` and its
  `/loans/collections` route, `myCollectionsTodayProvider`, the cash channel
  (`kRepaymentChannelCash`, `kRepaymentChannels`, `kCashCollectionNote`), and
  the `repayment_manage` permission entry.
- "Collect Payment" stays: it prompts the borrower to pay from their own
  contact.
- Requires `antinvestor_api_loans ^0.6.1`.

## 0.2.0

- **Breaking:** moves to connect-dart 2 and the protobuf 6 runtime:
  `antinvestor_ui_core ^0.6.0`, the protobuf-6 `antinvestor_api_*` SDKs,
  `connectrpc ^2.0.0`, `protobuf ^6.1.0`. Struct maps are passed as entries.
- Collection prompts go to the borrower's profile; the dialog no longer
  takes a phone number, and `validatePhone` is removed.
- Loan statement tab (`LoanStatement`) with running balance.
- "My collections today" (`/loans/collections`, `MyCollectionsScreen`,
  `myCollectionsTodayProvider`): the agent's repayments since midnight with
  exact per-currency totals.
- Offline outbox for repayments (`repaymentOutboxProvider`,
  `OutboxStore`): a repayment that cannot reach the service is queued with
  its idempotency key and replayed later; refusals are never queued.
  `RepaymentNotifier.record` returns null when the repayment was queued.

## 0.1.0

- Initial release
- Loan management UI: products, requests, accounts, disbursements, repayments,
  penalties, schedules, restructuring
- Portfolio reporting: summary and loan book screens
- Dashboard with injectable metrics
- Status badge widgets for loans and loan requests
