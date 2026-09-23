import 'package:flutter/material.dart';
import 'package:sawalove/core/theme/theme.dart';

/// Quick action buttons for incoming call screen
/// - Message · Texte
/// - Remind · Rappel
/// - Busy · Occupé
class CallQuickActions extends StatelessWidget {
  final VoidCallback onMessage;
  final VoidCallback onRemind;
  final VoidCallback onBusy;

  const CallQuickActions({
    super.key,
    required this.onMessage,
    required this.onRemind,
    required this.onBusy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _QuickAction(
          icon: Icons.message,
          label: 'Message · Texte',
          onTap: onMessage,
        ),
        _QuickAction(
          icon: Icons.notifications_active,
          label: 'Remind · Rappel',
          onTap: onRemind,
        ),
        _QuickAction(
          icon: Icons.do_not_disturb_on,
          label: 'Busy · Occupé',
          onTap: onBusy,
          highlighted: true,
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: highlighted 
                ? SawaLoveTheme.errorColor.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: highlighted ? SawaLoveTheme.errorColor : Colors.white70,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: highlighted ? SawaLoveTheme.errorColor : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Context badge chips for call screen
class ContextBadgeChips extends StatelessWidget {
  final bool hasSuperLiked;
  final bool isVerified;
  final String? faith;

  const ContextBadgeChips({
    super.key,
    this.hasSuperLiked = false,
    this.isVerified = false,
    this.faith,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    
    if (hasSuperLiked) {
      chips.add(const _BadgeChip(
        icon: Icons.star,
        label: 'Super Liked you',
        color: Color(0xFFFFD700),
      ));
    }
    
    if (isVerified) {
      chips.add(const _BadgeChip(
        icon: Icons.verified,
        label: 'Verified',
        color: Color(0xFF22C55E),
      ));
    }
    
    if (faith != null && faith!.isNotEmpty) {
      chips.add(_BadgeChip(
        icon: Icons.church,
        label: faith!,
        color: Colors.white70,
      ));
    }
    
    if (chips.isEmpty) return const SizedBox.shrink();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: chips,
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _BadgeChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
