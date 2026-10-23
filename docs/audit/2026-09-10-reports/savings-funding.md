## 1. Feature inventory

### SAVINGS — `proto/savings/savings/v1/savings.proto` (20 RPCs) → `apps/savings/service/handlers/savings_service.go`

| RPC | Handler | Status |
|---|---|---|
| SavingsProductSave | :61 | BUG — no org/tenant ownership check on update-by-id; `code` uniqueness only via DB index, error surfaces as 500 |
| SavingsProductGet | :75 | OK |
| SavingsProductSearch | :86 | OK (page-number cursor) |
| SavingsAccountCreate | :103 | BUG — client supplies `ledger_account_id` / `payment_account_ref` / `status`; no product existence or currency-match check |
| SavingsAccountGet | :116 | OK |
| SavingsAccountSearch | :127 | BUG — proto `query` field silently ignored (business/savings_account.go:134-146) |
| SavingsAccountFreeze | :142 | OK |
| SavingsAccountClose | :156 | BUG — closes with non-zero balance / open reservations, no balance check (business/savings_account.go:197) |
| DepositRecord | :173 | BUG (5 defects, see F1–F5) |
| DepositGet | :196 | OK |
| DepositSearch | :207 | OK |
| WithdrawalRequest | :225 | BUG (F3, F5) |
| WithdrawalApprove | :248 | BUG (F6) |
| **WithdrawalCancel** | — | **MISSING** — declared in proto (:846) and in the generated interface (`savingsv1connect/savings.connect.go:141`), business method exists (`business/withdrawal.go:367`), no handler → `UnimplementedSavingsServiceHandler` returns CodeUnimplemented |
| WithdrawalGet | :261 | OK |
| WithdrawalSearch | :272 | OK |
| InterestAccrualGet | :289 | OK |
| InterestAccrualSearch | :300 | OK |
| SavingsBalanceGet | :317 | OK |
| SavingsStatement | :328 | BUG (F12) |
| *(interest accrual engine)* | — | **STUB/DEAD** — `Accrue`/`AccrueAllActive` (`business/interest_accrual.go:140,332`) have zero callers: no RPC, no cron, not wired in `cmd/main.go` |

### FUNDING — `proto/funding/funding/v1/funding.proto` (7 RPCs) → `apps/funding/service/handlers/funding.go`

| RPC | Handler | Status |
|---|---|---|
| InvestorAccountSave | :58 | BUG (F8) |
| InvestorAccountGet | :77 | OK |
| InvestorAccountSearch | :91 | BUG — requires `investor_id` not in the contract (:97), ignores `cursor`, loads all rows and filters currency in memory (:109-114) |
| InvestorDeposit | :122 | BUG (F2, F4) |
| InvestorWithdraw | :152 | BUG (F2, F4) |
| FundLoan | :183 | BUG (F7, F9) |
| AbsorbLoss | :198 | BUG (F10) |
| *(FundingAllocation table)* | — | DEAD — model, repo and event handler registered (`cmd/main.go:165,211`) but nothing ever writes a row |

### UI

| Screen | Status |
|---|---|
| `ui/savings/.../savings_accounts_screen.dart` | BUG — create always rejected (no `organization_id`), no loading/error/empty state |
| `ui/savings/.../savings_products_screen.dart` | BUG — create always rejected (no `organization_id`/`code`/`currency_code`), no period/compounding/min-max fields |
| `ui/savings/.../savings_account_detail_screen.dart` | BUG — best of the six; no approve/cancel, no freeze/close, zero balance renders `—` |
| `ui/funding/.../investor_accounts_screen.dart` | BUG — list permanently empty (server requires `investor_id`), created accounts unusable (no currency) |
| `ui/funding/.../investor_account_detail_screen.dart` | BUG — Deposit/Withdraw 100% non-functional (no `Idempotency-Key` header) |
| Statement, interest accruals, withdrawal approval queue, absorb-loss | MISSING |

