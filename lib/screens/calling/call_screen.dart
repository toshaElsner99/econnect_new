import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart'
    show
        RTCVideoRenderer,
        RTCPeerConnection,
        MediaStream,
        RTCPeerConnectionState,
        createPeerConnection,
        navigator,
        RTCVideoView,
        RTCSessionDescription,
        RTCIceCandidate,
        Helper,
        RTCSignalingState,
        RTCVideoViewObjectFit;
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
      required this.callDirection,
      this.dataOfSocket});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isMuted = false;
  bool isShowMutedIcon = false;
  bool isRemoteVideoOn = false;
  bool isSpeakerOn = true;
  bool isVideoOn = false;
  bool _isCallAccepted = false;

  Timer? _timer;
  int _duration = 0;
  late StreamSubscription _subscription;

  Timer? _callTimeoutTimer;
  AudioPlayer? _ringPlayer;
  AudioPlayer? _inRingPlayer;

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

  void startIncomingRinging() async {
    print("Come here to start Incoming ringing");
    _inRingPlayer = AudioPlayer();
    await _inRingPlayer!.setReleaseMode(ReleaseMode.loop); // Loop the ringtone
    await _inRingPlayer!.play(AssetSource(AppSound.incomingRing));
  }

  void stopIncomingRinging() async {
    await _inRingPlayer?.stop();
    _inRingPlayer?.dispose();
    _inRingPlayer = null;
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
      debugPrint('📞 Initializing peer connection for incoming call...');
      // Initialize peer connection for incoming calls
      _createPeerConnection().then((_) {
        debugPrint(
            '📞 Peer connection initialized successfully for incoming call');
        // Set up signal listener after peer connection is ready

        // If we have signal data from the incoming call, set it as remote description
        if (widget.dataOfSocket != null &&
            widget.dataOfSocket['signal'] != null) {
          debugPrint('📞 Setting initial remote description for incoming call');
          _setInitialRemoteDescription();
        }
      }).catchError((error) {
        debugPrint(
            '❌ Error initializing peer connection for incoming call: $error');
      });
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
              targetId: widget.callerId,
              whoHangUpCallId: signInModel!.data!.user!.sId!);
          socketProvider.leaveCallEvent(
              callToUserId: widget.callerId,
              callFromUserId: signInModel!.data!.user!.sId!);
          stopRinging();
          stopIncomingRinging();
          if (mounted) {
            // Show timeout message similar to React JS
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Call timed out – ${widget.callerName} did not answer. Try again'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
            print("21112001");
            Navigator.pop(context);
          }
        }
      });
    } else {
      startIncomingRinging();
    }

    // Listen for call accepted event for both incoming and outgoing calls
    socketProvider.listenAcceptedCallEvent(_handleCallAccepted);

    // Listen for hang up events
    socketProvider.listenHangUpCallEvent((isHangup){
      stopIncomingRinging();
    });

    // Listen for peer media toggle events
    socketProvider.listenPeerMediaToggle((micOn, cameraOn) {
      debugPrint('🎤 Peer media toggle: micOn=$micOn, cameraOn=$cameraOn');
      print("Is icon show muted icon = $isShowMutedIcon");
      isShowMutedIcon = !micOn;
      print("this is the value coming form the cameraon==> $cameraOn");
      isRemoteVideoOn = cameraOn;
      print("Is icon show muted icon = $isShowMutedIcon");
      setState(() {});
      // You can update UI based on peer's media state here
    });

    // Listen for user busy events (for outgoing calls)
    if (widget.callDirection == CallDirection.outgoing) {
      socketProvider.listenUserBusyEvent((userId) {
        debugPrint('❌ User $userId is busy');
        stopRinging();
        if (mounted) {
          print("21112001");
          Navigator.pop(context);
        }
      });

      // Listen for call rejected events
      socketProvider.listenCallRejectedEvent(() {
        debugPrint('❌ Call was rejected');
        stopRinging();
        stopIncomingRinging(); // Ensure incoming ringtone stops (for safety)
        if (mounted) {
          print("21112001");
          print("21");
          // Navigator.pop(context);
        }
      });
    }

    socketProvider.addListener(_onSocketUpdate);

    // Set up call accepted callback
    _setupCallAcceptedCallback();
  }

  void _onSocketUpdate() {
    final data = socketProvider.latestMessage;

    print("Received message in ChatScreen: $data");
    _handleSdpSignal(data);
    // You can update your UI here or call setState
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
        'video': {
          'facingMode': 'user', // 'user' = front camera, 'environment' = rear
        },
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
      });
      debugPrint('🎥 Got local stream: [32m${_localStream != null}[0m');
      // Enable all local audio tracks
      _localStream?.getAudioTracks().forEach((track) {
        track.enabled = true;
        debugPrint('🎤 Local audio track enabled: [32m${track.enabled}[0m');
      });
    } catch (e) {
      debugPrint('❌ Error getting user media: $e');
      // Try to get audio only if video fails
      try {
        _localStream = await navigator.mediaDevices.getUserMedia({
          'video': false,
          'audio': {
            'echoCancellation': true,
            'noiseSuppression': true,
            'autoGainControl': true,
          },
        });
        debugPrint('🎤 Got audio-only stream as fallback');
      } catch (audioError) {
        debugPrint('❌ Error getting audio-only stream: $audioError');
      }
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
      debugPrint(
          '🎤 Local audio track found: ${localAudioTracks.first.enabled}');
    } else {
      debugPrint('❌ No local audio tracks found');
    }

    _peerConnection?.onTrack = (event) {
      debugPrint('📡 onTrack called, streams: ${event.streams.length}');
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        _remoteRenderer.srcObject = _remoteStream;
        debugPrint(
            '✅ Set remote stream with ${_remoteStream?.getTracks().length} tracks');

        // Handle audio tracks specifically
        final audioTracks = _remoteStream?.getAudioTracks();
        if (audioTracks != null && audioTracks.isNotEmpty) {
          debugPrint(
              '🎵 Remote audio track found: ${audioTracks.first.enabled}');
          // Ensure remote audio tracks are enabled and not muted
          for (var track in audioTracks) {
            track.enabled = true;
            debugPrint(
                '🎵 Remote audio track enabled: ${track.enabled}, muted: ${track.muted}');
          }

          // Force speakerphone on when we receive remote audio
          _setSpeaker(true);
        } else {
          debugPrint('❌ No remote audio tracks found');
        }

        // Handle video tracks
        final videoTracks = _remoteStream?.getVideoTracks();
        if (videoTracks != null && videoTracks.isNotEmpty) {
          debugPrint(
              '📹 Remote video track found: ${videoTracks.first.enabled}');
        }

        // Check audio status after setting remote stream
        _checkAudioStatus();
      } else {
        debugPrint('❌ No remote streams in onTrack');
      }
    };

    _peerConnection?.onIceCandidate = (candidate) {
      debugPrint('🧊 ICE candidate: ${candidate.candidate}');
      // Send ICE candidate to the other peer via signaling server
      socketProvider.sendIceCandidate(
        callToUserId: widget.callerId,
        candidate: candidate,
      );
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
          // Stop the ringtone when the call is connected
          stopRinging();
          // Check audio status when call connects
          _checkAudioStatus();
          // Force speakerphone on by default
          _setSpeaker(true);
          // Ensure audio is properly initialized for the call
          _initializeAudioForCall();

          // Ensure remote audio is enabled after a short delay
          Future.delayed(const Duration(milliseconds: 1000), () {
            _ensureRemoteAudioEnabled();
            _checkAudioStatus();
            _checkAudioState();
          });

          // Show connection success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Call connected! Audio should be working now.'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          // Call failed or disconnected
          debugPrint('❌ Call disconnected or failed');
          if (mounted) {
            print("21112001");
            Navigator.pop(context);
          };
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          debugPrint('🔒 Call connection closed');
          // if (mounted) {
          //   // print("21112001");
          //   // Navigator.pop(context);
          // };
          break;
        default:
          // Handle other states if needed
          break;
      }
    };

    debugPrint('📞 Peer connection creation completed successfully');
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
          debugPrint(
              '❌ Invalid data structure for callAccepted: signal=${data['type']}');
          return;
        }

        // Set the remote description with the answer from the callee
        final remoteDesc = RTCSessionDescription(
          data['signal']['sdp'],
          data['signal']['type'],
        );

        await _peerConnection!.setRemoteDescription(remoteDesc);
        debugPrint('📞 Set remote description with answer from callee');
