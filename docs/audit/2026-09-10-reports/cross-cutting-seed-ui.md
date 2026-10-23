# Cross-Cutting + Seed UI Production-Readiness Audit

No files were modified.

---

## 1. Inventory

### 1a. Per-service `main.go` wiring

Paths relative to `apps/`. "frame" = provided by `frame.NewServiceWithContext`/`svc.Run` (SIGTERM via `signal.NotifyContext`, `/livez` `/readyz` `/healthz` on the outer mux).

| Service | Auth middleware | Perm reg from proto | Health | Shutdown | Migrations | Outbound client timeouts |
|---|---|---|---|---|---|---|
| **identity** | ✅ both handlers `cmd/main.go:401-417` — but `/api/v1/login-targets/` mounted with **no interceptors** `:429-435` | ✅ `:86-88` (Field excluded) | frame | ✅ `:79` | setup-job only `:76-78,:87-93` | 30s `:295-333`, no retries |
| **loans** | ✅ `:359-364` | ✅ `:82-84` | frame | ✅ `:78` | setup-only `:75-77,:83-89` | 30s `:269-311`, no retries |
| **savings** | ✅ `:247-252` | ✅ `:81-83` | frame | ✅ `:76` | setup-only `:73-75,:82-88` | 30s `:191-211` |
| **funding** | ✅ `:324-329` | ✅ `:89-91` | frame | ✅ `:85` | setup-only `:82-84,:90-96` | 30s `:223-232,:343-352` |
| **operations** | ✅ `:269-274` | ✅ `:88-90` | frame | ✅ `:84` | setup-only `:81-83,:89-95` | 30s `:236-244` |
| **limits** | ✅ ×2 `:203-210,:230-237` — `/admin/archive` authn-only `:250` | ✅ `:85-87` | frame | ✅ `:78` | setup-only `:75-77,:86-92` | n/a |
| **stawi** | ❌ **NONE** — bare mux `:157,:269-286`, 18 money routes | ❌ **NONE** | frame | ✅ `:116` | own `DO_MIGRATION` `:124,:324-338` (Fatal ✅) | 30s `:142-145,:290-299` |
| **seed** | ❌ **NONE** — bare mux `:161-166` | ❌ **NONE** | frame (own `/healthz` `:163` dead) | ✅ `:111` | own `DO_MIGRATION` `:118-124`, **exits 0 on failure** | trustage only `:81-84` |
| **limits-admin** | CLI, bearer from env `:71-79` | n/a | n/a | n/a | n/a | ❌ **no Timeout** `:72-77` |

No runtime migration in any serving path — that dimension is clean. Dockerfiles: all 8 are multi-stage, `USER 65532:65532`, `CGO_ENABLED=0`, no baked secrets. **limits-admin has no Dockerfile, no config package, no CI build target.**

### 1b. Per-Seed route/screen status

| Route | Source | Auth guard | Permission guard | Status |
|---|---|---|---|---|
| `/login` | `login_screen.dart` | n/a | n/a | Real, OIDC redirect |
| `/auth/callback` | `router.dart:204-265` | n/a | n/a | Real |
| `/` Dashboard | `dashboard_screen.dart` | ✅ redirect | ❌ none | **Real data** (14 Thesa queries, `:81-123`) |
| `/organizations`, `/organizations/:id` | `ui/identity` | ✅ | ❌ | Real |
| `/org-units`, `/departments` (+`:id`) | `ui/identity` | ✅ | ❌ | Real; `OrgUnitDetailScreen` passed `organizationId: ''` (`router.dart:147`) |
| `/investors` | `ui/identity` | ✅ | ❌ | Real |
| `/workforce`, `/teams` (+`:id`) | `ui/identity` | ✅ | ❌ | Real |
| `/access-roles` | `ui/identity` | ✅ | ❌ **none** (nav-only) | Real — reachable by URL by any user |
| `/limits/*` (9 routes) | `ui/limits` `limits_routes.dart:28-72` | ✅ | ❌ | Real; all nav targets resolve |

**No route has any permission guard.** The only permission gating anywhere is sidebar visibility (`nav_items.dart:131`).

---

## 2. Findings

### CRITICAL

