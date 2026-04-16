# Swarnakar Backend

A Bun/Hono backend for the Swarnakar application with Firestore integration.

## Prerequisites

- Bun (https://bun.sh)
- Node.js 18+ (for firebase-admin)
- Firebase Project (swarnakar-79e57)

## Setup

### 1. Install Dependencies

```bash
cd backend
bun install
```

### 2. Firebase Configuration

#### Get your Firebase Service Account Key:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select the **swarnakar-79e57** project
3. Go to **Project Settings** → **Service Accounts**
4. Click **Generate New Private Key**
5. Save the JSON file as `firebase-service-account.json` in the backend folder

#### Set Environment Variables:

Create a `.env` file in the backend folder:

```bash
FIREBASE_PROJECT_ID=swarnakar-79e57
GOOGLE_APPLICATION_CREDENTIALS=./firebase-service-account.json
PORT=8787
```

Or copy from the example:
```bash
cp .env.example .env
```

### 3. Create Firestore Collection Structure

The backend expects the following Firestore structure:

```
firestore/
├── users/
│   ├── {firebaseId}/
│   │   ├── name: string
│   │   ├── email: string
│   │   ├── phone: string (optional)
│   │   ├── address: string (optional)
│   │   ├── profileImage: string (optional)
│   │   ├── isSubscribed: boolean
│   │   ├── subscriptionExpiry: timestamp (optional)
│   │   ├── totalCalculations: number
│   │   ├── savedReports: number
│   │   ├── favoritePrices: number
│   │   ├── preferences: object
│   │   ├── createdAt: timestamp
│   │   ├── updatedAt: timestamp
```

## Running the Backend

### Development Mode (with auto-reload)

```bash
bun run dev
```

### Production Mode

```bash
bun run start
```

The server will start at `http://localhost:8787`

## API Endpoints

### Profile Routes (require authentication)

All endpoints require a valid Firebase JWT token in the Authorization header:

```
Authorization: Bearer {firebase_id_token}
```

- `GET /api/profile` - Get user profile
- `PUT /api/profile/update` - Update user profile
- `POST /api/profile/change-password` - Change password
- `DELETE /api/profile/delete-account` - Delete user account
- `GET /api/profile/stats` - Get user statistics

### Health Check

- `GET /health` - Server health check

## Architecture

- **Framework**: Hono (lightweight web framework)
- **Database**: Firebase Firestore
- **Authentication**: Firebase JWT tokens
- **Runtime**: Bun

## Project Structure

```
src/
├── controllers/     # Request handlers
├── services/        # Business logic
├── routes/          # Route definitions
├── middleware/      # Authentication & utilities
├── db/              # Database configuration
└── types/           # TypeScript types
```

## Notes

- The backend uses Firebase Authentication for user management
- Firestore is used as the primary database
- All timestamps are stored as ISO 8601 strings
- CORS is enabled for localhost and development origins
