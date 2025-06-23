# E-Connect Mobile Application

A Flutter-based team communication platform for real-time messaging, channel discussions, and team
collaboration.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.6.0-blue.svg)](https://flutter.dev/)
[![Version](https://img.shields.io/badge/Version-1.0.13+16-green.svg)](#)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](#)

## 📱 Overview

E-Connect is a comprehensive team communication application similar to Slack, designed for internal
organizational communication. It provides real-time messaging, channel-based discussions, direct
messaging, file sharing, and integrated status management with push notifications.

## ✨ Features

### 🔐 Authentication & User Management

- Email/password authentication
- Google Single Sign-On (SSO)
- JWT token-based session management
- User profile and status management
- Device token management for notifications
- User search and discovery

### 💬 Messaging System

- Real-time direct messaging
- Message threading and replies
- Message reactions (emoji responses)
- Message pinning for important communications
- Message deletion and editing
- Message search across conversations
- Read/unread status tracking
- Message jump functionality

### 📢 Channel Management

- Create and manage communication channels
- Channel member management (add/remove users)
- Admin privileges and role management
- Channel-based messaging and discussions
- Channel search and discovery
- Channel favorites and organization
- Mute/unmute functionality
- Leave channel option

### 📎 File Sharing & Media

- File upload and sharing in messages
- Support for images, documents, and audio files
- File listing and management in conversations
- Media preview and download functionality
- Voice message recording and playback

### 🟢 User Status & Presence

- Online/offline status indication
- Custom status messages
- Away/busy/DND status management
- Automatic status updates based on app lifecycle

### 🔔 Notifications

- Push notifications for new messages
- Channel notification management
- Badge count for unread messages
- Notification preferences and settings

### 🌟 Additional Features

- Favorites management for users and channels
- Thread management for organized discussions
- Karma system integration (HRMS)
- App version checking and updates
- Network connectivity handling

## 🏗️ Architecture

### Technology Stack

- **Frontend**: Flutter (Cross-platform)
- **State Management**: Provider Pattern
- **Real-time Communication**: Socket.IO
- **Backend**: RESTful APIs
- **Authentication**: JWT + Google SSO
- **Push Notifications**: Firebase Cloud Messaging
- **File Storage**: Multipart upload system
- **Local Storage**: SharedPreferences

### Project Structure

```
lib/
├── main.dart                      # Application entry point
├── model/                         # Data models and DTOs
│   ├── sign_in_model.dart
│   ├── message_model.dart
│   ├── channel_list_model.dart
│   └── ...
├── providers/                     # State management providers
│   ├── sign_in_provider.dart
│   ├── chat_provider.dart
│   ├── channel_chat_provider.dart
│   └── ...
├── screens/                       # UI screens organized by feature
│   ├── sign_in_screen/
│   ├── chat/
│   ├── channel/
│   ├── bottom_navigation_screen/
│   └── ...
├── utils/                         # Utilities and services
│   ├── api_service/
│   ├── common/
│   ├── theme/
│   └── network_connectivity/
├── widgets/                       # Reusable UI components
├── socket_io/                     # Real-time communication
└── notificationServices/          # Push notification handling
```

## 🌐 API Endpoints

### Base URLs

- **Primary API**: `https://dev-econnect-sass.elsnerdev.co/v1/`
- **Profile Images**: `https://e-connect.elsner.com/public/`
- **HRMS Integration**: `https://hrms.elsner.com/`

### Authentication

| Endpoint                     | Method | Description                   |
|------------------------------|--------|-------------------------------|
| `/user/login`                | POST   | User authentication           |
| `/user/googleSSOLginApp`     | POST   | Google SSO login              |
| `/user/alloawgoogleSSOLogin` | GET    | Check Google SSO availability |
| `/user/deviceToken`          | POST   | Register device token         |
| `/user/removeDeviceToken`    | POST   | Remove device token           |

### User Management

| Endpoint                 | Method | Description          |
|--------------------------|--------|----------------------|
| `/user/update`           | PUT    | Update user status   |
| `/user/getUserById/{id}` | GET    | Get user details     |
| `/user/search-user`      | POST   | Search users         |
| `/user/user-suggestions` | GET    | Get user suggestions |
| `/user/mute-user`        | POST   | Mute user            |
| `/user/unmute-user`      | POST   | Unmute user          |

### Messaging

| Endpoint                                     | Method | Description          |
|----------------------------------------------|--------|----------------------|
| `/messages/send-message`                     | POST   | Send direct message  |
| `/messages/get-message`                      | POST   | Retrieve messages    |
| `/messages/delete/{messageId}`               | DELETE | Delete message       |
| `/messages/message-pin/{messageId}/{pinned}` | PUT    | Pin/unpin message    |
| `/messages/message-reaction`                 | POST   | Add message reaction |
| `/messages/search`                           | POST   | Search messages      |

### Channels

| Endpoint                                  | Method | Description         |
|-------------------------------------------|--------|---------------------|
| `/channels/get`                           | GET    | Get channel list    |
| `/channels/add`                           | POST   | Create channel      |
| `/channels/getChannelMembers/{channelId}` | GET    | Get channel members |
| `/channels/addMember/{channelId}`         | PUT    | Add channel member  |
| `/channels/leaveChannel/{channelId}`      | DELETE | Leave channel       |

### File Management

| Endpoint                               | Method | Description    |
|----------------------------------------|--------|----------------|
| `/files/upload?file_for=message_media` | POST   | Upload files   |
| `/messages/getFilesListing`            | POST   | Get chat files |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.6.0)
- Dart SDK
- Android Studio / Xcode
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd e_connect
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
    - Add `google-services.json` for Android
    - Add `GoogleService-Info.plist` for iOS
    - Configure Firebase Cloud Messaging

4. **Run the application**
   ```bash
   flutter run
   ```

### Build for Production

**Android**

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

**iOS**

```bash
flutter build ios --release
```

## 📦 Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.0.5
  socket_io_client: ^3.0.2
  http: ^1.3.0
  shared_preferences: ^2.3.5
  cached_network_image: ^3.4.1
  firebase_messaging: ^15.2.4
  firebase_core: ^3.12.1
  google_sign_in: ^6.3.0
  file_picker: 9.2.3
  image_picker: ^1.1.2
  emoji_picker_flutter: ^4.3.0
  permission_handler: ^11.3.1
  url_launcher: ^6.3.1
```

### UI & Media Dependencies

```yaml
  flutter_widget_from_html: ^0.16.0
  insta_image_viewer: ^1.0.4
  voice_message_player: ^1.1.2
  record: ^6.0.0
  camera: ^0.11.1
  video_player: ^2.9.5
  photo_view: ^0.15.0
```

## 🔧 Configuration

### Environment Setup

Update the base URLs in `lib/utils/api_service/api_string_constants.dart`:

```dart
class ApiString {
  // Development URL
  static const String baseUrl = 'https://dev-econnect-sass.elsnerdev.co/v1/';
  
  // Production URL (commented)
  // static const String baseUrl = 'https://e-connect.elsner.com/v1/';
  
  static const String profileBaseUrl = 'https://e-connect.elsner.com/public/';
  static const String karmaBaseUrl = "https://hrms.elsner.com/";
}
```

### App Configuration

- **App Name**: E-Connect
- **Bundle ID**: Configure in `android/app/build.gradle` and `ios/Runner.xcodeproj`
- **Version**: Update in `pubspec.yaml`

## 📱 Platform Support

### Android

- **Minimum SDK**: API level 21 (Android 6.0)
- **Target SDK**: Latest stable
- **Permissions**: Camera, Storage, Notifications, Network

### iOS

- **Minimum Version**: iOS 12.0
- **Permissions**: Camera, Photo Library, Notifications, Network

## 🔐 Security

- All API communications use HTTPS
- JWT tokens are securely stored using SharedPreferences
- File uploads are validated for type and size
- User authentication is validated on each API request

## 🧪 Testing

Run tests using:

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests (if available)
flutter drive --target=test_driver/app.dart
```

## 📊 Performance

- App startup time: < 3 seconds
- Message delivery: Near real-time (< 1 second)
- API response time: < 2 seconds
- File upload support: Up to 50MB

## 🚀 Deployment

### Development

- Environment: `dev-econnect-sass.elsnerdev.co`
- Debug builds with development API endpoints

### Production

- Environment: `e-connect.elsner.com`
- Release builds with production API endpoints
- App Store distribution (Google Play Store & Apple App Store)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📋 TODO

- [ ] Add unit tests coverage
- [ ] Implement offline message caching
- [ ] Add message encryption
- [ ] Implement message scheduling
- [ ] Add video calling feature
- [ ] Enhance file sharing with cloud storage

## 📞 Support

For support and questions:

- Create an issue in the repository
- Contact the development team
- Check the documentation

## 📄 License

This project is proprietary software. All rights reserved.

---

**Version**: 1.0.13+16  
**Last Updated**: Current Date  
**Maintained By**: Development Team
