import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MatchSuccessScreen extends StatelessWidget {
  final String matchId;
  const MatchSuccessScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEFF6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite, size: 96, color: Color(0xFFB30065)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  const Text(
                    "It's a Match! ✨",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Say hello and start chatting!",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.go('/chat/$matchId'),
                      child: const Text('Send Message'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Keep Swiping'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

