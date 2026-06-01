import { RecaptchaEnterpriseServiceClient } from '@google-cloud/recaptcha-enterprise';

async function testRecaptcha() {
  try {
    console.log('🔐 Testing reCAPTCHA Enterprise setup...');
    
    // Create client (automatically uses GOOGLE_APPLICATION_CREDENTIALS)
    const client = new RecaptchaEnterpriseServiceClient();
    
    // Get project path
    const projectPath = client.projectPath('swarnakar-79e57');
    
    console.log('✅ reCAPTCHA client created successfully');
    console.log('📁 Project path:', projectPath);
    console.log('🔑 Site key:', process.env.GOOGLE_RECAPTCHA_SITEKEY);
    console.log('📄 Credentials file:', process.env.GOOGLE_APPLICATION_CREDENTIALS);
    
    console.log('\n✅ All configurations loaded successfully!');
    console.log('📝 Note: This only tests client creation, not actual token verification.');
    console.log('To fully test, you need to create an assessment with a real token.');
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

testRecaptcha();
