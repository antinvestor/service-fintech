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

-- One capital movement per (account, idempotency key). This constraint is
-- what makes InvestorDeposit and InvestorWithdraw idempotent: a retry loses
-- the insert instead of posting to the ledger a second time.
CREATE UNIQUE INDEX IF NOT EXISTS uq_icm_account_idempotency
ON investor_capital_movements (investor_account_id, idempotency_key)
WHERE idempotency_key <> '' AND deleted_at IS NULL;

-- One allocation claim per loan request: this is the lock that stops two
-- concurrent FundLoan calls from reserving investor capital twice.
CREATE UNIQUE INDEX IF NOT EXISTS uq_lfclaim_request
ON loan_funding_claims (loan_request_id)
WHERE deleted_at IS NULL;

-- One absorption per loss reference, so repeating AbsorbLoss reports the
-- first call's split rather than eating further tranches.
CREATE UNIQUE INDEX IF NOT EXISTS uq_loss_reference
ON loss_absorptions (reference)
WHERE reference <> '' AND deleted_at IS NULL;

-- Tranche lookups walk from a loan request through its fundings; without an
-- index on the join column the subquery scans loan_fundings in full.
CREATE INDEX IF NOT EXISTS idx_ft_funding_level
ON funding_tranches (loan_funding_id, tranche_level)
WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_lfund_request_state
ON loan_fundings (loan_request_id, state)
WHERE deleted_at IS NULL;

-- Investor eligibility scans filter on currency and state before ordering by
-- utilisation.
CREATE INDEX IF NOT EXISTS idx_ia_currency_state
ON investor_accounts (currency, state)
WHERE deleted_at IS NULL;
