export type OtpPurpose = 'login' | 'reset';

export type OtpSendBody = {
	email: string;
	purpose: OtpPurpose;
};

export type OtpVerifyBody = {
	email: string;
	code: string;
	purpose: OtpPurpose;
};

export type LoginVerifyBody = {
	email: string;
	otp: string;
};

export type ResetVerifyBody = {
	email: string;
	otp: string;
};

export type ResetPasswordBody = {
	resetToken: string;
	newPassword: string;
};

export type UserRecord = {
	id: string;
	name: string;
	email: string;
	passwordHash: string;
	isEmailVerified: boolean;
	createdAt: string;
	lastLoginAt: string | null;
};

export type ApiOk<T = unknown> = {
	success: true;
	message?: string;
	data?: T;
};

export type ApiFail = {
	success: false;
	error: string;
};

// ============ PHONE AUTH TYPES ============

/**
 * Request body for checking if phone number exists
 * POST /auth/phone/check
 */
export type PhoneCheckBody = {
	phoneNumber: string;
};

/**
 * Response data for phone check
 */
export type PhoneCheckResponseData = {
	exists: boolean;
	phoneNumber: string;
	canSignin: boolean;
	canSignup: boolean;
};

/**
 * Request body for sending OTP to phone
 * POST /auth/phone/send-otp
 */
export type PhoneSendOtpBody = {
	phoneNumber: string;
	recaptchaToken: string;
};

/**
 * Response data for sending phone OTP
 */
export type PhoneOtpResponseData = {
	maskedPhone: string;
	expiresInSeconds: number;
	debugOtp?: string; // Only in development mode
};

/**
 * Request body for verifying phone OTP
 * POST /auth/phone/verify-otp
 */
export type PhoneVerifyOtpBody = {
	phoneNumber: string;
	code: string;
};

/**
 * Request body for phone signup
 * POST /auth/phone/signup
 */
export type PhoneSignupBody = {
	phoneNumber: string;
	otpCode: string;
	name?: string;
};

/**
 * Request body for phone signin
 * POST /auth/phone/signin
 */
export type PhoneSigninBody = {
	phoneNumber: string;
	otpCode: string;
};

/**
 * Response data for phone signup/signin
 */
export type PhoneAuthResponseData = {
	uid: string;
	customToken: string;
	profile: any;
};

/**
 * Request body for linking phone to email account
 * POST /auth/phone/link
 */
export type PhoneLinkBody = {
	phoneNumber: string;
	otpCode: string;
};

/**
 * Response data for linking/unlinking phone
 */
export type PhoneLinkResponseData = {
	phoneNumber: string;
};