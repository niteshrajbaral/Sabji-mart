/// Represents a user in the Sabji mart application.
class UserModel {
  final String userId;
  final String customerName;
  final String? email;
  final String? phone;
  final String sessionToken;
  final String? birthday;

  UserModel({
    required this.userId,
    required this.customerName,
    this.email,
    this.phone,
    required this.sessionToken,
    this.birthday,
  });

  /// Creates a UserModel from JSON response (API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? '',
      customerName: json['customerName'] ?? '',
      sessionToken: json['sessionToken'] ?? '',
    );
  }

  /// Converts UserModel to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'customerName': customerName,
      'email': email,
      'phone': phone,
      'sessionToken': sessionToken,
      'birthday': birthday,
    };
  }

  /// Creates a UserModel from stored JSON (shared_preferences)
  factory UserModel.fromStorage(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? '',
      customerName: json['customerName'] ?? '',
      email: json['email'],
      phone: json['phone'],
      sessionToken: json['sessionToken'] ?? '',
      birthday: json['birthday'],
    );
  }

  /// Returns the display name (customer name or email/phone)
  String get displayName => customerName.isNotEmpty ? customerName : (email ?? phone ?? 'User');

  /// Returns initials for avatar
  String get initials {
    if (customerName.isEmpty) return 'U';
    final names = customerName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return customerName.substring(0, 1).toUpperCase();
  }

  /// Creates a copy of this user with updated fields
  UserModel copyWith({
    String? userId,
    String? customerName,
    String? email,
    String? phone,
    String? sessionToken,
    String? birthday,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      sessionToken: sessionToken ?? this.sessionToken,
      birthday: birthday ?? this.birthday,
    );
  }
}
