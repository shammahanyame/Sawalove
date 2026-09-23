import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:go_router/go_router.dart';

/// Declined call screen - shown when recipient declines
///
/// Specifications:
/// - Dark crimson tinted background
/// - Gentle language: "Amaka declined" (not "rejected")
/// - Quick message CTA
/// - Manual message option
/// - Auto-routes after 8 seconds
class DeclinedCallScreen extends StatefulWidget {
  final String callerName;
  final VoidCallback? onQuickMessage;
  final VoidCallback? onManualMessage;
  final VoidCallback? onBackToDiscover;

  const DeclinedCallScreen({
    super.key,
    required this.callerName,
    this.onQuickMessage,
    this.onManualMessage,
    this.onBackToDiscover,
  });

  @override
  State<DeclinedCallScreen> createState() => _DeclinedCallScreenState();
}

class _DeclinedCallScreenState extends State<DeclinedCallScreen> {
  Timer? _autoRouteTimer;

  @override
  void initState() {
    super.initState();
    // Auto-route after 8 seconds
    _autoRouteTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        widget.onBackToDiscover?.call();
        context.go('/discover');
      }
    });
  }

  @override
  void dispose() {
    _autoRouteTimer?.cancel();
    super.dispose();
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
              Color(0xFF1A0B0F), // Dark with crimson
              Color(0xFF2D0F14),
              Color(0xFF0A0608),
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
                    color: SawaLoveTheme.errorColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.call_end,
                    color: SawaLoveTheme.errorColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Message - gentle language
                Text(
                  '${widget.callerName} declined',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "They're not available right now",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
                
                const Spacer(),
                
                // Quick message CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _autoRouteTimer?.cancel();
                      widget.onQuickMessage?.call();
                      context.go('/matches');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB30065),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.message),
                    label: const Text(
                      'Maybe later? Chat soon! · Peut-être plus tard ? À bientôt !',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Manual message option
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _autoRouteTimer?.cancel();
                      widget.onManualMessage?.call();
                      context.go('/matches');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('Send a message · Envoyer un message'),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Back to discover link
                TextButton(
                  onPressed: () {
                    _autoRouteTimer?.cancel();
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
