# Production readiness audit — field-agent lending — 2026-10-23

Scope: can a microfinance lender run lending through field agents on this
system end to end — onboard a borrower, originate a loan, disburse it, collect
repayments in the field or by mobile money, handle arrears — with every money
movement captured correctly and the borrower and agent told what happened at
each stage. Services audited: identity (field service), loans, operations,
savings, funding, seed, stawi, the shared packages, the Flutter packages and
the composed app. The notification and payment services were read in their
own repositories to verify contracts rather than assume them.

Baseline: the 2026-09 fix pass (`docs/audit/2026-09-10-production-readiness.md`)
had never been merged; `main` had moved on by 49 dependency bumps. This branch
(`audit/field-agent-lending`) merges that pass onto `main` and continues from
there. All 31 Go packages were green on the merged tree before any new change.

Method: six adversarial stage reviews reading full source (onboarding,
origination and disbursement, repayment and collections, product services,
capital plumbing, UI), cross-checked by hand against the sibling notification
and payment service code, followed by a fix pass on the same branch. Raw stage
reports are in the session scratchpad; this document is the consolidated
verdict and the record of what was fixed.

## 1. Requirements checklist

| Capability (field-agent lending) | Before | After |
|---|---|---|
| Agent registers a borrower (profile, phone, KYC) | FAIL: `ClientSave` required a retired agent id and a pre-existing profile; identity never created profiles; writes were fire-and-forget; any `client_view` holder saw every client; agents (member role) could not write | PASS: synchronous registration, profile found or created from the captured phone, one client per borrower per lender, agent scoped to own teams and relationships, phone validated |
| Borrower told about onboarding and KYC outcomes | FAIL: no messages | PASS: welcome, verified, rejected, more-info messages to the borrower's profile |
| Agent submits a loan application for the borrower | FAIL (UI): no screen; (API) actor from body, properties steer verification and payout | PASS: caller authorised for the client, reserved properties stripped for non-staff, submitter recorded; UI dialog (see §7) |
| Approval with separation of duties | FAIL: same permission creates and approves; no maker/checker | PASS: submitter/creator/agent cannot decide; decisions are conditional writes; decided_by recorded; audited |
| Disbursement with exactly one payout | FAIL: two keys paid twice; failed ledger post reported success; payout fire-and-forget | PASS: one live disbursement per loan; execution releases on failure and resumes; payout claimed once and confirmed with the payment rail; destination must be a borrower contact |
| Borrower told about approval and disbursement | FAIL: templates unregistered, variables in the wrong field, recipient by detail (dropped) | PASS: catalogue registered at setup, Payload + profile recipient, messages on submit/approve/reject/disburse |
| Agent records a cash repayment | FAIL: no collector, cash booked as borrower's own account, free-text channel | PASS: collector from claims, channel vocabulary, cash debited from the agent's cash-in-hand, agent confirmation message |
| Mobile-money repayment reaches the loan | PARTIAL: operations matched only group obligations | PARTIAL: group allocations now record the repayment with loans; direct borrower MSISDN/loan-reference matching is a tracked follow-up |
| Penalties and arrears | FAIL: penalty income double counted; scanner ignored delinquent/restructured loans; no cure; no messages | PASS: settlement clears the receivable; all live statuses scanned; cure to prior status; penalties idempotent per installment; borrower and agent messaged |
| Due and overdue reminders | FAIL: none | PASS: reminder job, each installment reminded once |
| Capital side (funding, savings) | FAIL: short allocations locked for ever; records orphaned | PASS for allocation; savings withdrawal payout and AbsorbLoss on write-off remain tracked (§8) |
| Product services (seed, stawi) can originate a disbursable loan | FAIL: no payout destination, no term/client/currency | PASS: both now send complete applications; stawi offer-response route still missing (§8) |
| Field-agent UI journey | FAIL: loans not mounted in the app; no client screens; no request creation | see §7 |

## 2. Implicit assumptions surfaced

1. Notification delivery assumed `Data` was rendered and `Detail` addressed a person; the service renders `Payload` and addresses `ProfileId`/`ContactId`. Every fintech message was undeliverable.
2. A transfer order in `CheckCreated` was assumed "done" by every retry; it meant "started and not finished".
3. An accepted `payment.Send` was assumed paid. The rail reports asynchronously; the service does not dedupe on reference.
4. A client id was assumed to be a contact; it is an identity row keyed to a profile.
5. Fee percentages were assumed annual rates; a 2% processing fee on a three-month loan collected 0.5%.
6. Daily and quarterly frequencies were assumed monthly.
7. A found row was assumed to mean its side effects had run (allocation orders, penalties).
8. Any single verified KYC entry was assumed sufficient when no fields were named.
9. Tokens without roles were assumed staff; they are now treated as unscoped only when internal or carrying admin/operator/viewer.

## 3. Scalability limits

Unchanged from the September audit except: both loan background jobs now run under a Postgres advisory lock on a configurable interval, and the reminder job pages installments; agent-scoped client searches resolve the agent's client ids first (bounded by team size), which is acceptable for field teams and should move to a join once teams exceed a few thousand clients.

## 4. Failure modes

Closed in this pass: ledger failure after a claim (release and retry), side-effect failure after a posted ledger (retained ledger id, resumed), ambiguous payout error (claim kept, confirmed by lookup, retaken only when stale and absent), allocation replay (lease, remainder, consumption recorded on the order), short funding (reservations and records given back), penalty save failure (mark cleared, save idempotent per installment), crashed scan (advisory lock, stale lease takeover), scheduler running on every replica (lock).

Open: an order whose payout the rail rejected after the ledger posted is left unsettled with a `payout_status = failed` marker and needs an operator reversal; no automatic reversal order exists yet.

## 5. Data integrity

