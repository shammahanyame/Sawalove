import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SafetyCenterScreen extends StatelessWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Center')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block Users'),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Report Profile'),
              onTap: () => context.go('/profile/someuid/report'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Safety Tips'),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Account'),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

