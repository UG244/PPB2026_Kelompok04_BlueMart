import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import '../utils/crypto_utils.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'username';
  static const String _keyRole = 'role';
  static const String _keyLoginTime = 'login_time';
  static const String _keyRegisteredUsers = 'registered_users';
  static const String _keyAdminSeed = 'admin_seeded';
  static const String _defaultAdminPass = 'admin123';

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (e, st) {
      debugPrint('AuthService.isLoggedIn error: $e\n$st');
      return false;
    }
  }

  Future<AppUser?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      if (!isLoggedIn) return null;
      final username = prefs.getString(_keyUsername);
      final role = prefs.getString(_keyRole);
      if (username == null || role == null) return null;
      return AppUser(username: username, role: role);
    } catch (e, st) {
      debugPrint('AuthService.getCurrentUser error: $e\n$st');
      return null;
    }
  }

  Future<Map<String, Map<String, String>>> _getRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyRegisteredUsers);
    if (json == null) return {};
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return decoded.map(
      (k, v) => MapEntry(k, Map<String, String>.from(v as Map)),
    );
  }

  Future<void> _saveRegisteredUsers(
    Map<String, Map<String, String>> users,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRegisteredUsers, jsonEncode(users));
  }

  /// Seed default admin account on first run (hashed).
  Future<void> _seedAdminIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyAdminSeed) == true) return;
    final users = await _getRegisteredUsers();
    if (!users.containsKey('admin')) {
      users['admin'] = {
        'password': CryptoUtils.hashPassword(_defaultAdminPass),
        'role': 'admin',
      };
      await _saveRegisteredUsers(users);
    }
    await prefs.setBool(_keyAdminSeed, true);
  }

  /// Login: returns null on success, or error message string.
  Future<String?> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return 'Username dan password tidak boleh kosong';
    }
    try {
      await _seedAdminIfNeeded();
      final lower = username.toLowerCase();
      final registeredUsers = await _getRegisteredUsers();
      final userData = registeredUsers[lower];
      if (userData == null) return 'Username tidak ditemukan';
      final storedPassword = userData['password'] ?? '';
      if (storedPassword.isEmpty) return 'Password salah';

      // Coba verifikasi sebagai hash dulu
      final isHashed = storedPassword.contains(':');
      if (isHashed) {
        if (!CryptoUtils.verifyPassword(password, storedPassword)) {
          return 'Password salah';
        }
      } else {
        // Fallback: plaintext (data lama sebelum upgrade ke hash)
        if (storedPassword != password) {
          return 'Password salah';
        }
        // Auto-upgrade plaintext ke hash
        registeredUsers[lower]!['password'] = CryptoUtils.hashPassword(
          password,
        );
        await _saveRegisteredUsers(registeredUsers);
      }
      return await _saveSession(username, userData['role'] ?? 'user');
    } catch (e, st) {
      debugPrint('AuthService.login error: $e\n$st');
      return 'Terjadi kesalahan sistem. Silakan coba lagi.';
    }
  }

  /// Register a new user account. Returns null on success, error message on fail.
  Future<String?> register(String username, String password) async {
    if (username.trim().isEmpty) return 'Username tidak boleh kosong';
    if (password.length < 4) return 'Password minimal 4 karakter';
    try {
      final lower = username.trim().toLowerCase();
      final registeredUsers = await _getRegisteredUsers();
      if (registeredUsers.containsKey(lower)) return 'Username sudah terdaftar';
      registeredUsers[lower] = {
        'password': CryptoUtils.hashPassword(password),
        'role': 'user',
      };
      await _saveRegisteredUsers(registeredUsers);
      await _saveSession(username.trim(), 'user');
      return null;
    } catch (e, st) {
      debugPrint('AuthService.register error: $e\n$st');
      return 'Gagal mendaftar. Silakan coba lagi.';
    }
  }

  Future<String?> _saveSession(String username, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUsername, username);
      await prefs.setString(_keyRole, role);
      await prefs.setString(_keyLoginTime, DateTime.now().toIso8601String());
      return null;
    } catch (e, st) {
      debugPrint('AuthService._saveSession error: $e\n$st');
      return 'Gagal menyimpan session.';
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUsername);
      await prefs.remove(_keyRole);
      await prefs.remove(_keyLoginTime);
    } catch (e, st) {
      debugPrint('AuthService.logout error: $e\n$st');
    }
  }

  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?.role == 'admin';
  }

  /// Get all registered users (from SharedPreferences).
  Future<List<Map<String, String>>> getAllUsers() async {
    final users = <Map<String, String>>[];
    try {
      await _seedAdminIfNeeded();
      final registered = await _getRegisteredUsers();
      for (final entry in registered.entries) {
        users.add({
          'username': entry.key,
          'role': entry.value['role'] ?? 'user',
        });
      }
    } catch (e, st) {
      debugPrint('AuthService.getAllUsers error: $e\n$st');
    }
    return users;
  }

  /// Change role of a registered user.
  Future<bool> updateUserRole(String username, String newRole) async {
    try {
      final lower = username.toLowerCase();
      if (lower == 'admin') return false;
      final registered = await _getRegisteredUsers();
      if (!registered.containsKey(lower)) return false;
      registered[lower]!['role'] = newRole;
      await _saveRegisteredUsers(registered);
      return true;
    } catch (e, st) {
      debugPrint('AuthService.updateUserRole error: $e\n$st');
      return false;
    }
  }

  /// Admin creates a new user account (without auto login).
  Future<String?> adminCreateUser(
    String username,
    String password,
    String role,
  ) async {
    if (username.trim().isEmpty) return 'Username tidak boleh kosong';
    if (password.length < 4) return 'Password minimal 4 karakter';
    try {
      final lower = username.trim().toLowerCase();
      if (lower == 'admin') return 'Username tidak tersedia';
      final registered = await _getRegisteredUsers();
      if (registered.containsKey(lower)) return 'Username sudah terdaftar';
      registered[lower] = {
        'password': CryptoUtils.hashPassword(password),
        'role': role,
      };
      await _saveRegisteredUsers(registered);
      return null;
    } catch (e, st) {
      debugPrint('AuthService.adminCreateUser error: $e\n$st');
      return 'Gagal menambah user.';
    }
  }

  /// Delete a registered user.
  Future<bool> deleteUser(String username) async {
    try {
      final lower = username.toLowerCase();
      if (lower == 'admin') return false;
      final registered = await _getRegisteredUsers();
      if (!registered.containsKey(lower)) return false;
      registered.remove(lower);
      await _saveRegisteredUsers(registered);
      return true;
    } catch (e, st) {
      debugPrint('AuthService.deleteUser error: $e\n$st');
      return false;
    }
  }
}
