import { Hono } from 'hono';
import { AuthController } from '../controllers/auth.controller';

const authController = new AuthController();

export const authRoutes = new Hono();

// Canonical endpoints
authRoutes.post('/send-otp', (c) => authController.sendOtp(c));
authRoutes.post('/resend-otp', (c) => authController.resendOtp(c));
authRoutes.post('/verify-signup', (c) => authController.verifySignup(c));
authRoutes.post('/verify-login', (c) => authController.verifyLogin(c));

// Compatibility endpoints for Flutter client
authRoutes.post('/otp/send', (c) => authController.sendOtp(c));
authRoutes.post('/otp/resend', (c) => authController.resendOtp(c));
authRoutes.post('/otp/verify', (c) => authController.verifyOtp(c));
