## 1. Feature inventory

**RPC → handler** (`apps/identity/service/handlers/identity.go`, 55 RPCs in proto, 50 handler methods)

| RPC group | Status | Note |
|---|---|---|
| OrganizationSave / Get / Search | **BUG** | Save silently no-ops on update (F1); partition injectable (F3); Search limit unbounded (F8) |
| OrgUnitSave / Get / Search | **BUG** | F1, F3, F8 |
| WorkforceMember, Department, Position, PositionAssignment, InternalTeam, TeamMembership Save/Get/Search (18 RPCs) | **BUG** | F1 on every Save; F8 on every Search |
| AccessRoleAssignmentSave / Get / Search | **BUG** | F1, F8, plus unvalidated `role_key` at GLOBAL scope (F4) |
| InvestorSave / Get / Search | **BUG** | F1, F8 |
| **ClientGroupSave / Get / Search** | **BROKEN** | Save unconditionally requires a retired Agent → always 404 (F2); Search drops the cursor entirely (F7) |
| **MembershipSave / Get / Search** | **BUG** | Search drops the cursor entirely (F7); F1 on Save |
| **InvestorAccountSave / Get / Search, InvestorDeposit, InvestorWithdraw** | **MISSING** | Not implemented; `identityv1connect.UnimplementedIdentityServiceHandler` embedded at `identity.go:45` returns `Unimplemented`. Real impls live in `apps/funding` only. Permissions, OPL relations and UI-less proto surface all exist for them (F5) |
| ClientDataSave / Get / List / Verify / Reject / RequestInfo / History | **BUG** | reviewer identity is caller-supplied (F6); no state machine on Verify/Reject; List never paginates past batch 1 (F9); Save is a lost-update race |
| FormTemplateSave / Get / Search / Publish | **BUG** | `Version` field shadows `BaseModel.Version` (F1b); Search leaks raw errors (F12) |
| FormSubmissionSave / Get / Search | **BUG** | Search leaks raw errors (F12); file-URI validator accepts any string |
| FieldService `Agent*` RPCs (same app) | **STUB** | All return 410 `ErrDeprecatedAgentModel` (`business/agent.go:78-119`) |

**UI → screen** (`ui/identity/lib`, from the parallel UI audit; 32 of 55 RPCs have no reachable UI)

| Screen | Status |
|---|---|
| OrganizationsScreen, OrgUnitsScreen, InvestorsScreen, WorkforceMembersScreen, TeamsScreen, DepartmentsScreen, AccessRolesScreen | **BUG** — errors render as an empty table |
| WorkforceMembersScreen "Register Member" + row click | **DEAD BUTTON** — routes don't exist |
| RolesScreen | **STUB** — hardcoded permission matrix, zero RPCs |
| FormTemplatesScreen | **STUB** — read-only, routes to nonexistent paths |
| Client KYC review, form designer, client groups, memberships, investor accounts/deposit/withdraw | **MISSING** |

## 2. Findings

**F1 — CRITICAL — every `*Save` update is a silent no-op.** `apps/identity/service/events/organization_save.go:77` (and identically `workforce_member_save.go:63`, `department_save.go:63`, `position_save.go:63`, `position_assignment_save.go:66`, `internal_team_save.go:63`, `team_membership_save.go:63`, `access_role_assignment_save.go:66`, `investor_save.go:63`, `group_save.go:63`, `membership_save.go:63`, `branch_save.go:68`, `form_template_save.go:63`, `form_submission_save.go:66`, `client_relationship_save.go:66`, `agent_save.go:63`, `client_save.go:63`).
Frame's `Update` does `Where("id = ? AND version = ?", id, entity.GetVersion())` (`frame/v2@v2.1.7/datastore/repository.go:263-278`) and `BeforeCreate` stamps `Version = 1` (`data/model.go:161`). The payload comes from `models.XFromAPI(...)`, which never sets `Version`, so every update runs `WHERE version = 0` and matches zero rows. All 17 handlers load `existing` and then discard it — `if _, err := repo.Update(ctx, m); err != nil` — throwing away `RowsAffected`, so the no-op is invisible and the RPC returns 200 with the caller's own payload echoed back.
Trigger: `OrganizationSave` with an existing `id` and a new `name` → HTTP 200, DB unchanged, subsequent `OrganizationGet` returns the old name.
Fix: in each `Execute`, `m.SetVersion(existing.GetVersion())` (or copy `existing.Version`) before `Update`, and fail when `RowsAffected == 0` (map to 409 Conflict). The dead `SetVersion` helpers at `models/models.go:520` and `:595` show this was designed and never wired.

