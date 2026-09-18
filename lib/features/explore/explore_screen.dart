import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modes = ['Friendship', 'Dating', 'Marriage', 'Networking'];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Explore'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Choose your mode', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: modes.length,
                    itemBuilder: (context, index) {
                      final mode = modes[index];
                      return GestureDetector(
                        onTap: () {
                          // Filter profiles by mode
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people, size: 48, color: Theme.of(context).primaryColor),
                              const SizedBox(height: 12),
                              Text(mode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('Find $mode connections', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

