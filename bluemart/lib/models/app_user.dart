class AppUser {
  final String username;
  final String role; // "admin" or "user"

  AppUser({
    required this.username,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'role': role,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        username: json['username'] as String,
        role: json['role'] as String,
      );
}