import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sawalove/core/utils/logger.dart';

const phpApiBaseUrl = String.fromEnvironment('API_BASE_URL');
const apiPhoneAuthEnabled = bool.fromEnvironment(
  'API_PHONE_AUTH_ENABLED',
  defaultValue: true,
);
const apiEmailAuthEnabled = bool.fromEnvironment(
  'API_EMAIL_AUTH_ENABLED',
  defaultValue: true,
);
const apiGoogleAuthEnabled = bool.fromEnvironment(
  'API_GOOGLE_AUTH_ENABLED',
  defaultValue: false,
);
const apiAppleAuthEnabled = bool.fromEnvironment(
  'API_APPLE_AUTH_ENABLED',
  defaultValue: false,
);

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
    phone: apiPhoneAuthEnabled,
    email: apiEmailAuthEnabled,
    google: apiGoogleAuthEnabled,
    apple: apiAppleAuthEnabled,
  );
}

class BackendService {
  static const _sessionTokenKey = 'sawalove.php.session_token';
  static const _sessionUserIdKey = 'sawalove.php.session_user_id';
  static const _sessionExpiresAtKey = 'sawalove.php.session_expires_at';

  static final StreamController<User?> _authController =
      StreamController<User?>.broadcast();

  static Future<void>? _sessionLoadFuture;
  static String? _sessionToken;
  static String? _sessionUserId;
  static DateTime? _sessionExpiresAt;
  static bool _lastLoadedSessionWasExpired = false;

  String? _pendingOtpPhone;
  Future<AuthProviderAvailability>? _providerAvailabilityFuture;

  bool get isConfigured => phpApiBaseUrl.trim().isNotEmpty;

  bool get lastLoadedSessionWasExpired => _lastLoadedSessionWasExpired;

  Future<void> loadLocalSession() => _ensureSessionLoaded();

  Future<bool> hasValidSession({bool verifyRemote = false}) async {
    if (!isConfigured) return false;

    await _ensureSessionLoaded();
    if (_sessionUserId == null || _sessionToken == null) return false;
    if (_isSessionExpired) {
      await _clearSession();
      _lastLoadedSessionWasExpired = true;
      return false;
    }

    if (!verifyRemote) return true;

    try {
      final response = await _sendJson('GET', '/session');
      await _storeSessionFromResponse(response);
      return _sessionUserId != null;
    } catch (e) {
      logger.w('Saved PHP session is not valid: $e');
      await _clearSession();
      return false;
    }
  }

  Future<AuthProviderAvailability> fetchAuthProviderAvailability({
    bool refresh = false,
  }) {
    if (_providerAvailabilityFuture == null || refresh) {
      _providerAvailabilityFuture = _loadAuthProviderAvailability();
    }
    return _providerAvailabilityFuture!;
  }

  Future<AuthProviderAvailability> _loadAuthProviderAvailability() async {
    if (!isConfigured) return AuthProviderAvailability.fromDartDefines;

    try {
      final response = await _sendJson('GET', '/auth/providers');
      final providers = response['providers'];
      if (providers is! Map) return AuthProviderAvailability.fromDartDefines;

      return AuthProviderAvailability(
        phone: apiPhoneAuthEnabled &&
            _providerEnabled(providers, 'phone', apiPhoneAuthEnabled),
        email: apiEmailAuthEnabled &&
            _providerEnabled(providers, 'email', apiEmailAuthEnabled),
        google: apiGoogleAuthEnabled &&
            _providerEnabled(providers, 'google', apiGoogleAuthEnabled),
        apple: apiAppleAuthEnabled &&
            _providerEnabled(providers, 'apple', apiAppleAuthEnabled),
      );
    } catch (e) {
      logger.w('PHP auth providers unavailable: $e');
      return AuthProviderAvailability.fromDartDefines;
    }
  }

  bool _providerEnabled(
      Map<dynamic, dynamic> providers, String key, bool fallback) {
    final value = providers[key];
    return value is bool ? value : fallback;
  }

  Future<bool> signInWithPhone(String phone) async {
    final availability = await fetchAuthProviderAvailability();
    if (!availability.phone) {
      throw BackendAuthException(code: 'phone-provider-disabled');
    }

    if (!isConfigured) {
      _pendingOtpPhone = phone;
      logger.i('Phone sign in demo mode for $phone');
      return true;
    }

    await _sendJson(
      'POST',
      '/auth/phone/request',
      body: {'phone': phone},
    );
    _pendingOtpPhone = phone;
    return true;
  }

  Future<bool> verifyOTP(String smsCode, {String? phone}) async {
    if (!isConfigured) {
      logger.i('OTP verify demo mode');
      return true;
    }

    final otpPhone = phone ?? _pendingOtpPhone;
    if (otpPhone == null || otpPhone.isEmpty) {
      throw BackendAuthException(code: 'missing-phone');
    }

    final response = await _sendJson(
      'POST',
      '/auth/phone/verify',
      body: {
        'phone': otpPhone,
        'code': smsCode,
      },
    );
    await _storeSessionFromResponse(response);
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
      throw BackendAuthException(code: 'email-provider-disabled');
    }

