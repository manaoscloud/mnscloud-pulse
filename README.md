# MNSCloud Pulse

MNSCloud Pulse is the public Flutter client for employee time clock workflows.

The app is intentionally a public API client. It must never contain customer data, production hosts,
API secrets, provider credentials, password hashes, tenant-specific policy rules, payroll formulas,
or private infrastructure details.

## Product Scope

- Employee login with a random Pulse login code, not CPF, document, phone, or personal email.
- First-login temporary password flow.
- Clock in, break start, break end, and clock out.
- Employee timesheet visibility.
- Adjustment and absence requests.
- Future mobile, web, desktop, and kiosk deployment targets.

## Security Boundary

The Flutter client only handles user experience and local session state.

The MNSCloud API owns:

- Pulse login code uniqueness.
- Password hashing and reset flows.
- Tenant and employee scope.
- Rate limiting and lockout decisions.
- Geofence, GPS, device, and audit validation.
- Timesheet consolidation and payroll export rules.

## Local Development

```bash
flutter pub get
flutter run
```

The first development screen accepts an API base URL and talks to the public Pulse API:

- `POST /api/v1/pulse/auth/signin`
- `GET /api/v1/pulse/auth/me`
- `POST /api/v1/pulse/auth/change-password`
- `POST /api/v1/pulse/punches`
- `GET /api/v1/pulse/punches`

Punch creation uses a client-generated idempotency key so retries and future offline sync can be
processed exactly once by the API.

## Runtime Configuration

The API base URL must be supplied through public-safe runtime configuration. Use placeholders in
examples:

```text
https://api.example.com/api/v1
```

Do not commit production domains, customer tenant domains, tokens, or credentials.
