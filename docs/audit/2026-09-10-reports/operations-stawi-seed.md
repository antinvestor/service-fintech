# Adversarial Production-Readiness Audit — OPERATIONS / STAWI / SEED

**Verdict: NO-GO.** Stawi and Seed expose money-moving HTTP endpoints with **zero authentication or authorization**. Seed ships hardcoded KYC and loan-creation stubs in `main()`. Every stawi workflow is broken (URL mismatches). Operations' central idempotency guarantee is built on an asynchronous queue emit and does not hold.

---

## 1. Feature Inventory

### OPERATIONS (Connect RPC, `proto/operations/operations/v1/operations.proto`)

| RPC | Handler | Status | Note |
|---|---|---|---|
| `TransferOrderExecute` | `handlers/operations.go:60` | **BUG** | Save is an async emit; `Execute` immediately re-reads by ID → not-found race. No input validation. State "claim" is non-atomic. |
| `TransferOrderSearch` | `handlers/operations.go:97` | **BUG** | Offset paging, no max-limit clamp (`cursor.limit` unbounded); `limit=0` when cursor set. |
| `IncomingPaymentNotify` | `handlers/operations.go:188` | **BUG** | Dedupe on `transaction_id` has no unique index and read-then-async-write. |
| `PaymentAllocate` | `handlers/operations.go:234` | **BUG** | Creates transfer orders that are never executed; obligations always empty (see F5). |

Non-RPC business modules: `ObligationBusiness` (365 LoC) — **DEAD**, constructed and discarded at `apps/operations/cmd/main.go:217`. 25 of 33 transfer side-effect handlers (`business/transfer_order.go:965-1387`) are **log-only no-ops**.

### STAWI (plain `http.ServeMux`, no proto, no OPL namespace)

| Endpoint | Handler | Status |
|---|---|---|
| `POST /groups/{id}/check-formation` | `workflow_callbacks.go:44` | **BUG** (unauth; `minMembers=5` hardcoded) |
| `POST /groups/{id}/welcome` | :46 | **BUG** (unauth; lender-registration failure swallowed) |
| `POST /groups/{id}/setup-ledger` | :50 | **BUG** (unauth; all ledger CreateAccount errors → warn, returns 200) |
| `POST /groups/{id}/create-tenure` | :53 | **BUG** (unauth; read-then-async-emit race) |
| `POST /groups/{id}/register-lender` | :55 | **BUG** (unauth; N+1, errors swallowed) |
| `POST /groups/{id}/open-period` | :58 | **BUG** (unauth; unique-index collision, F3) |
| `POST /groups/{id}/evaluate-loan-window` | :59 | **STUB** (hardcoded cycle params; creates no LoanWindow) |
| `POST /groups/{id}/calculate-obligations` | :61 | **BUG** (unauth; URL not called by any workflow) |
| `POST /groups/{id}/transition` | :64 | **CRITICAL** (unauth arbitrary group state change) |
| `POST /periods/{id}/close` | :67 | **BUG** (unauth; URL unused by workflow) |
| `POST /memberships/{id}/check-periodic-payment` | :71 | **STUB** (`membership.go:86` returns error) |
| `POST /loan-windows/{id}/generate-offers` | :76 | **BUG** (unauth; no expiry/leverage bounds) |
| `POST /loan-offers/{id}/source-funding` | :77 | **BUG** (unauth) |
| `POST /loan-offers/{id}/create-loan-account` | :79 | **CRITICAL** (unauth; non-idempotent duplicate loan creation) |
| `POST /loan-accounts/{id}/generate-schedule` | :391 | **STUB** — returns 501 |
| `POST /loan-accounts/{id}/disburse` | :397 | **STUB** — returns 501 |
| `POST /payments/identify` | :86 | **BUG** (unauth) |
| `POST /payments/{id}/allocate` | :87 | **BUG** (unauth) |
| `POST /transfer-orders/{id}/execute` | :88 | **CRITICAL** (unauth money movement) |
| `GET /obligations/{id}/status` | :91 | **BUG** (unauth; URL unused) |
| `MotionBusiness.Create/Vote` | `motion.go:40,44` | **STUB** — discarded at `cmd/main.go:201` |
| `MembershipBusiness.UpdateRole` | `membership.go:82` | **STUB** |

