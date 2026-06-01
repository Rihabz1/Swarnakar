# Security Guidelines for Swarnakar

This document outlines security best practices and requirements for Swarnakar.

## Table of Contents

- [Security Overview](#security-overview)
- [Authentication Security](#authentication-security)
- [Data Protection](#data-protection)
- [API Security](#api-security)
- [Infrastructure Security](#infrastructure-security)
- [Dependency Management](#dependency-management)
- [Incident Response](#incident-response)
- [Security Checklist](#security-checklist)

## Security Overview

Swarnakar handles sensitive user data including:
- Email addresses and passwords
- Profile information
- Financial calculations (gold/silver values)
- Subscription and billing data

Security is a shared responsibility between:
- **Developers** - Write secure code
- **DevOps** - Secure infrastructure
- **Users** - Use strong passwords, enable 2FA

## Authentication Security

### Password Requirements

**Client-side validation (Flutter):**
```dart
bool isStrongPassword(String password) {
  return password.length >= 8 &&
    RegExp(r'[A-Z]').hasMatch(password) && // Uppercase
    RegExp(r'[a-z]').hasMatch(password) && // Lowercase
    RegExp(r'[0-9]').hasMatch(password) && // Number
    RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password); // Special char
}
```

**Firebase Auth constraints:**
- Minimum 6 characters (enforced by Firebase)
- Recommended: 8+ characters with mixed case, numbers, symbols

### Firebase Auth Best Practices

1. **Enable Email Verification**
   - Verify email before granting access
   - Resend verification emails after 24 hours
   - Prevent email abuse by disabling unverified accounts

2. **Enable Multi-Factor Authentication (MFA)**
   ```dart
   // Enable phone-based MFA in Firebase Console
   // Users can enable TOTP in Settings screen
   ```

3. **Implement Password Reset Flow**
   ```dart
   // Current: OTP + Reset Token
   // Future: Email links or SMS verification
   ```

### OTP Security

**OTP Generation:**
```typescript
// Use cryptographically secure random
const otp = crypto.randomInt(100000, 999999).toString();
const hash = sha256(email + purpose + otp);
```

**OTP Storage:**
```typescript
// Store hashed OTP, not plain text
otpMap.set(email, {
  otpHash: sha256(otp),
  expiresAt: Date.now() + 10 * 60 * 1000,
  attempts: 0,
  purpose: 'reset_password'
});
```

**OTP Constraints:**
- 6 digits (1 million possibilities)
- 10-minute expiry
- 5 maximum attempts per OTP
- Rate limited: 10 per hour per email
- 45-second cooldown between requests

### JWT Token Security

**Token Generation:**
```typescript
const token = jwt.sign(
  { uid: user.uid, email: user.email },
  process.env.JWT_SECRET,
  { expiresIn: '7d' } // Short expiry
);
```

**Token Verification:**
```typescript
// Current implementation (development)
jwt.decode(token) // ⚠️ Only decodes, doesn't verify

// Production implementation
jwt.verify(token, process.env.JWT_SECRET)

// Ideal implementation (Firebase tokens)
admin.auth().verifyIdToken(token)
```

**Token Security:**
- Never store token in localStorage (use httpOnly cookies instead)
- Always use HTTPS for token transmission
- Implement token refresh mechanism
- Short expiry times (7-30 days)
- Revoke tokens on logout
- Secure JWT_SECRET (minimum 32 characters)

## Data Protection

### Encryption

**In Transit (TLS/SSL):**
```
✅ All API calls use HTTPS
✅ Firestore uses encrypted connections
✅ Email communications use TLS
```

**At Rest:**
```
✅ Firestore data encrypted by default
✅ Firebase Storage encrypted by default
✅ Database backups encrypted
```

**Password Storage:**
```typescript
// ✅ Firebase Auth handles password hashing
// ✅ Never store plain-text passwords
// ✅ Use bcrypt for any custom implementations
import bcrypt from 'bcryptjs';

const hashedPassword = await bcrypt.hash(password, 10);
const isMatch = await bcrypt.compare(password, hashedPassword);
```

### Data Minimization

Store only necessary data:
```dart
// ✅ Good: Only store needed fields
UserModel(
  uid: user.uid,
  email: user.email,
  name: user.displayName,
  isSubscribed: false
)

// ❌ Bad: Storing unnecessary data
UserModel(
  uid: user.uid,
  email: user.email,
  fullProfile: {...}, // Entire profile
  temporaryData: "..." // Temp data
)
```

### Personally Identifiable Information (PII)

**Never log PII:**
```dart
// ❌ Bad
print('User email: $email');
logger.info('User: $user.email logged in');

// ✅ Good
logger.info('User authenticated successfully');
logger.debug('User ID: ${user.uid}'); // UID only
```

**Firestore Rules for PII:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
      
      // Block sensitive operations
      allow delete: if false; // Require custom function
    }
  }
}
```

## API Security

### CORS Configuration

**Development (Permissive):**
```typescript
app.use('*', cors({
  origin: '*',
  credentials: false
}))
```

**Production (Restrictive):**
```typescript
app.use('*', cors({
  origin: ['https://swarnakar.app', 'https://app.swarnakar.app'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization'],
  maxAge: 600 // 10 minutes
}))
```

### Request Validation

```typescript
// ✅ Validate all inputs
const validateEmail = (email: string): boolean => {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
};

// ✅ Sanitize inputs
import DOMPurify from 'isomorphic-dompurify';
const cleanEmail = DOMPurify.sanitize(email);

// ✅ Rate limiting
app.use('/api/*', rateLimiter({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // Limit each IP to 100 requests per windowMs
}))
```

### Authentication Middleware

```typescript
// Verify JWT before accessing protected routes
app.use('/api/profile', (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '');
  
  if (!token) {
    return c.json({ error: 'Missing token' }, 401);
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    c.set('user', decoded);
    return next();
  } catch (error) {
    return c.json({ error: 'Invalid token' }, 401);
  }
});
```

### Error Handling

```typescript
// ❌ Bad: Reveals internal details
return c.json({
  error: "Database connection failed at line 42 of db.ts"
}, 500)

// ✅ Good: Generic error message
return c.json({
  error: "An error occurred. Please try again later."
}, 500)

// ✅ Log detailed errors server-side only
logger.error('Database error:', err.message);
```

### API Versioning

```typescript
// Use versioning for breaking changes
app.route('/api/v1/profile', profileRoutesV1)
app.route('/api/v2/profile', profileRoutesV2)

// Support multiple versions during migration
```

## Infrastructure Security

### Firebase Security

**Firestore Rules:**
```javascript
// Implement principle of least privilege
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Default: deny all
    match /{document=**} {
      allow read, write: if false;
    }
    
    // Users can access their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Public collections (read-only)
    match /public/{doc=**} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

**Storage Security:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images: user can upload to their folder
    match /profiles/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

### Backend Secrets Management

**Never hardcode secrets:**
```typescript
// ❌ Bad
const API_KEY = "sk_live_abc123xyz";

// ✅ Good
const API_KEY = process.env.API_KEY;
```

**Use environment variables:**
```bash
# .env.production (Never commit!)
JWT_SECRET=<random-secure-string>
FIREBASE_PROJECT_ID=swarnakar-79e57
GOOGLE_APPLICATION_CREDENTIALS=./service-account.json
```

**Rotate secrets regularly:**
- Change JWT_SECRET monthly
- Rotate service account keys annually
- Regenerate SMTP passwords after incidents

### Network Security

**HTTPS Only:**
```nginx
# Redirect HTTP to HTTPS
server {
  listen 80;
  server_name swarnakar.app;
  return 301 https://$server_name$request_uri;
}

# HSTS: Force browsers to use HTTPS
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

**Headers Security:**
```typescript
app.use('*', (c, next) => {
  c.header('X-Content-Type-Options', 'nosniff');
  c.header('X-Frame-Options', 'DENY');
  c.header('X-XSS-Protection', '1; mode=block');
  c.header('Referrer-Policy', 'strict-origin-when-cross-origin');
  c.header('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');
  return next();
});
```

## Dependency Management

### Regular Updates

```bash
# Check for vulnerable dependencies
flutter pub outdated
flutter pub audit

cd backend
bun update
# or
npm audit

# Update regularly
git pull
flutter pub get
cd backend && bun install
```

### Lock Files

Always commit lock files:
```bash
git add pubspec.lock
git add package-lock.json
git add bun.lock
```

### Dependency Vetting

Before adding dependencies:
- [ ] Check package popularity and downloads
- [ ] Review maintainer reputation
- [ ] Check for open security issues
- [ ] Verify recent updates and maintenance
- [ ] Read changelog for breaking changes

### Known Vulnerability Checking

```bash
# Firebase console
firebase:audit

# Dart/Flutter
dart pub outdated --mode=null-safety

# Node.js
npm audit
bun pm audit
```

## Incident Response

### Security Incident Procedure

**1. Immediate Response (First 1 hour)**
- [ ] Isolate affected system
- [ ] Preserve logs and evidence
- [ ] Notify security team: sarkarkabbo72@gmail.com
- [ ] Document incident with timestamp

**2. Investigation (1-24 hours)**
- [ ] Determine scope of breach
- [ ] Identify root cause
- [ ] List affected users/data
- [ ] Check for ongoing access

**3. Remediation (24-72 hours)**
- [ ] Apply security patch
- [ ] Reset exposed credentials
- [ ] Rotate secrets
- [ ] Deploy fix to production
- [ ] Verify fix is effective

**4. Communication (Ongoing)**
- [ ] Notify affected users
- [ ] Post status update
- [ ] Provide remediation steps
- [ ] Request password changes

**5. Post-Mortem (Week 1-2)**
- [ ] Conduct root cause analysis
- [ ] Document lessons learned
- [ ] Implement preventive measures
- [ ] Update security policies

### Examples of Security Incidents

**Example 1: Exposed Service Account Key**
```
1. GitHub detects exposed key in commit history
2. Immediately revoke exposed key
3. Generate new service account key
4. Update backend GOOGLE_APPLICATION_CREDENTIALS
5. Notify Firebase project owner
6. Audit Firebase access logs for unauthorized activity
```

**Example 2: Brute Force Attack**
```
1. Monitor detects unusual login attempts
2. Rate limit exceeded for IP address
3. Block IP temporarily (24 hours)
4. Notify affected users
5. Implement CAPTCHA for multiple failed attempts
6. Enable MFA for accounts
```

## Security Checklist

### Development

- [ ] No hardcoded secrets or API keys
- [ ] Input validation on all forms
- [ ] Error messages don't reveal system details
- [ ] Passwords are never logged
- [ ] HTTPS enforced on all endpoints
- [ ] CORS properly configured
- [ ] SQL injection prevention (Firestore rules)
- [ ] XSS protection (Flutter/HTML escaping)
- [ ] CSRF tokens on state-changing operations

### Testing

- [ ] Security scan completed (OWASP)
- [ ] Penetration testing performed
- [ ] SQL injection tested
- [ ] XSS vulnerabilities checked
- [ ] Authentication bypass tested
- [ ] Authorization bypass tested
- [ ] Rate limiting tested
- [ ] API endpoint security tested

### Deployment

- [ ] All secrets rotated for production
- [ ] Environment variables configured
- [ ] HTTPS certificates valid
- [ ] Security headers configured
- [ ] Firestore rules deployed
- [ ] Firebase auth configured
- [ ] Database backups enabled
- [ ] Monitoring and alerts enabled
- [ ] Incident response plan tested

### Ongoing

- [ ] Weekly dependency security checks
- [ ] Monthly access log review
- [ ] Quarterly security audit
- [ ] Incident response drills
- [ ] Security training updated
- [ ] Vulnerability disclosures monitored

---

**Report security vulnerabilities to:** sarkarkabbo72@gmail.com  
**Do not open public issues for security bugs**
