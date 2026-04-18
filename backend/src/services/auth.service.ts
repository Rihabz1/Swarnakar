import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import jwt, { type SignOptions } from 'jsonwebtoken';
import nodemailer from 'nodemailer';
import type {
  LoginVerifyBody,
  OtpPurpose,
  OtpSendBody,
  OtpVerifyBody,
  ResetPasswordBody,
  ResetVerifyBody,
  UserRecord,
} from '../types';
import { getAuth, getFirestore } from '../config/firebase';
import { generateOtpCode, isValidEmail, maskEmail, normalizeEmail } from '../utils/helpers';

type OtpRecord = {
  email: string;
  purpose: OtpPurpose;
  otpHash: string;
  expiresAt: number;
  attempts: number;
  sentAt: number;
};

type OtpSendResult = {
  cooldownSeconds: number;
  expiresInSeconds: number;
  maskedEmail: string;
  debugOtp?: string;
};

type ResetTokenRecord = {
  email: string;
  expiresAt: number;
  createdAt: number;
};

type ResetVerifyResult = {
  resetToken: string;
  maskedEmail: string;
  expiresInSeconds: number;
};

type ResetPasswordResult = {
  success: true;
  email: string;
};

const OTP_EXPIRY_MINUTES = Number(process.env.OTP_EXPIRY_MINUTES ?? 10);
const OTP_MAX_ATTEMPTS = Number(process.env.OTP_MAX_ATTEMPTS ?? 5);
const OTP_RESEND_COOLDOWN_SECONDS = Number(process.env.OTP_RESEND_COOLDOWN_SECONDS ?? 45);
const OTP_RATE_LIMIT_PER_HOUR = Number(process.env.OTP_RATE_LIMIT_PER_HOUR ?? 10);
const RESET_TOKEN_EXPIRY_MINUTES = Number(process.env.RESET_TOKEN_EXPIRY_MINUTES ?? 15);

const JWT_SECRET = process.env.JWT_SECRET ?? 'dev-jwt-secret-change-me';
const JWT_EXPIRES_IN: SignOptions['expiresIn'] =
  (process.env.JWT_EXPIRES_IN as SignOptions['expiresIn']) ?? '7d';

const smtpHost = process.env.SMTP_HOST;
const smtpPort = Number(process.env.SMTP_PORT ?? 587);
const smtpSecure = String(process.env.SMTP_SECURE ?? 'false') === 'true';
const smtpUser = process.env.SMTP_USER;
const smtpPass = process.env.SMTP_PASS;
const fromEmail = process.env.OTP_FROM_EMAIL ?? smtpUser ?? 'no-reply@swarnakar.app';

const transporter =
  smtpHost && smtpUser && smtpPass
    ? nodemailer.createTransport({
        host: smtpHost,
        port: smtpPort,
        secure: smtpSecure,
        auth: {
          user: smtpUser,
          pass: smtpPass,
        },
      })
    : null;

const otpStore = new Map<string, OtpRecord>();
const requestWindowStore = new Map<string, number[]>();
const userStore = new Map<string, UserRecord>();
const resetTokenStore = new Map<string, ResetTokenRecord>();

const otpKey = (email: string, purpose: OtpPurpose) => `${purpose}:${email}`;

const hashOtp = (email: string, purpose: OtpPurpose, otp: string): string => {
  return crypto
    .createHash('sha256')
    .update(`${email}:${purpose}:${otp}`)
    .digest('hex');
};

const createJwt = (user: UserRecord): string => {
  return jwt.sign(
    {
      sub: user.id,
      email: user.email,
      name: user.name,
      isEmailVerified: user.isEmailVerified,
    },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN },
  );
};

const pickPublicUser = (user: UserRecord) => ({
  id: user.id,
  name: user.name,
  email: user.email,
  isEmailVerified: user.isEmailVerified,
});

