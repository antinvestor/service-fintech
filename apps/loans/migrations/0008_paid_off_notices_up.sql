-- A paid-off loan's notice to downstream products (seed) is retried until
-- acknowledged, so a borrower who repaid is never left blocked by a notice
-- that did not get through. The job finds what is still to be noticed from
-- this partial index.

-- One statement per file: the migrator runs a file as a single command.
DO $$
BEGIN
    ALTER TABLE loan_accounts ADD COLUMN IF NOT EXISTS paid_off_noticed_at timestamptz;
    ALTER TABLE loan_accounts ADD COLUMN IF NOT EXISTS paid_off_notice_claimed_at timestamptz;

    CREATE INDEX IF NOT EXISTS idx_la_paid_off_unnoticed
        ON loan_accounts (modified_at)
        WHERE status = 5 AND paid_off_noticed_at IS NULL AND deleted_at IS NULL;
END $$;
