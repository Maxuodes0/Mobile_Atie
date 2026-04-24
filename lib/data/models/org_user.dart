class OrgUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profileImage;

  const OrgUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.profileImage,
  });

  factory OrgUser.fromJson(Map<String, dynamic> json) {
    return OrgUser(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      profileImage: (json['profileImage'] ?? '').toString().trim().isEmpty
          ? null
          : (json['profileImage'] ?? '').toString(),
    );
  }
}

