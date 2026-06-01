import { Context } from 'hono';
import { AuthService } from '../services/auth.service';
import RecaptchaService from '../services/recaptcha.service';
import type {
  LoginVerifyBody,
  OtpSendBody,
  OtpVerifyBody,
  ResetPasswordBody,
  ResetVerifyBody,
  PhoneSendOtpBody,
  PhoneVerifyOtpBody,
  PhoneSignupBody,
  PhoneSigninBody,
  PhoneCheckBody,
  PhoneLinkBody,
} from '../types';

const authService = new AuthService();

const badRequest = (c: Context, message: string) => {
  return c.json({ success: false, message, error: message }, 400);
};

const notFound = (c: Context, message: string) => {
  return c.json({ success: false, message, error: message }, 404);
};

export class AuthController {
  
  // ============ EXISTING EMAIL AUTH METHODS ============
  
  async sendOtp(c: Context) {
    try {
      const body = (await c.req.json()) as Partial<OtpSendBody>;
      if (!body?.email || !body?.purpose) {
        return badRequest(c, 'Email and purpose are required.');
      }

      const data = await authService.requestOtp({
        email: body.email,
        purpose: body.purpose,
      });

      return c.json({
        success: true,
        message: 'OTP sent successfully.',
        data,
      });
    } catch (error) {
      return badRequest(c, error instanceof Error ? error.message : 'Failed to send OTP.');
    }
  }

  async resendOtp(c: Context) {
    try {
      const body = (await c.req.json()) as Partial<OtpSendBody>;
      if (!body?.email || !body?.purpose) {
        return badRequest(c, 'Email and purpose are required.');
      }

      const data = await authService.resendOtp({
        email: body.email,
        purpose: body.purpose,
      });

      return c.json({
        success: true,
        message: 'OTP resent successfully.',
        data,
      });
    } catch (error) {
      return badRequest(c, error instanceof Error ? error.message : 'Failed to resend OTP.');
    }
  }

  async verifyOtp(c: Context) {
    try {
      const body = (await c.req.json()) as Partial<OtpVerifyBody>;
      if (!body?.email || !body?.code || !body?.purpose) {
        return badRequest(c, 'Email, code, and purpose are required.');
      }

      authService.verifyOtpOnly({
        email: body.email,
        code: body.code,
        purpose: body.purpose,
      });

      return c.json({
        success: true,
        message: 'OTP verified successfully.',
      });
    } catch (error) {
      return badRequest(c, error instanceof Error ? error.message : 'Failed to verify OTP.');
    }
  }

  async verifyResetOtp(c: Context) {
    try {
      const body = (await c.req.json()) as Partial<ResetVerifyBody>;
      if (!body?.email || !body?.otp) {
        return badRequest(c, 'Email and otp are required.');
      }

      const data = await authService.verifyResetWithOtp({
        email: body.email,
        otp: body.otp,
      });

      return c.json({
        success: true,
        message: 'Reset OTP verified successfully.',
        data,
      });
    } catch (error) {
      return badRequest(c, error instanceof Error ? error.message : 'Failed to verify reset OTP.');
    }
  }

  async verifyLogin(c: Context) {
    try {
      const body = (await c.req.json()) as Partial<LoginVerifyBody>;
      if (!body?.email || !body?.otp) {
        return badRequest(c, 'Email and otp are required.');
      }

      const data = authService.verifyLoginWithOtp({
        email: body.email,
        otp: body.otp,
      });

      return c.json({
        success: true,
        message: 'Login verified successfully.',
        data,
      });
    } catch (error) {
      return badRequest(c, error instanceof Error ? error.message : 'Failed to verify login OTP.');
    }
  }

  async resetPassword(c: Context) {
    try {
      const body = (await c.req.json()) as Partial<ResetPasswordBody>;
      if (!body?.resetToken || !body?.newPassword) {
        return badRequest(c, 'Reset token and new password are required.');
      }

      const data = await authService.resetPasswordWithToken({
        resetToken: body.resetToken,
        newPassword: body.newPassword,
      });

      return c.json({
        success: true,
        message: 'Password reset successfully.',
        data,
      });
    } catch (error) {
      return badRequest(c, error instanceof Error ? error.message : 'Failed to reset password.');
    }
  }

  // ============ NEW PHONE AUTH METHODS ============

  /**
   * Check if phone number exists
   * POST /auth/phone/check
   */
  async checkPhoneNumber(c: Context) {
    try {
      const body = (await c.req.json()) as Partial<PhoneCheckBody>;
      
      if (!body?.phoneNumber) {
        return badRequest(c, 'Phone number is required.');
      }

      const exists = await authService.isPhoneNumberExists(body.phoneNumber);
      const formattedNumber = authService.formatPhoneNumber(body.phoneNumber);

      return c.json({
        success: true,
        data: {
          exists,
          phoneNumber: formattedNumber,
          canSignin: exists,
          canSignup: !exists,
        },
      });
    } catch (error) {
      console.error('Check phone error:', error);
      return badRequest(c, error instanceof Error ? error.message : 'Failed to check phone number.');
    }
  }

  /**
   * Send OTP to phone number (after reCAPTCHA verification)
   * POST /auth/phone/send-otp
   */
  async sendPhoneOtp(c: Context) {
    try {
      const body = (await c.req.json()) as Partial<PhoneSendOtpBody>;

      if (!body?.phoneNumber) {
        return badRequest(c, 'Phone number is required.');
      }

      if (!body?.recaptchaToken) {
        return badRequest(c, 'reCAPTCHA token is required.');
      }

      // Verify reCAPTCHA
      const recaptchaResult = await RecaptchaService.verify(body.recaptchaToken, 'phone_otp');
      if (!recaptchaResult.success) {
        return badRequest(c, recaptchaResult.message || 'Security verification failed.');
      }

      // Send OTP
      const result = await authService.sendPhoneOtp(body.phoneNumber);

      return c.json({
        success: true,
        message: 'OTP sent successfully.',
        data: {
          maskedPhone: result.maskedPhone,
          expiresInSeconds: result.expiresInSeconds,
          ...(result.debugOtp && { debugOtp: result.debugOtp }),
        },
      });
    } catch (error) {
      console.error('Send phone OTP error:', error);
      return badRequest(c, error instanceof Error ? error.message : 'Failed to send OTP.');
    }
  }

