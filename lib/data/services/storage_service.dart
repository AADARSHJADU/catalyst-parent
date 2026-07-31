import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Handles local persistence — token, user data, etc.
class StorageService {
  static const _keyToken = 'auth_token';
  static const _keyUser = 'user_data';

  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  /// Singleton accessor (use after init() is called in main).
  static StorageService get instance => _instance!;

  static Future<StorageService> init() async {
    if (_instance != null) return _instance!;
    _instance = StorageService._();
    _instance!._prefs = await SharedPreferences.getInstance();
    return _instance!;
  }

  // ── Token ──────────────────────────────────────────────────────────────────
  String? getToken() => _prefs.getString(_keyToken);

  Future<void> saveToken(String token) =>
      _prefs.setString(_keyToken, token);

  Future<void> clearToken() => _prefs.remove(_keyToken);

  bool get hasToken {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // ── User data ──────────────────────────────────────────────────────────────
  Map<String, dynamic>? getUser() {
    final raw = _prefs.getString(_keyUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(Map<String, dynamic> user) =>
      _prefs.setString(_keyUser, jsonEncode(user));

  Future<void> clearUser() => _prefs.remove(_keyUser);

  // ── Clear all ──────────────────────────────────────────────────────────────
  Future<void> clearAll() => _prefs.clear();
}
