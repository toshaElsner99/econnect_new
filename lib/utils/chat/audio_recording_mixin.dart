import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../app_preference_constants.dart';
import '../app_string_constants.dart';
import '../../providers/chat_provider.dart';
import '../../providers/channel_chat_provider.dart';
import '../../providers/file_service_provider.dart';

/// Mixin providing audio recording functionality for chat screens
mixin AudioRecordingMixin<T extends StatefulWidget> on State<T> {
  // Audio recording variables
  late AudioRecorder _record;
  bool _isRecording = false;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  bool _showAudioPreview = false;
  String? _previewAudioPath;
  final Map<String, Duration> _audioDurations = {};
  final _audioPlayer = AudioPlayer();

  // Audio players for voice messages
  final Map<String, AudioPlayer> _audioPlayers = {};
  AudioPlayer? _currentlyPlayingPlayer;

  /// Initialize the audio recorder
  Future<void> initializeRecorder() async {
    _record = AudioRecorder();
    bool hasPermission = await _record.hasPermission();
    if (!hasPermission) {
      debugPrint("Recording permission denied!");
    }
  }

  /// Start the recording timer
  void startRecordingTimer() {
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration += Duration(seconds: 1);
      });
    });
  }

  /// Stop the recording timer
  void stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  /// Format duration to MM:SS or HH:MM:SS format
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  /// Get file path for audio recording
  Future<String> getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  /// Toggle recording state (start/stop)
  Future<void> toggleRecording() async {
    if (_isRecording) {
      final path = await _record.stop();
      stopRecordingTimer();
      setState(() {
        _isRecording = false;
        _audioPath = path;
        _showAudioPreview = true;
        _previewAudioPath = path;
      });
      debugPrint("Recording saved at: $_audioPath");
    } else {
      if (await _record.hasPermission()) {
        final path = await getFilePath();
        await _record.start(RecordConfig(encoder: AudioEncoder.aacLc), path: path);
        setState(() {
          _isRecording = true;
          _recordingDuration = Duration.zero;
          _showAudioPreview = false;
        });
        startRecordingTimer();
      }
    }
  }

  /// Cancel current recording
  void cancelRecording() async {
    if (_isRecording) {
      await _record.stop();
      stopRecordingTimer();
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
        _showAudioPreview = false;
      });
    }
  }

  /// Send audio message for single chat
  Future<void> sendAudioSingleChat({
    required String oppositeUserId,
    required bool showScrollToBottomButton,
    required VoidCallback reloadPageOne,
  }) async {
    if (_audioPath != null) {
      try {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        final uploadedFiles = await chatProvider.uploadFilesForAudio([_audioPath!]);
        
        await chatProvider.sendMessage(
          content: "",
          receiverId: oppositeUserId,
          files: uploadedFiles,
        );

        // Clear the audio state after successful send
        setState(() {
          _audioPath = null;
          _showAudioPreview = false;
          _recordingDuration = Duration.zero;
        });
        
        // Clear draft message after sending audio
        await clearDraftMessage();
      } catch (e) {
        debugPrint("Error sending audio message: $e");
      }
    }
  }

  /// Send audio message for channel chat
  Future<void> sendAudioChannelChat({
    required String channelId,
    required bool showScrollToBottomButton,
    required VoidCallback reloadPageOne,
  }) async {
    if (_audioPath != null) {
      try {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        final channelChatProvider = Provider.of<ChannelChatProvider>(context, listen: false);
        
        final uploadedFiles = await chatProvider.uploadFilesForAudio([_audioPath!]);
        
        await channelChatProvider.sendMessage(
          content: "", 
          channelId: channelId, 
          files: uploadedFiles
        );

        // Clear the audio state after successful send
        setState(() {
          _audioPath = null;
          _showAudioPreview = false;
          _recordingDuration = Duration.zero;
        });
        
        // Clear draft message after sending audio
        await clearDraftMessage();
      } catch (e) {
        debugPrint("Error sending audio message: $e");
      }
    }
  }

  /// Send audio message with scroll handling
  void sendAudioMessage({
    required bool showScrollToBottomButton,
    required VoidCallback reloadPageOne,
    required Future<void> Function() sendAudioFunction,
  }) async {
    if (showScrollToBottomButton) {
      reloadPageOne();
      Future.delayed(Duration(seconds: 3), () async {
        await sendAudioFunction();
      });
    } else {
      await sendAudioFunction();
    }
  }

  /// Handle audio playback
  void handleAudioPlayback(String audioUrl, AudioPlayer player) {
    // If there's already an audio playing and it's different from the new one
    if (_currentlyPlayingPlayer != null && _currentlyPlayingPlayer != player) {
      _currentlyPlayingPlayer!.stop();
    }
    setState(() => _currentlyPlayingPlayer = player);
  }

  /// Clear draft message (to be implemented by the using class)
  Future<void> clearDraftMessage() async {
    // This should be implemented by the class using this mixin
    // as it depends on the specific chat type (single/channel)
  }

  /// Dispose audio recording resources
  void disposeAudioRecording() {
    // Dispose all audio players
    for (var player in _audioPlayers.values) {
      player.dispose();
    }
    _audioPlayers.clear();
    _audioDurations.clear();
    _recordingTimer?.cancel();
    _record.dispose();
  }

  // Getters for state variables
  bool get isRecording => _isRecording;
  String? get audioPath => _audioPath;
  Duration get recordingDuration => _recordingDuration;
  bool get showAudioPreview => _showAudioPreview;
  String? get previewAudioPath => _previewAudioPath;
  Map<String, Duration> get audioDurations => _audioDurations;
  Map<String, AudioPlayer> get audioPlayers => _audioPlayers;
  AudioPlayer? get currentlyPlayingPlayer => _currentlyPlayingPlayer;

  // Setters for state variables
  set audioPath(String? value) => _audioPath = value;
  set showAudioPreview(bool value) => _showAudioPreview = value;
  set recordingDuration(Duration value) => _recordingDuration = value;
} 