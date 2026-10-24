# Loans Domain — Production-Readiness Audit

**Verdict: NOT production-ready.** The write path is architecturally broken: every mutation is a fire-and-forget queue publish, and the optimistic-lock version check silently discards most updates. Combined with a schedule generator that fails on the most common loan shapes and penalties that never enter the balance, the ledger and the loan book will diverge from day one.

---

## 1. Feature Inventory

### RPC → Handler (37 RPCs in proto, 31 handler methods)

| RPC | Handler | Status |
|---|---|---|
| LoanProductSave | `handlers/loan_management.go:82` | **BUG** — no validation; updates silently no-op (F3) |
| LoanProductGet | `:96` | OK |
| LoanProductSearch | `:107` | **BUG** — `query` hits nonexistent `searchable` column (F5); no `CleanErr` |
| LoanRequestSave | `:119` | **BUG** — arbitrary status/amount write, no state machine (F2) |
| LoanRequestGet | `:132` | OK |
| LoanRequestSearch | `:143` | **BUG** — same `searchable` issue; no `CleanErr` |
| LoanRequestApprove | `:153` | **BUG** — no amount/term/expiry validation |
| LoanRequestReject | `:166` | **BUG** — can reject an APPROVED request with a live loan account |
| LoanRequestCancel | `:180` | Same as Reject |
| **ClientProductAccessSave** | — | **MISSING** (Unimplemented) |
| **ClientProductAccessGet** | — | **MISSING** |
| **ClientProductAccessSearch** | — | **MISSING** |
| LoanAccountCreate | `:196` | **BUG** — not idempotent, double-funds (F4); schedule always fails (F1) |
| LoanAccountGet | `:210` | OK |
| LoanAccountSearch | `:221` | **BUG** — `searchable` |
| LoanBalanceGet | `:236` | **BUG** — penalties never in balance (F6) |
| LoanStatement | `:247` | **BUG** — mixes currencies; N+1 full scans |
| DisbursementCreate | `:488` | **BUG** — double-disbursement race (F7); stuck at PROCESSING (F3); returns 200 on failure |
| DisbursementGet | `:502` | OK |
| DisbursementSearch | `:513` | OK |
| RepaymentRecord | `:260` | **BUG** — idempotency optional (F8); ledger/schedule desync (F9); currency-decimals (F10) |
| RepaymentGet | `:274` | OK |
| RepaymentSearch | `:285` | OK |
| RepaymentScheduleGet | `:302` | OK (but schedule usually absent) |
| PenaltySave | `:315` | **BUG** — not idempotent, no balance impact, can un-waive (F6, F12) |
| PenaltyWaive | `:328` | **BUG** — `waived_by` never set server-side |
| PenaltySearch | `:342` | OK |
| LoanRestructureCreate | `:359` | **BUG** — zero validation |
| LoanRestructureApprove | `:372` | **BUG** — CLOSED→ACTIVE bypass; resets principal (F11) |
| LoanRestructureReject | `:385` | OK |
| LoanRestructureSearch | `:399` | OK |
| ReconciliationSave | `:416` | **BUG** — zero validation; updates no-op |
| ReconciliationSearch | `:429` | OK |
| **InitiateCollection** | — | **MISSING** — UI calls it |
| LoanStatusChangeSearch | `:446` | OK |
| **PortfolioSummary** | — | **MISSING** — dead REST handler in `handlers/portfolio.go`, never registered |
| **PortfolioExport** | — | **MISSING** — and the SQL is broken (`la.application_id`) |

### Screen → Status

| Screen | Status |
|---|---|
| `loan_accounts_screen.dart` | OK (no pagination past 50) |
| `loan_account_detail_screen.dart` | **BUG** — "Collect Payment" calls unimplemented RPC; idempotency key regenerated per retry |
| `loan_requests_screen.dart` / `loan_request_detail_screen.dart` | OK |
| `loan_products_screen.dart` | **BROKEN** — product creation always fails proto validation (F13); edit wipes `required_forms` |
| `loan_product_detail_screen.dart` | OK |
| `dashboard_screen.dart` | **BUG** — all counts capped at 1 (`PageCursor(limit: 1)` + `maxPages: 1`) |
| `portfolio_summary_screen.dart` | **DEAD** — RPC unimplemented |
| `loan_book_screen.dart` | **DEAD** — RPC unimplemented; export produces no file |

