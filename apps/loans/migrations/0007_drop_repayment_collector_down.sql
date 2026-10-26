DO $$
BEGIN
    ALTER TABLE repayments ADD COLUMN IF NOT EXISTS collected_by varchar(50);
    CREATE INDEX IF NOT EXISTS idx_rep_collector ON repayments (collected_by);
END $$;
