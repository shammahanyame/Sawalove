import 'package:flutter/material.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/shared/services/firebase_service.dart';
import 'package:sawalove/shared/widgets/pin_input.dart';

class ResetPinFlowScreen extends ConsumerWidget {
  const ResetPinFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ResetPinFlow();
  }
}

class ResetPinFlow extends ConsumerStatefulWidget {
  const ResetPinFlow({super.key});

  @override
  ConsumerState<ResetPinFlow> createState() => _ResetPinFlowState();
}

class _ResetPinFlowState extends ConsumerState<ResetPinFlow> {
  final _pinController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasError = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submitPin(String pin) async {
    if (_isSubmitting) return;
    // Mirror the server-side policy so users get instant feedback.
    if (pin.length < 4 || pin.length > 8) return;
    if (RegExp(r'^(\d)\1+$').hasMatch(pin) ||
        RegExp(r'^(?:0123|1234|2345|3456|4567|5678|6789|9876|8765|7654|6543|5432|4321|3210)')
            .hasMatch(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a PIN that is not repeated or sequential.')),
      );
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
        _hasError = false;
      });
      // The raw PIN is sent over TLS; the backend hashes it with
      // password_hash() before storing (never store unsalted hashes).
      await ref.read(firebaseServiceProvider).savePin(pin);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN updated successfully.')),
      );
      context.go('/home/profile');
    } catch (e) {
      if (!mounted) return;
      setState(() => _hasError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set your PIN')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text(
                'Create a transaction PIN',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Used to confirm sensitive actions. 4 to 8 digits.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 48),
              PinInput(
                controller: _pinController,
                length: 6,
                onCompleted: _submitPin,
                onResend: () {},
                showResendRow: false,
                errorText: _hasError ? 'Could not save PIN. Try again.' : null,
              ),
              if (_isSubmitting) ...[
                const SizedBox(height: 24),
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

class CustomNumpad extends StatelessWidget {
  final Function(int) onDigit;
  final VoidCallback onDelete;
  final bool showStrength;

  const CustomNumpad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.showStrength = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            if (index < 9) {
              return _NumpadKey(
                label: '${index + 1}',
                onTap: () => onDigit(index + 1),
              );
            } else if (index == 9) {
              return _NumpadKey(
                label: '0',
                onTap: () => onDigit(0),
              );
            } else {
              return _DeleteKey(onDelete: onDelete);
            }
          },
        ),
        if (showStrength) const PinStrengthMeter(),
      ],
    );
  }
}

class _NumpadKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NumpadKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => HapticFeedback.selectionClick(),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: SawaLoveTheme.surfaceContainerLow,
        ),
        child: Center(
          child: Semantics(
            label: label,
            button: true,
            child: Text(
              label,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteKey extends StatelessWidget {
  final VoidCallback onDelete;

  const _DeleteKey({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDelete,
      onLongPress: () {
        // Clear all
      },
      child: Semantics(
        label: 'Delete last digit',
        button: true,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: SawaLoveTheme.surfaceContainerLow,
          ),
          child: const Icon(Icons.backspace_outlined, color: SawaLoveTheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class PinStrengthMeter extends StatelessWidget {
  const PinStrengthMeter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _StrengthSegment(color: SawaLoveTheme.errorColor, label: 'Weak'),
        _StrengthSegment(color: SawaLoveTheme.warning, label: 'Fair'),
        _StrengthSegment(color: SawaLoveTheme.success, label: 'Strong'),
      ],
    );
  }
}

class _StrengthSegment extends StatelessWidget {
  final Color color;
  final String label;

  const _StrengthSegment({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: '$label PIN strength',
        child: Row(
          children: [
            Container(
              width: 20,
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

