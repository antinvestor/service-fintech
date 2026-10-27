-- A repayment schedule's own version number shared the base model's version
-- column, the optimistic-lock counter, so every update of a schedule (its
-- deactivation when the loan is re-anchored) affected no rows and loans kept
-- two active schedules. The number moves to schedule_version (added by
-- AutoMigrate); each loan keeps only its newest schedule active.

-- One statement per file: the migrator runs a file as a single command.
DO $$
BEGIN
    UPDATE repayment_schedules
    SET schedule_version = version
    WHERE schedule_version IS NULL OR schedule_version = 0;

    UPDATE repayment_schedules rs
    SET is_active = (rs.id = latest.id), modified_at = CURRENT_TIMESTAMP
    FROM (
        SELECT DISTINCT ON (loan_account_id) loan_account_id, id
        FROM repayment_schedules
        WHERE deleted_at IS NULL
        ORDER BY loan_account_id, generated_at DESC NULLS LAST, schedule_version DESC, id DESC
    ) latest
    WHERE rs.loan_account_id = latest.loan_account_id
      AND rs.deleted_at IS NULL
      AND rs.is_active IS DISTINCT FROM (rs.id = latest.id);
END $$;
