import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class LocalEventsNewsScreen extends StatefulWidget {
  const LocalEventsNewsScreen({super.key});

  @override
  State<LocalEventsNewsScreen> createState() => _LocalEventsNewsScreenState();
}

class _LocalEventsNewsScreenState extends State<LocalEventsNewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Events & News'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Douala Highlights',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              // Event carousel
              SizedBox(
                height: 220,
                child: PageView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) => Card(
                    margin: const EdgeInsets.only(right: 16),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            color: SawaLoveTheme.primary.withValues(alpha: 0.1),
                            width: double.infinity,
                            height: 220,
                            child: const Icon(Icons.event, size: 100, color: Colors.grey),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fête de la Jeunesse 2025',
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                              const Text(
                                'Stade Omnisports, 25 Jan • 15h',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Your Region Feed',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: 10,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage('https://picsum.photos/60?random=$index'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text('News ${index + 1}'),
                      subtitle: Text('Littoral • ${_getTimeAgo()}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opened local news ${index + 1}')),
                        );
                      },
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

  String _getTimeAgo() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return now.hour < 6 ? 'Tonight' : yesterday.hour < 6 ? 'Yesterday' : '2h ago';
  }
}