**C1 — Seed's entire permission system is inert; the backend endpoints it calls do not exist.**
`ui/seed/lib/core/auth/permission_checker.dart:29` POSTs `/ui/capabilities/batch-check`; `:59` GETs `/ui/capabilities`. Grepping `capabilities` across all `*.go`/`*.proto`/`*.yaml`/`*.ts` in the repo returns **zero hits**. Identity's mux registers only Connect handlers plus `/api/v1/login-targets/` (`apps/identity/cmd/main.go:432-435`).
Trigger: both requests 404 → `_fallbackCheck` returns `const <String>{}` (`:91`) → `nav_state.dart:23` `if (permissions.isEmpty) return allItems` → every authenticated user sees and can click **Access Roles**, the org/workforce admin surface. Second fail-open at `app_sidebar.dart:62` (`?? buildNavItems()`) shows everything while the check is in flight, so even a working backend leaks the full menu on every load.
Fix: implement the capabilities endpoint on identity; then make `checkAll` distinguish 404/5xx from "no grants" and make `filteredNavItems` fail **closed** (empty set ⇒ show only unrestricted items), and add a `redirect` guard on `/access-roles` keyed on `access_role_manage`.

**C2 — stawi serves 18 unauthenticated money-moving HTTP endpoints.**
`apps/stawi/cmd/main.go:157`, `:269-286`; routes `service/handlers/workflow_callbacks.go:44-88`. `buildWorkflowMux` builds a bare `http.ServeMux` handed straight to `frame.WithHTTPHandler` — no `connectInterceptors.DefaultList`, no authenticator, no tenancy checker. stawi never calls `svc.SecurityManager()`.
Trigger: `curl -X POST http://service-stawi/api/v1/loan-accounts/{id}/disburse` from any pod in the mesh disburses funds with no credentials and no partition scoping.
Fix: wrap the mux in `httptor.AuthenticationMiddleware(mux, sm.GetAuthenticator(ctx))` (the pattern at `apps/limits/cmd/main.go:250`) plus a tenancy check, and register stawi's proto permissions via a `ShouldRunSetup` branch.

**C3 — seed serves unauthenticated loan origination with caller-asserted identity.**
`apps/seed/cmd/main.go:161-166`; `service/handlers/http.go:73-77`. Same bare-mux defect. `POST /api/v1/seed/loan-requests` reads `client_id` and `actor_id` from the JSON body (`http.go:83-90`).
Trigger: unauthenticated `{"client_id":"<victim>","amount":100000000}` originates a loan attributed to another client.
Fix: as C2, and take actor identity from validated claims, never the request body.

**C4 — seed ships KYC and loan-creation stubs in the production binary.**
`apps/seed/cmd/main.go:144-145`: `business.AlwaysVerifiedKYC{}`, `business.StubLoanCreator{}` (acknowledged `:30-43`).
Trigger: the seed image approves every loan request as KYC-verified and creates no real loan, diverging from the loans service.
Fix: refuse to start when config is non-development and either extension point is a stub.

**C5 — Raw DB/driver error strings reach API clients.**
`pkg/apperrors/errorutil.go:35` → frame `data.ErrorConvertToAPI` calls `connect.NewError(code, err)` with the original error; Connect serialises `err.Error()`.
Trigger: any of the 128 `apperrors.CleanErr(err)` call sites (e.g. `apps/loans/service/handlers/loan_management.go:88`) ships `ERROR: duplicate key value violates unique constraint "idx_..." (SQLSTATE 23505)` — table, column, index names — to the caller.
Fix: `CleanErr` builds a fresh `connect.NewError(code, errors.New(publicMessage))`, logs the original with a correlation id, returns only the id.

**C6 — `apperrors` codes are dead; every domain error maps to `Internal`.**
`pkg/apperrors/errors.go:81` (`ErrorCode()`) has **zero callers**; `CleanErr` (`errorutil.go:24-36`) never inspects it.
Trigger: `apps/loans/service/business/errors.go:20` `ErrLoanProductNotFound` → client gets gRPC 13 / HTTP 500 with body `"404  : - loan product not found  "`. Every `Forbidden`/`Conflict`/`Unprocessable` sentinel across identity/loans/funding/savings degrades identically. Client retry logic and error budgets are wrong.
Fix: `errors.As(err, &appErr)` first in `CleanErr`, map via an explicit total table (400→InvalidArgument, 403→PermissionDenied, 404→NotFound, 409→AlreadyExists, 429→ResourceExhausted, 5xx→Internal), fall back after.