Every money movement touched in this pass is a conditional write with a persisted progress marker: `transfer_orders.ledger_transaction_id`, `payment_initiated_at`, `payment_id`, `payout_status`, `obligation_consumed`; `incoming_payments.allocating_at` and `remaining_amount`; `penalties.properties.balance_applied`; `schedule_entries` reminder and penalty marks; `disbursements` one-live-per-loan index; `penalties` one-per-installment-and-type index; `clients` one-per-profile-per-partition index. Backfills are run once behind a marker table, never on every start.

## 6. Security and isolation

Closed: borrower-supplied `data_verification_confirmed` and `payment_account_ref`; self-approval; agent reading or editing other teams' clients; agent moving clients between teams; agent binding a staff member's phone to a client; agent progressing approval cases; payout to an unverified destination; idempotency key reused across loans; suspended workforce members retaining scope. Open: OTP verification of a phone that already resolves to an existing borrower profile before an agent binds it (today the bind is allowed when the profile is not a staff member's; staff review of such registrations is recommended until OTP exists).

## 7. Operational gaps and UI

New deployment requirements (all recorded in `docs/runbook/required-environment.md`): `LENDER_DISPLAY_NAME` (loans, identity), `PROFILE_SERVICE_URI` (loans, seed), `PAYMENT_SERVICE_URI` now required by operations, `SEED_KYC_REQUIRED_FIELDS` required when secure, `STAWI_LOAN_PRODUCT_ID`, `DELINQUENCY_SCAN_INTERVAL`, `DUE_REMINDER_INTERVAL`, `DUE_REMINDER_DAYS`. The setup Job of loans and identity registers the message catalogue with the notification service on every deploy.

UI: the composed app did not mount the loans package and had no borrower screens; see the commit on the Flutter packages for what was added (loans mounted, client onboarding and KYC screens, loan application dialog, permission gating corrected, repayment channel vocabulary, agent portfolio filter). Mobile layout and offline tolerance remain open (§8).

## 8. Open items (tracked, not blocking a pilot with staff-side controls)

Proto follow-ups (publish to BSR, then wire): `ClientObject.agent_id`/`profile_id` optional (in tree), `ClientSearchRequest.profile_id`, `RepaymentObject.collected_by` and a `RepaymentSearch` filter by collector (exposed today through `properties.collected_by`), `LoanRequestObject.submitted_by/decided_by`, a `LoanRequestSave` binding to `loan_request_submit`, stawi offer-response RPC.

Service follow-ups: stawi offer-response route and member ledger account creation; savings withdrawal payout and investor principal return through the payment rail; `AbsorbLoss` on write-off; repayment redistribution decimals and legs; a reversal order for a rail-rejected payout; direct mobile-money matching by borrower MSISDN or loan reference; seed paid-off hook from loans; chart-of-accounts constants with an idempotent account creation step; the deprecated Agent RPCs (already fail closed with `Gone`) removed from the proto and OPL.

UI follow-ups: phone-width list layouts and bottom navigation; offline outbox for repayments and registrations; statement screen; loan request approval queue with maker/checker view; agent collections-today report (needs the collector filter above).

## 9. Verification log

Run on 2026-10-24 on the finished tree (branch `audit/field-agent-lending`, head `6b38bed` plus this document).

| Check | Command | Result |
|---|---|---|
| Go build | `go build ./...` | ok |
| Go tests, race detector, whole module | `go test -count=1 -race -p 2 ./...` | 33 packages ok, exit 0 (longest: limits business 199s, identity business 161s) |
| Go lint | `golangci-lint run ./...` (v2.15.0, the pre-commit hook's version) | 0 issues |
| Proto | `buf lint`; `buf breaking --against main` | clean; no breaking changes |
| OPL | `make opl-check` | generated files match the proto role bindings |
| Flutter `ui/loans` | `flutter analyze`; `dart format --set-exit-if-changed .`; `flutter test` | no issues; 0 changed; 44 passed |
| Flutter `ui/identity` | same | no issues; 0 changed; 31 passed |
| Flutter `ui/seed` | same | no issues; 0 changed; 53 passed |

Late finding closed during the gate: the payment-allocation path forwarded a loan obligation's `cause_id` (the schedule entry) to the loans service as the loan account, and completed the order even when the lender call failed. The loan account id is now recorded on each loan obligation when it is raised and read from there, and a failed lender call releases the order for a retry with the ledger leg retained (commit `e128447`, covered by `loan_repayment_feedback_test.go`). Loan obligations raised before this change carry no loan account id and are not fed back; they need the reconciliation described in §4.

Not verified here: a deployed end-to-end run against the real notification and payment services (their contracts were verified by reading their source, not by calling them), and the migrations against production data volumes.

## 10. Verdict

Before this pass: **NOT READY.** No borrower or agent could receive a single message; a failed ledger posting reported success to every retry and a disbursement could pay twice; agents could not register borrowers through the API at all; penalties were double counted; product services could not originate a disbursable loan.

After this pass: **READY WITH CONDITIONS** for a field-agent pilot in which staff approve applications and operators own payout failures:

1. Deploy with the new environment set and run the setup Jobs (migrations 0003/0004 for loans and 004 for identity add indexes that refuse pre-existing duplicates by design).
2. Publish the in-tree proto changes to BSR and wire the follow-ups listed in §8.
3. Keep a daily look at transfer orders with `payout_status = failed` and at `incoming_payments` in a non-initial state with no recorded remainder until the reversal path exists.
4. Treat agent registrations whose phone matched an existing profile as review items until phone verification exists.

## 11. Addendum 2026-10-24 — transaction limits

The limits service already evaluates every matching policy and requires all of them to pass, so the tightest cap wins. What was missing was the tie to the partition tree, plus the wiring to make the gates actually run. Fixed:

- **Partition tiers.** Candidate policies were matched by tenant alone, so a policy saved on one unit's partition bound every sibling and parent. They are now restricted to the transaction's partition and its ancestors, resolved through the tenancy service's `GetPartitionParents`, cached, and failing closed when the tree cannot be read or the walk was cut short. This works for any depth.
- **The record decides the partition.** Every gate evaluates in the partition that owns the record (`limits.InPartition`), not the partition of whoever triggered it.
- **Client attributes.** Borrowers were looked up as investors, so a client-filtered enforce policy failed closed for every borrower. They are now resolved through the field service. Agents tighten a client by setting the client's tier property against operator-defined tier policies.
- **Rejected intents.** Savings intents lacked the client and funding intents lacked the organization, so the limits service would have rejected them.
- **Stawi.** Stawi reserved its loans a second time with an invalid subject set, which would have double-counted against tenant and partition caps. That gate is removed, and loans limits the same loan. Stawi's in-process transfer orders, previously hard-coded ungated, now take the operations gate settings.
- **Branch scope.** An org-unit-scope policy must name its unit, and other scopes must not.
- **Defaults.** Gates default to enabled in enforce mode, and a service refuses to start when a gate is on without a limits client.

Not gated, by design: allocation of an incoming payment already received, because rejecting money that has arrived would strand it. The `STAWI_CONTRIBUTION` and `STAWI_PAYOUT` actions are unused. Stawi contributions arrive as payment allocations, and its outgoing movements execute as transfer orders, which are now gated.

## 12. Addendum 2026-10-24 — field-agent scope in loans

Finding: the loans service treated every non-staff caller as a borrower. A
field agent (platform role `member`) could not read or act on the loans of
the clients they serve, and the member role lacked `loan_request_submit`,
`repayment_manage` and `collection_manage`. Worse, loan account, loan
request, penalty and restructure searches and the active-schedule read
applied no caller scope at all, so any `member` could list every loan in the
partition, and `InitiateCollection` had no ownership check, so a caller could
send payment prompts to any phone number against any loan.

Fix:

- Field service `ClientAccessScope` (gated on `client_view`, which every peer
  service account already holds): returns the profile's own client, its
  workforce member and the clients its teams own or it has a relationship
  with. Only internal callers may name another profile.
- `ClientSearchRequest.profile_id` is now an exact filter in identity.
- Loans `ReadScope` resolves the caller through `ClientAccessScope` (cached
  30 s per tenancy and profile). Borrowers act on their own client, agents on
  their served clients, staff partition-wide. Every search is AND-ed with the
  caller's client set; penalty and restructure searches without a loan, and
  repayment searches without a loan or the caller's own `collected_by`, are
  staff-only. The schedule read is scoped through the loan.
- `RepaymentRecord` and `InitiateCollection` require staff, the payment rail
  or the serving agent (`AuthorizeAgent`); a borrower cannot mark their own
  loan paid or raise prompts.
- `LoanRequestSave` is gated on `loan_request_submit`. A non-staff caller's
  `agent_id` is stamped from their workforce member (empty for a borrower).
- Proto: `RepaymentObject.collected_by`, `RepaymentSearchRequest.collected_by`
  / `received_after` / `received_before` (agent collections-today report),
  `LoanRequestObject.submitted_by` / `decided_by`,
  `InitiateCollectionRequest.collection_amount` wired with a currency check.
- OPL: member gains `loan_request_submit`, `repayment_manage`,
  `collection_manage` on `service_loans`.

Deliberately not done: the deprecated Agent RPCs stay in the proto (they fail
closed with `Gone`) because removing them breaks published Dart SDK clients;
`WorkforceMemberSelf` is unnecessary because `ClientAccessScope` returns the
caller's member id for `WorkforceMemberGet`.

## 13. Addendum 2026-10-24 — money leaving the platform

Findings:

- Savings withdrawals posted the ledger leg with a transfer type whose
  operations handler only logs. The member's balance dropped and nothing
  was paid.
- Loan disbursements named the client id as the payout recipient, and
  operations sent it to the rail as a profile id. The destination phone
  never reached the rail.
- A payout the rail rejected left its ledger leg posted. The loan or
  savings account looked paid out with no money sent and no reversal.
- A written-off loan's principal was expensed but never absorbed by the
  funding tranches, so investor balances never carried the loss.

Fixes:

- Operations resolves every payout recipient before the ledger leg posts:
  `recipient_profile_id`, else the profile of `recipient_client_id`
  (through the field service), else the legacy id. `payment_account_ref`
  must be one of that profile's live contacts (shared rule in
  `pkg/payout`) and is sent to the rail as the contact detail.
- A rail rejection automatically posts a mirrored
  `DISBURSEMENT_REVERSAL` order (`payout-reversal:<reference>`) and closes
  the original order.
- Savings withdrawals are `DISBURSEMENT` orders addressed to the owner's
  client with the withdrawal's recipient reference as destination. A
  permanent rejection rejects the withdrawal and releases the hold. Group
  accounts are refused for rail payouts.
- Loans disbursements send `recipient_client_id`.
- Write-off calls funding `AbsorbLoss` for the outstanding principal after
  the bad-debt posting. Funding absorbs once per loan.

## 14. Addendum 2026-10-24 — individual borrower mobile money

Incoming payments were only matched to group memberships, so an individual
borrower's mobile-money repayment always ended up unidentified. Payments
with no group are now matched first to a loan: by the loan account id quoted
as the payment reference, else by the payer's phone through profile and
client to the client's single repayable loan (two or more loans without a
reference are not guessed). Allocation writes one `LOAN_REPAYMENT` order,
external cash of the loan's product to the borrower's loans account, keyed
`payment:<id>:loan:<loan>`; its side effect records the repayment with loans
on the `mobile_money` channel. Operations needs `loan_view` on
`service_loans` (service-authentication migration).

