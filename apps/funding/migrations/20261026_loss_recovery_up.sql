-- One recovery per reference, so repeating LoanRecoveryApply returns the
-- funders' share once.
CREATE UNIQUE INDEX IF NOT EXISTS uq_recovery_reference
ON loss_recoveries (reference)
WHERE reference <> '' AND deleted_at IS NULL;
