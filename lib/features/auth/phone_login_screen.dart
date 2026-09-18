import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/shared/widgets/bilingual_toggle.dart';
import 'package:sawalove/shared/services/firebase_service.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final phoneController = TextEditingController();
  bool _isSending = false;
  String? _socialProvider;
  StreamSubscription<User?>? _authSubscription;
  bool _handledSignedIn = false;
  bool _phoneAuthUnavailable = false;

  bool get _isPhoneValid =>
      phoneController.text.replaceAll(' ', '').length == 9;
  bool get _isBusy => _isSending || _socialProvider != null;

  @override
  void initState() {
    super.initState();
    phoneController.addListener(_onPhoneChanged);
    final authService = ref.read(firebaseServiceProvider);
    if (authService.isConfigured) {
      _authSubscription = authService.authStateChanges.listen(_handleSignedIn);
    }
  }

  void _onPhoneChanged() => setState(() {});

  void _handleSignedIn(User? user) {
    if (user == null || _handledSignedIn) return;
    _handledSignedIn = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    phoneController
      ..removeListener(_onPhoneChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_isPhoneValid || _isBusy) return;
    final phone = '+237${phoneController.text.replaceAll(' ', '')}';
    try {
      setState(() => _isSending = true);
      await ref.read(firebaseServiceProvider).signInWithPhone(phone);
      if (!mounted) return;
      context.push('/login/otp', extra: phone);
    } catch (e) {
      if (!mounted) return;
      if (isPhoneProviderDisabledAuthError(e)) {
        setState(() => _phoneAuthUnavailable = true);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _startSocialSignIn(
    String provider,
    Future<bool> Function() signIn,
  ) async {
    if (_isBusy) return;
    try {
      setState(() => _socialProvider = provider);
      await signIn();
      if (!mounted) return;

      final authService = ref.read(firebaseServiceProvider);
      if (!authService.isConfigured || authService.isSignedIn) {
        context.go('/onboarding');
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complete $provider sign-in in your browser.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _socialProvider = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAvailability = ref.watch(authProviderAvailabilityProvider);
    final availability = authAvailability.asData?.value;
    final isCheckingAvailability =
        authAvailability.isLoading && availability == null;
    final phoneAuthAvailable = !_phoneAuthUnavailable &&
        (availability?.phone ?? supabasePhoneAuthEnabled);
    final emailAuthAvailable = availability?.email ?? supabaseEmailAuthEnabled;
    final googleAuthAvailable =
        availability?.google ?? supabaseGoogleAuthEnabled;
    final appleAuthAvailable = availability?.apple ?? supabaseAppleAuthEnabled;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Bilingual Toggle
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BilingualToggle(),
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Logo
                    Image.asset(
                      'assets/branding/sawalove_horizontal_lockup.png',
                      height: 92,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Radiant connections, modern souls.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 48),
                    // Phone Input Card
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.06),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Welcome back',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your phone number to continue your journey.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          if (!phoneAuthAvailable) ...[
                            const SizedBox(height: 20),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onErrorContainer,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Phone sign-in is temporarily unavailable. Use email to continue.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onErrorContainer,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          // Country + Phone Input
                          Row(
                            children: [
                              // Cameroon Flag +237
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.flag_circle,
                                        color: Colors.green,
                                        size: 24), // Cameroon flag placeholder
                                    SizedBox(width: 8),
                                    Text('+237',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Icon(Icons.keyboard_arrow_down, size: 20),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(9),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: '6xx xxx xxx',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 24),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isPhoneValid &&
                                      !_isBusy &&
                                      phoneAuthAvailable
                                  ? _sendOTP
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                disabledBackgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                disabledForegroundColor: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28)),
                                elevation: 8,
                              ),
                              child: _isSending || isCheckingAvailability
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : Text(
                                      phoneAuthAvailable
                                          ? 'Continue'
                                          : 'Phone unavailable',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // OR Divider
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      height: 1,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Container(
                                      height: 1,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Social Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isBusy || !googleAuthAvailable
                                      ? null
                                      : () => _startSocialSignIn(
                                            'Google',
                                            () => ref
                                                .read(firebaseServiceProvider)
                                                .signInWithGoogle(),
                                          ),
                                  icon: _socialProvider == 'Google'
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(Icons.g_mobiledata,
                                          color: Colors.grey[700], size: 20),
                                  label: const Text('Google'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(28)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isBusy || !appleAuthAvailable
                                      ? null
                                      : () => _startSocialSignIn(
                                            'Apple',
                                            () => ref
                                                .read(firebaseServiceProvider)
                                                .signInWithApple(),
                                          ),
                                  icon: _socialProvider == 'Apple'
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.apple),
                                  label: const Text('Apple'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(28)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _isBusy || !emailAuthAvailable
                                ? null
                                : () => context.push('/login/email'),
                            icon: const Icon(Icons.email_outlined),
                            label: Text(emailAuthAvailable
                                ? 'Use email instead'
                                : 'Email unavailable'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Trust Badge
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[300],
                          ), // Profile placeholder
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue[300],
                          ), // Profile placeholder
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '+10k',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trusted by thousands in Cameroon',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.verified,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Secure & Private',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Footer Terms (tappable — required by Play policy)
            Padding(
              padding: const EdgeInsets.all(24),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  children: [
                    const TextSpan(text: 'By continuing, you agree to our '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: () => context.push('/profile/terms'),
                        child: Text(
                          'Terms of Service',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: () => context.push('/profile/privacy-policy'),
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
