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

--- Drops the statement-path composite indexes. The original single-column
--- loan_account_id indexes are managed by the model tags and are left alone.
DO $$
BEGIN
    DROP INDEX IF EXISTS idx_se_loan_due;
    DROP INDEX IF EXISTS idx_disb_loan_created;
    DROP INDEX IF EXISTS idx_pen_loan_created;
    DROP INDEX IF EXISTS idx_rep_loan_created;
END
$$;
