import 'dart:convert';

import 'package:safe/shared/services/current_user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthException implements Exception {
  final String message;

  const LocalAuthException(this.message);
}

class LocalAuthService {
  LocalAuthService._();

  static const String _accountsKey = 'safe_local_accounts';

  static Future<void> createAccount({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final accounts = await _loadAccounts();

    if (accounts.containsKey(normalizedEmail)) {
      throw const LocalAuthException('Este e-mail já tem uma conta local.');
    }

    accounts[normalizedEmail] = {
      'email': normalizedEmail,
      'password': password,
    };

    await _saveAccounts(accounts);
    CurrentUserProfile.setLocalAccount(email: normalizedEmail);
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final accounts = await _loadAccounts();
    final account = accounts[normalizedEmail];

    if (account == null || account['password'] != password) {
      throw const LocalAuthException('E-mail ou senha local incorretos.');
    }

    CurrentUserProfile.setLocalAccount(email: normalizedEmail);
  }

  static void signOut() {
    CurrentUserProfile.clearLocalAccount();
  }

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  static Future<Map<String, Map<String, String>>> _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_accountsKey);
    if (saved == null) return {};

    final decoded = jsonDecode(saved) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, Map<String, String>.from(value as Map)),
    );
  }

  static Future<void> _saveAccounts(
    Map<String, Map<String, String>> accounts,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountsKey, jsonEncode(accounts));
  }
}
