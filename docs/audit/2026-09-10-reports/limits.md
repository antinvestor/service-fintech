# LIMITS domain — production-readiness audit

## 1. Feature inventory

### RPC → handler status

| RPC | Handler | Status |
|---|---|---|
| `LimitsService.Check` | `runtime_service.go:217` | **BUG** — no error mapping (raw `err` returned); no tenant assertion (interceptor only matches `ReserveRequest`) |
| `LimitsService.Reserve` | `runtime_service.go:229` | **BUG** — idempotency not concurrency-safe; caller-controlled unbounded TTL; `Check` field dropped on replay |
| `LimitsService.Commit` | `runtime_service.go:245` | **BUG** — `GetByID` unscoped, `SetCommittedTx` has no tenant predicate (comment claims one) |
| `LimitsService.Release` | `runtime_service.go:257` | **BUG** — same as Commit; fails 500 if reservation already reaped |
| `LimitsService.Reverse` | `runtime_service.go:269` | OK (only path with an explicit tenant guard, `reservation.go:682`) |
| `LimitsAdminService.PolicySave` | `admin_service.go:54` | **BUG** — no cap/tier/scope validation; optimistic lock deliberately defeated; version numbering incoherent |
| `LimitsAdminService.PolicyGet` | `admin_service.go:66` | **BUG** — returns Frame lock `Version`, not the snapshot version `PolicySave` returns |
| `LimitsAdminService.PolicySearch` | `admin_service.go:78` | **BUG** — `tenant_id` filter ignored; drains entire table; no cursor returned |
| `LimitsAdminService.PolicyDelete` | `admin_service.go:89` | OK |
| `LimitsAdminService.ApprovalRequestList` | `admin_service.go:100` | **BUG** — `tenant_id` ignored, N+1 decisions, no cursor in response |
| `LimitsAdminService.ApprovalRequestGet` | `admin_service.go:111` | **BUG** — no tenant check (unlike `Decide`); raw error passthrough |
| `LimitsAdminService.ApprovalRequestDecide` | `admin_service.go:123` | **BUG** — `required_role` never enforced; maker check trusts caller-supplied `maker_id` |
| `LimitsAdminService.LedgerSearch` | `admin_service.go:135` | **BUG** — drains entire table, no cursor returned |
| `LimitsAdminService.LimitsAuditSearch` | `admin_service.go:147` | **BUG** — same, plus reaper-written events invisible |
| `POST /admin/archive` | `archival_handler.go:322` | **BUG** — authenticated but **not authorized**; RLS-bypassing hard delete |
| Reservation Get/List (any RPC) | — | **MISSING** — no RPC exists; `limits-admin reservations` actually lists approval requests |
| Policy version history RPC | — | **MISSING** — snapshots stored (`policy_repo.go:179`), never exposed |

### Screen → status (ui/limits)

| Screen | Status |
|---|---|
| policy_list | OK (filters commit only on Enter; 500-row ceiling) |
| policy_detail | **BUG** — version-history panel is a shipped placeholder |
| policy_editor | **BUG** — no validation at all; Cancel/Save are dead buttons; tier field crashes |
| policy_verdict_playground | **BUG** — emits requests that cannot pass buf.validate |
| approval_queue | OK |
| approval_request_detail | OK |
| ledger_search | **BUG** — no date filters; oldest-500 only |
| audit_feed | **BUG** — shows oldest 500 events; shadow-breach banner therefore always empty |

---

## 2. Findings

### CRITICAL