Neither UI package is routed by any app — `ui/old-implementation` (the host `lender_ui`) imports only their transport providers (`lib/main.dart:4-5,12-13`) and routes its own local copies. All 13 files are currently dead code.

---

## 2. Findings, most severe first

**F1 · CRITICAL — Deposits never reach COMPLETED; ledger txn id is silently lost.** `business/deposit.go:230-234` emits the same in-memory `dep` a second time to set status COMPLETED. `frame` `datastore/repository.go` `Update` executes `WHERE id = ? AND version = ?` using `entity.GetVersion()`; the business-layer struct was built by `DepositFromAPI` and has `Version == 0`, while the row written by the first emit has `version = 1`. The update matches 0 rows and returns `(0, nil)`; `events/deposit_save.go:63-67` ignores `RowsAffected`. *Trigger:* any successful deposit — money is credited to the balance and posted to the ledger, but the deposit row stays PENDING with an empty `ledger_transaction_id` forever, so reconciliation and statements are wrong. Same mechanism loses the accrual's ledger id at `business/interest_accrual.go:240` and makes every `InvestorAccountSave` update a silent no-op (`events/upsert_helper.go:277-284`). *Fix:* have the save-event handler load the row, copy `Version`, and update, or pass explicit `affectedFields` with a version-free write path; assert `RowsAffected > 0` in `upsertByID`/`DepositSave.Execute`.

**F2 · CRITICAL — Funding deposit/withdraw are not idempotent; the caller's key is discarded.** `handlers/funding.go:126` requires an `Idempotency-Key` header and `business/investor_account.go:140-143` requires the string, but it is never persisted, never looked up, and never used in the ledger reference. The reference is `investor:<id>:deposit:v<version+1>` (`:192`) / `withdraw:v<version>` (`:317`). *Trigger:* (a) two concurrent deposits read the same version → identical reference → operations dedupes to one ledger posting, but `AtomicDeposit` runs twice → balance credited twice with one ledger entry; (b) a client retry after a 504 sees a new version → new reference → second ledger posting *and* second credit. *Fix:* persist an `investor_capital_movement` row keyed on `(account_id, idempotency_key)` unique, short-circuit on hit, and derive the transfer reference from that row's id — never from `version`.

**F3 · CRITICAL — Savings idempotency short-circuit is racy and the empty-key case corrupts silently.** `business/deposit.go:128-133` (and `withdrawal.go:129-134`) read `GetByIdempotencyKey` before writing, but persistence is asynchronous — `eventsMan.Emit` publishes to a queue (`frame/events/manager.go:57-60`). A retry arriving before the consumer commits sees nothing and performs a second full deposit. Worse, `IdempotencyKey` carries `uniqueIndex:uq_dep_idempotency` on a non-null column (`models/models.go:178`, `:242`), so the *second* deposit with an empty key violates the unique index — and `events/deposit_save.go:70` swallows `data.ErrorIsDuplicateKey` and returns nil. *Trigger:* two deposits on any account without an idempotency key (the default: `LIMITS_GATE_ENABLED_SAVINGS_DEPOSIT=false`, and the key is only mandated inside the gated path at `deposit.go:154-157`) → money moves, balance is credited, **no deposit row exists**. *Fix:* make the key mandatory in `recordInner`, use a partial unique index (`WHERE idempotency_key <> ''`) or nullable column, write the deposit row synchronously via the repository before the ledger call, and stop swallowing duplicate-key errors.

**F4 · CRITICAL — Ledger postings are scaled with a hardcoded 2 decimals.** `moneyx.FromSmallestUnit(currency, amount, moneyDecimalPlaces=2)` at `business/deposit.go:296`, `withdrawal.go:348`, `interest_accrual.go:305`, and everywhere in funding (`handlers/funding.go:35,132,162,202,225-229`, `business/investor_account.go:44,157,277,462`), while the models convert with ISO-4217 precision (`models/helpers.go:448-459`, `moneyx.Decimals`). *Trigger:* a ¥100,000 JPY deposit stores 100000 minor units and posts ¥1,000.00 to the ledger (100× under-post); KWD posts 10× over. *Fix:* use `moneyx.Decimals(currency)` at every conversion site; delete the `moneyDecimalPlaces` constants.

