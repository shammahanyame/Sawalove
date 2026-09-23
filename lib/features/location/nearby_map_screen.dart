import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sawalove/core/utils/h3_stub.dart';
import 'package:sawalove/shared/services/firebase_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NearbyMapScreen extends ConsumerStatefulWidget {
  const NearbyMapScreen({super.key});

  @override
  ConsumerState<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends ConsumerState<NearbyMapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  Position? _currentPosition;
  String _cityName = 'Douala';
  double _radiusKm = 5.0;
  String? _currentH3Cell; // Changed to String
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
    _initConnectivity();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // Fixed deprecated desiredAccuracy
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.reduced,
        distanceFilter: 10,
      ),
    );

    final h3 = H3();
    final h3Index = h3.fromLatLng(
      LatLng(position.latitude, position.longitude),
      resolution: 8,
    );

    final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    final placemark = placemarks.first;

    setState(() {
      _currentPosition = position;
      _currentH3Cell = h3Index;
      _cityName = '${placemark.locality}, ${placemark.administrativeArea}';
    });

    _loadNearbyUsers(h3Index);
    _animateToCurrentLocation();
  }

  Future<void> _loadNearbyUsers(String h3Cell) async {
    final firebase = ref.read(firebaseServiceProvider);
    final h3 = H3();
    // Compute neighboring cells for radius-based query
    h3.gridDisk(h3Cell, radius: (_radiusKm / 2).round());

    final users = await firebase.fetchVisibleUsers(limit: 20);

    setState(() {
      _markers.clear();
      for (final data in users) {
        // Stub latLng
        final latLng = LatLng(4.0511 + (data['lat'] ?? 0), 9.7679 + (data['lng'] ?? 0));
        _markers.add(
          Marker(
            markerId: MarkerId(data['id']?.toString() ?? 'nearby-${_markers.length}'),
            position: latLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              (data['isPremium'] ?? false) ? BitmapDescriptor.hueViolet : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(title: data['name'] ?? 'User', snippet: '${data['distance'] ?? 2.5}km'),
          ),
        );
      }
    });
  }

  Future<void> _animateToCurrentLocation() async {
    if (_currentPosition == null) return;
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        14.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_cityName),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(4.0511, 9.7679),
              zoom: 13,
            ),
            style: _loadMapStyle(),
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
            markers: _markers,
            circles: {
              Circle(
                circleId: const CircleId('radius'),
                center: _currentPosition != null
                    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                    : const LatLng(4.0511, 9.7679),
                radius: _radiusKm * 1000,
                strokeWidth: 2,
                strokeColor: const Color(0xFFB30065),
                fillColor: const Color(0x10B30065),
                // Removed strokePattern - not supported
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          // Pulsing dot, bottom sheet unchanged
          if (_currentPosition != null)
            Positioned(
              bottom: 100,
              left: MediaQuery.of(context).size.width / 2 - 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: SawaLoveTheme.tertiary,
                  shape: BoxShape.circle,
                ),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 2),
                  tween: Tween(begin: 0.5, end: 1.0),
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: SawaLoveTheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.15,
            maxChildSize: 0.6,
            builder: (context, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(blurRadius: 40, color: Color(0x1A000000))],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: SawaLoveTheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nearby: ${_markers.length}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('$_radiusKm km'),
                      Expanded(
                        child: Slider(
                          value: _radiusKm,
                          min: 1.0,
                          max: 50.0,
                          divisions: 49,
                          onChanged: (value) {
                            setState(() => _radiusKm = value);
                            if (_currentH3Cell != null) _loadNearbyUsers(_currentH3Cell!);
                          },
                        ),
                      ),
                      const Text('50 km'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _markers.length,
                      itemBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: CircleAvatar(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _loadMapStyle() {
    return '''[
      {
        "elementType": "geometry",
        "stylers": [{"saturation": 30}]
      }
    ]''';
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _initConnectivity() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Monitor connectivity changes
    });
  }
}

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Pause Location'),
            value: false,
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }
}

