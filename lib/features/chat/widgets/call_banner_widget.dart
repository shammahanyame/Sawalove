import 'package:flutter/material.dart';
import 'package:sawalove/core/theme/theme.dart';

/// Banner widget for incoming call when app is in foreground
/// 
/// Specifications:
/// - 64dp tall
/// - Slides down from top with SlideTransition (350ms, easeOutCubic)
/// - Contains: avatar, name, call type, accept/decline buttons
/// - Auto-dismiss after 30 seconds
class CallBannerWidget extends StatefulWidget {
  final String callerName;
  final String? callerAvatar;
  final String callType;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback? onDismiss;

  const CallBannerWidget({
    super.key,
    required this.callerName,
    this.callerAvatar,
    this.callType = 'Incoming video call',
    required this.onAccept,
    required this.onDecline,
    this.onDismiss,
  });

  @override
  State<CallBannerWidget> createState() => _CallBannerWidgetState();
}

class _CallBannerWidgetState extends State<CallBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 8;
    
    return SlideTransition(
      position: _slideAnimation,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: Container(
          height: 64,
          padding: EdgeInsets.only(top: topPadding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4A0028),
                Color(0xFFB30065),
                Color(0xFF8329C8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundImage: widget.callerAvatar != null
                    ? NetworkImage(widget.callerAvatar!)
                    : null,
                  backgroundColor: Colors.white24,
                  child: widget.callerAvatar == null
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
                ),
                const SizedBox(width: 12),
                
                // Name and call type
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.callerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.callType,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Decline button
                _BannerButton(
                  icon: Icons.call_end,
                  color: SawaLoveTheme.errorColor,
                  onTap: () {
                    _dismiss();
                    widget.onDecline();
                  },
                ),
                const SizedBox(width: 12),
                
                // Accept button
                _BannerButton(
                  icon: Icons.call,
                  color: const Color(0xFF22C55E),
                  onTap: () {
                    _dismiss();
                    widget.onAccept();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BannerButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
