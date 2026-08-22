# Swarnakar Test Strategy

## Objective

Provide risk-based evidence that calculation, identity, market-data, entitlement, and navigation behavior remains correct across supported Android and web environments.

## Test levels

| Level | Scope | Tool | Execution |
| --- | --- | --- | --- |
| Unit | Calculations, conversion, validation, mapping | flutter_test | Every change |
| Provider | Riverpod filtering and entitlement behavior | flutter_test | Every change |
| Widget | Validation, input, rendering, interaction | flutter_test | Every change |
| Security rules | Firestore authorization boundaries | Emulator and Node test | Every rules change |
| E2E | Critical authenticated journeys | integration_test | Before release |
| Exploratory | Usability, localization, resilience | Test charter | Before milestone |

## Risk-based priorities

- **P0:** authentication, authorization, subscription entitlement, release build.
- **P1:** market accuracy, zakat boundaries, calculations, offline recovery.
- **P2:** navigation, responsive UI, Bengali content, accessibility.
- **P3:** animation polish and non-critical visual differences.

## Entry criteria

- Dependencies resolve.
- Test environment and fixtures are available.
- Acceptance criteria are reviewed.
- Emulator tests use a non-production project ID.

## Exit criteria

- All P0 and P1 automated tests pass.
- No open critical/high security defect is accepted without owner approval.
- Static analysis has zero issues.
- Android and web release builds succeed.
- Security Rules allow/deny tests pass.
- Traceability and test summary are updated.

## Defect severity

| Severity | Definition |
| --- | --- |
| Critical | Credential exposure, authorization bypass, payment bypass, unusable release |
| High | Incorrect financial result, broken critical journey, data loss |
| Medium | Feature failure with workaround or limited affected users |
| Low | Cosmetic, copy, or minor usability problem |

## Coverage policy

Coverage supports—not replaces—risk analysis. Target 80% overall line coverage, 90% for pure business logic, and 100% coverage of defined Security Rules allow/deny cases.
