## 0.4.0

- **Breaking:** regenerated with protoc_plugin 25.1 (`buf.build/protocolbuffers/dart:v25.1.0`)
  and connect-dart 2.0 (`buf.build/connectrpc/dart:v2.0.0`); requires
  `protobuf ^6.1.0`, `connectrpc ^2.0.0`, `fixnum ^1.1.1`,
  `antinvestor_api_common ^2.0.0` and Dart `^3.7.0`.
- Well-known types (`Struct`, `Timestamp`, ...) now come from
  `package:protobuf/well_known_types/...`; the vendored copies and empty
  `.pbserver.dart` files are gone. Map fields take entries in generated
  constructors.

## 0.3.0

- Add TransferOrderSearchResponse.next_cursor
- Add TransferOrderType enum and transfer_type field; int order_type deprecated
- Regenerated from latest proto definitions

## 0.2.0

- Money fields use common.v1.Money
- Regenerated from latest proto definitions

## 0.1.0

- Generated Dart SDK from proto definitions