**C1. `POLICY_SCOPE_PLATFORM` policies can never match — platform-wide limits silently do not exist.**
`repository/candidate_policy.go:48-65` unions `scope='platform' AND tenant_id=''`, but the query runs on `dbPool.DB(ctx, true)` with **no** `tenancy.WithSkipEnforcement`, while the RLS predicate (`frame/tenancy/postgres/sql.go:32-34`) only admits rows where `row_tenant_id = current_setting('app.tenant_id')`. A row with `tenant_id=''` is invisible to every real tenant. Compounding: `models.PolicyFromAPI` (`models/policy.go:130-204`) never reads `in.tenant_id`, so `BaseModel.GenID` stamps the creator's tenant — a platform policy can't even be *created* with `tenant_id=''`. The file comment at `candidate_policy.go:27-28` asserts a bypass the code does not perform.
*Trigger:* create a platform-scope cap; every tenant's Reserve ignores it.
*Fix:* wrap `FindCandidates` in `tenancy.WithSkipEnforcement(ctx)` and re-add explicit `tenant_id` predicates in SQL; force `tenant_id=''` for `scope=platform` in `PolicyFromAPI`.

**C2. Approver tier `required_role` is never enforced — total tier bypass.**
`business/approval.go:155-156` is an explicit `TODO(plan-4)`. `Decide` checks tenant, maker, pending status and expiry, but never compares `ar.RequiredRole` (`models/approval.go:195`) against the caller's roles. Per the OPL (`apps/default/service_limits.opl.ts:73-77`), `limits_approval_act` is held by `ROLE_OPERATOR`.
*Trigger:* a policy tier requires `cfo` × 2; any operator calls `ApprovalRequestDecide` twice from two accounts and a 10M disbursement is approved.
*Fix:* resolve the caller's roles via the `ResourceAccessChecker`/Keto and reject when `RequiredRole` isn't held; `limits_approval_override` exists in the OPL and proto but is wired to nothing.

**C3. Self-approval: the maker check trusts a caller-supplied field.**
`approval.go:182` compares `claims.GetProfileID()` to `ar.MakerID`, which is copied verbatim from `intent.maker_id` (`reservation.go:427` ← `models/reservation.go:92`). `LimitIntent.maker_id` (`limits.proto:145`) has no validate rule and `TenantAssertionInterceptor` (`handlers/tenant_assertion_interceptor.go:380-389`) rewrites only `tenant_id`.
*Trigger:* maker sends `maker_id: "someone-else"` on Reserve, then approves their own request.
*Fix:* overwrite `intent.maker_id` from claims in the interceptor, exactly as `tenant_id` is handled.

**C4. `POST /admin/archive` has authentication but no authorization, and bypasses RLS to hard-delete across all tenants.**
`cmd/main.go:250` wraps the handler in `httptor.AuthenticationMiddleware` only — no `FunctionAccessInterceptor`, no permission. It calls `HardDeleteTerminalBefore` / `HardDeleteBefore`, both of which do `ctx = tenancy.WithSkipEnforcement(ctx)` and `.Unscoped().Delete(...)` (`reservation_repo.go:366-373`, `ledger_repo.go:197-202`). `archival_handler_auth_test.go` asserts only that a token is required.
*Trigger:* any tenant's ordinary user with a valid OIDC token POSTs to `/admin/archive` → every tenant's terminal reservations >7d and ledger >90d are physically destroyed.
*Fix:* mount behind the same function-access check with a dedicated permission (or restrict to an internal-only listener); remove the public route.

**C5. Shadow-mode policies suppress ledger materialization for enforce-allowed transactions.**
`reservation.go:401-403` sets `resv.IsShadow = true` whenever no enforce policy required approval **and any shadow policy would have breached** — regardless of enforce policies that matched and passed. `Commit` then skips ledger entries entirely (`reservation.go:523`).
*Trigger:* deploy one shadow policy with a deliberately tiny cap (the normal way to start a rollout, per `docs/runbook/limits-rollout.md:22-37`). Every transaction now trips it, every reservation is marked shadow, no ledger rows are written, and every `ROLLING_WINDOW_*` enforce cap reads usage = 0 forever. Shadow mode disables enforcement.
*Fix:* `IsShadow` must mean "no enforce-mode policy matched at all", not "a shadow policy would have breached"; gate on `len(enforceMatched) == 0`.