**C7 — Production Keto OPL is generated into `apps/default/` but shipped from `opl/`; they have already diverged semantically.**
`.tmp/Makefile.common:101` generates into `apps/default/`; `.github/workflows/release.yaml:33-39` calls `opl-push.yml@main` whose `opl_source` defaults to `opl` with no `with:` override.
Trigger — already live: `apps/default/service_identity.opl.ts` grants `operator` on `organization_manage`/`branch_manage` while `opl/identity/...` does not; `apps/default/service_loans.opl.ts` removes `member` from `loan_request_submit` while `opl/loans/...` still grants it. Production runs the July identity copy and the April loans copy.
Fix: collapse to one source dir, delete the duplicate tree, add a CI step failing on generator drift.

**C8 — stawi emits audit events nothing persists.**
`apps/stawi/cmd/main.go:244` constructs `audit.NewWriter(evtsMan)` but the file has no `audit.NewRepository` and no `audit.NewEventSave`/`frame.WithRegisterEvents`. Every other audit-using app registers both (operations `:174/:231`, loans `:186/:264`, funding `:168/:214`, savings `:109/:175`, seed `:136/:173`, limits `:116/:163`).
Trigger: a stawi transfer order emits `audit_event.save`, no handler is subscribed, the regulatory record is silently lost; `RecordOrLog` swallows the error.
Fix: wire the repository + `frame.WithRegisterEvents(audit.NewEventSave(...))`; assert at boot that a handler exists whenever a `Writer` with a non-nil manager is built.

### HIGH

**H1 — Expired/failed sessions never redirect to login.** `ui/seed/lib/features/auth/data/auth_service.dart:311-319` marks the user authenticated purely because an `access_token` string exists, without checking expiry; `:322-327` returns `true` on the mere presence of a refresh token and fires refresh with `.ignore()`. `auth_state_provider.dart:18-23` then returns `AuthState.authenticated` even when `ensureValidAccessToken()` returned `null` ("Transient failure - keep session alive"). Trigger: refresh token revoked server-side → `isLoggedInSync` stays `true`, `router.dart:81-85` never redirects, and the user sits in a fully rendered app where every API call 401s. Fix: gate `_cachedIsAuthenticated` on a successful refresh; return `unauthenticated` when `ensureValidAccessToken()` yields null.

**H2 — Logout is local-only; no RP-initiated end-session, no token revocation.** `auth_service.dart:395-409` clears storage and resets the platform but never calls the OIDC `end_session_endpoint` and never revokes the refresh token. Trigger: on a shared browser, "Sign out" then "Sign In" silently re-authenticates the same user from the surviving IdP cookie; the stolen refresh token remains valid at the IdP. Fix: redirect to the issuer's `end_session_endpoint` with `id_token_hint` + `post_logout_redirect_uri`, and POST the refresh token to the revocation endpoint.

**H3 — Refresh/ID tokens in web `localStorage` with no `WebOptions`.** `auth_repository.dart:137` `const FlutterSecureStorage()`; no `WebOptions`/`webOptions` anywhere in `lib/`. On web, `flutter_secure_storage` 10.x stores values in `localStorage` wrapped with an AES key also held in `localStorage` — obfuscation, not protection. Trigger: any XSS (16 `GoogleFonts.*` call sites already pull third-party resources) recovers the refresh token and mints access tokens indefinitely. Fix: keep the refresh token out of the browser — use the BFF/auth-code-with-httpOnly-cookie pattern, or at minimum hold access tokens in memory only and set a `wrapKey` derived from a non-storage secret.

