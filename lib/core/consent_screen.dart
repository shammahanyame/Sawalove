import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/core/consent_notifier.dart';

class ConsentScreen extends ConsumerWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consent = ref.watch(consentProvider);
    final isReady = consent.isReadyToAccept;

    return Scaffold(
      appBar: AppBar(title: const Text('Consent')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teal banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DC9F1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Colors.white),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "We've written a simple summary of what matters most. / Nous avons ecrit un resume simple de l'essentiel.",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Terms of Service
                _DocumentCard(
                  title: 'Terms of Service',
                  version: '1.0.0',
                  summary: 'Age 18+, no impersonation/harassment, Cameroon law applies.',
                  pdfUrl: 'https://sawalove.com/tos.pdf',
                  icon: Icons.description,
                  onExpand: () => ref.read(consentProvider.notifier).openTos(),
                  isRead: consent.hasOpenedTos,
                ),
                const SizedBox(height: 16),
                // Privacy Policy
                _DocumentCard(
                  title: 'Privacy Policy',
                  version: '1.0.0',
                  summary: 'No data sold, city-level location only, right to delete.',
                  pdfUrl: 'https://sawalove.com/privacy.pdf',
                  icon: Icons.security,
                  onExpand: () => ref.read(consentProvider.notifier).openPrivacy(),
                  isRead: consent.hasOpenedPP,
                ),
                const SizedBox(height: 16),
                // Cookie Policy (Optional)
                _DocumentCard(
                  title: 'Cookie Policy (Optional)',
                  version: '1.0.0',
                  summary: 'Essential cookies only. Analytics optional.',
                  pdfUrl: 'https://sawalove.com/cookies.pdf',
                  icon: Icons.cookie,
                  onExpand: () => ref.read(consentProvider.notifier).openCookies(),
                  isRead: consent.hasOpenedCookies,
                  isOptional: true,
                ),
                const SizedBox(height: 32),
                // Indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _IndicatorDot(isFilled: consent.hasOpenedTos, required: true),
                    const SizedBox(width: 16),
                    _IndicatorDot(isFilled: consent.hasOpenedPP, required: true),
                  ],
                ),
                const SizedBox(height: 48),
                // Toggles
                const _ConsentToggle(
                  title: 'Necessary data processing',
                  description: 'Cannot be disabled / Ne peut pas etre desactive',
                  enabled: true,
                  enabledColor: Colors.grey,
                ),
                const SizedBox(height: 24),
                _ConsentToggle(
                  title: 'Personalised suggestions',
                  description: 'Improve matches from your activity',
                  enabled: consent.personalised,
                  onChanged: true,
                  provider: consentProvider,
                  type: ConsentType.personalised,
                ),
                const SizedBox(height: 24),
                _ConsentToggle(
                  title: 'Analytics & app improvement',
                  description: 'Anonymous usage data, no personal data shared',
                  enabled: consent.analytics,
                  onChanged: true,
                  provider: consentProvider,
                  type: ConsentType.analytics,
                ),
                const SizedBox(height: 64),
                // CTA Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _showDeclineModal(context),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isReady ? () => ref.read(consentProvider.notifier).submitConsent(context) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isReady ? const Color(0xFFB30065) : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(isReady ? 'I agree' : 'Read docs first'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeclineModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.55,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                'No account created, all data deleted, return to welcome. You can sign up again anytime.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true), // Decline confirmed
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Decline'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final String title;
  final String version;
  final String summary;
  final String pdfUrl;
  final IconData icon;
  final VoidCallback onExpand;
  final bool isRead;
  final bool isOptional;

  const _DocumentCard({
    required this.title,
    required this.version,
    required this.summary,
    required this.pdfUrl,
    required this.icon,
    required this.onExpand,
    required this.isRead,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onExpand,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
                        if (isRead) const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                    Text(summary),
                    Text('v$version', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsentToggle extends ConsumerWidget {
  final String title;
  final String description;
  final bool enabled;
  final bool onChanged;
  final Color? enabledColor;
  final StateNotifierProvider<ConsentNotifier, ConsentState>? provider;
  final ConsentType? type;

  const _ConsentToggle({
    required this.title,
    required this.description,
    required this.enabled,
    this.onChanged = false,
    this.enabledColor,
    this.provider,
    this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onChanged && provider != null && type != null
          ? () => ref.read(provider!.notifier).toggle(type!)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Semantics(
              toggled: enabled,
              label: '$title consent - ${enabled ? "enabled" : "disabled"}',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 32,
                decoration: BoxDecoration(
                  color: enabled ? const Color(0xFFB30065) : const Color(0xFFD89CB4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      left: enabled ? 20 : 4,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(description, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  final bool isFilled;
  final bool required;

  const _IndicatorDot({required this.isFilled, required this.required});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Document read: ${isFilled ? "yes" : "no"}',
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFilled ? const Color(0xFFB30065) : Colors.grey.shade400,
        ),
      ),
    );
  }
}

