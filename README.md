# MNSCloud Pulse

MNSCloud Pulse is the public Flutter client for employee time clock workflows.

The app is intentionally a public API client. It must never contain customer data, production hosts,
API secrets, provider credentials, password hashes, tenant-specific policy rules, payroll formulas,
or private infrastructure details.

## Product Scope

- Employee login with a random employee login code, not CPF, document, phone, or personal email.
- First-login temporary password flow.
- Clock in, break start, break end, and clock out.
- Employee timesheet visibility.
- Adjustment and absence requests.
- Future mobile, web, desktop, and kiosk deployment targets.

## Security Boundary

The Flutter client only handles user experience and local session state.

The MNSCloud API owns:

- Employee login code uniqueness.
- Password hashing and reset flows.
- Tenant and employee scope.
- Rate limiting and lockout decisions.
- Geofence, GPS, device, and audit validation.
- Timesheet consolidation and payroll export rules.

## Local Development

```bash
flutter pub get
flutter run -d web-server --web-port 8081 --dart-define PULSE_PUBLIC_API_BASE_URL=http://localhost:8000/api/v1
```

The client reads the public API base from deployment configuration and talks to the public Pulse API:

- `POST /api/v1/pulse/auth/signin`, `POST /api/v1/pulse/auth/refresh`, `POST /api/v1/pulse/auth/signout`
- `GET /api/v1/pulse/auth/me`, `POST /api/v1/pulse/auth/change-password`
- `GET /api/v1/pulse/time` (official server time)
- `POST /api/v1/pulse/punches`, `GET /api/v1/pulse/punches`
- `GET /api/v1/pulse/today`, `GET /api/v1/pulse/timesheet?month=YYYY-MM`

## Session

Every sign-in is a revocable server session. The client keeps a 15-minute access token in memory;
the rotating refresh token lives only in the HttpOnly cookie the API sets on the web (same origin),
so a page reload reopens the session without the password and nothing about the session is stored
by the app. HR can end the sessions of an account at any time (password reset, deactivation and
termination also end them). Native builds keep the refresh token in memory until secure storage
ships with the store apps.

## Punches

- `lib/src/punch/punch_workspace.dart` shows the official time (device clock corrected by the
  offset measured against `/pulse/time`), the suggested next mark and every other mark (never
  blocked), and the recent marks with the last receipt (NSR and hash).
- Each tap creates one UUID idempotency key and the mark is saved in a per-account queue on the
  device (`lib/src/core/punch_queue.dart`) before it is sent. Without connection it stays queued and
  is sent later as `offline` with the corrected time of the tap; a retry after a lost answer is
  recorded once by the API. Only marks are queued, never credentials or tokens.
- The position is read once at the moment of the punch (`lib/src/core/location_web.dart`,
  `location_io.dart`); there is no background tracking. A mark is recorded only with a position:
  GPS off, refused or timed out keeps it unrecorded with a message.
- `lib/src/permissions/permission_gate.dart` opens the signed-in app only when location, the camera
  (unless the policy is known to take no photo) and notifications (where the platform has them) are
  allowed. One tap asks every missing permission once and the browser or the system keeps the
  answer; the gate checks again when the app returns to the foreground and before every mark, and a
  permission blocked in the settings keeps the app closed with instructions. Native apps check
  location; their camera is asked by the system camera and they have no notification channel yet.
- Photo at punch (`lib/src/core/punch_camera.dart`): the native front camera on phones and a live
  `getUserMedia` stream on the web (no file chooser, so an old picture cannot be sent). With the
  policy `required` (also the default without a policy) the mark is confirmed only with a photo.
- The API owns the official time, the immutable ledger (NSR and SHA-256 per establishment) and the
  flags (offline, late sync, clock skew, sequence); the client never decides them.

## Company time clock (kiosk mode)

One device serves many employees (handoff `docs/handoffs/2026-11-10-pulse-kiosk-assessment.md` of the
workspace, K2). The sign-in page offers "Use this device as the company time clock"
(`lib/src/kiosk/kiosk_activation.dart`): the one-time activation code HR generated in the App
(HR › Time clocks) and a local administrator PIN. The device keeps an ECDSA P-256 key and the
monotonic counter in the platform secure storage (`lib/src/kiosk/kiosk_client.dart`) and signs every
`/pulse/kiosk/*` request (`MNSCLOUD-PULSE-KIOSK-V1`); the counter is stored before sending.

