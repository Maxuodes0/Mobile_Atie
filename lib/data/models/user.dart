class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? organizationId;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.organizationId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      organizationId: json['organizationId']?.toString(),
    );
  }
}
