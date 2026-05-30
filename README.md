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

- `POST /api/v1/pulse/auth/signin`
- `GET /api/v1/pulse/auth/me`
- `POST /api/v1/pulse/auth/change-password`
- `POST /api/v1/pulse/punches`
- `GET /api/v1/pulse/punches`

Punch creation uses a client-generated idempotency key so retries and future offline sync can be
processed exactly once by the API.

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
