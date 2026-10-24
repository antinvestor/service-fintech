## 0.7.0

- **Breaking:** regenerated with protoc_plugin 25.1 (`buf.build/protocolbuffers/dart:v25.1.0`)
  and connect-dart 2.0 (`buf.build/connectrpc/dart:v2.0.0`); requires
  `protobuf ^6.1.0`, `connectrpc ^2.0.0`, `fixnum ^1.1.1`,
  `antinvestor_api_common ^2.0.0` and Dart `^3.7.0`.
- Well-known types (`Struct`, `Timestamp`, ...) now come from
  `package:protobuf/well_known_types/...`; the vendored copies and empty
  `.pbserver.dart` files are gone. Map fields take entries in generated
  constructors.

## 0.6.0

- Add ClientDataListResponse.next_cursor
- Deprecate reviewer_id on ClientDataVerify/Reject/RequestInfo (reviewer derived from claims)
- Add ClientGroupSearch and MembershipSearch filter fields
- Deprecate identity InvestorAccount RPCs (owned by funding); role bindings dropped
- Add max_len validation on organization and org-unit name/code, cursor limit lte 200
- Regenerated from latest proto definitions

## 0.5.0

- Add OrganizationType values TRADING, RETAIL, MANUFACTURING, LOGISTICS, SERVICES
- Regenerated from latest proto definitions (partition_id optional on organization create)

## 0.4.0

- Add domain field to OrganizationObject (field 13)
- Regenerated from latest proto definitions

## 0.3.0

- Add OrganizationObject properties, client_id, partition_id fields
- Add workforce member, internal team, access role assignment messages

## 0.2.0

- Add form template and submission messages

## 0.1.0

- Generated Dart SDK from proto definitions
