import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Amaka Ngozi');
  final _bioController = TextEditingController(text: 'Loving life in Douala 🌅');

  String _selectedRegion = 'Littoral';
  String _selectedChurch = 'Catholic';
  final List<String> _photos = ['photo1.jpg', 'photo2.jpg'];

  final List<String> _regions = ['Littoral', 'Centre', 'West', 'Southwest', 'Northwest', 'Adamawa', 'East', 'Far North'];
  final List<String> _churches = ['Catholic', 'Protestant', 'Pentecostal', 'Baptist', 'Presbyterian'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                context.pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Photos
            const Text('Photos (6 max)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length + 1,
                itemBuilder: (context, index) {
                  if (index < _photos.length) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 120,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage('https://via.placeholder.com/100x120?text=Photo${index + 1}'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _photos.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return GestureDetector(
                    onTap: () {}, // Pick image
                    child: Container(
                      width: 100,
                      height: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: SawaLoveTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: SawaLoveTheme.primary, width: 2),
                      ),
                      child: const Icon(Icons.add_photo_alternate, size: 40, color: SawaLoveTheme.primary),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            // Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value!.isEmpty ? 'Name required' : null,
            ),
            const SizedBox(height: 24),
            // Bio
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell us about yourself (max 150 chars)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLength: 150,
              validator: (value) => value!.isEmpty ? 'Bio helps you get matches' : null,
            ),
            const SizedBox(height: 32),
            // Localized fields
            const Text('Local Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedRegion,
              decoration: InputDecoration(
                labelText: 'Region',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _regions.map((region) => DropdownMenuItem(value: region, child: Text(region))).toList(),
              onChanged: (value) => setState(() => _selectedRegion = value!),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _selectedChurch,
              decoration: InputDecoration(
                labelText: 'Church/Denomination',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _churches.map((church) => DropdownMenuItem(value: church, child: Text(church))).toList(),
              onChanged: (value) => setState(() => _selectedChurch = value!),
            ),
            const SizedBox(height: 48),
            // Premium badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [SawaLoveTheme.primaryContainer, SawaLoveTheme.primary]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text('Go Premium for more visibility', style: TextStyle(color: Colors.white)),
                  const Spacer(),
                  TextButton(onPressed: () {}, child: const Text('Upgrade', style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

