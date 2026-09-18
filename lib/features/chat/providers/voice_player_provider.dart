import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class PlayerState {
  final bool isPlaying;
  final double progress;
  final double speed;
  final Duration position;
  final Duration duration;

  const PlayerState({
    this.isPlaying = false,
    this.progress = 0.0,
    this.speed = 1.0,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  PlayerState copyWith({
    bool? isPlaying,
    double? progress,
    double? speed,
    Duration? position,
    Duration? duration,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      progress: progress ?? this.progress,
      speed: speed ?? this.speed,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class VoiceNotePlayerNotifier extends StateNotifier<PlayerState> {
  VoiceNotePlayerNotifier(this.messageId) : super(const PlayerState()) {
    _logger = Logger();
  }

  final AudioPlayer _player = AudioPlayer();
  late final Logger _logger;
  StreamSubscription<Duration?>? _positionSub;
  final String messageId;
  String? _conversationId;

// Remove invalid family constructor line

  Future<void> play(String audioUrl, {String? conversationId}) async {
    try {
      _conversationId = conversationId;
      await _player.setUrl(audioUrl);
      await _player.play();

      _positionSub ??= _player.positionStream.listen((position) {
        final dur = _player.duration ?? Duration.zero;
        final prog = dur.inMilliseconds > 0 ? position.inMilliseconds / dur.inMilliseconds : 0.0;
        state = state.copyWith(
          isPlaying: _player.playing,
          progress: prog.clamp(0.0, 1.0),
          position: position,
          duration: dur,
        );
      });

      state = state.copyWith(isPlaying: true);
    } catch (e) {
      _logger.e('Play error: $e');
    }
  }

  Future<void> pause() async {
    await _player.pause();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> toggle() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(double fraction) async {
    final dur = _player.duration ?? Duration.zero;
    await _player.seek(dur * fraction);
  }

  Future<void> setSpeed(double newSpeed) async {
    await _player.setSpeed(newSpeed);
    if (_conversationId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('voice_speed_$_conversationId', newSpeed);
    }
    state = state.copyWith(speed: newSpeed);
  }

  Future<double> getPersistedSpeed() async {
    if (_conversationId == null) return 1.0;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('voice_speed_$_conversationId') ?? 1.0;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

// Global for speeds if needed
final voicePlayerProvider = AutoDisposeStateNotifierProvider.family<VoiceNotePlayerNotifier, PlayerState, String>(
  (ref, messageId) => VoiceNotePlayerNotifier(messageId),
);

