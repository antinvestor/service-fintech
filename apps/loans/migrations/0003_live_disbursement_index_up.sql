-- One live (processing or completed) disbursement per loan. Two requests
-- carrying different idempotency keys for the same loan must not both reach
-- the payment rail; the loser of this index is answered with the winner.
-- Fails on pre-existing duplicates by design: clean the data first.
CREATE UNIQUE INDEX IF NOT EXISTS uq_disb_partition_loan_live
    ON disbursements (partition_id, loan_account_id)
    WHERE status IN (2, 3) AND deleted_at IS NULL;