## 15. Addendum 2026-10-24 — contacts by id only

Rule: fintech identifies people by profile id. Where a specific phone or
email is needed it names the profile contact by its contact id. A raw phone
or email is only ever passed to the profile service, to find or create a
profile, and is never stored, validated, compared or logged in fintech.

- Payout destinations (`LoanAccount.payment_account_ref`, seed/stawi offers,
  savings `recipient_reference`, operations `payment_account_ref`) are
  contact ids. They must be an active, verified mobile contact of the
  recipient's own profile (`pkg/payout.PayableContact`). The rail receives
  `ContactLink{profile_id, contact_id}`.
- Collections take `contact_id`; `phone_number` is deprecated and refused.
- Identity no longer stores the client's phone, validates it, or runs
  phone-change cases; contacts are changed on the profile. Migration 005
  drops stored phones from clients with a profile. Organization contacts are
  deduplicated by the profile service and dropped from the row once synced.
- Incoming payments match the payer as a profile id first; only otherwise is
  the payer reference handed to the profile service to resolve.

Follow-up for clients: loans written before this carry a phone in
`payment_account_ref` and will be refused at disbursement until it is reset
to the contact id. The loans UI collection dialog must pick a contact from
the borrower's profile instead of typing a number.

## 16. Addendum 2026-10-24 — loans→seed hook and stawi offer answers

