import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PinInput extends StatefulWidget {
  final Function(String) onCompleted;
  final Function() onResend;
  final TextEditingController? controller;
  final int length;
  final bool showResendRow;
  final int resendSeconds;
  final String? errorText;
  final bool enabled;

  const PinInput({
    super.key,
    required this.onCompleted,
    required this.onResend,
    this.controller,
    this.length = 6,
    this.showResendRow = true,
    this.resendSeconds = 59,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput> {
  TextEditingController? _ownController;
  final FocusNode _focusNode = FocusNode();
  Timer? _timer;
  int _secondsLeft = 0;

  TextEditingController get _effectiveController =>
      widget.controller ?? (_ownController ??= TextEditingController());

  bool get _canResend => _secondsLeft <= 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    // Only dispose the controller when this widget owns it.
    _ownController?.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = widget.resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _resend() {
    // Clear any previously entered code so the field is ready for the new one.
    _effectiveController.clear();
    widget.onResend();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        color: theme.colorScheme.surfaceContainerLowest,
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: errorColor, width: 1.5),
      ),
    );

    return Column(
      children: [
        Pinput(
          controller: _effectiveController,
          focusNode: _focusNode,
          length: widget.length,
          enabled: widget.enabled,
          autofocus: true,
          keyboardType: TextInputType.number,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: defaultPinTheme.copyWith(
            decoration: defaultPinTheme.decoration!.copyWith(
              border: Border.all(color: theme.colorScheme.primary, width: 1.5),
            ),
          ),
          submittedPinTheme: defaultPinTheme.copyWith(
            decoration: defaultPinTheme.decoration!.copyWith(
              border: Border.all(color: theme.colorScheme.primary),
            ),
          ),
          errorPinTheme: errorPinTheme,
          // Show the error state on the boxes themselves when provided.
          forceErrorState: widget.errorText != null,
          onCompleted: widget.enabled ? widget.onCompleted : null,
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(color: errorColor),
          ),
        ],
        if (widget.showResendRow) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _canResend ? _resend : null,
                child: const Text('Resend OTP'),
              ),
              Text(
                _canResend
                    ? 'available'
                    : 'in 00:${_secondsLeft.toString().padLeft(2, '0')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
