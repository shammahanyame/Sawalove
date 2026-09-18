import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) => setState(() => currentPage = index),
            children: [
              // Page 1: Welcome
              _buildPage(
                title: 'Welcome to SawaLove',
                subtitle: 'Find authentic connections in the Cameroonian community',
                image: Icons.heart_broken,
                color: SawaLoveTheme.primary,
              ),
              // Page 2: Swipe
              _buildPage(
                title: 'Swipe to Connect',
                subtitle: 'Right for like, left for pass. Simple & fun.',
                image: Icons.swipe,
                color: SawaLoveTheme.secondary,
              ),
              // Page 3: Premium African
              _buildPage(
                title: 'Premium African Modern',
                subtitle: 'Designed for Cameroonians – local & diaspora',
                image: Icons.location_on,
                color: SawaLoveTheme.tertiary,
              ),
            ],
          ),
          // Dots Indicator
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: currentPage == index 
                    ? SawaLoveTheme.primary 
                    : SawaLoveTheme.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ),
          // Bottom Actions
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo Verification coming soon'))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SawaLoveTheme.primary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                      ),
                      child: const Text('Get Started'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Skip for now'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required IconData image,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(image, color: Colors.white, size: 60),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
