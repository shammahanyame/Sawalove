import 'package:flutter/material.dart';

/// Missed call event bubble for chat thread
/// Displays as a special message type distinct from text messages
class MissedCallBubble extends StatelessWidget {
  final String callerName;
  final DateTime timestamp;
  final VoidCallback onCallBack;
  final bool isRead;

  const MissedCallBubble({
    super.key,
    required this.callerName,
    required this.timestamp,
    required this.onCallBack,
    this.isRead = false,
  });

  String _formatTime() {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Missed video call from $callerName at ${_formatTime()}. Double tap to call back.',
      button: true,
      child: GestureDetector(
        onTap: onCallBack,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
// Phone icon with arrow
              const Icon(
                Icons.phone_callback,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Missed video call',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Call back link
              TextButton(
                onPressed: onCallBack,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Call back',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

/// Special badge for missed call notifications in chat list
/// Distinct from unread message count - shows phone icon with down arrow
class MissedCallBadge extends StatelessWidget {
  final bool hasUnread;
  final int? count;

  const MissedCallBadge({
    super.key,
    this.hasUnread = false,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasUnread && count == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.call_missed,
            color: Colors.white,
            size: 12,
          ),
          if (count != null && count! > 0) ...[
            const SizedBox(width: 2),
            Text(
              count! > 99 ? '99+' : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
