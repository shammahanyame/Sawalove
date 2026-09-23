import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class MeetupPlacePickerScreen extends StatefulWidget {
  final String matchName;
  const MeetupPlacePickerScreen({super.key, required this.matchName});

  @override
  State<MeetupPlacePickerScreen> createState() =>
      _MeetupPlacePickerScreenState();
}

class _MeetupPlacePickerScreenState extends State<MeetupPlacePickerScreen> {
  String _selectedSpot = 'Cafe de la Paix';

  final List<Map<String, dynamic>> _safeSpots = [
    {
      'name': 'Cafe de la Paix',
      'category': 'Cafe',
      'distance': '1.2km',
      'crowd': 'Busy',
      'safety': 5,
      'icon': Icons.local_cafe,
    },
    {
      'name': 'Bonapriso Park',
      'category': 'Park',
      'distance': '800m',
      'crowd': 'Moderate',
      'safety': 4,
      'icon': Icons.park,
    },
    {
      'name': "Hilton Hotel Lobby",
      'category': 'Hotel',
      'distance': '2.1km',
      'crowd': 'Busy',
      'safety': 5,
      'icon': Icons.hotel,
    },
    {
      'name': 'Akwa Shopping Center',
      'category': 'Mall',
      'distance': '1.8km',
      'crowd': 'Very Busy',
      'safety': 4,
      'icon': Icons.shopping_cart,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meet ${widget.matchName}?'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Safety warning
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [SawaLoveTheme.warningContainer, SawaLoveTheme.warning]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.safety_check, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Meet in public, busy places during day. Share location with trusted friend.',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Safe Public Spots Nearby',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RadioGroup<String>(
                  groupValue: _selectedSpot,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedSpot = value);
                    }
                  },
                  child: ListView.separated(
                    itemCount: _safeSpots.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final spot = _safeSpots[index];
                      final name = spot['name'] as String;
                      final isSelected = _selectedSpot == name;
                      return Card(
                        color: isSelected
                            ? SawaLoveTheme.primary.withValues(alpha: 0.1)
                            : null,
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  SawaLoveTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(spot['icon'] as IconData,
                                color: SawaLoveTheme.primary),
                          ),
                          title: Text(name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${spot['category']} - ${spot['distance']}'),
                              Text('${spot['crowd']} crowd'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${spot['safety']}'),
                              const Icon(Icons.star,
                                  color: SawaLoveTheme.warning, size: 18),
                              Radio<String>(value: name),
                            ],
                          ),
                          onTap: () => setState(() => _selectedSpot = name),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Share location toggle
              SwitchListTile(
                title: const Text('Share live location'),
                subtitle: const Text('Friend gets your location during meetup'),
                value: false,
                onChanged: (v) {},
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedSpot.isNotEmpty
                          ? _sendMeetupSuggestion
                          : null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: SawaLoveTheme.primary),
                      child: const Text('Suggest Meetup'),
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

  void _sendMeetupSuggestion() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Suggested $_selectedSpot to ${widget.matchName}'),
        backgroundColor: SawaLoveTheme.primary,
        action: SnackBarAction(
          label: 'View Chat',
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
