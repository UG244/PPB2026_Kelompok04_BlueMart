import 'dart:convert';
import 'dart:math';

/// Simple password hashing utility for local storage.
/// In production, use a proper crypto library like `crypto` package with bcrypt.
class CryptoUtils {
  /// Hash password dengan salt sederhana.
  /// Untuk production, gunakan package `crypto` dengan PBKDF2 atau bcrypt.
  static String hashPassword(String password) {
    final salt = _generateSalt();
    final combined = '$salt:$password';
    final bytes = utf8.encode(combined);
    int hash = 0;
    for (var i = 0; i < bytes.length; i++) {
      hash = ((hash << 5) - hash + bytes[i]) & 0x7FFFFFFF;
      hash ^= (bytes[i] * salt.hashCode) & 0x7FFFFFFF;
    }
    final hashHex = hash.toRadixString(16).padLeft(8, '0');
    return '$salt:$hashHex';
  }

  /// Verify a password against a stored hash.
  static bool verifyPassword(String password, String storedHash) {
    final parts = storedHash.split(':');
    if (parts.length != 2) return false;
    final salt = parts[0];
    final combined = '$salt:$password';
    final bytes = utf8.encode(combined);
    int hash = 0;
    for (var i = 0; i < bytes.length; i++) {
      hash = ((hash << 5) - hash + bytes[i]) & 0x7FFFFFFF;
      hash ^= (bytes[i] * salt.hashCode) & 0x7FFFFFFF;
    }
    final hashHex = hash.toRadixString(16).padLeft(8, '0');
    return hashHex == parts[1];
  }

  static String _generateSalt() {
    final random = Random.secure();
    final chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
