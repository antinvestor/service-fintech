-- Nobody collects repayments on a borrower's behalf: every repayment is a
-- payment the borrower made from their own contact, applied by the payment
-- rail. The collector column and its index go.

-- One statement per file: the migrator runs a file as a single command.
DO $$
BEGIN
    DROP INDEX IF EXISTS idx_rep_collector;
    ALTER TABLE repayments DROP COLUMN IF EXISTS collected_by;
END $$;
