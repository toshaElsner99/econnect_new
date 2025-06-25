import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:e_connect/main.dart';

import '../../socket_io/socket_io.dart'; // For signInModel access

class CallPage extends StatefulWidget {
  final String oppositeUserId;

  const CallPage({required this.oppositeUserId, super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context,listen: false);


  @override
  void initState() {
    super.initState();
    _initRenderers();
    _connectSocket();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _connectSocket() {

      _startCall();


    // socket.on('answer', (data) async {
    //   debugPrint("📥 Received answer");
    //   await _peerConnection?.setRemoteDescription(
    //     RTCSessionDescription(data['sdp'], data['type']),
    //   );
    // });
    //
    // socket.on('signal', (data) async {
    //   final innerData = data['data'];
    //   if (innerData?['candidate'] != null) {
    //     debugPrint("📥 Received ICE candidate");
    //     await _peerConnection?.addCandidate(RTCIceCandidate(
    //       innerData['candidate']['candidate'],
    //       innerData['candidate']['sdpMid'],
    //       innerData['candidate']['sdpMLineIndex'],
    //     ));
    //   } else if (innerData?['description'] != null) {
    //     debugPrint("📥 Received remote SDP description");
    //     await _peerConnection?.setRemoteDescription(RTCSessionDescription(
    //       innerData['description']['sdp'],
    //       innerData['description']['type'],
    //     ));
    //   }
    // });
  }

  Future<void> _startCall() async {
    await _createPeerConnection();

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    final desc = await _peerConnection!.getLocalDescription();
    debugPrint('📞 Created offer: ${offer.sdp}');
    socketProvider.sendSignalForCall(widget.oppositeUserId, desc!.toMap());
    socketProvider.callAnyUser(widget.oppositeUserId, signInModel!.data!.user!.sId!, signInModel!.data!.user!.fullName ?? signInModel!.data!.user!.userName ?? '', offer);
    // socket.emit('callUser', {
    //   'toUserId': widget.oppositeUserId,
    //   'fromUserId': signInModel!.data!.user!.sId,
    //   'signal': {
    //     'sdp': offer.sdp,
    //     'type': offer.type,
    //   },
    //   'discussionId': 'discussion-1234',
    //   'name': signInModel!.data!.user!.fullName ?? signInModel!.data!.user!.userName ?? 'Caller',
    //   'cameraOn': true,
    //   'micOn': true,
    // });

    // Auto hang up after 60 seconds if not answered
    Future.delayed(const Duration(seconds: 60), () {
      if (_peerConnection?.connectionState != RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        // socket.emit('hangUp', {
        //   'toUserId': widget.oppositeUserId,
        //   'oppositeUserId': signInModel!.data!.user!.sId,
        // });
        debugPrint('📞 Call timed out');
        if (mounted) Navigator.pop(context);
      }
    });
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

    _peerConnection?.onTrack = (event) {
      debugPrint('📡 onTrack called, streams: ${event.streams.length}');
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
        debugPrint('✅ Set remote stream');
      } else {
        debugPrint('❌ No remote streams in onTrack');
      }
    };

    _peerConnection?.onIceCandidate = (candidate) {
      if (candidate != null) {
        // socket.emit('signal', {
        //   'toUserId': widget.oppositeUserId,
        //   'data': {
        //     'candidate': {
        //       'candidate': candidate.candidate,
        //       'sdpMid': candidate.sdpMid,
        //       'sdpMLineIndex': candidate.sdpMLineIndex,
        //     }
        //   }
        // });
      }
    };

    _peerConnection?.onRenegotiationNeeded = () async {
      try {
        // final offer = await _peerConnection!.createOffer();
        // await _peerConnection!.setLocalDescription(offer);
        // socketProvider.callAnyUser(widget.oppositeUserId, signInModel!.data!.user!.sId!, signInModel!.data!.user!.fullName ?? signInModel!.data!.user!.userName ?? '', offer);

        // socket.emit('signal', {
        //   'toUserId': widget.oppositeUserId,
        //   'data': {
        //     'description': {
        //       'sdp': offer.sdp,
        //       'type': offer.type,
        //     }
        //   }
        // });
      } catch (e) {
        debugPrint('❌ Error during renegotiation: $e');
      }
    };

    _peerConnection?.onConnectionState = (state) {
      debugPrint('🔄 Connection state changed: $state');

      switch (state) {
        case 'connected':
        // Call connected
          break;
        case 'disconnected':
        case 'failed':
        case 'closed':
          if (mounted) Navigator.pop(context);
          break;
        default:
        // Handle other states if needed
          break;
      }
    };

  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call')),
      body: Column(
        children: [
          Expanded(
            child: _localStream != null
                ? RTCVideoView(_localRenderer, mirror: true)
                : const Center(child: Text('No local stream', style: TextStyle(color: Colors.red))),
          ),
          Expanded(
            child: (_remoteRenderer.srcObject != null)
                ? RTCVideoView(_remoteRenderer)
                : const Center(child: Text('No remote stream', style: TextStyle(color: Colors.red))),
          ),
        ],
      ),
    );
  }
}
