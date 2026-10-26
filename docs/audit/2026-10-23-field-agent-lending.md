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

## 34. Addendum 2026-10-26 — limits reapers on trustage

**Finding.** The limits service expired reservations and approvals from two
goroutines on a 30-second in-process ticker (`runPeriodically`). That broke
the trustage-only scheduling rule and tied reaping to replica lifetimes.

**Change.**

- The tickers are gone. `LimitsAdminService.LimitsJobRun(job)` runs one pass
  of `RESERVATION_EXPIRY` or `APPROVAL_EXPIRY` under the existing advisory
  lock, for internal service accounts only.
- The permission is `limits_job_run`, bound to no role.
- Two trustage workflows fire every minute (`products/limits/workflows`).
  The limits setup job syncs them, and the image ships them at `/workflows`.
- Tenancy (service-authentication `20261026_05`): limits → trustage
  (workflow_manage, workflow_view); trustage → `service_limits`
  `limits_job_run`.

**Verified.** `TestLimitsJobsRunTheNamedReaperForInternalCallersOnly`. The
full limits suite passes, including integration tests. Workflows pass
`TestShippedWorkflowsValidate`.

## 35. Addendum 2026-10-26 — terms accepted once, at onboarding

**Decision (product owner, 2026-10-26).** "Borrowers need to accept terms
only during the onboarding phase. After that process it should be very
instantaneous." There is no per-loan offer acceptance; audit gap #11 is
closed by this decision.

**Change.**

- When a field agent activates a client, the borrower is first sent the
  lender's terms (`template.fintech.client.terms_offered`, `LENDER_TERMS_URL`
  on identity). The message tells them that giving the activation code
  means accepting the terms for every loan after.
- A successful activation records `terms_accepted_at` and `terms_accepted`
  (the terms reference) on the client. Only activation writes them; values
  sent by a caller are dropped.
- Loans after activation need nothing more from the borrower: the USSD
  borrow PIN authenticates the borrower but is not an acceptance step.
- Acceptance holds for everyone (product owner, 2026-10-26). Staff now
  activate with the person's code too. Only whoever asked for a code can
  redeem it: a field agent's workforce member, or the staff member
  themselves. The console's activation already prompted for the code, so it
  needed no change.

**Verified.** `TestActivationNeedsVerifiedKYCAndConsent` covers recorded
acceptance, a forged timestamp being dropped, staff waiting for the code and
recording acceptance, and an agent being unable to redeem a staff member's
code.

## 36. Addendum 2026-10-26 — cancelling an undisbursed loan releases its funding

**Finding.** Funding is reserved when a loan account opens (`FundLoan`). A
loan that was never disbursed could not be cancelled: PENDING_DISBURSEMENT
led only to ACTIVE or RESTRUCTURED. Its investors' capital therefore stayed
reserved forever, for example when the borrower's number was refused by the
rail.

**Change.**

- `LoanManagementService.LoanAccountCancel(id, reason)` (`loan_manage`)
  moves PENDING_DISBURSEMENT to CLOSED, then calls
  `FundingService.FundingRelease`.
  - It refuses while a disbursement is processing or completed. Failed
    disbursements, refused by the rail, do not block it.
  - Calling it again on a loan this closed retries the release.
- *Race with a starting disbursement.*
  - A disbursement re-reads the loan after claiming its row and abandons the
    row if the loan was closed.
  - A cancel re-checks after closing, and reopens the loan if a disbursement
    slipped in.
- *Funding.* `FundingRelease` is internal-only. Each active funding record is
  voided by a conditional write before its investor reservation is returned,
  so a reservation is released once however often it is called. The
  allocation lock is then dropped.
- *UI.* ui_loans offers "Cancel loan" on undisbursed loans and Collect
  Payment on defaulted ones.

**Verified.** funding `TestReleaseGivesBackReservedCapitalOnce` (Postgres);
loans `TestCancel*`; ui_loans tests (52 pass).

## 37. Addendum 2026-10-26 — investor capital arrives from the rail

**Finding.**

