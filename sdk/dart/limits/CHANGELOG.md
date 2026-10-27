## 0.3.1

- `LimitsAdminService.LimitsJobRun` (`LimitsJob`, permission
  `limits_job_run`): the scheduler's reservation and approval expiry passes.
  Service accounts only.

## 0.3.0

- **Breaking:** regenerated with protoc_plugin 25.1 (`buf.build/protocolbuffers/dart:v25.1.0`)
  and connect-dart 2.0 (`buf.build/connectrpc/dart:v2.0.0`); requires
  `protobuf ^6.1.0`, `connectrpc ^2.0.0`, `fixnum ^1.1.1`,
  `antinvestor_api_common ^2.0.0` and Dart `^3.7.0`.
- Well-known types (`Struct`, `Timestamp`, ...) now come from
  `package:protobuf/well_known_types/...`; the vendored copies and empty
  `.pbserver.dart` files are gone. Map fields take entries in generated
  constructors.

## 0.2.0

- Add next_cursor on all search responses
- Add PolicyHistory RPC and PolicyVersionObject
- Add limits_archive permission
- Add ReservationObject.reverses_reservation_id/notes, LimitsAuditSearchRequest.tenant_id
- Validation: ReserveRequest.ttl lte 3600s, cap_amount positive, cap_count gte 1
- Regenerated from latest proto definitions

## 0.1.0

- Generated Dart SDK from proto definitions
