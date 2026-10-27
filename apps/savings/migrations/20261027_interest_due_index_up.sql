-- ListDueForInterest: active accounts (status 1) in the order the interest
-- job works them, least recently checked first. The index serves the ORDER
-- BY ... LIMIT, so a run stops after its batch instead of sorting the book.
CREATE INDEX IF NOT EXISTS idx_sa_interest_due
ON savings_accounts (interest_checked_at NULLS FIRST, id)
WHERE deleted_at IS NULL AND status = 1;
