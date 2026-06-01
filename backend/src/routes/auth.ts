import { Hono } from 'hono';
import { AuthController } from '../controllers/auth.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const authController = new AuthController();

export const authRoutes = new Hono();

// ============ CANONICAL ENDPOINTS (Email Auth) ============
authRoutes.post('/send-otp', (c) => authController.sendOtp(c));
authRoutes.post('/resend-otp', (c) => authController.resendOtp(c));
authRoutes.post('/verify-login', (c) => authController.verifyLogin(c));
authRoutes.post('/verify-reset', (c) => authController.verifyResetOtp(c));
authRoutes.post('/reset-password', (c) => authController.resetPassword(c));

// ============ COMPATIBILITY ENDPOINTS FOR FLUTTER CLIENT (Email Auth) ============
authRoutes.post('/otp/send', (c) => authController.sendOtp(c));
authRoutes.post('/otp/resend', (c) => authController.resendOtp(c));
authRoutes.post('/otp/verify', (c) => authController.verifyOtp(c));
authRoutes.post('/otp/verify-reset', (c) => authController.verifyResetOtp(c));
authRoutes.post('/password/reset', (c) => authController.resetPassword(c));

// ============ PHONE AUTH ENDPOINTS (Public - No Auth Required) ============
// Check if phone number exists (determine signin vs signup)
authRoutes.post('/phone/check', (c) => authController.checkPhoneNumber(c));

// Send OTP to phone (requires reCAPTCHA token)
authRoutes.post('/phone/send-otp', (c) => authController.sendPhoneOtp(c));

// Verify OTP code
authRoutes.post('/phone/verify-otp', (c) => authController.verifyPhoneOtp(c));

// Complete signup after OTP verification
authRoutes.post('/phone/signup', (c) => authController.phoneSignup(c));

// Complete signin after OTP verification
authRoutes.post('/phone/signin', (c) => authController.phoneSignin(c));

// ============ PHONE AUTH ENDPOINTS (Protected - Auth Required) ============
// Link phone number to existing email account
authRoutes.post('/phone/link', authMiddleware, (c) => authController.linkPhoneToEmail(c));

// Unlink phone number from account
authRoutes.post('/phone/unlink', authMiddleware, (c) => authController.unlinkPhone(c));