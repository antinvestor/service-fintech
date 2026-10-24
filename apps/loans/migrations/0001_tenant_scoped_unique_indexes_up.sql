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

--- Tenant-scope the unique constraints on the loan tables.
---
--- Row-level security scopes what a tenant can read, but a unique index is
--- enforced across the whole table regardless of RLS. Globally unique product
--- codes and idempotency keys therefore let one organization block another
--- from creating a product code, and turn a shared key namespace into an
--- existence oracle across tenants. Each of these constraints is only
--- meaningful inside a partition, so that is where it is now enforced.
---
--- The idempotency-key indexes are additionally predicated on a non-empty
--- key: rows written before the key became mandatory carry an empty string
--- and would otherwise collide with each other inside a partition.
---
--- Wrapped in a DO block so the whole re-indexing lands or none of it does.
DO $$
BEGIN
    DROP INDEX IF EXISTS uq_lp_code;
    CREATE UNIQUE INDEX IF NOT EXISTS uq_lp_partition_code
        ON loan_products (partition_id, code)
        WHERE deleted_at IS NULL;

    DROP INDEX IF EXISTS uq_lr_idempotency;
    CREATE UNIQUE INDEX IF NOT EXISTS uq_lr_partition_idempotency
        ON loan_requests (partition_id, idempotency_key)
        WHERE idempotency_key <> '' AND deleted_at IS NULL;

    DROP INDEX IF EXISTS uq_loan_request;
    CREATE UNIQUE INDEX IF NOT EXISTS uq_la_partition_loan_request
        ON loan_accounts (partition_id, loan_request_id)
        WHERE deleted_at IS NULL;

    DROP INDEX IF EXISTS uq_rep_idem;
    CREATE UNIQUE INDEX IF NOT EXISTS uq_rep_partition_idem
        ON repayments (partition_id, idempotency_key)
        WHERE idempotency_key <> '' AND deleted_at IS NULL;

    DROP INDEX IF EXISTS uq_disb_idem;
    CREATE UNIQUE INDEX IF NOT EXISTS uq_disb_partition_idem
        ON disbursements (partition_id, idempotency_key)
        WHERE idempotency_key <> '' AND deleted_at IS NULL;

    DROP INDEX IF EXISTS uq_lb_loan;
    CREATE UNIQUE INDEX IF NOT EXISTS uq_lb_partition_loan
        ON loan_balances (partition_id, loan_account_id)
        WHERE deleted_at IS NULL;

    DROP INDEX IF EXISTS uq_cpa_client_product;
    CREATE UNIQUE INDEX IF NOT EXISTS uq_cpa_partition_client_product
        ON client_product_access (partition_id, client_id, product_id)
        WHERE deleted_at IS NULL;

    -- Reconciliation matches loans by these references; without an index each
    -- match is a sequential scan of the whole table.
    CREATE INDEX IF NOT EXISTS idx_rep_payment_reference
        ON repayments (partition_id, payment_reference);
    CREATE INDEX IF NOT EXISTS idx_rec_payment_reference
        ON reconciliations (partition_id, payment_reference);
    CREATE INDEX IF NOT EXISTS idx_rec_external_reference
        ON reconciliations (partition_id, external_reference);
    CREATE INDEX IF NOT EXISTS idx_pen_schedule_entry
        ON penalties (schedule_entry_id);
END
$$;
