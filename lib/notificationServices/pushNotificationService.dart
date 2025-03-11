import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oktoast/oktoast.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../screens/chat/single_chat_message_screen.dart';
import '../screens/channel/channel_chat_screen.dart';
import '../utils/loading_widget/loading_cubit.dart';
import '../utils/common/common_function.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    const androidInitialize = AndroidInitializationSettings('@mipmap/ic_launcher');
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
            _handleNotificationRedirect(payloadData);
          } else {
            // File Download Click Handling
            _openDownloadedFile(payload);
          }
        }
      },
    );

    enableIOSNotifications();
    registerFirebaseListeners();
  }

  /// ✅ Handles navigation when user clicks on push notification
  static void _handleNotificationRedirect(Map<String, dynamic> data) {
    print("Handling Notification Click: $data");

    if (data['type'] == 'message') {
      pushScreen(
        screen: SingleChatMessageScreen(
          userName: "",
          oppositeUserId: data['senderId'],
          needToCallAddMessage: false,
          isFromNotification: true
        ),
      );
    } else if (data['type'] == 'channel') {
      pushScreen(
        screen: ChannelChatScreen(
          channelId: data['senderId'],
          isFromNotification: true,
        ),
      );
    }
  }

  /// ✅ Handles opening a downloaded file when user clicks on download notification
  static Future<void> _openDownloadedFile(String filePath) async {
    try {
      if (await requestStoragePermission()) {
        final file = File(filePath);

        if (await file.exists()) {
          final result = await OpenFile.open(filePath);
          if (result.type != ResultType.done) {
            if (Platform.isAndroid) {
              await launchUrl(Uri.parse("content://com.android.externalstorage.documents/document/primary:Download"));
            } else if (Platform.isIOS) {
              print("Could not open file on iOS: ${result.message}");
            }
          }
        } else {
          print("File does not exist: $filePath");
        }
      } else {
        print("Storage permission denied.");
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
        _handleNotificationRedirect(message.data);
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Firebase Notification Received: ${message.data}");
      _showPushNotification(message);
    });
  }

  /// ✅ Shows push notifications
  static Future<void> _showPushNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      final AndroidNotificationChannel channel = _androidNotificationChannel();
      flutterLocalNotificationsPlugin.show(
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
            icon: 'mipmap/ic_notification',
            color: AppColor.appBarColor,
            // colorized: true,
            // ledColor: AppColor.commonAppColor,
          ),
        ),
        payload: json.encode(message.data),
      );
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
}
