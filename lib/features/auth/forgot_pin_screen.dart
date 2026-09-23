import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import 'dart:async';

enum PinStrength {
  weak,
  fair,
  strong,
}

class ForgotPinScreen extends StatefulWidget {
  const ForgotPinScreen({super.key});

  @override
  State<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends State<ForgotPinScreen>
    with TickerProviderStateMixin {
  int _currentStep = 1;
  final String _maskedPhone = '+237 6XX XXX X89';
  final List<String> _otpDigits = List.filled(6, '');
  List<int> _newPinDigits = List.filled(6, -1);
  List<int> _confirmPinDigits = List.filled(6, -1);
  int _timerSeconds = 30;
  int _otpAttempts = 0;
  Timer? _timer;
  late AnimationController _stepController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _stepController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_stepController);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stepController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  PinStrength _evaluatePinStrength(List<int> digits) {
    final s = digits.where((d) => d != -1).join();
    if (s.isEmpty) return PinStrength.weak;
    if (s.split('').toSet().length == 1) return PinStrength.weak;
    final sequentialPattern =
        RegExp(r'012345|123456|234567|345678|456789|987654|876543');
    if (sequentialPattern.hasMatch(s)) return PinStrength.weak;
    if (digits.where((d) => d != -1).length < 4) return PinStrength.weak;
    if (digits.where((d) => d != -1).length < 6) return PinStrength.fair;
    return PinStrength.strong;
  }

  String _getStrengthLabel(PinStrength strength) {
    switch (strength) {
      case PinStrength.weak:
        return 'WEAK';
      case PinStrength.fair:
        return 'FAIR';
      case PinStrength.strong:
        return 'STRONG';
    }
  }

  void _sendOtp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent! Check your SMS.')),
    );
    setState(() {
      _timerSeconds = 30;
      _startTimer();
    });
    _stepController.forward().then((_) {
      _stepController.reverse();
      setState(() => _currentStep = 2);
    });
  }

  void _verifyOtp() {
    if (_otpDigits.every((d) => d.isNotEmpty)) {
      setState(() => _currentStep = 3);
    } else {
      setState(() => _otpAttempts++);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter full code')),
      );
    }
  }

  void _clearPins() {
    setState(() {
      _newPinDigits = List.filled(6, -1);
      _confirmPinDigits = List.filled(6, -1);
    });
  }

  void _nextToConfirm() {
    final strength = _evaluatePinStrength(_newPinDigits);
    if (strength == PinStrength.weak) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a stronger PIN')),
      );
      return;
    }
    setState(() => _currentStep = 4);
  }

  void _completeReset() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN reset successful!')),
    );
    context.go('/login');
  }

  Widget _buildOtpBox(int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _setOtpFocus(index),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            border: Border.all(color: SawaLoveTheme.outlineVariant),
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              _otpDigits[index],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void _setOtpFocus(int index) {
    setState(() {
      if (index < 6 && _otpDigits[index].isNotEmpty) {
        _otpDigits[index + 1] = '';
      }
    });
  }

  Widget _buildPinDot(int index, List<int> pins) {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: SawaLoveTheme.onSurfaceVariant,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildNumpad(bool isConfirm) {
    final pins = isConfirm ? _confirmPinDigits : _newPinDigits;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => _buildPinDot(index, pins)),
        ),
        const SizedBox(height: 32),
        if (!isConfirm) ...[
          _buildStrengthMeter(),
          const SizedBox(height: 24),
        ],
        if (isConfirm &&
            _newPinDigits.join() != pins.where((d) => d != -1).join())
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SawaLoveTheme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.error, color: SawaLoveTheme.errorColor),
                SizedBox(width: 8),
                Text('PINs do not match', style: TextStyle(color: SawaLoveTheme.errorColor)),
              ],
            ),
          ),
        const SizedBox(height: 32),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 12,
          itemBuilder: (context, i) {
            if (i == 9) return _buildDeleteKey();
            if (i == 11) return _buildZeroKey();
            return _buildNumberKey(i + 1, pins, isConfirm);
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              final filled = pins.where((d) => d != -1).length;
              if (filled == 6) {
                if (isConfirm) {
                  if (_newPinDigits.join() == pins.join()) {
                    _completeReset();
                  } else {
                    _clearPins();
                  }
                } else {
                  _nextToConfirm();
                }
              }
            },
            child: Text(isConfirm ? 'Confirm PIN' : 'Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthMeter() {
    final strength = _evaluatePinStrength(_newPinDigits);
    return Column(
      children: [
        LinearProgressIndicator(
          value: _newPinDigits.where((d) => d != -1).length / 6,
          backgroundColor: SawaLoveTheme.outlineVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            strength == PinStrength.strong
                ? SawaLoveTheme.success
                : strength == PinStrength.fair
                    ? SawaLoveTheme.warning
                    : SawaLoveTheme.errorColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _newPinDigits.where((d) => d != -1).length < 2
              ? ''
              : _getStrengthLabel(strength),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildNumberKey(int number, List<int> pins, bool isConfirm) {
    return GestureDetector(
      onTapDown: (_) => HapticFeedback.lightImpact(),
      onTap: () {
        final index = pins.indexWhere((d) => d == -1);
        if (index != -1) {
          setState(() => pins[index] = number);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            '$number',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return GestureDetector(
      onTap: () {
        final index = _newPinDigits.indexWhere((d) => d != -1);
        if (index != -1) {
          setState(() => _newPinDigits[index] = -1);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.backspace, color: SawaLoveTheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildZeroKey() {
    return GestureDetector(
      onTap: () {
        final index = _newPinDigits.indexWhere((d) => d == -1);
        if (index == 0 || index != -1) {
          setState(() => _newPinDigits[index] = 0);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('0', style: TextStyle(fontSize: 32))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset PIN'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStepPill(1, 'Phone'),
                  _buildStepPill(2, 'Code'),
                  _buildStepPill(3, 'New PIN'),
                  _buildStepPill(4, 'Confirm'),
                  _buildStepPill(5, 'Done'),
                ],
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: IndexedStack(
                    index: _currentStep - 1,
                    children: [
                      _buildPhoneStep(),
                      _buildOtpStep(),
                      _buildNumpad(false),
                      _buildNumpad(true),
                      _buildSuccessStep(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepPill(int step, String label) {
    final isActive = _currentStep == step;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? SawaLoveTheme.primary : SawaLoveTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? SawaLoveTheme.onPrimary : SawaLoveTheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.phone_iphone, size: 80, color: SawaLoveTheme.onSurfaceVariant),
        const SizedBox(height: 32),
        Text('Confirm your number',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(_maskedPhone, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SawaLoveTheme.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: SawaLoveTheme.warning),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ne partagez jamais ce code / Never share this code',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _sendOtp,
            child: const Text('Send verification code'),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Enter verification code',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Code sent to $_maskedPhone',
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => _buildOtpBox(index)),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Resend in $_timerSeconds'),
            if (_timerSeconds == 0) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendOtp,
                child: const Text('Resend code',
                    style: TextStyle(
                        color: SawaLoveTheme.tertiary, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _verifyOtp,
            child: const Text('Verify Code'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            color: SawaLoveTheme.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 64, color: Colors.white),
        ),
        const SizedBox(height: 32),
        const Text('PIN Reset Complete',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Your new PIN is active. Log in to continue.'),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Go to Login'),
          ),
        ),
      ],
    );
  }
}
