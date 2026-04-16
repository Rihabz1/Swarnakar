import { Context, Next } from 'hono';
import jwt from 'jsonwebtoken';

export async function authMiddleware(c: Context, next: Next) {
  const authHeader = c.req.header('Authorization');

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ success: false, error: 'No token provided' }, 401);
  }

  const token = authHeader.substring(7);

  try {
    // Verify and decode JWT token
    // Note: In production, verify signature with Firebase public keys
    const decoded = jwt.decode(token, { complete: true });
    
    if (!decoded) {
      return c.json({ success: false, error: 'Invalid token' }, 401);
    }

    const payload = decoded.payload as any;
    
    // Firebase tokens use 'sub' for user ID
    const firebaseId = payload.sub || payload.uid || payload.userId;
    
    if (!firebaseId) {
      return c.json({ success: false, error: 'No user ID in token' }, 401);
    }

    c.set('userId', firebaseId);
    c.set('userEmail', payload.email);
    c.set('userName', payload.name ?? null);
    c.set('userPicture', payload.picture ?? null);
    
    await next();
  } catch (error) {
    console.error('Auth error:', error);
    return c.json({ success: false, error: 'Invalid token' }, 401);
  }
}
