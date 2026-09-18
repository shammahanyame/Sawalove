import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmergencySosScreen extends StatelessWidget {
  const EmergencySosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE91E63), Color(0xFFFF4081)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // SOS icon
                Container(
                  padding: const EdgeInsets.all(48),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sos_outlined,
                    size: 96,
                    color: Color(0xFFE91E63),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Emergency SOS',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hold for 3 seconds to share your live location with emergency contact',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Big button
                GestureDetector(
                  onLongPressStart: (_) => _startSos(context),
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app, size: 48, color: Color(0xFFE91E63)),
                          SizedBox(height: 12),
                          Text('HOLD FOR SOS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFFE91E63))),
                          Text('Live location shared', style: TextStyle(color: Color(0xFFE91E63))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Emergency contacts
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const CircleAvatar(child: Text('M')),
                          title: const Text('Mama • +237 699 123 456'),
                          subtitle: const Text('Emergency 1'),
                          trailing: Switch(value: true, onChanged: (v) {}),
                        ),
                        ListTile(
                          leading: const CircleAvatar(child: Text('S')),
                          title: const Text('Sister • +237 677 789 012'),
                          subtitle: const Text('Emergency 2'),
                          trailing: Switch(value: false, onChanged: (v) {}),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go('/safety/contacts'),
                          child: const Text('Add Contact'),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startSos(BuildContext context) {
    // SOS countdown
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sos, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('SOS ACTIVATED', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.red)),
              const SizedBox(height: 8),
              const Text('Location shared with: Mama (+237 699 123 456)'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Cancel SOS', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

