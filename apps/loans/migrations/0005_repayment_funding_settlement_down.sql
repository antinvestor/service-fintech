-- One penalty of a given type per installment. A late penalty is claimed by
-- inserting its row; a retried or concurrent delinquency scan that lost the
-- race reads the winner's row and resumes whatever that row still owes
-- (ledger posting, balance charge) instead of charging the borrower twice.
CREATE UNIQUE INDEX IF NOT EXISTS uq_pen_partition_entry_type
    ON penalties (partition_id, schedule_entry_id, penalty_type)
    WHERE schedule_entry_id <> '' AND deleted_at IS NULL;

DROP INDEX IF EXISTS idx_rep_funding_unsettled;
