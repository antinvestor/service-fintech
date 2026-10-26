# Limits — Production Rollout Runbook

This runbook walks through enabling limits enforcement for a new action key.
Use it once per (service, action) pair.

> **Since 2026-10-24 every gate ships enabled in `enforce` mode** (see
> `required-environment.md`, "Transaction limits are on by default"). The
> soak now happens per policy: a new policy starts in `SHADOW` mode, which
> records would-block verdicts without blocking, and is moved to `ENFORCE`
> once the soak is clean. The gate stages below remain the emergency
> controls: set `LIMITS_GATE_MODE_<action>=shadow` or `off` to stop a gate
> from blocking without touching policies.

## Stages

```
off → shadow → enforce
```

Never skip shadow. Shadow mode is the only way to detect false positives
(policies that would block legitimate operations) without customer impact.

## Stage 1 — off (initial deployment)

1. Deploy the consumer service with the limits Gate code in place but
   `LIMITS_GATE_MODE_<action>=off`. `limits.ParseMode` maps `off` (any case,
   also `disabled`/`none`) to `ModeOff`, and the Gate short-circuits: it does
   not call Reserve at all. Handler runs unchanged.
2. Verify deployment health: error rates, latency, business KPIs steady.

## Stage 2 — shadow (24-72 hours, depending on volume)

1. Set `LIMITS_GATE_MODE_<action>=shadow` and redeploy (or rolling-restart
   pods). The Gate now calls Reserve but does not enforce.
2. Watch for shadow-outcome logs. Specifically:
   - Aggregate count of `shadow_outcome=would_block` per action_key per hour.
   - Top subject_ids triggering would_block.
   - Top policy_ids cited in verdicts.
3. **Threshold for "ready to enforce":**
   - would_block rate is <0.1% of total operations, OR
   - the operations triggering would_block are explicable (matched the
     policy intent) and reviewed with stakeholders.
4. **If the rate is too high:** loosen the policy, or carve out exceptions
   via `policies disable <id>` for the offending policy. Repeat the
   24-72h soak before flipping to enforce.

Policies themselves have the same three modes. Create them with
`limits-admin policies shadow <id>` (or leave the editor's default Shadow
mode) and only move to `policies enable <id>` — which sets
`POLICY_MODE_ENFORCE` — once the soak is clean.

## Stage 3 — enforce

1. Set `LIMITS_GATE_MODE_<action>=enforce` and redeploy.
2. Watch for:
   - HTTP 412 (FailedPrecondition) and 429 (ResourceExhausted) on the
     consumer service's Connect endpoints.
   - Approval queue depth (`limits-admin reservations list --status=pending`;
     the command lists approval requests, and `--status` accepts either the
     short name or the full `APPROVAL_STATUS_*` enum name).
   - Customer support tickets about blocked operations.
3. Have an on-call operator with `limits-admin approvals approve` ready
   for legitimate-but-blocked cases. Document the override workflow in
   the consumer service's customer-facing runbook.

## Rollback

If enforce mode causes incidents:

1. **Fastest:** flip `LIMITS_GATE_MODE_<action>` back to `shadow` and
   redeploy. Operations stop being blocked but observability stays on.
2. **Slower:** disable the offending policy via
   `limits-admin policies disable <id>`. Gate still fires Reserve but the
   verdict comes back ALLOW for everything.
3. **Coldest:** flip to `off`. The Gate stops calling the limits service
   entirely; useful only if Reserve itself is unhealthy.

Policy-mode changes are optimistically locked: a save carries the version the
operator read, and a concurrent edit by another operator is rejected with
`Aborted` rather than silently overwriting. Re-read and re-apply.

A policy save or delete drops the candidate cache on the replica that served
it and publishes `limits.policy.invalidate.v1` on the service's Frame events
topic. Two consumers see that message:

- the shared events queue (`EVENTS_QUEUE_NAME`, competing consumers — one
  replica per message), where `PolicyInvalidateHandler` is registered via
  `frame.WithRegisterEvents`;
