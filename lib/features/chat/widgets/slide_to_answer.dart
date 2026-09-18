import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Slide-to-answer gesture widget for accept/decline actions
/// 
/// Specifications:
/// - GestureDetector with onHorizontalDragEnd
/// - Velocity threshold: 400 pixels/second
/// - Spring animation snap-back below threshold
/// - Action fires above threshold
class SlideToAnswer extends StatefulWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final String label;
  final Color acceptColor;
  final Color declineColor;
  final double trackWidth;
  final double thumbSize;
  final IconData acceptIcon;
  final IconData declineIcon;

  const SlideToAnswer({
    super.key,
    required this.onAccept,
    required this.onDecline,
    this.label = 'SLIDE TO ANSWER · GLISSER',
    this.acceptColor = const Color(0xFF22C55E),
    this.declineColor = const Color(0xFFEF4444),
    this.trackWidth = 280,
    this.thumbSize = 64,
    this.acceptIcon = Icons.call,
    this.declineIcon = Icons.call_end,
  });

  @override
  State<SlideToAnswer> createState() => _SlideToAnswerState();
}

class _SlideToAnswerState extends State<SlideToAnswer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  double _dragPosition = 0;
  bool _isDragging = false;
  
  static const double _velocityThreshold = 400;
  static const double _acceptZone = 0.6;
  static const double _declineZone = -0.6;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _positionAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _animationController.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.delta.dx;
      _dragPosition = _dragPosition.clamp(-widget.trackWidth / 2, widget.trackWidth / 2);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final normalizedPosition = _dragPosition / (widget.trackWidth / 2);
    
    if (velocity > _velocityThreshold || normalizedPosition > _acceptZone) {
      HapticFeedback.heavyImpact();
      widget.onAccept();
    } else if (velocity < -_velocityThreshold || normalizedPosition < _declineZone) {
      HapticFeedback.heavyImpact();
      widget.onDecline();
    } else {
      _snapBack();
    }
  }

  void _snapBack() {
    setState(() {
      _isDragging = false;
      _dragPosition = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final position = _isDragging ? _dragPosition : _positionAnimation.value;
    final normalizedPos = position / (widget.trackWidth / 2);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.trackWidth,
          height: widget.thumbSize + 16,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.trackWidth,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              Center(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                child: _buildThumb(widget.acceptColor, widget.acceptIcon, position > widget.trackWidth * 0.2),
              ),
              Positioned(
                left: 8,
                child: _buildThumb(widget.declineColor, widget.declineIcon, position < -widget.trackWidth * 0.2),
              ),
              GestureDetector(
                onHorizontalDragStart: _handleDragStart,
                onHorizontalDragUpdate: _handleDragUpdate,
                onHorizontalDragEnd: _handleDragEnd,
                child: Transform.translate(
                  offset: Offset(position, 0),
                  child: Container(
                    width: widget.thumbSize,
                    height: widget.thumbSize,
                    decoration: BoxDecoration(
                      color: normalizedPos > 0.2 
                        ? widget.acceptColor 
                        : normalizedPos < -0.2 
                          ? widget.declineColor 
                          : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: normalizedPos.abs() > 0.2 ? Colors.white : widget.acceptColor,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(widget.declineIcon, color: widget.declineColor, size: 16),
                  const SizedBox(width: 4),
                  Text('Decline', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  Text('Accept', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                  const SizedBox(width: 4),
                  Icon(widget.acceptIcon, color: widget.acceptColor, size: 16),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThumb(Color thumbColor, IconData thumbIcon, bool isActive) {
    return Container(
      width: widget.thumbSize - 16,
      height: widget.thumbSize - 16,
      decoration: BoxDecoration(
        color: isActive ? thumbColor : Colors.white.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(thumbIcon, color: Colors.white, size: 24),
    );
  }
}

/// Simple tap button version for quick actions row
class QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool outlined;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            border: outlined ? Border.all(color: Colors.white.withValues(alpha: 0.3)) : null,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color ?? Colors.white),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color ?? Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
