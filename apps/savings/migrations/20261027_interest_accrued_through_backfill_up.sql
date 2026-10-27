-- The interest job now catches up every day from interest_accrued_through
-- (or the day the account opened). An account the job never settled has
-- none; without a starting point the first run would back-accrue its whole
-- life. Start each such account at the beginning of the last closed day, or
-- the day it opened if later, so the first run accrues as the job always
-- did: the last closed day only.
UPDATE savings_accounts
SET interest_accrued_through = GREATEST(
        (date_trunc('day', now() AT TIME ZONE 'UTC') - interval '1 day') AT TIME ZONE 'UTC',
        date_trunc('day', created_at AT TIME ZONE 'UTC') AT TIME ZONE 'UTC')
WHERE interest_accrued_through IS NULL AND deleted_at IS NULL;