---

## 2. Findings (most severe first)

### F1 — CRITICAL: Repayment schedule generation fails for most loans
`apps/loans/service/business/repayment_schedule.go:243-262` + `pkg/calculation/amortization.go:69-99`
`validateScheduleInvariant` allows 1 minor unit of drift, but each installment is rounded independently (`decimalx.ToMinorUnits` uses `RoundHalfUp`, `decimal.go:242`). For principal 1000.00 over 12 monthly installments: `83.333…→8333`, `12×8333 = 99996`, drift 4 → error. **Every 12-installment monthly loan** (and 6, 7, …) fails. `loan_account.go:186-190` only logs the failure, so the loan is created with **no schedule at all**. `repayment.go:517-521` then falls back to "apply everything to principal" — interest and fees are never collected.
**Fix:** distribute residual in minor units after conversion (compute all entries in int64 minor units, give the last entry `principal − Σ(others)`), then the invariant holds exactly.

### F2 — CRITICAL: `LoanRequestSave` bypasses the entire approval state machine
`apps/loans/service/business/loan_request.go:80-99`
No validation whatsoever. A caller with `loan_request_manage` (ROLE_OPERATOR has it, `loans.proto:1170`) POSTs `LoanRequestObject{id: <existing>, status: APPROVED, approved_amount: 10_000_000}` — skipping `approveInner`'s SUBMITTED check (`:240`), `enforceProductRequirements` (`:247`), and the limits gate. Then calls `LoanAccountCreate`. Also resurrects REJECTED/CANCELLED requests.
**Fix:** `Save` must reject any client-supplied `status` other than DRAFT/SUBMITTED, must not allow status regression on an existing row, and must validate `approved_amount`/`term` against the product's min/max.

### F3 — CRITICAL: Optimistic-lock version mismatch silently discards updates
`frame/v2@v2.1.7/datastore/repository.go:261` (`WHERE id = ? AND version = ?`) vs. `apps/loans/service/events/*_save.go:61-68`
Business objects built by `models.XFromAPI` (`models.go:126`, `418`, `506`, …) carry `Version = 0`, while the persisted row is at ≥1. `Update` returns `RowsAffected = 0` with **no error**, and every event handler ignores `RowsAffected`. Consequences verified:
- `disbursement.go:209` — the COMPLETED status update never lands. Money moves via `TransferOrderExecute` (`:197`) but the disbursement row stays `PROCESSING` forever. The FAILED update at `:202` is equally lost.
- `penalty.go:187` — `ledger_transaction_id` is never persisted onto the penalty.
- `LoanProductSave` / `PenaltySave` / `ReconciliationSave` / `LoanRestructureCreate` on an existing id return HTTP 200 having changed nothing.
**Fix:** load the current row and copy its `Version` before `Update` in each event handler, and treat `RowsAffected == 0` as a retryable conflict rather than success.

### F4 — CRITICAL: `LoanAccountCreate` is not idempotent and double-reserves funding
`apps/loans/service/business/loan_account.go:160-195`
No check for an existing loan account on the request; `ensureLoanRequestFunding` (`:172` → `FundLoan`, `:290`) is called *before* `la.GenID` and before any uniqueness test. The loan request is never moved to `LOAN_REQUEST_STATUS_LOAN_CREATED` and `loan_account_id` is never written back (grep confirms no writer). Second call: funding reserved again, a *new* xid generated, `uq_loan_request` (`models.go:32`) rejects the insert — and `events/loan_account_save.go:70` swallows the duplicate-key error. The caller gets a 200 with an ID that does not exist.
**Fix:** look up by `loan_request_id` and return the existing account before touching funding; set the request to LOAN_CREATED + `loan_account_id` in the same operation.

### F5 — CRITICAL: Full-text search queries a column that was never created
`apps/loans/service/business/helpers.go:93` (`searchable @@ websearch_to_tsquery(...)`), used at `loan_account.go:445`, `loan_request.go:162`, `loan_product.go:115`.
`apps/loans/service/repository/migrate.go` only calls `AutoMigrate`; there is no `migrations/` directory under `apps/loans/` and frame never creates a `searchable` column (only `datastore/repository.go:129` whitelists the name). Compare `apps/identity/service/repository/migrate.go:139-260`, which builds the tsvector columns explicitly. Any UI search box with text → `column "searchable" does not exist`.
**Fix:** add the generated tsvector column + GIN index in `migrate.go` the way identity does.

