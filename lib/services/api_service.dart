import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Using a free exchange rate API (no key required for basic usage)
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest/IDR';

  // Cache for the session
  double? _cachedUsdRate;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 30);

  /// Get USD to IDR conversion rate.
  /// Returns the rate (how many IDR per 1 USD), or null on failure.
  Future<double?> getUsdToIdrRate() async {
    // Check cache
    if (_cachedUsdRate != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        return _cachedUsdRate;
      }
    }

    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>;
        final usdRate = rates['USD'] as double;

        // Cache the result
        _cachedUsdRate = usdRate;
        _cacheTime = DateTime.now();

        return usdRate;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Convert IDR price to USD.
  Future<double?> convertIdrToUsd(double idrAmount) async {
    final rate = await getUsdToIdrRate();
    if (rate == null) return null;
    return idrAmount * rate; // rate is USD per 1 IDR
  }
}