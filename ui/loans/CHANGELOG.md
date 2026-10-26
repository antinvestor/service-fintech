## 0.4.0

- Staff origination completes in the console:
  - On a submitted request, staff with `loan_request_manage` confirm the
    client's data (`data_verification_confirmed`) before approving.
  - On an approved request, staff with `loan_manage` open the loan account
    (`LoanRequestDetailScreen.canOpenAccount`).
- **Breaking:** the disburse dialog no longer asks for a channel or
  recipient reference. It confirms that the principal is paid to the
  borrower's own payout contact on the loan, and refuses a loan without one.
  `_DisbursementFormDialog` takes the loan.
- "Cancel loan" (`loan_manage`) on a loan never disbursed: closes it and
  releases its funding. Collect Payment is offered on defaulted and
  written-off loans too (a written-off loan's payments are recoveries).
- The restructure dialog no longer offers a partial waiver, which the
  service refuses (`restructureTypeOffered`).
- Loan products take an "Agent commission (% of interest)", shown on the
  product detail.
- `TeamCommissionSection` (`commission_view`): a team's commission earned,
  paid out and available, with its payouts. With `commission_payout` it
  offers "Pay out" to an active member's own verified mobile number
  (`CommissionPayoutDialog`, one idempotency key per dialog).

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