  /**
   * Verify phone OTP
   * POST /auth/phone/verify-otp
   */
  async verifyPhoneOtp(c: Context) {
    try {
      const body = (await c.req.json()) as Partial<PhoneVerifyOtpBody>;

      if (!body?.phoneNumber || !body?.code) {
        return badRequest(c, 'Phone number and OTP code are required.');
      }

      const isValid = authService.verifyPhoneOtp(body.phoneNumber, body.code);

      return c.json({
        success: true,
        message: 'OTP verified successfully.',
        data: {
          phoneNumber: authService.formatPhoneNumber(body.phoneNumber),
        },
      });
    } catch (error) {
      console.error('Verify phone OTP error:', error);
      return badRequest(c, error instanceof Error ? error.message : 'Failed to verify OTP.');
    }
  }

  /**
   * Complete phone signup (after OTP verification)
   * POST /auth/phone/signup
   */
  async phoneSignup(c: Context) {
    try {
      const body = (await c.req.json()) as Partial<PhoneSignupBody>;

      if (!body?.phoneNumber || !body?.otpCode) {
        return badRequest(c, 'Phone number and OTP code are required.');
      }

      // Verify OTP first
      const isValid = authService.verifyPhoneOtp(body.phoneNumber, body.otpCode);
      if (!isValid) {
        return badRequest(c, 'Invalid or expired OTP. Please request a new code.');
      }

      const formattedNumber = authService.formatPhoneNumber(body.phoneNumber);

      // Check if user already exists
      let userRecord = await authService.getUserByPhoneNumber(formattedNumber);

      if (!userRecord) {
        // Create new user
        userRecord = await authService.createPhoneUser(formattedNumber, body.name);
      }

      // Get Firestore profile
      const profile = await authService.getUserProfile(userRecord.uid);

      // Generate custom token for client
      const customToken = await authService.generateCustomToken(userRecord.uid);

      return c.json({
        success: true,
        message: 'Phone signup completed successfully.',
        data: {
          uid: userRecord.uid,
          customToken,
          profile,
        },
      });
    } catch (error) {
      console.error('Phone signup error:', error);
      return badRequest(c, error instanceof Error ? error.message : 'Failed to complete signup.');
    }
  }

  /**
   * Complete phone signin (after OTP verification)
   * POST /auth/phone/signin
   */
  async phoneSignin(c: Context) {
    try {
      const body = (await c.req.json()) as Partial<PhoneSigninBody>;

      if (!body?.phoneNumber || !body?.otpCode) {
        return badRequest(c, 'Phone number and OTP code are required.');
      }

      // Verify OTP
      const isValid = authService.verifyPhoneOtp(body.phoneNumber, body.otpCode);
      if (!isValid) {
        return badRequest(c, 'Invalid or expired OTP. Please request a new code.');
      }

      const formattedNumber = authService.formatPhoneNumber(body.phoneNumber);

      // Get user
      const userRecord = await authService.getUserByPhoneNumber(formattedNumber);
      if (!userRecord) {
        return notFound(c, 'No account found with this phone number.');
      }

      // Get Firestore profile
      const profile = await authService.getUserProfile(userRecord.uid);

      // Generate custom token
      const customToken = await authService.generateCustomToken(userRecord.uid);

      return c.json({
        success: true,
        message: 'Phone signin completed successfully.',
        data: {
          uid: userRecord.uid,
          customToken,
          profile,
        },
      });
    } catch (error) {
      console.error('Phone signin error:', error);
      return badRequest(c, error instanceof Error ? error.message : 'Failed to complete signin.');
    }
  }

  /**
   * Link phone number to existing email account (requires authentication)
   * POST /auth/phone/link
   */
  async linkPhoneToEmail(c: Context) {
    try {
      const user = c.get('user'); // From auth middleware
      const body = (await c.req.json()) as Partial<PhoneLinkBody>;

      if (!body?.phoneNumber || !body?.otpCode) {
        return badRequest(c, 'Phone number and OTP code are required.');
      }

      // Verify OTP
      const isValid = authService.verifyPhoneOtp(body.phoneNumber, body.otpCode);
      if (!isValid) {
        return badRequest(c, 'Invalid or expired OTP. Please request a new code.');
      }

      // Link phone to user
      await authService.linkPhoneToUser(user.uid, body.phoneNumber);

      return c.json({
        success: true,
        message: 'Phone number linked successfully.',
        data: {
          phoneNumber: authService.formatPhoneNumber(body.phoneNumber),
        },
      });
    } catch (error) {
      console.error('Link phone error:', error);
      return badRequest(c, error instanceof Error ? error.message : 'Failed to link phone number.');
    }
  }

  /**
   * Unlink phone number from account (requires authentication)
   * POST /auth/phone/unlink
   */
  async unlinkPhone(c: Context) {
    try {
      const user = c.get('user'); // From auth middleware

      await authService.unlinkPhoneFromUser(user.uid);

      return c.json({
        success: true,
        message: 'Phone number unlinked successfully.',
      });
    } catch (error) {
      console.error('Unlink phone error:', error);
      return badRequest(c, error instanceof Error ? error.message : 'Failed to unlink phone number.');
    }
  }
}