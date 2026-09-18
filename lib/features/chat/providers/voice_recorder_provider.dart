import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

enum RecorderState { idle, recording, uploading }

class VoiceRecorderNotifier extends StateNotifier<RecorderState> {
  VoiceRecorderNotifier() : super(RecorderState.idle);

  final AudioRecorder _recorder = AudioRecorder();
  final Logger _logger = Logger();
  final List<double> _amplitudes = [];
  Timer? _ampTimer;

  Future<void> startRecording(String conversationId) async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _logger.e('No mic permission');
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 16000,
        ),
        path: path,
      );

      state = RecorderState.recording;
      _amplitudes.clear();

      _ampTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        try {
          final amp = await _recorder.getAmplitude();
          final normalized = ((amp.current + 60) / 60).clamp(0.0, 1.0);
          _amplitudes.add(normalized);
          if (_amplitudes.length >= 600) { // ~60s
            await stopAndSend(conversationId);
          }
        } catch (e) {
          _logger.e('Amp error: $e');
        }
      });
    } catch (e) {
      _logger.e('Start recording error: $e');
    }
  }

  Future<void> stopAndSend(String conversationId) async {
    _ampTimer?.cancel();
    try {
      state = RecorderState.uploading;
      final path = await _recorder.stop();
      if (path == null) return;

      final file = File(path);
      final durationMs = await _getDuration(file);

      // Downsample to 50 values
      final sampled = _downsample(_amplitudes, 50);

      _logger.i(
        'Recorded ${file.path} for $conversationId '
        '($durationMs ms, ${sampled.length} samples). Supabase upload pending.',
      );

      _amplitudes.clear();
      state = RecorderState.idle;
    } catch (e) {
      _logger.e('Stop/send error: $e');
      state = RecorderState.idle;
    }
  }

  Future<int> _getDuration(File file) async {
    // Stub: use just_audio or audioplayers to get duration
    // For now return estimate from bytes
    final bytes = await file.length();
    return (bytes ~/ 32000).clamp(1000, 60000); // rough 16kHz AAC estimate
  }

  List<double> _downsample(List<double> input, int targetLength) {
    if (input.length <= targetLength) return input;
    final step = input.length / targetLength;
    return List.generate(targetLength, (i) => input[(i * step).floor()]);
  }

  void cancel() {
    _ampTimer?.cancel();
    _recorder.stop();
    _amplitudes.clear();
    state = RecorderState.idle;
  }
}

final voiceRecorderProvider = StateNotifierProvider<VoiceRecorderNotifier, RecorderState>((ref) {
  return VoiceRecorderNotifier();
});

