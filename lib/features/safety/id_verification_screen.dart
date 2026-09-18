import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/theme.dart';

class IdVerificationScreen extends StatefulWidget {
  const IdVerificationScreen({super.key});

  @override
  State<IdVerificationScreen> createState() => _IdVerificationScreenState();
}

class _IdVerificationScreenState extends State<IdVerificationScreen> {
  File? _ninImage;
  bool _isVerifying = false;
  bool _verified = false;

  Future<void> _pickIdImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _ninImage = File(pickedFile.path));
    }
  }

  Future<void> _verifyId() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() {
      _isVerifying = false;
      _verified = true;
    });
    messenger.showSnackBar(
      const SnackBar(content: Text('NIN verified! Gold badge unlocked')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Verification (NIN)'),
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
                'Optional National ID Verification',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Why verify?',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      _benefit(Icons.verified, 'Gold badge on profile'),
                      _benefit(Icons.shield, 'Higher trust score'),
                      _benefit(Icons.support_agent, 'Priority support'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Upload area
              Card(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickIdImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: SawaLoveTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: SawaLoveTheme.outlineVariant, width: 2),
                        ),
                        child: _ninImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child:
                                    Image.file(_ninImage!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.document_scanner,
                                      size: 64,
                                      color: SawaLoveTheme.onSurfaceVariant),
                                  const SizedBox(height: 16),
                                  Text('Tap to upload NIN',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const Text('Front side of National ID',
                                      style: TextStyle(
                                          color:
                                              SawaLoveTheme.onSurfaceVariant)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_ninImage != null && !_verified)
                      ElevatedButton.icon(
                        onPressed: _isVerifying ? null : _verifyId,
                        icon: _isVerifying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.verified),
                        label:
                            Text(_isVerifying ? 'Verifying...' : 'Verify ID'),
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56)),
                      )
                    else if (_verified)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified,
                                color: Colors.green, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Verified!',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18)),
                                  Text('Gold badge activated',
                                      style: TextStyle(
                                          color: Colors.green.shade700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Your NIN is encrypted & never shared. Cameroon gov compliant.',
                style: TextStyle(
                    color: SawaLoveTheme.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: SawaLoveTheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