An activated device opens straight in `lib/src/kiosk/kiosk_view.dart`: official clock, the employee
access code, a PIN pad, the suggested mark (every mark allowed), a live photo when the time clock asks
for it, the position, and the receipt on screen (NSR, hash) that returns to the start after
10 seconds; an unfinished step resets after 45 seconds of inactivity. The profile is checked every
5 minutes: a time clock revoked by HR stops at once. Leaving the mode needs the administrator PIN
(checked on the device; HR revokes the time clock in the App). The permission gate requires location
and, when the photo is asked, the camera; notifications are not needed. The time clock needs a
connection to record (offline kiosk marks are a later phase). Employees set their personal time
clock PIN in the signed-in app (key icon, current password required; 4 to 6 digits, no sequence or
repeated digit).

## Today and timesheet

The signed-in app has two tabs in a bottom navigation bar: **Home** (the punch workspace) and
**Timesheet**. Employees see results, never the rules behind them; the API computes every value.

- `lib/src/timesheet/today_card.dart` adds a compact *Today* card under the official clock: the
  expected shift (or day off, holiday, no schedule), the worked time (ticking every minute while
  working) and the state (working, on break, off duty). It reads `/pulse/today` on open, after each
  mark that reaches the API (also from the offline queue) and every 60 s while visible. Any failure
  hides the card; punching never depends on it.
- `lib/src/timesheet/timesheet_view.dart` shows one month (previous months available, never a
  future one): totals (worked, expected, balance, overtime, absences) and the days newest first
  with their marks (`LocalTime`, already in the policy time zone), worked time, balance and short
  labels for anything to review. Marks not yet in a consolidated day appear as a note. Pull down
  or use the refresh action to read it again.

## Runtime Configuration

The public API endpoint is supplied through public-safe module configuration. In production, the webapps
runtime reads `/etc/mnscloud/webapps/apps.d/pulse.env`. In the MNSCloud workspace, use
`make pulse-web` or `make pulse-web-debug`; the script reads the same `pulse.env` contract when it
exists and falls back to development workspace values.

For standalone Flutter commands, pass a dart define. Use placeholders in examples:

```bash
flutter build web --release --dart-define PULSE_PUBLIC_API_BASE_URL=https://api.example.com/api/v1
```

Do not commit production domains, customer tenant domains, tokens, or credentials.

### Prebuilt web bundle

Every GitHub Release ships `mnscloud-pulse-web-v<version>.tar.gz` plus `.sha256`, built with
`--base-href /` and the default same-origin API base `/api/v1`. `mnscloud-webapps` installs it with
`APP_SOURCE=release`, verifies the checksum and rewrites `<base href>` to its hosting path (for
example `/pulse/`), so the host needs no Flutter SDK. Deployments that need a different API base
must build from source with the `--dart-define` above (`APP_SOURCE=build`).

## New version notice

On the web build an open Pulse detects a newer release without a refresh:
`lib/src/version/app_update_controller.dart` reads `build.json` (written by `mnscloud-webapps` next
to `index.html` of the active release) on start, every ~5 min while visible and when the page
becomes visible or online again, and compares it with `appBuildInfo.version`, stamped from
`pubspec.yaml` at release by `scripts/sync-app-build-info.sh`. A different version is accepted
after two reads 45 s apart and shown as a calm card (`Update now` / `Later`, 4 h per version) that
says the employee will sign in again. Native builds do not run the detector.

Critical updates: a release that fixes a serious problem sets `minimumVersion` in
`web/update-policy.json` (usually to its own version, in the same PR). `mnscloud-webapps` copies it
into `build.json`; pages running below it get an "important update" notice without the postpone
action. It never reloads by itself. Keep it `null` for regular releases.

## Themed access and languages

Pulse loads the domain's public brand and `LoginAppearance` from
`GET /api/v1/public/theme/context?app=pulse`. Settings › Themes configures the brand and login
presentation. Missing Pulse presentation inherits App layout/image/links, while access instructions
use Pulse's own PT-BR, EN-US and ES-ES defaults. Language can follow the device or a saved preference;
switching it does not clear the form. Only that preference and queued marks are persisted, never the
session or password.

The access shell adapts to desktop/mobile and light/dark/system. First access uses the same shell
for the mandatory password change and never loads punches before that change. There is no public
self-registration, account recovery or remember-me flow added by the presentation configuration.

Panel images and help/legal links are optional HTTPS URLs. Logo/favicon retain their existing
upload contract. PWA installation name/icons remain the release defaults; the runtime favicon and
page identity follow the theme. Native clients keep the default brand unless their configured API
resolves a theme; organization discovery and store-icon branding are outside this web delivery.

Offline punches (encrypted queue, device grant, sending without a session): `docs/offline.md`.
