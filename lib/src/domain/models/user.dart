enum UserRole { owner, manager, cashier }

class User {
  const User({
    required this.id,
    required this.name,
    required this.role,
    this.pinHash,
    this.phone,
    this.isActive = true,
    required this.createdAt,
  });

  final String id;
  final String name;
  final UserRole role;
  final String? pinHash;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
      'pin_hash': pinHash,
      'phone': phone,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      role: UserRole.values.byName(map['role'] as String),
      pinHash: map['pin_hash'] as String?,
      phone: map['phone'] as String?,
      isActive: map['is_active'] == null || map['is_active'] == 1 || map['is_active'] == true,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