const assertRateLimit = (email: string) => {
  const now = Date.now();
  const oneHourAgo = now - 60 * 60 * 1000;
  const previous = requestWindowStore.get(email) ?? [];
  const recent = previous.filter((ts) => ts > oneHourAgo);

  if (recent.length >= OTP_RATE_LIMIT_PER_HOUR) {
    throw new Error('Too many OTP requests. Please try again later.');
  }

  recent.push(now);
  requestWindowStore.set(email, recent);
};

const assertCooldown = (email: string, purpose: OtpPurpose) => {
  const existing = otpStore.get(otpKey(email, purpose));
  if (!existing) {
    return;
  }

  const waitMs = existing.sentAt + OTP_RESEND_COOLDOWN_SECONDS * 1000 - Date.now();
  if (waitMs > 0) {
    const waitSeconds = Math.ceil(waitMs / 1000);
    throw new Error(`Please wait ${waitSeconds}s before requesting a new OTP.`);
  }
};

const ensureSignupAllowed = (email: string) => {
  if (userStore.has(email)) {
    throw new Error('An account with this email already exists. Please log in.');
  }
};

const ensureLoginAllowed = (email: string) => {
  const user = userStore.get(email);
  if (!user) {
    throw new Error('No account found with this email. Sign up first.');
  }
};

const ensureResetAllowed = async (email: string) => {
  const auth = await getAuth();

  try {
    await auth.getUserByEmail(email);
  } catch (error) {
    throw new Error('No account found with this email. Sign up first.');
  }
};

const createResetToken = (email: string): string => {
  const resetToken = crypto.randomUUID();
  const now = Date.now();

  resetTokenStore.set(resetToken, {
    email,
    createdAt: now,
    expiresAt: now + RESET_TOKEN_EXPIRY_MINUTES * 60 * 1000,
  });

  return resetToken;
};

const consumeResetToken = (resetToken: string): ResetTokenRecord => {
  const record = resetTokenStore.get(resetToken);
  if (!record) {
    throw new Error('Reset link expired or invalid. Please request a new OTP.');
  }

  if (Date.now() > record.expiresAt) {
    resetTokenStore.delete(resetToken);
    throw new Error('Reset link expired or invalid. Please request a new OTP.');
  }

  return record;
};

const sendOtpEmail = async (email: string, purpose: OtpPurpose, code: string): Promise<void> => {
  const verb = purpose === 'login' ? 'log in' : 'reset your password';
  const subject = purpose === 'reset' ? 'Swarnakar OTP for password reset' : `Swarnakar OTP for ${verb}`;
  const text = `Your Swarnakar OTP is ${code}. It expires in ${OTP_EXPIRY_MINUTES} minutes.`;
  const html = `
    <div style="font-family: Arial, sans-serif; line-height: 1.5;">
      <h2>Swarnakar Verification</h2>
      <p>Use this 6-digit code to ${verb}:</p>
      <p style="font-size: 28px; font-weight: 700; letter-spacing: 6px;">${code}</p>
      <p>This code expires in ${OTP_EXPIRY_MINUTES} minutes.</p>
      <p>If you did not request this, ignore this message.</p>
    </div>
  `;

  if (!transporter) {
    throw new Error(
      'SMTP is not configured. Set SMTP_HOST, SMTP_USER, SMTP_PASS, and OTP_FROM_EMAIL in backend/.env to send OTP emails.',
    );
  }

  await transporter.sendMail({
    from: fromEmail,
    to: email,
    subject,
    text,
    html,
  });
};

const issueOtp = async ({ email, purpose }: OtpSendBody): Promise<OtpSendResult> => {
  if (!isValidEmail(email)) {
    throw new Error('Invalid email format.');
  }

  const normalizedEmail = normalizeEmail(email);

  if (purpose === 'login') {
    ensureLoginAllowed(normalizedEmail);
  } else {
    await ensureResetAllowed(normalizedEmail);
  }

  assertRateLimit(normalizedEmail);
  assertCooldown(normalizedEmail, purpose);

  const code = generateOtpCode();
  const now = Date.now();

  otpStore.set(otpKey(normalizedEmail, purpose), {
    email: normalizedEmail,
    purpose,
    otpHash: hashOtp(normalizedEmail, purpose, code),
    expiresAt: now + OTP_EXPIRY_MINUTES * 60 * 1000,
    attempts: 0,
    sentAt: now,
  });

  await sendOtpEmail(normalizedEmail, purpose, code);

  return {
    cooldownSeconds: OTP_RESEND_COOLDOWN_SECONDS,
    expiresInSeconds: OTP_EXPIRY_MINUTES * 60,
    maskedEmail: maskEmail(normalizedEmail),
    ...(process.env.NODE_ENV === 'development' ? { debugOtp: code } : {}),
  };
};

