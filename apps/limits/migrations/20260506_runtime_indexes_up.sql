--- Copyright 2023-2026 Ant Investor Ltd
---
--- Licensed under the Apache License, Version 2.0 (the "License");
--- you may not use this file except in compliance with the License.
--- You may obtain a copy of the License at
---
---      http://www.apache.org/licenses/LICENSE-2.0
---
--- Unless required by applicable law or agreed to in writing, software
--- distributed under the License is distributed on an "AS IS" BASIS,
--- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--- See the License for the specific language governing permissions and
--- limitations under the License.

-- Reservation idempotency: per-tenant unique on (tenant_id, idempotency_key).
-- Frame's BaseModel provides tenant_id; this constraint must be SQL because
-- GORM tag-driven composite uniques don't reach into embedded fields.

-- One statement per file: the migrator runs a file as a single command.
DO $$
BEGIN
    CREATE UNIQUE INDEX IF NOT EXISTS uq_resv_idempotency
    ON limits_reservations (tenant_id, idempotency_key)
    WHERE deleted_at IS NULL;

    -- Ledger hot path: rolling-window queries scan by (tenant, subject, action,
    -- currency, committed_at). Partial index drops the reversed-or-deleted rows.
    CREATE INDEX IF NOT EXISTS idx_ledger_window
    ON limits_ledger (tenant_id, subject_type, subject_id, action, currency_code, committed_at DESC)
    WHERE reversed_at IS NULL AND deleted_at IS NULL;

    -- Reservation TTL reaper scans for active rows past their TTL.
    CREATE INDEX IF NOT EXISTS idx_resv_ttl_active
    ON limits_reservations (ttl_at)
    WHERE status = 'active' AND deleted_at IS NULL;

    -- Reservation pending sums during evaluation: scan by tenant+action+currency.
    CREATE INDEX IF NOT EXISTS idx_resv_pending_sum
    ON limits_reservations (tenant_id, action, currency_code, status)
    WHERE status IN ('active', 'pending_approval') AND deleted_at IS NULL;

    -- Approval expiry reaper scans for pending rows past expires_at.
    CREATE INDEX IF NOT EXISTS idx_approval_expiry
    ON limits_approval_requests (expires_at)
    WHERE status = 'pending' AND deleted_at IS NULL;

    -- Approval decisions: a single approver can vote at most once per request.
    CREATE UNIQUE INDEX IF NOT EXISTS uq_approval_decision
    ON limits_approval_decisions (approval_request_id, approver_id)
    WHERE deleted_at IS NULL;

    -- Subject attribute snapshot: one row per (tenant, subject_type, subject_id).
    CREATE UNIQUE INDEX IF NOT EXISTS uq_subject_attribute
    ON limits_subject_attributes (tenant_id, subject_type, subject_id)
    WHERE deleted_at IS NULL;
END $$;