- Seed serves `LoanPaidOffNotify` over Connect; loans calls it from the call
  that won the PAID_OFF claim when `SEED_SERVICE_URI` is set. Seed completes
  each loan request once (conditional claim) and credits the profile.
- Stawi exposes `POST /api/v1/groups/{group_id}/loan-offers/{offer_id}/respond`
  (`stawi_loan_offer_respond`, held by members). A member answers only their
  own offer in its own group; owner, admin, operator and services answer any.
- `make opl-generate` builds the seed and stawi workspaces too; their OPL
  had silently stopped regenerating when they became separate workspaces.

## 17. Addendum 2026-10-24 — chart of accounts

The ledger refuses postings to accounts it does not hold, and nothing in
fintech created the named accounts (`member:<id>:loans`,
`agent:<id>:cash_in_hand`, `product:<id>:external_cash`, ...). Every such
name is now on a chart (`pkg/constants/chart.go`) that maps it to a ledger
of the right category. When the ledger reports an account missing,
operations creates the order's chart accounts (and their ledgers) and posts
once more. Names not on the chart land in `fintech_unclassified` with a
warning; a test keeps every account constructor on the chart.

## 18. Addendum 2026-10-24 — field agent app

- Phones get a bottom bar (Home, Clients, Loans, Collections for agents who
  record repayments); the drawer keeps everything else.
- Loan statement tab; "My collections today" (a loan-less repayment search
  by a field agent is their own collections); "My portfolio" enabled from
  the agent's member id via `ClientAccessScope`.
- Offline outbox for repayments: queued on network failure with the
  original idempotency key, replayed on resume or on demand, kept in device
  storage; refusals are shown at once. Registrations: see §20.
- Approval queue and maker/checker were already in place (pending filter;
  the server refuses a decider who submitted, created or brought in the
  request).

## 19. Addendum 2026-10-25 — repayment redistribution

Investor interest was split with a fixed two-decimal precision (wrong for
UGX or three-decimal currencies), the net, fee and tax legs were rounded
separately (they need not sum to the share), and a replayed side effect
wrote new orders and moved tranche counters and investor balances again.
Fee and tax now use the currency's decimals, the net leg is the share less
fee and tax, and redistribution orders are written synchronously keyed on
their reference; tranche and balance updates run only when the order was
newly written.

## 20. Addendum 2026-10-25 — offline registration

An agent can capture a borrower's full registration without a connection:
name, the phone used to find or create their profile, national ID, date of
birth, residential address, occupation and any other named detail. It is
stored in the device's encrypted outbox before anything is sent and sent on
resume or "Sync now". The client is registered first; each detail is then
saved as a COLLECTED KYC entry and leaves the outbox once saved, so a replay
never resends one.

No server change: identity already answers a repeated registration of the
same person with the existing client (`CreateIfAbsent` on the profile, and
`requireConsent` passes a person who is already a client), and KYC entries
are saved per field key.

Consent is no longer asked for at registration; see §21.

The phone stays on the device only until the registration reaches identity.

## 21. Addendum 2026-10-25 — consent at activation

Asking for the consent code at registration made onboarding brittle: it
needed the person and a connection at the moment of capture. Registration
now asks nobody for anything. Every new client starts CREATED, whatever the
payload says. It becomes ACTIVE only by activation:

- the KYC its organization requires is VERIFIED (see §22);
- a field agent then gets a code sent to the client's consent contact and
  resubmits with it (15-minute TTL, five attempts, bound to the profile and
  the agent). Staff activate without a code.

The consent contact is recorded at registration (`clients.consent_contact_id`):
an existing person's verified mobile contact, or the contact a new profile
was created with. A correct code also verifies that contact on the profile,
so a new borrower's phone becomes a payable destination by being activated.
An existing person with no verified mobile contact is activated by staff.

Until activation a field agent does not see the client's profile id, so
typing a phone number does not reveal an existing person's profile. An
agent can no longer change a client's state by an edit.

Loans approves a loan request only for an ACTIVE client
(`ClientStandingChecker`, `ErrClientNotActive`; failing to reach identity
refuses rather than approves). Applications can be drafted and submitted
before activation.

Migration 006 marks every stored CREATED client ACTIVE: before this change
a stored client had either passed consent at registration or been registered
by staff.

## 22. Addendum 2026-10-25 — KYC requirements per organization