- Staff with `investor_account_manage` typed an investor deposit amount, and
  it was credited to the fund without any money arriving.
- The funding UI's Fund Loan dialog implied it drew on one investor's
  account, but `FundLoanRequest` has no account: allocation draws on the
  whole pool, and loans already calls it when an account opens.
- Separately, operations persisted a payment's identification through an
  async event, so the inline allocation could read the payment as still
  unmatched.

**Change.**

- *Deposits.* `InvestorDeposit` is internal-only and honours the body's
  `idempotency_key` when no header is sent. Deposits are no longer gated by
  limits (money received).
- *Matching.* Operations matches a payment quoting an investor account id,
  but only when the payer is that investor's own profile. Payer by profile id
  from the rail; by contact, resolved by the profile service, from a
  notifier. Capital is never credited on a reference alone.
  - The whole payment is deposited, keyed `payment:<id>:investor:<acct>`.
  - Matching order: loan, then savings, then investor account.
  - The settle job covers these payments too.
- *Identification* is persisted synchronously with the conditional
  `AssignOwner` (unowned, unleased payments only), so the allocation that
  follows always reads the owner.
- *ui_funding 0.5.0.* Deposit and Fund Loan are removed. The account screen
  says how capital arrives: the investor pays, quoting the account id.
- *Tenancy* (service-authentication `20261026_06`): operations → `/funding`
  with `investor_account_view` and `investor_account_manage`. Operations
  needs `FUNDING_SERVICE_URI`.
- *Open.* Investor withdrawals post a ledger movement but nothing pays the
  investor.

**Verified.** operations `TestInvestorsOwnPaymentBecomesCapitalOnce`,
`TestQuotingAnInvestorAccountFromAnotherProfileCreditsNothing`; funding
suite; ui_funding tests.

## 38. Addendum 2026-10-26 — investor withdrawals are paid out

**Finding.** An investor withdrawal debited the account and posted
`INVESTOR_PRINCIPAL_RETURN` (investor capital → platform external cash), an
order type with no payout. Nothing ever paid the investor.

**Change.**

- New transfer type `INVESTOR_WITHDRAWAL` (49), a payout order type in
  operations. Like a disbursement, the recipient and destination are checked
  before the ledger posts, the payment goes to the rail, and a payout the
  rail rejects is reversed.
- Funding resolves the investor's own payout destination before debiting
  anything: the profile from identity and its first verified mobile contact,
  by id (`InvestorPayoutResolver`). It names them on the order. Without a
  resolver or a contact, the withdrawal is refused and nothing moves.
- A failed transfer returns the investor's funds only when operations
  refused it outright (invalid argument, failed precondition, not found or
  permission denied), meaning nothing moved. A timeout or a payout awaiting
  confirmation keeps the movement debited, so those funds cannot be
  withdrawn again. Retrying the same key resumes the same order.
- The withdrawal limits gate stays, because this money is leaving.
- ui_funding: Withdraw says where the money goes.
- No new grants: funding already holds `investor_view` and `profile_view`.

