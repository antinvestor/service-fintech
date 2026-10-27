// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package business_test

import (
	"os"
	"strings"

	"gorm.io/gorm"
)

// The interest job's read is served by its partial index in the order it
// reads, so a run stops after its batch instead of sorting every account.
func (s *savingsSuite) TestInterestDueQueryUsesItsIndex() {
	e := s.newEnv()
	sql, err := os.ReadFile("../../migrations/20261027_interest_due_index_up.sql")
	s.Require().NoError(err)
	s.Require().NoError(e.dbPool.DB(e.ctx, false).Exec(string(sql)).Error)

	var plan []string
	s.Require().NoError(e.dbPool.DB(e.ctx, false).Transaction(func(tx *gorm.DB) error {
		if setErr := tx.Exec("SET LOCAL enable_seqscan = off").Error; setErr != nil {
			return setErr
		}
		return tx.Raw(`EXPLAIN SELECT * FROM savings_accounts
WHERE deleted_at IS NULL AND status = 1
  AND (interest_accrued_through IS NULL OR interest_accrued_through < now())
  AND (interest_checked_at IS NULL OR interest_checked_at < now())
ORDER BY interest_checked_at NULLS FIRST, id LIMIT 100`).Scan(&plan).Error
	}))
	joined := strings.Join(plan, "\n")
	s.Contains(joined, "idx_sa_interest_due")
	s.NotContains(joined, "Sort", "the index supplies the order")
}