**H4 — Seed's Flutter CI has never been able to pass (two independent breakages).** (a) `.github/actions/flutter-setup/action.yml:52-55` runs `flutter pub get` in `ui/seed`, but `ui/seed/pubspec.yaml:55-62` commits `dependency_overrides` with path deps on `../../../common/ui_core` and `../../../service-profile/ui/{profile,geolocation}` — sibling repos never checked out by `actions/checkout@v7` (`ci.yml:32,51,73`). The pubspec's own comment at `:46-49` admits this. (b) `action.yml:74` runs `dart run build_runner build`, but `build_runner` is in neither `ui/seed/pubspec.yaml` (dev_deps at `:41-44` are only `flutter_test` + `flutter_lints`) nor `pubspec.lock`. Note the stated justification is obsolete: `antinvestor_ui_core` 0.5.1, `ui_profile` 0.2.5 and `ui_geolocation` 0.2.3 are all published. Every sibling package uses the correct gitignored `pubspec_overrides.yaml` pattern (`.gitignore:63`); seed is the only one that committed overrides into `pubspec.yaml`. Fix: drop the three published-package overrides from `pubspec.yaml`, move any remaining local override to `pubspec_overrides.yaml`, and add `build_runner`/`riverpod_generator` to dev_dependencies (or set `run-codegen: false`).

**H5 — `ci.yaml`'s Flutter job is dead, and no `ui/*` package except `ui/seed` is linted or tested.** `.github/workflows/ci.yaml:18-21` calls `flutter-ci.yml@main`, which gates on `[ -f "ui/pubspec.yaml" ]` — that file does not exist, so `has_ui=false` and the job always skips. Even if it ran, its test step is `flutter test || true`. `ci.yml` hardcodes `working-directory: ui/seed` at `:41,:45,:63,:73,:105,:112`; grepping the workflows for `ui/identity|ui/limits|ui/loans|ui/savings|ui/funding|ui/operations` returns zero hits. Trigger: `ui/identity` (27 lib files, powering 8 of Seed's 9 route groups) and `ui/limits` (44 lib files) merge with no `flutter analyze` and no test. Fix: delete the dead job; add a matrix in `ci.yml` over every `ui/*` with a pubspec.

**H6 — Two workflows both named `CI` with colliding `test` job ids.** `.github/workflows/ci.yaml:2` and `ci.yml:2`; `ci.yaml:9` job `test` (Go) vs `ci.yml:47` job `test` (Flutter). Both trigger on PRs to `main`. `ci.yml` has **no `push` trigger**, so `main` gets no Flutter checks post-merge. Trigger: branch protection on `CI / test` is ambiguous and may be satisfied by the wrong job. Fix: rename one workflow and give the jobs distinct ids.

**H7 — Go tests never run with `-race`.** `common/.github/workflows/go-test.yml:29` runs `go test -p 1 -json -v ./...`; the repo's own `.tmp/Makefile.common` `test:` target uses `-race -cover`. Trigger: a data race in the audit writer or limits gate is invisible to CI. Fix: add `-race` to the shared workflow, or run `make test` from `ci.yaml`.

**H8 — Privileged workflows consume mutable `@main` reusable workflows.** `release.yaml:23,29,37,48`, `auto-merge.yaml:11`, `dependabot.yaml:8`, `draft-release.yaml:10`, `publish-release.yaml:9`, `changelog.yaml:10`, `dockerfile-lint.yml:25`, `ci.yaml:13,17,21`. Those jobs hold `packages: write`, `contents: write`, `id-token: write` (GCP WIF for `stawi-identity`) and receive `DEPLOY_REPO_TOKEN`/`BUF_TOKEN`. Also `Makefile:13-17` `curl`s `Makefile.common` from `@main` inside `$(shell ...)` and `include`s it on every `make`. Trigger: one bad commit on `antinvestor/common@main` executes with GHCR push and Cloud Run deploy credentials, and runs shell on every dev box. Fix: pin every `uses:` and the curl URL to a commit SHA with a checksum; bump via Dependabot.

**H9 — Event-push endpoint unauthenticated by default in every service.** Frame default `FRAME_QUEUE_PUSH_AUTH=none` resolves to `push.NoneAuth{}`, and `/_frame/queue` is mounted unconditionally. No config in `apps/*/config/*.go` and no workflow sets the variable. Trigger: an in-mesh POST of a `deposit.save` payload hits the handler at `apps/savings/cmd/main.go:168-176` and writes to the DB, bypassing every Connect interceptor. Fix: set `FRAME_QUEUE_PUSH_AUTH=oidc` per deployment and assert it at boot.

