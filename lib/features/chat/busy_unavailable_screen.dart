import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:go_router/go_router.dart';

/// Busy/Unavailable screen - shown when recipient is on another call or has DND enabled
///
/// Specifications:
/// - Deep blue gradient background
/// - Explicit reason message
/// - Voice message recorder (60s max)
/// - No auto-route (user chooses when to leave)
class BusyUnavailableScreen extends StatefulWidget {
  final String recipientName;
  final bool isOnAnotherCall;
  final bool hasDoNotDisturb;
  final VoidCallback? onLeaveVoiceMessage;
  final VoidCallback? onBackToDiscover;

  const BusyUnavailableScreen({
    super.key,
    required this.recipientName,
    this.isOnAnotherCall = false,
    this.hasDoNotDisturb = false,
    this.onLeaveVoiceMessage,
    this.onBackToDiscover,
  });

  @override
  State<BusyUnavailableScreen> createState() => _BusyUnavailableScreenState();
}

class _BusyUnavailableScreenState extends State<BusyUnavailableScreen> {
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
    });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingSeconds++;
        });
        // Max 60 seconds
        if (_recordingSeconds >= 60) {
          _stopRecording();
        }
      }
    });
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
    });
    if (_recordingSeconds > 0) {
      widget.onLeaveVoiceMessage?.call();
      _showSentFeedback();
    }
  }

  void _showSentFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice message sent! · Message vocal envoyé !'),
        backgroundColor: Color(0xFF22C55E),
        duration: Duration(seconds: 2),
      ),
    );
    context.go('/discover');
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  String get _reasonMessage {
    if (widget.isOnAnotherCall && widget.hasDoNotDisturb) {
      return '${widget.recipientName} may be on another call or has Do Not Disturb enabled';
    } else if (widget.isOnAnotherCall) {
      return '${widget.recipientName} is on another call right now';
    } else if (widget.hasDoNotDisturb) {
      return '${widget.recipientName} has Do Not Disturb enabled';
    }
    return '${widget.recipientName} is unavailable';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1628), // Deep blue
              Color(0xFF142840),
              Color(0xFF0A1520),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: SawaLoveTheme.tertiary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.do_not_disturb_on,
                    color: SawaLoveTheme.tertiary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Reason message
                Text(
                  _reasonMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Leave a voice message and they\'ll get back to you',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(),
                
                // Voice message button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording 
                        ? SawaLoveTheme.errorColor 
                        : const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                    ),
                    label: Text(
                      _isRecording 
                        ? 'Stop (${_recordingSeconds}s)'
                        : 'Leave voice message · Message vocal',
                    ),
                  ),
                ),
                
                // Recording indicator
                if (_isRecording) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _recordingSeconds / 60,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(SawaLoveTheme.errorColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recording... $_recordingSeconds/60s',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Back to discover
                TextButton(
                  onPressed: () {
                    widget.onBackToDiscover?.call();
                    context.go('/discover');
                  },
                  child: Text(
                    'Back to discover · Retourner à la découverte',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
