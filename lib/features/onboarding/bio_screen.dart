import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/services/backend_service.dart';

class BioScreen extends ConsumerStatefulWidget {
  const BioScreen({super.key});

  @override
  ConsumerState<BioScreen> createState() => _BioScreenState();
}

class _BioScreenState extends ConsumerState<BioScreen> {
  final TextEditingController _bioController = TextEditingController();
  String _selectedHint = '';

  /// Live AI-generated bio drafts from the server-side capped gateway. Empty
  /// until fetched; on any failure (offline, not signed in, budget exhausted)
  /// the static [hints] below still render, so onboarding never blocks.
  List<Map<String, String>> _aiHints = const [];

  @override
  void initState() {
    super.initState();
    _loadAiHints();
  }

  Future<void> _loadAiHints() async {
    final items = await ref
        .read(backendServiceProvider)
        .fetchAiBioSuggestions(about: _bioController.text);
    if (!mounted || items == null) return;
    setState(() {
      _aiHints = [
        for (final text in items) {'title': 'AI suggestion', 'bio': text},
      ];
    });
  }

  final List<Map<String, String>> hints = [
    {
      'title': 'Playful',
      'bio': 'Loves laughter, good food, and spontaneous adventures. Currently mastering jollof rice recipes. 🌶️',
    },
    {
      'title': 'Romantic',
      'bio': 'Beach walks at sunset, meaningful conversations, and building something real. Let\'s create our own story.',
    },
    {
      'title': 'Adventurous',
      'bio': 'Exploring Cameroon\'s hidden gems - from Limbe beaches to Waza mountains. Join the journey?',
    },
    {
      'title': 'Career-driven',
      'bio': 'Entrepreneur at heart. Building tomorrow while cherishing today\'s connections. Ambitious minds connect.',
    },
    {
      'title': 'Faith-focused',
      'bio': 'Sunday service, family values, and finding someone who shares the journey of faith.',
    },
  ];

  void _useHint(int index) {
    _bioController.text = hints[index]['bio']!;
    _selectedHint = hints[index]['title']!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress
              const LinearProgressIndicator(
                value: 0.7,
                backgroundColor: SawaLoveTheme.surfaceContainerLow,
                valueColor: AlwaysStoppedAnimation<Color>(SawaLoveTheme.primary),
              ),
              const SizedBox(height: 48),
              Text(
                'Tell your story',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Bio helps others know you better',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: SawaLoveTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              // Bio textarea
              TextField(
                controller: _bioController,
                maxLines: 4,
                maxLength: 160,
                decoration: InputDecoration(
                  hintText: 'I love hiking Mount Cameroon, cooking ndolé, and finding people who appreciate deep conversations...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: SawaLoveTheme.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 32),
              // AI Hints
              Text(
                'AI writing suggestions',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _aiHints.length + hints.length,
                  itemBuilder: (context, index) {
                    final hint = index < _aiHints.length
                        ? _aiHints[index]
                        : hints[index - _aiHints.length];
                    final isSelected = _selectedHint == hint['title'];
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 200,
                      decoration: BoxDecoration(
                        color: isSelected ? SawaLoveTheme.primaryContainer : SawaLoveTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () => _useHint(index),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: SawaLoveTheme.primary.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.auto_awesome, size: 16, color: Color(0xFFB30065)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      hint['title']!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white : SawaLoveTheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  if (index < _aiHints.length)
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: _loadAiHints,
                                      tooltip: 'More suggestions',
                                      icon: const Icon(Icons.refresh, size: 16, color: SawaLoveTheme.onSurfaceVariant),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  hint['bio']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.3,
                                    color: isSelected ? Colors.white : SawaLoveTheme.onSurface,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go('/onboarding/finalize'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SawaLoveTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

