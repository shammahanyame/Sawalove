import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _wordmarkController;
  late final Animation<double> _logoAnimation;
  late final Animation<double> _wordmarkAnimation;

  bool _showLanguageSelect = false;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _wordmarkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );
    _wordmarkAnimation = CurvedAnimation(
      parent: _wordmarkController,
      curve: Curves.easeOutCubic,
    );
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = !prefs.containsKey('first_launch_done');

      await _runBrandAnimation();
      if (!mounted) return;

      if (isFirstLaunch) {
        setState(() => _showLanguageSelect = true);
        return;
      }

      final authResult = await Future.any<AuthResult>([
        ref.read(authServiceProvider).checkSession(),
        Future<AuthResult>.delayed(
          const Duration(seconds: 5),
          () => AuthResult.noSession,
        ),
      ]);

      if (!mounted) return;
      _navigateBasedOnAuth(authResult);
    } catch (e, st) {
      debugPrint('SplashScreen init error: $e');
      debugPrintStack(stackTrace: st);
      if (mounted) _navigateBasedOnAuth(AuthResult.noSession);
    }
  }

  Future<void> _runBrandAnimation() async {
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _wordmarkController.forward();
  }

  void _navigateBasedOnAuth(AuthResult result) {
    final router = GoRouter.of(context);
    switch (result) {
      case AuthResult.firstInstall:
        router.go('/language-select');
      case AuthResult.validSession:
        router.go('/home/discover');
      case AuthResult.expiredSession:
        router.go('/login?reason=expired');
      case AuthResult.noSession:
        router.go('/login');
    }
  }

  Future<void> _selectLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language', language);
    await prefs.setBool('first_launch_done', true);
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _logoController.dispose();
    _wordmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB30065),
      body: SafeArea(
        child: _showLanguageSelect
            ? _LanguageSelectionState(onLanguageSelected: _selectLanguage)
            : _SplashAnimationState(
                logoAnimation: _logoAnimation,
                wordmarkAnimation: _wordmarkAnimation,
              ),
      ),
    );
  }
}

class _SplashAnimationState extends StatelessWidget {
  final Animation<double> logoAnimation;
  final Animation<double> wordmarkAnimation;

  const _SplashAnimationState({
    required this.logoAnimation,
    required this.wordmarkAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = MediaQuery.of(context).disableAnimations;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: logoAnimation,
              builder: (context, child) => Transform.scale(
                scale: isDisabled ? 1.0 : logoAnimation.value,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/branding/sawalove_app_icon_512.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: wordmarkAnimation,
              builder: (context, child) => Opacity(
                opacity: isDisabled ? 1.0 : wordmarkAnimation.value,
                child: const Column(
                  children: [
                    Text(
                      'SawaLove',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 48,
                        letterSpacing: 0,
                        color: Color(0xFFFFEFF2),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Find your soulmate in Cameroon / Trouvez votre ame soeur au Cameroun',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFFEFF2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 56),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFFFEFF2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSelectionState extends StatelessWidget {
  final Future<void> Function(String) onLanguageSelected;

  const _LanguageSelectionState({required this.onLanguageSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/branding/sawalove_app_icon_512.png',
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEFF2),
                foregroundColor: const Color(0xFFB30065),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              onPressed: () => onLanguageSelected('en'),
              child: const Text(
                'English',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFEFF2),
                side: const BorderSide(color: Color(0xFFFFE0EA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              onPressed: () => onLanguageSelected('fr'),
              child: const Text(
                'Francais',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LocaleBadge(label: 'CM'),
              SizedBox(width: 8),
              _LocaleBadge(label: 'FR'),
              SizedBox(width: 8),
              _LocaleBadge(label: 'EN'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocaleBadge extends StatelessWidget {
  final String label;

  const _LocaleBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFF2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFB30065),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
