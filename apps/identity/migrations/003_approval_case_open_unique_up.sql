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

-- Submit used to guard against a second open case with a read (GetOpenBySubject)
-- followed by an emit. Two concurrent submissions both read "none open" and both
-- created one. The database now enforces the invariant.
--
-- Older duplicates are closed first, otherwise the index cannot be built. The
-- newest open case per subject survives; the rest are rejected so the audit
-- trail keeps them rather than deleting them.

WITH ranked AS (
  SELECT id,
         row_number() OVER (
           PARTITION BY subject_type, subject_id, case_type
           ORDER BY created_at DESC, id DESC
         ) AS rn
  FROM approval_cases
  WHERE deleted_at IS NULL
    AND status IN ('pending_verification', 'pending_approval')
)
UPDATE approval_cases AS ac
SET status = 'rejected',
    comment = 'superseded by a newer open case'
FROM ranked
WHERE ac.id = ranked.id
  AND ranked.rn > 1;

CREATE UNIQUE INDEX IF NOT EXISTS uq_approval_case_open_subject
  ON approval_cases (subject_type, subject_id, case_type)
  WHERE deleted_at IS NULL
    AND status IN ('pending_verification', 'pending_approval');
