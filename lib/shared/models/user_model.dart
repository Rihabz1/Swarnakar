class UserModel {
  final String uid;
  final String name;
  final String email;
  final bool isSubscribed;
  final DateTime? subscriptionExpiry;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.isSubscribed,
    this.subscriptionExpiry,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    bool? isSubscribed,
    DateTime? subscriptionExpiry,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
    );
  }

  String getInitials() {
    final names = name.split(' ');
    if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }
}