- a **per-replica broadcast subscription** (`business.NewPolicyInvalidateBroadcast`,
  registered via `frame.WithRegisterSubscriber`) named
  `limits.policy.invalidate.broadcast.<hostname>-<random>` on the same topic.
  Its URL is `EVENTS_QUEUE_SUBSCRIBE_URL` (or `EVENTS_QUEUE_URL`) with the
  shared-consumer parameters `consumer_durable_name` / `consumer_name`
  removed, so every replica holds its own plain (core NATS) or ephemeral
  (JetStream) subscription and receives every message. The worker acts only
  on the invalidation header and acknowledges everything else.

Queue-URL requirement: the events URL must use the `nats://` scheme (or
`mem://` in tests). `push://` and `gcppubsub://` cannot fan out per replica —
a per-pod subscription would have to exist on the broker before the pod
starts — and `NewPolicyInvalidateBroadcast` returns
`ErrBroadcastUnsupported`; the service then runs with the shared consumer only
and the cache TTL (`POLICY_CACHE_TTL_SECONDS`, default 60s) is the propagation
bound. With NATS every replica converges within delivery latency, and the TTL
is only the fallback for a replica whose subscription was reconnecting.

## Per-action keys

Limits gate money leaving the platform. Money a payer has already sent is
never gated: loan repayments, savings deposits and the operations orders
that allocate a received payment are applied without a reservation, since a
refusal would only strand money that has arrived.

| Service     | Env var                                      | Subject       |
|-------------|----------------------------------------------|---------------|
| loans       | LIMITS_GATE_MODE_LOAN_DISBURSEMENT          | borrower      |
| loans       | LIMITS_GATE_MODE_LOAN_REQUEST_APPROVAL      | borrower      |
| savings     | LIMITS_GATE_MODE_SAVINGS_WITHDRAWAL         | account       |
| operations  | LIMITS_GATE_MODE_OPERATIONS_TRANSFER        | source acct   |
| funding     | LIMITS_GATE_MODE_FUNDING_DEPOSIT            | invest acct   |
| funding     | LIMITS_GATE_MODE_FUNDING_WITHDRAW           | invest acct   |
| stawi       | LIMITS_GATE_MODE_STAWI_LOAN_DISBURSEMENT    | member        |

## Escalation

- Slack: #fintech-limits
- On-call: limits-oncall (PagerDuty)
- Emergency disable: see "Rollback" above; any of the three modes
  resolves an incident in under 5 minutes.

## Tenant scoping and the internal-system exception

Every tenanted limits RPC derives its tenant from the caller's claims, not from
the request body. `TenantAssertionInterceptor` (unary *and* server-streaming)
rejects a payload naming a tenant other than the caller's, then overwrites the
field with the claim value; the business layer repeats the check against the
stored row.

The scoping fails closed. Claims that carry no `tenant_id` are rejected with
`Unauthenticated` rather than stamped with an empty tenant — an empty tenant
would have disabled every downstream `tenant != ""` guard and turned the
cross-tenant controls off for exactly the tokens least entitled to them.

The single exception is the internal-system principal (`roles` contains
`internal`). It legitimately acts across tenants — archival sweeps, reconciliation
jobs, cross-tenant reporting — and therefore carries no tenant of its own. For
that role, and only that role:

- The interceptor honours `tenant_id` from the request, and **requires** it:
  omitting it is rejected with `InvalidArgument`.
- The stored-row guards (`assertSameTenant`, `assertApprovalTenant`,
  `assertRequestTenant`) pass it through.
- `LimitsAuditSearch` derives its tenant filter from claims, so an internal
  principal gets an unfiltered feed; every other caller is filtered to its own
  tenant. (The proto now carries `tenant_id` on the request; once the BSR
  module is bumped the interceptor applies the same rule to it as to every
  other tenanted request.)

Rows written by the background reapers are part of each tenant's feed: they
carry the reservation's or approval's tenancy and the actor
`system:limits-reaper`, so `limits.reservation.expired_ttl` and
`limits.approval.expired` show up next to the human-driven verbs.

Operationally this means an internal service token must set `intent.tenant_id`
(or the request's `tenant_id`) on every call it makes. A token that is meant to
be tenant-scoped must carry `tenant_id` in its claims and must **not** carry the
`internal` role; issuing it with neither now fails at the interceptor instead of
silently reading across tenants.