### F6 — CRITICAL: Penalties never enter the loan balance
`apps/loans/service/business/penalty.go:84-128` and `repository/loan_balance.go:106`
`penalties_outstanding` is only ever **decremented** (`GREATEST(penalties_outstanding - ?, 0)`); nothing ever increments it (verified by grep across `apps/loans`). So `waterfallAllocate`'s penalty step (`repayment.go:509`) is always a no-op, `total_outstanding` excludes penalties, and a loan flips to PAID_OFF (`repayment.go:336`) while an unpaid penalty receivable sits on the ledger from `postPenaltyAccrual`.
**Fix:** in `PenaltyBusiness.Save`, apply an atomic `penalties_outstanding + amount`, `total_outstanding + amount` delta; reverse it on `Waive`.

### F7 — CRITICAL: Double-disbursement race
`apps/loans/service/business/disbursement.go:100-105`, `:157-164`
The idempotency check is a plain read (`GetByIdempotencyKey`), and the `PENDING_DISBURSEMENT` guard reads `la` from the DB. Two concurrent requests with the same key both miss, both see PENDING, both build a disbursement with a *distinct* xid, and both call `TransferOrderExecute` with reference `disbursement:<distinct-id>` (`:309`) — the operations-service dedupe never fires. The `uq_disb_idem` unique index only rejects the losing row later, asynchronously, after the money has left.
**Fix:** insert the disbursement row synchronously with the idempotency key inside a transaction (`INSERT … ON CONFLICT DO NOTHING`, then re-read) and derive the transfer reference from `idempotency_key`, not the row id.

### F8 — CRITICAL: Repayment idempotency is optional by default
`apps/loans/service/business/repayment.go:129-152`; `apps/loans/config/config.go` (`LIMITS_GATE_ENABLED_LOAN_REPAYMENT` defaults `false`)
The `idempotency_key required` check at `:149` sits *after* the early return at `:130`. With the gate off (the default), a key-less repayment is accepted, stored with `IdempotencyKey = ""` against `uniqueIndex:uq_rep_idem` (`models.go:445`). The *second* key-less repayment in the whole database collides — and `events/repayment_save.go:70` swallows the duplicate-key error, so the repayment vanishes while its ledger transfer orders were already posted. `repayment_limits_test.go:346` only covers the gate-enabled path.
**Fix:** move the required-key check above line 129, and make the key part of a partition-scoped unique index.

### F9 — CRITICAL: Repayment is not transactional; a ledger failure leaves the schedule marked paid
`apps/loans/service/business/repayment.go:216` → `:235` → `:248` → `:257`
Order of operations: `waterfallAllocate` mutates and emits every schedule entry (`:598`), then the repayment row is emitted (`:235`), *then* the transfer orders execute (`:248`). If a transfer order fails, `:249` returns an error to the caller — but the entries are already PAID and the repayment row already exists. A retry with the same key short-circuits at `:122-127` and returns the existing repayment, so the ledger posting **never happens**. Nothing is wrapped in a DB transaction anywhere in this service.
**Fix:** post the ledger first (or record an outbox row), and wrap the repayment + schedule-entry + balance writes in one `Transaction`.

### F10 — CRITICAL: Ledger amounts hardcode 2 decimal places
`repayment.go:477`, `disbursement.go:307`, `penalty.go:167`, `loan_account.go:826`
All four use `moneyx.FromSmallestUnit(currency, amount, decimalPrecision)` with `decimalPrecision = 2` (`loan_account.go:50`), while storage uses ISO-4217 decimals via `models.MinorUnitsToMoney` → `moneyx.FromMinorUnitsByCurrency` (`models/helpers.go:89`). For JPY (0 dp) the ledger is posted **100×** the true amount; for KWD/BHD/OMR (3 dp) it is **10× too small**.
**Fix:** use `moneyx.FromMinorUnitsByCurrency(currency, amount)` in all four places.

