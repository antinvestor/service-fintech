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

--- Indexes for the loan statement path.
---
--- A statement reads every repayment, penalty and disbursement of one loan in
--- posting order, and the schedule in due-date order. The existing
--- single-column loan_account_id indexes serve the filter but not the sort,
--- so Postgres still has to gather and sort the matched heap tuples. A
--- composite (loan_account_id, created_at) index serves both the filter and
--- the order in a single ordered index range scan.
DO $$
BEGIN
    CREATE INDEX IF NOT EXISTS idx_rep_loan_created
        ON repayments (loan_account_id, created_at);
    CREATE INDEX IF NOT EXISTS idx_pen_loan_created
        ON penalties (loan_account_id, created_at);
    CREATE INDEX IF NOT EXISTS idx_disb_loan_created
        ON disbursements (loan_account_id, created_at);
    CREATE INDEX IF NOT EXISTS idx_se_loan_due
        ON schedule_entries (loan_account_id, due_date);
END
$$;
