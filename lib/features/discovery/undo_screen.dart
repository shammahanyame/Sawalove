import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';

class UndoScreen extends StatelessWidget {
  const UndoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Undo icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.4),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.undo,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Undo Last Swipe',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w800,
                  color: SawaLoveTheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'Bring back the last profile you swiped. Premium feature - 3/day.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: SawaLoveTheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Quota
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SawaLoveTheme.primary.withValues(alpha: 0.1),
                      SawaLoveTheme.primaryContainer.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flash_on, size: 20, color: SawaLoveTheme.primary),
                    SizedBox(width: 12),
                    Text(
                      '2/3 remaining',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: SawaLoveTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: const Text('Continue Swiping'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Last swipe undone!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      child: const Text(
                        'Undo',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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

