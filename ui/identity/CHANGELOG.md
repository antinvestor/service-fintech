## 0.2.0

- **Breaking:** moves to connect-dart 2 and the protobuf 6 runtime:
  `antinvestor_ui_core ^0.6.0`, the protobuf-6 `antinvestor_api_*` SDKs,
  `connectrpc ^2.0.0`, `protobuf ^6.1.0`. Struct maps are passed as entries.

## 0.1.0

- Initial release
- Organization, org unit, branch, investor management screens and providers
- Workforce member listing, detail, and registration screens
- Access role assignment management
- Form template listing with status badges
- Client data entry providers (verify, reject, request info)
- Roles & Permissions reference matrix screen
- All providers use plain FutureProvider / NotifierProvider (no codegen)