**F5 · CRITICAL — Request currency is discarded; cross-currency deposits are credited at face value.** `handlers/savings_service.go:177` (`depAmount, _ := models.MoneyToMinorUnits(...)`) and `:229` throw away the currency, and `business/deposit.go:206` re-labels the amount with `sa.CurrencyCode`. *Trigger:* `DepositRecord{amount: {USD, 100.00}}` into a KES account credits KES 100.00. *Fix:* reject when `amount.currency_code != account.currency_code` (and when the product currency differs) before any write.

**F6 · CRITICAL — Withdrawal approval debits before it posts, with no compensation.** `business/withdrawal.go:273-281` calls `DebitReserved` (which decrements both `balance` and `reserved_balance`) and only then posts the transfer order; on failure it returns without releasing. *Trigger:* operations is down during Approve → the member's money is gone from `balance`, the reservation is gone, the withdrawal is still PENDING, and a retry hits `DebitReserved` again — now failing the `reserved_balance >= ?` guard, so the withdrawal can never be settled and the funds are unrecoverable without manual SQL. *Fix:* post the transfer order first (it is already idempotent on `withdrawal:<id>`), then `DebitReserved`; on transfer failure leave the reservation intact.

**F7 · CRITICAL — FundLoan allocates against fabricated capital.** `business/funding_allocation.go:445-451` uses the loan amount itself as the group-savings first-loss balance, and `:494-501` uses a percentage of the loan amount as the platform reserve — both with in-code NOTEs admitting it. *Trigger:* any group loan is reported `fully_funded` with a tranche-1 source that has no real balance behind it. *Fix:* query the savings service / ledger for the actual group savings and reserve balances; refuse to allocate a source whose balance cannot be verified.

**F8 · CRITICAL — `InvestorAccountSave` is a balance-write endpoint.** `handlers/funding.go:245-256` builds the model straight from `available_balance` and `max_exposure`, and `business/investor_account.go:87-103` force-sets `State = Active` and emits it. On the create path any caller with `investor_account_manage` mints arbitrary capital; on the update path the write silently no-ops (F1) while returning 200 with the caller's numbers echoed back, and `reserved_balance`/`total_deployed`/`total_returned`/`last_deployed_at` are absent from the model entirely. *Fix:* strip balance fields from the save path (balances change only via Deposit/Withdraw/Reserve/Release), load-and-merge on update, and honour the requested `state` only through an explicit state-transition method.

**F9 · CRITICAL — Allocation is not idempotent and reservation failures are ignored.** `funding_allocation.go:93-99` guards on `GetByLoanRequestID`, but the `LoanFunding` rows are written asynchronously (`:163`), so a retried/concurrent `FundLoan` re-runs the whole allocation and calls `AtomicReserve` again; separately `:176-179` only *logs* a reservation failure while still returning the allocation as successful. *Trigger:* double-click FundLoan → investors double-reserved; or a reserve that hits `ErrInvestorInsufficientFunds` → loan reported funded with no capital committed. *Fix:* insert a unique `loan_request_id` funding row synchronously as the idempotency lock, wrap allocation + reservation in one DB transaction, and fail the RPC when any reservation fails.

**F10 · HIGH — `AbsorbLoss` reports a fiction.** `handlers/funding.go:212-214` returns `Absorbed: req.Msg.GetAmount()` unconditionally and never sets `Unrecoverable`; `business/funding_allocation.go:346-351` only logs the unabsorbed remainder and returns nil. It is also non-idempotent — repeated calls keep absorbing until tranches are exhausted. *Trigger:* absorb 1,000,000 against tranches totalling 100,000 → response claims full absorption. *Fix:* return the real `(absorbed, unrecoverable)` from the business method, and key absorption on a loss event id.

