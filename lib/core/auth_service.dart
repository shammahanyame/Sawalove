import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/services/firebase_service.dart';

enum AuthResult { firstInstall, validSession, expiredSession, noSession }

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  Future<AuthResult> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = !prefs.containsKey('first_launch_done');
    if (isFirstLaunch) return AuthResult.firstInstall;

    final backend = FirebaseService();
    if (!backend.isConfigured) {
      return AuthResult.noSession;
    }

    final hasSession = await backend.hasValidSession();
    if (hasSession) return AuthResult.validSession;
    return backend.lastLoadedSessionWasExpired
        ? AuthResult.expiredSession
        : AuthResult.noSession;
  }
}
