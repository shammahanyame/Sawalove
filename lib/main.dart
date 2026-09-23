import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'shared/services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts ship in assets/google_fonts; never fetch them over the network.
  GoogleFonts.config.allowRuntimeFetching = false;
  const isReleaseBuild = bool.fromEnvironment('dart.vm.product');

  if (apiBaseUrl.trim().isEmpty) {
    if (isReleaseBuild) {
      throw StateError(
        'API_BASE_URL is missing. Release builds require the PHP API URL.',
      );
    }
    debugPrint('API_BASE_URL missing; running with demo backend.');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

