import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sawalove/core/utils/logger.dart';

const supabaseUrlDefine = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKeyDefine = String.fromEnvironment('SUPABASE_ANON_KEY');
const supabaseProfilePhotosBucket =
    String.fromEnvironment('SUPABASE_PROFILE_PHOTOS_BUCKET', defaultValue: 'profile-photos');
const supabaseAuthRedirectTo =
    String.fromEnvironment('SUPABASE_AUTH_REDIRECT_TO', defaultValue: 'io.sawalove.app://login-callback');
const supabasePhoneAuthEnabled = bool.fromEnvironment(
  'SUPABASE_PHONE_AUTH_ENABLED',
  defaultValue: true,
);
const supabaseEmailAuthEnabled = bool.fromEnvironment(
  'SUPABASE_EMAIL_AUTH_ENABLED',
  defaultValue: true,
);
const supabaseGoogleAuthEnabled = bool.fromEnvironment(
  'SUPABASE_GOOGLE_AUTH_ENABLED',
  defaultValue: false,
);
const supabaseAppleAuthEnabled = bool.fromEnvironment(
  'SUPABASE_APPLE_AUTH_ENABLED',
  defaultValue: false,
);

// Compatibility aliases (screens import these names from firebase_service.dart).
const apiPhoneAuthEnabled = supabasePhoneAuthEnabled;
const apiEmailAuthEnabled = supabaseEmailAuthEnabled;
const apiGoogleAuthEnabled = supabaseGoogleAuthEnabled;
const apiAppleAuthEnabled = supabaseAppleAuthEnabled;

final backendServiceProvider = Provider<BackendService>((ref) {
  return BackendService();
});

final authProviderAvailabilityProvider =
    FutureProvider<AuthProviderAvailability>((ref) {
  return ref.read(backendServiceProvider).fetchAuthProviderAvailability();
});

class AuthProviderAvailability {
  final bool phone;
  final bool email;
  final bool google;
  final bool apple;

  const AuthProviderAvailability({
    required this.phone,
    required this.email,
    required this.google,
    required this.apple,
  });

  static const fromDartDefines = AuthProviderAvailability(
    phone: supabasePhoneAuthEnabled,
    email: supabaseEmailAuthEnabled,
    google: supabaseGoogleAuthEnabled,
    apple: supabaseAppleAuthEnabled,
  );
}

/// Supabase-backed implementation of the app's backend surface.
///
/// Auth: Supabase Auth (GoTrue) — sessions persist automatically.
/// Data: PostgREST + security-definer RPCs (all authorization is RLS + RPC).
/// Media: Supabase Storage `profile-photos` bucket.
/// AI: Edge Functions with ledger-backed spend caps.
class BackendService {
  static SupabaseClient? _client;

  String? _pendingOtpPhone;
  AuthProviderAvailability? _availability;

  static SupabaseClient get client {
    final c = _client;
    if (c == null) {
      throw const BackendAuthException(code: 'backend-not-configured');
    }
    return c;
  }

  /// Initialize once from main() before runApp.
  static Future<void> initialize() async {
    if (supabaseUrlDefine.trim().isEmpty || supabaseAnonKeyDefine.trim().isEmpty) {
      logger.w('SUPABASE_URL / SUPABASE_ANON_KEY missing; demo mode.');
      return;
    }
    await Supabase.initialize(
      url: supabaseUrlDefine,
      publishableKey: supabaseAnonKeyDefine,
    );
    _client = Supabase.instance.client;
  }

  bool get isConfigured => _client != null;

  bool get lastLoadedSessionWasExpired => false;

  Future<void> loadLocalSession() async {}

  Future<bool> hasValidSession({bool verifyRemote = false}) async {
    if (!isConfigured) return false;
    final session = client.auth.currentSession;
    if (session == null) return false;
    if (verifyRemote) {
      try {
        await client.auth.getUser();
      } catch (e) {
        logger.w('Saved Supabase session is not valid: $e');
        await signOut();
        return false;
      }
    }
    return true;
  }

  Future<AuthProviderAvailability> fetchAuthProviderAvailability({
    bool refresh = false,
  }) {
    if (_availability == null || refresh) {
      // Providers are compile-time flags + dashboard settings. The dashboard
      // state surfaces as specific GoTrue error codes at sign-in time, which
      // authErrorMessage() maps to friendly copy.
      _availability = AuthProviderAvailability.fromDartDefines;
    }
    return Future.value(_availability!);
  }

  // ── AUTH ──────────────────────────────────────────────────────────────────

