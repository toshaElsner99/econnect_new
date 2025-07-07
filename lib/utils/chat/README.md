# Chat Utils - Audio Recording Mixin

## Overview

The `AudioRecordingMixin` provides a reusable audio recording functionality for chat screens. It eliminates code duplication between single chat and channel chat screens by centralizing all audio recording logic.

## Features

- ✅ Audio recording with permission handling
- ✅ Recording timer with formatted duration display
- ✅ Audio preview before sending
- ✅ File upload and message sending
- ✅ Audio playback management
- ✅ Resource cleanup and disposal
- ✅ Support for both single chat and channel chat

## Usage

### 1. Import the Mixin

```dart
import 'package:your_app/utils/chat/audio_recording_mixin.dart';
```

### 2. Add Mixin to Your State Class

```dart
class _YourChatScreenState extends State<YourChatScreen> 
    with AudioRecordingMixin {
  // Your existing code...
}
```

### 3. Initialize in initState()

```dart
@override
void initState() {
  super.initState();
  initializeRecorder();
}
```

### 4. Implement Required Method

```dart
@override
Future<void> clearDraftMessage() async {
  // Implement draft message clearing logic
  // This is specific to your chat type (single/channel)
}
```

### 5. Clean Up in dispose()

```dart
@override
void dispose() {
  disposeAudioRecording();
  super.dispose();
}
```

## Available Methods

### Core Recording Methods

- `initializeRecorder()` - Initialize the audio recorder
- `toggleRecording()` - Start/stop recording
- `cancelRecording()` - Cancel current recording
- `formatDuration(Duration)` - Format duration to MM:SS or HH:MM:SS

### Audio Sending Methods

- `sendAudioSingleChat()` - Send audio in single chat
- `sendAudioChannelChat()` - Send audio in channel chat
- `sendAudioMessage()` - Generic audio sending with scroll handling

### Audio Playback Methods

- `handleAudioPlayback(String, AudioPlayer)` - Manage audio playback
- `disposeAudioRecording()` - Clean up audio resources

## State Variables

### Getters
- `isRecording` - Current recording state
- `audioPath` - Path to recorded audio file
- `recordingDuration` - Current recording duration
- `showAudioPreview` - Whether to show audio preview
- `audioPlayers` - Map of audio players
- `currentlyPlayingPlayer` - Currently playing audio player

### Setters
- `audioPath` - Set audio file path
- `showAudioPreview` - Set preview visibility
- `recordingDuration` - Set recording duration

## Example Implementation

### Single Chat Screen

```dart
class _SingleChatMessageScreenState extends State<SingleChatMessageScreen> 
    with AudioRecordingMixin {
  
  @override
  void initState() {
    super.initState();
    initializeRecorder();
  }

  @override
  void dispose() {
    disposeAudioRecording();
    super.dispose();
  }

  @override
  Future<void> clearDraftMessage() async {
    // Single chat draft clearing logic
  }

  Widget buildAudioInput() {
    return Row(
      children: [
        if (!isRecording && !showAudioPreview) ...[
          GestureDetector(
            onTap: () => toggleRecording(),
            child: Icon(Icons.mic),
          ),
        ],
        if (isRecording) ...[
          Text(formatDuration(recordingDuration)),
          IconButton(
            onPressed: cancelRecording,
            icon: Icon(Icons.close),
          ),
          IconButton(
            onPressed: toggleRecording,
            icon: Icon(Icons.stop),
          ),
        ],
        if (showAudioPreview) ...[
          Icon(Icons.audio_file),
          Text(formatDuration(recordingDuration)),
          IconButton(
            onPressed: () => sendAudioMessage(
              showScrollToBottomButton: _showScrollToBottomButton,
              reloadPageOne: reloadPageOne,
              sendAudioFunction: () => sendAudioSingleChat(
                oppositeUserId: oppositeUserId,
                showScrollToBottomButton: _showScrollToBottomButton,
                reloadPageOne: reloadPageOne,
              ),
            ),
            icon: Icon(Icons.send),
          ),
        ],
      ],
    );
  }
}
```

### Channel Chat Screen

```dart
class _ChannelChatScreenState extends State<ChannelChatScreen> 
    with AudioRecordingMixin {
  
  @override
  void initState() {
    super.initState();
    initializeRecorder();
  }

  @override
  void dispose() {
    disposeAudioRecording();
    super.dispose();
  }

  @override
  Future<void> clearDraftMessage() async {
    // Channel chat draft clearing logic
  }

  Widget buildAudioInput() {
    return Row(
      children: [
        if (!isRecording && !showAudioPreview) ...[
          GestureDetector(
            onTap: () => toggleRecording(),
            child: Icon(Icons.mic),
          ),
        ],
        if (isRecording) ...[
          Text(formatDuration(recordingDuration)),
          IconButton(
            onPressed: cancelRecording,
            icon: Icon(Icons.close),
          ),
          IconButton(
            onPressed: toggleRecording,
            icon: Icon(Icons.stop),
          ),
        ],
        if (showAudioPreview) ...[
          Icon(Icons.audio_file),
          Text(formatDuration(recordingDuration)),
          IconButton(
            onPressed: () => sendAudioMessage(
              showScrollToBottomButton: _showScrollToBottomButton,
              reloadPageOne: reloadPageOne,
              sendAudioFunction: () => sendAudioChannelChat(
                channelId: channelId,
                showScrollToBottomButton: _showScrollToBottomButton,
                reloadPageOne: reloadPageOne,
              ),
            ),
            icon: Icon(Icons.send),
          ),
        ],
      ],
    );
  }
}
```

## Benefits

1. **Code Reduction**: Eliminates ~200 lines of duplicated code per screen
2. **Consistency**: Both screens behave identically for audio recording
3. **Maintainability**: Single source of truth for audio recording logic
4. **Testing**: Easier to test isolated audio functionality
5. **Performance**: Shared logic reduces memory usage

## Dependencies

Make sure you have these dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  record: ^latest_version
  just_audio: ^latest_version
  path_provider: ^latest_version
  provider: ^latest_version
```

## Migration Guide

### From Single Chat Screen

1. Remove all audio recording variables
2. Remove all audio recording methods
3. Add `with AudioRecordingMixin` to your state class
4. Call `initializeRecorder()` in `initState()`
5. Call `disposeAudioRecording()` in `dispose()`
6. Implement `clearDraftMessage()` method
7. Update UI to use mixin methods and getters

### From Channel Chat Screen

Follow the same steps as single chat screen migration.

## Troubleshooting

### Common Issues

1. **Permission Denied**: Check microphone permissions in app settings
2. **Audio Not Playing**: Ensure `just_audio` plugin is properly configured
3. **File Not Found**: Verify file path generation in `getFilePath()`
4. **Memory Leaks**: Always call `disposeAudioRecording()` in dispose

### Debug Tips

- Use `debugPrint()` statements in the mixin for debugging
- Check console logs for permission and file path issues
- Verify audio file format compatibility (m4a recommended) 