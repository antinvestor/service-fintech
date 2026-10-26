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

-- GIN index for subject_refs @> ? containment queries used by PendingSum/PendingCount.
-- jsonb_path_ops produces a smaller index than the default jsonb_ops and covers the
-- @> operator used in all hot-path reservation queries.
--
-- NOTE: CONCURRENTLY is NOT used here because the Frame migration runner wraps
-- migrations in transactions and CREATE INDEX CONCURRENTLY cannot run inside a
-- transaction. On a hot production table this index should be created manually
-- with CONCURRENTLY before deploying; the SQL below is safe for fresh deploys
-- and staging environments.
CREATE INDEX IF NOT EXISTS idx_resv_subject_refs_gin
    ON limits_reservations USING gin (subject_refs jsonb_path_ops)
    WHERE deleted_at IS NULL AND status IN ('active','pending_approval');
