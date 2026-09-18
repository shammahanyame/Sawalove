import 'package:flutter/material.dart';

/// Animated pulsing ring around caller avatar during incoming call
/// 
/// Specifications:
/// - Three rings staggered with 600ms offsets
/// - Scale from 1.0 to 1.54
/// - Fade from 0.3 opacity to 0 opacity
/// - Duration: 1.8 seconds
/// - Continuous ripple effect
class PulsingRing extends StatefulWidget {
  final double size;
  final Color ringColor;
  final int ringCount;
  final Duration staggerDelay;
  final Duration animationDuration;

  const PulsingRing({
    super.key,
    this.size = 96.0,
    this.ringColor = const Color(0xFFB30065),
    this.ringCount = 3,
    this.staggerDelay = const Duration(milliseconds: 600),
    this.animationDuration = const Duration(milliseconds: 1800),
  });

  @override
  State<PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<PulsingRing> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = [];
    _scaleAnimations = [];
    _fadeAnimations = [];

    for (int i = 0; i < widget.ringCount; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
      );
      
      final scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 1.54,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));

      final fadeAnimation = Tween<double>(
        begin: 0.3,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));

      _controllers.add(controller);
      _scaleAnimations.add(scaleAnimation);
      _fadeAnimations.add(fadeAnimation);

      Future.delayed(widget.staggerDelay * i, () {
        if (mounted) {
          controller.repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.8,
      height: widget.size * 1.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < widget.ringCount; i++)
            AnimatedBuilder(
              animation: _controllers[i],
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimations[i].value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.ringColor.withValues(alpha: 
                          _fadeAnimations[i].value,
                        ),
                        width: 3,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Static ring widget for use when animations are not needed
class StaticPulsingRing extends StatelessWidget {
  final double size;
  final double scale;
  final double opacity;
  final Color ringColor;

  const StaticPulsingRing({
    super.key,
    this.size = 96.0,
    this.scale = 1.0,
    this.opacity = 0.3,
    this.ringColor = const Color(0xFFB30065),
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: ringColor.withValues(alpha: opacity),
            width: 3,
          ),
        ),
      ),
    );
  }
}

/// View transition animations per spec
class CallViewTransitions {
  static const Duration duration = Duration(milliseconds: 250);
  static const Curve timingFunction = Curves.easeOutCubic;
  
  static const String viewTransitionName = 'callTransition';
}

/// Brand gradient for incoming call screen
class CallBrandGradient {
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4A0028),
      Color(0xFFB30065),
      Color(0xFF8329C8),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient declined = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A0B0F),
      Color(0xFF2D0F14),
    ],
  );
  
  static const LinearGradient busy = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A1628),
      Color(0xFF142840),
    ],
  );
}
