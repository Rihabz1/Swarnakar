# Release Quality Checklist

## Automated gates

- [ ] Dart formatting passes
- [ ] Flutter analysis reports zero issues
- [ ] Flutter unit/provider/widget tests pass
- [ ] Firestore Emulator Security Rules tests pass
- [ ] Coverage threshold passes
- [ ] Android release bundle builds and is signed correctly
- [ ] Web production build succeeds
- [ ] Dependency audit is reviewed

The workflow at .github/workflows/quality.yml enforces these checks on pull
requests and pushes. The initial line-coverage floor is 10%; increase it as
integration and screen coverage grows.

## Functional and non-functional

- [ ] P0/P1 requirements have traceable test evidence
- [ ] Authentication, reset, logout, and session expiry pass
- [ ] Subscription entitlement cannot be modified by clients
- [ ] Market prices and timestamps are verified
- [ ] Offline and reconnect flows pass
- [ ] Bengali text has no truncation at 200% scale
- [ ] Accessibility labels, focus, contrast, and tap targets pass
- [ ] Supported Android/browser matrix is executed
- [ ] Performance and crash monitoring are enabled

## Governance

- [ ] No critical/high defects remain without written acceptance
- [ ] Firestore rules were reviewed and deployed
- [ ] Production Firebase environment is selected
- [ ] Secrets, keystores, and customer data are absent from Git
- [ ] Privacy, terms, deletion, and retention flows are approved
- [ ] Rollback owner and procedure are identified
