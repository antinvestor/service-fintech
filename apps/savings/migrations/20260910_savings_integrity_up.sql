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

-- Idempotency keys are the authoritative duplicate guard for deposits and
-- withdrawals. The index is partial so historical rows that predate the
-- mandatory key (empty string) do not collide with each other.
DROP INDEX IF EXISTS uq_dep_idempotency;
CREATE UNIQUE INDEX IF NOT EXISTS uq_dep_idempotency
ON deposits (idempotency_key)
WHERE idempotency_key <> '' AND deleted_at IS NULL;

DROP INDEX IF EXISTS uq_wdr_idempotency;
CREATE UNIQUE INDEX IF NOT EXISTS uq_wdr_idempotency
ON withdrawals (idempotency_key)
WHERE idempotency_key <> '' AND deleted_at IS NULL;

-- Statement and search queries filter on (account, status, date); the
-- single-column account index cannot serve them.
CREATE INDEX IF NOT EXISTS idx_dep_account_status_created
ON deposits (savings_account_id, status, created_at DESC)
WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_wdr_account_status_created
ON withdrawals (savings_account_id, status, created_at DESC)
WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_ia_account_created
ON interest_accruals (savings_account_id, created_at DESC)
WHERE deleted_at IS NULL;

-- Full-text search columns backing SavingsProductSearch.query and
-- SavingsAccountSearch.query. Without them those RPCs reference a column
-- that does not exist.
ALTER TABLE savings_products ADD COLUMN IF NOT EXISTS searchable tsvector;
CREATE OR REPLACE FUNCTION savings_products_searchable_update() RETURNS trigger AS $$
BEGIN
  NEW.searchable :=
    setweight(to_tsvector('english', coalesce(NEW.name, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.code, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.description, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(NEW.currency_code, '')), 'C');
  RETURN NEW;
END
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS savings_products_searchable_trigger ON savings_products;
CREATE TRIGGER savings_products_searchable_trigger
BEFORE INSERT OR UPDATE ON savings_products
FOR EACH ROW EXECUTE FUNCTION savings_products_searchable_update();
UPDATE savings_products SET searchable =
  setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(code, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(currency_code, '')), 'C');
CREATE INDEX IF NOT EXISTS idx_savings_products_searchable
ON savings_products USING GIN (searchable);

ALTER TABLE savings_accounts ADD COLUMN IF NOT EXISTS searchable tsvector;
CREATE OR REPLACE FUNCTION savings_accounts_searchable_update() RETURNS trigger AS $$
BEGIN
  NEW.searchable :=
    setweight(to_tsvector('english', coalesce(NEW.owner_id, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.id, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.product_id, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(NEW.currency_code, '')), 'C');
  RETURN NEW;
END
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS savings_accounts_searchable_trigger ON savings_accounts;
CREATE TRIGGER savings_accounts_searchable_trigger
BEFORE INSERT OR UPDATE ON savings_accounts
FOR EACH ROW EXECUTE FUNCTION savings_accounts_searchable_update();
UPDATE savings_accounts SET searchable =
  setweight(to_tsvector('english', coalesce(owner_id, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(id, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(product_id, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(currency_code, '')), 'C');
CREATE INDEX IF NOT EXISTS idx_savings_accounts_searchable
ON savings_accounts USING GIN (searchable);