**Verified.** funding `TestWithdrawIsIdempotentAndGuardsTheBalance` (the
order is a payout to the investor's contact) and
`TestWithdrawWithoutAPayoutContactMovesNothing`,
`TestWithdrawKeepsFundsDebitedUntilThePayoutIsKnown`; operations
`TestPayout_InvestorWithdrawalGoesToTheInvestorsOwnContact`.

## 39. Addendum 2026-10-26 — recoveries on written-off loans

**Decision (product owner, 2026-10-26).** Money a borrower pays after a
write-off goes back to the funders who absorbed the loss, most senior tranche
first: the reverse of the order the loss was charged in. Anything beyond the
loss they still carry is the lender's recovery income.

**Finding.** A written-off loan refused payments. A borrower who paid had
their money sit unmatched, and the funders' realised loss could never be
reduced.

**Change.**

- *Loans.* WRITTEN_OFF is repayable, in loans and in operations matching.
  Allocation is unchanged: the loan's balance still records what is owed.
  - The recovered principal and penalties are credited to the product's
    bad-debt expense, reversing the write-off. They are not credited to the
    loan asset and penalty receivable, because the write-off already cleared
    those.
  - Recovered interest and fees are income.
  - A fully recovered loan moves to CLOSED. It is not a pay-off, so no
    paid-off notice restores the borrower's standing.
- *Settlement.* Funding settlement calls `FundingService.LoanRecoveryApply`
  with the principal for a written-off loan. It does not use the repayment
  share. It runs through the same settlement job, so it is retried.
- *Funding.*
  - `LoanRecoveryApply` (internal only) walks the loss's absorbed shares from
    the most senior tranche down.
  - Each tranche gets back what it lost and has not yet recovered
    (`funding_tranches.loss_recovered`).
  - Investors' available capital rises and `total_lost` falls, in one
    transaction with the `loss_recoveries` row, which is unique per
    reference.
  - The ledger posts bad-debt expense → investor capital, or → platform
    first-loss reserve.
  - Migration `20261026_loss_recovery`.
- *UI.* ui_loans offers Collect Payment on written-off loans.

**Verified.**

- funding `TestRecoveryReturnsTheLossSeniorFirstOnce` (Postgres): senior
  first, then first-loss, the excess not returned, a repeat moves nothing.
- loans `TestRecoveryOnAWrittenOffLoanReversesTheBadDebt`,
  `TestRecoveredPrincipalGoesBackToTheFunders`, `TestRepayableStatuses`.

## 40. Addendum 2026-10-26 — temporary borrowing caps

**Design (2026-10-25 redesign, step 3).** The product credit profile (the
tier ladder) is the permanent limit. The serving agent may set a temporary
lower cap with an expiry, and the effective limit is the lower of the two.

**Change.**

- *Seed credit profile.* New fields `temp_cap_amount`,
  `temp_cap_expires_at`, `temp_cap_set_by` and `temp_cap_reason`.
  `EffectiveLimit(now)` returns the tier limit, lowered by an unexpired cap.
- *Enforcement.* Borrowing in the app and by USSD is checked against the
  effective limit, and USSD shows the effective limit.
- *Setting a cap.*
  `POST /api/v1/seed/credit-profiles/{client}/{currency}/cap` and
  `/cap/clear` (`seed_credit_profile_cap`, bound to member, operator, admin,
  owner and service).
  - A cap must be below the tier limit, expire within 90 days and give a
    reason. It never raises a limit.
  - Staff may cap any client. A field agent may cap only a client they serve,
    checked through field `ClientAccessScope`.
  - Each change is audited with the actor and reason.
  - An active cap can be loosened only by staff: lifted, raised or ended
    sooner. A field agent may tighten it, or lift a cap they set themselves.
  - Tightening does not take a cap over. It keeps whoever set it, so an
    agent cannot tighten a staff cap and then lift it as their own.
  - The write applies only to the profile version that was checked. A
    concurrent change returns Conflict (`ErrTempCapRaced`) and the caller
    retries against the new state.
- *UI.* Seed's Lending tab shows "Can borrow up to" as the effective limit,
  plus the active cap with its expiry and reason. With the permit, it offers
  "Set temporary cap" (amount, 7–90 days, reason) and "Lift cap".
- No new grants: seed already holds `client_view` on field.

**Verified.** seed `TestTemporaryCapOnlyLowersTheLimitUntilItLapses`,
`TestTemporaryCapIsSetOnlyByStaffOrTheServingAgent`,
`TestTemporaryCapRefusesAProfileChangedSinceTheCheck`, the manifest route
tests, and the ui/seed Lending tab tests (64 pass).

## 41. Addendum 2026-10-26 — product commission to the serving team

**Design (2026-10-25 redesign, step 4).** Each loan product sets a
commission as a percentage of interest. On each repayment, the field team
serving the borrower earns that share of the interest repaid. It is the
product's cost; the borrower pays nothing more, and no agent handles money.

**Change.**

- *Product.* `LoanProductObject.agent_commission_percent` (field 24) is held
  in basis points (`agent_commission_percent`, 0–10 000).
- *Ledger.* New accounts `product:<id>:commission_expense` (expense) and
  `team:<id>:commission_payable` (payable), and order type
  `AGENT_COMMISSION` (50). Operations records it as an accrual only.
- *Posting.* `FundingSettlement.Settle` calls `AgentCommission.Post` before
  sharing the repayment with funders:
  - The amount is interest repaid × rate, credited to the client's owning
    team, read from field `ClientGet`.
  - The reference is `commission:<repayment id>`, so a retried settlement
    posts it once.
  - Nothing is owed on a recovery, a repayment without interest, a product
    without a rate, or a client no team serves.
  - A transient failure leaves the repayment unsettled for retry. A
    permanent refusal (InvalidArgument, FailedPrecondition, NotFound) is
    logged and dropped, so it never holds back the funders' share.
- *UI.* ui/loans product form "Agent commission (% of interest)" and a
  detail row.
- *SDKs.* Dart loans 0.6.4, operations 0.4.5.
- No new grants: loans already executes transfer orders on operations and
  reads clients on field.

**Open.** Paying the team's payable out (a team payout order type) is not
built. The accrual is visible on the ledger until it is.

**Verified.** loans `TestCommissionIsTheTeamsShareOfRepaidInterest`,
`TestNoCommissionWithoutARateATeamInterestOrOnARecovery`,
`TestCommissionRefusalDoesNotBlockSettlement`; ui/loans 52 tests.

## 42. Addendum 2026-10-26 — team commission is paid out

**Gap closed.** In §41, commission built up on the team's ledger payable but
was never paid out.

**Change.**

- *Balances (loans).* New tables `team_commissions` (team, currency,
  accrued, paid_out) and `team_commission_movements` (one row per accrual or
  payout, unique on partition and reference; migration `0009`).
  - An accrual is recorded after its ledger order posts, keyed
    `commission:<repayment id>`. A retried settlement counts it once (insert
    `ON CONFLICT DO NOTHING`, then an upsert of the balance in the same
    transaction).
- *Payout.* `TeamCommissionPayout` (`commission_payout`, owner and admin):
  - The recipient must be an active member of the team (identity
    `TeamMembershipSearch`). The money goes to that member's own default
    payout contact (`WorkforceMemberGet` → profile → contact id). Nobody
    names a number.
  - The movement row, keyed `team-payout:<idempotency key>`, is the
    idempotency record. A replay with different terms returns Conflict.
  - The balance is taken in the transaction that moves the payout from
    PENDING to PROCESSING, guarded by `accrued - paid_out >= amount`.
    Concurrent payouts cannot overdraw.
  - An operations `TEAM_COMMISSION_PAYOUT` (53) payout order moves the
    money from the team's payable to external cash. Operations checks the
    recipient and destination before posting, and reverses a rail
    rejection.
  - A refusal (InvalidArgument, FailedPrecondition, NotFound,
    PermissionDenied) returns the amount to the balance and the payout to
    PENDING, with its reason. Any other failure keeps it taken; retrying
    the same key resumes the same order and never pays twice.
- *Reads.* `TeamCommissionSearch` and `TeamCommissionPayoutSearch`
  (`commission_view`: owner, admin, operator, viewer).
- *UI.* Seed's team page shows `TeamCommissionSection` (ui/loans) through
  `TeamDetailScreen(sections:)` (ui/identity): balances, payouts, and "Pay
  out" to an active member. The dialog keeps one idempotency key while open
  and shows a failure in place, so a retry is safe.
- *SDKs.* Dart loans 0.6.5, operations 0.4.6.
- No new grants: loans already holds identity (`team_membership_view`,
  `workforce_member_view`), profile and operations; operations already pays
  out through payment.

**Verified.**
- Postgres: loans `TestCommissionAccruesOncePerReference` and
  `TestCommissionPayoutsNeverOverdraw` (five concurrent payouts of 400 against
  1 000: exactly two succeed).
- Business: `TestCommissionPayoutPaysTheMembersOwnContactOnce`,
  `TestCommissionPayoutNeedsAPayableMember`,
  `TestCommissionPayoutRefusedGoesBackUnknownStaysTaken`,
  `TestCommissionAccruesToTheTeamsBalance`.
- UI: ui/loans (58 tests), ui/identity (52) and ui/seed (64) pass.

## 43. Addendum 2026-10-26 — investor statements, and investors read only their own accounts

**Gaps closed.**

1. *No statement.* Nothing reported what moved an investor's capital over a
   period.
2. *Unscoped reads.* Funding binds `investor_account_view` to `ROLE_MEMBER`,
   and `InvestorAccountGet` and `InvestorAccountSearch` were not scoped. Any
   member of the partition (a borrower or a field agent) could read every
   investor's account and balances.

**Change.**

- *Statement.* `FundingService.InvestorStatement` (`investor_account_view`)
  covers a period of at most 366 days (`from` inclusive, `to` exclusive). It
  is built from the records that already move capital:
  - Settled deposits and withdrawals. A withdrawal whose payout is still
    unconfirmed is shown as pending.
  - Tranches funded (deployment) and released (a loan cancelled before
    disbursement).
  - Each repayment distribution's share for the account: principal, and
    interest net of the platform fee and withholding tax, which are shown
    alongside.
  - Shares of loss absorptions and recoveries.

  Entries are ordered oldest first, with totals. Each kind of record is
  capped at 2 000 rows per statement; beyond that the response is marked
  `truncated` and the reader narrows the period. Shares are matched in
  Postgres with `->'shares' @> [{"investor_account_id": …}]`.
- *Scoping (`InvestorReads`).*
  - Staff (owner, admin, operator, viewer) and service principals read any
    account in the partition.
  - Anyone else reads an account only when the account's investor (identity
    `InvestorGet`) has the caller's profile.
  - Other accounts are answered as not found.
  - A non-staff search must name the caller's own investor.
  - Applies to `InvestorAccountGet`, `InvestorAccountSearch` and
    `InvestorStatement`.
