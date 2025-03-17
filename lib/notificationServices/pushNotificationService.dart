import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_new_badger/flutter_new_badger.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../screens/chat/single_chat_message_screen.dart';
import '../screens/channel/channel_chat_screen.dart';
import '../socket_io/socket_io.dart';
import '../utils/common/common_function.dart';
import '../providers/channel_list_provider.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Map<String, dynamic>? pendingNotification;

  static Future<void> initializeNotifications() async {
    const androidInitialize = AndroidInitializationSettings('@drawable/ic_notification');
    const iOSInitialize = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final String? payload = response.payload;
        print("Notification Click Payload: $payload");

        if (payload != null && payload.isNotEmpty) {
          if (payload.contains('{')) {
            // Push Notification Click Handling
            final Map<String, dynamic> payloadData = Map<String, dynamic>.from(json.decode(payload.replaceAll("'", '"')));
            handleNotificationRedirect(payloadData);
          } else {
            // File Download Click Handling
            openDownloadedFile(payload);
          }
        }
      },
    );

    enableIOSNotifications();
    registerFirebaseListeners();
    await setBadgeCount();
  }

  /// ✅ Handles navigation when user clicks on push notification
  static void handleNotificationRedirect(Map<String, dynamic> data) async {
    print("Handling Notification Click: $data");

    // Wait for the app to be fully initialized
    await Future.delayed(const Duration(milliseconds: 1000));

    if (navigatorKey.currentState == null) {
      print("Navigator key is not initialized yet");
      return;
    }

    try {
      // Clear any existing routes to prevent navigation stack issues
      if (navigatorKey.currentState!.canPop()) {
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
      }

      if (data['type'] == 'message') {
        if(signInModel.data?.user?.id != null && signInModel.data?.user?.id != ""){
          Provider.of<SocketIoProvider>(navigatorKey.currentState!.context, listen: false).connectSocket();
        }
        await pushScreen(
          screen: SingleChatMessageScreen(
              userName: "",
              oppositeUserId: data['senderId'],
              needToCallAddMessage: false,
              isFromNotification: true
          ),
        );
      } else if (data['type'] == 'channel') {
        if(signInModel.data?.user?.id != null && signInModel.data?.user?.id != "") {
          Provider.of<SocketIoProvider>(navigatorKey.currentState!.context, listen: false).connectSocket();
        }
        await pushScreen(
          screen: ChannelChatScreen(
            channelId: data['senderId'],
            isFromNotification: true,
          ),
        );
      }
      await setBadgeCount();
    } catch (e) {
      print("Error in handleNotificationRedirect: $e");
    }
  }

  /// ✅ Handles opening a downloaded file when user clicks on download notification
  static Future<void> openDownloadedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          print("Error opening file: ${result.message}");
        }
      } else {
        print("File does not exist.");
      }
    } catch (e) {
      print("Error opening file: $e");
    }
  }

  /// ✅ Registers Firebase Messaging Listeners
  static Future<void> registerFirebaseListeners() async {
    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) {
        print("onMessageOpenedApp: ${message.data}");
        handleNotificationRedirect(message.data);
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Firebase Notification Received: ${message.data}");
      _showPushNotification(message);
    });

    // ✅ Handle notifications when the app is killed and then opened
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("Handling notification from terminated state: ${message.data}");
        // Store the notification data to be handled after app initialization
        pendingNotification = message.data;
      }
    });
  }

  /// ✅ Shows push notifications
  static Future<void> _showPushNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      final AndroidNotificationChannel channel = _androidNotificationChannel();
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            styleInformation: BigTextStyleInformation(notification.body!),
            icon: '@drawable/ic_notification',
          ),
        ),
        payload: json.encode(message.data),
      );

      // Update badge count when notification is received
      await setBadgeCount();
    }
  }

  /// ✅ Shows file download notifications
  static Future<void> showDownloadNotification({
    required String fileName,
    required String filePath,
    required int notificationId,
    required bool isCompleted,
  }) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'download_channel',
      'File Download',
      channelDescription: 'Shows file download progress',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: !isCompleted,
      autoCancel: isCompleted,
    );

    DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      isCompleted ? 'Download Complete' : 'Downloading...',
      isCompleted ? 'Tap to open $fileName' : 'Downloading $fileName...',
      platformChannelSpecifics,
      payload: isCompleted ? filePath : null,
    );
  }

  /// ✅ Enable iOS Notifications
  static Future<void> enableIOSNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// ✅ Create Android Notification Channel
  static AndroidNotificationChannel _androidNotificationChannel() => const AndroidNotificationChannel(
    'econnect',
    'Econnect',
    showBadge: true,
    groupId: 'chat',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// ✅ Request Storage Permission for Android
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      int sdkInt = await getDeviceSdkForAndroid();
      if (sdkInt >= 30) {
        if (await Permission.manageExternalStorage.isGranted) {
          return true;
        } else {
          PermissionStatus status = await Permission.manageExternalStorage.request();
          return status == PermissionStatus.granted;
        }
      } else {
        PermissionStatus status = await Permission.storage.request();
        return status == PermissionStatus.granted;
      }
    }
    return true;
  }

  /// ✅ Get Android SDK Version
  static Future<int> getDeviceSdkForAndroid() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  }

  /// Calculate and set badge count based on unread messages
  static Future<void> setBadgeCount() async {
    try {
      final channelListProvider = Provider.of<ChannelListProvider>(navigatorKey.currentState!.context, listen: false);

      // Get unread counts from favorites
      int favoritesUnreadCount = 0;
      channelListProvider.favoriteListModel?.data?.chatList?.forEach((chat) {
        favoritesUnreadCount += (chat.unseenMessagesCount ?? 0).toInt();
      });
      channelListProvider.favoriteListModel?.data?.favouriteChannels?.forEach((channel) {
        favoritesUnreadCount += (channel.unseenMessagesCount ?? 0).toInt();
      });

      // Get unread counts from channels
      int channelsUnreadCount = 0;
      channelListProvider.channelListModel?.data?.forEach((channel) {
        channelsUnreadCount += (channel.unreadCount ?? 0).toInt();
      });

      // Get unread counts from direct messages
      int directMessagesUnreadCount = 0;
      channelListProvider.directMessageListModel?.data?.chatList?.forEach((chat) {
        directMessagesUnreadCount += (chat.unseenMessagesCount ?? 0).toInt();
      });

      // Calculate total unread count
      int totalUnreadCount = favoritesUnreadCount + channelsUnreadCount + directMessagesUnreadCount;

      // Update the badge count
      if (totalUnreadCount > 0) {
        await FlutterNewBadger.setBadge(totalUnreadCount);
      } else {
        await FlutterNewBadger.removeBadge();
      }
    } catch (e) {
      print("Error setting badge count: $e");
    }
  }

  static clearBadgeCount() async{
    await FlutterNewBadger.setBadge(0);
    await FlutterNewBadger.removeBadge();
  }

  static Future<void> clearAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print("✅ All notifications cleared!");
  }
}
