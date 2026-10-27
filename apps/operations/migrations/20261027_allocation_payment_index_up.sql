-- A payment's allocation reads back what its earlier runs already paid to
-- obligations (SumConsumedObligationOrders) before spending the rest; the
-- allocation orders carry the payment they spend in extra_data.
CREATE INDEX IF NOT EXISTS idx_to_allocation_payment
ON transfer_orders ((extra_data ->> 'payment_id'))
WHERE deleted_at IS NULL AND extra_data ->> 'source' = 'payment_allocation';
