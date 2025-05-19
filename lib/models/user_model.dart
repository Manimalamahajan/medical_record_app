// lib/models/user_model.dart
class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
    };
  }

  // Create a copy of User with modified fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