**C6. Gate re-executes money-moving handlers on retry of an already-committed reservation (shadow mode) / reports failure (enforce).**
`pkg/limits/gate.go:124-153`: on replay with the same idempotency key, Reserve returns the existing reservation with status `COMMITTED` (`reservation.go:252-257`), which falls into the `default:` arm. In `ModeShadow` this fire-and-forget-Releases and **re-runs the handler**; in `ModeEnforce` it returns "unexpected reservation status committed" for an operation that in fact succeeded.
*Fix:* treat `COMMITTED` as success (return nil), `RELEASED`/`EXPIRED`/`REVERSED` as terminal errors.

### HIGH

**H1. Attribute-filtered policies never fire in production — fail-open.**
`cmd/main.go:128` passes `nil` as the identity client (`// identity client wired in a later task`). `attribute_resolver.go:404-407` then returns `(nil, nil)`; `Get` returns nil attrs; `evaluatePredicate` returns `false` on nil (`reservation.go:931-933`), so `reservation.go:261-263` **skips** the policy. For non-client subjects `Get` returns `{}` (`attribute_resolver.go:322-325`) with the same effect.
*Trigger:* any KYC-tier or country-scoped cap is silently inert.
*Fix:* wire the identity client; make attribute-resolution failure fail *closed* for enforce-mode policies (deny or require approval), not skip.

**H2. Concurrent duplicate Reserve returns 500 instead of the existing reservation.**
The idempotency short-circuit (`reservation.go:252`) runs *outside* the transaction; `uq_resv_idempotency` (`migrations/20260506_runtime_indexes.up.sql:18-20`) then rejects the second insert, and `reservation.go:405-407` maps it to `CodeInternal`.
*Trigger:* client timeout + immediate retry → `Internal` → caller's own retry logic sees a non-idempotent failure on a money path.
*Fix:* on unique violation, re-read by `(tenant_id, idempotency_key)` and return that reservation.

**H3. `GetByIdempotencyKey` is not tenant-scoped and its error is discarded.**
`reservation_repo.go:121-128` filters on `idempotency_key` alone (the unique index is `(tenant_id, key)`); both call sites swallow the error with `_` (`reservation.go:252`, `:660`). Under RLS the read is scoped, but a DB error is indistinguishable from "not found" → duplicate creation attempt. The collision error also leaks a reservation ID (`reservation.go:255`).
*Fix:* add `tenant_id` to the predicate, return `(nil,nil)` only on `ErrRecordNotFound`, propagate everything else.

**H4. Auto-reject-on-recheck is dead for exactly the policies that produce approvals.**
`approval.go:313` breaks only on `v.GetBreached()`. But a policy with approver tiers sets `WouldRequireApproval=true` and leaves `Breached=false` (`evaluator.go:94-98`, `:126-130`). Every approval request originates from a tiered policy, so the recheck can never fail on cap grounds.
*Trigger:* subject blows past the cap between Reserve and the final approval; the approval lands, reservation activates, cap is oversubscribed.
*Fix:* treat `Breached || WouldRequireApproval` as a re-breach at recheck time.

**H5. `ApprovalRequestGet` has no tenant check while `Decide` does.**
`approval.go:130-140` calls `approvalRepo.GetByID` with no tenancy assertion; `Decide` adds one at `:169-176` with the comment "approval row must belong to caller's tenant". Defense relies solely on RLS; the asymmetry means one of the two is wrong.
*Fix:* apply the same claims check in `Get` (and in `List`, which drops `req.tenant_id` entirely — `approval.go:103-109`).

**H6. Reaper-written audit events are invisible to every tenant.**
`reaper_reservation.go:68` and `reaper_approval.go:156` use the non-Tx `Record` path → `audit/writer.go:110` emits to the bus → `EventSave.Execute` persists in a queue context with no claims → `tenant_id=''`. `LimitsAuditSearch` then hides those rows under RLS. `limits.reservation.expired_ttl` and `limits.approval.expired` never reach the audit feed.
*Fix:* stamp tenancy from the reaped row (`Record.Parent` / `CopyPartitionInfo`) before emitting.

