import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/core/theme/theme.dart';
import '../providers/voice_player_provider.dart';
import '../../../shared/models/voice_message.dart';

class SafetyFlaggedCard extends ConsumerWidget {
  final VoiceMessage message;
  const SafetyFlaggedCard({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
          const SizedBox(height: 8),
          Text(
            'Safety notice · Avertissement sécurité',
            style: SawaLoveTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          Text(
            'This voice note may contain personal contact information (phone number detected). · Ce message vocal pourrait contenir des informations de contact personnelles.',
            style: SawaLoveTheme.bodyMedium?.copyWith(color: SawaLoveTheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Listen anyway · Écouter quand même'),
                  onPressed: () {
                    // Play normally
                    ref.read(voicePlayerProvider(message.id).notifier).play(message.audioUrl);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: SawaLoveTheme.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Soft-delete from view (local state or mark read)
                  },
                  child: const Text('Dismiss · Ignorer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

