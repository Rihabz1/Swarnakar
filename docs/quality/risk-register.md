# Quality Risk Register

| ID | Risk | Likelihood | Impact | Rating | Mitigation/status |
| --- | --- | --- | --- | --- | --- |
| R-01 | Custom client authentication cannot satisfy secure rules | High | Critical | Critical | Migrate to Firebase Auth/trusted backend |
| R-02 | Signup accepts arbitrary non-empty OTP | High | Critical | Critical | Verified server-issued SMS OTP |
| R-03 | Client can toggle temporary subscription state | High | Critical | Critical | Server-verified payment entitlement |
| R-04 | Web build fails in platform-view registration | Certain | High | Critical | Migrate deprecated web API |
| R-05 | Calculator unit does not alter formula | High | High | High | Define and test unit conversion rules |
| R-06 | Reports use mock data | Certain | Medium | High | Persist owner-scoped reports |
| R-07 | Third-party chart executes remote JavaScript | Medium | High | High | CSP, vendor review, fallback |
| R-08 | No Flutter end-to-end suite | High | Medium | High | Add emulator-backed critical journeys |
| R-09 | Emulator npm tree reports 8 vulnerabilities | Medium | Medium | Medium | Audit, upgrade, review production exposure |
| R-10 | DNS check may misclassify a valid network | Medium | Medium | Medium | Use owned health endpoint |

Review this register at each milestone and whenever architecture, dependencies, authentication, payments, or data access changes.
