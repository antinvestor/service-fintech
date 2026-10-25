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

    -- Scheduled jobs claim their work from these partial indexes, so each run
    -- reads only what is due, whatever the size of the book.

    -- Delinquency: loans that can fall into or out of arrears, by when they are
    -- next due for assessment. Existing loans are due now.
    UPDATE loan_accounts SET next_assessment_at = now()
    WHERE next_assessment_at IS NULL AND status IN (2, 3, 6) AND deleted_at IS NULL;

    CREATE INDEX IF NOT EXISTS idx_la_assessment_due
        ON loan_accounts (next_assessment_at)
        WHERE status IN (2, 3, 6) AND deleted_at IS NULL;

    -- Reminders: carry over the claims recorded in properties, then index what
    -- is still to be reminded by due date.
    UPDATE schedule_entries SET due_reminded_at = now()
    WHERE due_reminded_at IS NULL AND jsonb_exists(COALESCE(properties, '{}'::jsonb), 'reminder_due_sent_at');

    UPDATE schedule_entries SET overdue_reminded_at = now()
    WHERE overdue_reminded_at IS NULL AND jsonb_exists(COALESCE(properties, '{}'::jsonb), 'reminder_overdue_sent_at');

    CREATE INDEX IF NOT EXISTS idx_se_due_unreminded
        ON schedule_entries (due_date)
        WHERE due_reminded_at IS NULL AND status <> 3 AND outstanding > 0 AND deleted_at IS NULL;

    CREATE INDEX IF NOT EXISTS idx_se_overdue_unreminded
        ON schedule_entries (due_date)
        WHERE overdue_reminded_at IS NULL AND status <> 3 AND outstanding > 0 AND deleted_at IS NULL;

    -- Request expiry: submitted or approved requests holding an offer deadline.
    CREATE INDEX IF NOT EXISTS idx_lr_offer_expiry
        ON loan_requests (offer_expires_at)
        WHERE status IN (2, 3) AND offer_expires_at IS NOT NULL AND deleted_at IS NULL;
END
$$;
