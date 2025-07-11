import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/providers/channel_list_provider.dart';
import 'package:e_connect/providers/chat_provider.dart';
import 'package:e_connect/providers/common_provider.dart';
import 'package:e_connect/providers/download_provider.dart';
import 'package:e_connect/providers/search_message_provider.dart';
import 'package:e_connect/providers/sign_in_provider.dart';
import 'package:e_connect/providers/splash_screen_provider.dart';
import 'package:e_connect/providers/thread_provider.dart';
import 'package:e_connect/providers/change_password_provider.dart';
import 'package:e_connect/providers/forgot_password_provider.dart';
import 'package:e_connect/screens/bottom_nav_tabs/home_screen.dart';
import 'package:e_connect/screens/bottom_navigation_screen/bottom_navigation_screen_cubit.dart';
import 'package:e_connect/screens/calling/call_screen.dart';
import 'package:e_connect/screens/splash_screen/splash_screen.dart';
import 'package:e_connect/providers/file_service_provider.dart';
import 'package:e_connect/socket_io/socket_io.dart';
import 'package:e_connect/utils/app_preference_constants.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/prefrance_function.dart';
import 'package:e_connect/utils/loading_widget/loading_cubit.dart';
import 'package:e_connect/utils/loading_widget/loading_widget.dart';
import 'package:e_connect/utils/network_connectivity/network_connectivity.dart';
import 'package:e_connect/utils/theme/theme_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_callkit_incoming/entities/call_event.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'model/sign_in_model.dart';
import 'notificationServices/pushNotificationService.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
SignInModel? signInModel;
/// Global App Lifecycle Observer
class AppLifecycleObserver with WidgetsBindingObserver {
  static final AppLifecycleObserver _instance = AppLifecycleObserver._internal();
  factory AppLifecycleObserver() => _instance;
  AppLifecycleObserver._internal();

  void startObserving() {
    WidgetsBinding.instance.addObserver(this);
  }

  void stopObserving() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final commonProvider = Provider.of<CommonProvider>(context, listen: false);

