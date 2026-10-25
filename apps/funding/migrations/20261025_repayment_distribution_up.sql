-- Copyright 2023-2026 Ant Investor Ltd
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- One statement per file: the migrator runs a file as a single command.
DO $$
BEGIN
    -- One distribution per repayment reference. This is what makes
    -- LoanRepaymentApply idempotent: the insert that loses the race moves no
    -- tranche or investor counter.
    CREATE UNIQUE INDEX IF NOT EXISTS uq_rd_reference
    ON repayment_distributions (reference)
    WHERE deleted_at IS NULL;

    -- Distributions still owing a ledger posting, for the settlement retry.
    CREATE INDEX IF NOT EXISTS idx_rd_unsettled
    ON repayment_distributions (created_at)
    WHERE settled_at IS NULL AND deleted_at IS NULL;

    -- A loss absorption is settled once its ledger postings are done.
    ALTER TABLE loss_absorptions ADD COLUMN IF NOT EXISTS settled_at timestamptz;
    ALTER TABLE loss_absorptions ADD COLUMN IF NOT EXISTS product_id varchar(50);
END
$$;