KYC requirements were one list for the whole seed service
(`SEED_KYC_REQUIRED_FIELDS`). Each organization now sets its own, as the
required fields of its newest published client form template (`entity_type`
"client"). An organization without one uses its nearest ancestor's; with
none anywhere, its clients cannot be activated (`ErrClientKYCNotConfigured`)
until it publishes one. The same template is the onboarding form the agent
fills in, so what is captured and what is required cannot drift apart; the
app caches it for offline onboarding.

`IdentityService.ClientKYCRequirements` returns the template and, for a
client, the status of each required field. Activation requires every one
VERIFIED. Seed no longer checks fields itself: a client may borrow when
identity has activated them, so `SEED_KYC_REQUIRED_FIELDS` is gone.

Found on the way: KYC data was not scoped to the caller. Any member could
list any client's entries, and field agents (members) lacked
`client_data_manage`, so the details captured at onboarding were refused on
sync. KYC reads, writes, reviews and history are now allowed only for staff
and the agents serving the client, and members hold `client_data_manage`.

## 23. Addendum 2026-10-25 — money flow gaps and scheduled work

Tracing every flow end to end found money that never moved and work that
never ran. Fixed:

- **Funders were never paid.** Operations shared repayments out by reading
  the funding tables from its own database, where they do not exist (each
  service has its own database), so nothing was ever redistributed. Funding
  now owns it: `FundingService.LoanRepaymentApply` writes one distribution per
  repayment (unique reference) and moves tranche counters and investor
  balances in the same transaction, then posts the interest legs (funder's
  net share and withholding tax out of the product's income; the platform
  fee is income it keeps). Principal posts nothing: a funder's capital claim
  did not shrink when the loan went out. Loans calls it after each repayment
  and marks the repayment settled; the settlement job finishes any that did
  not complete. Repayments recorded before this are shared retroactively.
- **Write-off could not happen.** It is now a restructure of type WRITE_OFF on
  a DEFAULT loan, approved by someone other than its requester. It posts the
  principal still on the loan asset and the unpaid penalties to bad debt
  (interest and fees were never booked, so need no reversal), has the funders
  absorb the principal first-loss first (only what each tranche still has
  lent out) and move their share of the expense onto their capital, then
  closes the loan.
- **Restructures had no maker/checker** and were decided by unconditional
  writes. Every decision is now a conditional claim; the requester cannot
  approve.
- **Disbursement credited a contact id**, not a ledger account. It credits the
  product's external cash; the contact stays the payout destination.
- **Concurrent repayments on one loan could double-allocate**, and
  installments were persisted through asynchronous events with absolute
  values. Repayments on a loan now run one at a time under a lease; the
  allocation is stored with the repayment, the ledger is posted, and the
  installments, balance and an `applied_at` mark move in one transaction.
  A retry with the same key resumes from wherever it stopped.
- **Seed loans were priced at the product rate** and seed's own approval was
  refused as self-approval. The tier rate reaches loans; an internal product
  service deciding by its own credit policy is not self-approval. A field
  agent or borrower can no longer set a loan's rate.
- **Lapsed offers never expired.** Submitted or approved requests past their
  offer deadline now expire and the borrower is told.

**Scheduled work runs only through trustage.** The delinquency scan and due
reminders were in-process tickers on a service that scales to zero, so they
ran only while a request happened to be in flight. They, funder settlement
and offer expiry are now `LoanJobRun` batches that trustage calls on the
schedules in `products/loans/workflows`, registered by the loans setup Job.
Each job claims its items in the database (`FOR UPDATE SKIP LOCKED` on
partial indexes), so any number of runs and replicas share the work and the
cost of a run follows what is due, not the size of the book: a loan is
assessed once a day, each reminder is claimed once, each repayment settled
once.

Found and queued: four of the five stawi workflow definitions fail trustage's
current DSL validation and so were never registered (`return`/`noop` step
types, missing `signal_name`, `foreach.items`); stawi embeds a second funding
allocation in its own database; limits' reapers and savings' interest accrual
still run in-process.

## 24. Addendum 2026-10-25 — loan terms and KYC review stages

Loan products could name terms the schedule could not produce:

- **Compound interest** was accepted on a product and billed as flat. It now
  grows on the principal once per period over the term,
  `P × ((1 + r/n)^k − 1)`, worked at 34 significant digits and collected in
  equal parts.
- **Daily and quarterly repayment** were refused when the schedule was
  generated. Both are supported now (365 and 4 periods a year).
- **Monthly due dates drifted.** Each installment was the previous one plus a
  month, so a loan due on 31 January was next due on 3 March and stayed on
  the 3rd. Due dates are now counted from the first one and held to the last
  day of a shorter month: 31 Jan, 28 Feb, 31 Mar.
- **The grace period was stored and ignored.** A product's
  `grace_period_days` now defers the late penalty by that many days after the
  due date. Days past due, arrears and portfolio at risk still count from the
  due date. It is validated to 0–365 days. The unused
  `DEFAULT_GRACE_PERIOD_DAYS` setting is removed.

KYC entries had two of their six stages in use:

- **Under review.** `ClientDataStartReview` hands an entry that is collected,
  or back with more information, to the calling reviewer. While it is under
  review only that reviewer can verify it, reject it or ask for more; a hold
  untouched for a day can be taken over. The hold is a conditional update, so
  of two reviewers opening the entry at once exactly one gets it. Deciding
  straight from collected still works.
- **Expired.** An entry past its `expires_at` reads as `EXPIRED` the moment
  it expires: on the entry, in status-filtered lists, in the KYC
  requirements that gate activation, and to reviewers, who can no longer
  decide it. Nothing has to restamp the row, so no scheduled job is needed.
  Submitting the document again starts it over at collected. A rejection
  stands even after the date passes.
- A review used to emit an asynchronous full upsert of the entry after its
  conditional write had already landed. That upsert could overwrite a
  resubmission made in between; it is removed.