**F11 · HIGH — Every business error is returned as CodeInternal.** `pkg/apperrors/errorutil.go:24-36` falls through to `data.ErrorConvertToAPI`, whose fallback is `connect.NewError(connect.CodeInternal, err)` (`frame/data/errors.go:86`); `apperrors.Error.Error()` renders `"422  : - insufficient balance for withdrawal"`, which matches none of the string heuristics. *Trigger:* insufficient funds, frozen account, invalid transition and not-found all surface as 500 with the raw internal message; clients retry non-retriable failures and internal text leaks to callers. *Fix:* implement a `connect.Code` mapping on `apperrors.Error` and return `connect.NewError(code, sanitizedMessage)` in `CleanErr`.

**F12 · HIGH — `SavingsStatement` returns nothing when `to_date` is omitted, is unbounded, unordered, and racy.** `handlers/savings_service.go:332-341` converts unparsed dates to the zero `time.Time`, and `business/savings_account.go:326-327` applies them as `created_at <= ?` → zero rows. There is no limit or cursor on the three searches (`:322-396`), entries are never sorted, the per-entry `balance` field is never populated, `GetByID` runs twice (`:285`, `:297`), and `entries` is appended from `workerpoolConsumeStream` callbacks (`helpers.go:24-32`) with no synchronisation — a data race under `-race` if the pool is concurrent. *Fix:* default `to` to `now` and `from` to `now-90d`, page the query, sort by date, compute the running balance, and collect into a mutex-guarded or per-batch slice.

**F13 · HIGH — No database transaction exists anywhere in either service.** `grep "Transaction("` over `apps/savings` and `apps/funding` returns nothing. Every multi-write flow (deposit row + balance credit + status update; allocation + tranche + reservation; withdrawal debit + status) is a sequence of independent writes across an async event queue and raw SQL. *Fix:* execute the row-write + balance mutation of each money movement inside `db.Transaction(fn)` and keep the ledger call outside it with an outbox.

**F14 · HIGH — Savings accounts accept caller-controlled ledger routing.** `models/models.go:151-152` copies `ledger_account_id` and `payment_account_ref` verbatim from the request, and every deposit/withdrawal posts to them (`deposit.go:294-295`, `withdrawal.go:346-347`). *Trigger:* create an account pointing `payment_account_ref` at another tenant's control account and deposit — the ledger posting debits it. *Fix:* derive both refs server-side from product + account id (as the interest path already does with `constants.ProductSavingsInterestExpenseAccount`), and ignore the request fields.

**F15 · HIGH — `interest_rate` is always 0, so rate-gated investors are never eligible.** `apps/funding/cmd/main.go:290` does `float64(fundingmodels.StringToBasisPoints(lr.GetInterestRate()))`, and that helper is `strconv.ParseInt` (`models/helpers.go:502-508`) — it returns 0 for the proto's decimal format `"12.50"`. `GetEligibleForLoan` then filters `min_interest_rate = 0 OR min_interest_rate <= 0` (`repository/investor_account_repo.go:155`). *Trigger:* every investor with a non-zero `min_interest_rate` is excluded from all loans. *Fix:* parse via `decimalx` to basis points, matching the savings `StringToBasisPoints`.

**F16 · HIGH — Funding source query failures are indistinguishable from "no investors".** `funding_allocation.go:456`, `:475`, `:513` all use `if err == nil {` with no else branch. *Trigger:* a DB blip during `GetEligibleForLoan` produces a silently under-funded loan with a deficit instead of an error. *Fix:* return the error.

