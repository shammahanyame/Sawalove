import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  RangeValues _ageRange = const RangeValues(18, 35);
  RangeValues _distanceRange = const RangeValues(1, 100);
  String _intentFilter = 'All';
  String _regionFilter = 'All';
  double _heightMin = 150;
  double _heightMax = 190;

  final List<String> intents = ['All', 'Friendship', 'Dating', 'Marriage', 'Networking'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Clear All', style: TextStyle(color: Color(0xFFB30065))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _sectionTitle('Age Range'),
          _sliderSection(
            subtitle: '${_ageRange.start.toInt()} - ${_ageRange.end.toInt()}',
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(activeTrackColor: SawaLoveTheme.primary),
              child: RangeSlider(
                values: _ageRange,
                min: 18,
                max: 60,
                onChanged: (values) => setState(() => _ageRange = values),
              ),
            ),
          ),
          _sectionTitle('Distance'),
          _sliderSection(
            subtitle: '${_distanceRange.start.toInt()} - ${_distanceRange.end.toInt()} km',
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(activeTrackColor: SawaLoveTheme.primary),
              child: RangeSlider(
                values: _distanceRange,
                min: 1,
                max: 500,
                divisions: 499,
                onChanged: (values) => setState(() => _distanceRange = values),
              ),
            ),
          ),
          _sectionTitle('Relationship Intent'),
          _dropdownSection(_intentFilter, intents, (value) => setState(() => _intentFilter = value!)),
          _sectionTitle('Region'),
          _dropdownSection(_regionFilter, ['All', 'Centre', 'Littoral', 'Ouest', 'Diaspora'], (value) => setState(() => _regionFilter = value!)),
          _sectionTitle('Height Range'),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Min', style: TextStyle(fontSize: 12, color: SawaLoveTheme.onSurfaceVariant)),
                    Slider(
                      value: _heightMin,
                      min: 140,
                      max: 200,
                      divisions: 60,
                      onChanged: (value) => setState(() => _heightMin = value),
                    ),
                    Text('${_heightMin.toInt()} cm'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Max', style: TextStyle(fontSize: 12, color: SawaLoveTheme.onSurfaceVariant)),
                    Slider(
                      value: _heightMax,
                      min: 140,
                      max: 200,
                      divisions: 60,
                      onChanged: (value) => setState(() => _heightMax = value),
                    ),
                    Text('${_heightMax.toInt()} cm'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Apply filters
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filters updated!')),
                );
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SawaLoveTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _sliderSection({
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SawaLoveTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(subtitle, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _dropdownSection(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SawaLoveTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value == 'All' ? null : value,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