**H7. Policy-change audit rows have no actor.**
`auditing.go:333-348` and `:352-368` build `audit.Record` with no `ActorID`/`ActorType`, and `Writer.RecordTx` (`audit/writer.go:120-152`) does not default them from claims. "Who raised the disbursement cap" is unanswerable. Symmetrically, `RecordBreachHard`/`RecordBreachShadow` (`auditing.go:95`, `:111`) use the **spoofable** `intent.maker_id` as `ActorID`.
*Fix:* populate `ActorID` from `security.ClaimsFromContext(ctx).GetProfileID()` in `Writer.Record*`.

**H8. Hard-breach and shadow-breach audit rows use the lossy async path.**
`reservation.go:334-338` calls `RecordBreachHard`/`RecordBreachShadow` **after** `tx.Rollback()`, via `RecordOrLog` → events bus. `writer.go:117-121` explicitly documents `RecordTx` as the path for records that "must not be lost". A crash between rollback and bus delivery drops the regulatory record of a denial.
*Fix:* write breach audit rows in a separate committed transaction before returning the denial.

**H9. Reservation TTL is unbounded and caller-controlled.**
`ReserveRequest.ttl` (`limits.proto:344`) has no validate rule; `runtime_service.go:233-236` only replaces `ttl <= 0`. A client can pin cap space for years — the reaper only expires rows past `ttl_at`.
Conversely `pkg/limits/gate.go:103-106` never sets a TTL, so any handler slower than the 5-minute default has its reservation reaped mid-flight, and the subsequent `Commit` fails `FailedPrecondition` **after** the money moved.
*Fix:* add `(buf.validate.field).duration.lte = 3600s` and clamp server-side; have `Gate` set a TTL derived from the handler's own deadline.

**H10. Streaming searches drain the whole table and never return a cursor.**
`PolicySearchResponse`/`ApprovalRequestListResponse`/`LedgerSearchResponse`/`LimitsAuditSearchResponse` (`limits.proto:187`, `228`, `276`, `306`) carry only `data` — no `next_cursor`. The business loops (`policy.go:206-235`, `approval.go:102-126`, `ledger_search.go:190-222`, `audit_search.go:62-109`) iterate until exhaustion with a hard-coded `pageSize = 50`, ignoring the client's `cursor.limit`. The UI compensates by silently truncating at 500 rows (`ui/limits/.../audit_providers.dart:55`).
*Trigger:* `LedgerSearch` with no filters on a busy tenant streams millions of rows.
*Fix:* add `common.v1.PageCursor next_cursor` to each response, honour the requested limit, and stop after one page.

**H11. Ledger hard-delete at 90 days silently corrupts long-window caps.**
`archival.go:213-214` hard-codes 7d/90d with no config. `WindowSeconds` is unbounded (`models/policy.go:102`); a 180-day rolling cap reads a truncated ledger and under-counts usage indefinitely.
*Fix:* make cutoffs configurable and refuse to delete inside `max(window_seconds)` across live policies.

**H12. Policy optimistic locking is explicitly disabled — concurrent edits clobber.**
`business/policy.go:107` sets `pol.Version = prior.Version` on every update, so Frame's lock counter never detects a stale write, and `policy_repo.go:91` uses `tx.Save(p)` (full-row overwrite). `limits-admin`'s `togglePolicyMode` (`policies.go:306-338`) is a read-modify-write with no guard.
*Trigger:* two operators edit the same cap; one change vanishes with no error.
*Fix:* pass the client's version through and let `BeforeUpdate` reject on mismatch.

### MEDIUM