**H10 — Durable-events default is an in-memory queue.** Frame default `EVENTS_QUEUE_URL=mem://frame.events.internal_._queue`, not overridden anywhere. All eight services persist domain state through `frame.WithRegisterEvents`. Trigger: unset in one environment → a deposit is acked, the pod restarts before the handler drains, the row never lands. Silent money loss, no error surface. Fix: fail startup on a `mem://` scheme outside tests.

**H11 — seed exits 0 on migration failure.** `apps/seed/cmd/main.go:118-124` logs `.Error(...)` and returns. Trigger: a migrate job with bad DDL reports success; the serving revision rolls out against an un-migrated schema. Every other service `Fatal`s. Fix: `.Fatal(...)`.

**H12 — Audit rows can be written with no actor and no partition.** `pkg/audit/writer.go:90-91` and `save_event.go:82-84` validate only `EntityType`+`Action`; partition is copied only when `r.Parent != nil` (`writer.go:113-115,:152-154`) — 21 `Parent:` assignments across 25 `RecordOrLog` sites, and only 12 sites set `ActorID`. Related: `writer.go:87-89` returns `nil` (success) when `eventsMan` is nil, silently disabling the whole audit trail; `RecordOrLog` (`:164-172`) swallows failures at every money-movement site (`loans/disbursement.go:239`, `savings/withdrawal.go:172,290`, `funding/investor_account.go:213,339`). Fix: derive actor from `constants.AuditTrailFromContext(ctx)` and require a non-empty partition, rejecting otherwise; return `ErrAuditDisabled` instead of nil; migrate money paths to `RecordTx` (currently used by exactly one caller).

**H13 — operations silently disables payment identification when identity is unreachable.** `apps/operations/cmd/main.go:110-113` warns and continues with `identityCli == nil`; `service/business/payment_routing.go:131-159` skips five identification strategies on nil rather than erroring. Trigger: identity briefly down at boot → every subsequent payment fails to resolve a payer and lands misrouted, with one startup WARN. Fix: `Fatal`, matching the ledger check at `:124-127`. Same class, lower blast radius: `apps/loans/cmd/main.go:104-108` warns where savings `:116-119` and funding `:119-122` correctly `Fatal`.

**H14 — identity's `/api/v1/login-targets/` is unauthenticated with wildcard CORS.** Mounted with no interceptors at `apps/identity/cmd/main.go:435`; `service/handlers/login_targets.go:56` sets `Access-Control-Allow-Origin: *`. Trigger: any origin, unauthenticated, enumerates a partition's org/branch tree by walking `client_id` values from a browser on any site. Fix: allow-list from `OAuthRedirectURIs` (`apps/identity/config/config.go:35`), plus rate limiting.

**H15 — Dark mode makes the entire sidebar unreadable.** `app_theme.dart:392` sets dark `primary: _inversePrimary` = `Color(0xFFB6C7EB)` (pale blue); `app_sidebar.dart:74` paints the sidebar `theme.colorScheme.primary` while every label and icon is hardcoded `Colors.white` (`:164,:180,:305,:314,:413,:422,:443,:480`). `main.dart:106-110` sets `darkTheme` with no `themeMode`, so this is `ThemeMode.system`. Trigger: any user with OS dark mode gets white-on-pale-blue nav at roughly 1.4:1 contrast — the primary navigation is illegible. The dark theme also has no `navigationRailTheme` (light does, `:155`). Fix: give the sidebar its own token (e.g. `surfaceContainerLowest` in dark) or derive text color from `onPrimary`.

### MEDIUM

**M1 — File upload has no size or type limit and no timeout.** `ui/seed/lib/core/api/file_upload_helper.dart:41-62`: `Uint8List` held whole in memory, no MIME check, no byte cap, and `request.send()` at `:62` has no `.timeout(...)`. `:47` uses `getAccessToken()` rather than `ensureValidAccessToken()`, so an expired token 401s instead of refreshing. `:65` `debugPrint`s the full server response body (not stripped in release), and `:68` surfaces the raw body in the user-facing exception. Fix: cap bytes and validate the MIME type before sending; use `ensureValidAccessToken()`; wrap in a timeout; drop the body from both the log and the message.