- *UI.* ui/funding `InvestorStatementCard` on the investor account page
  offers the last 30 days, this month, last month and year to date. It
  shows totals and entries, and downloads the statement as CSV.
- *SDK.* Dart funding 0.5.3.

**Verified.**
- funding `TestStatementReportsEveryCapitalMovement` runs deposit → funding
  → repayment → loss → recovery on Postgres and checks every total.
- `TestInvestorReadsOnlyTheirOwnAccount`.
- ui/funding: 26 tests pass, including the statement card and CSV. ui/seed:
  64 tests pass.

## 44. Addendum 2026-10-26 — KYC documents are captured and reviewed

**Gaps closed.**

1. *No capture.* The KYC model has photo, file and signature fields, but
   nothing could capture one. The onboarding form deferred them to the KYC
   tab, which only took typed text.
2. *Arbitrary values.* `ClientDataSave` accepted any string as a "file"
   value, so an entry could point at a file somebody else holds.
3. *Earlier blocker.* Files-service media are private to the uploader, so
   reviewers could not open documents a field agent uploaded.

**Design.** Identity owns the documents. The app sends the image to
identity, which uploads it privately to service-files as itself. No file is
shared with anyone, so no sharing model is needed. A reviewer gets a
five-minute signed link only after identity's own client guard admits them.

