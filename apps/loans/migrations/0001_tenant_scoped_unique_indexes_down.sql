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

--- Reverting only drops what the up migration created. The globally unique
--- indexes it replaced are deliberately not recreated: on multi-tenant data
--- they cannot be built at all, so recreating them would turn a rollback
--- into a failed migration. The supporting non-unique indexes go with them.
DO $$
BEGIN
    DROP INDEX IF EXISTS idx_pen_schedule_entry;
    DROP INDEX IF EXISTS idx_rec_external_reference;
    DROP INDEX IF EXISTS idx_rec_payment_reference;
    DROP INDEX IF EXISTS idx_rep_payment_reference;

    DROP INDEX IF EXISTS uq_cpa_partition_client_product;
    DROP INDEX IF EXISTS uq_lb_partition_loan;
    DROP INDEX IF EXISTS uq_disb_partition_idem;
    DROP INDEX IF EXISTS uq_rep_partition_idem;
    DROP INDEX IF EXISTS uq_la_partition_loan_request;
    DROP INDEX IF EXISTS uq_lr_partition_idempotency;
    DROP INDEX IF EXISTS uq_lp_partition_code;
END
$$;
