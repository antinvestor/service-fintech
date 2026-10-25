-- One penalty of a given type per installment. A late penalty is claimed by
-- inserting its row; a retried or concurrent delinquency scan that lost the
-- race reads the winner's row and resumes whatever that row still owes
-- (ledger posting, balance charge) instead of charging the borrower twice.

-- One statement per file: the migrator runs a file as a single command.
DO $$
BEGIN
    CREATE UNIQUE INDEX IF NOT EXISTS uq_pen_partition_entry_type
        ON penalties (partition_id, schedule_entry_id, penalty_type)
        WHERE schedule_entry_id <> '' AND deleted_at IS NULL;

    -- Every repayment recorded before applied_at existed was applied when it was
    -- recorded (a failed one had its key released and is REVERSED), so history
    -- is carried over as applied.
    UPDATE repayments SET applied_at = created_at
    WHERE applied_at IS NULL AND status IN (2, 3, 4) AND deleted_at IS NULL;

    -- Repayments still to be shared out to their loans' funders. The settlement
    -- job claims from this index, so its cost follows the backlog, not the
    -- table. Reversed repayments moved no money and are never shared.
    CREATE INDEX IF NOT EXISTS idx_rep_funding_unsettled
        ON repayments (created_at)
        WHERE funding_settled_at IS NULL AND applied_at IS NOT NULL AND status IN (2, 3, 4) AND deleted_at IS NULL;
END
$$;
