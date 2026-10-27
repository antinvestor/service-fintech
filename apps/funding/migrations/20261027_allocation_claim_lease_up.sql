-- An allocation claim is leased to the call building the allocation: status
-- 1 while it is being built, 3 once it is complete, and claimed_at when the
-- holder took it. A call that finds an unfinished claim whose lease lapsed
-- takes it over, voids the partial allocation and builds it afresh, instead
-- of answering every retry with whatever the crashed holder left.
--
-- Claims recorded before this column existed keep status 3: complete.
ALTER TABLE loan_funding_claims ADD COLUMN IF NOT EXISTS claimed_at timestamptz;
