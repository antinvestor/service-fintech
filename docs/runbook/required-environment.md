# Required environment for every fintech service

Frame's defaults are tuned for local development. Several of them are unsafe in
any shared environment, so they must be set per deployment.

## The services enforce this themselves

Every service runs `pkg/bootcheck.Validate` before frame initialises. With
`RUN_SERVICE_SECURELY=true` (frame's default) the process refuses to start on
any violation and logs one error listing every rule it breaks, for example:

```
refusing to start: unsafe environment: FRAME_QUEUE_PUSH_AUTH must be oidc or bearer, got "none"; EVENTS_QUEUE_URL must point at a durable broker, got "mem://frame.events.internal_._queue"
```

With `RUN_SERVICE_SECURELY=false` the same violations are logged as warnings
and the service starts, which is the local-development mode. The rules are:

| Variable | Rule |
|---|---|
| `RUN_SERVICE_SECURELY` | must be `true` |
| `FRAME_QUEUE_PUSH_AUTH` | must be `oidc` or `bearer` |
| `EVENTS_QUEUE_URL` | must be set and must not use the `mem://` scheme |
| `MIGRATION_PATH` | must be set (the Dockerfiles set `/migrations`) |
| `AUDIT_SERVICE_URI` | must be set when running securely (see below) |
| `OAUTH_REDIRECT_URIS` | identity only: must be set when running securely (no default; a blank value would let every organization's login client inherit nothing, an unset one used to inherit `localhost`) |
| `FIELD_SERVICE_URI` | loans only: endpoint that serves `field.v1` (the identity binary); required at boot so client callers can be resolved for per-client read scoping |
| `LOANS_STAFF_ROLES` | loans only: comma-separated roles treated as staff for partition-wide loan reads (default `admin,operator,viewer`); every other role is scoped to its own client |

The check applies to the serving process and to the migrate/setup Job, which
run from the same image and environment.

## `FRAME_QUEUE_PUSH_AUTH` — must be `oidc`

Frame mounts `/_frame/queue` unconditionally on the service's HTTP handler and
resolves `FRAME_QUEUE_PUSH_AUTH=none` (the default) to `push.NoneAuth{}`. That
endpoint dispatches straight into the registered event handlers and does **not**
pass through the Connect interceptor chain, so with the default an in-mesh POST
of a `deposit.save` payload writes to the database with no authentication, no
tenancy check and no function-access check.

```
FRAME_QUEUE_PUSH_AUTH=oidc
RUN_SERVICE_SECURELY=true
```

`RUN_SERVICE_SECURELY=true` makes `FRAME_QUEUE_PUSH_REQUIRE_AUTH` effective, and
frame's `validateQueuePushAuth` then refuses to start a service that has push
subscribers while push auth is `none`. Setting both means a misconfigured
deployment fails at boot instead of serving an open write endpoint.

`FRAME_QUEUE_PUSH_AUTH=bearer` also satisfies the check but additionally
requires `FRAME_QUEUE_PUSH_BEARER_TOKEN`; prefer `oidc`, which reuses the
workload identity already configured for service-to-service calls.

## `EVENTS_QUEUE_URL` — must not be `mem://`

The default is `mem://frame.events.internal_._queue`, an in-process queue with
no durability. Every service in this repo persists domain state through
`frame.WithRegisterEvents`: a savings deposit is acknowledged to the caller,
then the row is written by an event handler. With the in-memory queue a pod
restart between the ack and the handler run loses the write silently — there is
no error, no retry and no dead-letter record. For money movements that is
undetectable data loss.

Point it at the durable broker for the environment, e.g.

```
EVENTS_QUEUE_URL=nats://nats.fintech.svc.cluster.local:4222?subject=...
```

Local development and tests may keep `mem://`.

## `MIGRATION_PATH` — must be set

Schema migrations run only in the setup Job (`argv = ["setup"]`) and read SQL
files from `MIGRATION_PATH`. The Dockerfiles copy each service's migrations to
`/migrations` and set the variable there; an empty value is refused at boot.
The migrate step also takes a Postgres advisory lock keyed on the service name
(`pkg/dbmigrate.Locked`), so two overlapping setup Jobs serialise instead of
racing on DDL: the second one blocks until the first finishes.

## `AUDIT_SERVICE_URI` — must be set when running securely

The RPC-level audit interceptor (`github.com/antinvestor/common/audit`) needs
a client to the platform audit service; without one it records nothing. Each
service builds that client from:

```
AUDIT_SERVICE_URI=<audit service endpoint>
AUDIT_SERVICE_WORKLOAD_API_TARGET_PATH=/ns/audit/sa/service-audit   # default
```

`AUDIT_SERVICE_URI` has no default. When `RUN_SERVICE_SECURELY=true` and it is
empty the service fails at boot; when running insecurely it logs a warning and
the interceptor runs with a nil client (audit disabled), for local development
only.

## Internal principals must name their tenant

Every service's interceptor chain now runs `pkg/tenantassert` directly after
the tenancy access check. A token carrying the `internal` role acts across
tenants, so it must name the tenant it acts for on each request: through the
request's `tenant_id` field where the message has one, or through the
`X-Tenant-Id` header otherwise. A request naming no tenant is refused with
`InvalidArgument`; a tenant principal naming a tenant other than its own is
refused with `PermissionDenied`; a principal whose claims carry no tenant is
refused with `Unauthenticated`. The named tenant is bound as the request's
row-level scope, so internal callers no longer bypass tenancy binding.

## Verifying a deployment

```bash
# From a shell in the target namespace
env | grep -E 'FRAME_QUEUE_PUSH_AUTH|EVENTS_QUEUE_URL|RUN_SERVICE_SECURELY|MIGRATION_PATH|AUDIT_SERVICE_URI'
```

Expect `FRAME_QUEUE_PUSH_AUTH=oidc`, `RUN_SERVICE_SECURELY=true`, a non-empty
`MIGRATION_PATH` and `AUDIT_SERVICE_URI`, and an `EVENTS_QUEUE_URL` whose
scheme is not `mem`. A pod that started at all under `RUN_SERVICE_SECURELY=true`
has already passed these checks; a crash-looping pod logs the violation list.

## Seed web bundle

The Seed console has no defaults in release builds. See `ui/seed/README.md`;
`make ui-build-prod` requires `OIDC_CLIENT_ID_PROD`, `OIDC_ISSUER_PROD` and
`API_BASE_URL_PROD` and fails rather than shipping development credentials.
