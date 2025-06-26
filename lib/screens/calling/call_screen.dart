import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart'
    show RTCVideoRenderer, RTCPeerConnection, MediaStream, RTCPeerConnectionState, createPeerConnection, navigator, RTCVideoView, RTCSessionDescription, RTCIceCandidate, Helper;
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../socket_io/socket_io.dart';
import '../../utils/app_sound_constants.dart';

enum CallDirection { incoming, outgoing }

class CallScreen extends StatefulWidget {
  final String callerName;
  final String callerId;
  final String imageUrl;
  final CallDirection callDirection;
  final dynamic dataOfSocket;

  const CallScreen(
      {super.key,
        required this.callerName,
        required this.callerId,
        required this.imageUrl,
        required this.callDirection, this.dataOfSocket});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isMuted = false;
  bool isSpeakerOn = true;
  bool isVideoOn = false;
  bool _isCallAccepted = false;

  Timer? _timer;
  int _duration = 0;

  Timer? _callTimeoutTimer;
  AudioPlayer? _ringPlayer;

  void startRinging() async {
    print("Come here to start ringing");
    _ringPlayer = AudioPlayer();
    await _ringPlayer!.setReleaseMode(ReleaseMode.loop); // Loop the ringtone
    await _ringPlayer!.play(AssetSource(AppSound.ring));
  }

  void stopRinging() async {
    await _ringPlayer?.stop();
    _ringPlayer?.dispose();
    _ringPlayer = null;
  }

  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final socketProvider = Provider.of<SocketIoProvider>(
      navigatorKey.currentState!.context,
      listen: false);

