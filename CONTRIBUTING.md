# Contributing

Thanks for contributing to MNSCloud Pulse.

Contributions must preserve the public client boundary:

- Use Pull Requests.
- Keep examples generic and public-safe.
- Do not add secrets, customer data, production URLs, internal topology, or private business rules.
- Keep authorization, tenant scope, password hashing, geofence validation, audit decisions, and
  payroll calculations API-side.

Before opening a PR:

```bash
flutter analyze
flutter test
```
