import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/shared/services/firebase_service.dart';
import 'package:sawalove/shared/widgets/pin_input.dart';
import '../../shared/widgets/bilingual_toggle.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String? phone;

  const OTPVerificationScreen({super.key, this.phone});

  @override
  ConsumerState<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  bool _isVerifying = false;

  void _verifyOTP(String otp) async {
    if (_isVerifying) return;
    try {
      setState(() => _isVerifying = true);
      await ref
          .read(firebaseServiceProvider)
          .verifyOTP(otp, phone: widget.phone);
      if (!mounted) return;
      context.go('/onboarding');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOTP() async {
    final phone = widget.phone;
    if (phone == null || phone.isEmpty) return;
    try {
      await ref.read(firebaseServiceProvider).signInWithPhone(phone);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(16),
            child: BilingualToggle(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text(
                'Enter the 6-digit code sent to your phone',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                widget.phone ?? '6xx xxx xxx',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 48),
              PinInput(
                onCompleted: _verifyOTP,
                onResend: _resendOTP,
                enabled: !_isVerifying,
              ),
              if (_isVerifying) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(strokeWidth: 2),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
