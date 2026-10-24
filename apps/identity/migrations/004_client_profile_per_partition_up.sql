-- A borrower is one client per lender (partition), not one client globally:
-- the same person may be served by two organizations. The global index is
-- replaced by a partition-scoped one that also ignores clients without a
-- profile yet. Fails on pre-existing duplicates by design.
DROP INDEX IF EXISTS uq_client_profile;
CREATE UNIQUE INDEX IF NOT EXISTS uq_client_partition_profile
    ON clients (partition_id, profile_id)
    WHERE profile_id <> '' AND deleted_at IS NULL;
