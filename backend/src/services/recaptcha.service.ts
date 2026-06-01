import { RecaptchaEnterpriseServiceClient } from '@google-cloud/recaptcha-enterprise';

class RecaptchaService {
  private client: RecaptchaEnterpriseServiceClient;
  private projectId: string;
  private siteKey: string;

  constructor() {
    this.client = new RecaptchaEnterpriseServiceClient();
    this.projectId = process.env.GOOGLE_RECAPTCHA_PROJECT_ID || 'swarnakar-79e57';
    this.siteKey = process.env.GOOGLE_RECAPTCHA_SITEKEY || '';
  }

  async verify(token: string, action: string = 'phone_verification'): Promise<{
    success: boolean;
    score: number;
    message?: string;
  }> {
    try {
      if (!token) {
        return { success: false, score: 0, message: 'reCAPTCHA token missing' };
      }

      if (!this.siteKey && process.env.NODE_ENV !== 'production') {
        return { success: true, score: 0.9, message: 'Development mode - bypassed' };
      }

      const projectPath = this.client.projectPath(this.projectId);
      const request = {
        parent: projectPath,
        assessment: {
          event: { token, siteKey: this.siteKey, expectedAction: action },
        },
      };

      const [response] = await this.client.createAssessment(request);

      if (!response.tokenProperties?.valid) {
        return { success: false, score: 0, message: 'Invalid reCAPTCHA token' };
      }

      const score = response.riskAnalysis?.score || 0;
      return { success: score >= 0.5, score };
    } catch (error) {
      if (process.env.NODE_ENV !== 'production') {
        return { success: true, score: 0.5, message: 'Development mode - bypassed' };
      }
      return { success: false, score: 0, message: 'reCAPTCHA verification failed' };
    }
  }
}

export default new RecaptchaService();