**Change.**

- *Identity.*
  - `ClientDocumentUpload` (`client_data_manage`) takes JPEG, PNG, WebP or
    PDF up to 5 MiB, validated in the proto.
    - The client guard runs first: staff, or an agent serving the client.
    - The file is stored through `filesDocumentStore`. Its upload
      idempotency key is a hash of client, field and bytes, so a retry
      stores one file.
    - The upload is recorded as a new revision of the entry: COLLECTED, with
      the review decision cleared.
  - `ClientDocumentLink` (`client_data_view`) returns a signed link valid
    for five minutes, after the same guard. Asking for a text entry
    returns `ErrNotADocument`. A file identity does not hold returns
    `ErrDocumentUnavailable`.
  - `ClientDataSave` refuses `photo`, `file` and `signature`
    (`ErrDocumentNeedsUpload`).
  - Config: `FILES_SERVICE_URI` and `FILES_SERVICE_WORKLOAD_API_TARGET_PATH`.
    Without them, documents are refused and typed KYC data still works.
- *Grants.* service-authentication `af24877` (`20261026_07`): the identity
  SA gets the `/files` audience and `content_upload` and `content_view` in
  `service_file`.
- *UI.* ui/identity KYC tab:
  - "Upload document" takes a photo or chooses an image, scaled to at most
    1 600 px at quality 80.
  - Document entries show "View document", which opens the image through
    the link. The storage id is never shown.
