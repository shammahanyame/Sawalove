import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class PhotoVerificationScreen extends StatefulWidget {
  const PhotoVerificationScreen({super.key});

  @override
  State<PhotoVerificationScreen> createState() => _PhotoVerificationScreenState();
}

class _PhotoVerificationScreenState extends State<PhotoVerificationScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takeSelfie() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      // TODO: ML liveness check stub
      // Upload to FirebaseStorage
      if (mounted) {
        context.go('/home/discover');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Identity')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              const Column(
                children: [
                  Text(
                    'Verify Your Identity',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Take a quick selfie to get your blue checkmark',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // Camera Preview (Placeholder)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB30065), Color(0xFFFF8AB8)],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Liveness Oval Overlay
                    Container(
                      width: 200,
                      height: 280,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 4, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      child: FloatingActionButton(
                        onPressed: _takeSelfie,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.camera_alt, color: Colors.black, size: 32),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Good/Bad Lighting Examples
              const Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _LightingExample(
                          icon: Icons.wb_sunny,
                          background: Color(0xFFE9FFF4),
                          foreground: Color(0xFF1D9E75),
                        ),
                        Text('Good Lighting'),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        _LightingExample(
                          icon: Icons.dark_mode,
                          background: Color(0xFFFFEEF2),
                          foreground: Color(0xFFB3261E),
                        ),
                        Text('Avoid'),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _takeSelfie,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera),
                          SizedBox(width: 12),
                          Text('Take Photo', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/home/discover'),
                    child: const Text('Skip for now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LightingExample extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;

  const _LightingExample({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: Icon(icon, size: 44, color: foreground)),
    );
  }
}

