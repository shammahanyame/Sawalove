import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlassBottomNav extends ConsumerStatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  const GlassBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  ConsumerState<GlassBottomNav> createState() => _GlassBottomNavState();
}

class _GlassBottomNavState extends ConsumerState<GlassBottomNav> {
  static const tabs = [
    {'icon': Icons.favorite, 'label': 'Discover'},
    {'icon': Icons.travel_explore, 'label': 'Explore'},
    {'icon': Icons.favorite_border, 'label': 'Likes'},
    {'icon': Icons.chat_bubble, 'label': 'Chats'},
    {'icon': Icons.person, 'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(48),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(48),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(tabs.length, (index) {
              final tab = tabs[index];
              final isActive = widget.currentIndex == index;
              return GestureDetector(
                onTap: () => widget.onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: isActive ? BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ) : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tab['icon'] as IconData, color: isActive ? Colors.white : colorScheme.onSurfaceVariant),
                      Text(
                        tab['label'] as String,
                        style: TextStyle(
                          color: isActive ? Colors.white : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// Usage in ShellRoute builder

