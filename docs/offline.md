# Pulse offline punches

Pulse records a mark even without connection, on the web (installed PWA or browser tab) and on the
native apps. Offline is an exception: the mark is flagged `offline` and the server keeps deciding
the official record (NSR, hash chain, receipt).

## Where a mark lives until the API acknowledges it

- **Encrypted queue.** `PunchStore` (`lib/src/core/punch_queue.dart`) is one SQLite database
  encrypted with SQLite3MultipleCiphers: a native file on Android, iOS and desktop, IndexedDB through
  `web/sqlite3mc.wasm` in the browser (pinned by `scripts/fetch-sqlite-wasm.sh`, precached by the
  service worker). The key is random per device and lives only in secure storage. Marks of earlier
  versions (plain `shared_preferences`) move into it on the first read.
- **Secure storage** (`lib/src/offline/secret_vault.dart`): the database key, the device key with its
  counter and grant, the native refresh token and the profile used to open offline. Never the
  password.

## Sending

`PunchSync` (`lib/src/offline/punch_sync.dart`) is the only sender, oldest mark first:

1. With the live session of the account: `POST /pulse/punches` with `offline=true` and the device
   time corrected by the offset measured with `GET /pulse/time`.
2. Without it (expired, app closed, sign-out, opened offline): `POST /pulse/device/punches`, signed
   by the **offline grant** of this device (`lib/src/offline/device_grant.dart`).

It runs at start, every 30 seconds, when the browser regains connection, when the app returns to the
foreground and after every new mark. Network failures stop the pass; a mark the API refuses as
invalid leaves the queue; a refused access keeps the marks until access is back.

## Offline grant

- While a session is live the app registers an ECDSA P-256 key (`POST /pulse/devices`): the private
  key never leaves secure storage, the registration is signed to prove possession, and the grant
  lasts 30 days, renewed at most once a day by any online session.
- Each signed request carries `X-Device-Id`, `X-Device-Timestamp`, `X-Device-Counter` and
  `X-Device-Signature` over `MNSCLOUD-PULSE-DEVICE-V1`, the path, the time, the counter and the
  SHA-256 of the exact body. The counter is stored before the request and grows on every request; the
  browser tabs share a Web Lock so they never reuse one (a repeated counter revokes the device).
- The grant ends with its validity, a replayed counter, a password change or reset, an HR session
  revocation, or an inactive account. A sign-out keeps it, so marks taken before are still delivered.
  A refused grant keeps the marks for the next session.

## Opening without connection

When the app opens offline, the employee who did not sign out on this device (profile in secure
storage) gets the punch screen in offline mode. The marks are queued and sent as above; when the
connection returns, the session is restored (refresh cookie on the web, secure storage on native).
Signing out removes that profile: nobody else can open the punch screen offline.

## Limits

- The web queue protects against disk copies and casual reading, not against code running in the
  page (the edge CSP is the defense).
- Offline marks older than 72 hours are flagged `late_sync`; a device time in the future is replaced
  by the server time (`future_time`).
- Native background sending (WorkManager, BGTaskScheduler) is not used: marks go when the app runs.
