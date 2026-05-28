import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class CurrentUserProfile {
  CurrentUserProfile._();

  static User? get _user => FirebaseAuth.instance.currentUser;

  static String get id => _user?.uid ?? 'local-user';

  static String get name {
    final displayName = _user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = _user?.email?.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;

    return 'Motorista SAFE';
  }

  static String? get email {
    final value = _user?.email?.trim();
    return value == null || value.isEmpty ? null : value;
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
}
