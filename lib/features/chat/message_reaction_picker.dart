import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme.dart';

/// Emoji reaction tray shown on long-press of a chat bubble.
class MessageReactionPicker extends StatefulWidget {
  final String messageId;
  final Offset tapPosition;
  final void Function(String emoji, String messageId) onReactionSelected;

  const MessageReactionPicker({
    super.key,
    required this.messageId,
    required this.tapPosition,
    required this.onReactionSelected,
  });

  @override
  State<MessageReactionPicker> createState() => _MessageReactionPickerState();
}

class _MessageReactionPickerState extends State<MessageReactionPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int? _hoveredIndex;

  // Culturally relevant quick reactions
  static const List<String> _quickReactions = [
    '❤️', '😂', '😍', '🙏', '🔥', '😢', '👏', '🎉',
  ];

  // Full emoji grid (culturally relevant for Cameroon)
  static const List<String> _allEmojis = [
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
    '😂', '😍', '🥰', '😘', '😊', '🙂', '😎', '🤩',
    '🙏', '👏', '🤝', '✊', '👍', '👎', '🫶', '💪',
    '🔥', '✨', '🌟', '💫', '⭐', '🎉', '🎊', '🥳',
    '😢', '😭', '😤', '😡', '🤯', '😱', '🤔', '🫡',
    '🇨🇲', '🌴', '🌅', '🎺', '🕺', '💃', '🍛', '🌶️',
  ];

  bool _showFullPicker = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectReaction(String emoji) {
    HapticFeedback.mediumImpact();
    widget.onReactionSelected(emoji, widget.messageId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.black54,
        child: Stack(
          children: [
            // Dismiss tap area
            Positioned.fill(
              child: GestureDetector(onTap: () => Navigator.of(context).pop()),
            ),
            // Reaction tray
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 80,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_showFullPicker) _buildFullPicker(),
                      _buildQuickReactions(),
                      const SizedBox(height: 8),
                      _buildContextMenu(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReactions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ..._quickReactions.asMap().entries.map((entry) {
            final index = entry.key;
            final emoji = entry.value;
            final isHovered = _hoveredIndex == index;
            return GestureDetector(
              onTap: () => _selectReaction(emoji),
              onTapDown: (_) => setState(() => _hoveredIndex = index),
              onTapUp: (_) => setState(() => _hoveredIndex = null),
              onTapCancel: () => setState(() => _hoveredIndex = null),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 150),
                scale: isHovered ? 1.4 : 1.0,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 150),
                  offset: Offset(0, isHovered ? -0.2 : 0),
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: isHovered ? 32 : 28),
                  ),
                ),
              ),
            );
          }),
          // More button
          GestureDetector(
            onTap: () => setState(() => _showFullPicker = !_showFullPicker),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _showFullPicker
                    ? SawaLoveTheme.primary.withValues(alpha: 0.15)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showFullPicker ? Icons.expand_more : Icons.add,
                size: 22,
                color: _showFullPicker ? SawaLoveTheme.primary : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullPicker() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'All Reactions',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: SawaLoveTheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: _allEmojis.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _selectReaction(_allEmojis[index]),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      _allEmojis[index],
                      style: const TextStyle(fontSize: 22),
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

  Widget _buildContextMenu() {
    final actions = [
      _ContextAction(icon: Icons.reply, label: 'Reply', onTap: () => Navigator.of(context).pop('reply')),
      _ContextAction(icon: Icons.copy, label: 'Copy', onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop('copy');
      }),
      _ContextAction(icon: Icons.forward, label: 'Forward', onTap: () => Navigator.of(context).pop('forward')),
      _ContextAction(icon: Icons.delete_outline, label: 'Delete', isDestructive: true, onTap: () => Navigator.of(context).pop('delete')),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(
                  action.icon,
                  color: action.isDestructive ? Colors.red : SawaLoveTheme.onSurface,
                  size: 22,
                ),
                title: Text(
                  action.label,
                  style: TextStyle(
                    color: action.isDestructive ? Colors.red : SawaLoveTheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: action.onTap,
                dense: true,
              ),
              if (index < actions.length - 1)
                Divider(height: 1, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ContextAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ContextAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// Helper to show the reaction picker as a modal
Future<String?> showMessageReactionPicker({
  required BuildContext context,
  required String messageId,
  required Offset tapPosition,
  required void Function(String emoji, String messageId) onReactionSelected,
}) {
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return MessageReactionPicker(
        messageId: messageId,
        tapPosition: tapPosition,
        onReactionSelected: onReactionSelected,
      );
    },
  );
}