**F1b — CRITICAL — `FormTemplate.Version` shadows the optimistic-lock column.** `apps/identity/service/models/form_template.go:34` declares `Version int32` on a struct that already embeds `data.BaseModel` (`:31`). Both map to GORM column `version`; the outer field wins, so `GetVersion()` (promoted from `BaseModel`) always returns 0 while `Publish` (`business/form_template.go:157: ft.Version++`) writes the domain version into the lock column. Net effect: a template can be updated while its stored `version` is 0, and once published (`version = 1`) it can never be updated again — silently.
Fix: rename the domain field to `TemplateVersion` with `gorm:"column:template_version"` and add a migration.

**F2 — CRITICAL — `ClientGroupSave` is permanently broken.** `apps/identity/service/business/group.go:63-67` calls `b.agentRepo.GetByID(ctx, group.AgentID)` and returns `ErrAgentNotFound` on failure, but the Agent model is retired: `business/agent.go:78-119` makes every agent write return `ErrDeprecatedAgentModel` (410). No agent can be created, so no agent row exists, so every `ClientGroupSave` returns 404.
Fix: replace the agent gate with an `InternalTeam`/`WorkforceMember` ownership check, matching the workforce migration.

**F3 — HIGH — client-supplied `partition_id` is written verbatim.** `apps/identity/service/models/models.go:127` (`model.PartitionID = obj.GetPartitionId()`) and `:193` (same, `OrgUnitFromAPI`). This runs *before* `GenID`, whose claims-derived default only fires when the field is empty (`frame/v2/data/model.go:60-62`). Postgres RLS `WITH CHECK` (`frame/v2/tenancy/postgres/sql.go:52-54`) is the only backstop, and it accepts **any** partition in the caller's comma-separated inherited list (`sql.go:38`) and accepts **everything** when `app.partition_id` is empty (`sql.go:36-37`).
Trigger: a parent-org admin posts `OrganizationSave{name:"x", partition_id:"<child-org-partition>"}` and plants a record inside a child tenant's partition; a caller whose claims carry no partition writes anywhere.
Fix: on create, always overwrite `PartitionID` from claims (or from the freshly minted child partition) and reject a client-supplied value; on update, never accept it (it is already in `FieldsImmutable`, but the create path is not covered).

**F4 — HIGH — arbitrary `role_key` grantable at GLOBAL scope.** `apps/identity/service/business/workforce.go:545-547` validates only `RoleKey != ""` — there is no allowlist. `validateAccessScope` (`workforce.go:821`) returns `nil` immediately for `ACCESS_SCOPE_TYPE_GLOBAL` (`:829-830`), skipping every org/unit/team containment check that the other branches perform. `AccessRoleAssignmentSave` requires only `access_role_assignment_manage`, which the proto grants to `ROLE_OPERATOR` (`identity.proto:1552` block).
Trigger: an operator calls `AccessRoleAssignmentSave{member_id:<self>, role_key:"platform_admin", scope_type:GLOBAL}` and self-escalates through whatever consumes `role_key` downstream (`business/workforce_platform_access.go`).
Fix: validate `role_key` against the role catalogue from the tenancy/platform-access client, and restrict `GLOBAL` scope to callers holding an explicit platform-admin permission.