- *SDK.* Dart identity 0.8.2.

**Verified.**
- identity `TestKYCDocumentIsStoredAndLinked`,
  `TestKYCDocumentIsNeverSavedAsAPlainValue` and
  `TestKYCDocumentRefusedWithoutAStore` (Postgres).
- The concurrency test now uses a text field.
- ui/identity: 54 tests pass, including upload and view. ui/seed: 64 pass.

**Deploy.** Set `FILES_SERVICE_URI` on identity, and apply auth migration
`20261026_07`.

## 45. Addendum 2026-10-26 — fixes from an independent review of §41–§44

An independent, read-only review of commission, payout, statements and KYC
documents confirmed no double-payment, lost-money or cross-investor leak.
It raised these lower-confidence points, all fixed:

1. *A resumed payout could stick.*
   - Cause: the member was re-checked before the movement was claimed. If
     the member left the team after a timed-out attempt, which may have
     paid, the retry was refused before reaching the stored order. The
     payout then stayed PROCESSING with the balance taken.
   - Fix: a payout already PROCESSING resumes without re-checking the
     member (`payoutDestination`). Operations runs the order it stored
     under the reference, with the recipient it checked.
   - Test: `TestCommissionPayoutResumesAfterTheMemberLeaves`.
2. *A commission could accrue to the wrong team.*
   - Cause: the serving team was re-resolved on every settlement retry. A
     client reassigned between a successful ledger posting and a failed
     accrual sent the balance to the new team, while the payable sat with
     the old one.
   - Fix: the accrual uses the `team_id` on the order operations returns
     for the reference.
   - Test: `TestCommissionAccruesToTheTeamTheLedgerCredited`.
3. *Funding failed open without claims.* `callerIsStaff` treated a context
   without claims as staff; it now denies.
4. *Withdraw had no ownership check.* `InvestorWithdraw` now applies the
   same `CheckInvestor` as the read RPCs. This is defence in depth: only
   staff hold `investor_account_manage`.
5. *A refused payout pinned its key.* A rail-refused order is closed, so
   retrying its key is refused again. The payout dialog now mints a new key
   after a refusal (InvalidArgument, FailedPrecondition, NotFound,
   PermissionDenied) and keeps the key after any other failure. The dialog
   also scrolls, so a long error no longer overflows it.

## 46. Addendum 2026-10-26 — KYC document hardening

An automated security review of §44 flagged two points. Neither was
exploitable as built, but both are hardened:

1. *Document type came from the request alone.*
   - Before: a document value saved as `"text"` or `" Photo "` could never
     produce a link and showed only as text.
   - Now: value types are normalised (trimmed and lower-cased). The client's
     form template is consulted, so a field it declares a photo, file or
     signature is refused on `ClientDataSave`, and a field it declares typed
     refuses `ClientDocumentUpload`.
   - A field the form declares is uploaded as its declared kind, whatever
     the request calls it, so a photo field never holds a PDF.
   - Test: `TestKYCDocumentFollowsTheFormsFieldType`.
2. *Upload content was trusted.*
   - Before: the proto already limited content types and size, and frame's
     validation interceptor enforced that.
   - Now identity also checks:
     - the bytes match the declared type (`http.DetectContentType`), so a
       page sent as an image is refused;
     - photos and signatures are images only, and only documents may be PDF;
     - the size is at most 5 MiB.

     Nothing refused is stored.
   - Test: `TestKYCDocumentContentMustMatchItsKind`.

