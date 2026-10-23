## 0.2.0

- Add next_cursor on all search responses
- Add PolicyHistory RPC and PolicyVersionObject
- Add limits_archive permission
- Add ReservationObject.reverses_reservation_id/notes, LimitsAuditSearchRequest.tenant_id
- Validation: ReserveRequest.ttl lte 3600s, cap_amount positive, cap_count gte 1
- Regenerated from latest proto definitions

## 0.1.0

- Generated Dart SDK from proto definitions
