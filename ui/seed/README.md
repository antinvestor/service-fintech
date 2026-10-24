# Seed UI

The Seed lending operations console: organizations, org units, workforce,
teams, access roles, investors, clients, loans, limits and portfolio
analytics. Composed from the shared `antinvestor_ui_*` libraries;
`ui/identity`, `ui/loans` and `ui/limits` supply most of the screens.

## Local setup

Seed resolves `antinvestor_ui_core`, `antinvestor_ui_profile` and
`antinvestor_ui_geolocation` from pub.dev. To develop against local checkouts
of `common/` and `service-profile/` sitting beside this repo, create a
`pubspec_overrides.yaml` (gitignored):

```yaml
dependency_overrides:
  antinvestor_ui_core:
    path: ../../../common/ui_core
  antinvestor_ui_profile:
    path: ../../../service-profile/ui/profile
  antinvestor_ui_geolocation:
    path: ../../../service-profile/ui/geolocation
```

Then:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

## Configuration

Every environment value arrives through `--dart-define` (see
`lib/core/config/app_config.dart`). Debug builds fall back to development
defaults; **release builds have no defaults** and `AppConfig.assertConfigured()`
aborts startup when any of these is missing:

| Define           | Purpose                                    |
|------------------|--------------------------------------------|
| `OIDC_CLIENT_ID` | OAuth2 public client id for the environment |
| `OIDC_ISSUER`    | OIDC discovery issuer                       |
| `API_BASE_URL`   | Gateway base URL for every backend service  |

Per-service overrides are optional and default to a path under
`API_BASE_URL`:

| Define            | Default                      | Serves                          |
|-------------------|------------------------------|---------------------------------|
| `IDENTITY_URL`    | `$API_BASE_URL/identity`     | identity + field (clients)      |
| `LOANS_URL`       | `$API_BASE_URL/loans`        | loan products, requests, book   |
| `PROFILE_URL`     | `$API_BASE_URL/profile`      | profiles                        |
| `FILES_URL`       | `$API_BASE_URL/files`        | uploads                         |
| `AUDIT_URL`       | `$API_BASE_URL/audit`        | audit trail                     |
| `GEOLOCATION_URL` | `$API_BASE_URL/geolocation`  | areas                           |
| `TENANCY_URL`     | `$API_BASE_URL/tenancy`      | partitions                      |
| `THESA_BASE_URL`  | `$API_BASE_URL/thesa`        | dashboard analytics             |

Build production with `make ui-build-prod` from the repo root, which requires
`OIDC_CLIENT_ID_PROD`, `OIDC_ISSUER_PROD` and `API_BASE_URL_PROD` in the
environment and fails rather than shipping development credentials.

## Authorization

Navigation and routing both gate on the capability set returned by identity
(see `lib/core/auth/permission_checker.dart` for the endpoint contract). The
resolution **fails closed**: when the capability endpoints cannot be reached,
no permission-gated item is shown and no permission-gated route is reachable.

## Fonts

Manrope and Inter are bundled under `assets/google_fonts/` and runtime fetching
is disabled, so the app never contacts `fonts.googleapis.com`.

## Checks

```bash
flutter analyze --no-fatal-infos
dart format --set-exit-if-changed .
flutter test
flutter build web --no-web-resources-cdn
```

`--no-web-resources-cdn` bundles the CanvasKit/skwasm runtime with the app.
Without it Flutter loads it from `www.gstatic.com`, which the Content Security
Policy in `web/index.html` blocks — deliberately, since a lending console
should not depend on a third-party host to render.
