import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LikesMatchesScreen extends ConsumerWidget {
  const LikesMatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              const SliverAppBar(
                title: Text('Likes & Matches'),
                pinned: true,
                bottom: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.favorite_border), text: 'Likes'),
                    Tab(icon: Icon(Icons.favorite), text: 'Matches'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              // Likes Tab - Incoming likes grid
              GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 12, // Mock data
                itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: NetworkImage('https://via.placeholder.com/120'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8, right: 8),
                      decoration: const BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                        ),
                      ),
                      child: const Icon(Icons.favorite, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
              // Matches Tab - Mutual matches grid
              GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 8, // Mock data
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/chat/$index'),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Image.network('https://via.placeholder.com/160x200'),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black54, Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Amaka, 24',
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'New match! Say hi 👋',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