## 47. Addendum 2026-10-26 — payouts the rail fails after accepting them; savings interest on trustage

**Gaps closed.**

1. *Late payout failures were never seen.*
   - The payment service's `Send` answers QUEUED, and providers report the
     outcome later by webhook. Operations completed a payout order on that
     acceptance and never asked again.
   - So a disbursement, savings withdrawal, investor withdrawal or commission
     payout the rail failed afterwards stayed "paid" everywhere, while the
     money never reached the person.
   - It was the only open item from §8 that touched money.
2. *Savings interest ran on an in-process timer* (`runInterestAccrual`).
   This broke the trustage-only scheduling rule, and on a service that
   scales to zero it may not run.

**Change.**

- *Operations.*
  - A payout the rail accepts is `payout_status = pending`; the rail's
    SUCCESSFUL makes it `confirmed`. New columns: `payout_checked_at` and
    `originator_notified_at`.
  - `OperationsJobRun(RECONCILE_PAYOUTS)` runs every 10 minutes on trustage
    (`operations_reconcile_payouts.json`). For each payout order whose
    outcome is unknown, oldest checked first:
    - An order that never completed is resumed (the existing confirm path).
    - A completed order is looked up at the payment service. SUCCESSFUL
      becomes confirmed.
    - FAILED is marked failed and its ledger leg reversed, but only for the
      order's own payout: its recorded payment id, or, with none recorded,
      an outbound payment of exactly its amount. Any other answer stays
      undecided and goes to an operator.
      (`reverseRejectedPayout`).
    - Still undecided after a day is logged at error for operators.
  - Late-failed orders are then reported to their originator by reference
    prefix, until the originator answers.
  - A completed order whose payout failed now answers a re-execution with
    `ErrPayoutFailed`. Before, it reported success, which would have let a
    retried commission payout count as paid.
- *Originators.* `PayoutFailedApply` (`payout_outcome_apply`, internal
  callers only, idempotent):
  - *Loans, disbursement.* The disbursement becomes FAILED and the loan
    returns ACTIVE → PENDING_DISBURSEMENT with its disbursement date
    cleared, so staff can pay it again. A loan already repaid on, or no
    longer ACTIVE, is logged for an operator rather than undone.
  - *Loans, team commission.* The payout returns COMPLETED → PENDING with
    the reason, and its amount goes back to the team's balance.
  - *Savings.* The withdrawal becomes COMPLETED → REVERSED. The balance is
    credited back and `total_withdrawals` reduced.
  - *Funding.* The movement becomes COMPLETED → REVERTED (new status 4), and
    the investor's available balance is restored.
- *Savings interest.*
  - `SavingsJobRun(ACCRUE_INTEREST)` runs hourly
    (`savings_accrue_interest.json`). The workflow ships in the image and
    the setup job registers it.
  - Each account records `interest_accrued_through` (accrued or skipped)
    and `interest_checked_at`, so the job settles every active account once
    a day. A failing account waits 10 minutes rather than blocking the batch.
  - The timer and `SAVINGS_INTEREST_ACCRUAL_*` config are gone.
- *Grants.* service-authentication `20261026_08`:
  - operations → `payout_outcome_apply` on loans, savings and funding;
  - savings → trustage (`workflow_manage`, `workflow_view`) and `/trustage`;
  - trustage → `savings_job_run` and `/savings`.
- *SDKs.* Dart loans 0.6.6, funding 0.5.4, savings 0.4.1, operations 0.4.7.

**Verified.**
- operations: `TestReconcile_LateFailureIsReversedAndTheOriginatorTold`
  (it also checks a retry is refused), and
  `TestReconcile_ConfirmsPaidAndKeepsUndecidedPending`.
- loans: `TestLateFailedDisbursementReturnsTheLoanToPending` and
  `TestLateFailedCommissionPayoutReturnsToTheBalance`.
