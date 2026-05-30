# MNSCloud Pulse Skill

Use this repository for the public Flutter employee time clock client.

## Rules

- Treat this app as a public API client.
- Do not place secrets, customer data, production domains, private policies, or payroll formulas in
  the repository.
- Keep sensitive decisions in the MNSCloud API/control plane.
- Use Pulse login codes issued by the API. Never derive employee login from CPF, document, phone,
  personal email, or name.

## Validation

```bash
flutter analyze
flutter test
```