### F11 — HIGH: Restructure approval resets principal and bypasses the state machine
`apps/loans/service/business/loan_restructure.go:123`, `:132`
`la.Status = RESTRUCTURED` is assigned directly, skipping `validTransitions` (`loan_account.go:62-94`) and writing no `LoanStatusChange` audit row. Since RESTRUCTURED→ACTIVE is legal (`:82-86`), a **CLOSED or WRITTEN_OFF loan can be brought back to ACTIVE**. Then `scheduleBusiness.Generate` (`:132`) regenerates from `la.PrincipalAmount` — the *original* principal — so a borrower who has repaid 60% re-owes the full amount. `WaivedAmount` and `RESTRUCTURE_TYPE_WRITE_OFF`/`PARTIAL_WAIVER` are read from the request but never applied to the balance or the ledger.
**Fix:** route through `laBusiness.TransitionStatus`; generate the new schedule from `balance.principal_outstanding`; implement the waiver/write-off ledger postings or reject those restructure types.

### F12 — HIGH: Penalties are re-applied on every delinquency scan (and the scanner is never wired)
`apps/loans/service/business/delinquency.go:234`
`entry.Properties["penalty_applied"] = true` is set in memory and never emitted, so the skip check at `:207-211` never sees it — every scan posts a fresh penalty and a fresh ledger accrual for the same installment. Moot today because `NewDelinquencyScanner` has **zero call sites** (verified by grep across the repo): no loan ever becomes DELINQUENT or DEFAULT, no late penalty is ever charged, and `days_past_due` is never written (`computeDaysPastDue` discards its result), so `par_30` is permanently `0.00` (`portfolio.go:137`). The scan is also capped at 500 loans with no paging (`:99`, `:133`).
**Fix:** emit the entry after marking it, wire the scanner to a scheduled job, persist `days_past_due`, and page the scan.

### F13 — HIGH: Loan product creation from the UI is impossible
`ui/loans/lib/src/screens/loan_products_screen.dart:327-361`
`organizationId` is set **only when editing** (`:358`). On create it stays empty, violating `(buf.validate.field).string.min_len = 3` on `LoanProductObject.organization_id` (`loans.proto:203-206`) — the RPC is rejected before reaching the handler. Additionally `requiredForms` is never carried over on edit, so saving an existing product **wipes its required-forms list**, silently disabling the `enforceProductRequirements` verification gate (`loan_request.go:339-342`).
**Fix:** source `organizationId` from the active tenancy context; preserve `requiredForms` (and all unedited fields) on update.

### F14 — HIGH: Six RPCs are unimplemented but wired in the UI
`apps/loans/service/handlers/loan_management.go` (31 of 37), `apps/loans/service/handlers/portfolio.go:31` (never called from `cmd/main.go`)
`PortfolioSummary`, `PortfolioExport`, `InitiateCollection`, and all three `ClientProductAccess*` fall through to `UnimplementedLoanManagementServiceHandler` (`:49`). The UI calls all but ClientProductAccess: `portfolio_summary_screen.dart:36`, `loan_book_screen.dart:34`, `loan_account_detail_screen.dart:401`. `portfolioBusiness` is injected into the handler struct (`:45`) and never read. The export SQL is broken independently — `export.go:78` selects `la.application_id`, a column that does not exist (the model field is `LoanRequestID` → `loan_request_id`).
**Fix:** implement the six handlers (or remove the UI entry points); fix the export column; delete the dead REST handler.

### F15 — HIGH: Global unique indexes cross tenant boundaries
`apps/loans/service/models/models.go:326` (`Code uniqueIndex:uq_lp_code`), `:445`, `:704`
Tenant isolation is RLS-based (`frame/datastore/pool/implementation.go:129-131`), which scopes *reads* but not unique-index enforcement. Organization B cannot create a product with code `PERSONAL` if organization A already has one — a cross-tenant DoS and an existence oracle. Same for idempotency keys.
**Fix:** make these indexes composite with `partition_id`.

### F16 — HIGH: Overpayment excess is taken but never posted or refunded
`apps/loans/service/business/repayment.go:541-546`
`result.excessAmount = remaining` is stored on the repayment row, but `emitRepaymentTransferOrders` (`:399-449`) only posts principal/interest/fees/penalties — the excess never reaches the ledger. Status is set to `MATCHED` whenever anything was allocated, so `REPAYMENT_STATUS_OVERPAYMENT` and `REPAYMENT_STATUS_PARTIAL` are **unreachable enum values**.
**Fix:** post the excess to a suspense/member-credit account and set the correct status.