    if (!isConfigured) {
      logger.i('Email sign up demo mode for $email');
      return true;
    }

    final response = await _sendJson(
      'POST',
      '/auth/email/signup',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'country': country,
      },
    );
    await _storeSessionFromResponse(response);
    return true;
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final availability = await fetchAuthProviderAvailability();
    if (!availability.email) {
      throw BackendAuthException(code: 'email-provider-disabled');
    }

    if (!isConfigured) {
      logger.i('Email sign in demo mode for $email');
      return true;
    }

    final response = await _sendJson(
      'POST',
      '/auth/email/signin',
      body: {
        'email': email,
        'password': password,
      },
    );
    await _storeSessionFromResponse(response);
    return true;
  }

  Future<bool> signInWithGoogle() async {
    final availability = await fetchAuthProviderAvailability();
    if (!availability.google) {
      throw BackendAuthException(code: 'google-provider-disabled');
    }
    return _signInWithOAuth('google');
  }

  Future<bool> signInWithApple() async {
    final availability = await fetchAuthProviderAvailability();
    if (!availability.apple) {
      throw BackendAuthException(code: 'apple-provider-disabled');
    }
    return _signInWithOAuth('apple');
  }

  Future<bool> _signInWithOAuth(String provider) async {
    if (!isConfigured) {
      logger.i('$provider sign in demo mode');
      return true;
    }

    final response = await _sendJson('POST', '/auth/oauth/$provider');
    await _storeSessionFromResponse(response);
    return true;
  }

  /// Saves the user's transaction PIN.
  ///
  /// SECURITY: the raw PIN is sent over TLS and hashed server-side with
  /// password_hash() (bcrypt + per-user salt). Never send or store an
  /// unsalted client-side hash of a short numeric code.
  Future<void> savePin(String pin) async {
    if (!isConfigured) {
      logger.i('Save PIN demo mode');
      return;
    }

    await _sendJson(
      'POST',
      '/me/pin',
      body: {'pin': pin},
      requiresAuth: true,
    );
  }

  Future<void> signOut() async {
    if (isConfigured && _sessionToken != null) {
      try {
        await _sendJson('POST', '/auth/signout');
      } catch (e) {
        logger.w('PHP sign out request failed: $e');
      }
    }
    await _clearSession();
  }

  bool get isSignedIn => currentUserId != null;

  String? get currentUserId {
    if (!isConfigured) return 'demo-user';
    if (_isSessionExpired) return null;
    return _sessionUserId;
  }

  User? get currentUser {
    final uid = currentUserId;
    return uid == null ? null : User(uid: uid);
  }

  Stream<User?> get authStateChanges async* {
    await _ensureSessionLoaded();
    yield currentUser;
    yield* _authController.stream;
  }

  Future<List<Map<String, dynamic>>> fetchVisibleUsers({int limit = 20}) async {
    if (!isConfigured) return _demoUsers.take(limit).toList();

    final response = await _sendJson(
      'GET',
      '/users',
      query: {
        'visible': 'true',
        'limit': '$limit',
      },
    );
    return _readListOfMaps(response['users']).take(limit).toList();
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

    final response = await _sendJson(
      'GET',
      '/users/${Uri.encodeComponent(uid)}',
    );
    final user = response['user'];
    return user is Map ? Map<String, dynamic>.from(user) : null;
  }

  Future<void> saveUserProfile(String uid, Map<String, dynamic> data) async {
    if (!isConfigured) {
      logger.i('Save profile demo mode for $uid');
      return;
    }

    await _sendJson(
      'PUT',
      '/users/${Uri.encodeComponent(uid)}',
      body: data,
      requiresAuth: true,
    );
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

    await _ensureSessionLoaded();
    if (_sessionToken == null || currentUserId == null) {
      throw BackendAuthException(code: 'not-authenticated');
    }

    final extension = switch (contentType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => 'jpg',
    };
    final request = http.MultipartRequest(
      'POST',
      _apiUri('/photos/profile'),
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $_sessionToken',
    });
    request.fields['slot_index'] = '$slotIndex';
    request.fields['content_type'] = contentType;
    request.files.add(
      http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename:
            'profile_${slotIndex}_${DateTime.now().millisecondsSinceEpoch}.$extension',
      ),
    );

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
    final decoded = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exceptionFromResponse(response, decoded);
    }

    final url = decoded['url'];
    return url is String && url.isNotEmpty ? url : null;
  }

  Future<void> pauseAccount() async {
    if (!isConfigured) {
      logger.i('Pause account demo mode');
      return;
    }

    await _sendJson('POST', '/me/pause', requiresAuth: true);
  }

  Future<void> requestAccountDeletion() async {
    if (!isConfigured) {
      logger.i('Account deletion request demo mode');
      return;
    }

    await _sendJson('POST', '/me/delete-request', requiresAuth: true);
    await signOut();
  }

  Future<void> requestDataExport() async {
    if (!isConfigured) {
      logger.i('Data export request demo mode');
      return;
    }

    await _sendJson('POST', '/me/data-export', requiresAuth: true);
  }

  Future<Map<String, dynamic>> _sendJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    bool requiresAuth = false,
  }) async {
    if (!isConfigured) {
      throw BackendAuthException(code: 'backend-not-configured');
    }

    await _ensureSessionLoaded();
    if (requiresAuth && (_sessionToken == null || currentUserId == null)) {
      throw BackendAuthException(code: 'not-authenticated');
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (_sessionToken != null) 'Authorization': 'Bearer $_sessionToken',
    };
    final uri = _apiUri(path, query: query);

    final response = await switch (method) {
      'GET' => http.get(uri, headers: headers),
      'POST' => http.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        ),
      'PUT' => http.put(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        ),
      _ => throw ArgumentError('Unsupported method: $method'),
    }
        .timeout(const Duration(seconds: 20));

    final decoded = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exceptionFromResponse(response, decoded);
    }
    return decoded;
  }

  Uri _apiUri(String path, {Map<String, String>? query}) {
    final normalizedBase = phpApiBaseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$normalizedBase$normalizedPath');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: query);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {'data': decoded};
  }

  BackendAuthException _exceptionFromResponse(
    http.Response response,
    Map<String, dynamic> decoded,
  ) {
    final error = decoded['error'];
    if (error is Map) {
      final code = error['code']?.toString();
      final message = error['message']?.toString();
      return BackendAuthException(
        code: code == null || code.isEmpty ? 'api-error' : code,
        message: message,
        statusCode: response.statusCode,
      );
    }

    return BackendAuthException(
      code: 'api-error',
      message: response.reasonPhrase,
      statusCode: response.statusCode,
    );
  }

  Future<void> _ensureSessionLoaded() {
    if (!isConfigured) return Future.value();
    _sessionLoadFuture ??= _loadSession();
    return _sessionLoadFuture!;
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionToken = prefs.getString(_sessionTokenKey);
    _sessionUserId = prefs.getString(_sessionUserIdKey);
    final rawExpiresAt = prefs.getString(_sessionExpiresAtKey);
    _sessionExpiresAt =
        rawExpiresAt == null ? null : DateTime.tryParse(rawExpiresAt);

    if (_isSessionExpired) {
      _lastLoadedSessionWasExpired = true;
      await _clearSession(notify: false);
    } else {
      _lastLoadedSessionWasExpired = false;
    }
  }

  bool get _isSessionExpired {
    final expiresAt = _sessionExpiresAt;
    return expiresAt != null && expiresAt.isBefore(DateTime.now().toUtc());
  }

  Future<void> _storeSessionFromResponse(Map<String, dynamic> response) async {
    final session = response['session'];
    if (session is! Map) return;

    final token = session['token']?.toString();
    final userId = session['user_id']?.toString();
    final expiresAt = DateTime.tryParse(session['expires_at']?.toString() ?? '');
    if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
      throw BackendAuthException(code: 'invalid-session-response');
    }

    _sessionToken = token;
    _sessionUserId = userId;
    _sessionExpiresAt = expiresAt;
    _lastLoadedSessionWasExpired = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionTokenKey, token);
    await prefs.setString(_sessionUserIdKey, userId);
    if (expiresAt != null) {
      await prefs.setString(_sessionExpiresAtKey, expiresAt.toIso8601String());
    } else {
      await prefs.remove(_sessionExpiresAtKey);
    }

    _authController.add(User(uid: userId));
  }

  Future<void> _clearSession({bool notify = true}) async {
    _sessionToken = null;
    _sessionUserId = null;
    _sessionExpiresAt = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_sessionUserIdKey);
    await prefs.remove(_sessionExpiresAtKey);

    if (notify) _authController.add(null);
  }

  List<Map<String, dynamic>> _readListOfMaps(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }
}