**M2 — Every service uses the legacy claims binder, so `roles=internal` skips tenancy checks.** All eight go through `connectInterceptors.DefaultList` (identity `:401,:412`; loans `:359`; savings `:247`; funding `:324`; operations `:269`; limits `:203,:230`) = `HonorInternalSkip: true`. Trigger: any token carrying `roles=internal`, including one minted for a different service, reads and writes across every partition. Fix: `DefaultListWithBinder` with `WithoutInternalTenancySkip()`.

**M3 — `/admin/archive` in limits is authenticated but not authorized.** `apps/limits/cmd/main.go:250` wraps only `AuthenticationMiddleware`; the Connect handlers on the same mux additionally get tenancy + function checkers. Trigger: any valid platform token, including another partition's service account, triggers reservation/ledger archival. Fix: add the admin `FunctionChecker`, or move archival onto `LimitsAdminService`.

**M4 — stawi and seed bypass the frame setup plan, so their proto permissions are never registered.** `apps/stawi/cmd/main.go:124,:324-338` and `apps/seed/cmd/main.go:118-124` use legacy `DoDatabaseMigrate()` instead of `svc.Setup().RegisterFunc(setup.NameMigrate, ...)` + `frame.ShouldRunSetup`. This is the root cause that makes C2/C3 unfixable by adding interceptors alone — no permission manifest exists in Keto for either service. Fix: convert both, with `frame.WithPermissionRegistration(sd)`.

**M5 — One failed metric blanks the whole dashboard.** `dashboard_screen.dart:81-123` `Future.wait` over 14 queries; any rejection jumps to `:153-158` and replaces the entire page with an error banner. Fix: settle each independently and degrade per-tile.

**M6 — `SafeInt32FromInt64` silently clamps.** `pkg/constants/safe_convert.go:21-29`. Bounds logic is correct, but a monetary value above 2^31-1 becomes exactly `2147483647` and is persisted as if real. Fix: return `(int32, error)`.

**M7 — Makefile `APP_DIRS` and `UI_DIR` have both drifted from the layout.** `Makefile:3` lists `apps/origination` (dissolved) and omits `apps/seed`, `apps/limits-admin`, `apps/default`, so `make build` (`.tmp/Makefile.common:119-124`, `[ -d $$app_dir/cmd ]`-guarded) never builds seed and `inject-permissions` (`:93-98`) never processes its OpenAPI spec. `Makefile:4` `UI_DIR := ui`, but `ui/pubspec.yaml` does not exist — so `make ui-analyze`, `make ui-build-prod` (`Makefile:44`, the only place production OIDC config is injected) and `make all` all fail. Fix: `APP_DIRS := $(shell ls -d apps/*/)`; `UI_DIR := ui/seed`.

**M8 — Production OIDC client id/issuer hardcoded in two places, and they disagree.** `Makefile:9-10` `OIDC_CLIENT_ID_PROD ?= d6qbqdkpf2t52mcunf60`; `ui/seed/lib/core/config/app_config.dart:11` defaults to `d6qbqdkpf2t52mcunf6g` ("dev client", final char differs) with issuer defaulting to `https://oauth2.stawi.org` and `_apiBaseUrl` to `https://api.stawi.org` (`:15-26`). No secret is exposed — a public client id is correct for a web app — but a build missing its `--dart-define`s silently points a dev client at production. Fix: source both from the environment and fail the build when unset instead of defaulting; never default to a production URL.

**M9 — Sidebar and dashboard disagree on what "width" means.** `seed_shell.dart:17-19` uses `LayoutBuilder` constraints (correct); `dashboard_screen.dart:166-167` uses `MediaQuery.sizeOf(context).width` (whole window). Between 1200 and ~1460px the desktop 4-across KPI row is applied to a content pane 260px narrower than assumed. At 400px both agree and the drawer layout is correct. Fix: use `LayoutBuilder` in the dashboard too.

