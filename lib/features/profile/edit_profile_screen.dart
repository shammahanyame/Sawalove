import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/theme.dart';
import '../../shared/services/backend_service.dart';

/// Edits the signed-in user's own profile (`GET`/`PUT /users/{id}`).
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _villageController = TextEditingController();

  String _selectedRegion = '';
  String _selectedChurch = '';
  String? _photoUrl;
  Map<String, dynamic> _preferences = {};

  bool _loading = true;
  bool _saving = false;
  bool _uploadingPhoto = false;

  static const _regions = [
    'Littoral',
    'Centre',
    'West',
    'Southwest',
    'Northwest',
    'Adamawa',
    'East',
    'Far North',
  ];
  static const _churches = [
    'Catholic',
    'Protestant',
    'Pentecostal',
    'Baptist',
    'Presbyterian',
  ];

  static String _text(dynamic value) =>
      value == null ? '' : value.toString();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final backend = ref.read(backendServiceProvider);
    final uid = backend.currentUserId;
    if (!backend.isConfigured || uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final profile = await backend.getUserProfile(uid);
      if (!mounted) return;
      if (profile == null) {
        setState(() => _loading = false);
        return;
      }
      _nameController.text = _text(profile['name']);
      final bio = _text(profile['bio']);
      // The API substitutes this placeholder for a null bio; don't let it
      // become the user's saved bio on the next save.
      _bioController.text = bio == 'New to SawaLove.' ? '' : bio;
      _cityController.text = _text(profile['city']);
      _villageController.text = _text(profile['village']);
      final prefs = profile['preferences'];
      setState(() {
        _selectedRegion = _text(profile['location']);
        _preferences = prefs is Map ? Map<String, dynamic>.from(prefs) : {};
        _selectedChurch = _text(_preferences['religion']);
        _photoUrl = _text(profile['photo']);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load your profile.')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    final backend = ref.read(backendServiceProvider);
    final uid = backend.currentUserId;

    setState(() => _saving = true);
    try {
      if (backend.isConfigured && uid != null) {
        final payload = <String, dynamic>{
          'name': _nameController.text.trim(),
          'bio': _bioController.text.trim(),
        };
        // The columns are NOT NULL with defaults — never send empty values.
        final city = _cityController.text.trim();
        final village = _villageController.text.trim();
        if (city.isNotEmpty) payload['city'] = city;
        if (village.isNotEmpty) payload['village'] = village;
        if (_selectedRegion.isNotEmpty) payload['location'] = _selectedRegion;

        final prefs = Map<String, dynamic>.from(_preferences);
        if (_selectedChurch.isEmpty) {
          prefs.remove('religion');
        } else {
          prefs['religion'] = _selectedChurch;
        }
        payload['preferences'] = prefs;

        await backend.saveUserProfile(uid, payload);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save changes. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Picks a new primary photo and uploads it to slot 0 (the server promotes
  /// slot 0 to the public `photo` URL automatically).
  Future<void> _changePhoto() async {
    if (_uploadingPhoto) return;
    final backend = ref.read(backendServiceProvider);
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      final bytes = await picked.readAsBytes();
      final url = await backend.uploadProfilePhoto(
        bytes: bytes,
        slotIndex: 0,
        contentType: picked.mimeType ?? 'image/jpeg',
      );
      if (url == null && backend.isConfigured) {
        throw Exception('upload failed');
      }
      await _loadProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo updated')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not upload photo. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  List<DropdownMenuItem<String>> _items(List<String> base, String current) {
    final values = <String>[
      '',
      ...base,
      if (current.isNotEmpty && !base.contains(current)) current,
    ];
    return [
      for (final value in values)
        DropdownMenuItem(
          value: value,
          child: Text(value.isEmpty ? 'Not set' : value),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _saving || _loading ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Profile photo (server has a single primary photo).
                  const Text('Profile photo',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _uploadingPhoto ? null : _changePhoto,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: SawaLoveTheme.surfaceContainer,
                            image: (_photoUrl != null &&
                                    _photoUrl!.isNotEmpty)
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(_photoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (_photoUrl == null || _photoUrl!.isEmpty)
                              ? const Icon(Icons.person_rounded,
                                  size: 48, color: SawaLoveTheme.onSurfaceVariant)
                              : null,
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: _uploadingPhoto
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to change your photo',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Name required'
                            : null,
                  ),
                  const SizedBox(height: 24),
                  // Bio
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell us about yourself (max 150 chars)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLength: 150,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Bio helps you get matches'
                            : null,
                  ),
                  const SizedBox(height: 32),
                  // Local fields
                  const Text('Local Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _villageController,
                    decoration: InputDecoration(
                      labelText: 'Village',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRegion,
                    decoration: InputDecoration(
                      labelText: 'Region',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _items(_regions, _selectedRegion),
                    onChanged: (value) =>
                        setState(() => _selectedRegion = value ?? ''),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedChurch,
                    decoration: InputDecoration(
                      labelText: 'Church/Denomination',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _items(_churches, _selectedChurch),
                    onChanged: (value) =>
                        setState(() => _selectedChurch = value ?? ''),
                  ),
                  const SizedBox(height: 48),
                  // Premium badge
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        SawaLoveTheme.primaryContainer,
                        SawaLoveTheme.primary
                      ]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.white),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Go Premium for more visibility',
                              style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: () => context.push('/premium'),
                          child: const Text('Upgrade',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
