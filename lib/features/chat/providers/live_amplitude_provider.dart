import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveAmplitudeNotifier extends StateNotifier<double> {
  LiveAmplitudeNotifier() : super(0.0);

  void updateAmplitude(double amplitude) {
    state = amplitude.clamp(0.0, 1.0);
  }

  void reset() {
    state = 0.0;
  }
}

final liveAmplitudeProvider = StateNotifierProvider<LiveAmplitudeNotifier, double>(
  (ref) => LiveAmplitudeNotifier(),
);

