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

package repository_test

import (
	"os"
	"path/filepath"
	"strings"

	"gorm.io/gorm"
)

// applyMigrations runs the service's SQL migrations as the setup job would.
func (s *claimsSuite) applyMigrations(e *claimsEnv) {
	s.T().Helper()
	files, err := filepath.Glob("../../migrations/*_up.sql")
	s.Require().NoError(err)
	s.Require().NotEmpty(files)
	for _, f := range files {
		sql, readErr := os.ReadFile(f)
		s.Require().NoError(readErr)
		s.Require().NoError(e.dbPool.DB(e.ctx, false).Exec(string(sql)).Error, f)
	}
}

// planOf is the plan Postgres picks for query when it may not scan the table:
// it names the index only when one can serve the query.
func (s *claimsSuite) planOf(e *claimsEnv, query string) string {
	s.T().Helper()
	var plan []string
	err := e.dbPool.DB(e.ctx, false).Transaction(func(tx *gorm.DB) error {
		if err := tx.Exec("SET LOCAL enable_seqscan = off").Error; err != nil {
			return err
		}
		return tx.Raw("EXPLAIN " + query).Scan(&plan).Error
	})
	s.Require().NoError(err)
	return strings.Join(plan, "\n")
}

// The operations jobs' queries are each served by their partial index, in
// the order they read, so a run reads only what is due.
func (s *claimsSuite) TestJobQueriesUseTheirPartialIndexes() {
	e := s.newEnv()
	s.applyMigrations(e)

	cases := map[string]string{
		"idx_to_unexecuted_allocations": `SELECT * FROM transfer_orders
WHERE deleted_at IS NULL AND state IN (1, 2) AND extra_data ->> 'source' = 'payment_allocation'
  AND modified_at < now()
  AND (reference LIKE 'payment:%:loan:%' OR reference LIKE 'payment:%:member:%'
       OR (reference LIKE 'payment:%:obligation:%' AND extra_data ->> 'suspense_funded' = 'true'))
ORDER BY modified_at LIMIT 100`,
		"idx_to_late_failed_payouts": `SELECT * FROM transfer_orders
WHERE deleted_at IS NULL AND payout_status = 'failed' AND state = 4 AND originator_notified_at IS NULL
ORDER BY modified_at LIMIT 100`,
		"idx_ip_awaiting_allocation": `SELECT * FROM incoming_payments
WHERE deleted_at IS NULL AND owner_type IN ('client_loan', 'client_savings', 'investor_account', 'membership')
  AND coalesce(owner_id, '') <> '' AND state = 1
  AND modified_at < now() AND (allocating_at IS NULL OR allocating_at < now())
ORDER BY modified_at LIMIT 100`,
	}
	for index, query := range cases {
		s.Contains(s.planOf(e, query), index)
	}
}
