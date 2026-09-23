import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen> {
  static const _holdDuration = Duration(seconds: 3);

  Timer? _countdownTimer;
  int _countdown = 0;
  bool _sosActivated = false;

  bool get _countingDown => _countdown > 0;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    if (_countingDown || _sosActivated) return;
    HapticFeedback.mediumImpact();
    setState(() => _countdown = _holdDuration.inSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _countdown -= 1);
      HapticFeedback.selectionClick();
      if (_countdown <= 0) {
        timer.cancel();
        _activateSos();
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    setState(() => _countdown = 0);
  }

  void _activateSos() {
    HapticFeedback.heavyImpact();
    setState(() => _sosActivated = true);
    _showActivatedSheet();
  }

  void _cancelSos() {
    setState(() {
      _sosActivated = false;
      _countdown = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE91E63), Color(0xFFFF4081)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // SOS icon
                Container(
                  padding: const EdgeInsets.all(48),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sos_outlined,
                    size: 96,
                    color: Color(0xFFE91E63),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Emergency SOS',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hold for 3 seconds to share your live location with emergency contact',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Big button: press-and-hold with a 3s countdown before activation.
                GestureDetector(
                  onLongPressStart: (_) => _startCountdown(),
                  onLongPressEnd: (_) => _cancelCountdown(),
                  onLongPressCancel: _cancelCountdown,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeOut,
                        child: _sosActivated
                            ? const Icon(
                                Icons.sos,
                                key: ValueKey('activated'),
                                size: 56,
                                color: SawaLoveTheme.errorColor,
                              )
                            : _countingDown
                                ? _CountdownRing(
                                    key: const ValueKey('countdown'),
                                    remaining: _countdown,
                                    total: _holdDuration.inSeconds,
                                  )
                                : const Column(
                                    key: ValueKey('idle'),
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.touch_app, size: 48, color: Color(0xFFE91E63)),
                                      SizedBox(height: 12),
                                      Text('HOLD FOR SOS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFFE91E63))),
                                      Text('Keep holding to confirm', style: TextStyle(color: Color(0xFFE91E63))),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Emergency contacts
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const CircleAvatar(child: Text('M')),
                          title: const Text('Mama • +237 699 123 456'),
                          subtitle: const Text('Emergency 1'),
                          trailing: Switch(value: true, onChanged: (v) {}),
                        ),
                        ListTile(
                          leading: const CircleAvatar(child: Text('S')),
                          title: const Text('Sister • +237 677 789 012'),
                          subtitle: const Text('Emergency 2'),
                          trailing: Switch(value: false, onChanged: (v) {}),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go('/safety/contacts'),
                          child: const Text('Add Contact'),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActivatedSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sos, size: 64, color: SawaLoveTheme.errorColor),
            const SizedBox(height: 16),
            const Text(
              'SOS ACTIVATED',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: SawaLoveTheme.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Live location shared with: Mama (+237 699 123 456)'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _cancelSos();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SawaLoveTheme.errorColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: const Text('Cancel SOS'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular countdown shown inside the SOS button while the user holds it.
class _CountdownRing extends StatelessWidget {
  final int remaining;
  final int total;

  const _CountdownRing({super.key, required this.remaining, required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: remaining / total,
            backgroundColor: const Color(0xFFE91E63).withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
            strokeWidth: 6,
          ),
          Center(
            child: Text(
              '$remaining',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: const Color(0xFFE91E63),
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