### F17 — MEDIUM: `LoanAccountCreate` computes interest with the wrong method
`apps/loans/service/business/loan_account.go:867-888`
`computeInterestAndFees` always calls `calculation.FlatRateInterest`, ignoring `lp.InterestMethod`, while the schedule honours it (`amortization.go:169`). For a REDUCING_BALANCE product the initial `LoanBalance.InterestAccrued` (`:383`) overstates interest, so `total_outstanding` never reaches 0 and the loan never auto-transitions to PAID_OFF.
**Fix:** derive the initial balance by summing the generated schedule instead of recomputing.

### F18 — MEDIUM: Stale in-memory writes clobber concurrent updates
`disbursement.go:213-224` vs. `:227-233`; `repayment.go:337-338`
After `Emit(LoanAccountSaveEvent, la)` with `DisbursedAt`, `TransitionStatus` re-reads the loan from the DB (`loan_account.go:661`) — very likely before the queued update has landed — and emits the whole stale struct, dropping `DisbursedAt`. Emit is asynchronous (`frame/events/manager.go:57` publishes to a queue), so read-modify-write over a queue is the norm here, not the exception. Same pattern in `applyRepaymentToBalance`, which sets PAID_OFF on a stale `la` and writes no `LoanStatusChange` row.
**Fix:** use targeted column updates (`Update(entity, "disbursed_at")`) rather than whole-entity writes.

### F19 — MEDIUM: Failed disbursement returns HTTP 200
`apps/loans/service/business/disbursement.go:198-204`
On transfer failure the method returns `disb.ToAPI(), nil`. The handler then records `audit.ActionCreate` as a success (`handlers/loan_management.go:496-499`). Worse, the idempotency key is now consumed: retrying with the same key returns the FAILED record forever via `:100-105`, so that loan can never be disbursed with that key.
**Fix:** return a typed error, and exclude FAILED records from the idempotency short-circuit.

### F20 — MEDIUM: No per-client authorization on loan reads
`loans.proto:1424-1478`, `apps/default/service_loans.opl.ts:111-118`
`LoanAccountGet`, `LoanBalanceGet`, `LoanStatement`, `RepaymentSearch` all require only `loan_view`, which `ROLE_MEMBER` holds (`loans.proto:1197`). Any member of an organization can read **any** loan, balance, and statement in that partition by id. `authz/constants.go:32` defines `loan_view_own`, but it appears in neither the proto nor the OPL and `RolePermissions` (`:87`) has zero call sites — the whole file below `NamespaceTenancyAccess` is dead and misleading.
**Fix:** add a per-resource check binding `client_id` to the caller, or delete the dead constants so the real model is unambiguous.

### F21 — MEDIUM: Raw errors leak internals and map to the wrong gRPC codes
`repayment.go:196`, `:202`, `:206`; `loan_account.go:169`; `penalty.go:93`
These are bare `fmt.Errorf`, so `apperrors.CleanErr` (`pkg/apperrors/errorutil.go:24-36`) cannot classify them — clients get `Internal`/`Unknown` for what are plainly `InvalidArgument`/`FailedPrecondition`, with internal status ints in the message. `LoanProductSearch` (`handlers:112`) and `LoanRequestSearch` (`:148`) skip `CleanErr` entirely.
**Fix:** use the `apperrors` constructors in `business/errors.go` and wrap both stream handlers.

### F22 — MEDIUM: Idempotency key regenerated on every retry in the UI
`ui/loans/lib/src/screens/loan_account_detail_screen.dart:302`, `:354`, `:400`
`_generateIdempotencyKey()` runs inside `onSave`, and `_submit` (`:1767-1778`) leaves the dialog open on error with `_saving = false`. A user retrying a timed-out payment sends a *different* key → a second real repayment/disbursement.
**Fix:** generate the key once in `initState` of the dialog.