  Future<bool> signInWithPhone(String phone) async {
    final availability = await fetchAuthProviderAvailability();
    if (!availability.phone) {
      throw const BackendAuthException(code: 'phone-provider-disabled');
    }
    if (!isConfigured) {
      _pendingOtpPhone = phone;
      logger.i('Phone sign in demo mode for $phone');
      return true;
    }

    _pendingOtpPhone = phone;
    await client.auth.signInWithOtp(
      phone: phone,
      // The Supabase "OTP expiry" dashboard setting controls this (10 min).
      shouldCreateUser: true,
    );
    return true;
  }

  Future<bool> verifyOTP(String smsCode, {String? phone}) async {
    if (!isConfigured) {
      logger.i('OTP verify demo mode');
      return true;
    }

    final otpPhone = phone ?? _pendingOtpPhone;
    if (otpPhone == null || otpPhone.isEmpty) {
      throw const BackendAuthException(code: 'missing-phone');
    }

    final response = await client.auth.verifyOTP(
      type: OtpType.sms,
      phone: otpPhone,
      token: smsCode,
    );
    if (response.session == null) {
      throw const BackendAuthException(code: 'invalid_otp');
    }
    _pendingOtpPhone = null;
    return true;
  }

  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String country,
  }) async {
    final availability = await fetchAuthProviderAvailability();
    if (!availability.email) {
      throw const BackendAuthException(code: 'email-provider-disabled');
    }
    if (!isConfigured) {
      logger.i('Email sign up demo mode for $email');
      return true;
    }

    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'country': country},
      emailRedirectTo: supabaseAuthRedirectTo,
    );
    if (response.session != null) {
      logger.i('Signed up $email');
    } else {
      logger.i('Signed up $email; confirmation email sent');
    }
    return true;
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final availability = await fetchAuthProviderAvailability();
    if (!availability.email) {
      throw const BackendAuthException(code: 'email-provider-disabled');
    }
    if (!isConfigured) {
      logger.i('Email sign in demo mode for $email');
      return true;
    }

    await client.auth.signInWithPassword(email: email, password: password);
    return true;
  }

  Future<bool> signInWithGoogle() async {
    final availability = await fetchAuthProviderAvailability();
    if (!availability.google) {
      throw const BackendAuthException(code: 'google-provider-disabled');
    }
    if (!isConfigured) return true;
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: supabaseAuthRedirectTo,
    );
    return true;
  }

  Future<bool> signInWithApple() async {
    final availability = await fetchAuthProviderAvailability();
    if (!availability.apple) {
      throw const BackendAuthException(code: 'apple-provider-disabled');
    }
    if (!isConfigured) return true;
    await client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: supabaseAuthRedirectTo,
    );
    return true;
  }

  /// Sends a password reset email. The reset LINK expiry is enforced by
  /// Supabase Auth (dashboard: "Password reset / recovery link expiry",
  /// configured to 1 hour) and flood-limited (2/hour/IP).
  Future<void> sendPasswordReset(String email) async {
    if (!isConfigured) {
      logger.i('Password reset demo mode for $email');
      return;
    }
    await client.auth.resetPasswordForEmail(
      email,
      redirectTo: supabaseAuthRedirectTo,
    );
    try {
      await client.rpc('log_event', params: {
        'p_level': 'warn',
        'p_event': 'password_reset_requested',
        'p_context': {'email_domain': email.split('@').last},
      });
    } catch (_) {
      // Logging must never block the user flow.
    }
  }

  /// Saves the user's transaction PIN. Hashed server-side (bcrypt via
  /// pgcrypto) inside the save_pin RPC; the raw PIN only travels over TLS.
  Future<void> savePin(String pin) async {
    if (!isConfigured) {
      logger.i('Save PIN demo mode');
      return;
    }
    await client.rpc('save_pin', params: {'p_pin': pin});
  }

  Future<void> signOut() async {
    if (isConfigured) {
      try {
        await client.auth.signOut();
      } catch (e) {
        logger.w('Supabase sign out failed: $e');
      }
    }
  }

  bool get isSignedIn => currentUserId != null;

  String? get currentUserId => isConfigured ? client.auth.currentUser?.id : null;

  User? get currentUser {
    final uid = currentUserId;
    return uid == null ? null : User(uid: uid);
  }

  Stream<User?> get authStateChanges {
    if (!isConfigured) return Stream.value(null);
    return client.auth.onAuthStateChange
        .map((event) => event.session == null ? null : User(uid: event.session!.user.id));
  }

  // ── PROFILES + DISCOVERY ──────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchVisibleUsers({int limit = 20}) async {
    if (!isConfigured) return _demoUsers.take(limit).toList();

    final rows = await client.rpc('fetch_discovery_deck', params: {
      'p_limit': limit,
    });
    return _readListOfMaps(rows).take(limit).toList();
  }

  Stream<List<Map<String, dynamic>>> watchVisibleUsers({int limit = 20}) {
    if (!isConfigured) return Stream.value(_demoUsers.take(limit).toList());

    return Stream<List<Map<String, dynamic>>>.multi((controller) {
      Timer? timer;

      Future<void> emit() async {
        if (controller.isClosed) return;
        try {
          controller.add(await fetchVisibleUsers(limit: limit));
        } catch (e, stackTrace) {
          controller.addError(e, stackTrace);
        }
      }

      emit();
      // Realtime would need a public channel; polling every 12s matches the
      // previous behavior and respects RLS row filtering automatically.
      timer = Timer.periodic(const Duration(seconds: 12), (_) => emit());
      controller.onCancel = () => timer?.cancel();
    });
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    if (!isConfigured) {
      return _demoUsers.cast<Map<String, dynamic>?>().firstWhere(
            (user) => user?['id'] == uid,
            orElse: () => null,
          );
    }

    final rows = await client
        .from('users')
        .select(_publicProfileColumns)
        .eq('id', uid)
        .limit(1);
    final list = _readListOfMaps(rows);
    return list.isEmpty ? null : list.first;
  }

  Future<void> saveUserProfile(String uid, Map<String, dynamic> data) async {
    if (!isConfigured) {
      logger.i('Save profile demo mode for $uid');
      return;
    }

    // Whitelist writable columns; protected columns (status/role/isPremium/
    // visible) are additionally pinned server-side by the RLS restrictive
    // policy, so even a malicious client cannot escalate.
    const writable = {
      'name', 'age', 'city', 'location', 'village', 'goal', 'intent',
      'bio', 'photo', 'lat', 'lng', 'distance', 'preferences',
    };
    final update = Map.fromEntries(
      data.entries.where((e) => writable.contains(e.key)),
    );
    if (update.isEmpty) return;

    await client.from('users').update(update).eq('id', uid);
  }

  Future<String?> uploadProfilePhoto({
    required Uint8List bytes,
    required int slotIndex,
    String contentType = 'image/jpeg',
  }) async {
    if (!isConfigured) {
      logger.i('Profile photo upload demo mode for slot $slotIndex');
      return null;
    }

    final uid = currentUserId;
    if (uid == null) {
      throw const BackendAuthException(code: 'not-authenticated');
    }

    final extension = switch (contentType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => 'jpg',
    };
    final path = '$uid/slot_$slotIndex.$extension';

    // Storage RLS restricts uploads to the owner's folder; the bucket caps
    // size at 5 MB and MIME to jpeg/png/webp.
    await client.storage.from(supabaseProfilePhotosBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );

    return client.storage.from(supabaseProfilePhotosBucket).getPublicUrl(path);
  }

  // ── ACCOUNT OPS ───────────────────────────────────────────────────────────

  Future<void> pauseAccount() async {
    if (!isConfigured) {
      logger.i('Pause account demo mode');
      return;
    }
    await client.rpc('pause_account');
  }

  Future<void> requestAccountDeletion() async {
    if (!isConfigured) {
      logger.i('Account deletion request demo mode');
      return;
    }
    await client.rpc('request_account_deletion');
    await signOut();
  }

  Future<void> requestDataExport() async {
    if (!isConfigured) {
      logger.i('Data export request demo mode');
      return;
    }
    await client.rpc('request_data_export');
  }

  // ── AI SUGGESTIONS (Edge Functions) ───────────────────────────────────────

  /// Returns null on any failure (not configured, offline, budget exhausted,
  /// provider error) so callers fall back to built-in static content.
  Future<List<String>?> fetchAiIceBreakers({String about = ''}) async {
    return _fetchAiSuggestions('ai-icebreakers', about);
  }

  Future<List<String>?> fetchAiBioSuggestions({String about = ''}) async {
    return _fetchAiSuggestions('ai-bio-suggestions', about);
  }

  Future<List<String>?> _fetchAiSuggestions(String functionName, String about) async {
    if (!isConfigured) return null;
    try {
      final response = await client.functions.invoke(
        functionName,
        body: {'about': about},
      );
      final raw = response.data is Map
          ? (response.data as Map)['suggestions']
          : null;
      if (raw is! List) return null;
      final items = raw
          .whereType<String>()
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((e) => e.length > 160 ? e.substring(0, 160) : e)
          .take(6)
          .toList();
      return items.isEmpty ? null : items;
    } catch (_) {
      // Includes 429 budget caps and network errors — degrade gracefully.
      return null;
    }
  }

  // ── SWIPES / MATCHES / MESSAGES ───────────────────────────────────────────

  Future<SwipeResult> sendSwipe({
    required String targetUserId,
    required String action, // 'like' | 'nope' | 'super_like'
  }) async {
    final decoded = await client.rpc('record_swipe', params: {
      'p_target_id': targetUserId,
      'p_action': action,
    });
    return SwipeResult(
      matched: decoded['matched'] == true,
      matchId: decoded['match_id']?.toString(),
    );
  }

  Future<List<Map<String, dynamic>>> fetchIncomingLikes({int limit = 20}) async {
    final rows = await client.rpc('fetch_incoming_likes', params: {
      'p_limit': limit,
    });
    return _readListOfMaps(rows);
  }

  Future<List<Map<String, dynamic>>> fetchMatches({int limit = 30}) async {
    final rows = await client.rpc('fetch_matches', params: {'p_limit': limit});
    final result = <Map<String, dynamic>>[];
    for (final row in _readListOfMaps(rows)) {
      final peer = row['peer'];
      final entry = <String, dynamic>{
        'match_id': row['match_id']?.toString(),
        if (peer is Map) ...Map<String, dynamic>.from(peer),
      };
      final lastMessage = row['last_message'];
      if (lastMessage is Map && lastMessage['body_preview'] != null) {
        entry['last_message'] = lastMessage['body_preview'];
      }
      result.add(entry);
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchMessages(
    String matchId, {
    int limit = 50,
  }) async {
    final rows = await client.rpc('fetch_messages', params: {
      'p_match_id': matchId,
      'p_limit': limit,
    });
    return _readListOfMaps(rows);
  }

  Future<Map<String, dynamic>> sendMessage(
    String matchId,
    String body,
  ) async {
    final msg = await client.rpc('send_message', params: {
      'p_match_id': matchId,
      'p_body': body,
    });
    return _readListOfMaps([msg]).first;
  }

  Future<void> unmatch(String matchId) async {
    await client.rpc('unmatch', params: {'p_match_id': matchId});
  }

  Future<Map<String, dynamic>?> fetchMatch(String matchId) async {
    final matches = await fetchMatches(limit: 100);
    for (final m in matches) {
      if (m['match_id'] == matchId) return m;
    }
    return null;
  }

  // ── BLOCKS ────────────────────────────────────────────────────────────────

  Future<void> blockUser(String uid) async {
    await client.rpc('block_user', params: {'p_target_id': uid});
  }

  Future<void> unblockUser(String uid) async {
    await client.rpc('unblock_user', params: {'p_target_id': uid});
  }

  Future<List<Map<String, dynamic>>> fetchBlockedUsers() async {
    final rows = await client.rpc('fetch_blocked_users');
    return _readListOfMaps(rows);
  }

  // ── REPORTS + MODERATION ──────────────────────────────────────────────────

  Future<String> submitReport({
    required String reportedUserId,
    required String reason,
    String? details,
  }) async {
    final report = await client.rpc('submit_report', params: {
      'p_reported_user_id': reportedUserId,
      'p_reason': reason,
      if (details != null && details.trim().isNotEmpty) 'p_details': details.trim(),
    });
    return report is Map ? (report['id']?.toString() ?? '') : '';
  }

  Future<List<Map<String, dynamic>>> fetchModerationReports({
    String status = 'pending',
  }) async {
    final rows = await client.rpc('fetch_moderation_reports', params: {
      'p_status': status,
    });
    return _readListOfMaps(rows);
  }

  Future<void> resolveReport({
    required String reportId,
    required String outcome,
    String? note,
  }) async {
    await client.rpc('resolve_report', params: {
      'p_report_id': reportId,
      'p_outcome': outcome,
      if (note != null && note.trim().isNotEmpty) 'p_note': note.trim(),
    });
  }

  Future<void> setUserStatus({
    required String userId,
    required String action, // 'pause' | 'ban' | 'reinstate'
    String? note,
  }) async {
    await client.rpc('set_user_status', params: {
      'p_user_id': userId,
      'p_action': action,
      if (note != null && note.trim().isNotEmpty) 'p_note': note.trim(),
    });
  }

  Future<void> logClientEvent({
    String level = 'info',
    required String event,
    Map<String, dynamic> context = const {},
  }) async {
    if (!isConfigured) return;
    try {
      await client.rpc('log_event', params: {
        'p_level': level,
        'p_event': event,
        'p_context': context,
      });
    } catch (_) {
      // Logging must never block the user flow.
    }
  }
}

/// Columns any client may read from public.users — email/phone/pin_hash are
/// excluded server-side by column grants too (defense in depth).
const _publicProfileColumns =
    'id, name, age, city, location, village, goal, intent, bio, photo, '
    'visible, status, "isPremium", lat, lng, distance, preferences, created_at';

class User {
  final String uid;
  User({required this.uid});
}

/// Result of record_swipe.
class SwipeResult {
  final bool matched;
  final String? matchId;

  const SwipeResult({required this.matched, this.matchId});
}

class BackendAuthException implements Exception {
  final String code;
  final String? message;
  final int? statusCode;

  const BackendAuthException({
    required this.code,
    this.message,
    this.statusCode,
  });

  @override
  String toString() {
    final details = [
      code,
      if (message != null && message!.isNotEmpty) message,
      if (statusCode != null) 'statusCode: $statusCode',
    ].join(', ');
    return 'BackendAuthException($details)';
  }
}

const _phoneProviderDisabledMessage =
    'Phone sign-in is temporarily unavailable. Use email to continue while SMS login is being enabled.';
const _emailProviderDisabledMessage =
    'Email sign-in is temporarily unavailable. Try another sign-in option.';
const _socialProviderDisabledMessage =
    'This social sign-in option is temporarily unavailable. Use email to continue.';

bool isPhoneProviderDisabledAuthError(Object error) {
  final description = _authErrorDescription(error);
  return description.contains('phone_provider_disabled') ||
      description.contains('phone provider is disabled') ||
      description.contains('unsupported phone provider') ||
      description.contains('phone provider') &&
          (description.contains('disabled') || description.contains('unsupported'));
}

String authErrorMessage(Object error) {
  if (error is BackendAuthException) {
    if (isPhoneProviderDisabledAuthError(error)) {
      return _phoneProviderDisabledMessage;
    }

    switch (error.code) {
      case 'email_provider_disabled':
      case 'email-provider-disabled':
        return _emailProviderDisabledMessage;
      case 'google-provider-disabled':
      case 'apple-provider-disabled':
      case 'provider-disabled':
      case 'provider_disabled':
        return _socialProviderDisabledMessage;
      case 'invalid_credentials':
      case 'invalid-credentials':
        return 'The email, phone, or password is incorrect.';
      case 'email_already_exists':
      case 'email-already-exists':
      case 'user_already_exists':
        return 'An account already exists for that email address.';
      case 'invalid_otp':
      case 'otp_expired':
        return 'That OTP is invalid or expired. Request a new code and try again.';
      case 'over_request_rate_limit':
      case 'over_rate_limit':
        return 'Too many attempts. Wait a moment, then try again.';
      case 'missing-phone':
        return 'Enter a phone number before verifying an OTP.';
      case 'not-authenticated':
      case 'not_authenticated':
        return 'You need to sign in again.';
      case 'backend-not-configured':
        return 'The backend is not configured on this build.';
    }

    if (error.message != null && error.message!.trim().isNotEmpty) {
      return error.message!;
    }
  }

  final description = _authErrorDescription(error);
  if (isPhoneProviderDisabledAuthError(error)) {
    return _phoneProviderDisabledMessage;
  }
  if (description.contains('email_provider_disabled') ||
      description.contains('email provider is disabled')) {
    return _emailProviderDisabledMessage;
  }
  if (description.contains('provider_disabled') ||
      description.contains('provider is not enabled') ||
      description.contains('unsupported provider')) {
    return _socialProviderDisabledMessage;
  }

  return 'Something went wrong while signing in. Please try again.';
}

String _authErrorDescription(Object error) {
  if (error is BackendAuthException) {
    return '${error.code} ${error.message ?? ''} $error'.toLowerCase();
  }
  return error.toString().toLowerCase();
}

List<Map<String, dynamic>> _readListOfMaps(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((row) => Map<String, dynamic>.from(row))
      .toList();
}

const _demoUsers = [
  {
    'id': 'demo-user',
    'name': 'Amaka',
    'age': 28,
    'city': 'Douala',
    'intent': 'Serious relationship',
    'visible': true,
    'isPremium': false,
    'lat': 0.01,
    'lng': 0.02,
    'distance': 2.5,
  },
];
