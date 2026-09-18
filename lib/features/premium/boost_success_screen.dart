import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoostSuccessScreen extends StatelessWidget {
  const BoostSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 200,
                    child: Icon(Icons.rocket_launch, color: Colors.orange, size: 120),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Boost Activated!',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your profile will be seen by 10x more people for 30 minutes',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.go('/home/discover'),
                      child: const Text('Continue Swiping'),
                    ),
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

