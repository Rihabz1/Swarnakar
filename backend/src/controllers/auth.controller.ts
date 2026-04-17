import { Context } from 'hono';
import { AuthService } from '../services/auth.service';
import type {
  LoginVerifyBody,
  OtpSendBody,
  OtpVerifyBody,
  ResetPasswordBody,
  ResetVerifyBody,
} from '../types';

const authService = new AuthService();

const badRequest = (c: Context, message: string) => {
  return c.json({ success: false, message, error: message }, 400);
};

export class AuthController {
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
}
