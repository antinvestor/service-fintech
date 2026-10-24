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
