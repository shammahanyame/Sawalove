import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isVideoOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.red, size: 32),
                    onPressed: () => context.pop(),
                  ),
                  const Column(
                    children: [
                      Text('Amaka N.', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      Text('00:01:23', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Video feeds
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Main video (local)
                  Container(
                    color: Colors.blueGrey.shade900,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam_off, color: Colors.white54, size: 64),
                          Text('Amaka N.', style: TextStyle(color: Colors.white, fontSize: 18)),
                          Text('Remote Video', style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    ),
                  ),
                  // Small preview (self)
                  Positioned(
                    top: 100,
                    right: 16,
                    child: Container(
                      width: 120,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, color: Colors.white, size: 48),
                            Text('You', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Controls
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _controlButton(
                    icon: Icons.mic,
                    isActive: !_isMuted,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                    activeColor: Colors.white,
                    inactiveColor: Colors.white54,
                  ),
                  _controlButton(
                    icon: Icons.switch_video,
                    isActive: _isSpeakerOn,
                    onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                    activeColor: Colors.white,
                    inactiveColor: Colors.white54,
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                    ),
                  ),
                  _controlButton(
                    icon: Icons.videocam,
                    isActive: _isVideoOn,
                    onTap: () => setState(() => _isVideoOn = !_isVideoOn),
                    activeColor: Colors.white,
                    inactiveColor: Colors.white54,
                  ),
                  _controlButton(
                    icon: Icons.screen_share,
                    isActive: false,
                    onTap: () {},
                    activeColor: Colors.white,
                    inactiveColor: Colors.white54,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}

// Note: Add agora_rtc_engine: ^6.3.2 to pubspec.yaml for real video call
// Initialize AgoraEngineController in initState