**F17 · MEDIUM — Interest accrual is idempotent only against committed rows.** `interest_accrual.go:152-158` checks `GetByAccountAndPeriod`, but the row is written asynchronously; two overlapping runs of the same period both post to the ledger before either row lands (the `uq_ia_account_period` index then rejects the second row, and `events/interest_accrual_save.go:165` swallows the duplicate-key error). Also `days := int64(periodEnd.Sub(periodStart).Hours()/24)` (`:192`) truncates DST-affected periods, and the run is per-account with an N+1 product lookup (`:172`) inside the batch loop. *Fix:* insert the accrual row synchronously as the idempotency lock before posting.

**F18 · MEDIUM — RPC-level audit trail is never persisted.** `auditmw.NewInterceptor("service_savings", nil)` (`apps/savings/cmd/main.go:245`, `apps/funding/cmd/main.go:322`) passes a nil audit client; the interceptor only reaches the audit service when the client is non-nil (`common/audit/audit.go:434`). Every `audit.WithResource/WithAction/WithDetail` call in both handlers ends up in structured logs only. *Fix:* wire the audit service client.

**F19 · MEDIUM — Stale duplicated permission model.** `apps/savings/service/authz/constants.go:262-365` defines permissions (`savings_account_create`, `deposit_record`, `withdrawal_request`, `withdrawal_approve`, `interest_accrual_view`) and roles (`manager`, `agent`, `verifier`, `approver`, `auditor`) that exist in neither the proto `service_permissions` (savings.proto:572-668) nor `service_savings.opl.ts`. Only `NamespaceTenancyAccess` is referenced anywhere. *Fix:* delete everything except the namespace constants — the proto is the source of truth.

**F20 · MEDIUM — `funding.proto` has no validation constraints at all** (no `buf/validate` import, unlike savings), so `account_id`, `investor_id` and amounts are unconstrained at the edge; and `InvestorAccountSearchResponse` (:76) has no next-cursor field, so paging cannot be added without a wire change. `InvestorAccountObject.min_interest_rate` is serialised as a raw integer (`models/helpers.go:496`, `"1250"`) while the savings equivalent uses `"12.50"` — the same field means 1250% vs 12.50% across services.

**F21 · MEDIUM — Missing indexes on the columns actually queried.** `savings_balances.savings_account_id` has a unique index, but `deposits`/`withdrawals` lookups by `idempotency_key` are covered only incidentally; `funding_tranches` `GetByLoanRequestID` runs a correlated subquery against `loan_fundings` (`repository/funding_tranche_repo.go:70`) with no covering index, and all statement queries filter `(savings_account_id, status, created_at)` with only a single-column index (`models/models.go:170`, `:233`). There are no SQL migration files in either app (`apps/*/migrations` do not exist) — schema comes solely from AutoMigrate, so none of this is fixable without a migration directory (per project rule, column/constraint changes need SQL files).

**F22 · LOW — PII in audit metadata and outbound ledger payloads.** `payer_reference` / `recipient_reference` (typically MSISDNs) are written unredacted into audit records (`deposit.go:251`, `withdrawal.go:188`) and into the operations `ExtraData` struct (`deposit.go:288-289`, `withdrawal.go:341`).

### UI findings (verified by sub-review)

