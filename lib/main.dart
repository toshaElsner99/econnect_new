import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/providers/channel_list_provider.dart';
import 'package:e_connect/providers/chat_provider.dart';
import 'package:e_connect/providers/common_provider.dart';
import 'package:e_connect/providers/download_provider.dart';
import 'package:e_connect/providers/search_message_provider.dart';
import 'package:e_connect/providers/sign_in_provider.dart';
import 'package:e_connect/providers/splash_screen_provider.dart';
import 'package:e_connect/providers/thread_provider.dart';
import 'package:e_connect/screens/bottom_navigation_screen/bottom_navigation_screen_cubit.dart';
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
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/sign_in_model.dart';
import 'notificationServices/pushNotificationService.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late SignInModel signInModel;
/// CLear Notification Class ///
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
        print("App is terminating...");
        break;
        
      default:
        break;
    }
  }
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initializeNotifications();
  await NotificationService.clearAllNotifications();

  // await NotificationService.registerFirebaseListeners();
  // NotificationService.requestPermissions();
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
  AppLifecycleObserver().startObserving();
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




