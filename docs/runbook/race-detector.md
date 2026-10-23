# Race detector on the Go test suites

`make test` and the `Race detector` job in `.github/workflows/ci.yaml` run the
whole module under `go test -race`. This note records why that is safe now and
what to do if the detector fires inside frame again.

## History

The shared `Makefile.common` `test` target omits `-race` because an earlier
`github.com/pitabwire/frame/v2` release had a data race in
`queue.subscriber.Stop()` against its own listener goroutine. It fired during
service cleanup in any suite that instantiated a `frame.Service`, which is
most of the integration suites in this repo, so `-race` was limited to
`./pkg/...`.

## Current state (frame v2.1.7, 2026-09-11)

Reproduction attempt on the pinned frame:

```
go test -race -count=1 ./apps/identity/...          # ok, no DATA RACE
go test -race -count=1 ./apps/loans/... ./apps/savings/... ./apps/funding/... \
    ./apps/limits/... ./apps/operations/... ./apps/stawi/... ./apps/seed/... ./pkg/...
```

No `DATA RACE` report was produced by any package. The shutdown ordering the
suites rely on (`frametests.FrameBaseTestSuite` stops the service before the
testcontainers are torn down; per-test services register `svc.Stop` through
`t.Cleanup`) is race-clean on this frame version, so no test-side mitigation
was needed and the frame version was not bumped (`v2.1.8` exists but is not
required for this).

## If the detector fires again

1. Capture the full `WARNING: DATA RACE` block; the two stacks identify whether
   both sides are inside frame (`queue/`, `events/`) or one side is ours.
2. If one side is ours, fix the ordering in our code: stop consumers and drain
   the events manager before the datastore pool closes, never the other way
   around.
3. If both sides are inside frame, check `go list -m -versions
   github.com/pitabwire/frame/v2` for a fix and bump only when `go build ./...`
   and the full suite stay green. Until then, narrow the exclusion to the exact
   package in `.github/workflows/ci.yaml` rather than disabling `-race`
   globally, and record the frame issue link here.
