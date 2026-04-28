/// Represents a user in the Sabji mart application.
class UserModel {
  final String userId;
  final String customerName;
  final String? email;
  final String? phone;
  final String sessionToken;
  final String? birthday;
  final String? bio;
  final String? avatar;
  final String? dietaryPreference;

  UserModel({
    required this.userId,
    required this.customerName,
    this.email,
    this.phone,
    required this.sessionToken,
    this.birthday,
    this.bio,
    this.avatar,
    this.dietaryPreference,
  });

  /// Creates a UserModel from JSON response (API). Tolerates several payload
  /// shapes: flat top-level fields, `{data: {...}}` wrapping, `{data: {user, token}}`
  /// nesting, and multiple common token field names.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final userMap = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : data;

    String? pickToken(Map<String, dynamic> m) {
      for (final key in const [
        'sessionToken',
        'token',
        'accessToken',
        'access_token',
        'authToken',
        'auth_token',
        'jwt',
      ]) {
        final v = m[key];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return null;
    }

    final token = pickToken(json) ?? pickToken(data) ?? pickToken(userMap) ?? '';

    return UserModel(
      userId: (userMap['userId'] ?? userMap['_id'] ?? '').toString(),
      customerName:
          (userMap['customerName'] ?? userMap['name'] ?? '').toString(),
      email: userMap['email'] as String?,
      phone: userMap['phone']?.toString(),
      sessionToken: token,
      birthday: userMap['birthday'] as String?,
      bio: userMap['bio'] as String?,
      avatar: userMap['avatar'] as String?,
      dietaryPreference: userMap['dietaryPreference'] as String?,
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
      'bio': bio,
      'avatar': avatar,
      'dietaryPreference': dietaryPreference,
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
      bio: json['bio'],
      avatar: json['avatar'],
      dietaryPreference: json['dietaryPreference'],
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
    String? bio,
    String? avatar,
    String? dietaryPreference,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      sessionToken: sessionToken ?? this.sessionToken,
      birthday: birthday ?? this.birthday,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
    );
  }
}
