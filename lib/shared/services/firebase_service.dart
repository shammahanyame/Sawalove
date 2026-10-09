import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backend_service.dart';

export 'backend_service.dart'
    show
        AuthProviderAvailability,
        BackendAuthException,
        BackendService,
        User,
        apiAppleAuthEnabled,
        apiEmailAuthEnabled,
        apiGoogleAuthEnabled,
        apiPhoneAuthEnabled,
        authErrorMessage,
        authProviderAvailabilityProvider,
        isPhoneProviderDisabledAuthError,
        supabaseUrlDefine;

const apiBaseUrl = supabaseUrlDefine;

// Compatibility names kept while screens migrate off Firebase terminology.
const supabaseUrl = supabaseUrlDefine;
const supabaseAnonKey = supabaseAnonKeyDefine;
const supabasePhoneAuthEnabled = apiPhoneAuthEnabled;
const supabaseEmailAuthEnabled = apiEmailAuthEnabled;
const supabaseGoogleAuthEnabled = apiGoogleAuthEnabled;
const supabaseAppleAuthEnabled = apiAppleAuthEnabled;

final firebaseServiceProvider = Provider<BackendService>((ref) {
  return ref.watch(backendServiceProvider);
});

typedef FirebaseService = BackendService;