**15 workflow-referenced endpoints have no handler at all** (see F2).

### SEED — the backend implements the credit-profile ladder for real; the two things that make it a *lending* service are stubs.

| Endpoint / component | Location | Status |
|---|---|---|
| `POST /api/v1/seed/loan-requests` | `handlers/http.go:74` | **CRITICAL** (unauth; caller supplies `client_id` and `actor_id`) |
| `GET /api/v1/seed/credit-profiles/{c}/{cur}` | :75 | **BUG** (unauth; any client's profile readable) |
| `POST /api/v1/seed/internal/paid-off` | :76 | **CRITICAL** (unauth; forges repayments → tier promotion) |
| `AlwaysVerifiedKYC` | `business/stubs.go:33`, wired `cmd/main.go:144` | **STUB in production binary** |
| `StubLoanCreator` | `business/stubs.go:53`, wired `cmd/main.go:145` | **STUB in production binary** — no loan, no money, returns `"stub-loan-…"` |
| `CreditProfileBusiness` (Ensure/Evaluate/RecordRepayment) | `credit_profile.go` | OK (real, atomic SQL) |
| `AtomicSetStatus` (suspend/block) | `credit_profile_repo.go:257` | **DEAD** — no caller, no endpoint |
| `CreditTierConfig` seeding | — | **MISSING** — nothing anywhere creates a tier row |

### ui/operations

| Screen | Status |
|---|---|
| `TransferOrdersScreen` | **BUG** — read-only; order-type enum mapping wrong (F10); 100-row cap, no paging |
| `DisbursementQueueScreen` | **STUB** — `disbursementQueueProvider` returns `[]` (`:29`); no RPC; buttons vanish if host omits callbacks |
| `NotificationTemplatesScreen` | **STUB** — 170 lines of `const` data (`:303-475`); no RPC, no loading/error/empty; comment at `:274` cites `pkg/templates/defaults.go` which does not exist |

`TransferOrderExecute`, `IncomingPaymentNotify`, `PaymentAllocate` have **no UI surface at all**.

---

## 2. Findings (most severe first)

### F1 — CRITICAL: Stawi and Seed HTTP surfaces have no authentication, authorization, or tenant isolation
`apps/stawi/cmd/main.go:157,303` — `buildWorkflowMux` returns a bare `http.ServeMux` handed to `frame.WithHTTPHandler(mux)`. `apps/seed/cmd/main.go:161-169` — identical. Compare `apps/operations/cmd/main.go:269-278`, which builds `connectInterceptors.DefaultList(authenticator, tenancyAccessInterceptor, functionAccessInterceptor, auditInterceptor)`. Neither service calls `frame.WithPermissionRegistration`, and there is no `service_stawi.opl.ts` or `service_seed.opl.ts` in `apps/default/` (only 8 namespaces exist, neither of them).
**Trigger:** `curl -X POST $STAWI_URL/api/v1/transfer-orders/{any-id}/execute` from anywhere with network reach posts a double-entry ledger transaction and fires a real `PaymentClient.Send`. `POST /api/v1/groups/{id}/transition -d '{"state":6}'` shuts down any group in any tenant. `POST /api/v1/seed/loan-requests -d '{"client_id":"victim",...}'` originates a loan.
**Fix:** Route both muxes through `connectInterceptors.DefaultList` (or the equivalent `http.Handler` middleware chain) with an authenticator + `NewTenancyAccessInterceptor` + `NewFunctionAccessInterceptor`; add `service_stawi.opl.ts` / `service_seed.opl.ts` namespaces and `frame.WithPermissionRegistration`; derive `group_id`/`client_id` scope from the caller's claims, not the path.

### F2 — CRITICAL: No stawi workflow can complete — 15 referenced endpoints do not exist and 9 more are at different URLs
Registered routes: `apps/stawi/service/handlers/workflow_callbacks.go:44-91`. Workflow URLs: `products/stawi/workflows/*.json`.
Mismatched: `loan_origination.json:76` `/groups/{g}/members/{m}/generate-loan-offers` vs registered `/loan-windows/{id}/generate-offers`; `:193` `/groups/{g}/loans/source-funding` vs `/loan-offers/{id}/source-funding`; `:243` `POST /groups/{g}/loans` vs `/loan-offers/{id}/create-loan-account`; `payment_routing.json:34` `/payments/identify-sender` vs `/payments/identify`; `:138` `/groups/{g}/payments/allocate` vs `/payments/{id}/allocate`; `:163` `/groups/{g}/ledger/transfer` vs `/transfer-orders/{id}/execute`; `period_lifecycle.json:98` `/groups/{g}/periods/{p}/close` vs `/periods/{id}/close`; `savings_collection.json:38` `/groups/{g}/periods/{p}/calculate-obligations` vs `/groups/{id}/calculate-obligations`.
Absent entirely: `loan-eligibility` (`loan_origination.json:32`), `expire-loan-offers` (:166), `suspense/deposit` (`payment_routing.json:58`), `payments/{tx}/confirm` (:211), `check-obligations` (:240), `periods/{p}/freeze` (`period_lifecycle.json:32`), `/reconcile` (:45), `/calculate-penalties` (:58), `/loan-window/open` (:132), `/periods/{p}/extend` (:204), `/members?status=active` (`savings_collection.json:25`), `/suspense-balance` (:58), `/apply-suspense` (:77), `/outstanding-obligations` (:161), `/ledger/transfer-failure` (`payment_routing.json:189`).
**Trigger:** Deploy stawi, trigger `sacco_loan_origination`. Step 1 (`check_eligibility`) 404s, retries 3×, workflow dies. Same for every other workflow.
**Fix:** Reconcile the two in one pass — pick the workflow URL shapes as canonical (they carry group scope, which is needed for tenant checks anyway), implement the 15 missing handlers, and add a contract test that asserts every `http.request` URL template in `products/stawi/workflows/*.json` resolves against the registered mux patterns.

### F3 — CRITICAL: Only one group in the entire deployment can ever open its first period
`apps/stawi/service/models/models.go:133` — `ParentPeriodID string \`gorm:"...;uniqueIndex:uq_per_parent"\``. `apps/stawi/service/business/period.go:144` returns `parentPeriodID = ""` for the first period of every tenure. `ParentPeriodID` is a non-pointer string, so GORM inserts `''`, not `NULL` — Postgres enforces uniqueness across empty strings.
**Trigger:** Group A opens period 1 (`parent_period_id=''`, inserted). Group B opens period 1 → duplicate key on `uq_per_parent`. `events/upsert_helper.go:69` then calls `GetByID(entity.GetID())` which is not found, returns the error, the event fails and is retried forever. Group B never gets a period; `ObligationBusiness.CalculateForGroup` then fails with "current period not found".
**Fix:** Replace with a partial unique index — `apps/operations/service/repository/migrate.go:93` already has exactly this helper (`createPartialUniqueIndex(..., "parent_period_id <> ''")`). Drop the GORM tag, add a `postMigrate` to `apps/stawi/service/repository/migrate.go` (which currently has none).

### F4 — CRITICAL: Seed's production binary hardwires a KYC bypass and a fake loan creator
`apps/seed/cmd/main.go:144-145` — `kycVerifier := business.AlwaysVerifiedKYC{}` / `loanCreator := business.StubLoanCreator{}`. There is no config flag, env var, or build tag gating this. `stubs.go:41` returns `KYCStatusVerified` unconditionally; `stubs.go:66,79,92` return `"stub-application-…"`, `"stub-loan-…"`, `"stub-disb-…"`.
**Trigger:** Deploy seed as-is. Every `POST /loan-requests` passes KYC, is marked `LoanRequestStatusDisbursed` (`loan_request.go:379`), audit-logged as `seed.loan_request.disbursed`, and `AtomicMarkBorrowed` increments the client's `TotalBorrowed` — with no loan account and no money. The credit ladder then promotes clients on fictitious repayments.
**Fix:** Delete `stubs.go` from the production import path (move behind a `//go:build dev` tag or a test package) and make `main()` fail fast when the real `identityv1connect` / `loansv1connect` clients are unconfigured, the way `apps/operations/cmd/main.go:124-127` refuses to boot without a ledger client.

### F5 — CRITICAL: Operations obligations are never created, so `PaymentAllocate` always allocates nothing
`apps/operations/cmd/main.go:217` — `_ = business.NewObligationBusiness(ctx, evtsMan, obRepo, identityCli, perAdapter)`. The result is discarded; `CalculateForGroup` and `CreateLoanObligations` (`business/obligation.go:81,183`) have no caller in the operations process, and the operations proto exposes no obligation RPC.
**Trigger:** Call `PaymentAllocate`. `obRepo.GetByMembershipID` (`payment_routing.go:629`) returns an empty slice, `runAllocationBuckets` allocates 0, `resolvePaymentState` (`:757`) returns `StateCheckCreated`, and every payment sits unallocated forever.
**Fix:** Either expose `ObligationCalculate`/`ObligationStatus` RPCs on `OperationsService` and wire the business into the handler, or delete the dead module and document that stawi is the sole obligation owner.

### F6 — CRITICAL: All state claims and idempotency guards are read-then-*async-emit*, so none of them hold
`frame/v2/events/manager.go:57` — `Emit` is `qm.Publish(...)`, a queue publish. Every "claim" in this codebase treats it as a synchronous write:
- `handlers/operations.go:74-84` — `toBusiness.Save(order)` emits, then `Execute(orderID)` does `toRepo.GetByID(ctx, orderID)` at `transfer_order.go:172`. **The row does not exist yet.** Every first-time `TransferOrderExecute` races the consumer and typically returns `transfer order not found`.
- `transfer_order.go:186-189` — the `StateCheckCreated` "claim for execution" is an emit; two concurrent `Execute` calls both pass the `:181` guard and both run `dispatchSideEffect`. The ledger dedupes on `order.GetID()`, but `sendPayment` (`:493`) does **not** — the borrower is paid twice.
- `payment_routing.go:614-617` — same pattern for `AllocatePayment`'s "concurrency guard".
- `payment_routing.go:218-226` — `GetByTransactionID` dedupe with **no unique index** on the column (`models.go:81` is `index:idx_ip_txn`, not unique).
- `apps/seed/service/business/loan_request.go:226` — idempotency-key lookup before an async insert.
- `apps/stawi/service/business/tenure.go:75` ("no active tenure") and `period.go:147` ("previous period still active") — same.
**Trigger:** Two retries of the loans service's `TransferOrderExecute` call (`apps/loans/service/business/repayment.go:485`) landing within the queue's delivery latency → two `PaymentClient.Send` calls for one repayment.
**Fix:** Do the claim with a conditional SQL `UPDATE … WHERE id = ? AND state = ?` on `RowsAffected`, not an emit. Add the `UNIQUE` index on `incoming_payments.transaction_id` and `INSERT … ON CONFLICT DO NOTHING` for creation, then read back. Keep the emit for downstream projection only.

### F7 — CRITICAL: Stawi `CreateLoanAccount` is not idempotent — a retry originates a second loan
`apps/stawi/service/business/loan_offer.go:262-299` — `createLoanAccountInner` checks only `offer.Response == Accept` (`:273`). It never checks whether `offer.LoanAccountID` / `offer.ApplicationID` is already populated before calling `LoanRequestSave` → `LoanRequestApprove` → `LoanAccountCreate` (`:324,340,349`).
**Trigger:** `loan_origination.json:253` sets `"retry": "default"` (3 attempts) on `create_loan`. A timeout after the loans service commits → retry → a second approved loan account for the same offer, then a second disbursement.
**Fix:** Return early when `offer.LoanAccountID != ""`; pass a stable idempotency key derived from `offerID` into `LoanRequestSave` (`SourceRequestId` is already set to `offerID` at `:321` — enforce uniqueness on it in the loans service).

### F8 — HIGH: `createLoanAccountInner` reports success when loan creation failed
`loan_offer.go:328,344,353` — every downstream failure in `createLoanFromOffer` is `logger.Warn(...); return` (void). `createLoanAccountInner` then returns `result, nil` at `:298`, and `handleCreateLoanAccount` (`workflow_callbacks.go:387`) writes HTTP 200.
**Trigger:** Loans service is down. Workflow's `create_loan` step succeeds with an empty body; `generate_repayment_schedule` then interpolates `{{ vars.loan.body.loan_id }}` as empty and the workflow proceeds as if a loan exists.
**Fix:** Make `createLoanFromOffer` return `error` and propagate; fail the RPC.

### F9 — HIGH: Event handlers swallow duplicate-key errors, acking the message and losing the write
`apps/seed/service/events/loan_request_save.go:83` — `if err := e.repo.Create(ctx, lr); err != nil && !data.ErrorIsDuplicateKey(err) { return err }; return nil`. Identical at `credit_profile_save.go:172`.
**Trigger:** Two loan requests submitted with an **empty** `IdempotencyKey` (not required — `validateRequestInput`, `loan_request.go:610-623`, does not check it) collide on `uq_lr_idempotency` (`models.go:216`, a plain unique index over `''`). The second `Create` fails, the error is swallowed, the queue message is acked — but the seed pipeline already ran `CreateApplication` → `CreateLoanAccount` → `Disburse`. **A disbursed loan with no `seed_loan_requests` row.**
**Fix:** Require a non-empty `IdempotencyKey` in `validateRequestInput`; make the index partial (`WHERE idempotency_key <> ''`); on duplicate key, `GetByID` and `Update` rather than dropping the write (the stawi `upsertOnDuplicate` at `events/upsert_helper.go:69` already does this).

### HIGH: Seed cannot originate any loan out of the box — no `CreditTierConfig` row is ever created
Nothing in the repository (Go, SQL, or config) inserts a `seed_credit_tiers` row. `EvaluateTier` (`credit_profile.go:202`) returns `ErrNoTierConfigured`, which `RequestLoan` (`loan_request.go:269-272`) turns into a 500.
**Fix:** Ship a migration or a seeding job for the default ladder; add an admin endpoint. (`ErrNoTierConfigured` currently has no handler mapping either — it 500s instead of 503/409.)

### HIGH: Seed credit-limit check is skipped when `MaxLoanAmount` is 0
`loan_request.go:263` — `if profile.MaxLoanAmount > 0 && req.Amount > profile.MaxLoanAmount`. `EnsureProfile` (`credit_profile.go:146-154`) only logs a warning if `AtomicPromoteTier` fails, leaving `MaxLoanAmount = 0`.
**Trigger:** Transient DB error during first-profile provisioning → profile persists with limit 0 → the next request for any amount passes the check.
**Fix:** Treat `MaxLoanAmount <= 0` as "deny" and fail `EnsureProfile` when the initial tier cannot be set.

### HIGH: Concurrent seed requests both pass the "one outstanding loan" check
`loan_request.go:258` reads `profile.OutstandingLoanCount`, but `AtomicMarkBorrowed` (`:386`) runs *after* disbursement, and its failure is only logged ("Don't fail the request: the money has moved", `:390`).
**Fix:** Reserve the slot before disbursement with a conditional `UPDATE … SET outstanding_loan_count = outstanding_loan_count + 1 WHERE id = ? AND outstanding_loan_count = 0` and release on failure.

### HIGH: Stawi group activation proceeds after ledger account creation fails
`business/group.go:209-215` — every `LedgerClient.CreateAccount` error is `logger.Warn(...)`; the loop finishes and returns `nil` with "ledger account setup completed". `:183-186` returns `nil` outright when the ledger client is absent.
**Trigger:** Ledger unavailable during `setup_ledger`. `welcome_group` then transitions the group to ACTIVE. Every subsequent transfer targeting `constants.GroupBankAccount(groupID)` fails at post time, after obligations and offers have been generated.
**Fix:** Collect errors and fail the step; make the endpoint safely re-runnable (ledger `CreateAccount` should already be idempotent on `Id`).

### HIGH: Loan offers ignore their own expiry and accept any response value
`loan_offer.go:190-213` — `Respond` checks `offer.State == StateActive` but never reads `offer.ExpiryDate` (set to now+72h at `:131,164`), and accepts any `int32` as `response` without validating it against `LoanOfferResponseNone…Custom` (`models/models.go:27-32`).
**Trigger:** Member accepts a 6-month-old offer priced on stale savings; or sends `response: 99`, which is `!= Accept` so the offer is silently killed, and `createLoanAccountInner` rejects it with a confusing message.
**Fix:** Reject when `ExpiryDate` has passed (and add an expiry sweeper); validate the enum range.

### HIGH: Loan offer amount is derived from one period's contribution, not accumulated savings
`loan_offer.go:148-150` — `periodicDec := decimalx.FromMinorUnits(window.PeriodicAmount, …); maxLoanDec := CalculateMaxLoanAmount(periodicDec, window.Leverage)`. `PeriodicAmount` is documented as the per-period contribution (`models/models.go:54`). Every member in the group receives the **same** offer regardless of their actual savings balance or repayment history.
**Fix:** Query the member's savings balance (savings service) and leverage that; `LoanWindow` already carries `MembershipID` (`models.go:48`) but `GenerateForWindow` iterates all group members and ignores it.

### HIGH: `Leverage` is documented as basis points but divided by 100, and is never bounds-checked
`pkg/calculation/leverage.go:20,33` — `leverageDivisor = 100`, so `190` means 1.90×. But `models/models.go:55`, `leverage.go:24`, and `leverage.go:37` all say "basis points". `products/stawi/config.go:29-30` defines `MinLeverage=190`/`MaxLeverage=220`, and **nothing clamps `window.Leverage` to that range**.
**Trigger:** An operator (or an unauthenticated caller, per F1) sets `Leverage` in true basis points — `19000` — and every member is offered 190× their contribution.
**Fix:** Rename to `LeverageHundredths` throughout and clamp against `MinLeverage`/`MaxLeverage` in `GenerateForWindow`.

### HIGH: `minUnitsToMoney` in stawi hardcodes 2 decimal places, diverging from the ISO-4217 helper
`loan_offer.go:57-65` uses `percentageDivisor = 100` and `moneyNanosFactor = 10_000_000` unconditionally, while `apps/operations/service/models/helpers.go:34` uses `moneyx.FromMinorUnitsByCurrency` (JPY=0, KWD/BHD/OMR=3). The same 2-dp assumption sits at `handlers/operations.go:36` and `transfer_order.go:48`.
**Trigger:** A JPY loan offer of ¥100,000 (minor units 100000) is sent to the limits gate and the loans service as ¥1,000.
**Fix:** Route every conversion through `moneyx.Decimals(currency)`.

### HIGH: Operations UI mislabels every transfer type
`ui/operations/lib/src/screens/transfer_orders_screen.dart:94-102` and `:308-318` map `1=Disbursement, 2=Repayment, 3=Fee, 4=Penalty, 5=Interest, 6=Transfer`. The real values (`pkg/constants/transfer_types.go:19-51`) are `1=Payment, 2=PaymentIdentified, 3=PaymentAllocated, 6=Disbursement, 42=LoanRepayment, 31=Penalty, 46=LoanInterest`; 4 and 5 are not assigned at all.
**Trigger:** An operator filters "Disbursement" and gets raw inbound payments; a `LoanRepayment` (42) renders as "Type 42".
**Fix:** Generate the Dart enum from `pkg/constants/transfer_types.go` (or add the enum to the proto and use the generated one).

### MEDIUM: `allocateBucket` mutates the obligation before computing the `partial` flag
`apps/operations/service/business/payment_routing.go:809` decrements `obl.Amount -= allocAmount`, then `:829` reports `"partial": allocAmount < obl.Amount` against the already-decremented value.
**Trigger:** Obligation 100, remaining 60 → `allocAmount=60`, `obl.Amount` becomes 40, `60 < 40` is false → a partial allocation is reported to the caller as full.
**Fix:** Capture `originalAmount := obl.Amount` before mutating.

### MEDIUM: Obligation-load failure is swallowed and treated as "no obligations"
`payment_routing.go:629-633` — on error, `obligations = nil` and allocation proceeds.
**Fix:** Return the error; leave the payment claimable for retry.

### MEDIUM: Stawi handlers map every error to HTTP 500 and echo `err.Error()` to the client
`workflow_callbacks.go:114,137,158,175,197,213,233,253,280,301,322,342,363,383,421,442,459,477` — all `http.Error(w, err.Error(), http.StatusInternalServerError)`. "group not found", "invalid state transition", and "offer not accepted" are all 500s, so the workflow retry policy (`retry: default`, 3 attempts) hammers permanent failures. The error strings leak internal IDs and, from `identifyByPayerName` (`payment_routing.go:511`), **the payer's name** into HTTP responses and logs.
**Fix:** Use `pkg/apperrors` (`ErrDataNotFound`/`ErrInvalidInput`/`ErrDataConflict` already exist) and `apperrors.CleanErr`, as the operations handler does.

### MEDIUM: `groupBusiness.Create` has a tautological state guard — groups can be created directly as ACTIVE
`apps/stawi/service/business/group.go:51-53` — `if group.GetState() == commonv1.STATE_CREATED { group.State = commonv1.STATE_CREATED }`. Any other state passes straight through to `ClientGroupSave`, skipping formation checks, ledger setup, and lender registration.
**Fix:** Force `STATE_CREATED` on create unconditionally.

### MEDIUM: `Transition` allows shutdown from any state, including DELETED
`group.go:94-95` — `case int32(constants.StateShutdown): valid = true`.
**Fix:** Restrict to `{JustCreated, CheckCreated, Active, Inactive}`.

### MEDIUM: Stawi never migrates the operations tables it writes to
`apps/stawi/service/repository/migrate.go:37-49` registers only the 11 stawi models, but `cmd/main.go:180-184` constructs `opsrepo` repositories for `transfer_orders`, `obligations`, `incoming_payments`, `account_refs`, `cbs_sync_records` against the same pool, and registers save handlers for all of them (`:315-319`). Stawi also skips the partial unique index on `transfer_orders.reference` that `apps/operations/service/repository/migrate.go:80-88` creates — so stawi's transfer-order idempotency guard exists only if operations migrated the same database first.
**Fix:** Make the shared-database dependency explicit (one migration owner, documented ordering) or give stawi its own migration of the shared tables.

### MEDIUM: Workflow `notification.send` steps carry no idempotency key
Every `notification.send` in `products/stawi/workflows/*.json` (~25 call sites, e.g. `loan_origination.json:286`, `savings_collection.json:129,178,224,295`) passes only `template` + `data`. Several sit inside `foreach` loops under a step-level `retry` policy.
**Trigger:** A workflow replay or a partial `foreach` failure re-sends every reminder already delivered in that pass.
**Fix:** Add a deterministic `dedupe_key` (e.g. `"{{template}}:{{member_id}}:{{period_id}}"`) and enforce it in the notification service.

### MEDIUM: Every template name referenced by stawi workflows is unregistered
`group_formation_complete`, `loan_offers_available`, `period_closed_summary`, `savings_obligation_due`, `savings_reminder_first/second/final`, `leader_delinquency_report`, etc. — none appear anywhere in the Go tree. `ui/operations/.../notification_templates_screen.dart:274` claims to mirror `pkg/templates/defaults.go`, **which does not exist**; the names it does list (`template.fintech.agent.*`, `loan_approved`) live in `apps/loans/service/business/notifier.go` and `apps/identity/service/business/agent_notifier.go`.
**Fix:** Register the stawi template set; drive the UI screen off a notification-service RPC instead of a `const` list.

### MEDIUM: Workflow response-shape mismatches even where routes align
`period_lifecycle.json:124` reads `vars.loan_window_result.body.eligible` and `:135` `.window_duration`, but `loanWindowBusiness.Evaluate` (`loan_window.go:77-82`) returns `should_open` / `cycle_position` / `completed_periods` — the loan window never opens. `:183-185` reads `.body.period_id` / `.start_date` / `.end_date`, but `handleOpenPeriod` (`workflow_callbacks.go:217`) JSON-encodes `*models.Period`, which has no `json` tags — the keys are `ID`, `StartDate`, `EndDate`.
**Fix:** Add `json` tags to the response models (or return explicit DTOs) and align the field names; cover with a contract test.

### MEDIUM: `evaluate-loan-window` uses hardcoded product parameters and creates nothing
`loan_window.go:63-66` — `maturityPeriod/gracePeriod/loanTenure/coolOff` come from package constants with the comment "These would typically come from group properties or product configuration" (`:62`), ignoring `products/stawi/config.go:35-37`. And **no code path anywhere creates a `LoanWindow` row**, so `GenerateForWindow` can never find one.
**Fix:** Read from `ProductConfig`/group properties, and implement window creation.

### MEDIUM: Disbursement UI allows double-submit
`disbursement_queue_screen.dart:318-321,330-354` — no in-flight flag or button disable; the dialog pops before `onDisburse` resolves, and the list button remains live.
**Fix:** Guard with a per-item in-flight set; show a progress state; require the host callback to pass an idempotency key.

### MEDIUM: `TransferOrderSearch` paging is unbounded and offset-based
`handlers/operations.go:104-111` — `cursor.GetLimit()` is used verbatim with no clamp, and `limit` defaults to 0 when a cursor is supplied without one. `ui/.../transfer_order_providers.dart:12` hardcodes `limit: 100` with no continuation.
**Fix:** Clamp to a max (e.g. 200), default sensibly, and return a next-page cursor.

### LOW: `resolveAccountRef` silently fabricates a synthetic ledger account on lookup failure
`transfer_order.go:341-359` — any `arRepo.GetByID` error yields `&models.AccountRef{LedgerID: refID, Properties: {"synthetic": true}}`, which is then posted to the ledger.
**Fix:** Distinguish not-found from a DB error; fail on the latter.

### LOW: `registerMembers` is an unbounded N+1 with swallowed errors
`group.go:262-285` — one `RegisterClient` RPC per member (up to `membershipSearchLimit = 1000`, `:37`), sequential, every failure a `Warn`.

### LOW: PII in persisted properties and error paths
`payment_routing.go:927` stores `payer_reference` (typically a phone number) and `payer_name` in `IncomingPayment.Properties`; `:511` embeds the payer name in an error string that reaches HTTP responses via F-MEDIUM above.

### LOW: `service_field.opl.ts` still models the retired Agent domain
`apps/default/service_field.opl.ts:107-113` grants `agent_view` / `agent_manage` / `agent_subagent_manage`; `proto/field/field/v1/field.proto:55` marks `AgentObject` `Deprecated: use identity.v1.WorkforceMemberObject…`, and the 15 `FieldService` RPCs are implemented by `apps/identity/service/handlers/field.go`, not by anything in this audit's scope.

---

## 3. Test Coverage Assessment

**4 test files across ~16k lines of production code in scope. Every handler and every event handler is untested.**

| Area | Coverage |
|---|---|
| `products/stawi/tests/calculation_test.go` (869 L, 27 tests) | **Good.** Table-driven, covers leverage, flat/reducing schedules, dust remainders, penalty escalation, funding allocation, interest distribution, negative clamping, biweekly date advance. This is the only genuinely solid suite. |
| `payment_routing_test.go` (328 L, 3 tests) | **Misleading.** `TestIdentifyPaymentIsIdempotentByTransactionID` passes only because `paymentEventsManagerStub` writes to the repo *synchronously*. Production `Emit` is `qm.Publish` (`frame/v2/events/manager.go:57`). **The test asserts a property the production code does not have** (F6). |
| `transfer_order_limits_test.go` / `loan_offer_limits_test.go` (612 L, 8 tests) | Narrow — only the four limits-gate branches (disabled/allowed/denied/pending). No coverage of `executeInner`, the 33-entry side-effect dispatch, redistribution math, or `createLoanAccountInner`. |

Not covered at all:
- All 4 operations RPC handlers; both request/response converters (`transferOrderFromAPI/ToAPI`).
- `redistributeRepayment` / `redistributeToFundingSource` — the proportional split, last-tranche remainder (`transfer_order.go:568`), fee/tax deduction, and investor balance release. This is the highest-risk money math in operations and has zero tests.
- All 21 stawi workflow-callback handlers; the group state machine (`Transition`); tenure/period open-close; `GenerateForWindow`.
- Every seed path: `RequestLoan`, `HandlePaidOff`, tier evaluation, all `Atomic*` repository methods.
- All 15 event handlers (both `upsertByID` variants, `upsertVersioned`, the duplicate-key branches).
- Migrations — no test exercises `postMigrate`, which would have caught F3 immediately.
- **Zero Flutter tests.** No `test/` directory in `ui/operations`; the wrong enum mapping (F10) and the stub providers would be caught by a single widget test.

**Priorities:** (1) integration tests against a real Postgres + real queue (testcontainers) for the claim/idempotency paths — this is the only way F6 and F3 surface; (2) a workflow-URL contract test (F2); (3) table-driven tests for `redistributeRepayment`; (4) widget tests for the three UI screens.
