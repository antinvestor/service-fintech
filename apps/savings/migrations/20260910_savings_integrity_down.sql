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

DROP INDEX IF EXISTS idx_savings_accounts_searchable;
DROP TRIGGER IF EXISTS savings_accounts_searchable_trigger ON savings_accounts;
DROP FUNCTION IF EXISTS savings_accounts_searchable_update();
ALTER TABLE savings_accounts DROP COLUMN IF EXISTS searchable;

DROP INDEX IF EXISTS idx_savings_products_searchable;
DROP TRIGGER IF EXISTS savings_products_searchable_trigger ON savings_products;
DROP FUNCTION IF EXISTS savings_products_searchable_update();
ALTER TABLE savings_products DROP COLUMN IF EXISTS searchable;

DROP INDEX IF EXISTS idx_ia_account_created;
DROP INDEX IF EXISTS idx_wdr_account_status_created;
DROP INDEX IF EXISTS idx_dep_account_status_created;

DROP INDEX IF EXISTS uq_wdr_idempotency;
DROP INDEX IF EXISTS uq_dep_idempotency;
