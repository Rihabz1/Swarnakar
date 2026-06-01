# Troubleshooting Guide for Swarnakar

Common issues and their solutions.

## Table of Contents

- [Flutter/Frontend Issues](#flutterflutter-issues)
- [Backend Issues](#backend-issues)
- [Firebase Issues](#firebase-issues)
- [Network & CORS Issues](#network--cors-issues)
- [Authentication Issues](#authentication-issues)
- [Database Issues](#database-issues)
- [Deployment Issues](#deployment-issues)
- [Performance Issues](#performance-issues)

## Flutter/Frontend Issues

### Issue: "Flutter SDK not found"

**Error:**
```
The Flutter binary is not in your PATH.
```

**Solutions:**

```bash
# Add Flutter to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# Verify installation
flutter --version

# Verify all components
flutter doctor
```

---

### Issue: "No connected devices"

**Error:**
```
No devices available.
Run 'flutter emulator --launch <emulator id>' to start an emulator.
```

**Solutions:**

**Android Emulator:**
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch Pixel_6_API_30

# Or open Android Studio → Tools → Device Manager
```

**iOS Simulator:**
```bash
# Launch iOS simulator
open -a Simulator

# Or: Xcode → Xcode → Open Developer Tool → Simulator
```

**Web (Chrome):**
```bash
# Chrome should auto-launch
flutter run -d chrome

# Or specify Chrome path
flutter run -d chrome --dart-define=BROWSER_PATH=/path/to/chrome
```

**Physical Device:**
```bash
# Android: Enable USB debugging
# iOS: Trust the computer when connecting

# Verify device is detected
flutter devices

# Run on specific device
flutter run -d <device_id>
```

---

### Issue: "pubspec.lock conflicts"

**Error:**
```
version solving failed
```

**Solutions:**

```bash
# Clean and reinstall
flutter clean
rm pubspec.lock
flutter pub get

# Or upgrade all packages
flutter pub upgrade

# Or check for outdated packages
flutter pub outdated
```

---

### Issue: "Build fails with Java error"

**Error:**
```
Execution failed for task ':app:compileDebugKotlin'
```

**Solutions:**

```bash
# Clean build
flutter clean
cd android && ./gradlew clean
cd ..

# Rebuild
flutter run

# Or update Gradle
cd android
./gradlew wrapper --gradle-version=8.0
cd ..
```

---

### Issue: "Xcode build fails (iOS)"

**Error:**
```
Error (Xcode): Build input file cannot be found
```

**Solutions:**

```bash
# Clean Flutter
flutter clean

# Clean Xcode
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..

# Rebuild
flutter run -d ios
```

---

### Issue: "Firestore options not found"

**Error:**
```
MissingPluginException: No implementation found for method firebase initialization
```

**Solutions:**

```bash
# Regenerate Firebase options
flutterfire configure --project=swarnakar-79e57

# Reinstall packages
flutter pub get
flutter pub global activate flutterfire_cli

# Rebuild
flutter clean
flutter pub get
flutter run
```

---

### Issue: "Hot reload not working"

**Error:**
```
Hot reload failed.
```

**Solutions:**

```bash
# Do full restart instead
# In terminal, press 'R' during flutter run

# Or stop and restart
# Press Ctrl+C
flutter run

# Check file size (rebuild needed if > 100MB)
ls -lh build/app/outputs/flutter-apk/app.apk
```

---

### Issue: "Widget not updating after state change"

**Cause:** Riverpod provider not invalidating

**Solution:**

```dart
// ✅ Correct: Use ref.refresh() to update
ref.refresh(userProvider);

// ❌ Wrong: Direct state modification doesn't notify
state = newState; // Use ref.read().state = newState instead
```

---

## Backend Issues

### Issue: "Port 8787 already in use"

**Error:**
```
Error: listen EADDRINUSE: address already in use :::8787
```

**Solutions:**

```bash
# Find process using port
lsof -i :8787
# Or on Windows:
netstat -ano | findstr :8787

# Kill process
kill -9 <PID>

# Or use different port
PORT=8788 bun run dev
```

---

### Issue: "Bun: command not found"

**Error:**
```
bash: bun: command not found
```

**Solutions:**

```bash
# Install Bun
curl -fsSL https://bun.sh/install | bash

# Add to PATH
export PATH=$HOME/.bun/bin:$PATH

# Add to ~/.bashrc or ~/.zshrc
echo 'export PATH=$HOME/.bun/bin:$PATH' >> ~/.bashrc

# Verify
bun --version
```

---

### Issue: "Firebase service account key not found"

**Error:**
```
Error: ENOENT: no such file or directory, open './swarnakar-79e57-firebase-adminsdk-fbsvc-1f11cecb42.json'
```

**Solutions:**

```bash
# Check if file exists
ls -la backend/swarnakar-79e57-firebase-adminsdk-fbsvc-1f11cecb42.json

# Download from Firebase Console
# 1. Go to Firebase Console → Project Settings → Service Accounts
# 2. Click "Generate New Private Key"
# 3. Move to backend directory
mv ~/Downloads/swarnakar-79e57-firebase-adminsdk-fbsvc-1f11cecb42.json backend/

# Verify GOOGLE_APPLICATION_CREDENTIALS in .env
cat backend/.env | grep GOOGLE_APPLICATION_CREDENTIALS
```

---

### Issue: "TypeError: Cannot read property 'uid' of null"

**Cause:** User not authenticated but accessing protected route

**Solution:**

```typescript
// ✅ Check auth middleware
app.use('/api/profile', authMiddleware);

// ✅ Verify user before accessing
if (!c.get('user')) {
  return c.json({ error: 'Unauthorized' }, 401);
}

const user = c.get('user');
console.log('User UID:', user.uid);
```

---

### Issue: "SMTP error: connect ECONNREFUSED"

**Error:**
```
Error: connect ECONNREFUSED 127.0.0.1:587
```

**Solutions:**

```bash
# Check SMTP settings in .env
cat backend/.env | grep SMTP

# Test SMTP connection
telnet smtp.gmail.com 587

# If using Gmail, ensure app password is used
# NOT your regular Gmail password
# Generate at: https://myaccount.google.com/apppasswords

# Update .env
SMTP_USER=your-email@gmail.com
SMTP_PASS=xxxx-xxxx-xxxx-xxxx  # 16-char app password
```

---

### Issue: "TypeScript compilation errors"

**Error:**
```
error TS2307: Cannot find module '@types/node'
```

**Solutions:**

```bash
cd backend

# Install missing types
bun install --save-dev @types/node

# Or rebuild TypeScript cache
rm -rf node_modules/.vite
bun install

# Check tsconfig.json
cat tsconfig.json
```

---

## Firebase Issues

### Issue: "Firestore database creation returns 403"

**Error:**
```
HTTP 403 Forbidden
```

**Cause:** Billing not enabled

**Solutions:**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select **swarnakar-79e57** project
3. **Billing** → Link billing account
4. Wait 5-10 minutes
5. Go to Firestore → Create database

---

### Issue: "Firebase Auth: 'invalid-api-key'"

**Error:**
```
Invalid API key provided.
```

**Solutions:**

```bash
# Check firebase_options.dart
cat lib/firebase_options.dart

# If wrong project, regenerate
flutterfire configure --project=swarnakar-79e57

# Or manually update lib/firebase_options.dart
# with correct API key from Firebase Console
```

---

### Issue: "Authentication fails on real device"

**Error:**
```
FirebaseException: [firebase_auth/network-request-failed]
```

**Solutions:**

```bash
# Check internet connection
ping 8.8.8.8

# On iOS, check network config
# Project settings → Capabilities → Push Notifications

# On Android, add permissions to AndroidManifest.xml
# <uses-permission android:name="android.permission.INTERNET" />

# Verify Firebase app registered in Firebase Console
# Android: Check google-services.json
# iOS: Check GoogleService-Info.plist
```

---

### Issue: "Firestore rules deploy fails"

**Error:**
```
Error: Could not find any Firestore database in project
```

**Solutions:**

```bash
# Ensure database exists
firebase firestore:indexes describe

# If not, create first:
firebase firestore:create --region asia-south1

# Then deploy rules
firebase deploy --only firestore:rules

# Or deploy specific file
firebase deploy --only firestore:rules --debug
```

---

### Issue: "Storage permission denied"

**Error:**
```
FirebaseException: [firebase_storage/unauthorized]
```

**Solutions:**

Update `firebase.json` storage rules:

```json
{
  "storage": [
    {
      "bucket": "swarnakar-79e57.appspot.com",
      "rules": "storage.rules"
    }
  ]
}
```

Update `storage.rules`:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload to their profile folder
    match /profiles/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }
    
    // Allow public read of shared images
    match /public/{document=**} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

Then deploy:

```bash
firebase deploy --only storage
```

---

## Network & CORS Issues

### Issue: "CORS error: 'has been blocked by CORS policy'"

**Error:**
```
Access to XMLHttpRequest blocked by CORS policy
```

**Solutions:**

Check backend `src/index.ts` CORS configuration:

```typescript
// Development (permissive)
app.use('*', cors({
  origin: '*',  // Allow all
  credentials: false
}))

// Production (restrictive)
app.use('*', cors({
  origin: ['https://swarnakar.app', 'https://app.swarnakar.app'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']
}))
```

---

### Issue: "Android emulator cannot reach localhost"

**Error:**
```
Connection refused
```

**Cause:** Android emulator runs in isolated network

**Solutions:**

```bash
# Use 10.0.2.2 instead of localhost for backend URL
flutter run --dart-define=OTP_API_BASE_URL=http://10.0.2.2:8787

# Or configure in code
const String baseUrl = kIsWeb 
  ? 'http://localhost:8787'
  : 'http://10.0.2.2:8787';
```

---

### Issue: "iOS simulator cannot reach backend"

**Error:**
```
Network request failed
```

**Solutions:**

```bash
# Restart simulator
killall "com.apple.CoreSimulator.CoreSimulatorService"
open -a Simulator

# Or use physical device with actual network

# Check firewall
# System Preferences → Security & Privacy → Firewall
```

---

## Authentication Issues

### Issue: "OTP email not received"

**Cause:** Multiple possible reasons

**Solutions:**

```bash
# Check backend logs
# Should show: "OTP sent to email"

# Check spam/junk folder

# Verify SMTP in .env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=app-specific-password

# Test SMTP directly
# Create test script: backend/test-smtp.ts
import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 587,
  secure: false,
  auth: {
    user: 'your-email@gmail.com',
    pass: 'your-app-password'
  }
});

transporter.sendMail({
  from: 'your-email@gmail.com',
  to: 'recipient@example.com',
  subject: 'Test OTP',
  text: 'Your OTP is: 123456'
}, (err, info) => {
  if (err) console.error('Error:', err);
  else console.log('Sent:', info);
});

# Run test
bun backend/test-smtp.ts
```

---

### Issue: "OTP verification fails: 'Invalid code'"

**Error:**
```
OTP invalid or expired
```

**Solutions:**

```bash
# Check OTP hasn't expired (10 minutes)

# Check for typos

# In development, check browser console logs
# Should show debug OTP in response

# Verify in backend logs
# Should show OTP verification attempt

# Check email domain matches (case-insensitive)
```

---

### Issue: "Firebase Auth: 'weak-password'"

**Error:**
```
Password should be at least 6 characters
```

**Solutions:**

```dart
// Ensure password is strong
String password = '...';

if (password.length < 8) {
  showError('Password must be at least 8 characters');
  return;
}

if (!RegExp(r'[A-Z]').hasMatch(password)) {
  showError('Password must contain uppercase letter');
  return;
}

// Then sign up with Firebase
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password
);
```

---

### Issue: "Login fails: 'User disabled'"

**Error:**
```
The user account has been disabled
```

**Solutions:**

1. Go to Firebase Console
2. **Authentication** → **Users**
3. Find user and click **Disable** to re-enable

Or check for:
- Multiple failed login attempts (if rate limiting enabled)
- User deletion (if soft deleted)

---

## Database Issues

### Issue: "Firestore query returns empty despite data existing"

**Cause:** Incorrect collection name or index missing

**Solutions:**

```typescript
// Check collection name (case-sensitive)
// Backend checks both:
// - 'users'
// - 'Users'

// Add to Firestore indexes if querying by multiple fields
firebase firestore:indexes describe

// Or deploy index
firebase deploy --only firestore:indexes
```

---

### Issue: "Firestore write quota exceeded"

**Error:**
```
RESOURCE_EXHAUSTED: Too many concurrent requests
```

**Solutions:**

```typescript
// Implement batching
const batch = db.batch();

users.forEach(user => {
  batch.set(db.collection('users').doc(user.uid), user);
});

await batch.commit();

// Or implement exponential backoff
async function retryWrite(operation, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await operation();
    } catch (error) {
      if (i < maxRetries - 1) {
        await new Promise(r => setTimeout(r, Math.pow(2, i) * 1000));
      } else {
        throw error;
      }
    }
  }
}
```

---

## Deployment Issues

### Issue: "Deployment fails: 'Permission denied'"

**Error:**
```
Permission denied while trying to connect to Docker daemon
```

**Solutions:**

```bash
# Docker: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Firebase: Check authentication
firebase login

# Railway/Render: Check API token
# GitHub Secrets: Verify CI/CD variables
```

---

### Issue: "Deployed backend returns 502 Bad Gateway"

**Error:**
```
502 Bad Gateway
```

**Solutions:**

```bash
# Check if backend is running
curl https://api.swarnakar.app/health

# Check logs
railway logs
heroku logs
# or
firebase functions:log

# Restart service
railway up
# or
heroku restart

# Check environment variables
# Ensure all required .env variables are set
```

---

### Issue: "Web deployment shows old version"

**Cause:** Cache not cleared

**Solutions:**

```bash
# Clear browser cache
# Ctrl+Shift+Delete (Chrome)
# Cmd+Shift+Delete (Safari)

# Or hard refresh
# Ctrl+Shift+R (Chrome)
# Cmd+Shift+R (Safari)

# Firebase hosting
firebase deploy --only hosting

# Verify deployment
curl -I https://swarnakar.app

# Check cache headers
curl -I https://swarnakar.app | grep Cache-Control
```

---

## Performance Issues

### Issue: "App is slow / laggy"

**Solutions:**

```dart
// Profile app performance
flutter run --profile

// Or with tracing
flutter run --release --verbose

// Check widget rebuild frequency
// DevTools → Performance → Rebuild counts

// Optimize expensive widgets
// Use const constructors
const Text('Static text')

// Use shouldRebuild in Notifier
@override
bool updateShouldNotify(covariant OldNotifier old) {
  return old.value != value; // Only notify if changed
}
```

---

### Issue: "API responses are slow"

**Solutions:**

```typescript
// Add caching
app.use('/api/*', cache({ ttl: '5 minutes' }));

// Add indexes to Firestore queries
// Check composite indexes: Firebase Console → Indexes

// Implement pagination
app.get('/api/users', (c) => {
  const limit = parseInt(c.query('limit') || '10');
  const offset = parseInt(c.query('offset') || '0');
  
  // Return paginated results
});

// Monitor with tracing
const start = Date.now();
const result = await db.collection('users').get();
console.log(`Query took ${Date.now() - start}ms`);
```

---

### Issue: "Backend memory usage increasing"

**Cause:** Memory leak from in-memory OTP storage

**Solutions:**

```typescript
// Implement cleanup for expired OTPs
setInterval(() => {
  const now = Date.now();
  
  for (const [email, record] of otpMap.entries()) {
    if (record.expiresAt < now) {
      otpMap.delete(email);
    }
  }
}, 60 * 1000); // Every minute

// Or use database for OTP storage
// and implement TTL
```

---

## Getting Additional Help

If these solutions don't work:

1. **Check GitHub Issues:** https://github.com/yourusername/swarnakar/issues
2. **Check Logs:** Look for detailed error messages
3. **Firebase Console:** Check project diagnostics
4. **Contact:** sarkarkabbo72@gmail.com

When reporting issues, include:
- Error message (exact copy)
- Steps to reproduce
- Environment (OS, versions, device)
- Relevant code snippets
- Screenshots/logs

---

**Last updated:** May 18, 2026