### F23 — MEDIUM: Dashboard counts are structurally capped at 1
`ui/loans/lib/src/providers/dashboard_providers.dart:12`, `:27`, `:42`, `:56`
`PageCursor(limit: 1)` plus `maxPages: 1` in `countStream` means every metric renders 0 or 1. No list screen has a "load more" control either — all providers hardcode `limit: 50` with `cursor.page` never advanced, so nothing past the 50th record is reachable anywhere in the UI.
**Fix:** add a count RPC (or `total` on the cursor); implement cursor paging in the list providers.

### F24 — MEDIUM: `formatLoanMoney` renders zero as an em-dash and breaks on negatives
`ui/loans/lib/src/utils/money_compat.dart:12-27`
`if (units == 0 && nanos == 0) return '—'` — a genuinely zero balance on a paid-off loan shows as "—", not "KES 0.00". Negative Money renders as `-5.-50` (`nanos ~/ 10000000` on a negative nanos). Sub-cent precision (KWD, 3 dp) is truncated, and the blanket `catch (_)` hides every failure as "—".
**Fix:** format from minor units with the currency's ISO decimal count; render zero as zero.

### F25 — LOW: UI permission manifest names a permission that does not exist
`ui/loans/lib/src/routing/loans_route_module.dart:138` declares `repayment_record`; the real permission is `repayment_manage` (`loans.proto:1101`, `service_loans.opl.ts:150`). `/reports/loan-book` is gated on `portfolio_view` (`:101`) but the export RPC requires `portfolio_export`. `LoanAccountDetailScreen`'s `canManage`/`canRecordPayment` default to `true` and the route builder (`:60-64`) never overrides them, so Disburse/Restructure/Record-Payment render for anyone with `loan_view`.

### F26 — LOW: Missing indexes and N+1 reads on the statement path
`loan_account.go:549-592` issues two unbounded `Search` calls per statement and re-fetches the loan account (`:530`) that the caller already loaded (`:483`). `Repayment.PaymentReference`, `Reconciliation.PaymentReference`/`ExternalReference`, and `Penalty.ScheduleEntryID` (`models.go:436`, `766-767`, `529`) carry no index despite being the natural reconciliation lookup keys.

---

## 3. Test Coverage Assessment

**What exists** — 4 real test files, ~1 400 lines, all stub-based unit tests, all about the limits gate:

| File | Covers |
|---|---|
| `business/disbursement_test.go` | gate on/off/allowed/denied/pending, idempotency short-circuit |
| `business/repayment_limits_test.go` | gate on/off/allowed/denied/pending, empty-key rejection (gate-enabled only) |
| `business/loan_request_limits_test.go` | gate on/off/allowed/denied/pending |
| `business/metrics_test.go` | one OTel attribute assertion |
| `business/loan_account_test.go` | **empty** — 15 lines, license header and `package business` only |

No Go handler tests. No repository tests. No testcontainers/DB integration tests anywhere in `apps/loans`. No `pkg/calculation` tests at all. No Flutter tests in `ui/loans` (zero `*_test.dart`).

**Critical paths with zero coverage:**
- **All money math.** `pkg/calculation` — flat vs. reducing-balance schedules, dust distribution, `PeriodsPerYear`. A single table test over installment counts 1–24 would have caught F1.
- **The repayment waterfall** (`waterfallAllocate`, `allocateToEntry`) — penalty→interest→fees→principal ordering, partial payments, overpayment, currency mismatch, zero/negative amounts.
- **The loan status machine** (`validTransitions`, `TransitionStatus`) and, crucially, the three code paths that bypass it (F11, F18).
- **Idempotency and concurrency** — no test issues two concurrent `DisbursementCreate`/`RepaymentRecord` calls with the same key (F7, F8). All existing tests are single-threaded against in-memory stubs.
- **The event/persistence layer** — no test asserts that an emitted save actually lands, which is exactly why F3 (silent `RowsAffected == 0`) went unnoticed.
- **Schema** — no migration test; F5 (missing `searchable` column) is invisible to stub-based tests by construction.
- **Every handler** — validation, error mapping, audit emission, streaming pagination.
- **The whole Flutter package** — no widget tests, so F13 (product creation impossible) and F23 (counts capped at 1) ship unnoticed.

**Minimum bar before shipping:** testcontainers-backed integration tests for create→fund→disburse→repay→payoff with real Postgres and a real queue; a table test over `GenerateScheduleFromProduct` asserting `Σ principal == principal` exactly; and concurrent-request tests for disbursement and repayment idempotency.