// Stop the ringtone immediately when the call is accepted
        stopRinging();
        // Start the timer to show call duration
        if (!_isCallAccepted) {
          setState(() {
            _isCallAccepted = true;
          });
          stopRinging(); // for testing
          _startTimer();
          // Ensure audio is properly initialized
          _initializeAudioForCall();

          // Update UI to show in-call state (similar to React JS)
          debugPrint('✅ Call accepted - both users now in call');
        }
        //stopRinging(); // for testing
      } catch (e) {
        debugPrint('❌ Error setting remote description with answer: $e');
      }
    }
  }

  // Method to handle incoming SDP signals (offers/answers) and ICE candidates
  void _handleSdpSignal(dynamic data) async {
    print("_handleSdpSignal = $data");

    // Wait for peer connection to be ready (with retry)
    int retryCount = 0;
    while (_peerConnection == null && retryCount < 10) {
      debugPrint(
          '⏳ Waiting for peer connection to be ready... (attempt ${retryCount + 1})');
      await Future.delayed(const Duration(milliseconds: 500));
      retryCount++;
    }

    if (_peerConnection == null) {
      debugPrint(
          '❌ Peer connection is null after retries, cannot handle signal');
      return;
    }

    try {
      if (data != null && data != null) {
        // Handle SDP description (offer/answer)
        if (data['description'] != null) {
          final description = data['description'];
          final type = description['type'];
          final currentState = _peerConnection!.signalingState;

          debugPrint('📞 Received SDP $type, current state: $currentState');

          // Check state before setting an offer
          if (type == 'offer' &&
              currentState != RTCSignalingState.RTCSignalingStateStable) {
            debugPrint('⚠️ Cannot set remote offer in state: $currentState');
            return;
          }

          // Check state before setting an answer
          if (type == 'answer' &&
              currentState !=
                  RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
            debugPrint('⚠️ Cannot set remote answer in state: $currentState');
            return;
          }

          // Set the remote description if the state is valid
          final remoteDesc = RTCSessionDescription(
            description['sdp'],
            description['type'],
          );
          await _peerConnection!.setRemoteDescription(remoteDesc);
          debugPrint('📞 Set remote description with $type');

          // Handle offer by creating and sending an answer
          if (type == 'offer') {
            debugPrint('📞 Creating answer for incoming offer...');
            final answer = await _peerConnection!.createAnswer();
            await _peerConnection!.setLocalDescription(answer);

            // Send the answer back via signal
            socketProvider.sendAnswerSignal(
              callToUserId: widget.callerId,
              description: await _peerConnection!.getLocalDescription(),
            );

            debugPrint('📞 Answer created and sent');
          }
          // Handle answer received (for outgoing calls)
          else if (type == 'answer') {
            debugPrint('📞 Answer received from peer');

            // Start the timer to show call duration
            if (!_isCallAccepted) {
              setState(() {
                _isCallAccepted = true;
              });
              _startTimer();

              // Ensure audio is properly initialized
              _initializeAudioForCall();

              // Update UI to show in-call state (similar to React JS)
              debugPrint('✅ Call accepted - both users now in call');
            }
          }
        }
        // Handle ICE candidate
        else if (data['candidate'] != null) {
          debugPrint('🧊 Received ICE candidate from peer');
          final candidate = RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          );
          await _peerConnection!.addCandidate(candidate);
          debugPrint('🧊 Added ICE candidate to peer connection');
        }
      }
    } catch (err) {
      debugPrint('❌ Error handling signal: $err');
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _callTimeoutTimer?.cancel();
    stopRinging();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  void _cleanup() {
    debugPrint('🧹 Cleaning up call resources');
    _stopTimer();
    _callTimeoutTimer?.cancel();
    stopRinging();
    _localStream?.dispose();
    _peerConnection?.close();
    setState(() {
      _isCallAccepted = false;
    });
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
        fit: StackFit.loose,
        alignment: Alignment.center,
        children: [
          Center(
            child: _isCallAccepted && isRemoteVideoOn
                ? SizedBox(
                    // 200height: ,
                    child: RTCVideoView(
                    _remoteRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    placeholderBuilder: (con) {
                      return Container(
                        color: Colors.black,
                      );
                    },
                  ))
                : ClipOval(
                    child: Stack(
                      children: [
                        CachedNetworkImage(
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
                      ],
                    ),
                  ),
          ),
          // if (isShowMutedIcon)
          //   Positioned(
          //     // left: MediaQuery.of(context).size.width / 2 - 50,
          //     top: 20,
          //       child: Align(
          //         alignment: Alignment.center,
          //         child: Container(
          //           decoration: BoxDecoration(color: Colors.grey.withAlpha(180),borderRadius: BorderRadius.circular(12)),
          //           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //           child: Text("${widget.callerName} is Muted"),
          //         ),
          //       )),
          // Waiting message for outgoing calls (similar to React JS)
          if (widget.callDirection == CallDirection.outgoing &&
              !_isCallAccepted)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Calling ${widget.callerName}...",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          // Remote video view when call is active and video is on
          if (isVideoOn)
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
                  child: RTCVideoView(
                    _localRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    placeholderBuilder: (con) {
                      return Container(
                        color: Colors.black,
                      );
                    },
                  ),
                ),
              ),
             ),
          // else
          //   Positioned(
          //     top: 100,
          //     right: 20,
          //     child: Container(
          //       width: 120,
          //       height: 160,
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(12),
          //         color: AppColor.commonAppColor,
          //
          //         border: Border.all(color: Colors.white, width: 2),
          //       ),
          //       child: Center(
          //         child:  ClipRRect(
          //           borderRadius: BorderRadius.circular(200),
          //           child: CachedNetworkImage(
          //             imageUrl: widget.imageUrl,
          //             width: 50,
          //             height: 50,
          //             fit: BoxFit.cover,
          //
          //             placeholder: (context, url) => const CircleAvatar(
          //               radius: 200,
          //               backgroundColor: Colors.grey,
          //             ),
          //             errorWidget: (context, url, error) =>
          //             const CircleAvatar(
          //               radius: 150,
          //               backgroundColor: Colors.grey,
          //               child: Icon(Icons.person,
          //                   color: Colors.white, size: 50),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //     ),


          // Status text showing call duration or calling status

          Positioned(bottom: 15, child: _buildBottomControls()),
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
          ? "Calling..."
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
                socketProvider.rejectCallEvent(callToUserId: widget.callerId);
                socketProvider.hangUpCallEvent(
                    targetId: widget.callerId,
                    whoHangUpCallId: signInModel!.data!.user!.sId!);
                socketProvider.leaveCallEvent(
                    callToUserId: widget.callerId,
                    callFromUserId: signInModel!.data!.user!.sId!);
                stopRinging();
                stopIncomingRinging(); // Stops incoming ringtone
                // if (mounted) {
                //   Navigator.pop(context);
                // }
              }),
          SizedBox(
            width: 100,
          ),
          _buildPillButton(
            icon: Icons.call,
            text: "Accept",
            color: Colors.green,
            onPressed: () async {
              try {
                debugPrint('📞 Accept button pressed');
                debugPrint('📞 Data structure: ${widget.dataOfSocket}');
                socketProvider.sendPeerMediaToggle(callToUserId: widget.callerId, micOn: true, cameraOn: false);

                // Check if peer connection is initialized
                if (_peerConnection == null) {
                  debugPrint('❌ Peer connection is null. Cannot accept call.');
                  // Try to wait a bit and retry once
                  await Future.delayed(const Duration(milliseconds: 500));
                  if (_peerConnection == null) {
                    debugPrint(
                        '❌ Peer connection still null after retry. Cannot accept call.');
                    return;
                  }
                }

                // Check if remote description is already set, if not set it
                final currentRemoteDesc =
                    await _peerConnection!.getRemoteDescription();
                if (currentRemoteDesc == null) {
                  // First, ensure the remote description is set
                  if (widget.dataOfSocket != null &&
                      widget.dataOfSocket['signal'] != null) {
                    debugPrint(
                        '📞 Signal data found: Type ${widget.dataOfSocket['signal']['type']}');

                    // Validate the data structure
                    if (widget.dataOfSocket['signal']['sdp'] == null ||
                        widget.dataOfSocket['signal']['type'] == null) {
                      debugPrint('❌ Invalid data structure for incoming call');
                      return;
                    }

                    final remoteDesc = RTCSessionDescription(
                      widget.dataOfSocket['signal']['sdp'],
                      widget.dataOfSocket['signal']['type'],
                    );

                    debugPrint(
                        '📞 Setting remote description with type: ${remoteDesc.type}');
                    await _peerConnection!.setRemoteDescription(remoteDesc);
                    debugPrint('📞 Remote description set successfully');
                  } else {
                    debugPrint('❌ No signal data available for incoming call');
                    return;
                  }
                } else {
                  debugPrint(
                      '📞 Remote description already set, proceeding with answer creation');
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

                // Update UI state to show in-call
                setState(() {
                  _isCallAccepted = true;
                });

                // Ensure audio is properly initialized
                _initializeAudioForCall();

                // Send the answer via signal (new approach)
                final localDesc = await _peerConnection!.getLocalDescription();
                socketProvider.sendAnswerSignal(
                  callToUserId: widget.callerId,
                  description: localDesc!.toMap(),
                );

                // Also emit accept call event for backward compatibility
                socketProvider.acceptCallEvent(
                    callToUserId: widget.callerId, signal: answer.toMap());
                stopIncomingRinging();
                _startTimer();

                // Update UI to show in-call state (similar to React JS)
                debugPrint('✅ Call accepted - both users now in call');
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

                // Emit peer media toggle event
                socketProvider.sendPeerMediaToggle(
                  callToUserId: widget.callerId,
                  micOn: !isMuted,
                  cameraOn: isVideoOn,
                );
              },
            ),
            SizedBox(
              width: 8,
            ),

            _buildControlButton(
              icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off_rounded,
              onPressed: () {
                // setState(() {
                //   isSpeakerOn = !isSpeakerOn;
                // });
                // Toggle speaker mode
                _toggleSpeakerMode();
              },
            ),
            SizedBox(
              width: 8,
            ),

         //    // Debug button for audio testing
         //    _buildControlButton(
         //      icon: Icons.screen_share,
         //      onPressed: () async{
         // await startScreenShareService();
         //
         //        final mediaConstraints = {
         //          'video': {'mandatory': {}, 'optional': []},
         //          'audio': true,
         //        };
         //        try {
         //          _localStream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
         //        if(_localStream != null){
         //          _localStream!.getTracks().forEach((track){
         //            _peerConnection?.addTrack(track, _localStream!);
         //          });
         //
         //        }
         //          // Use this stream in your peer connection
         //          print("Screen sharing started");
         //        } catch (e) {
         //          print("Error during screen sharing: $e");
         //        }
         //      },
         //    ),
         //    SizedBox(
         //      width: 8,
         //    ),

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
                // Emit peer media toggle event
                socketProvider.sendPeerMediaToggle(
                  callToUserId: widget.callerId,
                  micOn: !isMuted,
                  cameraOn: isVideoOn,
                );
              },
            ),
            SizedBox(
              width: 8,
            ),

            _buildControlButton(
              icon: Icons.call_end,
              color: Colors.red,
              onPressed: () {
                socketProvider.hangUpCallEvent(
                    targetId: widget.callerId,whoHangUpCallId: signInModel!.data!.user!.sId!);
                socketProvider.leaveCallEvent(callToUserId: widget.callerId,callFromUserId:  signInModel!.data!.user!.sId!);
                _cleanup();
                if (mounted) {
                  // Show end call message similar to React JS
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Call ended'),
                      backgroundColor: Colors.grey,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  // Navigator.pop(context);
                }
                stopRinging();
                stopIncomingRinging();
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
      setState(() {
      });
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

      // Force speakerphone on by default for calls
      _setSpeaker(true);

      // Enable all local audio tracks
      if (_localStream != null) {
        final localAudioTracks = _localStream!.getAudioTracks();
        if (localAudioTracks.isNotEmpty) {
          for (var track in localAudioTracks) {
            track.enabled = !isMuted;
            debugPrint('🎤 Local audio track enabled: ${track.enabled}, muted: ${track.muted}');
          }
        } else {
          debugPrint('❌ No local audio tracks found');
        }
      } else {
        debugPrint('❌ Local stream is null');
      }

      // Enable all remote audio tracks and ensure they're not muted
      if (_remoteStream != null) {
        final remoteAudioTracks = _remoteStream!.getAudioTracks();
        if (remoteAudioTracks.isNotEmpty) {
          for (var track in remoteAudioTracks) {
            track.enabled = true;
            debugPrint(
                '🎵 Remote audio track enabled: ${track.enabled}, muted: ${track.muted}');
          }
        } else {
          debugPrint('❌ No remote audio tracks found');
        }
      } else {
        debugPrint('❌ Remote stream is null');
      }

      // Set audio session for calls
      _configureAudioSession();

      debugPrint('🎵 Audio initialization complete');
    } catch (e) {
      debugPrint('❌ Error initializing audio: $e');
    }
  }

  void _configureAudioSession() async {
    try {
      // Configure audio session for voice calls
      await Helper.setSpeakerphoneOn(true);

      // Additional audio configuration for better call quality
      debugPrint('🔊 Audio session configured for calls');

      // Check audio state after configuration
      _checkAudioState();
    } catch (e) {
      debugPrint('❌ Error configuring audio session: $e');
    }
  }

  void _checkAudioState() {
    try {
      debugPrint('🔍 Checking detailed audio state...');

      // Check if remote stream has audio
      if (_remoteStream != null) {
        final audioTracks = _remoteStream!.getAudioTracks();
        debugPrint('🎵 Remote audio tracks count: ${audioTracks.length}');

        for (int i = 0; i < audioTracks.length; i++) {
          final track = audioTracks[i];
          debugPrint('🎵 Remote audio track $i: enabled=${track.enabled}, muted=${track.muted}');
        }
      }

      // Check if local stream has audio
      if (_localStream != null) {
        final audioTracks = _localStream!.getAudioTracks();
        debugPrint('🎤 Local audio tracks count: ${audioTracks.length}');

        for (int i = 0; i < audioTracks.length; i++) {
          final track = audioTracks[i];
          debugPrint('🎤 Local audio track $i: enabled=${track.enabled}, muted=${track.muted}');
        }
      }

      // Check peer connection state
      if (_peerConnection != null) {
        debugPrint('🔗 Peer connection state: ${_peerConnection!.connectionState}');
        debugPrint('🔗 Signaling state: ${_peerConnection!.signalingState}');
        debugPrint('🔗 ICE connection state: ${_peerConnection!.iceConnectionState}');
      }
    } catch (e) {
      debugPrint('❌ Error checking audio state: $e');
    }
  }

  void _ensureRemoteAudioEnabled() {
    try {
      if (_remoteStream != null) {
        final audioTracks = _remoteStream!.getAudioTracks();
        if (audioTracks.isNotEmpty) {
          for (var track in audioTracks) {
            if (!track.enabled) {
              track.enabled = true;
              debugPrint('🎵 Re-enabled remote audio track');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error ensuring remote audio enabled: $e');
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

  void _setInitialRemoteDescription() async {
    try {
      if (_peerConnection == null) {
        debugPrint('❌ Peer connection is null in _setInitialRemoteDescription');
        return;
      }

      if (widget.dataOfSocket != null && widget.dataOfSocket['signal'] != null) {
        final signal = widget.dataOfSocket['signal'];
        if (signal['sdp'] != null && signal['type'] != null) {
          final remoteDesc = RTCSessionDescription(
            signal['sdp'],
            signal['type'],
          );
          await _peerConnection!.setRemoteDescription(remoteDesc);
          debugPrint('📞 Initial remote description set successfully for incoming call');
        } else {
          debugPrint('❌ Invalid signal data structure for initial remote description');
        }
      }
    } catch (e) {
      debugPrint('❌ Error setting initial remote description: $e');
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

  void _forceAudioReinitialization() async {
    try {
      debugPrint('🔄 Force reinitializing audio...');

      // Force speakerphone on again
      await _setSpeaker(true);

      // Re-enable all remote audio tracks
      if (_remoteStream != null) {
        final audioTracks = _remoteStream!.getAudioTracks();
        for (var track in audioTracks) {
          track.enabled = true;
          debugPrint('🎵 Re-enabled remote audio track');
        }
      }

      // Re-enable all local audio tracks
      if (_localStream != null) {
        final audioTracks = _localStream!.getAudioTracks();
        for (var track in audioTracks) {
          track.enabled = !isMuted;
          debugPrint('🎤 Re-enabled local audio track');
        }
      }

      // Check audio state after reinitialization
      _checkAudioState();

      debugPrint('✅ Audio reinitialization complete');
    } catch (e) {
      debugPrint('❌ Error reinitializing audio: $e');
    }
  }

  void _testAudioOutput() async {
    try {
      debugPrint('🔊 Testing audio output...');

      // Create a simple audio test
      final testPlayer = AudioPlayer();
      await testPlayer.setReleaseMode(ReleaseMode.stop);

      // Play a short beep sound to test audio output
      await testPlayer.play(AssetSource(AppSound.ring));

      // Stop after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        testPlayer.stop();
        testPlayer.dispose();
        debugPrint('🔊 Audio test completed');
      });
    } catch (e) {
      debugPrint('❌ Error testing audio output: $e');
    }
  }
}

const MethodChannel _channel = MethodChannel('com.elsner.econnect/screen_share');

Future<void> startScreenShareService() async {
  try {
    await _channel.invokeMethod('startService');
  } on PlatformException catch (e) {
    print("Failed to start service: '${e.message}'.");
  }
}

Future<void> stopScreenShareService() async {
  try {
    await _channel.invokeMethod('stopService');
  } on PlatformException catch (e) {
    print("Failed to stop service: '${e.message}'.");
  }
}