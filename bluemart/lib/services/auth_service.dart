import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'username';
  static const String _keyRole = 'role';
  static const String _keyLoginTime = 'login_time';

  // Hardcoded credentials for course purposes
  static const Map<String, Map<String, String>> _validUsers = {
    'admin': {'password': 'admin123', 'role': 'admin'},
    'user1': {'password': 'user123', 'role': 'user'},
    'user2': {'password': 'user123', 'role': 'user'},
  };

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;

    final username = prefs.getString(_keyUsername);
    final role = prefs.getString(_keyRole);
    if (username == null || role == null) return null;

    return AppUser(username: username, role: role);
  }

  /// Returns null on success, or an error message string on failure.
  Future<String?> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return 'Username dan password tidak boleh kosong';
    }

    final userData = _validUsers[username];
    if (userData == null) {
      return 'Username tidak ditemukan';
    }

    if (userData['password'] != password) {
      return 'Password salah';
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyRole, userData['role']!);
    await prefs.setString(_keyLoginTime, DateTime.now().toIso8601String());

    return null; // success
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyLoginTime);
  }

  /// Check if the current session has admin role.
  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?.role == 'admin';
  }
}