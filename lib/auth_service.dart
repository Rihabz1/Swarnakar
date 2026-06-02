import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Requests a password reset OTP for the given phone number.
  Future<String> requestPasswordResetOtp(String phone) async {
    if (phone.trim().isEmpty) {
      throw Exception('ফোন নম্বর দিন। (Enter phone number)');
    }

    // Check if a user with this phone number actually exists
    final snapshot = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone.trim())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('এই নম্বরে অ্যাকাউন্ট নেই। (No account found)');
    }

    final doc = snapshot.docs.first;

    // Using a demo OTP for now. Later this will be replaced with a 3rd party SMS API.
    const mockOtp = '123456';

    await doc.reference.update({
      'resetOtp': mockOtp,
      'otpCreatedAt': FieldValue.serverTimestamp(),
    });

    return mockOtp;
  }

  /// Resets the password using the provided OTP and the new password hash.
  Future<void> resetPasswordWithPhone(
      String phone, String otp, String passwordHash) async {
    phone = phone.trim();
    otp = otp.trim().replaceAll(RegExp(r'\s+'), '');
    passwordHash = passwordHash.trim();

    if (phone.isEmpty) {
      throw Exception('ফোন নম্বর দিন। (Enter phone number)');
    }
    if (otp.isEmpty || otp.length != 6) {
      throw Exception('সঠিক OTP দিন। (Enter valid 6-digit OTP)');
    }
    if (passwordHash.isEmpty) {
      throw Exception('পাসওয়ার্ড হ্যাশ প্রদান করা হয়নি। (Password required)');
    }

    // Find the user document
    final snapshot = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('এই নম্বরে অ্যাকাউন্ট নেই। (No account found)');
    }

    final doc = snapshot.docs.first;
    final userData = doc.data();

    // Verify OTP
    final storedOtp = userData['resetOtp'];
    if (storedOtp == null || storedOtp.toString() != otp) {
      throw Exception('ভুল OTP প্রদান করা হয়েছে। (Invalid OTP)');
    }

    // Update the passwordHash and clear the OTP fields
    await doc.reference.update({
      'passwordHash': passwordHash,
      'passwordUpdatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'resetOtp': FieldValue.delete(),
      'otpCreatedAt': FieldValue.delete(),
    });
  }
}