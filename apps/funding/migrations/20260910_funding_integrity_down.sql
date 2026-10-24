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

DROP INDEX IF EXISTS idx_ia_currency_state;
DROP INDEX IF EXISTS idx_lfund_request_state;
DROP INDEX IF EXISTS idx_ft_funding_level;
DROP INDEX IF EXISTS uq_loss_reference;
DROP INDEX IF EXISTS uq_lfclaim_request;
DROP INDEX IF EXISTS uq_icm_account_idempotency;
