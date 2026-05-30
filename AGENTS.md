# AGENTS.md

MNSCloud Pulse is a public Flutter API client for employee time clock workflows.

## Public Client Boundary

- Do not commit secrets, credentials, customer data, production domains, private IPs, payroll rules,
  tenant-specific policies, provider credentials, or internal topology.
- Do not implement API-side authorization, tenant scope, geofence decisions, password hashing, or
  payroll calculations as the only enforcement layer in Flutter.
- Use placeholders in documentation and examples.
- The API/control plane is the source of truth for identity, authorization, audit, and timesheet
  consolidation.

## Development

- Run `flutter analyze`.
- Run `flutter test`.
- Keep UI changes mobile-first and accessible.
- Keep platform-specific changes minimal unless the feature requires them.
