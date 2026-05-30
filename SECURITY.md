# Security Policy

Report security issues privately to the MNSCloud maintainers.

Do not open public issues for vulnerabilities involving authentication, tenant isolation, time clock
tampering, geofence bypasses, credential leakage, or payroll/audit integrity.

This repository must not include:

- Tokens, passwords, private keys, signing secrets, or API credentials.
- Customer data or production tenant examples.
- Private API hosts, internal network addresses, or provider account details.
- API-side policy logic that would bypass the MNSCloud control plane.

The Flutter app may store only short-lived user/session data issued by the API. Persistent secrets
and sensitive decisions stay server-side.