## 25. Addendum 2026-10-25 — agents never handle borrower money

Rule: a field agent never touches a borrower's money. Repaying is the
borrower's own act, from their own registered contact; the payment rail
matches the inbound payment and applies it to the loan.

What this removed:

- **Agents recording cash.** `ROLE_MEMBER` held `repayment_manage`, and a
  field agent could book a cash repayment that debited an
  `agent:<profile>:cash_in_hand` ledger account "until remitted". That
  account, the cash channel, the collector column (`repayments.collected_by`,
  dropped by migration 0007), the "collection recorded, remit by end of day"
  message, the agent app's Record Payment dialog, its offline repayment
  outbox and the "My collections" screen are gone.
- **Anyone recording by hand.** `RepaymentRecord` now refuses every caller
  but an internal service account (the operations payment rail, which holds
  its grant explicitly), and refuses cash even from the rail. Owners, admins
  and operators lost `repayment_manage` too; a payment that arrived but did
  not match is resolved through operations' suspense and allocation, never by
  typing in an amount.
- A partition-wide repayment search (no loan named) is staff-only; field
  agents read repayments loan by loan, for the clients they serve.

What stays: "Collect Payment" (`InitiateCollection`), with which a field
agent or staff member prompts the borrower to pay from their own contact.

Production had no repayments recorded when this shipped, so no cash entries
or agent cash balances needed unwinding.

## 26. Addendum 2026-10-26 — staff console completeness

Goal: everything a lender's staff must do is reachable from the Seed app.

- **Unmatched payments.** A borrower's payment that matched no loan used to
  stay unresolved with no screen to see it. Operations now has
  `IncomingPaymentSearch` (`payment_view`: owner, admin, operator, viewer) and
  `IncomingPaymentAssign` (`payment_allocate`). Assigning names the loan and a
  note and nothing else: the payment is applied in full, as the rail received
  it, from the product's collection account. The loan must take repayments
  and be of the product the rail credited. The assignment lands only while
  the payment is still unmatched and unallocated, so two people cannot apply
  it twice. It records who assigned it and why. The payer reference the rail
  supplied (often a phone number) is not returned. Seed shows this under
  Payments → Incoming Payments, with a loan search in the assign dialog.
- **Funding and transfers mounted.** Investor accounts (`/funding/accounts`)
  and transfer orders (`/operations/transfers`) are in Seed's navigation.
  Opening accounts, deposits and withdrawals are offered only with
  `investor_account_manage`, and Fund Loan only with `fund_manage`.
- **KYC form templates.** Templates had a list but no way to build one, so no
  organization could publish its client KYC form. Seed now routes
  `/form-templates` and a designer. On the server, Save keeps only drafts:
  a published or archived template is never rewritten (clients filled it
  in), status changes only through Publish, and the version only through
  publishing. A change to a published form is a new draft, and publishing it
  makes it the newest published version, which KYC uses. Save validates the
  template (name, organization, entity type, unique field keys, options for
  choice fields) and refuses phone and email fields, because contacts are
  kept on the profile. Save now writes synchronously, so Publish straight
  after it finds the row.
- **Not mounted: savings.** Savings deposits are recorded by staff typing an
  amount (`DepositRecord`), and no payment-rail path credits a savings
  account. That conflicts with the rule that clients pay from their own
  contact, so savings stays out of Seed until deposits come from the rail.

## 27. Addendum 2026-10-26 — SQL migrations never reached loans and limits

Frame reads the migration directory from `MIGRATION_PATH`. The loans image
set `DATABASE_MIGRATION_PATH`, so its setup Job scanned the default
`./migrations/0001` and applied nothing. The limits image did not carry its
migrations at all. Its files were also named `.up.sql`/`.down.sql`, and Frame
skips only `_down.sql`, so the revert files would have been applied too.

Production consequences until this ships:

- Loans kept the global unique indexes (`uq_lp_code`, `uq_rep_idem`,
  `uq_lr_idempotency`, …) instead of the partition-scoped ones from 0001. A
  product code or idempotency key used by one lender blocked every other
  lender.
- Loans lacked the penalty-per-installment and live-disbursement guards
  (0003, 0004), the job claim indexes (0006), and the collector column drop
  (0007).
- Limits lacked the reservation idempotency unique index and its runtime
  indexes.

Fix: the loans image sets `MIGRATION_PATH`. The limits image ships its
migrations and sets it too. The limits files are renamed `_up`/`_down` and
wrapped in one `DO` block each. `pkg/dbmigrate` now has a test that fails
when an app with migrations does not ship them, or names them so Frame would
misapply them. Every loans and limits up-migration was dry-run against
production in a rolled-back transaction, and all succeed. Identity, funding
and savings had applied theirs; operations, seed and stawi have none.

## 28. Addendum 2026-10-26 — borrower self-service on USSD

A borrower dials the lender's USSD code (Africa's Talking) and gets the Seed
menu from the service-notification USSD engine. Nothing Seed-specific lives
in the engine.

- **Who is calling.** The engine resolves the number to the caller's profile
  and contact. The gateway is accepted only with the service's auth key, since
  the engine acts for whoever the number names.
- **What they see.** When a known caller opens the menu, the engine calls
  Seed's `UssdState` (`seed_ussd_state`, engine service account only). Seed
  answers with the borrower's rows: client, current loan (reference, balance,
  next instalment and due date) and room to borrow. Borrowing needs an active
  client with a PIN, no loan running, and an active credit profile. The call
  goes only to trusted hosts, because it carries the engine's token.
