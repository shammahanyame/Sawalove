import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Per-type toggles
  bool _matchToggle = true;
  bool _messageToggle = true;
  bool _likeToggle = true;
  bool _superLikeToggle = true;
  bool _boostToggle = true;
  bool _promoToggle = false;

  TimeOfDay? _quietStart;
  TimeOfDay? _quietEnd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              // Main toggles
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Push Notifications',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 18)),
                          Switch(
                              value: _pushEnabled,
                              onChanged: (v) =>
                                  setState(() => _pushEnabled = v)),
                        ],
                      ),
                      if (_pushEnabled) ...[
                        SwitchListTile(
                          title: const Text('Sounds'),
                          value: _soundEnabled,
                          onChanged: (v) => setState(() => _soundEnabled = v),
                        ),
                        SwitchListTile(
                          title: const Text('Vibration'),
                          value: _vibrationEnabled,
                          onChanged: (v) =>
                              setState(() => _vibrationEnabled = v),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Per-type
              const Text('Notification Types',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Row(children: [
                  Icon(Icons.favorite, color: Colors.pink.shade400),
                  const SizedBox(width: 12),
                  const Text('New Matches'),
                ]),
                value: _matchToggle,
                onChanged: (v) => setState(() => _matchToggle = v),
              ),
              SwitchListTile(
                title: const Row(children: [
                  Icon(Icons.chat_bubble, color: SawaLoveTheme.primary),
                  SizedBox(width: 12),
                  Text('New Messages'),
                ]),
                value: _messageToggle,
                onChanged: (v) => setState(() => _messageToggle = v),
              ),
              SwitchListTile(
                title: const Row(children: [
                  Icon(Icons.thumb_up, color: SawaLoveTheme.tertiary),
                  SizedBox(width: 12),
                  Text('New Likes'),
                ]),
                value: _likeToggle,
                onChanged: (v) => setState(() => _likeToggle = v),
              ),
              SwitchListTile(
                title: const Row(children: [
                  Icon(Icons.star, color: SawaLoveTheme.warning),
                  SizedBox(width: 12),
                  Text('Super Likes'),
                ]),
                value: _superLikeToggle,
                onChanged: (v) => setState(() => _superLikeToggle = v),
              ),
              SwitchListTile(
                title: const Row(children: [
                  Icon(Icons.flash_on, color: SawaLoveTheme.tertiary),
                  SizedBox(width: 12),
                  Text('Boost Notifications'),
                ]),
                value: _boostToggle,
                onChanged: (v) => setState(() => _boostToggle = v),
              ),
              SwitchListTile(
                title: const Row(children: [
                  Icon(Icons.campaign, color: SawaLoveTheme.onSurfaceVariant),
                  SizedBox(width: 12),
                  Text('Promotions'),
                ]),
                value: _promoToggle,
                onChanged: (v) => setState(() => _promoToggle = v),
              ),
              const SizedBox(height: 24),
              // Quiet hours
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Quiet Hours',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 18)),
                          Switch(
                            value: _quietStart != null && _quietEnd != null,
                            onChanged: (v) => setState(() {
                              if (v) {
                                _quietStart = TimeOfDay.now();
                                _quietEnd =
                                    const TimeOfDay(hour: 22, minute: 0);
                              } else {
                                _quietStart = null;
                                _quietEnd = null;
                              }
                            }),
                          ),
                        ],
                      ),
                      if (_quietStart != null && _quietEnd != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                                    'From: ${_quietStart!.format(context)}')),
                            Expanded(
                                child:
                                    Text('To: ${_quietEnd!.format(context)}')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Times'),
                            onPressed: () async {
                              final start = await showTimePicker(
                                context: context,
                                initialTime: _quietStart!,
                              );
                              if (!context.mounted) return;
                              final end = await showTimePicker(
                                context: context,
                                initialTime: _quietEnd!,
                              );
                              if (start != null && end != null && mounted) {
                                setState(() {
                                  _quietStart = start;
                                  _quietEnd = end;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ],
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
