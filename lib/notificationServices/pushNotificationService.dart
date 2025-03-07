import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../screens/chat/single_chat_message_screen.dart';
import '../screens/channel/channel_chat_screen.dart';
import '../utils/common/common_function.dart';
// import '../general_exports.dart';
class PushNotificationService {

  void handleNotificationRedirect(Map<String, dynamic> data) {
    if (data['type'] == 'message') {
      // Handle single chat notification
      final senderId = data['senderId'];
      pushScreen(
        screen: SingleChatMessageScreen(
          userName: "",
          oppositeUserId: senderId,
          needToCallAddMessage: false
        ),
      );
    }
    // else if (data['type'] == 'channel') {
    //   // Handle channel notification
    //   final channelId = data['senderId'];
    //   pushScreen(
    //     screen: ChannelChatScreen(
    //       channelId: channelId,
    //     ),
    //   );
    // }
  }

  Future<void> setupInteractedMessage() async {
    // This function is called when ios app is opened, for android case `onDidReceiveNotificationResponse` function is called
    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) {
            // notificationRedirect(message.data[keyTypeValue], message.data[keyType]);
            print("onMessageOpenedApp :::> ${message.data}");
            handleNotificationRedirect(message.data);
      },
    );
    enableIOSNotifications();
    await registerNotificationListeners();
  }

  Future<void> registerNotificationListeners() async {
    final AndroidNotificationChannel channel = androidNotificationChannel();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    // flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>().requestNotificationsPermission();
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('mipmap/ic_launcher');
    const DarwinInitializationSettings iOSSettings =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings, iOS: iOSSettings);
    flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Convert payload string to map
        if (details.payload != null) {
          final Map<String, dynamic> payloadData = Map<String, dynamic>.from(
            json.decode(details.payload!.replaceAll("'", '"'))
          );
          handleNotificationRedirect(payloadData);
        }
      },
    );
    // _fcmToken = (await FirebaseMessaging.instance.getToken())!;
    // print("firebase token :- $_fcmToken");
    // FirebaseMessaging.instance.onTokenRefresh.listen((event) {
    //   //API call can be done here to update token in back-end
    //   _fcmToken = event;
    //   print("firebase token refresh :- $_fcmToken");
    // });
    // LoginProvider loginProvider = Provider.of<LoginProvider>(navigatorKey.currentState!.context, listen: false);
    // loginProvider.setDToken(token: _fcmToken);
// onMessage is called when the app is in foreground and a notification is received
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // consoleLog(message, key: 'firebase_message');
      // print("firebase_message :::> ${message?.contentAvailable}");
      // print("firebase_message1 :::> ${message?.data}");
      // print("firebase_message3 :::> ${message?.notification!.toMap()}");
      // print("firebase_message5 :::> ${message?.notification!.web!.link}");
        final RemoteNotification? notification = message.notification;
      final AndroidNotification? android = message.notification?.android;

// If `onMessage` is triggered with a notification, construct our own
// local notification to show to users using the created channel.
      if (notification != null && android != null) {
        print("hashcode :::> ${notification.hashCode}");
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
              icon: android.smallIcon,
            ),
          ),
          payload: json.encode(message.data), // Store the data as JSON string
        );
        print("notification :::> ${message.data}");
      }
    });
  }
  Future<void> enableIOSNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  AndroidNotificationChannel androidNotificationChannel() =>
      const AndroidNotificationChannel(
        'econnect', // id
        'Econnect', // title
        showBadge: true,
        groupId: 'chat',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
}




