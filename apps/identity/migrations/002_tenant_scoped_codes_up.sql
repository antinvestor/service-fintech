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

-- Organization and org unit codes are chosen per tenant, so a globally unique
-- index lets one tenant block a code for every other tenant and turns the
-- constraint into a cross-tenant existence oracle. Scope both to the partition.

-- Both tables are soft-deleted (deleted_at). Without the predicate a deleted
-- row keeps its code reserved forever, so a code can never be reused and a
-- delete-then-recreate of the same organization fails.

DROP INDEX IF EXISTS uq_organization_code;
CREATE UNIQUE INDEX IF NOT EXISTS uq_organization_partition_code
  ON organizations (partition_id, code)
  WHERE deleted_at IS NULL;

DROP INDEX IF EXISTS uq_branch_code;
CREATE UNIQUE INDEX IF NOT EXISTS uq_org_unit_partition_code
  ON org_units (partition_id, code)
  WHERE deleted_at IS NULL;
