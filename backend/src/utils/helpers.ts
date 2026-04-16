export const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export const normalizeEmail = (email: string): string => email.trim().toLowerCase();

export const isValidEmail = (email: string): boolean => EMAIL_REGEX.test(email);

export const generateOtpCode = (): string => {
	return Math.floor(100000 + Math.random() * 900000).toString();
};

export const maskEmail = (email: string): string => {
	const [name, domain] = email.split('@');
	if (!name || !domain || name.length < 3) {
		return email;
	}
	return `${name[0]}${'*'.repeat(name.length - 2)}${name[name.length - 1]}@${domain}`;
};
