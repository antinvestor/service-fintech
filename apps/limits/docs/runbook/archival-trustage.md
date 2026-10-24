# Limits — Archival Trustage Workflow

The limits service exposes `POST /admin/archive` for periodic cleanup of
terminal reservations and old ledger entries. Trustage calls this endpoint on
a schedule. The job deletes across every tenant, so it is gated three ways.

## Authentication and authorisation

1. **Authentication.** `POST /admin/archive` sits behind the same JWT
   bearer-token authenticator as every Connect RPC in the limits service
   (`httptor.AuthenticationMiddleware`). Trustage must present a valid OIDC
   access token issued by the configured identity provider.
2. **Permission.** The route is additionally wrapped in
   `httptor.FunctionAccessMiddleware` and requires **`limits_policy_manage`**
   in the `service_limits` namespace, checked against the caller's own
   tenant/partition path. Grant it to the Trustage service account the same
   way as any other limits admin permission. A dedicated **`limits_archive`**
   permission is now declared in the proto `service_permissions` (bound to
   no role — grant it explicitly to the Trustage service account); the route
   switches to it once the BSR module carrying it is published and
   `cmd/main.go`'s `archivalPermission` is flipped, after which
   `limits_policy_manage` no longer opens the archival route.
3. **Principal type.** The handler itself refuses any caller that is not a
   machine principal — the claims must carry the internal-system role or a
   service name. A human operator token, however privileged inside its own
   tenant, cannot destroy another tenant's ledger.

Add the `Authorization` header to the Trustage step:

```yaml
headers:
  Authorization: "Bearer <oidc-access-token>"
```

| Response | Meaning |
|----------|---------|
| **401**  | No bearer token. |
| **403**  | Token rejected by the authenticator, the caller lacks `limits_policy_manage`, or the principal is not a service account. |

Rotate the token according to your OIDC provider's service-account credential
lifecycle (typically via Workload Identity or a client-credentials grant).

## Workflow

```yaml
name: limits_archive
trigger:
  schedule: every 1 hour
steps:
  - name: archive
    action: http_call
    target:
      service: service_limits
      method: POST
      path: /admin/archive
    expect:
      status_code: 200
```

## Cadence guidance

- Hourly is the recommended cadence.
- Daily is acceptable for low-volume deployments.
- Sub-hourly is unnecessary overhead.

## Failure handling

- HTTP 500 indicates a DB connectivity or query error. Trustage retries;
  an hour-long pause is acceptable for archival purposes.
- HTTP 405 indicates the caller used GET instead of POST.

## Observability

Each run emits an INFO log with:

```
{"job":"archival","reservations_deleted":N,"ledger_deleted":M,"msg":"archival run complete"}
```

- Steadily non-zero counts → DB is keeping up with the inflow.
- Stuck at zero for more than a week → nothing is eligible (unexpected for
  a busy service; investigate whether terminal statuses are being set).
- Rising counts that never fall → archival frequency may need increasing or
  the cutoff windows may need shortening.

## Cutoffs

| Table                  | Column         | Cutoff                                   |
|------------------------|----------------|------------------------------------------|
| `limits_reservations`  | `modified_at`  | `ARCHIVAL_RESERVATION_RETENTION_HOURS` (default 168 = 7 days) |
| `limits_ledger`        | `committed_at` | `ARCHIVAL_LEDGER_RETENTION_HOURS` (default 2160 = 90 days) |

The ledger cutoff is widened automatically at run time so it never falls
inside the widest live rolling window (plus a day of slack). A 180-day rolling
cap therefore keeps 181 days of ledger regardless of the configured value:
deleting inside a live window would make that cap under-count usage
permanently, and the log line `archival: ledger retention widened to cover the
longest live rolling window` records when this happens.

Terminal reservation statuses eligible for deletion: `committed`, `released`,
`reversed`, `expired`.

Active and `pending_approval` reservations are never deleted by this job.
