import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swarnakar/core/utils/connectivity_helper.dart';
import 'package:swarnakar/shared/models/user_model.dart';
import 'package:swarnakar/features/auth/domain/bd_phone_number.dart';
import 'dart:math';
import 'dart:convert';

class FirebaseAuthService {
  FirebaseAuthService._();

  static final FirebaseAuthService instance = FirebaseAuthService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _sessionPhoneKey = 'session_phone';
  static const String _pendingSignupKey = 'pending_signup';

  _PendingSignup? _pendingSignup;
  String? _sessionPhone;

  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString(_sessionPhoneKey);
    if (phone == null || phone.isEmpty) return false;
    _sessionPhone = phone;
    return true;
  }

  Future<void> clearSession() async {
    _sessionPhone = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionPhoneKey);
  }

  Future<void> stageSignup({
    required String name,
    required String phone,
    required String password,
    bool acceptAnyOtp = true,
  }) async {
    await ConnectivityHelper.ensureConnected();
    _pendingSignup = _PendingSignup(
      name: name,
      phone: phone,
      password: password,
      acceptAnyOtp: acceptAnyOtp,
    );
    await _persistPendingSignup(_pendingSignup!);
  }

  Future<void> clearPendingSignup() async {
    _pendingSignup = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingSignupKey);
  }

  Future<UserModel> completeSignupWithOtp({required String otp}) async {
    await ConnectivityHelper.ensureConnected();
    var pending = _pendingSignup;
    if (pending == null) {
      pending = await _loadPendingSignup();
      _pendingSignup = pending;
    }
    if (pending == null) {
      throw AuthException(
        code: 'missing-signup',
        message: 'সাইন আপ তথ্য পাওয়া যায়নি। আবার চেষ্টা করুন।',
      );
    }

    // Demo OTP will proceed and accept anything
    if (pending.acceptAnyOtp || otp.isNotEmpty) {
      return registerWithPhonePassword(
        name: pending.name,
        phone: pending.phone,
        password: pending.password,
      );
    }

    throw AuthException(
      code: 'invalid-otp',
      message: 'ভুল OTP প্রদান করা হয়েছে। আবার চেষ্টা করুন।',
    );
  }

  Future<UserModel> registerWithPhonePassword({
    required String name,
    required String phone,
    required String password,
  }) async {
    await ConnectivityHelper.ensureConnected();
    final normalizedPhone = normalizeBdPhone(phone);
    if (!isValidBdMobile(normalizedPhone)) {
      throw AuthException(
        code: 'invalid-phone-number',
        message: 'সঠিক মোবাইল নম্বর দিন।',
      );
    }

    final existing = await _findUserDocByPhone(normalizedPhone);
    if (existing != null) {
      throw AuthException(
        code: 'phone-already-in-use',
        message: 'এই মোবাইল নম্বরে একটি অ্যাকাউন্ট আছে। লগ ইন করুন।',
      );
    }

    final passwordHash = _hashPassword(password);
    try {
      final docRef = _firestore.collection('users').doc();
      final now = FieldValue.serverTimestamp();
      final payload = <String, dynamic>{
        'uid': docRef.id,
        'name': name,
        'email': '',
        'phone': normalizedPhone,
        'provider': 'local',
        'isSubscribed': false,
        'plan': '',
        'subExpires': null,
        'lastLoginAt': now,
        'updatedAt': now,
        'createdAt': now,
        'passwordHash': passwordHash,
        'passwordUpdatedAt': now,
      };
      await _runFirestore(() => docRef.set(payload));
      await _persistSessionPhone(normalizedPhone);

      // Clear pending signup only if successful
      await clearPendingSignup();

      return UserModel(
        uid: docRef.id,
        name: name,
        email: '',
        phone: normalizedPhone,
        shopName: '',
        address: '',
        isSubscribed: false,
        plan: '',
        subExpires: null,
      );
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw AuthException(
        code: 'internal-error',
        message: 'অ্যাকাউন্ট তৈরি করা যায়নি: $e',
      );
    }
  }

  Future<UserModel> signInWithPhonePassword({
    required String phone,
    required String password,
  }) async {
    try {
      await ConnectivityHelper.ensureConnected();
      final normalizedPhone = normalizeBdPhone(phone);
      if (!isValidBdMobile(normalizedPhone)) {
        throw AuthException(
          code: 'invalid-phone-number',
          message: 'সঠিক মোবাইল নম্বর দিন।',
        );
      }

      final doc = await _findUserDocByPhone(normalizedPhone);
      if (doc == null) {
        throw AuthException(
          code: 'user-not-found',
          message: 'এই নম্বরে অ্যাকাউন্ট নেই। সাইন আপ করুন।',
        );
      }

      final data = doc.data() ?? <String, dynamic>{};
      final passwordHash = (data['passwordHash'] as String?) ?? '';
      if (passwordHash.isEmpty || !BCrypt.checkpw(password, passwordHash)) {
        throw AuthException(
          code: 'wrong-password',
          message: 'পাসওয়ার্ড সঠিক নয়। আবার চেষ্টা করুন।',
        );
      }

      await _persistSessionPhone(normalizedPhone);
      return _userModelFromDoc(doc);
    } on AuthException catch (e) {
      throw AuthException(
        code: e.code,
        message: _friendlyLoginMessage(e),
      );
    }
  }

  Future<void> updatePasswordHashForPhone({
    required String phone,
    required String newPassword,
  }) async {
    await ConnectivityHelper.ensureConnected();
    final normalizedPhone = normalizeBdPhone(phone);
    if (!isValidBdMobile(normalizedPhone)) {
      throw AuthException(
        code: 'invalid-phone-number',
        message: 'সঠিক মোবাইল নম্বর দিন।',
      );
    }

    final targetDoc = await _findUserDocByPhone(normalizedPhone);

    if (targetDoc == null) {
      throw AuthException(
        code: 'user-not-found',
        message: 'এই নম্বরে অ্যাকাউন্ট নেই। সাইন আপ করুন।',
      );
    }

    final passwordHash = _hashPassword(newPassword);
    await _runFirestore(
      () => targetDoc.reference.set(
        {
          'passwordHash': passwordHash,
          'passwordUpdatedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      ),
    );
  }

  Future<void> changePasswordForCurrentUser({
    required String currentPassword,
    required String newPassword,
    String? phone,
  }) async {
    try {
      await ConnectivityHelper.ensureConnected();
      final lookupPhone = phone ?? _sessionPhone ?? '';
      if (lookupPhone.isEmpty) {
        throw AuthException(
          code: 'not-authenticated',
          message: 'লগইন পাওয়া যায়নি। আবার লগইন করুন।',
        );
      }
      final normalizedPhone = normalizeBdPhone(lookupPhone);
      if (!isValidBdMobile(normalizedPhone)) {
        throw AuthException(
          code: 'invalid-phone-number',
          message: 'সঠিক মোবাইল নম্বর দিন।',
        );
      }
      final targetDoc = await _findUserDocByPhone(normalizedPhone);

      if (targetDoc == null) {
        throw AuthException(
          code: 'user-not-found',
          message: 'এই নম্বরে অ্যাকাউন্ট নেই। সাইন আপ করুন।',
        );
      }

      final data = targetDoc.data() ?? <String, dynamic>{};
      final passwordHash = (data['passwordHash'] as String?) ?? '';
      if (passwordHash.isEmpty ||
          !BCrypt.checkpw(currentPassword, passwordHash)) {
        throw AuthException(
          code: 'wrong-password',
          message: 'বর্তমান পাসওয়ার্ড সঠিক নয়।',
        );
      }

      final updatedHash = _hashPassword(newPassword);
      await _runFirestore(
        () => targetDoc.reference.set(
          {
            'passwordHash': updatedHash,
            'passwordUpdatedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        ),
      );
    } on AuthException catch (e) {
      throw AuthException(
        code: e.code,
        message: _friendlyChangePasswordMessage(e),
      );
    }
  }

  Future<String> requestPasswordResetOtp(String phone) async {
    await ConnectivityHelper.ensureConnected();
    final normalizedPhone = normalizeBdPhone(phone);
    if (!isValidBdMobile(normalizedPhone)) {
      throw AuthException(
        code: 'invalid-phone-number',
        message: 'সঠিক মোবাইল নম্বর দিন।',
      );
    }

    final doc = await _findUserDocByPhone(normalizedPhone);
    if (doc == null) {
      throw AuthException(
        code: 'user-not-found',
        message: 'এই নম্বরে অ্যাকাউন্ট নেই।',
      );
    }

    final mockOtp = _generateOtp();
    final expiresAt = DateTime.now().add(const Duration(minutes: 5));
    await _runFirestore(
      () => doc.reference.update({
        'resetOtp': mockOtp,
        'otpCreatedAt': FieldValue.serverTimestamp(),
        'otpExpiresAt': Timestamp.fromDate(expiresAt),
      }),
    );

    return mockOtp;
  }

  Future<void> resetPasswordWithOtp({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    await ConnectivityHelper.ensureConnected();
    final normalizedPhone = normalizeBdPhone(phone);
    if (!isValidBdMobile(normalizedPhone)) {
      throw AuthException(
        code: 'invalid-phone-number',
        message: 'সঠিক মোবাইল নম্বর দিন।',
      );
    }

    final doc = await _findUserDocByPhone(normalizedPhone);
    if (doc == null) {
      throw AuthException(
        code: 'user-not-found',
        message: 'এই নম্বরে অ্যাকাউন্ট নেই।',
      );
    }

    final userData = doc.data() ?? <String, dynamic>{};
    final storedOtp = (userData['resetOtp'] as String?) ?? '';
    if (storedOtp.isEmpty) {
      throw AuthException(
        code: 'otp-missing',
        message: 'OTP পাওয়া যায়নি। আবার OTP পাঠান।',
      );
    }

    final expiresAt = userData['otpExpiresAt'];
    if (expiresAt is Timestamp && expiresAt.toDate().isBefore(DateTime.now())) {
      await _runFirestore(
        () => doc.reference.update({
          'resetOtp': FieldValue.delete(),
          'otpCreatedAt': FieldValue.delete(),
          'otpExpiresAt': FieldValue.delete(),
        }),
      );
      throw AuthException(
        code: 'otp-expired',
        message: 'OTP এর মেয়াদ শেষ হয়েছে। আবার OTP পাঠান।',
      );
    }

    if (storedOtp != otp.trim()) {
      throw AuthException(
        code: 'invalid-otp',
        message: 'ভুল OTP প্রদান করা হয়েছে।',
      );
    }

    final passwordHash = _hashPassword(newPassword);
    await _runFirestore(
      () => doc.reference.update({
        'passwordHash': passwordHash,
        'passwordUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'resetOtp': FieldValue.delete(),
        'otpCreatedAt': FieldValue.delete(),
        'otpExpiresAt': FieldValue.delete(),
      }),
    );
  }

  Future<UserModel?> getCurrentUserProfile() async {
    await ConnectivityHelper.ensureConnected();
    final phone = _sessionPhone;
    if (phone == null || phone.isEmpty) return null;
    final doc = await _findUserDocByPhone(phone);
    if (doc == null) return null;
    return _userModelFromDoc(doc);
  }

  Future<UserModel> updateUserProfile({
    required String name,
    required String shopName,
    required String address,
  }) async {
    await ConnectivityHelper.ensureConnected();
    final phone = _sessionPhone;
    if (phone == null || phone.isEmpty) {
      throw AuthException(
        code: 'not-authenticated',
        message: 'লগইন পাওয়া যায়নি। আবার লগইন করুন।',
      );
    }
    final doc = await _findUserDocByPhone(phone);
    if (doc == null) {
      throw AuthException(
        code: 'user-not-found',
        message: 'এই নম্বরে অ্যাকাউন্ট নেই। সাইন আপ করুন।',
      );
    }
    final payload = {
      'name': name,
      'shopName': shopName,
      'address': address,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _runFirestore(
        () => doc.reference.set(payload, SetOptions(merge: true)));
    final updatedDoc = await _runFirestore(() => doc.reference.get());
    return _userModelFromDoc(updatedDoc);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _findUserDocByPhone(
    String normalizedPhone,
  ) async {
    await ConnectivityHelper.ensureConnected();
    if (!isValidBdMobile(normalizedPhone)) {
      return null;
    }
    final snapshot = await _runFirestore(
      () => _firestore
          .collection('users')
          .where('phone', isEqualTo: normalizedPhone)
          .limit(1)
          .get(),
    );
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first;
    }
    return null;
  }

  UserModel _userModelFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final subExpires = data['subExpires'];
    return UserModel(
      uid: (data['uid'] as String?) ?? doc.id,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      shopName: (data['shopName'] as String?) ?? '',
      address: (data['address'] as String?) ?? '',
      isSubscribed: (data['isSubscribed'] as bool?) ?? false,
      plan: (data['plan'] as String?) ?? '',
      subExpires: subExpires is Timestamp ? subExpires.toDate() : null,
    );
  }

  Future<void> _persistSessionPhone(String phone) async {
    _sessionPhone = phone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionPhoneKey, phone);
  }

  Future<void> _persistPendingSignup(_PendingSignup pending) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'name': pending.name,
      'phone': pending.phone,
      'password': pending.password,
      'acceptAnyOtp': pending.acceptAnyOtp,
    };
    await prefs.setString(_pendingSignupKey, jsonEncode(payload));
  }

  Future<_PendingSignup?> _loadPendingSignup() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingSignupKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final payload = jsonDecode(raw);
      if (payload is! Map) return null;
      return _PendingSignup(
        name: (payload['name'] as String?) ?? '',
        phone: (payload['phone'] as String?) ?? '',
        password: (payload['password'] as String?) ?? '',
        acceptAnyOtp: (payload['acceptAnyOtp'] as bool?) ?? true,
      );
    } catch (_) {
      return null;
    }
  }

  String _hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  String _generateOtp() {
    final value = Random.secure().nextInt(1000000);
    return value.toString().padLeft(6, '0');
  }

  Future<T> _runFirestore<T>(Future<T> Function() action) async {
    await ConnectivityHelper.ensureConnected();
    try {
      return await action();
    } on FirebaseException catch (e) {
      if (_isNetworkFirebaseError(e)) {
        throw const NetworkException();
      }
      rethrow;
    }
  }

  bool _isNetworkFirebaseError(FirebaseException e) {
    return e.code == 'unavailable' ||
        e.code == 'deadline-exceeded' ||
        e.code == 'network-request-failed';
  }

  String _friendlyLoginMessage(AuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'এই নম্বরের কোনো অ্যাকাউন্ট পাওয়া যায়নি।';
      case 'wrong-password':
        return 'পাসওয়ার্ড সঠিক নয়।';
      case 'invalid-email':
        return 'মোবাইল নম্বর সঠিক নয়।';
      case 'user-disabled':
        return 'এই অ্যাকাউন্ট নিষ্ক্রিয় করা হয়েছে।';
      default:
        return e.message ?? 'লগইন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।';
    }
  }

  String _friendlyChangePasswordMessage(AuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return 'বর্তমান পাসওয়ার্ড সঠিক নয়।';
      case 'weak-password':
        return 'পাসওয়ার্ড আরও শক্তিশালী দিন।';
      case 'requires-recent-login':
        return 'নিরাপত্তার জন্য আবার লগইন করুন।';
      case 'internal':
      case 'internal-error':
      case 'unknown':
        return 'পাসওয়ার্ড আপডেট ব্যর্থ হয়েছে। আবার চেষ্টা করুন।';
      default:
        return e.message ?? 'পাসওয়ার্ড আপডেট ব্যর্থ হয়েছে।';
    }
  }
}

class AuthException implements Exception {
  final String code;
  final String? message;

  AuthException({
    required this.code,
    this.message,
  });
}

class _PendingSignup {
  final String name;
  final String phone;
  final String password;
  final bool acceptAnyOtp;

  const _PendingSignup({
    required this.name,
    required this.phone,
    required this.password,
    required this.acceptAnyOtp,
  });
}
