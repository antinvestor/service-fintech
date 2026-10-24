# Limits — Production Rollout Rehearsal Log

**Date:** 2026-05-06 (template — populate during actual rehearsal)
**Action exercised:** TBD (recommended: `loan_disbursement` for the canary)
**Operators present:** TBD

## Pre-rehearsal checks

- [ ] Staging environment matches production topology (limits service + at
      least loans + savings consumers).
- [ ] `docs/runbook/limits-rollout.md` is the version under test.
- [ ] `limits-admin` CLI installed and configured for staging.

## Stage 1 — off → shadow (target: <5 min)

- [ ] Set `LIMITS_GATE_MODE_LOAN_DISBURSEMENT=shadow` in staging config.
- [ ] Trigger redeploy / rolling-restart.
- [ ] Confirm `shadow_outcome` log lines appear within 5 minutes of redeploy.

**Time-to-shadow-on:** _____ minutes
**Issues encountered:** _____

## Stage 2 — shadow soak (target: 1+ hour for rehearsal; 24-72h in prod)

- [ ] Generate enough traffic for >1k Reserve calls.
- [ ] Inspect `shadow_outcome=would_block` rate.
- [ ] Confirm log fields are searchable in the chosen log backend.
- [ ] Confirm `would_block` reservations are released (not lingering in
      the limits service).

**would_block rate:** _____
**Notes:** _____

## Stage 3 — shadow → enforce (target: <5 min)

- [ ] Set `LIMITS_GATE_MODE_LOAN_DISBURSEMENT=enforce` and redeploy.
- [ ] Confirm a known-bad operation now returns FailedPrecondition or
      ResourceExhausted.
- [ ] Run `limits-admin reservations list --status=pending` (the command
      lists approval requests; `--status` also accepts the full
      `APPROVAL_STATUS_PENDING` enum name) and observe any approval queue.

**Time-to-enforce-on:** _____ minutes
**Issues encountered:** _____

## Rollback drill (target: <2 min)

- [ ] Page-simulated incident: page on-call.
- [ ] Operator flips `LIMITS_GATE_MODE_LOAN_DISBURSEMENT=shadow`.
- [ ] Confirm production traffic resumes immediately.

**Time-to-rollback:** _____ minutes
**Issues encountered:** _____

## Runbook corrections

After the rehearsal, list any steps that were unclear, ambiguous, or
required interpretation. Update `docs/runbook/limits-rollout.md` to fix
each one and reference the rehearsal in the commit message.

- TBD

## Sign-off

- Operator: _____
- Date: _____
