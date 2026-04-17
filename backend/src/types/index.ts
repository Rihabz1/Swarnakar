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