**M10 — Stale `service_origination.opl.ts` and 8× duplicated base classes.** `apps/default/service_origination.opl.ts` has no `opl/` counterpart and origination is dissolved; the merge script (`opl-push.yml:115-133`) has no delete path, so fixing C7 toward `apps/default` would append a dead namespace permanently. Separately, all 8 `.opl.ts` files redeclare `profile_user` (`:17`) and `tenancy_access` (`:19`), tolerated only by a hardcoded `skip = {...}` at `opl-push.yml:89`. Fix: delete the file, add pruning, emit shared base classes to a generator-owned `_base.opl.ts`.

**M11 — limits-admin CLI has no HTTP timeout and no Dockerfile.** `apps/limits-admin/cmd/main.go:72-77` builds a client over `http.DefaultTransport` with no `Timeout` (the production path at `:82-85` inherits 30s). The directory has only `cmd/`; `release.yaml:41-58` ships only `identity-identity`. Trigger: the documented break-glass tool hangs indefinitely against a wedged endpoint, and is unavailable to any operator without a Go toolchain. Fix: set `Timeout: 30 * time.Second`; add a Dockerfile or drop the "in-cluster production" claim at `:43-44`.

**M12 — No connection-pool tuning on platform clients.** `pkg/clients/platform.go:100-110` passes no `HTTPOption`, so `http.DefaultTransport`'s `MaxIdleConnsPerHost: 2` applies. Client-level timeouts are present and correct at 30s. Trigger: ledger/payment clients churn TLS handshakes under concurrent disbursement load. Fix: explicit transport sized to expected concurrency.

**M13 — `ui/old-implementation` is dead weight.** 270MB, last touched 2026-08-14 by a Dependabot bump, referenced only by `.github/dependabot.yml:78`. No code, workflow, or pubspec outside itself references it. Fix: delete the directory and its dependabot entry.

**M14 — Google Fonts fetched at runtime.** 16 `GoogleFonts.*` call sites; `ui/seed/pubspec.yaml:64-65` bundles no font assets. Trigger: every page load makes a third-party request to `fonts.googleapis.com`; blocked by a strict CSP, and a privacy/GDPR exposure for a fintech console. Fix: bundle the Manrope files as assets.

### LOW