**M1. `validatePolicy` accepts caps that block everything.** `business/policy.go:302-317` checks only window>0, currency presence and `effective_to > effective_from`. `models/policy.go:255-258` returns `0` when `cap_amount` is nil. A `PER_TXN_MAX` policy with no cap → `Value=0` → `evaluator.go:92` breaches every positive amount. Proto has no `gte` on `cap_amount`/`cap_count` either. *Fix:* require `Value > 0` for all kinds except `PER_TXN_MIN`.

**M2. Approver tiers are never validated or sorted.** `pickTier` (`evaluator.go:211-219`) returns the **first** tier whose `up_to` covers the amount. Tiers are persisted in submission order (`models/policy.go:195-201`); an operator entering the catch-all (`up_to=0`) first makes every amount, however small, demand the highest tier — or, reversed, a wide first tier lets a large amount be approved at the lowest tier. `ErrApproverTiersInvalid` (`business/errors.go:23`) is declared and error-mapped (`admin_service.go:167`) but **never returned by any code path** — the same is true of `ErrCurrencyMismatch`. *Fix:* sort ascending by `up_to` (catch-all last) and reject overlaps/gaps with the existing sentinel.

**M3. `approval_ttl = 0` creates instantly-expired approvals.** `reservation.go:430` computes `ExpiresAt = now + ApprovalTTLSec`; an explicit zero-duration `approval_ttl` yields `ApprovalTTLSec=0` (`models/policy.go:178-179`), while the reservation gets the 72h fallback (`reservation.go:1067-1081`). The approval reaper expires it on the next 30s pass and releases the reservation. *Fix:* clamp `ApprovalTTLSec` to a minimum and use one source of truth for both TTLs.

**M4. Reapers run in every replica with no leader election.** `cmd/main.go:156-157` launches both reapers unconditionally; `AcquireAdvisoryLocks` (`advisory_lock.go:279`) exists but is never used by them. `ApprovalRequestRepository.SetStatus` (`approval_repo.go:362-379`) has no status guard and no rows-affected check, so N replicas each emit a duplicate `limits.approval.expired` audit row and a duplicate `EventApprovalExpired`. *Fix:* wrap each reaper pass in `pg_advisory_lock` on a fixed key, and add `AND status='pending'` + rows-affected to `SetStatus`.

**M5. Reservation reaper audits rows it did not expire.** `reaper_reservation.go:58-69` gets `n` rows actually updated from `BulkSetExpired`, then unconditionally audits **all** `rows`. A reservation committed between the SELECT and the UPDATE gets a false `limits.reservation.expired_ttl` audit record. *Fix:* have `BulkSetExpired` return the updated IDs (`RETURNING id`) and audit only those.

**M6. Pending-approval reservations are never TTL-reaped.** `ListExpiredActive` (`reservation_repo.go:397`) filters `status='active'` only; `idx_resv_ttl_active` is likewise partial on `status='active'`. If the approval row's `expires_at` and the reservation's `ttl_at` diverge (they are computed from different sources — `reservation.go:394` vs `:430`), a pending reservation can hold cap space past its own TTL indefinitely.

**M7. Quorum race in `Decide`.** The decision row is written outside the transaction (`approval.go:196-208`), then `ListDecisions` + `approveCount >= RequiredCount` (`:252-263`) is evaluated unserialized. Two concurrent final approvers both enter the "last approver" path, both re-evaluate, both `SetActiveTx`. `SetActiveTx` (`reservation_repo.go:349-355`) has no rows-affected guard so the duplicate is silent. *Fix:* move decision insert + quorum check + activation inside one transaction with `SELECT … FOR UPDATE` on the approval row.

**M8. Reject on an already-reaped reservation returns 500.** `approval.go:226-234` calls `SetReleasedTx`, which errors when the reservation is terminal (`reservation_repo.go:283-285`), failing the whole transaction → `CodeInternal`. *Fix:* tolerate zero rows on the cascade release.

