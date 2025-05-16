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
import '../providers/channel_list_provider.dart';
import '../providers/common_provider.dart';
import '../screens/chat/single_chat_message_screen.dart';
import '../screens/channel/channel_chat_screen.dart';
import '../socket_io/socket_io.dart';
import '../utils/common/common_function.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Map<String, dynamic>? pendingNotification;

  static Future<void> initializeNotifications() async {
    await _initializeLocalNotifications();
    await _enableIOSNotifications();
    await _registerFirebaseListeners();
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidInitialize = AndroidInitializationSettings('@drawable/ic_notification');
    const iOSInitialize = DarwinInitializationSettings(
      requestBadgePermission: true,
      defaultPresentBadge: true,
    );
    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final String? payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          await _handleNotificationResponse(payload);
        }
      },
    );
  }

  static Future<void> _handleNotificationResponse(String payload) async {
    if (payload.contains('{')) {
      final Map<String, dynamic> payloadData = json.decode(payload);
      await handleNotificationRedirect(payloadData);
      await FlutterNewBadger.setBadge(int.parse(payloadData["badge"]));
    } else {
      await _openDownloadedFile(payload);
    }
  }

  static Future<void> handleNotificationRedirect(Map<String, dynamic> data) async {
    print("Handling notification redirect: $data");
    
    // Wait enough time for the app to be fully initialized
    await Future.delayed(const Duration(milliseconds: 1500));

    if (navigatorKey.currentState == null) {
      print("Navigator key is not initialized yet");
      // Store for later handling when the navigator is available
      pendingNotification = data;
      return;
    }

    try {
      // Clear any existing routes to prevent navigation stack issues
      if (navigatorKey.currentState!.canPop()) {
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
      }

      if (data['type'] == 'message') {
        await _navigateToChatScreen(data['senderId']);
      } else if (data['type'] == 'channel') {
        await _navigateToChannelScreen(data['senderId']);
      }
      
      // Update badge count
      try {
        if (data.containsKey("badge")) {
          await FlutterNewBadger.setBadge(int.parse(data["badge"]));
        } else if (data.containsKey("unreadCounts")) {
          await FlutterNewBadger.setBadge(int.parse(data["unreadCounts"]));
        }
      } catch (e) {
        print("Error setting badge: $e");
      }
    } catch (e) {
      print("Error in handleNotificationRedirect: $e");
    }
  }

  static Future<void> _navigateToChatScreen(String senderId) async {
    if (_isUserSignedIn()) {
    Provider.of<SocketIoProvider>(navigatorKey.currentState!.context, listen: false).connectSocket();
    Provider.of<CommonProvider>(navigatorKey.currentState!.context, listen: false).getUserByIDCall();
    }
    await Cf.instance.pushScreen(
      screen: SingleChatMessageScreen(
        userName: "",
        oppositeUserId: senderId,
        needToCallAddMessage: false,
        isFromNotification: true,
      ),
    );
  }

  static Future<void> _navigateToChannelScreen(String channelId) async {
    if (_isUserSignedIn()) {
    Provider.of<SocketIoProvider>(navigatorKey.currentState!.context, listen: false).connectSocket();
    Provider.of<CommonProvider>(navigatorKey.currentState!.context, listen: false).getUserByIDCall();
    }
    await Cf.instance.pushScreen(
      screen: ChannelChatScreen(
        channelId: channelId,
        isFromNotification: true,
      ),
    );
  }

  static bool _isUserSignedIn() {
    return signInModel!.data?.user?.id != null && signInModel!.data?.user?.id != "";
  }

  static Future<void> _openDownloadedFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        print("Error opening file: ${result.message}");
      }
    } else {
      print("File does not exist.");
    }
  }

  static Future<void> _registerFirebaseListeners() async {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationRedirect(message.data);
      Provider.of<SocketIoProvider>(navigatorKey.currentState!.context, listen: false).connectSocket(true);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showPushNotification(message);
    });

    // Handle notifications when the app is killed and then opened
    // The navigation will be handled in SplashProvider.whereToGO()
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) async {
      if (message != null) {
        print("Received initial message: ${message.data}");
        pendingNotification = message.data;
        
        // Only set badge count, don't navigate here
        try {
          if (message.data.containsKey("badge")) {
            await FlutterNewBadger.setBadge(int.parse(message.data["badge"]));
          } else if (message.data.containsKey("unreadCounts")) {
            await FlutterNewBadger.setBadge(int.parse(message.data["unreadCounts"]));
          }
        } catch (e) {
          print("Error setting badge: $e");
        }
      }
    });
  }

  static Future<void> _showPushNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = message.notification?.android;
      print("payload>>>>> ${message.data}");
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
            sound: RawResourceAndroidNotificationSound('sound'),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: int.parse(message.data["badge"]),
          ),
        ),
        payload: json.encode(message.data),
      );

      await FlutterNewBadger.setBadge(int.parse(message.data["badge"]));
    }
  }

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

  static Future<void> _enableIOSNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static AndroidNotificationChannel _androidNotificationChannel() {
    return const AndroidNotificationChannel(
      'econnect',
      'Econnect',
      showBadge: true,
      groupId: 'chat',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
  }

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

  static Future<int> getDeviceSdkForAndroid() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  }

  static Future<void> clearAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print("✅ All notifications cleared!");
  }
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
  static Future<void> clearBadgeCount() async {
    await FlutterNewBadger.setBadge(0);
    await FlutterNewBadger.removeBadge();
  }
}
