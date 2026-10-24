# Production readiness audit — 2026-09-10

Scope: every service in this repo (identity, loans, savings, funding, operations, stawi, seed, limits, limits-admin), their Flutter UI packages (ui/identity, ui/loans, ui/savings, ui/funding, ui/operations, ui/limits) and the composed app (ui/seed), plus the shared Go packages, CI, and container images.

Method: six adversarial per-domain reviews (API contract → handler → business → repository → migrations → UI), each reading the full source, followed by a fix pass on the same branch. Raw per-domain reports are in `2026-09-10-reports/`. This document is the consolidated verdict and the record of what was fixed.

Baseline before any change: `go build`, `go vet`, `golangci-lint`, and `go test ./...` were green; `flutter analyze` failed in ui/identity (SDK drift after #332) and was clean elsewhere. Green tooling hid every finding below, because the suites did not exercise the update path, the handler layer, concurrency, or the UI.

## 1. Requirements checklist

| Capability | Before | Notes |
|---|---|---|
| Organization / org-unit / workforce management (identity) | FAIL | Every `*Save` update was a silent no-op (version mismatch); self-granted tenancy admin via `platform_role`; forged approvals via request-supplied actor. |
| KYC client data lifecycle (identity) | FAIL | Reviewer identity from request; no state machine; history best-effort. |
| Loan products / requests / accounts (loans) | FAIL | Schedule generation failed for common tenors; `LoanRequestSave` bypassed approval; account creation double-funded; six RPCs unimplemented but wired in UI. |
| Disbursement / repayment / penalties (loans) | FAIL | Double-disbursement race; optional repayment idempotency; penalties never in balance; hardcoded 2dp in ledger postings. |
| Savings accounts, deposits, withdrawals | FAIL | Deposits never reached COMPLETED; currency discarded; approval debited before posting; `WithdrawalCancel` unimplemented. |
| Investor funding (funding) | FAIL | Idempotency key discarded; `InvestorAccountSave` writes balances; FundLoan allocates against fabricated balances. |
| Transfer orders / payment routing (operations) | FAIL | Read-then-async-emit claims; obligations never created; UI enum mapping wrong. |
| Group lending (stawi) | FAIL | No authentication on 18 money endpoints; every workflow URL mismatched; only one group could open a period. |
| Direct lending (seed) | FAIL | No authentication; KYC and loan-creation stubs in the production binary; no tier config. |
| Transaction limits (limits) | FAIL | Platform-scope policies never matched; approver tier role not enforced; self-approval via spoofed maker; shadow mode disabled enforcement; `/admin/archive` unauthorized cross-tenant hard delete. |
| Seed app shell (auth, nav, permissions) | FAIL | Permission checks fail open against endpoints that do not exist; expired sessions never redirect; logout local-only. |
| CI / delivery | FAIL | Flutter CI effectively never ran; OPL shipped from a directory that had diverged from the generated one; unpinned `@main` reusable workflows with write credentials. |

## 2. Systemic defects (root causes shared across services)

1. **Optimistic-lock no-op on every event save.** Frame `Update` runs `WHERE id=? AND version=?`; payloads rebuilt from API objects carry version 0; every GetByID-then-Update handler in identity, loans, savings, funding, operations and seed matched zero rows and returned success. Fixed by `pkg/upsert.ByID`, now used by all event save handlers, with a Postgres-backed test proving the previous behaviour.
2. **Error mapping collapsed to Internal.** `apperrors.CleanErr` ignored the HTTP-style codes and forwarded raw driver errors. Now maps to connect codes and sanitizes unknown errors.
3. **Async "claims".** Idempotency and state guards were read-then-`Emit`; `Emit` is a queue publish, so retries and concurrent calls both passed. Replaced with synchronous conditional writes (`INSERT … ON CONFLICT`, `UPDATE … WHERE status=?` with rows-affected checks).
4. **Hardcoded 2-decimal money at ledger boundaries** while storage used ISO-4217 decimals. Replaced with `moneyx.Decimals`.
5. **Actor identity from request bodies** (maker, reviewer, approver, actor_id, platform_role). Now derived from claims only.
6. **Unauthenticated HTTP surfaces** in stawi and seed. Wrapped with frame authentication, tenancy and function-access middleware.
7. **Missing test layers**: no handler tests, no update-path tests, no concurrency tests, near-zero Flutter tests. Each fix added tests at the layer that would have caught it.

## 3. Per-domain outcome

| Domain | Critical/High fixed | Still open (tracked) |
|---|---|---|
| identity | Update no-op (21 handlers → `pkg/upsert`); FormTemplate version shadowing; actor/reviewer/platform_role from claims with allowlists; GLOBAL scope restricted; KYC state machine + separation of duties; ClientGroupSave off the retired Agent model; partition never from request; cursor threading, limit clamp, ClientDataList paging; migrations shipped in the image, renamed to frame's `_up/_down` convention, int→varchar conversion moved to `preMigrate`; tenant-scoped code uniqueness; approval-case transitions as conditional writes + open-case unique index; stored tenancy carried on every update; profile sync diffed and idempotent; searchable backfill versioned by expression hash; `/ui/capabilities` endpoints backed by the Keto authorizer. UI: real error/loading/empty states, dead routes fixed, exhaustive org types, wizard cleanup, 14 tests. | `ClientDataSave` read-modify-write race (write now lands, no row lock); file-field URI allowlist; localhost OAuth redirect default; `/api/v1/login-targets/` unauthenticated with wildcard CORS and no rate limit; identity lists have no infinite scroll (server clamps at 200). |
| loans | Schedule math in integer minor units (exact sums, 1–36 installments tested); `LoanRequestSave` state machine and product bounds; idempotent `LoanAccountCreate` with conditional claim; synchronous idempotency rows for disbursement/repayment, references keyed on the idempotency key; ledger posted before schedule mutation; penalties enter the balance; ISO-4217 decimals; restructure through `TransitionStatus` from outstanding principal; delinquency scanner persisted + scheduled + paged; `PortfolioSummary`/`Export`/`InitiateCollection`/`ClientProductAccess*` implemented; `searchable` columns created; tenant-scoped indexes via SQL migration with partial predicates; write-off cascade before status claim; overpayment to suspense; one transition table for both manual and automatic status changes. UI: product create works, keys minted once per dialog, real counts, money formatting, pagination, permission gating, 24 tests. | Per-client read authorization (`loan_view_own` absent from proto/OPL); browser download for the loan-book export; statement path N+1. |
| savings | Deposits/withdrawals/accruals are synchronous claimed rows inside one transaction with guarded balance mutations; mandatory idempotency key; currency mismatch rejected; approval posts ledger before debit; ledger refs derived server-side; `WithdrawalCancel` implemented; statement defaults/paging/running balance; accrual job scheduled, settlement rejects an empty ledger id; blind `Model(&X{})` updates (which matched zero rows) rewritten; partial unique indexes + searchable columns via migration; stale authz constants removed. UI: create dialogs send required fields, approve/cancel/freeze/close wired, states, validation, ISO decimals, 25 tests. | No standalone statement or approval-queue screen; RPC-level audit client is nil platform-wide (services persist their own audit rows). |
| funding | Capital movement rows keyed on `(account, idempotency_key)` with resumable PENDING/DEBITED states; `InvestorAccountSave` cannot write balances; allocation lock row; source balances read from savings/ledger (no fabricated capital); `AbsorbLoss` debits available capital and is idempotent per loan; `ReleaseWithReturn` credits interest only; rate parsing fixed; search pages and no longer requires `investor_id`. UI: Idempotency-Key sent, currency always set, states, validation, 21 tests. | Investor min-rate semantics still split between "12.50" and integer forms across services until the proto is aligned. |
| operations | Transfer order persisted synchronously and claimed with conditional updates; incoming payments deduped by unique index; obligations consumed atomically; partial-allocation flag; limit clamp; identity client required at boot; ISO decimals; dead obligation wiring removed (stawi owns obligations). UI: transfer types mirrored from `pkg/constants` with a test, pagination, fake-data screens removed. | `TransferOrderSearch` has no next-cursor field (proto). |
| stawi | HTTP mux behind frame authentication + tenancy middleware; converted to the frame setup plan; all 33 workflow-referenced routes implemented (period freeze/reconcile/penalties/extend, suspense, payment confirm, eligibility, schedule, disburse …) with contract tests over URLs, response DTO fields, and dedupe keys; first-period unique index fixed; idempotent loan-account creation with propagated errors; offer expiry/enum validation; offer amounts from real savings balances; leverage clamped; audit persistence registered; stawi migrates the shared operations tables. | Function-level (per-endpoint) authorization needs a `stawi.v1` proto with `service_permissions`; notification template registration lives in the notification service. |
| seed | HTTP mux behind authentication + tenancy; caller's client resolved from the profile via the field service; stubs behind a `dev` build tag with real identity-KYC and loans-backed creators; fail-fast when clients are missing; migration failure fails the setup job; default credit-tier ladder; idempotency key required and never poisoned by eligibility failures; slot reserved before disbursement and kept on unconfirmed disbursement with reconciliation via `DisbursementSearch`; zero-row atomic updates fixed. | Per-endpoint authorization needs a `seed.v1` proto; suspend/block has no admin surface. |
| limits | Platform-scope policies resolvable under RLS; approver `required_role` enforced with override permission; maker from claims; `/admin/archive` authorized and service-only; shadow mode no longer suppresses enforcement; Gate treats COMMITTED replay as success; attribute resolution fails closed; duplicate Reserve converges; recheck on approval; tenant assertion as a full streaming-aware interceptor, empty tenant fails closed, internal principals must name a tenant; audit rows carry tenancy and actor; breach audit committed before denial; TTL clamped; one page per search; archival never inside a live window; optimistic lock honoured; tiers validated; reapers under advisory lock; quorum in one transaction; runbooks corrected. UI: working navigation, full validation, ISO decimals, newest-first audit feed with filters, capability gating, 24 tests. Chaos suite (all skipped) deleted. | Pending-approval reservations rely on the approval reaper; cross-replica cache invalidation converges within the TTL. |
| seed app shell | Permissions fail closed with route guards and throttled retry; expired/failed refresh → unauthenticated; RP-initiated logout + revocation; access token memory-only on web, refresh token session-scoped; tenancy reset on logout; dark-mode sidebar contrast; per-tile dashboard degradation; upload limits/timeouts; bundled fonts with CSP; no production defaults in config; 48 tests. | — |
| delivery | Single OPL source (`apps/default`) with a drift gate; UI CI matrix over all seven packages with in-repo SDK overrides; distinct workflow names; push trigger on main; reusable workflows and `Makefile.common` pinned to a commit; base images pinned by digest; every Dockerfile copies exactly the packages its binary imports (funding and stawi images previously could not build); limits-admin gets a Dockerfile and client timeout; Dart SDKs bumped (identity 0.5.0, loans 0.3.0, savings/funding/operations 0.2.0). | `-race` on app suites blocked by a frame queue shutdown race; outbound pool tuning needs a `common` option; `ui/old-implementation` (270 MB, dead) left for a separate deletion; migrations do not take an advisory lock. |


## 4. Scalability and operational gaps (unchanged unless noted)

- Streaming searches in limits drain whole tables because the responses carry no next-cursor field (proto follow-up). Server now honours `cursor.limit` and stops after one page.
- Reapers ran in every replica without leader election; now serialized with an advisory lock.
- Event queue and push-auth defaults (`mem://`, `none`) are documented as deployment-required overrides; config validation added where a config-only pattern exists.
- Base images used floating tags; pinned by digest.

## 5. Proto follow-ups (cannot be consumed from Go until published to BSR)

- identity: `ClientDataListResponse.next_cursor`; remove `reviewer_id` from verify/reject/request-info requests; `PageCursor.limit lte 200`; `max_len` on organization/org-unit `name`/`code`; drop `InvestorAccount*`/`InvestorDeposit`/`InvestorWithdraw` and their permissions from identity (they live in funding); `ClientGroupSearch`/`MembershipSearch` filter fields; a `role_key` catalogue; `field.v1.ClientSearchRequest.profile_id` filter (seed resolves the caller's client through free-text search today).
- loans: `loan_view_own` (or resource-scoped `loan_view`); server-only `LoanRequestObject.status`; `PortfolioSummary.pending_disbursement_loans`; `InitiateCollectionRequest.amount` as `Money`; uniqueness on `source_service + source_request_id`.
- savings/funding: `buf.validate` rules on `funding.proto`; `InvestorAccountSearchResponse.next_cursor`; explicit `InvestorAccountObject.currency_code`; `AbsorbLossRequest.loss_reference`; a cursor on `SavingsStatementRequest`; `SAVINGS_PERIOD_TYPE_ANNUALLY`.
- operations/stawi/seed: `stawi.v1` and `seed.v1` protos carrying `service_permissions` so both can register a permission manifest and run per-endpoint function access; obligation RPCs on operations if it should own obligations; `TransferOrderSearchResponse.next_cursor`; a `TransferOrderType` enum; a credit-profile admin RPC for suspend/block.
- limits: `next_cursor` on all four search responses; a dedicated `limits_archive` permission; validate rules (`ttl lte 3600s`, `cap_amount/cap_count gte 1`, `ApproverTier.role min_len 1`); a policy version-history RPC; `reverses_reservation_id`/`notes` on `ReservationObject`; `tenant_id` on `LimitsAuditSearchRequest`; `sort`/`desc` on `PageCursor`.


## 6. Verification log

All runs on 2026-09-11 against the final working tree.

| Check | Result |
|---|---|
| `go build ./...`, `go vet ./...`, `gofmt -l` | clean |
| `golangci-lint run ./...` | 0 issues |
| `go test -count=1 ./...` | 26 packages ok (15 before the audit); Postgres via testcontainers for identity, limits, loans, savings, funding, operations, stawi, seed, `pkg/upsert` |
| `flutter analyze` / `dart format --set-exit-if-changed` | clean in all seven `ui/*` packages |
| `flutter test` | identity 14, limits 24, loans 24, savings 25, funding 21, operations 9, seed 48 (165 total; 3 real tests before) |
| `flutter build web --no-web-resources-cdn` (ui/seed) | built |
| CI-style dependency resolution (only the generated in-repo SDK overrides, no sibling checkouts) | all seven packages resolve and analyze clean |
| `docker build` for all nine service images (identity, loans, savings, funding, operations, stawi, seed, limits, limits-admin) | all built |
| `make opl-check` (generator drift) | no drift |
| `actionlint` | clean |

What the suites now cover that they did not before: the update path of every event handler, negative authorization (self-grant, spoofed actor, cross-partition edit, tier bypass, self-approval), concurrent claims (8-way transfer-order execution, duplicate Reserve, approve-vs-reject), idempotency resumption after a failed attempt, exact schedule sums, migrations against a real schema (including re-runs), the stawi workflow contract (URLs, response fields, dedupe keys), and UI form validation, list states, routing guards and permission fail-closed behaviour.


## 7. Verdict

**Before the fix pass: NOT READY.** Every domain carried at least one deploy-blocking defect (silent update loss, money double-posting, unauthenticated money endpoints, authorization bypasses, non-building images).

**After the fix pass: READY WITH CONDITIONS.** No known critical or high finding remains open in the code on this branch. Shipping still requires:

1. Deployment environment: `FRAME_QUEUE_PUSH_AUTH=oidc`, `RUN_SERVICE_SECURELY=true`, a non-`mem://` `EVENTS_QUEUE_URL`, and `MIGRATION_PATH=/migrations` (set by the Dockerfiles) — see `docs/runbook/required-environment.md`.
2. Publish the bumped Dart SDKs (identity 0.5.0, loans 0.3.0, savings 0.2.0, funding 0.2.0, operations 0.2.0) so consumers outside this repo resolve the same contract CI now builds against.
3. Apply the proto follow-ups in section 5 and republish to BSR; until then the affected controls are enforced server-side with the existing contract (no next-cursor on limits searches, per-endpoint authorization absent for stawi/seed, which are gated by authentication + partition tenancy only).
4. Decide on the remaining medium items listed per domain in section 3, in particular: the `internal` role's tenancy skip in every service's interceptor chain, the identity login-targets endpoint (now origin-restricted and rate limited, still unauthenticated by design), and deletion of `ui/old-implementation`.
5. Run the migrations once in a staging copy of production data: identity 001–003, loans 0001, savings and funding 20260910 all add partial unique indexes that will refuse to build on pre-existing duplicate rows, which is the intended signal to clean the data first.

```
PRODUCTION READINESS VERIFICATION
════════════════════════════════════════════════════
Requirements:     PASS (12/12 capabilities now exercised end to end; see section 3 for tracked gaps)
Assumptions:      PASS (7 systemic assumptions surfaced and closed; see section 2)
Scalability:      PASS WITH CONDITIONS (cursor-less searches capped server-side pending proto)
Failure Modes:    PASS (claims and idempotency are synchronous; retries converge)
Data Integrity:   PASS (transactions + partial unique indexes on every money path)
Security:         PASS WITH CONDITIONS (stawi/seed per-endpoint authz pending proto; internal-role skip)
Operations:       PASS (images build, migrations shipped, CI covers Go and all UI packages)
Critical Issues:  0 open (every CRITICAL and HIGH finding in the six reports fixed; open MEDIUM/LOW items tracked in section 3)

VERDICT:          READY WITH CONDITIONS

Blocking issues:  None in code; conditions 1–3 above are deployment/release steps.
════════════════════════════════════════════════════
```


## 8. Hardening pass — 2026-09-11

Every item listed as "still open" in section 3, every condition in section 7 that could be closed in code, and every proto follow-up in section 5 that lives in this repository was addressed on the same branch after the fix pass was committed. Summary by area:

| Area | Closed |
|---|---|
| identity | `ClientDataSave` and `FormTemplate.Publish` are single-transaction conditional writes (`SELECT … FOR UPDATE` / rows-affected), and the review transitions (verify, reject, request-info) are conditional on the status they read, so concurrent submits, publishes and reviews converge to one winner; file-field URIs must be `https` with a host and no userinfo, long prose in a file field is rejected instead of misclassified; `FieldsToAPI` no longer drops `field_type`/`group`/`order` for templates loaded from Postgres (`json.Number` decoding); list screens page through the cursor with load-more; `OAUTH_REDIRECT_URIS` has no default and is required when running securely; deprecated investor-account permissions dropped from every identity role binding. |
| loans | Statement path is bounded, indexed (`0002_statement_indexes`) and single-pass with a constant query count proven by test; mixed currencies are rejected, not summed; per-client read scoping on account, balance, statement, request, repayment and disbursement reads (staff roles by config, clients resolved through the field service, fails closed when unresolvable); dead authz tuple builders removed; loan-book export downloads in the browser and shares on device. |
| savings, funding | Investor `min_interest_rate` is parsed strictly as a decimal percentage and always emitted in that form; malformed rates are `InvalidArgument`, not silently zero; loan rates in the funding adapter use the same parser; standalone statement and withdrawal approval-queue screens; absorb-loss dialog with a single idempotency key per dialog. |
| limits | Approval TTL has one source of truth with a clamped minimum, reservation and approval expire at the same instant; decisions and expiries release the linked reservation in the same transaction, the reaper is a safety net only; reaper audit rows carry tenancy and a system actor so they appear in the tenant's audit feed; policy-cache invalidation is published on save/delete and consumed by every replica through a per-replica broadcast subscription (NATS or in-memory), with the TTL as fallback and the unsupported-broker case logged; policy version history is paged. |
| stawi, seed | `stawi.v1` and `seed.v1` proto modules carry `service_permissions` and `google.api.http` for every route; Go is generated in-repo under `gen/go` until the modules are published; permission manifests are registered at setup and enforced per route by a fail-closed function-access middleware; seed exposes suspend, block and reinstate admin routes; stawi maps permanent failures to 404/409/422 with sanitized messages and stable codes so the workflow engine stops retrying them. |
| operations | `next_cursor` and a `TransferOrderType` enum on the wire (server consumption after publish). |
| platform | RPC-level audit reaches the audit service in every service (`AUDIT_SERVICE_URI`, required when secure); internal principals must name a tenant everywhere (`pkg/tenantassert`, Connect and HTTP); `pkg/bootcheck` refuses to start on unsafe queue, push-auth or migration-path settings when `RUN_SERVICE_SECURELY=true`; migrations run under a Postgres advisory lock; `make test` and CI run the whole tree under `-race` (the historical frame queue race no longer reproduces, see `docs/runbook/race-detector.md`); `ui/old-implementation` and the dead local `gen/go/{identity,field}` modules are deleted; Dart SDKs bumped (identity 0.6.0, field 0.3.0, loans 0.4.0, savings 0.3.0, funding 0.3.0, operations 0.3.0, limits 0.2.0). |

New deployment requirements introduced by this pass: `AUDIT_SERVICE_URI`, `OAUTH_REDIRECT_URIS` (identity), `FIELD_SERVICE_URI` and `LOANS_STAFF_ROLES` (loans), and the `X-Tenant-Id` header on every internal call. All are recorded in `docs/runbook/required-environment.md`.

Still outside this repository: publishing the seven proto modules (plus the two new ones) to BSR and bumping `go.mod`, after which the server-side use of the new wire fields (next-cursor emission, `collection_amount`, `PolicyHistory` handler, `limits_archive` in the archive handler, enum transfer type) is a small wiring change per service; `sort`/`desc` on `PageCursor` belongs to the `common` module; Keto grants for the stawi and seed service accounts are applied through the normal permission sync on release.