**F5 — HIGH — 5 RPCs are published in the contract, the OPL, and the permission manifest, but return `Unimplemented`.** `handlers/identity.go:45` embeds `UnimplementedIdentityServiceHandler`; `InvestorAccountSave/Get/Search`, `InvestorDeposit`, `InvestorWithdraw` have no method. Permissions `investor_account_view/manage` are registered in the proto (`identity.proto:1440-1441`) and OPL (`service_identity.opl.ts:59-60, 262-275`), so clients discover the surface and get a runtime `Unimplemented`. Deposit/withdraw are money movements.
Fix: remove the five RPCs and their permissions from the identity contract (they belong to funding), or delegate to the funding client.

**F6 — HIGH — KYC verification identity is caller-supplied and there is no state machine.** `handlers/identity.go:664, 678, 693` pass `req.Msg.GetReviewerId()` straight through to `Verify/Reject/RequestInfo`, and `identity.go:670, 684, 701` write that same attacker-controlled value into the audit trail. `business/client_data.go:124-151`, `:153-178`, `:180-205` load the entry and overwrite `VerificationStatus` with no check of the current status, so an entry can be re-verified after rejection, or verified twice. Separation of duties is also absent: `ROLE_OPERATOR` holds both `client_data_manage` and `client_data_verify` (proto role_bindings), so the same principal can submit and approve a KYC field.
Fix: derive `reviewer_id` from `security.ClaimsFromContext(ctx).GetProfileID()` and drop the request field; reject transitions out of `VERIFIED`/`REJECTED`; reject when the reviewer equals `entry.CreatedBy`.

**F7 — HIGH — `ClientGroupSearch` and `MembershipSearch` ignore pagination entirely.** `handlers/identity.go:531-532` passes `0, nil` and `:585-586` passes `0, 0` — the proto `cursor` field (`identity.proto:917`, `:986`) is dropped on the floor, and `business/group.go:99` takes the cursor as `_ *data.SearchQuery`. `data.NewSearchQuery()` then applies the 50-row default (`frame/v2/data/search.go:60`), so these two RPCs can only ever return the first 50 rows and no client can page past them.
Fix: thread `req.Msg.GetCursor()` through both business signatures, as the other search paths do.

**F8 — HIGH — no upper bound on `cursor.limit` in any search.** `business/workforce.go:610`, `business/organization.go:153`, `business/investor.go:311`, `business/form_template.go:102`, `business/form_submission.go:255` all do `data.WithSearchLimit(int(cursor.GetLimit()))` with no clamp, and the common `PageCursor` proto has no `lte` rule. Frame caps only the *batch* size at 50, not the total (`frame/v2/data/search.go:73-79`).
Trigger: `WorkforceMemberSearch{cursor:{limit: 100000000}}` streams the entire table.
Fix: `limit = min(max(limit, 1), 200)` in a shared helper.

**F9 — HIGH — `ClientDataList` is declared streaming but sends exactly one batch.** `handlers/identity.go:657` calls `stream.Send(...)` once and returns; there is no loop and no next-cursor in the response (`identity.proto:1252-1255`), so a client with >50 KYC fields cannot reach the rest. `identity.go:637-639` silently swallows the offset parse error (`if v, err := parseInt(p); err == nil`), so a malformed page token silently returns page 1 instead of 400. `parseInt` itself (`identity.go:721-725`) uses `fmt.Sscanf`, which accepts `"12abc"` as 12.
Fix: loop over pages, return a next cursor, and use `strconv.Atoi` with an error response.

**F10 — HIGH — SQL migrations are not in the container image, and their filenames are wrong.** `apps/identity/Dockerfile:31` copies only `/app/binary` into the final stage; `apps/identity/migrations/` is never shipped. Frame's scanner globs `<dir>/*.sql` and returns nil on a missing directory (`frame/v2/datastore/migration/migrator.go:58-61`), so `001_string_based_types` is silently skipped in production. Separately, the framework skips down-files by the suffix `_down.sql` (`migrator.go:69`), but the file is named `001_string_based_types.down.sql` — a **dot**, not an underscore — so if the directory were ever shipped, `sort.Strings` (`migrator.go:63`) would order the *rollback* before the up-file and apply both, converting the string columns to integers and then back.
Fix: `COPY --from=builder /app/apps/identity/migrations /migrations` plus `DATABASE_MIGRATION_PATH=/migrations`, and rename to `001_string_based_types_up.sql` / `_down.sql`.

