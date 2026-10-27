DO $$
BEGIN
    DROP INDEX IF EXISTS idx_la_paid_off_unnoticed;
    ALTER TABLE loan_accounts DROP COLUMN IF EXISTS paid_off_notice_claimed_at;
    ALTER TABLE loan_accounts DROP COLUMN IF EXISTS paid_off_noticed_at;
END $$;
