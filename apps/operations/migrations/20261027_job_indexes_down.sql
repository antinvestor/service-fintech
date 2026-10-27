DO $$
BEGIN
    DROP INDEX IF EXISTS idx_to_unexecuted_allocations;
    DROP INDEX IF EXISTS idx_to_late_failed_payouts;
    DROP INDEX IF EXISTS idx_ip_awaiting_allocation;
END
$$;