**F11 — HIGH — migration 001 cannot execute against the schema AutoMigrate produces.** `frame/v2/datastore/pool/implementation.go:220-232` runs `AutoMigrate` **before** the SQL patch files. AutoMigrate materialises `engagement_type` as `varchar(50)` (from `models.go:714`), then `apps/identity/migrations/001_string_based_types.up.sql:25` runs `WHEN engagement_type = 1` → `operator does not exist: character varying = integer`, which Postgres raises at plan time regardless of row count. Same at `:43` and `:61`. On a legacy DB with the integer columns still present, AutoMigrate's `ALTER COLUMN ... TYPE varchar(50)` has no `USING` clause and Postgres rejects the int→varchar cast, hard-failing the setup Job.
Fix: do the type conversion in a pre-AutoMigrate step (`repository/migrate.go:preMigrate`) with an explicit `USING`, and drop the int comparisons from 001.

**F12 — MEDIUM — two RPCs return raw internal errors to clients.** `handlers/identity.go:758-765` (`FormTemplateSearch`) and `:811-817` (`FormSubmissionSearch`) return the business error directly instead of `apperrors.CleanErr(err)`, unlike all 48 other handlers. A GORM/Postgres error surfaces verbatim, leaking table and column names.
Fix: wrap both in `apperrors.CleanErr`.

**F13 — MEDIUM — `preMigrate` failures are swallowed, then AutoMigrate creates fresh empty tables.** `repository/migrate.go:38-40` logs the error as a `Warn` and continues. If `ALTER TABLE banks RENAME TO organizations` (`:84`) or `branches → org_units` (`:95`) fails — e.g. the advisory lock was not acquired and a concurrent boot holds the table — AutoMigrate then creates an empty `organizations`/`org_units` and the service comes up serving zero rows while the real data sits in the old table.
Fix: `return preErr`.

**F14 — MEDIUM — organization and org-unit `code` uniqueness is global, not tenant-scoped.** `models/models.go:74` (`uniqueIndex:uq_organization_code`) and `:143` (`uq_branch_code`) have no tenant/partition/organization component, unlike departments (`:765`), positions (`:818`) and teams (`:921`), which are correctly scoped by `organization_id`. Two effects: tenant A's choice of `code` blocks tenant B (cross-tenant DoS and an existence oracle), and a soft-deleted row keeps occupying the index so the code can never be reused. Worse, the collision is **silent** — `events/organization_save.go:81` and every sibling do `if err := Create(...); err != nil && !data.ErrorIsDuplicateKey(err)`, returning `nil` on duplicate key, so the RPC returns 200 and the row is never written.
Fix: make both indexes composite on `(partition_id, code)`, and stop treating duplicate-key as success on the create path.