const consumeOtp = ({ email, purpose, code }: OtpVerifyBody): void => {
  if (!isValidEmail(email)) {
    throw new Error('Invalid email format.');
  }

  if (!/^\d{6}$/.test(code)) {
    throw new Error('OTP must be 6 digits.');
  }

  const normalizedEmail = normalizeEmail(email);
  const key = otpKey(normalizedEmail, purpose);
  const record = otpStore.get(key);

  if (!record) {
    throw new Error('OTP not found. Please request a new code.');
  }

  if (Date.now() > record.expiresAt) {
    otpStore.delete(key);
    throw new Error('OTP has expired. Please request a new code.');
  }

  if (record.attempts >= OTP_MAX_ATTEMPTS) {
    otpStore.delete(key);
    throw new Error('Too many incorrect attempts. Request a new OTP.');
  }

  const candidate = hashOtp(normalizedEmail, purpose, code);
  if (candidate !== record.otpHash) {
    record.attempts += 1;
    otpStore.set(key, record);
    throw new Error('Invalid OTP.');
  }

  otpStore.delete(key);
};

const loginWithOtp = ({ email, otp }: LoginVerifyBody) => {
  const normalizedEmail = normalizeEmail(email);
  const user = userStore.get(normalizedEmail);

  if (!user) {
    throw new Error('No account found with this email. Sign up first.');
  }

  consumeOtp({ email: normalizedEmail, code: otp, purpose: 'login' });

  user.lastLoginAt = new Date().toISOString();
  userStore.set(normalizedEmail, user);

  return {
    token: createJwt(user),
    user: pickPublicUser(user),
  };
};

const verifyOtpOnly = ({ email, code, purpose }: OtpVerifyBody): void => {
  consumeOtp({ email: normalizeEmail(email), code, purpose });
};

const verifyResetWithOtp = async ({ email, otp }: ResetVerifyBody): Promise<ResetVerifyResult> => {
  const normalizedEmail = normalizeEmail(email);
  await ensureResetAllowed(normalizedEmail);

  consumeOtp({ email: normalizedEmail, code: otp, purpose: 'reset' });

  return {
    resetToken: createResetToken(normalizedEmail),
    maskedEmail: maskEmail(normalizedEmail),
    expiresInSeconds: RESET_TOKEN_EXPIRY_MINUTES * 60,
  };
};

const resetPasswordWithToken = async ({ resetToken, newPassword }: ResetPasswordBody): Promise<ResetPasswordResult> => {
  if (!newPassword || newPassword.trim().length < 8) {
    throw new Error('Password must be at least 8 characters long.');
  }

  const record = consumeResetToken(resetToken);
  const normalizedEmail = normalizeEmail(record.email);

  const auth = await getAuth();
  const userRecord = await auth.getUserByEmail(normalizedEmail);

  await auth.updateUser(userRecord.uid, {
    password: newPassword,
  });

  const db = await getFirestore();
  await db.collection('users').doc(userRecord.uid).set(
    {
      email: normalizedEmail,
      updatedAt: new Date(),
      passwordResetAt: new Date(),
      isEmailVerified: true,
    },
    { merge: true },
  );

  resetTokenStore.delete(resetToken);

  return {
    success: true,
    email: normalizedEmail,
  };
};

export class AuthService {
  requestOtp = issueOtp;
  resendOtp = issueOtp;
  verifyLoginWithOtp = loginWithOtp;
  verifyOtpOnly = verifyOtpOnly;
  verifyResetWithOtp = verifyResetWithOtp;
  resetPasswordWithToken = resetPasswordWithToken;
}
