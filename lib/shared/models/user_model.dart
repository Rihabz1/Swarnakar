class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String shopName;
  final String address;
  final bool isSubscribed;
  final String plan;
  final DateTime? subExpires;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.shopName,
    required this.address,
    required this.isSubscribed,
    required this.plan,
    this.subExpires,
  });

  String getInitials() {
    final cleaned = name.trim();
    if (cleaned.isEmpty) return 'U';
    final parts = cleaned.split(RegExp(r'\s+'));
    final first = parts.first.trim();
    if (first.isEmpty) return 'U';
    return first.substring(0, 1).toUpperCase();
  }
}
