import 'package:google_maps_flutter/google_maps_flutter.dart';

class H3 {
  String fromLatLng(LatLng latLng, {required int resolution}) {
    // stub H3 index generation
    return '8${latLng.latitude.abs().floor()}${latLng.longitude.abs().floor()}';
  }

  List<String> gridDisk(String h3Index, {required int radius}) {
    return [h3Index];
  }
}

