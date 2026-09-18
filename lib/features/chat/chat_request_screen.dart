import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';

class ChatRequestScreen extends StatelessWidget {
  const ChatRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SawaLoveTheme.surface,
      appBar: AppBar(
        title: const Text('Chat Request'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Profile
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [SawaLoveTheme.primary.withValues(alpha: 0.05), SawaLoveTheme.primaryContainer.withValues(alpha: 0.05)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150'),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Grace M.',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Wants to chat with you!',
                      style: TextStyle(color: SawaLoveTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Profile info
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_city, color: SawaLoveTheme.tertiary),
                          SizedBox(width: 8),
                          Text('Douala, Littoral'),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.church, color: SawaLoveTheme.secondary),
                          SizedBox(width: 8),
                          Text('Pentecostal'),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.favorite, color: SawaLoveTheme.primary),
                          SizedBox(width: 8),
                          Text('Looking for marriage'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // CTAs
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/chat/1'),
                      icon: const Icon(Icons.chat),
                      label: const Text('Accept Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SawaLoveTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close),
                      label: const Text('Decline'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: SawaLoveTheme.outlineVariant),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

