import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

let admin: any;
let db: any;
let isInitialized = false;

async function loadAdmin() {
  if (!admin) {
    const mod = await import('firebase-admin');
    admin = mod.default ?? mod;
  }
  return admin;
}

function loadServiceAccount() {
  const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (!credentialsPath) {
    throw new Error('GOOGLE_APPLICATION_CREDENTIALS is not set');
  }

  const absolutePath = resolve(process.cwd(), credentialsPath);
  return JSON.parse(readFileSync(absolutePath, 'utf8'));
}

export async function initializeFirebase() {
  if (isInitialized && db) {
    return db;
  }

  try {
    const admin = await loadAdmin();

    if (!admin.apps || !admin.apps.length) {
      console.log('Initializing Firebase Admin SDK...');
      const serviceAccount = loadServiceAccount();
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: process.env.FIREBASE_PROJECT_ID || serviceAccount.project_id || 'swarnakar-79e57',
      });
      console.log('✓ Firebase Admin SDK initialized');
    }

    db = admin.firestore();
    isInitialized = true;
    console.log('✓ Firestore initialized');
    return db;
  } catch (error) {
    console.error('Failed to initialize Firebase:', error);
    throw error;
  }
}

export async function getFirestore() {
  if (!db) {
    return await initializeFirebase();
  }
  return db;
}

export async function getAuth() {
  const admin = await loadAdmin();

  if (!admin.apps || !admin.apps.length) {
    await initializeFirebase();
  }

  return admin.auth();
}
