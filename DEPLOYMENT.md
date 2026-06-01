# Deployment Guide for Swarnakar

This guide covers deploying Swarnakar to production across different platforms.

## Table of Contents

- [Pre-Deployment Checklist](#pre-deployment-checklist)
- [Environment Configuration](#environment-configuration)
- [Frontend Deployment](#frontend-deployment)
- [Backend Deployment](#backend-deployment)
- [Mobile Deployment](#mobile-deployment)
- [Database Migration](#database-migration)
- [Monitoring & Logging](#monitoring--logging)
- [Troubleshooting](#troubleshooting)

## Pre-Deployment Checklist

### Code Quality

- [ ] All tests pass: `flutter test` and `cd backend && bun test`
- [ ] No analyzer warnings: `flutter analyze`
- [ ] Code formatted: `dart format lib/` and `cd backend && bun run format`
- [ ] No console.logs or debug prints in production code
- [ ] No hardcoded URLs or credentials
- [ ] Dependencies updated and audited

### Security

- [ ] Firebase Security Rules reviewed and deployed
- [ ] `.env` file not committed (add to `.gitignore`)
- [ ] Service account keys not committed
- [ ] JWT secrets changed from defaults
- [ ] CORS configured for specific domains
- [ ] HTTPS enabled for all endpoints
- [ ] Firebase Authentication enabled and configured
- [ ] Firestore backup enabled

### Preparation

- [ ] Firebase project created and configured (swarnakar-79e57)
- [ ] Firestore database created and indexed
- [ ] Storage buckets created (if using file uploads)
- [ ] Billing enabled on Firebase
- [ ] Domain registered and DNS configured
- [ ] SSL/TLS certificates obtained (if not using managed hosting)

## Environment Configuration

### Production `.env`

Create `backend/.env.production`:

```env
# Server
PORT=8787
NODE_ENV=production

# Firebase
FIREBASE_PROJECT_ID=swarnakar-79e57
GOOGLE_APPLICATION_CREDENTIALS=./swarnakar-79e57-firebase-adminsdk-fbsvc-1f11cecb42.json

# Security
JWT_SECRET=generate-a-strong-random-string-min-32-chars-use-crypto-random
JWT_EXPIRES_IN=7d

# OTP
OTP_EXPIRY_MINUTES=10
OTP_MAX_ATTEMPTS=5
OTP_RESEND_COOLDOWN_SECONDS=45
OTP_RATE_LIMIT_PER_HOUR=10

# SMTP
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=true
SMTP_USER=production-email@gmail.com
SMTP_PASS=your-app-specific-password
OTP_FROM_EMAIL=noreply@swarnakar.com

# CORS
ALLOWED_ORIGINS=https://swarnakar.app,https://www.swarnakar.app

# Database (if migrating from Firestore)
DATABASE_URL=postgresql://prod_user:secure_password@db.example.com:5432/swarnakar_prod

# Logging
LOG_LEVEL=info
```

### Generate Secure JWT Secret

```bash
# Using Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Using OpenSSL
openssl rand -hex 32

# Using Bun
bun -e "console.log(crypto.randomUUID())"
```

### Environment Variables in Deployment

**GitHub Secrets** (for CI/CD):
1. Go to Repository Settings → Secrets → New repository secret
2. Add:
   - `FIREBASE_SERVICE_ACCOUNT` - Service account JSON content
   - `FIREBASE_PROJECT_ID` - swarnakar-79e57
   - `JWT_SECRET` - Secure random string
   - `SMTP_PASSWORD` - Email app password
   - `DEPLOY_KEY` - SSH/API key for deployment

## Frontend Deployment

### Option 1: Firebase Hosting

**Pros:** Free tier available, simple setup, auto-HTTPS  
**Cons:** Limited to Firebase ecosystem

```bash
# Build web app
flutter build web --release

# Install Firebase CLI (if not already installed)
npm install -g firebase-tools
firebase login

# Configure Firebase hosting
firebase init hosting

# Deploy
firebase deploy --only hosting
```

**Configure firebase.json:**

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

### Option 2: Netlify

**Pros:** Great UI, easy deploy, auto-deploys from git  
**Cons:** Limited free tier bandwidth

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Build
flutter build web --release

# Deploy
netlify deploy --prod --dir=build/web
```

**netlify.toml:**

```toml
[build]
  command = "flutter build web --release"
  publish = "build/web"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*.js"
  [headers.values]
    Cache-Control = "public, max-age=31536000"
```

### Option 3: Vercel

**Pros:** Excellent performance, serverless functions  
**Cons:** Commercial focus

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod
```

**vercel.json:**

```json
{
  "buildCommand": "flutter build web --release",
  "outputDirectory": "build/web",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

### Option 4: Traditional Server (Nginx)

```nginx
server {
    listen 443 ssl http2;
    server_name swarnakar.app;

    ssl_certificate /etc/letsencrypt/live/swarnakar.app/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/swarnakar.app/privkey.pem;

    root /var/www/swarnakar/web;
    index index.html;

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|svg|woff2|woff|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
```

## Backend Deployment

### Option 1: Railway

**Pros:** Simple, good for Bun, auto-deploys from git  
**Cons:** Paid only

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Deploy
railway up

# View logs
railway logs
```

### Option 2: Render

**Pros:** Free tier available, good UX  
**Cons:** Slower free tier

1. Push code to GitHub
2. Go to [Render Dashboard](https://dashboard.render.com)
3. New → Web Service
4. Connect GitHub repo
5. Configure:
   - **Build Command:** `bun install`
   - **Start Command:** `bun run start`
   - **Environment:** Add production `.env` variables
6. Deploy

### Option 3: Vercel (Serverless Functions)

```bash
# Update backend/src/index.ts for serverless
export default app

# Deploy
vercel deploy --prod --env-file .env.production
```

**vercel.json:**

```json
{
  "buildCommand": "bun install",
  "functions": {
    "api/**": {
      "runtime": "bun"
    }
  },
  "env": {
    "NODE_ENV": "production"
  }
}
```

### Option 4: Docker (Any Cloud Provider)

**Dockerfile:**

```dockerfile
FROM oven/bun:latest

WORKDIR /app

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY . .

EXPOSE 8787

ENV NODE_ENV=production

CMD ["bun", "run", "start"]
```

**Deploy to Docker Hub:**

```bash
# Build
docker build -t yourusername/swarnakar-backend:latest .

# Login
docker login

# Push
docker push yourusername/swarnakar-backend:latest

# Run container
docker run -p 8787:8787 \
  -e NODE_ENV=production \
  -e FIREBASE_PROJECT_ID=swarnakar-79e57 \
  -e JWT_SECRET=your-secret \
  yourusername/swarnakar-backend:latest
```

**Deploy to Cloud Run (Google Cloud):**

```bash
# Set project
gcloud config set project swarnakar-79e57

# Build image
gcloud builds submit --tag gcr.io/swarnakar-79e57/backend

# Deploy
gcloud run deploy swarnakar-backend \
  --image gcr.io/swarnakar-79e57/backend \
  --platform managed \
  --region asia-south1 \
  --allow-unauthenticated \
  --set-env-vars "FIREBASE_PROJECT_ID=swarnakar-79e57"
```

## Mobile Deployment

### Android

**Release APK:**

```bash
# Build signed APK
flutter build apk --release \
  --flavor=production

# Output: build/app/outputs/apk/production/release/app-release.apk
```

**Google Play Store:**

```bash
# Build App Bundle (required for Play Store)
flutter build appbundle --release \
  --flavor=production

# Open Google Play Console
# New app → Upload build/app/outputs/bundle/productionRelease/app-production-release.aab
```

**Signing Configuration (android/app/build.gradle.kts):**

```kotlin
signingConfigs {
    create("release") {
        keyAlias = "swarnakar-key"
        keyPassword = "your-key-password"
        storeFile = file("../keystore/swarnakar.jks")
        storePassword = "your-store-password"
    }
}
```

### iOS

**Build for App Store:**

```bash
# Build iOS app
flutter build ios --release

# Open Xcode workspace
open ios/Runner.xcworkspace

# Select Runner → Targets → Runner
# Set deployment target and team
# Product → Archive
# Distribute App

# Or use Command Line
flutter build ios --release
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -derivedDataPath build/ios_build \
  -archivePath build/ios_build/Runner.xcarchive \
  archive

xcodebuild -exportArchive \
  -archivePath build/ios_build/Runner.xcarchive \
  -exportPath build/ios_build/ipa \
  -exportOptionsPlist ios/ExportOptions.plist
```

## Database Migration

### Firestore to PostgreSQL (Future)

If migrating from Firestore to PostgreSQL:

```bash
# Generate Drizzle migration
cd backend
bun run db:generate

# Create migration file
bun run db:migrate

# Backup Firestore data
firebase firestore:export ./backups/firestore-backup-$(date +%s)

# Migrate data
# Run custom migration script:
node scripts/migrate-firestore-to-postgres.js

# Verify data
bun run db:studio
```

## Monitoring & Logging

### Firebase Monitoring

1. **Firestore:**
   - Go to **Firestore** → **Indexes** → Verify production indexes
   - Enable **Firestore Backups**: **Backup & Restore** → **Create Schedule**

2. **Authentication:**
   - Monitor sign-up/sign-in rates
   - Track failed login attempts

3. **Storage:**
   - Monitor storage usage and costs

### Backend Monitoring

**Error Logging:**

```typescript
// Add Sentry for error tracking
import * as Sentry from "@sentry/bun";

Sentry.init({
  dsn: "your-sentry-dsn",
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
});

app.onError((err, c) => {
  Sentry.captureException(err);
  return c.json({ error: err.message }, 500);
});
```

**Performance Monitoring:**

```typescript
// Log API response times
app.use("*", async (c, next) => {
  const start = Date.now();
  await next();
  const duration = Date.now() - start;
  console.log(`${c.req.method} ${c.req.path} ${duration}ms`);
});
```

**Uptime Monitoring:**

Use services like:
- [UptimeRobot](https://uptimerobot.com)
- [Pingdom](https://www.pingdom.com)
- [StatusPage](https://statuspage.io)

Configure to monitor:
- `/health` endpoint
- POST `/api/auth/send-otp` (with invalid data)
- GET `/api/profile` (test authentication)

### Application Monitoring (Flutter)

**Firebase Performance Monitoring:**

```dart
import 'package:firebase_performance/firebase_performance.dart';

final trace = FirebasePerformance.instance.newTrace('custom_trace');
await trace.start();

// Your code here

await trace.stop();
```

## SSL/TLS Configuration

### Let's Encrypt (Free)

```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Get certificate
sudo certbot certonly --standalone -d swarnakar.app -d www.swarnakar.app

# Auto-renew
sudo certbot renew --dry-run
```

### Self-Signed (Development Only)

```bash
# Generate self-signed certificate
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365

# Use in Nginx
ssl_certificate /path/to/cert.pem;
ssl_certificate_key /path/to/key.pem;
```

## Performance Optimization

### Frontend

```bash
# Build with optimization
flutter build web --release \
  --dart-define=FLUTTER_WEB_USE_SKIA=true \
  --dart-define=FLUTTER_WEB_CANVASKIT_URL="canvaskit/"

# Check size
flutter build web --analyze-size --release
```

### Backend

```typescript
// Enable caching
app.use("*", cache({ maxAge: 3600 }));

// Compression
app.use("*", compress());

// Connection pooling for database
const poolSize = process.env.DB_POOL_SIZE || 10;
```

## Backup & Recovery

### Firestore Backup

```bash
# Manual backup
firebase firestore:export gs://swarnakar-backup/$(date +%Y-%m-%d)

# Automatic backup (Cloud Console)
# Firestore → Backups → Create Schedule
# - Retention: 30 days
- Frequency: Daily
```

### Database Backup

```bash
# PostgreSQL backup
pg_dump -h db.example.com \
  -U postgres \
  -d swarnakar_prod \
  > swarnakar-backup-$(date +%Y-%m-%d).sql

# Upload to storage
gsutil cp swarnakar-backup-*.sql gs://swarnakar-backups/
```

## Disaster Recovery Plan

### Recovery Time Objectives (RTO)

| Component | RTO | Strategy |
|-----------|-----|----------|
| Frontend | 1 hour | Re-deploy from CI/CD |
| Backend | 30 minutes | Switch to standby instance |
| Database | 4 hours | Restore from backup |
| Authentication | 15 minutes | Firebase fail-over |

### Recovery Steps

1. **Identify Issue**: Check monitoring dashboards
2. **Notify Team**: Escalate to team leads
3. **Engage Backup**: Activate standby systems
4. **Restore Data**: Use latest clean backup
5. **Verify**: Run smoke tests
6. **Communicate**: Update status page

## Troubleshooting

### 502 Bad Gateway

**Cause:** Backend unreachable

**Solution:**
```bash
# Check backend status
curl https://api.swarnakar.app/health

# Check logs
railway logs # for Railway
firebase functions:log # for Cloud Functions

# Restart
railway up
```

### CORS Errors

**Cause:** Frontend and backend on different domains

**Solution:** Update backend CORS config:
```typescript
app.use("*", cors({
  origin: "https://swarnakar.app",
  credentials: true
}))
```

### Firestore "Quota Exceeded"

**Cause:** Too many reads/writes

**Solution:**
- Enable Firestore caching
- Implement request batching
- Use Cloud Tasks for async work
- Upgrade Firestore billing tier

### High Latency

**Cause:** Database/API slowness

**Solution:**
- Add database indexes
- Implement caching
- Use CDN for static assets
- Profile slow queries

---

**For questions, contact:** sarkarkabbo72@gmail.com
