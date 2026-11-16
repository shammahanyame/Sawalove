import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'shared/services/backend_service.dart';
import 'shared/services/call_ringer.dart';
import 'shared/services/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts ship in assets/google_fonts; never fetch them over the network.
  GoogleFonts.config.allowRuntimeFetching = false;
  const isReleaseBuild = bool.fromEnvironment('dart.vm.product');

  await BackendService.initialize();
  // No-op unless the build was given FIREBASE_* dart-defines.
  await PushService.initialize();
  // Foreground fallback so calls still ring without Firebase keys.
  CallRinger.initialize();

  if (!BackendService().isConfigured) {
    if (isReleaseBuild) {
      throw StateError(
        'SUPABASE_URL / SUPABASE_ANON_KEY are missing. Release builds require the Supabase project.',
      );
    }
    debugPrint('SUPABASE_URL missing; running with demo backend.');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
