import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:flutter/material.dart';

enum CallDirection { incoming, outgoing }

class CallScreen extends StatefulWidget {
  final String callerName;
  final String callerId;
  final String imageUrl;
  final CallDirection callDirection;
  final String? joinedUserName;
  final String? joinedUserImageUrl;

  const CallScreen({
    super.key,
    required this.callerName,
    required this.callerId,
    required this.imageUrl,
    required this.callDirection,
    this.joinedUserName,
    this.joinedUserImageUrl,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isMuted = false;
  bool isSpeakerOn = false;
  bool isVideoOn = false;
  bool _isCallAccepted = false;

  Timer? _timer;
  int _duration = 0;

  @override
  void initState() {
    super.initState();
    if (widget.callDirection == CallDirection.outgoing) {
      // For an outgoing call, we consider it "accepted" to show the in-call UI immediately.
      // In a real app, a socket event would trigger the timer.
      // Here, we'll just show "Ringing...". A timer would start on a 'call_accepted' event.
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _duration++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.commonAppColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Text(
              widget.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            _buildStatusText(),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.grey,
                    ),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white, size: 75),
                    ),
                  ),
                ),
                const Spacer(),
                _buildBottomControls(),
              ],
            ),
          ),
          // Joined user avatar at bottom right
          if (widget.joinedUserName != null && widget.joinedUserName!.isNotEmpty)
            Positioned(
              right: 20,
              bottom: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColor.commonAppColor,
                      backgroundImage: (widget.joinedUserImageUrl != null &&
                              widget.joinedUserImageUrl!.isNotEmpty)
                          ? NetworkImage(widget.joinedUserImageUrl!)
                          : null,
                      child: (widget.joinedUserImageUrl == null ||
                              widget.joinedUserImageUrl!.isEmpty)
                          ? Text(
                              widget.joinedUserName![0].toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.joinedUserName!,
                      style: TextStyle(
                        color: AppColor.commonAppColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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

  Widget _buildStatusText() {
    // If call is active, show timer
    if (_isCallAccepted) {
      return Text(
        _formatDuration(_duration),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      );
    }
    // Otherwise, show status based on call direction
    return Text(
      widget.callDirection == CallDirection.outgoing ? "Ringing..." : "Incoming call...",
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
    );
  }

  Widget _buildBottomControls() {
    // If it's an incoming call and not yet accepted, show Accept/Decline buttons
    if (widget.callDirection == CallDirection.incoming && !_isCallAccepted) {
      return _buildIncomingCallControls();
    }
    // Otherwise, show the active in-call controls
    return _buildActiveCallControls();
  }

  Widget _buildIncomingCallControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 70.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPillButton(
            icon: Icons.call_end,
            text: "Decline",
            color: Colors.red,
            onPressed: () => Navigator.of(context).pop(),
          ),
          _buildPillButton(
            icon: Icons.call,
            text: "Accept",
            color: Colors.green,
            onPressed: () {
              setState(() {
                _isCallAccepted = true;
              });
              _startTimer();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPillButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Icon(icon, color: Colors.white, size: 35),
          ),
        ),
        const SizedBox(height: 12),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }

  Widget _buildActiveCallControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0, left: 20, right: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        decoration: BoxDecoration(
          color: AppColor.whiteColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildControlButton(
              icon: isVideoOn ? Icons.videocam : Icons.videocam_off,
              onPressed: () => setState(() => isVideoOn = !isVideoOn),
            ),
            _buildControlButton(
              icon: isSpeakerOn ? Icons.volume_up : Icons.volume_down,
              onPressed: () => setState(() => isSpeakerOn = !isSpeakerOn),
            ),
            _buildControlButton(
              icon: isMuted ? Icons.mic_off : Icons.mic,
              onPressed: () => setState(() => isMuted = !isMuted),
            ),
            _buildControlButton(
              icon: Icons.call_end,
              color: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? Colors.white.withOpacity(0.2),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
