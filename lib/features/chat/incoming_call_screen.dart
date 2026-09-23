import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import 'models/incoming_call_data.dart';
import 'widgets/pulsing_ring.dart';
import 'widgets/slide_to_answer.dart';
import 'widgets/call_quick_actions.dart';

class IncomingCallScreen extends StatefulWidget {
  final IncomingCallData? callData;

  const IncomingCallScreen({
    super.key,
    this.callData,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  Timer? _ringingTimer;
  Timer? _autoDismissTimer;
  late IncomingCallData _callData;

  // Brand gradient colors
  static const List<Color> _brandGradient = [
    Color(0xFF4A0028),
    Color(0xFFB30065),
    Color(0xFF8329C8),
  ];

  @override
  void initState() {
    super.initState();
    _callData = widget.callData ?? IncomingCallData.demo();
    _startAutoDismissTimer();
  }

  void _startAutoDismissTimer() {
    _autoDismissTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        // Auto-dismiss after 30 seconds - treat as missed
        context.go('/chat');
      }
    });
  }

  @override
  void dispose() {
    _ringingTimer?.cancel();
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  void _onAccept() {
    _autoDismissTimer?.cancel();
    // Navigate to video call
    context.go('/chat/video-call', extra: _callData.matchId);
  }

  void _onDecline() {
    _autoDismissTimer?.cancel();
    // Navigate to declined screen
    context.go('/chat/call-declined', extra: _callData);
  }

  void _onMessage() {
    // Silently decline and send message
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.go('/chat/${_callData.matchId}');
      }
    });
  }

  void _onRemind() {
    _autoDismissTimer?.cancel();
    // Schedule reminder for 10 minutes
    // Would implement local notification here
    context.go('/chat');
  }

  void _onBusy() {
    _autoDismissTimer?.cancel();
    // Send unavailable signal to caller
    context.go('/chat/call-busy', extra: _callData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _brandGradient,
          ),
        ),
        child: SafeArea(
          child: Semantics(
            label: 'Incoming video call from ${_callData.callerName}. ${_callData.faith ?? ""}',
            liveRegion: true,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 60),
                // Avatar with pulsing rings
                const Stack(
                  alignment: Alignment.center,
                  children: [
                    PulsingRing(size: 96, ringColor: Colors.white),
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white, size: 48),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Caller name
                Text(
                  _callData.callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                // Incoming call label
                Text(
                  'Incoming video call...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                // Context badges
                ContextBadgeChips(
                  hasSuperLiked: _callData.superLikedYou,
                  isVerified: _callData.isVerified,
                  faith: _callData.faith,
                ),
                const Spacer(),
                // Slide to answer/decline
                SlideToAnswer(
                  onAccept: _onAccept,
                  onDecline: _onDecline,
                ),
                const SizedBox(height: 32),
                // Quick actions
                CallQuickActions(
                  onMessage: _onMessage,
                  onRemind: _onRemind,
                  onBusy: _onBusy,
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Declined call screen - shown to caller when recipient declines
class DeclinedCallScreen extends StatefulWidget {
  final IncomingCallData? callData;

  const DeclinedCallScreen({
    super.key,
    this.callData,
  });

  @override
  State<DeclinedCallScreen> createState() => _DeclinedCallScreenState();
}

class _DeclinedCallScreenState extends State<DeclinedCallScreen> {
  Timer? _autoDismissTimer;
  late IncomingCallData _callData;

  @override
  void initState() {
    super.initState();
    _callData = widget.callData ?? IncomingCallData.demo();
    _startAutoDismissTimer();
  }

  void _startAutoDismissTimer() {
    // Auto-route after 8 seconds
    _autoDismissTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        context.go('/chat');
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  void _onQuickMessage() {
    _autoDismissTimer?.cancel();
    // Send quick message and navigate to chat
    context.go('/chat/${_callData.matchId}');
  }

  void _onManualMessage() {
    _autoDismissTimer?.cancel();
    // Navigate to chat for manual message
    context.go('/chat/${_callData.matchId}');
  }

  void _onBackToDiscover() {
    _autoDismissTimer?.cancel();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A0B1D),
              const Color(0xFF4A1028).withValues(alpha: 0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.person_remove,
                size: 80,
                color: SawaLoveTheme.errorColor,
              ),
              const SizedBox(height: 24),
              Text(
                '${_callData.callerName} declined',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'They\'re not available right now',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              // Quick message CTA
              ElevatedButton.icon(
                onPressed: _onQuickMessage,
                icon: const Icon(Icons.message),
                label: const Text(
                  'Maybe later? Chat soon! · Peut-être plus tard ? À bientôt !',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SawaLoveTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Manual message option
              TextButton(
                onPressed: _onManualMessage,
                child: Text(
                  'Send a message instead',
                  style: TextStyle(
                    color: SawaLoveTheme.primary.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Back to discover
              TextButton(
                onPressed: _onBackToDiscover,
                child: Text(
                  'Back to discover',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Busy/Unavailable screen - shown when recipient is busy
class BusyUnavailableScreen extends StatefulWidget {
  final IncomingCallData? callData;
  final String? reason;

  const BusyUnavailableScreen({
    super.key,
    this.callData,
    this.reason,
  });

  @override
  State<BusyUnavailableScreen> createState() => _BusyUnavailableScreenState();
}

class _BusyUnavailableScreenState extends State<BusyUnavailableScreen> {
  late IncomingCallData _callData;

  @override
  void initState() {
    super.initState();
    _callData = widget.callData ?? IncomingCallData.demo();
  }

  void _onLeaveVoiceMessage() {
    // Would open voice recorder
    // Navigate to voice message screen
    context.go('/chat/${_callData.matchId}/voice-message');
  }

  void _onBackToDiscover() {
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final reasonText = widget.reason ??
        'She may be on another call or has Do Not Disturb enabled';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1929),
              Color(0xFF1A3A5C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
const Icon(
                Icons.call_missed,
                size: 80,
                color: SawaLoveTheme.tertiary,
              ),
              const SizedBox(height: 24),
              Text(
                'Can\'t reach ${_callData.callerName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  reasonText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              // Leave voice message button
              ElevatedButton.icon(
                onPressed: _onLeaveVoiceMessage,
                icon: const Icon(Icons.mic),
                label: const Text(
                  'Leave voice message · Message vocal',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SawaLoveTheme.tertiary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Back to discover
              TextButton(
                onPressed: _onBackToDiscover,
                child: Text(
                  'Back to discover',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
