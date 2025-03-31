import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../utils/api_service/api_string_constants.dart';
import '../utils/app_color_constants.dart';
import '../utils/app_preference_constants.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final Map<String, AudioPlayer> audioPlayers;
  final Map<String, Duration> audioDurations;
  final Function(String, AudioPlayer) onPlaybackStart;
  final AudioPlayer? currentlyPlayingPlayer;
  final bool isForwarded; // Add isForwarded flag

  const AudioPlayerWidget({
    Key? key,
    required this.audioUrl,
    required this.audioPlayers,
    required this.audioDurations,
    required this.onPlaybackStart,
    required this.currentlyPlayingPlayer,
    this.isForwarded = false, // Default to false for normal messages
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}
class _AudioPlayerWidgetState extends State<AudioPlayerWidget> with AutomaticKeepAliveClientMixin {
  late AudioPlayer _player;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration? _duration;
  Timer? _positionTimer;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  Future<void> _setupPlayer() async {
    // Create a unique key based on whether it's forwarded or not
    String playerKey = widget.isForwarded ? "forwarded_${widget.audioUrl}" : "normal_${widget.audioUrl}";
    _player = widget.audioPlayers[playerKey] ?? AudioPlayer();
    widget.audioPlayers[playerKey] = _player;

    try {
      await _player.setUrl("${ApiString.profileBaseUrl}${widget.audioUrl}");

      _duration = widget.audioDurations[widget.audioUrl];
      if (_duration == null) {
        final newDuration = await _player.duration;
        if (newDuration != null) {
          _duration = newDuration;
          widget.audioDurations[widget.audioUrl] = newDuration;
        }
      }

      // Listen to player state changes
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            _isInitialized = true;

            // Check if playback has completed
            if (state.processingState == ProcessingState.completed) {
              _isPlaying = false;
              _position = Duration.zero;
              _player.seek(Duration.zero);
            }
          });
        }
      });

      // Listen to position changes
      _player.positionStream.listen((position) {
        if (mounted) {
          setState(() => _position = position);

          // Check if we've reached the end
          if (_duration != null && position >= _duration!) {
            _player.seek(Duration.zero);
            _player.pause();
            setState(() {
              _isPlaying = false;
              _position = Duration.zero;
            });
          }
        }
      });

    } catch (e) {
      print('Error setting up audio player: $e');
    }
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      // Stop all other players that match our forwarded state
      for (var entry in widget.audioPlayers.entries) {
        if (entry.value != _player && entry.key.startsWith(widget.isForwarded ? "forwarded_" : "normal_")) {
          await entry.value.pause();
        }
      }

      // If we're at the end, reset position before playing
      if (_position >= (_duration ?? Duration.zero)) {
        await _player.seek(Duration.zero);
        setState(() => _position = Duration.zero);
      }
      widget.onPlaybackStart(widget.audioUrl, _player);
      await _player.play();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Play/Pause Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : AppColor.blueColor,
            ),
            child: IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.blueColor : Colors.white,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              onPressed: _playPause,
            ),
          ),
          SizedBox(width: 12),

          // Progress and Duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waveform/Progress bar
                Container(
                  height: 24,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Background waveform
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          20,
                              (index) => Container(
                            width: 3,
                            height: (index % 2 == 0 ? 15.0 : 10.0),
                            decoration: BoxDecoration(
                              color: AppPreferenceConstants.themeModeBoolValueGet ?
                              Colors.white.withOpacity(0.3) : AppColor.blueColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                      ),
                      // Progress waveform
                      ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: _duration != null ?
                          (_position.inMilliseconds / _duration!.inMilliseconds).clamp(0.0, 1.0) : 0.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              20,
                                  (index) => Container(
                                width: 3,
                                height: index % 2 == 0 ? 15.0 : 10.0,
                                decoration: BoxDecoration(
                                  color: AppPreferenceConstants.themeModeBoolValueGet ?
                                  Colors.white : AppColor.blueColor,
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                // Duration text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppPreferenceConstants.themeModeBoolValueGet ?
                        Colors.white.withOpacity(0.7) : Colors.grey[600],
                      ),
                    ),
                    Text(
                      _formatDuration(_duration ?? Duration.zero),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppPreferenceConstants.themeModeBoolValueGet ?
                        Colors.white.withOpacity(0.7) : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
