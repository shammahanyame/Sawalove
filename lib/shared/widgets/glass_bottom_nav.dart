import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/shared/widgets/pressable_scale.dart';

class GlassBottomNav extends ConsumerStatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  const GlassBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  ConsumerState<GlassBottomNav> createState() => _GlassBottomNavState();
}

class _GlassBottomNavState extends ConsumerState<GlassBottomNav> {
  static const tabs = [
    {'icon': Icons.favorite_border, 'activeIcon': Icons.favorite, 'label': 'Discover'},
    {'icon': Icons.travel_explore_outlined, 'activeIcon': Icons.travel_explore, 'label': 'Explore'},
    {'icon': Icons.favorite_border, 'activeIcon': Icons.favorite, 'label': 'Likes'},
    {'icon': Icons.chat_bubble_outline, 'activeIcon': Icons.chat_bubble, 'label': 'Chats'},
    {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Static glass surface: the BackdropFilter subtree never rebuilds on tab
    // change, so the blur is not re-rendered during the active-pill animation.
    final glassDecoration = BoxDecoration(
      color: colorScheme.surface.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(48),
    );

    return Container(
      height: 80,
      decoration: glassDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(48),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final tab = tabs[index];
              final isActive = widget.currentIndex == index;
              final activeColor = colorScheme.primary;
              final inactiveColor = colorScheme.onSurfaceVariant;
              return Expanded(
                // Expanded guarantees each tab gets >= 44px of width on the
                // smallest supported screens; the inner padding gives the
                // 44px-minimum height.
                child: PressableScale(
                  onTap: () => widget.onTap(index),
                  child: Semantics(
                    button: true,
                    selected: isActive,
                    label: tab['label'] as String,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
                      alignment: Alignment.center,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        style: TextStyle(
                          color: isActive ? activeColor : inactiveColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              transitionBuilder: (child, animation) => FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(scale: animation, child: child),
                              ),
                              child: Icon(
                                isActive ? tab['activeIcon'] as IconData : tab['icon'] as IconData,
                                key: ValueKey(isActive),
                                color: isActive ? activeColor : inactiveColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(tab['label'] as String),
                          ],
                        ),
                      ),
                    ),
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
