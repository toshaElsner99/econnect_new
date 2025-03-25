// import 'dart:async';
//
// import 'package:e_connect/screens/bottom_nav_tabs/home_screen.dart';
// import 'package:e_connect/screens/sign_in_screen/sign_in_Screen.dart';
// import 'package:e_connect/utils/common/common_function.dart';
// import 'package:flutter/cupertino.dart';
//
// import '../main.dart';
// import '../utils/app_preference_constants.dart';
// import '../utils/common/prefrance_function.dart';
// import '../model/sign_in_model.dart';
// import '../notificationServices/pushNotificationService.dart';
//
//
// class SplashProvider extends ChangeNotifier{
//   whereToGO() async {
//     signInModel = (await SignInModel.loadFromPrefs()) ?? SignInModel();
//     final isLoggedIn = await getBool(AppPreferenceConstants.isLoginPrefs) ?? false;
//     Timer(const Duration(seconds: 3), () {
//         if (isLoggedIn != null) {
//           if (isLoggedIn) {
//             pushReplacement(screen: const HomeScreen());
//           } else {
//             pushReplacement(screen: const SignInScreen());
//           }
//         } else {
//           pushReplacement(screen: const SignInScreen());
//         }
//     });
//     notifyListeners();
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:e_connect/screens/bottom_nav_tabs/home_screen.dart';
import 'package:e_connect/screens/sign_in_screen/sign_in_Screen.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../utils/api_service/api_service.dart';
import '../utils/api_service/api_string_constants.dart';
import '../utils/app_image_assets.dart';
import '../utils/app_preference_constants.dart';
import '../utils/common/common_widgets.dart';
import '../utils/common/prefrance_function.dart';
import '../model/sign_in_model.dart';
import '../notificationServices/pushNotificationService.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'common_provider.dart';

class SplashProvider extends ChangeNotifier {
  bool isForceUpdate = false;
  whereToGO() async {
    signInModel = (await SignInModel.loadFromPrefs()) ?? SignInModel();
    final isLoggedIn = await getBool(AppPreferenceConstants.isLoginPrefs) ?? false;

    Timer(const Duration(seconds: 3), () {
      if (isLoggedIn) {
        if (NotificationService.pendingNotification != null && 
            NotificationService.pendingNotification!.isNotEmpty && 
            (NotificationService.pendingNotification!.containsKey('type') && 
            NotificationService.pendingNotification!.containsKey('senderId'))) {
          pushReplacement(screen: const HomeScreen());
          // Delay notification processing to ensure app is fully initialized
          Timer(const Duration(milliseconds: 500), () {
            try {
              NotificationService.handleNotificationRedirect(NotificationService.pendingNotification!);
              NotificationService.pendingNotification = null;
              // Check user status and update to online if not busy/dnd
              _checkAndUpdateUserStatus();
            } catch (e) {
              print("Error handling pending notification: $e");
              // Reset pendingNotification to prevent infinite attempts
              NotificationService.pendingNotification = null;
            }
          });
        } else {
          pushReplacement(screen: const HomeScreen());
          // Check user status and update to online if not busy/dnd
          _checkAndUpdateUserStatus();
        }
      } else {
        pushReplacement(screen: const SignInScreen());
      }
    });
    notifyListeners();
  }
  
  void _checkAndUpdateUserStatus() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      final commonProvider = Provider.of<CommonProvider>(context, listen: false);
      // First get current user status
      commonProvider.getUserByIDCall().then((_) {
        final currentStatus = commonProvider.getUserModel?.data?.user?.status?.toLowerCase() ?? "";
        // Only update to online if not busy or DND
        if (currentStatus != AppString.busy.toLowerCase() && 
            currentStatus != AppString.dnd.toLowerCase()) {
          commonProvider.updateStatusCall(status: AppString.online.toLowerCase());
        }
      });
    }
  }

  Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<void> checkForForceUpdate(BuildContext context) async {
    final currentVersion = await getAppVersion();
    print("Current App Version: $currentVersion");

    final platform = Platform.isAndroid ? 'android' : 'ios';
    final latestVersion = await fetchLatestVersion(platform);
    print("latestVersio>>>>n $latestVersion");

    if (latestVersion != null && isUpdateRequired(currentVersion, latestVersion)) {
      showForceUpdateDialog(context,isForceUpdate);
    } else {
      whereToGO();
    }
  }

  Future<String?> fetchLatestVersion(String platform) async {
    final url = Uri.parse(ApiString.baseUrl + ApiString.getAppVersion);
    print("URL>>>.. $url");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        isForceUpdate = data['data']['is_force_update'] ?? false;
        return platform == 'android' ? data['data']['android_version'] : data['data']['ios_version'];
      } else {
        print("Failed to fetch version: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching version: $e");
    }
    return null;
  }

  bool isUpdateRequired(String currentVersion, String latestVersion) {
    List<int> currentParts = currentVersion.split('.').map(int.parse).toList();
    List<int> latestParts = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (currentParts[i] < latestParts[i]) {
        return true;
      } else if (currentParts[i] > latestParts[i]) {
        return false;
      }
    }
    return false;
  }
  Future<void> showForceUpdateDialog(BuildContext context, bool isForceUpdate) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Prevents system back button dismissal
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.white, width: 1),
            ),
            title: Row(
              children: [
                Image.asset(Platform.isAndroid ? AppImage.playStoreIcon : AppImage.appStoreIcon, height: 20, width: 20),
                const SizedBox(width: 10),
                commonText(text: 'Update Required', fontSize: 17),
              ],
            ),
            content: commonText(
              text: isForceUpdate
                  ? 'A new version of the app is available. Please update to continue using the app.'
                  : 'A new version of the app is available. Would you like to update now?',
              fontSize: 15,
            ),
            actions: [
              TextButton(
                // style: AppPreferenceConstants.themeModeBoolValueGet ?  ButtonStyle(
                //   shape: WidgetStatePropertyAll(
                //     RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(6), // Same border radius as AlertDialog
                //       side: BorderSide(color: Colors.white, width: 1), // White border
                //     ),
                //   ),
                // ) : null,
                onPressed: () {
                  if (isForceUpdate) {
                    exit(0);
                  } else {
                    pop();
                    whereToGO();
                  }
                },
                child: commonText(
                  text: isForceUpdate ? 'Cancel' : "Later",
                  fontSize: 15,
                  color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white :Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: const WidgetStatePropertyAll(AppColor.appBarColor),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                onPressed: () => openStore(),
                child: commonText(text: 'Update', fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }


  void openStore() {
    final url = Platform.isAndroid
    ? 'https://play.google.com/store/apps/details?id=com.elsner.econnect'
    : 'https://apps.apple.com/app/id6743174123';
    launchUrl(Uri.parse(url));
  }
}