class UserProfile {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String phone;
  final String status;
  final List<String> roles;

  UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.status,
    required this.roles,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}
