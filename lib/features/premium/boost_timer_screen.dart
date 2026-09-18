import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class BoostTimerScreen extends StatefulWidget {
  const BoostTimerScreen({super.key});

  @override
  State<BoostTimerScreen> createState() => _BoostTimerScreenState();
}

class _BoostTimerScreenState extends State<BoostTimerScreen> {
  Duration _remainingTime = const Duration(hours: 1, minutes: 30);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [SawaLoveTheme.primary, SawaLoveTheme.primaryContainer],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rocket
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.rocket_launch, color: Colors.white, size: 80),
              ),
              const SizedBox(height: 48),
              Text(
                'Boost Active!',
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your profile is 10x more visible',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 64),
              // Timer
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      _formatDuration(_remainingTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Text(
                      'Time remaining',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Progress
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 1.0 - (_remainingTime.inSeconds / 5400.0), // 1.5h = 5400s
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // CTA
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('Buy More Boost', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB30065))),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

