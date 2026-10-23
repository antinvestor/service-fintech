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

-- Rollback of 002.
--
-- The globally unique indexes this migration replaced are deliberately NOT
-- recreated. Once codes have been allocated per partition, two partitions may
-- legitimately hold the same code, and recreating a global unique index would
-- fail outright or, worse, block a rollback halfway through. Dropping the
-- partition-scoped indexes returns the schema to "no uniqueness", which is
-- always applicable; the global constraint was the defect being removed and is
-- not a state worth restoring.

DROP INDEX IF EXISTS uq_organization_partition_code;
DROP INDEX IF EXISTS uq_org_unit_partition_code;