  @override
  void initState() {
    super.initState();
    _initRenderers();

    // Debug: Log the incoming call data structure
    if (widget.callDirection == CallDirection.incoming) {
      debugPrint('📞 Incoming call data: ${widget.dataOfSocket}');
    }

    // Call _startCall for both incoming and outgoing calls
    if (widget.callDirection == CallDirection.outgoing) {
      _startCall();
      // Listen Incoming Call Event
      socketProvider.listenAcceptedCallEvent(_handleCallAccepted);
      startRinging();
      _callTimeoutTimer = Timer(const Duration(seconds: 60), () {
        if (!mounted) return; // Prevent logic if widget is already disposed

        if (_peerConnection?.connectionState !=
            RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          debugPrint('📞 Call timed out');
          socketProvider.hangUpCallEvent(
              targetId: widget.callerId,whoHangUpCallId: signInModel!.data!.user!.sId!);
          socketProvider.leaveCallEvent(callToUserId: widget.callerId,callFromUserId:  signInModel!.data!.user!.sId!);
          stopRinging();
          if (mounted) Navigator.pop(context);
        }
      });
    }

    // Listen for call accepted event for both incoming and outgoing calls
    socketProvider.listenAcceptedCallEvent(_handleCallAccepted);

    // Listen for hang up events
    socketProvider.listenHangUpCallEvent();

    // // Listen for ICE candidates
    // socketProvider.listenForIceCandidates(_handleIceCandidate);

    // Listen for SDP signals
    socketProvider.listenSignalForCall(_handleSdpSignal);

    // Set up call accepted callback
    _setupCallAcceptedCallback();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _startCall() async {
    await _createPeerConnection();

    if (widget.callDirection == CallDirection.outgoing) {
      // For outgoing calls, create and send offer
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      final desc = await _peerConnection!.getLocalDescription();
      debugPrint('📞 Created offer: ${offer.sdp}');
      socketProvider.sendSignalForCall(widget.callerId, desc!.toMap(), offer);
    }
  }

  Future<void> _createPeerConnection() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ]
    };

    _peerConnection = await createPeerConnection(configuration);

    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'video': true,
        'audio': true,
      });
      debugPrint('🎥 Got local stream: [32m${_localStream != null}[0m');
      // Enable all local audio tracks
      _localStream?.getAudioTracks().forEach((track) {
        track.enabled = true;
        debugPrint('🎤 Local audio track enabled: [32m${track.enabled}[0m');
      });
    } catch (e) {
      debugPrint('❌ Error getting user media: $e');
    }

    _localRenderer.srcObject = _localStream;

    if (_localStream == null) {
      debugPrint('❌ _localStream is null after getUserMedia');
    }

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    // Log local audio tracks for debugging
    final localAudioTracks = _localStream?.getAudioTracks();
    if (localAudioTracks != null && localAudioTracks.isNotEmpty) {
      debugPrint('🎤 Local audio track found: ${localAudioTracks.first.enabled}');
    } else {
      debugPrint('❌ No local audio tracks found');
    }

    _peerConnection?.onTrack = (event) {
      debugPrint('📡 onTrack called, streams: ${event.streams.length}');
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        _remoteRenderer.srcObject = _remoteStream;
        debugPrint('✅ Set remote stream with ${_remoteStream?.getTracks().length} tracks');
        // Log audio tracks for debugging
        final audioTracks = _remoteStream?.getAudioTracks();
        if (audioTracks != null && audioTracks.isNotEmpty) {
          debugPrint('🎵 Remote audio track found: ${audioTracks.first.enabled}');
        } else {
          debugPrint('❌ No remote audio tracks found');
        }
        // Enable all remote audio tracks
        _remoteStream?.getAudioTracks().forEach((track) {
          track.enabled = true;
          debugPrint('🎵 Remote audio track enabled: ${track.enabled}');
        });
        // Check audio status
        _checkAudioStatus();
      } else {
        debugPrint('❌ No remote streams in onTrack');
      }
    };

    _peerConnection?.onIceCandidate = (candidate) {
      debugPrint('🧊 ICE candidate: ${candidate.candidate}');
      // Send ICE candidate to the other peer via signaling server
      // socketProvider.sendIceCandidate(widget.callerId, candidate);
    };

    _peerConnection?.onRenegotiationNeeded = () async {
      try {
        debugPrint('🔄 Renegotiation needed');
        // Handle renegotiation if needed
      } catch (e) {
        debugPrint('❌ Error during renegotiation: $e');
      }
    };

    _peerConnection?.onConnectionState = (state) {
      debugPrint('🔄 Connection state changed: $state');

      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        // Call connected
          debugPrint('✅ Call connected successfully');
          // Check audio status when call connects
          _checkAudioStatus();
          // Force speakerphone on by default
          _setSpeaker(isSpeakerOn);
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        // Call failed or disconnected
          debugPrint('❌ Call disconnected or failed');
          if (mounted) Navigator.pop(context);
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          debugPrint('🔒 Call connection closed');
          if (mounted) Navigator.pop(context);
          break;
        default:
        // Handle other states if needed
          break;
      }
    };
  }

  void _setupCallAcceptedCallback() {
    // This will be called when the callAccepted event is received
    // We need to handle setting the remote description for outgoing calls
    if (widget.callDirection == CallDirection.outgoing) {
      // For outgoing calls, we need to wait for the answer from the callee
      // This will be handled in the socket listener
    }
  }

  // Method to handle when call is accepted (for outgoing calls)
  void _handleCallAccepted(dynamic data) async {
    if (widget.callDirection == CallDirection.outgoing && data != null) {
      try {
        // Check if peer connection is initialized
        if (_peerConnection == null) {
          debugPrint('❌ Peer connection is null in _handleCallAccepted');
          return;
        }

        // Validate the data structure - signal is nested
        if (data['signal']['sdp'] == null || data['signal']['type'] == null) {
          debugPrint('❌ Invalid data structure for callAccepted: signal=${data['type']}');
          return;
        }

        // Set the remote description with the answer from the callee
        final remoteDesc = RTCSessionDescription(
          data['signal']['sdp'],
          data['signal']['type'],
        );
        await _peerConnection!.setRemoteDescription(remoteDesc);
        debugPrint('📞 Set remote description with answer from callee');

        // Start the timer to show call duration
        if (!_isCallAccepted) {
          setState(() {
            _isCallAccepted = true;
          });
          _startTimer();

          // Ensure audio is properly initialized
          _initializeAudioForCall();
        }
      } catch (e) {
        debugPrint('❌ Error setting remote description with answer: $e');
      }
    }
  }

  // Method to handle ICE candidates
  void _handleIceCandidate(dynamic data) async {
    if (data != null && data['data'] != null && data['data']['type'] == 'candidate') {
      try {
        final candidate = RTCIceCandidate(
          data['data']['candidate'],
          data['data']['sdpMid'],
          data['data']['sdpMLineIndex'],
        );
        await _peerConnection!.addCandidate(candidate);
        debugPrint('🧊 Added ICE candidate to peer connection');
      } catch (e) {
        debugPrint('❌ Error adding ICE candidate: $e');
      }
    }
  }

  // Method to check if peer connection is ready to create answer
  Future<bool> _isPeerConnectionReadyForAnswer() async {
    if (_peerConnection == null) {
      debugPrint('❌ Peer connection is null');
      return false;
    }

    // Check if we have a remote description set
    final remoteDesc = await _peerConnection!.getRemoteDescription();
    if (remoteDesc == null) {
      debugPrint('❌ No remote description set');
      return false;
    }

    debugPrint('✅ Peer connection ready for answer. Remote description type: ${remoteDesc.type}');
    return true;
  }

  // Method to handle incoming SDP signals (offers/answers)
  void _handleSdpSignal(dynamic data) async {
    if (data != null && data['data'] != null) {
      try {
        if (data['data']['type'] == 'offer') {
          // Handle incoming offer (for incoming calls)
          if (widget.callDirection == CallDirection.incoming) {
            // Validate the data structure
            if (data['data']['signal'] == null || data['data']['signal']['sdp'] == null || data['data']['signal']['type'] == null) {
              debugPrint('❌ Invalid offer data structure: signal=${data['data']['signal']}');
              return;
            }

            final remoteDesc = RTCSessionDescription(
              data['data']['signal']['sdp'],
              data['data']['signal']['type'],
            );
            await _peerConnection!.setRemoteDescription(remoteDesc);
            debugPrint('📞 Set remote description with offer');
          }
        } else if (data['data']['type'] == 'answer') {
          // Handle incoming answer (for outgoing calls)
          if (widget.callDirection == CallDirection.outgoing) {
            // Validate the data structure
            if (data['data']['signal'] == null || data['data']['signal']['sdp'] == null || data['data']['signal']['type'] == null) {
              debugPrint('❌ Invalid answer data structure: signal=${data['data']['signal']}');
              return;
            }

            final remoteDesc = RTCSessionDescription(
              data['data']['signal']['sdp'],
              data['data']['signal']['type'],
            );
            await _peerConnection!.setRemoteDescription(remoteDesc);
            debugPrint('📞 Set remote description with answer');

            // Start the timer to show call duration
            if (!_isCallAccepted) {
              setState(() {
                _isCallAccepted = true;
              });
              _startTimer();
            }
          }
        }
      } catch (e) {
        debugPrint('❌ Error handling SDP signal: $e');
      }
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.close();
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
                isVideoOn
                    ? SizedBox(
                    height: 200,
                    child: RTCVideoView(_localRenderer, mirror: true))
                    : ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.grey,
                    ),
                    errorWidget: (context, url, error) =>
                    const CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person,
                          color: Colors.white, size: 75),
                    ),
                  ),
                ),
                const Spacer(),
                _buildBottomControls(),
              ],
            ),
          ),
          // Remote video view when call is active and video is on
          if (_isCallAccepted && isVideoOn)
            Positioned(
              top: 100,
              right: 20,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: RTCVideoView(_remoteRenderer),
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
      widget.callDirection == CallDirection.outgoing
          ? "Ringing..."
          : "Incoming call...",
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
              onPressed: () {
                socketProvider.hangUpCallEvent(targetId:widget.callerId,whoHangUpCallId: signInModel!.data!.user!.sId!);
                socketProvider.leaveCallEvent(callToUserId: widget.callerId,callFromUserId:  signInModel!.data!.user!.sId!);
                // Navigator.of(context).pop();
              }),
          _buildPillButton(
            icon: Icons.call,
            text: "Accept",
            color: Colors.green,
            onPressed: () async {
              try {
                debugPrint('📞 Accept button pressed');
                debugPrint('📞 Data structure: ${widget.dataOfSocket}');

                // Check if peer connection is initialized
                if (_peerConnection == null) {
                  debugPrint('❌ Peer connection is null. Cannot accept call.');
                  return;
                }

                // First, ensure the remote description is set
                if (widget.dataOfSocket != null && widget.dataOfSocket['signal'] != null) {
                  debugPrint('📞 Signal data found: Type ${widget.dataOfSocket['signal']['type']}');

                  // Validate the data structure
                  if (widget.dataOfSocket['signal']['sdp'] == null || widget.dataOfSocket['signal']['type'] == null) {
                    debugPrint('❌ Invalid data structure for incoming call');
                    return;
                  }

                  final remoteDesc = RTCSessionDescription(
                    widget.dataOfSocket['signal']['sdp'],
                    widget.dataOfSocket['signal']['type'],
                  );

                  debugPrint('📞 Setting remote description with type: ${remoteDesc.type}');
                  await _peerConnection!.setRemoteDescription(remoteDesc);
                  debugPrint('📞 Remote description set successfully');
                } else {
                  debugPrint('❌ No signal data available for incoming call');
                  return;
                }

                // Check if peer connection is ready for answer
                final isReady = await _isPeerConnectionReadyForAnswer();
                if (!isReady) {
                  debugPrint('❌ Peer connection not ready for answer');
                  return;
                }

                // Now create the answer
                debugPrint('📞 Creating answer...');
                final answer = await _peerConnection!.createAnswer();
                await _peerConnection!.setLocalDescription(answer);

                debugPrint('📞 Created answer: ${answer.sdp}');

                // Update UI state
                setState(() {
                  _isCallAccepted = true;
                });

                // Ensure audio is properly initialized
                _initializeAudioForCall();

                // Emit Accept call with the answer
                socketProvider.acceptCallEvent(
                    callToUserId: widget.callerId,
                    signal: answer.toMap()
                );

                _startTimer();
              } catch (e) {
                debugPrint('❌ Error accepting call: $e');
                setState(() {
                  _isCallAccepted = false;
                });
              }
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
          color: AppColor.whiteColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildControlButton(
              icon: isVideoOn ? Icons.videocam : Icons.videocam_off,
              onPressed: () {
                setState(() {
                  isVideoOn = !isVideoOn;
                });
                // Toggle video track
                _localStream?.getVideoTracks().forEach((track) {
                  track.enabled = isVideoOn;
                });
              },
            ),
            _buildControlButton(
              icon: isSpeakerOn ? Icons.volume_up : Icons.volume_down,
              onPressed: () {
                setState(() {
                  isSpeakerOn = !isSpeakerOn;
                });
                // Toggle speaker mode
                _toggleSpeakerMode();
              },
            ),
            _buildControlButton(
              icon: isMuted ? Icons.mic_off : Icons.mic,
              onPressed: () {
                setState(() {
                  isMuted = !isMuted;
                });
                // Toggle audio track
                _localStream?.getAudioTracks().forEach((track) {
                  track.enabled = !isMuted;
                });
              },
            ),
            _buildControlButton(
              icon: Icons.call_end,
              color: Colors.red,
              onPressed: () {
                socketProvider.hangUpCallEvent(
                    targetId: widget.callerId,whoHangUpCallId: signInModel!.data!.user!.sId!);
                socketProvider.leaveCallEvent(callToUserId: widget.callerId,callFromUserId:  signInModel!.data!.user!.sId!);
                // Navigator.of(context).pop();
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
          color: color ?? Colors.white.withValues(alpha: 0.2),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  void _toggleSpeakerMode() async {
    try {
      isSpeakerOn = !isSpeakerOn;
      await _setSpeaker(isSpeakerOn);
      debugPrint('🔊 Speaker mode toggled: ${isSpeakerOn ? "ON" : "OFF"}');
    } catch (e) {
      debugPrint('❌ Error toggling speaker mode: $e');
    }
  }

  Future<void> _setSpeaker(bool on) async {
    try {
      await Helper.setSpeakerphoneOn(on);
      debugPrint('🔈 Speakerphone set to: $on');
    } catch (e) {
      debugPrint('❌ Error setting speakerphone: $e');
    }
  }

  void _initializeAudioForCall() {
    try {
      debugPrint('🎵 Initializing audio for call...');
      // Enable all local audio tracks
      if (_localStream != null) {
        final localAudioTracks = _localStream!.getAudioTracks();
        if (localAudioTracks.isNotEmpty) {
          localAudioTracks.forEach((track) => track.enabled = !isMuted);
          debugPrint('🎤 Local audio track enabled: ${localAudioTracks.first.enabled}');
        }
      }
      // Enable all remote audio tracks
      if (_remoteStream != null) {
        final remoteAudioTracks = _remoteStream!.getAudioTracks();
        if (remoteAudioTracks.isNotEmpty) {
          remoteAudioTracks.forEach((track) => track.enabled = true);
          debugPrint('🎵 Remote audio track enabled: ${remoteAudioTracks.first.enabled}');
        }
      }
      // Force speakerphone on by default
      _setSpeaker(isSpeakerOn);
      debugPrint('🎵 Audio initialization complete');
    } catch (e) {
      debugPrint('❌ Error initializing audio: $e');
    }
  }

  void _checkAudioStatus() {
    debugPrint('🔍 Checking audio status...');
    // Check local stream
    if (_localStream != null) {
      final localTracks = _localStream!.getTracks();
      debugPrint('🎤 Local stream has ${localTracks.length} tracks');
      final localAudioTracks = _localStream!.getAudioTracks();
      if (localAudioTracks.isNotEmpty) {
        debugPrint('🎤 Local audio track: enabled=${localAudioTracks.first.enabled}, muted=${localAudioTracks.first.muted}');
      }
      final localVideoTracks = _localStream!.getVideoTracks();
      if (localVideoTracks.isNotEmpty) {
        debugPrint('📹 Local video track: enabled=${localVideoTracks.first.enabled}');
      }
    } else {
      debugPrint('❌ Local stream is null');
    }
    // Check remote stream
    if (_remoteStream != null) {
      final remoteTracks = _remoteStream!.getTracks();
      debugPrint('🎵 Remote stream has ${remoteTracks.length} tracks');
      final remoteAudioTracks = _remoteStream!.getAudioTracks();
      if (remoteAudioTracks.isNotEmpty) {
        debugPrint('🎵 Remote audio track: enabled=${remoteAudioTracks.first.enabled}, muted=${remoteAudioTracks.first.muted}');
      }
      final remoteVideoTracks = _remoteStream!.getVideoTracks();
      if (remoteVideoTracks.isNotEmpty) {
        debugPrint('📹 Remote video track: enabled=${remoteVideoTracks.first.enabled}');
      }
    } else {
      debugPrint('❌ Remote stream is null');
    }
    // Check peer connection state
    if (_peerConnection != null) {
      debugPrint('🔗 Peer connection state: ${_peerConnection!.connectionState}');
    } else {
      debugPrint('❌ Peer connection is null');
    }
  }
}