**M9. `Check`, `PolicySave` and all streaming RPCs skip the tenant assertion.** `TenantAssertionInterceptor` is a `UnaryInterceptorFunc` (`tenant_assertion_interceptor.go:370`) that only matches `*limitsv1.ReserveRequest`. `CheckRequest.intent.tenant_id` and `PolicySearchRequest.tenant_id` are caller-controlled. It also passes through unchanged when `claims == nil` (`:375-377`). RLS is the only remaining control. *Fix:* switch on the tenanted field generically, and fail closed on nil claims.

**M10. `ParseMode` silently promotes any unrecognized value to full enforcement.** `gate.go:47-52`: `"off"`, `"OFF"`, `"Shadow"`, or a typo all return `ModeEnforce`. The rollout runbook's coldest rollback (`docs/runbook/limits-rollout.md:59`, `:18`) is literally `off`. All current call sites happen to guard `== "off"` before calling `Gate`, so this is latent — but the documented emergency lever means "enforce" inside the helper it names. *Fix:* make `ParseMode` case-insensitive with an explicit `ModeOff`.

**M11. `LimitBreachedError` is dead.** `pkg/limits/errors.go:239-247` defines it; `Gate` never constructs it. Consumers cannot distinguish a cap breach from an infrastructure failure — they get a raw Connect `FailedPrecondition`.

**M12. `PolicyCache` TTL config is ignored and invalidation is process-local.** `config.go:27` declares `POLICY_CACHE_TTL_SECONDS` (default 60) and `cmd/main.go:115` never passes it; `policy_cache.go:328` hard-codes 30s. `InvalidateTenant` purges only the local process (`:357-359`), so the comment at `:317-318` claiming "sub-second propagation" is false across replicas — a policy change takes up to 30s to land everywhere. The `EventPolicyInvalidate` event is emitted (`policy.go:181`) but nothing subscribes to it in `main.go`.

**M13. N+1 on the approval queue.** `approval.go:116` issues one `ListDecisions` per row inside the page loop (50 queries/page) and discards its error.

**M14. Policy search `query` is an unescaped ILIKE.** `policy_repo.go:133` interpolates the user string into `%…%` without escaping `%`/`_`; `strings.ToLower` on an already-case-insensitive operator is a no-op.

### LOW

**L1.** `PolicyGet` returns `Version = p.Version` (Frame lock counter, `models/policy.go:219`) while `PolicySave` returns `snapshotVersion = len(versions)+1` (`business/policy.go:158`). Two numbering schemes on one field; `limits-admin policies disable` prints the second, `policies show` the first.
**L2.** `snapshotVersion` is computed as a non-atomic `COUNT+1` (`business/policy.go:114`) — concurrent saves produce duplicate version numbers; no unique index exists on `(policy_id, version)`.
**L3.** Version-snapshot append is fire-and-log (`business/policy.go:166-175`) — the policy commits without its audit snapshot.
**L4.** `Reservation.ReversesReservationID` and `Notes` are persisted (`models/reservation.go:60-61`) but absent from `ReservationObject`; reversal linkage is invisible on the wire.
**L5.** `SetExpired`, `SetReversed`, `SetPendingApproval`, `SetActive` (`reservation_repo.go:289`, `:312`, `:333`, `:341`) have no rows-affected guards; `SetReversed` has no status guard at all.
**L6.** `shadowRelease` (`gate.go:188`) spawns a goroutine with `WithoutCancel` and **no timeout**.
**L7.** `moneyx` conversion errors discarded in 6 audit/metadata sites (`auditing.go:377`, `:459`, `:463`, `:490`, `:494`; `approval.go:300`).
**L8.** `limits_approval_override` is granted in the OPL (`service_limits.opl.ts:79-82`) and declared in the proto service permissions (`limits.proto:414`) but no RPC requires it.

### Runbook vs. code discrepancies