class User {
  final String uid;
  User({required this.uid});
}

class BackendAuthException implements Exception {
  final String code;
  final String? message;
  final int? statusCode;

  BackendAuthException({
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
  final code = _authErrorCode(error);
  final description = _authErrorDescription(error);
  return code == 'phone_provider_disabled' ||
      code == 'phone-provider-disabled' ||
      description.contains('phone_provider_disabled') ||
      description.contains('unsupported phone provider') ||
      (description.contains('phone provider') &&
          (description.contains('disabled') ||
              description.contains('unsupported')));
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
        return 'An account already exists for that email address.';
      case 'invalid_otp':
      case 'otp_expired':
        return 'That OTP is invalid or expired. Request a new code and try again.';
      case 'over_request_rate_limit':
        return 'Too many attempts. Wait a moment, then try again.';
      case 'missing-phone':
        return 'Enter a phone number before verifying an OTP.';
      case 'not-authenticated':
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

String? _authErrorCode(Object error) {
  if (error is BackendAuthException) return error.code;

  final codeMatch =
      RegExp(r'code:\s*([a-zA-Z0-9_-]+)').firstMatch(error.toString());
  return codeMatch?.group(1);
}

String _authErrorDescription(Object error) {
  if (error is BackendAuthException) {
    return '${error.code} ${error.message ?? ''} $error'.toLowerCase();
  }
  return error.toString().toLowerCase();
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
