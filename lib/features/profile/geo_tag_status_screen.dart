import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';

class GeoTagStatusScreen extends StatefulWidget {
  const GeoTagStatusScreen({super.key});

  @override
  State<GeoTagStatusScreen> createState() => _GeoTagStatusScreenState();
}

class _GeoTagStatusScreenState extends State<GeoTagStatusScreen> {
  bool _showLocation = false;

  final List<String> _locations = [
    'Douala - Bonapriso',
    'Yaoundé - Bastos',
    'Buea - Molyko',
    'Garoua - Roumdé Adjia',
    'Bamenda - Commercial Avenue',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Status'),
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
                'Show Location on Profile',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: const Text('Show city'),
                        subtitle: const Text('Others see "Douala"'),
                        value: _showLocation,
                        onChanged: (value) => setState(() => _showLocation = value),
                      ),
                      if (_showLocation) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _locations.map((location) => DropdownMenuItem(value: location, child: Text(location))).toList(),
                          onChanged: (value) {},
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Preview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('Profile Preview', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage('https://picsum.photos/60'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Amaka N.', style: TextStyle(fontWeight: FontWeight.w700)),
                                const Text('Catholic • 25 • Douala'),
                                if (_showLocation)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: SawaLoveTheme.tertiary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.location_on, size: 16, color: SawaLoveTheme.tertiary),
                                        SizedBox(width: 4),
                                        Text('Douala - Bonapriso', style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Location status saved')),
                  );
                  context.pop();
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
