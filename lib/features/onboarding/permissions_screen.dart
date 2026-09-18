import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/theme.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _locationEnabled = false;
  bool _cameraEnabled = false;
  bool _notificationsEnabled = false;
  int _progress = 0;

  Future<void> _requestPermissions() async {
    // Location
    final locationStatus = await Permission.location.request();
    setState(() {
      _locationEnabled = locationStatus.isGranted;
      _progress = 1;
    });

    // Camera
    final cameraStatus = await Permission.camera.request();
    setState(() {
      _cameraEnabled = cameraStatus.isGranted;
      _progress = 2;
    });

    // Notifications
    final notifStatus = await Permission.notification.request();
    setState(() {
      _notificationsEnabled = notifStatus.isGranted;
      _progress = 3;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: index < _progress 
                      ? const Color(0xFFB30065)
                      : SawaLoveTheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                )),
              ),
              const SizedBox(height: 48),
              // Hero
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB30065), SawaLoveTheme.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.security,
                      size: 64,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'SawaLove Permissions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'For the best experience',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Permissions list
              _permissionTile(
                icon: Icons.location_on_outlined,
                title: 'Location',
                subtitle: 'Find matches near you (Douala, Yaoundé, etc.)',
                enabled: _locationEnabled,
                onTap: () => openAppSettings(),
              ),
              _permissionTile(
                icon: Icons.camera_alt_outlined,
                title: 'Camera',
                subtitle: 'Verify photos & video calls',
                enabled: _cameraEnabled,
                onTap: () => openAppSettings(),
              ),
              _permissionTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'New matches & messages',
                enabled: _notificationsEnabled,
                onTap: () => openAppSettings(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _requestPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB30065),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Grant Permissions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Skip (Limited features)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _permissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: enabled 
              ? const Color(0xFFB30065).withValues(alpha: 0.1)
              : SawaLoveTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: enabled ? const Color(0xFFB30065) : SawaLoveTheme.onSurfaceVariant),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        trailing: Switch(
          value: enabled,
          onChanged: (_) => onTap(),
          activeThumbColor: const Color(0xFFB30065),
        ),
        onTap: onTap,
      ),
    );
  }
}

