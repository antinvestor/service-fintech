# Limits — Capacity Review

## Production targets

| Metric                | Target           | Headroom |
|-----------------------|------------------|----------|
| Reserve p99 latency   | <50ms            | 30%      |
| Commit p99 latency    | <50ms            | 30%      |
| Throughput            | 1k rps sustained | 50%      |
| Approval-queue depth  | <100 pending     | n/a      |

## Bottlenecks identified during load testing

**Status:** Targets and headroom expectations below were established from architecture review. Actual measurements from production load tests should be filled in after each staging run; see `pkg/limits/loadtests/README.md` for the harness.

1. **DB connection pool**: at 1k rps Reserve+Commit, the limits service
   needs ~80 connections per pod. Pool size set to 100; HPA target CPU
   60% so pods scale before connection saturation.
2. **Advisory locks on subject_id**: Reserve serialises per-subject. At
   1k rps with 1k unique subjects, no contention. With <100 unique
   subjects (e.g. concentrated traffic on a single account), Reserve
   degrades to sequential per-subject. There is no dedicated contention
   metric yet; detect it from Reserve p99 latency against a flat request
   rate, or from `pg_locks` on the advisory-lock class.
3. No outbox; cap reconciliation via TTL + audit pipeline.

## Headroom plan

- 50% above peak production load. If Reserve sustained traffic exceeds
  1.5k rps, scale limits service replicas and DB pool linearly.
- Approval-queue depth >500: page on-call. Either pending volume is
  spiking (legitimate — investigate cause) or approvers are not
  acting fast enough (process issue).
## Reaper SLAs

Both reapers run every 30s and take a Postgres advisory lock, so exactly one
replica reaps per pass however many are running.

- Reserved-but-not-committed reservations: TTL defaults to 5 minutes when the
  caller does not ask for one, and is clamped server-side to a maximum of
  1 hour. The reaper transitions them to `expired` (not `released`) on the
  next pass after `ttl_at`.
- Pending-approval reservations: the reservation's `ttl_at` and the approval
  request's `expires_at` are the same instant, derived from one value — the
  shortest *effective* `approval_ttl` across the policies that demanded
  approval. The effective TTL is clamped at save time and again at read time
  (`Policy.EffectiveApprovalTTL`): unset/zero → **72 hours**, anything under
  **15 minutes** → 15 minutes. A policy can therefore never produce an
  approval that is born expired, even from a hand-edited row.
- Settling a pending-approval reservation is the decision's job, not the
  reaper's: `ApprovalRequestDecide` releases (reject / auto-reject) or
  activates (final approve) the linked reservation **in the same transaction**
  as the approval status change, with a rows-affected guard on both rows. A
  reservation the caller already released is tolerated and logged; any other
  release failure aborts the decision so the two rows never disagree.
- The approval reaper is only the safety net for requests nobody decided
  before `expires_at`. Each expiry is one transaction: `status='pending'`
  guard → release reservation → audit row. A `Decide` racing a reaper pass
  converges on exactly one outcome (whichever commits first; the other sees
  "not pending" / `FailedPrecondition`), which
  `TestDecide_RacesReaper_ConvergesToOneOutcome` exercises.
- The reservation reaper likewise commits the bulk expiry and its audit rows
  together.
- Reaper-written audit rows (`limits.reservation.expired_ttl`,
  `limits.approval.expired`) carry the affected row's `tenant_id`/`partition_id`
  and the actor `system:limits-reaper` (type `system`), so they appear in that
  tenant's `LimitsAuditSearch` feed under RLS.

## Archival retention

`ARCHIVAL_RESERVATION_RETENTION_HOURS` (default 168) and
`ARCHIVAL_LEDGER_RETENTION_HOURS` (default 2160) set the hard-delete cutoffs.
The job widens the ledger cutoff automatically so it never deletes inside the
widest live rolling window plus a day of slack — deleting there would make that
cap under-count usage for the rest of its life.

## Open issues

1. Approval queue currently has no priority ordering. Future work:
   priority lane for high-value subjects.
2. Per-tenant rate limiting on Reserve itself (not just on the operations
   it gates) is not implemented. Future work: token bucket per tenant.
3. Bridge to org/orgUnit-level cap aggregation is computed at Reserve
   time. Future work: materialised aggregates updated by a worker for
   sub-1ms p99.
