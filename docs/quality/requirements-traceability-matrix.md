# Requirements Traceability Matrix

| ID | Requirement | Risk | Automated evidence | Status |
| --- | --- | --- | --- | --- |
| CALC-01 | Calculate metal value and labour total | High | calculator_provider_test.dart | Pass |
| CONV-01 | Convert gram, bhori, and ounce bidirectionally | High | weight_converter_test.dart | Pass |
| ZAKAT-01 | Apply correct nisab boundary and 2.5% | High | zakat_calculator_test.dart, zakat_screen_test.dart | Pass |
| AUTH-01 | Accept valid Bangladesh mobile prefixes | High | bd_phone_number_test.dart | Pass |
| AUTH-02 | Reject invalid login input before request | Medium | login_screen_test.dart | Pass |
| PRICE-01 | Parse numeric Firestore price representations | High | price_mapper_test.dart | Pass |
| PRICE-02 | Group market values in correct sections | High | price_mapper_test.dart | Pass |
| SUB-01 | Expired subscriptions are inactive | Critical | subscription_provider_test.dart | Pass |
| RULE-01 | Only admins change market reference data | Critical | firestore.rules.test.js | Pass |
| RULE-02 | Users cannot grant their own entitlement | Critical | firestore.rules.test.js | Pass |
| RULE-03 | Users cannot read another profile/report | Critical | firestore.rules.test.js | Pass |
| AUTH-03 | Production identity satisfies Security Rules | Critical | Migration required | Open |
| WEB-01 | Optimized web build succeeds | High | flutter build web | Failing |
| E2E-01 | Signup through dashboard journey succeeds | Critical | Planned integration test | Planned |