| Doc claim | Reality |
|---|---|
| `limits-rollout.md:18,59` — "`=off` … the Gate is a no-op" / "Coldest: flip to `off`" | `ParseMode("off")` → `ModeEnforce` (`gate.go:47-52`). Safe only because each consumer separately guards the literal; the helper itself does the opposite of the doc. |
| `limits-capacity-review.md:22-23` — metric `limits_reserve_subject_contention` "to detect" contention | Does not exist anywhere in the repo. |
| `limits-capacity-review.md:35-38` — "Reaper **releases** on the next pass"; "Pending-approval reservations: TTL **24 hours**" | Reaper sets `expired`, not `released` (`reservation_repo.go:304`). Default approval TTL is **72h** (`models/policy.go:88`, column default 259200). Pending-approval reservations are not reaped at all (M6). |
| `archival-trustage.md:9-27` — "must be a machine/service-account principal" | Nothing checks the principal. Any authenticated token works (C4). |
| `limits-rehearsal-2026-05-06.md:39` — `reservations list --status=pending` | Rejected: the flag parses proto enum names only (`reservations.go:58-66`); the valid form is `--status=APPROVAL_STATUS_PENDING`. The command also lists *approval requests*, not reservations. |
| `limits-rollout.md:12` — "Never skip shadow" | `limits-admin policies enable` sets `POLICY_MODE_ENFORCE` directly (`policies.go:289`); no shadow step. |
| `limits-rollout.md:57` — "Gate still fires Reserve but the verdict comes back ALLOW for everything" after `policies disable` | Correct — `FindCandidates` filters `mode != 'off'` (`candidate_policy.go:53`). But invalidation takes up to 30s across replicas (M12). |

### UI findings (highest severity)

**U1. CRITICAL — Policy editor Cancel/Save are dead buttons.** `policy_editor_screen.dart:89,312` call `Navigator.pop()`, but every entry uses `context.go(...)` (`policy_list_screen.dart:76`, `policy_detail_screen.dart:47`) against flat sibling routes (`limits_routes.dart:28-75`), so the stack depth is 1 and `pop()` is a no-op. No AppBar back button either. *Fix:* `context.push` for detail/editor, or `context.go('/limits/policies')` on cancel.

**U2. CRITICAL — Zero client-side validation in the policy editor.** `policy_editor_screen.dart:319` has no `Form`/validators; `cap_amount_field.dart:66-71` + `money_helpers.dart:83-102` silently leave `units/nanos = 0` on any parse failure. Combined with M1, typing `1,000` and selecting Enforce creates a zero-cap enforce policy that blocks every transaction of that action. *Fix:* `Form` + `cap > 0` for non-count kinds + a confirm dialog before saving `POLICY_MODE_ENFORCE`.

**U3. HIGH — Uncaught `FormatException` in the approver-tier editor.** `approver_tiers_editor.dart:76` uses `Int64.parseInt(v)` (throws) inside `onChanged`; the sibling field at `policy_editor_screen.dart:252` correctly uses `tryParseInt`. Typing `-` or pasting `1,000` red-screens the app.

**U4. HIGH — Approver-tier inputs violate buf.validate with no guard.** `role` defaults to `''` against `min_len=1` (`limits.proto:108`); count is `int.tryParse(v) ?? 1` with no `lte 11` bound (`limits.proto:109-112`). Failure surfaces as a raw `invalid_argument` snackbar.

**U5. HIGH — Rolling-window policies savable with no window.** `window_duration_field.dart:39-42` silently discards unparsable input and can never clear a set window; `policy_editor_screen.dart:262-269` never requires it, so the server rejection at `business/policy.go:303-306` is the first feedback.

**U6. HIGH — Cap truncated to 2 decimals on every edit.** `policy_editor_screen.dart:225` uses `moneyToAmountString`, hard-coded to 2 decimals (`ui_core/.../money_helpers.dart:145-152`), while display uses ISO exponents (`currency_amount_text.dart:17-28`). A KWD cap of 1.234 round-trips as 1.230.

