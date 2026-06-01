class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phoneNumber;  // ADDED: Optional phone number
  final bool isSubscribed;
  final DateTime? subscriptionExpiry;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber,  // ADDED: Make optional
    required this.isSubscribed,
    this.subscriptionExpiry,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,  // ADDED
    bool? isSubscribed,
    DateTime? subscriptionExpiry,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,  // ADDED
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
    );
  }

  String getInitials() {
    final names = name.split(' ');
    if (names.isNotEmpty && names[0].isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }

  // Helper method to get display name (prefers name, falls back to phone or email)
  String getDisplayName() {
    if (name.isNotEmpty && name != '') {
      return name;
    }
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      return phoneNumber!;
    }
    return email.split('@')[0];
  }

  // Helper method to check if phone is linked
  bool get hasPhoneNumber => phoneNumber != null && phoneNumber!.isNotEmpty;

  // Helper method to get masked phone number for privacy
  String? getMaskedPhoneNumber() {
    if (phoneNumber == null || phoneNumber!.length < 4) return phoneNumber;
    final length = phoneNumber!.length;
    final last4 = phoneNumber!.substring(length - 4);
    return '****$last4';
  }
}