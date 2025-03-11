import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/providers/channel_list_provider.dart';
import 'package:e_connect/providers/chat_provider.dart';
import 'package:e_connect/providers/common_provider.dart';
import 'package:e_connect/providers/download_provider.dart';
import 'package:e_connect/providers/sign_in_provider.dart';
import 'package:e_connect/providers/splash_screen_provider.dart';
import 'package:e_connect/screens/bottom_navigation_screen/bottom_navigation_screen_cubit.dart';
import 'package:e_connect/screens/splash_screen/splash_screen.dart';
import 'package:e_connect/providers/file_service_provider.dart';
import 'package:e_connect/socket_io/socket_io.dart';
import 'package:e_connect/utils/loading_widget/loading_cubit.dart';
import 'package:e_connect/utils/loading_widget/loading_widget.dart';
import 'package:e_connect/utils/network_connectivity/network_connectivity.dart';
import 'package:e_connect/utils/theme/theme_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'model/sign_in_model.dart';
import 'notificationServices/pushNotificationService.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late SignInModel signInModel;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // SocketIoProvider();
  NetworkStatusService();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value)async{
    await Firebase.initializeApp();
    await PushNotificationService().setupInteractedMessage();
    // DownloadFileProvider downloadFileProvider = DownloadFileProvider();
    // await downloadFileProvider.initializeNotifications();
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // App received a notification when it was killed
    }
    await Permission.notification.isDenied.then(
          (bool value) {
        if (value) {
          Permission.notification.request();
        }
      },
    );
    runApp(const MyApp());
  },);
}


void updateSystemUiChrome(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: themeProvider.themeData.appBarTheme.backgroundColor,
    statusBarIconBrightness: Brightness.dark,
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
              return Loading(child: child!);
            },
          );
        },),
      ),
    );
  }
}




