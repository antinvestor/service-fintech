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

-- Columns added by proto changes. AutoMigrate runs before this file, so every
-- statement is written to be a no-op on a schema AutoMigrate already created.
-- The int -> varchar conversion of engagement_type, team_type and
-- membership_role happens in preMigrate, before AutoMigrate, because Postgres
-- needs an explicit USING clause for that cast.

ALTER TABLE organizations ADD COLUMN IF NOT EXISTS domain VARCHAR(255) DEFAULT '';
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS organization_type INTEGER DEFAULT 0;
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS parent_id VARCHAR(50) DEFAULT '';
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS has_children BOOLEAN DEFAULT FALSE;
CREATE INDEX IF NOT EXISTS idx_organization_parent ON organizations (parent_id);
ALTER TABLE org_units ADD COLUMN IF NOT EXISTS profile_id VARCHAR(50) DEFAULT '';