**F15 — MEDIUM — `ClientDataSave` is a lost-update race.** `business/client_data.go:64-81` reads by `(client_id, field_key)`, mutates in memory, increments `Revision`, and emits — with no transaction and no row lock. Two concurrent saves for the same field both read revision N and both write N+1; the unique index `uq_cde_client_key` (`models.go:1087-1088`) then makes one insert a silent no-op (F14's swallowed duplicate-key). The same read-modify-write shape appears in `form_template.go:144-160` (`Publish`), where concurrent publishes lose a version bump.
Fix: wrap in `db.Transaction` with `SELECT ... FOR UPDATE`, or move to an `ON CONFLICT (client_id, field_key) DO UPDATE ... WHERE revision = $n` upsert.

**F16 — MEDIUM — KYC history writes are best-effort and can be lost.** `business/client_data.go:97-99, 146-148, 173-175, 200-202` log a `Warn` and continue when `recordHistory` fails. For a regulated KYC audit trail, the entry can transition to VERIFIED with no corresponding history row and the RPC still returns success.
Fix: make history emission part of the same transaction as the entry write and fail the RPC on error.

**F17 — MEDIUM — audit records point at the wrong resource.** `handlers/identity.go:611, 668, 682, 699` tag client-data operations as `audit.ResourceClient` while passing the **entry** ID. Every KYC audit row therefore references a client ID that does not exist.
Fix: add and use `audit.ResourceClientDataEntry`.

**F18 — MEDIUM — `postMigrate` rewrites every searchable table on every boot.** `repository/migrate.go:349-353` issues an unbounded `UPDATE <table> SET searchable = ...` for all 14 tables (`:155-294`) on each migration run, after having just dropped and recreated the trigger (`:333-347`). On a large `clients` or `workforce_members` table this is a full-table rewrite plus bloat on every deploy, inside the advisory lock, blocking the setup Job.
Fix: guard the backfill with `WHERE searchable IS NULL`, or gate it on a schema-version marker.

**F19 — MEDIUM — no max length on `name`/`code`, so oversized values are silently dropped.** `identity.proto:189-190` (`OrganizationObject.name`, `.code`) and `:240-241` (`OrgUnitObject`) declare only `min_len = 1`. The columns are `varchar(255)` / `varchar(50)` (`models.go:73-74`, `:142-143`). Because persistence is asynchronous through the event bus, a 300-char name returns HTTP 200 and the row is never written.
Fix: add `string.max_len = 255` / `= 50` to the proto to match the schema.

**F20 — MEDIUM — file-field URIs are unvalidated.** `business/form_submission.go:188-196` accepts *any* string as a content URI once it fails the base64 heuristic — no scheme or host allowlist — so `javascript:...` or an attacker-controlled external URL is stored in `FileRefs` and later rendered. `looksLikeBase64` (`:217-229`) also rejects any plain-text answer ≥256 chars that lacks `://` in a PHOTO/FILE/SIGNATURE field.
Fix: parse with `net/url` and require `https` plus a configured files-service host.

**F21 — LOW — production OAuth clients can inherit a localhost redirect URI.** `apps/identity/config/config.go:35` defaults `OAuthRedirectURIs` to `http://localhost:5174/auth/callback,...`. This value is fed to `NewLoginClientBusiness` (`cmd/main.go:246-250`), which registers redirect URIs on partition-scoped Hydra clients. If `OAUTH_REDIRECT_URIS` is unset in a deployment, every org's login client accepts a localhost callback.
Fix: no default; fail startup when unset.

**F22 — LOW — `/api/v1/login-targets/` is unauthenticated and enumerable.** `cmd/main.go:436` registers the handler with no interceptors, and `handlers/login_targets.go:56` sets `Access-Control-Allow-Origin: *`. `business/login_client.go:264-280` returns every organization in the tenant (name, code, OAuth client ID) for a root-level client ID. This is arguably intended for a login picker, but it is an unauthenticated tenant-wide directory with no rate limiting.
Fix: rate-limit the endpoint and restrict CORS to the known login origins.

**F23 — LOW — `RegisteredMetrics()` is a hand-maintained duplicate.** `business/metrics.go:61-116` restates the seven counters declared at `:31-58`; the two lists will drift. No counters exist for client-data, form, group or membership operations.

### UI findings (verified by the parallel audit; absolute paths under `ui/identity/lib/src/`)
- **CRITICAL** `screens/workforce_members_screen.dart:69` and `:113` navigate to `/workforce/members/new` and `/workforce/members/:id`; the host router (`ui/seed/lib/app/router.dart:169-176`) defines only `/workforce` and `/workforce/:memberId`. Both the create button and every row are dead.
- **CRITICAL** every list screen renders errors as an empty table: `organizations_screen.dart:71-72`, `org_units_screen.dart:60`, `workforce_members_screen.dart:49`, `investors_screen.dart:48`, `access_roles_screen.dart:52-53`, `teams_screen.dart:37`, `departments_screen.dart:52`, `form_templates_screen.dart:54-55` — all `whenOrNull(data:) ?? []`. Auth expiry looks identical to "no records".
- **HIGH** `workforce_member_detail_screen.dart:488-496` and `workforce_members_screen.dart:572-580` rebuild `WorkforceMemberObject` without `properties`, permanently wiping the display name read at `workforce_member_detail_screen.dart:87-89`.
- **HIGH** `organization_form_wizard.dart:426-432` resolves org type by `t.name.toLowerCase().contains(typeText)`; an empty input matches the first enum value, silently assigning `ORGANIZATION_TYPE_UNSPECIFIED`. The dropdown at `:926-935` is also missing 5 of 13 proto values (`TRADING`, `RETAIL`, `MANUFACTURING`, `LOGISTICS`, `SERVICES`).
- **HIGH** memory-rule violations — `ref.read(provider.future)` in interactive flows at `organization_form_wizard.dart:126`, `:193-198`, `:843-848`.
- **HIGH** the UI defeats F3's intended fix by *setting* `partitionId` on create: `organizations_screen.dart:142-145`, `org_unit_form_dialog.dart:296-300`.
- **HIGH** detail screens create the `Future` inside `build()`, refiring the Get RPC on every rebuild: `organization_detail_screen.dart:44-45`, `org_unit_detail_screen.dart:35-36`, `teams_screen.dart:192-193`, `departments_screen.dart:186-187`.
- **MEDIUM** no pagination anywhere — every provider hardcodes `PageCursor(limit: 50)` and `collectStream` caps at 10 pages (≈500 rows), with no scroll controller on any screen.
- **MEDIUM** `investors_screen.dart:134-143` swallows the save error and still pops the dialog at `:300`, discarding the user's input.
- **MEDIUM** `roles_screen.dart:58-106` is a fabricated hardcoded permission matrix with zero RPCs; `form_templates_screen.dart` routes to `/admin/form-templates/*`, which no router defines.

## 3. Test coverage

**Exists** — 5 Go test files, ~35 tests, all business/repository layer:
- `business/org_unit_test.go` — org-unit search filters, geo-id required, partition inheritance, and two genuine cross-tenant isolation tests (`:444`, `:460`).
- `business/approval_workflow_test.go` — branch/org-unit approval-case lifecycle, client phone-change gating, cross-tenant client Get (`:325`).
- `business/workforce_platform_access_test.go`, `business/tenancy_platform_access_client_test.go` — platform-access provisioning against a fake tenancy client.
- `repository/migrate_test.go` — one test, that `postMigrate` adds the searchable columns.

**Untested critical paths:**
- **Every update path.** No test saves an entity twice and asserts the change persisted — which is exactly why F1 and F1b are undetected. This is the single highest-value gap.
- **Handler layer — zero tests.** No coverage of the 50 handlers: no assertion that permissions map to the right RPCs, that errors map to the right codes, or that the 5 missing RPCs are absent.
- **Migrations.** `migrate_test.go` never exercises `001_string_based_types.up.sql` (it isn't in the image, so nothing runs it), never tests the legacy `banks`/`branches`/`groups` renames, and never tests idempotent re-run.
- **Client data / KYC.** No test of `Save` upsert-and-revision, `Verify`/`Reject`/`RequestInfo` transitions, history recording, or concurrent save.
- **Forms.** No test of `FormTemplatePublish` draft-gating, template-version stamping, required-field validation, or the file-URI validator.
- **Client groups / memberships.** No test — F2 (permanently broken `ClientGroupSave`) would be caught by a single happy-path test.
- **Authorization.** No test that a caller in partition A cannot *write* into partition B (only read isolation is tested), and no test of `role_key`/`GLOBAL` scope escalation.
- **Pagination.** No test that a cursor limit is bounded or that page 2 differs from page 1.
- **Flutter: zero tests.** `ui/identity` has no `test/` directory at all — no widget tests, no form-validation tests, no provider tests.
The second agent returned. Let me verify its highest-severity claims firsthand before publishing them.