- **L1** `ui/seed/lib/app/router.dart:33-36` — `tenancyInitialized` is a closure-local bool set to `true` *before* the await and never reset on logout. After logout and login as a different user, tenancy is not re-initialized and the previous user's partition/org context persists in `tenancyContextProvider`. Reset it from the logout path.
- **L2** `ui/seed/lib/core/navigation/app_sidebar.dart:108-109` and `nav_items.dart:31` — `currentRoute.startsWith(item.route!)` means the Dashboard item (`route: '/'`) matches every location, so it renders active on every page. Use exact match for `'/'`.
- **L3** `ui/seed/lib/features/auth/data/auth_service.dart:243-273` — `_isPermanentRefreshError` checks transient substrings first, including `'dns'`, `'socket'`, `'500'`, `'429'`. Any permanent error whose text happens to contain those characters is treated as transient and never logs the user out. Match on the structured OAuth `error` field.
- **L4** `ui/seed/lib/features/auth/data/auth_repository.dart:144` — `restoreSelectedClient().ignore()` races `_ensureInitialized()`, which may initialize with the default client before the stored one is restored. Await it.
- **L5** `ui/seed/lib/features/auth/data/auth_service.dart:367-380` — the ID token is base64-decoded with no signature verification, and `partition_id`/`tenant_id`/`roles` are read from it (`auth_repository.dart:97-107`). Client-side only, but it feeds tenancy initialization.
- **L6** `pkg/apperrors/errors.go:78` — `Error()` returns `fmt.Sprintf("%d  : - %s  ", ...)`, embedding a second contradictory HTTP code and double spaces in the wire message. `errors.go:92-98` `Override` concatenates arbitrary inner error strings; currently 0 call sites, so latent. Return just `e.message`; delete `Override`.
- **L7** `pkg/dbmigrate/pool.go:19-31` is a correct pool selector with no leak, but provides no advisory lock. Two overlapping migrate Jobs would race on DDL. Confirm Frame's migrator takes `pg_advisory_lock`, or wrap the caller.
- **L8** Dead code in Seed: `lib/core/auth/role_provider.dart` + `.g.dart` (`LenderRole`, `currentUserRoles` — `main.dart:44` overrides ui_core's provider, not this one), `lib/core/api/files_provider.dart` (both providers unreferenced), `uploadPublicImage` (`file_upload_helper.dart:27`), `ContentConstraint` (`content_constraint.dart`, never instantiated). Five of the six permissions in `permission_manifests.dart:7-43` are batch-checked but never consulted — only `access_role_manage` is used (`nav_items.dart:131`).
- **L9** Untouched Flutter scaffold shipping as product identity: `web/index.html:21,26,32` (`"A new Flutter project."`, title `seed_ui`), `web/manifest.json:2-9` (name `seed_ui`, Flutter-blue `#0175C2`, `orientation: portrait-primary` on a desktop-first admin console), `README.md:1-3`. `index.html` also has no CSP — relevant given H3.
- **L10** `apps/seed/cmd/main.go:163-166` hand-rolled `/healthz` returns 200 unconditionally and is shadowed by frame's readiness-aware handler, so it never fires. Delete it.
- **L11** Base images are floating tags: `golang:1.26` (line 2 of all eight Dockerfiles) and `cgr.dev/chainguard/static:latest` (funding:30, identity:28, limits:28, loans:28, operations:31, savings:28, seed:28, stawi:32). Chainguard `:latest` moves daily, so the same git SHA is not reproducible. Pin `@sha256:`.
- **L12** `pkg/clients/platform.go:183-184,203-206` — a missing endpoint only warns and leaves the field nil; contained today because all three callers hand-check, but a `Required []string` on `ServiceEndpoints` would make it structural.
- **L13** `ui/seed/lib/app/router.dart:147` — `OrgUnitDetailScreen` is constructed with `organizationId: ''`.

---

## 3. Test / CI coverage assessment

| Package | Lint | Test | Race | Workflow | Actually runs? |
|---|---|---|---|---|---|
| All Go pkgs in root module (`pkg/*`, `apps/*`, `products/stawi`, `tools/*`) | ✅ `golangci-lint run` | ✅ `go test -p 1 ./...` | ❌ | `ci.yaml` → `common/*@main` | ✅ |
| `gen/go/*` (4 separate go.mod) | ❌ | ❌ | ❌ | none | — |
| `ui/seed` | ✅ `flutter analyze` + `dart format` | ✅ `flutter test --coverage` | n/a | `ci.yml`, **PR only, no push** | ❌ **broken** (H4) |
| `ui/{identity,limits,loans,savings,funding,operations}` | ❌ | ❌ | n/a | none (H5) | — |
| `ui/old-implementation` (8 test files) | ❌ | ❌ | n/a | none | — |
| `proto/**` | ✅ `buf lint` + `buf breaking` | n/a | n/a | `proto.yml` | ✅ |
| `apps/default/*.opl.ts`, `opl/**` | ❌ no lint, type-check, or drift check | ❌ | n/a | none | — (see C7) |
| `Dockerfile*` | ✅ | n/a | n/a | `dockerfile-lint.yml` | ✅ |

Dart test inventory: `ui/seed` 2 files, of which `test/widget_test.dart` is `expect(1 + 1, equals(2))` with the comment "Placeholder test" — so **one** real suite, `test/dashboard_analytics_test.dart` (280 lines, genuinely good: verifies UTC time ranges, that `tenant_id`/`partition_id` are never client-sent at `:164-165`, and 400/503/empty error paths). `ui/limits` has 1 test file for 44 lib files; `ui/identity` has 0 for 27. Aggregate for the composed app: **3 test files against 106 lib files, none covering auth, routing, permissions, nav filtering, or upload** — every CRITICAL and HIGH finding above sits in untested code.

The 80% coverage gate is decorative: `ci.yml:72-82` is `continue-on-error: true` and emits only `::warning::`, guarded by `if command -v lcov` — and `lcov` is never installed on the runner, so the check is skipped entirely.

**Net CI position:** Go lint and tests genuinely run (without `-race`); proto and Dockerfile linting run. Flutter has **zero effective enforcement** — `ci.yaml`'s job is permanently skipped (H5) and `ci.yml`'s pipeline cannot get past dependency resolution or codegen (H4). Fixing H4 and H5 is the prerequisite for any other UI finding here staying fixed.