- funding: `TestWithdrawalFailedAtTheRailIsReturnedOnce` (Postgres).
- savings: `TestWithdrawalFailedAtTheRailIsReversedOnce` and
  `TestInterestJobAccruesEachDayOnce` (Postgres).
- trustage workflow validation covers savings.

**Deploy.** Apply auth migration `20261026_08`, and set
`TRUSTAGE_SERVICE_URI` on savings for its setup job.

## 48. Addendum 2026-10-26 — maker/checker in the UI; phone-width lists

**Gaps closed (from the §8 UI follow-ups).**

1. *Maker/checker was not shown.* The service already refuses a credit
   decision by whoever submitted a request (`requireSeparationOfDuties`).
   The console never showed who submitted or decided a request, and still
   offered the submitter Approve and Reject, which then failed.
   - Now: the request page shows *Submitted by* and *Decided by*. When the
     signed-in profile is the submitter (`currentProfileIdProvider`, which
     Seed supplies from its sign-in), the page says another staff member
     must decide, and offers no buttons.
2. *Lists did not fit a phone.* Field agents' lists (Clients, Loan
   Accounts, Loan Requests) were wide `DataTable`s at every width.
   - Now: below the mobile breakpoint they are lists of tiles
     (`CompactEntityList`) with the same search, filters, actions,
     load-more and add button.
   - A phone-width test caught the load-more row overflowing a narrow
     screen; its label now shrinks.
   - ui_core's `AdminEntityListPage` has no mobile layout. Fixing it at the
     root means publishing a new ui_core, so this is done in the fintech
     packages instead.

**Verified.** ui/loans 61 tests (including `the submitter is not offered a
decision on their request` and `a phone lists loans as tiles with the
filters`), ui/identity 55 (`a phone lists clients as tiles and keeps
onboarding`), ui/seed 64.

## 49. Addendum 2026-10-26 — Stawi group product: audit and phase 1

**Audit.** None of Stawi's five workflows (`products/stawi/workflows`) ever
started an instance:

- No triggers or signals exist, and nothing creates instances.
- `SyncFromFS` stops at the first invalid file, and Stawi's setup only logs
  the failure.
- Their calls could not have worked anyway. `http.request` sends no service
  credentials, `{{ env.* }}` does not resolve, and `notification.send`
  expects raw contacts.

So in practice groups have no lifecycle: no tenure, no period, no loan window,
no offer. Group rail payments stop at "identified" in operations (the settle
job allocates only `client_loan`, `client_savings` and `investor_account`).
Group obligations live only in Stawi's private copy of the operations code, on
its own database. Stawi also carried a private copy of funding allocation
whose tables it never migrates.

With the user's agreement, the group product is rebuilt in six phases on
`feat/stawi-groups`:

1. Retire the superseded flows.
2. Group obligations and allocation in operations.
3. Accepting an offer originates through loans.
4. Period and collection cycles as `StawiJobRun` jobs on trustage.
5. Group lifecycle triggered from identity events.
6. Deployment wiring.

**Phase 1.**

- Deleted `payment_routing.json` and `loan_origination.json`.
- Removed the 14 callback routes, handlers, business code and RPCs only those
  workflows used:
  - sender identification by raw phone, payment allocation and confirmation;
  - ledger transfer of caller-named accounts;
  - suspense deposit;
  - funding source;
  - offer generation and expiry;
  - eligibility, schedule and disbursement.
- Stawi no longer embeds funding allocation, the transfer-order business, or
  the limits client. Its manifest drops `stawi_loan_offer_manage`,
  `stawi_loan_view`, `stawi_loan_fund`, `stawi_loan_disburse` and
  `stawi_ledger_transfer`.
- service-authentication `20261026_09` narrows the stored `service_stawi`
  namespace so the additive-only registration accepts the new manifest. It
  was exercised against Postgres; a re-run is a no-op.
- Kept for later phases:
  - the offer-respond and loan-account routes (phase 3);
  - Stawi's private copy of operations obligations (phase 2).
