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
        phpApiBaseUrl;

const apiBaseUrl = phpApiBaseUrl;

// Compatibility names kept while the app finishes moving away from Firebase/
// Supabase terminology.
const supabaseUrl = phpApiBaseUrl;
const supabaseAnonKey = '';
const supabasePhoneAuthEnabled = apiPhoneAuthEnabled;
const supabaseEmailAuthEnabled = apiEmailAuthEnabled;
const supabaseGoogleAuthEnabled = apiGoogleAuthEnabled;
const supabaseAppleAuthEnabled = apiAppleAuthEnabled;

final firebaseServiceProvider = Provider<BackendService>((ref) {
  return ref.watch(backendServiceProvider);
});

typedef FirebaseService = BackendService;
