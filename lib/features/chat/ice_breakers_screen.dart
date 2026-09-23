import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/services/backend_service.dart';

class IceBreakersScreen extends ConsumerStatefulWidget {
  const IceBreakersScreen({super.key, this.participantName});

  /// Name of the person the openers are for.
  ///
  /// SECURITY/BUGFIX: this screen previously hardcoded a demo name ("Amaka
  /// N."), so every user saw the same fake person. Peer names are untrusted
  /// user input: they are trimmed, length-clamped, and rendered as inert text
  /// (Flutter Text never interprets markup), so a crafted name cannot inject
  /// layout or impersonate UI.
  final String? participantName;

  @override
  ConsumerState<IceBreakersScreen> createState() => _IceBreakersScreenState();
}

class _IceBreakersScreenState extends ConsumerState<IceBreakersScreen> {
  String get _safeParticipantName {
    final raw = (widget.participantName ?? '').trim();
    if (raw.isEmpty) {
      return 'them';
    }
    return raw.length > 40 ? raw.substring(0, 40) : raw;
  }

  /// Live AI suggestions from the server-side gateway (already validated and
  /// clamped there); empty until a successful fetch. On any failure the
  /// built-in [_iceBreakers] render instead, so the screen always works —
  /// offline, not signed in, or when the AI budget is exhausted.
  _AiLoadState _state = _AiLoadState.loading;
  List<String> _aiSuggestions = const [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() => _state = _AiLoadState.loading);
    final name = _safeParticipantName;
    final about = name == 'them' ? '' : 'Starting a chat with $name.';
    final items = await ref
        .read(backendServiceProvider)
        .fetchAiIceBreakers(about: about);
    if (!mounted) return;
    setState(() {
      _aiSuggestions = items ?? const [];
      _state = items == null ? _AiLoadState.fallback : _AiLoadState.ready;
    });
  }

  List<Map<String, String>> get _visibleSuggestions {
    if (_state == _AiLoadState.ready && _aiSuggestions.isNotEmpty) {
      return [
        for (final text in _aiSuggestions) {'text': text, 'category': 'AI pick'},
      ];
    }
    return _iceBreakers;
  }

  static const List<Map<String, String>> _iceBreakers = [
    {
      'text': 'Love your hometown! How long have you been in Douala?',
      'category': 'Location',
    },
    {
      'text': 'What\'s your favorite Cameroonian dish to cook?',
      'category': 'Culture',
    },
    {
      'text': "What's the best ndolo party you've been to?",
      'category': 'Fun',
    },
    {
      'text': 'Which church song gets you dancing?',
      'category': 'Faith',
    },
    {
      'text': 'What made you smile today?',
      'category': 'Positive',
    },
    {
      'text': 'If you could visit any region in Cameroon, where?',
      'category': 'Adventure',
    },
    {
      'text': 'Favorite Bible verse for relationships?',
      'category': 'Faith',
    },
    {
      'text': 'MTN or Orange? Be honest! 😄',
      'category': 'Fun',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ice Breakers'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _state == _AiLoadState.loading ? null : _loadSuggestions,
            tooltip: 'Refresh suggestions',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: _state == _AiLoadState.ready
                        ? 'AI suggested openers for '
                        : 'Openers for ',
                  ),
                  TextSpan(
                    text: _safeParticipantName,
                    style: const TextStyle(color: SawaLoveTheme.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _state == _AiLoadState.loading
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: SawaLoveTheme.primary),
                          SizedBox(height: 16),
                          Text('Thinking of openers…'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _visibleSuggestions.length,
                      itemBuilder: (context, index) {
                        final breaker = _visibleSuggestions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(20),
                            dense: true,
                            title: Text(
                              breaker['text']!,
                              style: const TextStyle(height: 1.4),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                breaker['category']!,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: SawaLoveTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => Navigator.pop(context, breaker['text']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SawaLoveTheme.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: Text('Send', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: SawaLoveTheme.onPrimary)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AiLoadState { loading, ready, fallback }

// Reached via /chat/ice-breakers?name=... (see app_router); pops the chosen
// opener back to the caller.