- **What they can do.** Each completed session reaches Seed on its own
  Pub/Sub topic, through the notification service's `ussd` receive route.
  - *Borrow*: amount plus PIN. It runs `RequestLoan` in the borrower's own
    partition, keyed by the session so a redelivery never borrows twice. A
    refusal (over the limit, a loan running, KYC incomplete, account paused)
    is texted back.
  - *Repay*: next instalment, full balance or another amount. Loans
    `InitiateCollection` sends the prompt to the contact the borrower dialled
    from; they approve it with their mobile money PIN. Seed never touches the
    money.
  - *Set or change PIN*: a one-time code from the profile service to that
    contact, then the code and the PIN twice.
- **PINs.**
  - PIN and code prompts are secret menus. The engine seals what is typed
    with Seed's public key before keeping it anywhere, so sessions, the
    notification payload and logs never hold a PIN; only Seed can open it. A
    value that arrives unsealed is refused.
  - Seed keeps an argon2id hash and locks the PIN for an hour after five
    wrong tries.
  - A code is good once, for ten minutes, and only from the contact it was
    sent to. Every session's contact must be a verified mobile contact of
    the caller's own profile.
  - A code alone (the phone) never replaces an existing PIN: Change PIN also
    needs the current PIN. Forgot PIN resets with the code but keeps any lock
    running and blocks borrowing for 24 hours.
  - Every PIN change is texted to the profile.
- **Partition.** `ClientObject` now carries `tenant_id` and `partition_id`.
  Seed acts as its own service account inside the borrower's partition, so
  what USSD creates belongs to the lender.
- **Grants (tenancy).**
  - New account `service_notification_ussd`: `profile_view`,
    `notification_send` and `seed_ussd_state`.
  - Seed gains the `/ussd` and `/notification` audiences, `contact_manage`
    (to send the code) and `notification_send`, and loses `repayment_manage`.

## 29. Addendum 2026-10-26 — savings deposits only from the payment rail

**Finding.** `SavingsService.DepositRecord` accepted a deposit from any
caller holding `deposit_manage`, with any amount and channel, including
`cash`. The savings UI offered staff a "Record deposit" form. That is the
same agent-handled-money path closed for loans in §25.

**Change.**

- savings `DepositRecord` refuses callers that are not internal service
  accounts (`ErrDepositRecordInternalOnly`, PermissionDenied) and refuses the
  `cash` channel (`ErrCashDepositRefused`).
- operations matches an individual's incoming payment to their loan first,
  then to their own savings account: by the account id the payer quoted, or
  by the payer's profile to their one open individual account of the product
  the rail credited (`borrower_savings_routing.go`). Allocation records the
  whole payment as a deposit, keyed `payment:<id>:savings:<acct>`, so a retry
  never deposits twice.
- `IncomingPaymentAssign` takes exactly one of `loan_account_id` or
  `savings_account_id` (proto field 4). Staff say where the money belongs;
  the amount stays the rail's.
- UI: ui_savings 0.3.0 drops Record deposit and gates account actions on
  permissions. Seed mounts the savings routes. ui_operations 0.3.1 assign
  dialog offers Loan or Savings.
- Tenancy (service-authentication `20261026_02`): operations gets the
  `/savings` audience plus `savings_account_view` and `deposit_manage` on
  `service_savings`. Operations also needs `SAVINGS_SERVICE_URI`.

**Verified.** `TestDepositsComeOnlyFromThePaymentRail`; operations
`TestBorrowerSavings*` (deposit recorded once; other product not deposited;
staff assign to savings); ui_operations and ui_savings widget tests.

## 30. Addendum 2026-10-26 — repayments from the rail, end to end

**Finding.** No repayment could reach a loan:

- Nothing fed `IncomingPaymentNotify`.
- `IdentifyPayment` matched a borrower's payment but never allocated it.
- The LOAN_REPAYMENT order an allocation raised stayed JustCreated forever,
  so `RepaymentRecord` was never called.
- A defaulted loan refused payments.
- The limits gate could refuse money that had already arrived.
- Separately, loans `LoanRequestSave` wrote asynchronously, and every
  decision re-emitted the full row after its conditional claim. An approval
  could miss a just-saved request, and a late rewrite could revert
  LOAN_CREATED.

**Change.**

- *Rail feed.* Operations subscribes to the payment service's receive route
  (`OPERATIONS_PAYMENT_RECEIVED_URI`) and books each inbound payment:
  - the transaction id is the rail payment id, so redelivery books once;
  - the payer is named by profile id, and the contact id is kept in
    properties;
  - the product and the loan or savings account come from the prompt's
    extras;
  - booking runs as operations inside the payment's partition.
- *Payment service* (`service-payment` `feat/prompt-success-receives`):
  - a prompt that succeeds is received as an inbound payment with the
    prompt's id and extras, so it is routed like any other receipt;
  - `Receive` keeps the caller's id, transaction id and extras;
  - a replayed inbound save resumes routing.
- *Allocate and post at once.* An individual's matched payment is allocated
  inside `IdentifyPayment`, and the borrower's repayment order is executed
  inline (`WithOrderExecutor`). A failure leaves the allocation standing.
- *Settle job.* `OperationsJobRun(SETTLE_PAYMENTS)`, permission
  `operations_job_run`, is fired by trustage every 5 minutes
  (`products/operations/workflows`, synced by the setup job).
  - It allocates individuals' matched-but-unallocated payments and posts
    borrower repayment orders that were raised but never executed.
  - Each item runs in its own partition.
  - Group obligation orders are left to their workflows.
- *Repayable statuses.* DEFAULT now takes repayments in loans and in
  operations matching. A full repayment moves the loan to PAID_OFF, which
  the transition table already allowed.
- *Limits.* Limits gate money leaving, never money received. The gate is
  removed from loans repayments and savings deposits
  (`LIMITS_GATE_*_LOAN_REPAYMENT` and `*_SAVINGS_DEPOSIT` are gone).
  Operations skips it for payment-allocation orders.