    switch (state) {
      case AppLifecycleState.resumed:
        NotificationService.clearAllNotifications();
        // First check user's current status from getUserById
        commonProvider.getUserByIDCall().then((_) {
          final currentStatus = commonProvider.getUserModel?.data?.user?.status?.toLowerCase() ?? "";
          // Only update to online if not busy or DND
          if (currentStatus != AppString.busy.toLowerCase() ||
              currentStatus != AppString.dnd.toLowerCase()) {
            commonProvider.updateStatusCall(status: AppString.online.toLowerCase());
          }
        });
        Provider.of<ChannelListProvider>(context, listen: false).refreshAllLists();
        Provider.of<SocketIoProvider>(context, listen: false).connectSocket(true);
        break;

      case AppLifecycleState.paused:
      // App is minimized or in background
      // First check user's current status
        commonProvider.getUserByIDCall().then((_) {
          final currentStatus = commonProvider.getUserModel?.data?.user?.status?.toLowerCase() ?? "";
          // Only update to away if not busy or DND
          if (currentStatus != AppString.busy.toLowerCase() ||
              currentStatus != AppString.dnd.toLowerCase()) {
            commonProvider.updateStatusCall(status: AppString.away.toLowerCase());
          }
        });
        break;

      case AppLifecycleState.detached:
      // App is terminated
        commonProvider.updateStatusCall(status: AppString.offline.toLowerCase());
        // Provider.of<SocketIoProvider>(context, listen: false).dispose();
        // print("App is terminating...");
        break;

      default:
        break;
    }
  }
}

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async{
//   // This method will be called when the app is in the background or terminated
//   // and a notification is received.
//   // You can handle the notification here, such as showing a local notification.
//   print("Handling a background message: ${message.messageId}");
//   print("Handling a background message data : ${message.data}");
//   print("Handling a background message meta : ${message.data["metaData"]}");
//   if (message.data['type'] == "incoming_call") {
//     // await FlutterCallkitIncoming.showCallkitIncoming(CallKitParams(
//     //   id:message.data['senderId'],
//     //   nameCaller: message.data['fromUserName'] ?? "Unknown",
//     //   handle: 'Video',
//     //   type: 1, // 0 = audio, 1 = video
//     //   avatar: '', // Optional
//     //   duration: 30000, // Optional
//     //   textAccept: 'Accept',
//     //   textDecline: 'Decline',
//     //   extra: {
//     //     'callerId': message.data['senderId'],
//     //     'metaData': message.data['metaData'] ?? {}
//     //   },
//     // ));
//     final params = CallKitParams.fromJson({
//       'id': message.data['senderId'],
//       'nameCaller':  message.data['fromUserName'] ?? "Unknown",
//       'appName': 'notification test',
//       'avatar': 'https://i.pravatar.cc/100',
//       'handle': 'Video',
//       'type': 0,
//       'textAccept': 'Accept',
//       'textDecline': 'Decline',
//       'duration': 30000,
//       'extra': {
//         'callerId': message.data['senderId'],
//         'metaData': message.data['metaData'] ?? {}
//       },
//       'android': {
//         'isCustomNotification': false,
//         'isShowLogo': false,
//         'backgroundColor': '#0A0A0A',
//         'actionColor': '#800080',
//         'textColor': '#ffffff',
//         'incomingCallNotificationChannelName': 'Incoming Calls',
//         'missedCallNotificationChannelName': 'Missed Calls',
//         'isShowFullScreen': true,
//         'isShowFullLockedScreen': true,
//
//       },
//       'ios': {
//         'iconName': 'CallKitLogo',
//         'handleType': 'generic',
//         'supportsVideo': false,
//
//       },
//     });
//
//     await FlutterCallkitIncoming.showCallkitIncoming(
//         params
//     //     CallKitParams(
//     //   id:message.data['senderId'],
//     //   nameCaller: message.data['fromUserName'] ?? "Unknown",
//     //   handle: 'Video',
//     //   type: 1, // 0 = audio, 1 = video
//     //   avatar: '', // Optional
//     //   duration: 30000, // Optional
//     //   textAccept: 'Accept',
//     //   textDecline: 'Decline',
//     //   extra: {
//     //     'callerId': message.data['senderId'],
//     //     'metaData': message.data['metaData'] ?? {}
//     //   },
//     // )
//     );
//     Provider.of<SocketIoProvider>(navigatorKey.currentState!.context, listen: false).connectSocket(true);
//   }
// if(message.data['type'] == "incoming_call"){
//   // Navigator.push(
//   //   navigatorKey.currentContext!,
//   //   MaterialPageRoute(
//   //     builder: (context) => CallScreen(
//   //       dataOfSocket: message.data['metaData'] ?? {},
//   //       callerName: message.data['fromUserName'] ?? "Unknown",
//   //       //  callerName: 'John Doe',
//   //       callerId: message.data['senderId'],
//   //       imageUrl: "",
//   //       // imageUrl: 'https://t3.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg',
//   //       callDirection: CallDirection.incoming,
//   //     ),
//   //   ),
//   // );
//   Provider.of<SocketIoProvider>(navigatorKey.currentState!.context, listen: false).connectSocket(true);
// }
  // You can also call NotificationService to show a local notification
//}



// void initCallKitEventHandler() {
//   FlutterCallkitIncoming.onEvent.listen((event) async {
//     switch (event?.event) {
//       case Event.actionCallAccept:
//         print('Call accepted');
//         // Navigate to your CallScreen
//         navigatorKey.currentState?.push(MaterialPageRoute(
//           builder: (_) => CallScreen(
//             callerName: event?.body['nameCaller'] ?? 'Unknown',
//             callerId: event?.body['id'] ?? '',
//             dataOfSocket: {}, // or pass data if you saved it
//             imageUrl: '',
//             callDirection: CallDirection.incoming,
//           ),
//         )
//         );
//         // navigatorKey.currentState?.push(MaterialPageRoute(
//         //   builder: (_) => HomeScreen()
//         // )
//         //);
//         break;
//
//       case Event.actionCallDecline:
//         print('Call declined');
//         break;
//
//       default:
//         break;
//     }
//   });
// }


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  await NotificationService.initializeNotifications();
  await NotificationService.clearAllNotifications();

  await Permission.notification.isDenied.then(
        (bool value) {
      if (value) {
        Permission.notification.request();
      }
    },
  );
  NetworkStatusService();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final isLoggedIn = await getBool(AppPreferenceConstants.isLoginPrefs) ?? false;
  if(isLoggedIn){
    AppLifecycleObserver().startObserving();
  }
  //initCallKitEventHandler();
  runApp(const MyApp());
}


void updateSystemUiChrome(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: themeProvider.themeData.appBarTheme.backgroundColor,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.light
  ));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SocketIoProvider()),
        ChangeNotifierProvider(create: (_) => ChannelChatProvider()),
        ChangeNotifierProvider(create: (_) => LoadingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => NetworkStatusService(),),
        ChangeNotifierProvider(create: (_) => SignInProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavigationProvider()),
        ChangeNotifierProvider(create: (_) => ChannelListProvider()),
        ChangeNotifierProvider(create: (_) => CommonProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => FileServiceProvider()),
        ChangeNotifierProvider(create: (_) => DownloadFileProvider()),
        ChangeNotifierProvider(create: (_) => SearchMessageProvider()),
        ChangeNotifierProvider(create: (_) => ThreadProvider()),
        ChangeNotifierProvider(create: (_) => ChangePasswordProvider()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
      ],
      child: OKToast(
        child: Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
          updateSystemUiChrome(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            navigatorKey: navigatorKey,
            home: const SplashScreen(),
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1.0), boldText: false),
                child: Loading(child: child!),
              );
            },
          );
        },),
      ),
    );
  }
}