**U7. HIGH — Audit feed shows the *oldest* 500 events.** `audit_providers.dart:55-70` uses `collectStream` (10 pages × server-fixed 50) against `ORDER BY id ASC` (`audit_search.go:90`), never advancing the cursor and never sending `from`/`to`. Consequently `ShadowBreachAlert` (`shadow_breach_alert.dart:31-36`), which filters that page for events <24h old, renders nothing on any table with >500 rows — the shadow-rollout safety signal is permanently blank.

**U8. HIGH — Shipped placeholder.** `policy_version_history.dart:26-29` renders "Version history will land when the admin RPC is exposed" on every policy detail page.

**Also:** `ref.read(provider.future)` for an interactive load plus mutation of the provider-cached message (`policy_editor_screen.dart:59-62`, then `:133`, `:234`, `:277`) — direct project-rule violation; verdict playground sends provably invalid requests (`policy_verdict_playground_screen.dart:58-72`); no date filters despite `from`/`to` on both search requests; no `effective_from`/`effective_to`/`approval_ttl` controls at all, so policies can never be scheduled or expired from the UI; no permission gating on Delete/New/Save; `UsageBar` ratio math overflows on web above ~9M major units (`usage_bar.dart:30-37`); unset timestamps render as `1970-01-01`.
*Enum coverage is complete* — all 7 proto enums fully mapped in `enum_labels.dart`; the only weakness is `default:` fallthrough, so a future enum value renders as "Any" instead of failing the build.

---

## 3. Test coverage assessment

**Go — broad but shallow on exactly the properties that matter.**

Strong: repository-level RLS isolation (`policy_repo_test.go:TestTenantIsolation`, `ledger_repo_test.go:TestWindowSumTx_AppliesTenantPartition`), the four cross-tenant integration tests, the reservation state machine (23 cases in `reservation_test.go`), reaper boundary conditions, and `pkg/limits/gate_test.go` (10 cases including detached-context release).

Gaps:
- **The concurrency tests assert only an upper bound.** `reservation_concurrent_test.go:80-83` asserts `successes ≤ 10`; a regression that denies *all 20* passes. No lower bound, no assertion that the ledger/pending sum equals the successes.
- **The chaos suite is inert.** Every fault injector in `pkg/limits/chaostests/setup.go` opens with `t.Skip(...)` (`:103`, `:125`), and the non-skipping tests exercise a hand-written `partitionedLimitsStub`, not the service. Four "chaos" tests validate a mock's return value.
- **No test for tier bypass or self-approval.** `TestDecide_MakerCannotApprove` seeds `MakerID` server-side, so C3 is invisible. No test asserts `required_role`.
- **No test for concurrent Reserve with the same idempotency key** (H2) — `TestReserveIdempotencyReplay` is sequential.
- **No test for `IsShadow` when an enforce policy also matched** (C5); `TestCommit_ShadowSkipsLedger` codifies the buggy behaviour as correct.
- **No test for platform-scope candidate resolution under RLS** (C1) — `candidate_policy_test.go` has a single case, and the suite context always carries a tenant.
- **No test of `/admin/archive` authorization** — `archival_handler_auth_test.go` tests authentication only, and `TestArchivalHandler_AcceptsValidToken` actively asserts C4's behaviour is correct.
- Nothing covers window rollover boundaries, clock skew, `approval_ttl = 0`, multi-replica reaper duplication, or pagination cursor correctness.

**Flutter — effectively untested.** `ui/limits/test/` contains exactly one file, `currency_amount_text_test.dart` (78 lines, 6 cases), covering one leaf widget in a ~4.3 kLoC package. Highest-value additions, in order: policy-editor validation and the `PolicyObject` it emits per `LimitKind` (would catch U2/U5/U6); `approver_tiers_editor` input handling (U3/U4); `duration_format` parse/format round-trip (pure functions, currently silently dropping input); provider invalidation with a fake admin client; a navigation test over `limitsRoutes()` asserting Cancel returns to the list (U1); an enum-label exhaustiveness loop.

**Go-live blockers:** C1–C6 and H1 must be fixed before enforce mode is enabled for any action; H9 and C4 before the service is exposed at all.
