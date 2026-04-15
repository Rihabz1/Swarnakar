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

  String getInitials() {
    final names = name.split(' ');
    if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }
}
