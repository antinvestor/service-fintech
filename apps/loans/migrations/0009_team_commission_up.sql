-- A team's commission balance is one row per team and currency, and each
-- accrual or payout is recorded once under its reference: an accrual is
-- keyed on the repayment that earned it, so a retried settlement credits it
-- once; a payout on its caller's key, so a retried payout never pays twice.

-- One statement per file: the migrator runs a file as a single command.
DO $$
BEGIN
    CREATE UNIQUE INDEX IF NOT EXISTS uq_tc_partition_team_currency
        ON team_commissions (partition_id, team_id, currency_code)
        WHERE deleted_at IS NULL;

    CREATE UNIQUE INDEX IF NOT EXISTS uq_tcm_partition_reference
        ON team_commission_movements (partition_id, reference)
        WHERE deleted_at IS NULL;

    CREATE INDEX IF NOT EXISTS idx_tcm_team_kind
        ON team_commission_movements (team_id, kind, created_at DESC)
        WHERE deleted_at IS NULL;
END $$;