- *Loans.* `LoanRequestSave` upserts synchronously. Approve, reject and
  cancel no longer re-emit the row after their claim.

**Deploy needs.**

- A receive route in the payment service publishing to the operations
  topic.
- Tenancy: trustage → `service_operations` `operations_job_run`, plus the
  `/operations` audience; operations → `/trustage` with workflow_manage and
  workflow_view.
- `TRUSTAGE_SERVICE_URI` on operations.

**Verified.** Operations tests cover:

- `TestMatchedBorrowerPaymentIsPostedAtOnce`
- `TestBorrowerPaymentStaysAllocatedWhenPostingFails`
- `TestSettleJob*`
- `TestDefaultedLoanTakesTheBorrowersPayment`
- `TestTransferOrderExecute_ReceivedMoneyIsNotGated`
- `TestReceivedPayment*`
- repository `TestSettleListingsFindOnlyUnfinishedIndividualWork` (Postgres)

Loans tests cover `TestSave_WritesTheRequestBeforeReturning`,
`TestRepayableStatuses` and `TestRecord_AppliesReceivedMoneyWithoutALimitsCheck`.
Payment covers `TestPaymentFromPrompt*`.

## 31. Addendum 2026-10-26 — collection prompts and paid-off notices

**Findings.**

- `InitiateCollection` only sent an SMS. Nothing asked the borrower's mobile
  money to pay, so a collections officer could not collect.
- A paid-off notice to seed that failed was logged and dropped, which left a
  repaid borrower blocked from borrowing again.

**Change.**

- *Collection prompts.* `InitiateCollection` raises
  `PaymentService.InitiatePrompt` on the borrower's own verified mobile
  number: the contact named by id, or their first payable contact.
  - The prompt id is derived from the loan and idempotency key.
  - Extras carry `product_id` and `loan_account_id`, so the money that
    answers the prompt is matched to the loan by operations (§30).
  - Without a payment client, prompts are refused (`ErrCollectionPromptUnavailable`).
  - The SMS still goes out.
- *Payment service.*
  - Resolves the contact id to the number only when it publishes to the
    provider.
  - Refuses a contact that is not on the payer's profile.
  - Does not push a second time for a prompt id it already holds.
- *Paid-off notices.* The pay-off notice records `paid_off_noticed_at` when
  seed acknowledges it. `LoanJobRun(PAID_OFF_NOTICES)`, fired by trustage
  every 10 minutes, re-notices paid-off loans that lack it. It leases each
  loan for 10 minutes and skips pay-offs from the last 2 minutes.
  Migration `0008_paid_off_notices`.
- *Tenancy.* service-authentication `20261026_04`: loans → `/payment`
  `prompt_initiate`.

**Verified.**

- `TestCollectionInitiate_RaisesAPromptOnTheBorrowersOwnContact`
- `TestCollectionInitiate_RefusedWithoutPaymentPrompts`
- `TestPaidOffNoticeThatFailedIsRetriedUntilAcknowledged`
- repository `TestPaidOffNoticesAreClaimedUntilNoticed` (Postgres)
- payment `TestPayerNumber*`

## 32. Addendum 2026-10-26 — staff origination and rail-only payment notices

**Findings.**

- Staff origination stopped at APPROVED. The console could not open the
  loan account. It had no way to confirm KYC data. Its disburse dialog asked
  for a free-text channel and "recipient reference / rail transaction code".
- `IncomingPaymentNotify` was granted to OPERATOR, so staff could announce a
  payment that the rail would then apply to a loan. The notified properties
  could also pre-set allocation fields such as `remaining_amount` and
  `client_id`.

**Change.**

- *Request detail.* A submitted request has a "Client data verified"
  toggle, which saves `data_verification_confirmed`. An approved request has
  "Open loan account" (`loan_manage`), which opens the account and goes to
  it.
- *Disbursement.* The disburse dialog is a confirmation. The principal goes
  to the loan's payout contact, and a loan without one cannot be disbursed.
- *Payout contact.* A loan opened from a request that named none takes the
  borrower's first verified mobile number, by contact id.
- *Notify.* `IncomingPaymentNotify` accepts internal service accounts only
  (`ErrPaymentNotifyInternalOnly`). Notified and rail-received properties
  never carry the fields identification, allocation and assignment decide.
  The rail consumer keeps only `prompt_id` and `purpose` from the extras.

**Verified.**

- operations `TestIncomingPaymentNotifyIsTheRailsAlone`,
  `TestNotifiedPropertiesCannotPreDecideThePayment`
- loans `TestLoanAccountDefaultsItsPayoutContact`
- ui_loans 0.4.0 widget tests (48 pass)

## 33. Addendum 2026-10-26 — onboarding fixes

- *Owning team.* Staff client creation failed with `ErrOwningTeamRequired`
  because the onboarding form never offered a team. `ClientFormDialog` now
  offers the teams, with "My team" leaving it to the service for field
  agents. The offline outbox keeps the choice.
- *Owner role.* The partition owner was treated as a field agent and
  scoped. `owner` now counts as staff, in identity `callerIsStaff` and in
  loans `defaultStaffRoles`.
- *KYC review gating.* Verify, reject and take-for-review were offered on
  `client_manage`. They now need `client_data_verify`, the permission the
  service checks. The seed manifest registers it.
- *Phone at registration (kept as designed).* The registration still
  carries the number to identity, which only relays it to the profile
  service: a field agent's client is bound to the profile the number
  resolves to, and an agent-supplied profile id is ignored. Resolving the
  profile on the device would let an agent bind a client to any profile.
- *Open: KYC documents.* Photo, file, signature and location fields are not
  captured. Media uploaded through the files service is private to the
  uploader, and reviewers get access only through per-file grants. Capture
  needs the files service to share KYC media with the partition's reviewers
  first; otherwise a reviewer would verify a document they cannot open.
