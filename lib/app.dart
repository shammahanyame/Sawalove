import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'core/router/app_router.dart';
import 'features/chat/models/incoming_call_data.dart';
import 'l10n/app_localizations.dart';
import 'shared/providers/app_settings_provider.dart';
import 'shared/services/call_ringer.dart';
import 'shared/services/push_service.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    PushService.incomingCall.addListener(_openIncomingCall);
    // Foreground fallback for builds without push credentials.
    CallRinger.ring.addListener(_openIncomingCall);
    // A cold start from the ringing notification can resolve before the first
    // frame, so check once the router exists too.
    WidgetsBinding.instance.addPostFrameCallback((_) => _openIncomingCall());
  }

  void _openIncomingCall() {
    final payload = CallRinger.ring.value ?? PushService.incomingCall.value;
    if (payload == null || !mounted) return;
    // Consumed: the ring must not reopen on the next rebuild.
    PushService.incomingCall.value = null;
    CallRinger.clear();
    ref.read(goRouterProvider).go(
          '/call/incoming',
          extra: IncomingCallData.fromMap(payload),
        );
  }

  @override
  void dispose() {
    PushService.incomingCall.removeListener(_openIncomingCall);
    CallRinger.ring.removeListener(_openIncomingCall);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      title: 'SawaLove',
      theme: SawaLoveTheme.lightTheme,
      darkTheme: SawaLoveTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      routerConfig: router,
    );
  }
}
