import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class CurrentUserProfile {
  CurrentUserProfile._();

  static String? _localEmail;

  static User? get _user => FirebaseAuth.instance.currentUser;

  static String get id => _user?.uid ?? _localUserId ?? 'local-user';

  static String? get _localUserId {
    final email = _localEmail;
    if (email == null || email.isEmpty) return null;
    return 'local-${email.toLowerCase()}';
  }

  static String get name {
    final displayName = _user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = _user?.email?.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;

    final localEmail = _localEmail;
    if (localEmail != null && localEmail.isNotEmpty) {
      return localEmail.split('@').first;
    }

    return 'Motorista SAFE';
  }

  static String? get email {
    final value = _user?.email?.trim();
    if (value != null && value.isNotEmpty) return value;
    return _localEmail;
  }

  static String? get photoUrl {
    final value = _user?.photoURL?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static String get initial {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return 'S';
    return trimmedName.characters.first.toUpperCase();
  }

  static void setLocalAccount({required String email}) {
    _localEmail = email.trim();
  }

  static void clearLocalAccount() {
    _localEmail = null;
  }
}