- **CRITICAL** `ui/funding/lib/src/providers/funding_providers.dart:71-73`, `:91-93` — deposit/withdraw send no `Idempotency-Key` header; the server hard-rejects (`handlers/funding.go:126-129`). Both actions are 100% non-functional.
- **CRITICAL** `funding_providers.dart:20-22` + `investor_accounts_screen.dart:25,27` — search omits `investor_id` (server-required) and the error is swallowed by `whenOrNull(...) ?? []` → permanently blank table, no error, no retry.
- **CRITICAL** `savings_accounts_screen.dart:278-283` / `savings_products_screen.dart:289-293` — create requests omit proto-required `organization_id` (and `code`/`currency_code` for products); protovalidate rejects every create. The retired screen set them (`ui/old-implementation/.../savings_accounts_screen.dart:163-165`) — a regression.
- **CRITICAL** `investor_accounts_screen.dart:300-304` — no currency set; the server derives account currency from `available_balance.currency_code` (`funding.go:246`), so UI-created accounts fail every deposit with `ErrMissingInvestorContext`. Related: the savings create dialog never sets `ledger_account_id`/`payment_account_ref`, so UI-created savings accounts always fail `ErrSavingsAccountLedgerRefsMissing` (`deposit.go:195`).
- **HIGH** All three list screens (`savings_accounts_screen.dart:32`, `savings_products_screen.dart:32`, `investor_accounts_screen.dart:27`) collapse `AsyncValue` to `?? []` — no loading, error or empty state, and the family provider caches the failure.
- **HIGH** Dead providers: `WithdrawalNotifier.approve` (`savings_providers.dart:287-301`), `SavingsAccountNotifier.freeze/close` (`:137-161`), `absorbLoss` (`funding_providers.dart:125-144`) — no caller; `WithdrawalCancel` has no provider (and no server handler, F above).
- **HIGH** No amount validation on any money dialog (`savings_account_detail_screen.dart:278-284`, `:366-372`; `investor_account_detail_screen.dart:262-266`, `:316-320`) — unparseable input silently submits 0; ui_core's `validateAmount` is unused.
- **HIGH** Zero balances render as `—` (ui_core `money_helpers.dart:33-35`), indistinguishable from unknown, on every balance card.
- **HIGH** Pagination is not implemented: cursor limit 50 set once, `collectStream` drops `hasMore` and caps at 10 batches; the funding server ignores the cursor entirely — lists silently truncate while presenting as complete.
- **MEDIUM** Idempotency keys are generated inside the request builder (`savings_providers.dart:211`, `:273`), so a user retry mints a new key and duplicates the deposit.
- **MEDIUM** Search fires one streaming RPC per keystroke (no debounce); dialog `TextEditingController`s never disposed; `SavingsPeriodType`/`CompoundingFrequency`/min-max deposit have no UI at all; transports default to a hardcoded `https://api.antinvestor.com` URL.
- Positive: no `ref.read(provider.future)` anywhere, and provider invalidation after mutations is correct throughout; enum labels cover all non-UNSPECIFIED values for the status/owner-type enums.

---

## 3. Test coverage assessment

Measured: `go test -cover` → `apps/savings/service/business` **17.0%**, `apps/funding/service/business` **15.7%**. Every other package in both apps reports **no test files** (handlers, repository, events, models, cmd, config, `pkg/fundingcompat`). Both UI packages have **zero** `*_test.dart` and no `test/` directory despite declaring `flutter_test`.

The three existing test files (`deposit_limits_test.go`, `withdrawal_limits_test.go`, `investor_account_limits_test.go`) exercise only limits-gate routing, and they do it against hand-written in-process stubs — including a no-op events manager (`deposit_limits_test.go:57`) and stub repositories. That means the entire class of defects above is structurally untestable by the current suite: no test touches a real Postgres, so the version-mismatch update no-op (F1), the empty-idempotency-key unique violation (F3), the balance guard SQL, the partition/RLS isolation, and the index behaviour are all unverified. There are no handler tests, so `WithdrawalCancel` being unimplemented and the error-code collapse to 500 (F11) went unnoticed. There are no concurrency/race tests for the deposit/withdraw/reserve paths despite those being the correctness core, and no golden test for money conversion across JPY/KWD, which is where F4 lives.

Minimum bar before this ships: testcontainers-backed repository tests for the six `SavingsBalance` mutators and the five `InvestorAccount` atomics (including concurrent callers), a `BaseTestSuite` integration test per money-moving RPC asserting the persisted row state after the async event settles, a table-driven money-conversion test across 0/2/3-decimal currencies, and widget tests for the five screens covering loading/error/empty and form validation.
