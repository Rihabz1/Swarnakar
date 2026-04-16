import { Context, Next } from 'hono';

export async function authMiddleware(c: Context, next: Next) {
  const authHeader = c.req.header('Authorization');

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ success: false, error: 'No token provided' }, 401);
  }

  const token = authHeader.substring(7);

  try {
    // Mock JWT verification for now - in production use jsonwebtoken
    const decoded = JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString());
    c.set('userId', decoded.userId || decoded.sub);
    c.set('userEmail', decoded.email);
    await next();
  } catch (error) {
    return c.json({ success: false, error: 'Invalid token' }, 401);
  }
}
