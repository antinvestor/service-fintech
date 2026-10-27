DO $$
BEGIN
    DROP INDEX IF EXISTS idx_tcm_team_kind;
    DROP INDEX IF EXISTS uq_tcm_partition_reference;
    DROP INDEX IF EXISTS uq_tc_partition_team_currency;
END $$;
