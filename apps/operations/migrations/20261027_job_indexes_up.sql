-- Scheduled operations jobs read their work from these partial indexes, so
-- each run reads only what is due, whatever the size of the book. Each
-- predicate matches its query's WHERE clause, and each key its ORDER BY.

-- One statement per file: the migrator runs a file as a single command.
DO $$
BEGIN
    -- ListUnexecutedAllocations: payment allocation orders not yet executed
    -- (state 1 just created, 2 check created), oldest first.
    CREATE INDEX IF NOT EXISTS idx_to_unexecuted_allocations
        ON transfer_orders (modified_at)
        WHERE deleted_at IS NULL AND state IN (1, 2)
          AND extra_data ->> 'source' = 'payment_allocation';

    -- ListLateFailedPayouts: payouts the rail failed after the order settled
    -- (state 4 inactive) whose originator was not told yet, oldest first.
    CREATE INDEX IF NOT EXISTS idx_to_late_failed_payouts
        ON transfer_orders (modified_at)
        WHERE deleted_at IS NULL AND payout_status = 'failed' AND state = 4
          AND originator_notified_at IS NULL;

    -- ListAwaitingAllocation: matched payments (state 1) of an owner that can
    -- be allocated without a decision, oldest first.
    CREATE INDEX IF NOT EXISTS idx_ip_awaiting_allocation
        ON incoming_payments (modified_at)
        WHERE deleted_at IS NULL AND state = 1
          AND owner_type IN ('client_loan', 'client_savings', 'investor_account', 'membership')
          AND coalesce(owner_id, '') <> '';
END
$$;
