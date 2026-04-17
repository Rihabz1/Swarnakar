import { Hono } from 'hono';
import { AuthController } from '../controllers/auth.controller';

const authController = new AuthController();

export const authRoutes = new Hono();

// Canonical endpoints
authRoutes.post('/send-otp', (c) => authController.sendOtp(c));
authRoutes.post('/resend-otp', (c) => authController.resendOtp(c));
authRoutes.post('/verify-login', (c) => authController.verifyLogin(c));
authRoutes.post('/verify-reset', (c) => authController.verifyResetOtp(c));
authRoutes.post('/reset-password', (c) => authController.resetPassword(c));

// Compatibility endpoints for Flutter client
authRoutes.post('/otp/send', (c) => authController.sendOtp(c));
authRoutes.post('/otp/resend', (c) => authController.resendOtp(c));
authRoutes.post('/otp/verify', (c) => authController.verifyOtp(c));
authRoutes.post('/otp/verify-reset', (c) => authController.verifyResetOtp(c));
authRoutes.post('/password/reset', (c) => authController.resetPassword(c));
