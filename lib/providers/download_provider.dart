import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/loading_widget/loading_cubit.dart';


class DownloadFileProvider extends ChangeNotifier {
  double progress = 0;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<int> getDeviceSdkForAndroid() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo;
    androidInfo = await deviceInfo.androidInfo;
    final version = androidInfo.version.sdkInt;
    print("ANDROID_DEVICE_VERSION $version");
    print(
        'Android version OpenPdfInOutPresent : ${androidInfo.version.sdkInt}');
    return version;
  }
  Future<void> initializeNotifications() async {
    const androidInitialize = AndroidInitializationSettings('app_icon');
    const iOSInitialize = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payload = response.payload;
        if (payload != null) {
          // OpenFile.open(payload); // Open the file when notification is tapped
        }
      },
    );
  }
  Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      PermissionStatus result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }
  Future<void> showProgressNotification({
    required int progress,
    required String fileName,
    required String filePath,
    required int notificationId,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'download_channel',
      'File Download',
      channelDescription: 'Shows file download progress',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      ongoing: progress < 100,
      autoCancel: progress >= 100,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      'Downloading $fileName',
      progress < 100 ? 'Download in progress: $progress%' : 'Download complete',
      platformChannelSpecifics,
      payload: filePath,
    );
  }
  Future<void> downloadFile({
    required String fileUrl,
    required BuildContext context,
  }) async {
    try {
      progress = 0.0;
      String fileName = fileUrl.split('/').last;
      // Add timestamp to filename for uniqueness
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final int notificationId = DateTime.now().millisecondsSinceEpoch.hashCode;

      // Show loading indicator
      Provider.of<LoadingProvider>(context, listen: false).startLoading();

      if (Platform.isAndroid) {
        int deviceSdk = await getDeviceSdkForAndroid();
        print("Device SDK $deviceSdk");

        // Check permission for Android (SDK 31+ uses a different permission system)
        if (deviceSdk > 31
            ? true
            : await requestPermission(Permission.storage)) {

          const downloadPath = '/storage/emulated/0/Download';
          final directory = await Directory(downloadPath).create(recursive: true);

          // Append unique filename to the directory path
          final filePath = '${directory.path}/$uniqueFileName';
          File file = File(filePath);

          // HTTP request to download the file
          final request = http.Request('GET', Uri.parse(fileUrl));
          final response = await http.Client().send(request);

          if (response.statusCode == 200) {
            int totalBytes = response.contentLength ?? 0;
            int receivedBytes = 0;

            // Stop loading animation and show download progress dialog
            Provider.of<LoadingProvider>(context, listen: false).stopLoading();
            // downloadProgressDialog(context);


            // Listen to download stream and write to file
            response.stream.listen((data) {
              receivedBytes += data.length;
              progress = (receivedBytes / totalBytes) * 100;
              showProgressNotification(
                progress: progress.round(),
                fileName: fileName,
                filePath: filePath,
                notificationId: notificationId,
              );
              notifyListeners();

              file.writeAsBytesSync(data, mode: FileMode.append);
            }, onDone: () async{
              print("File downloaded to: $filePath");
              await showProgressNotification(
              progress: 100,
              fileName: fileName,
              filePath: filePath,
              notificationId: notificationId,
            );
              // commonShowToast("Downloaded");
              // AppUtils.showToast(LanguageKey.reportHasBeenDownloadedInDownloadFolder.tr(context) );
              // Navigator.of(context).pop();
            }, onError: (error) {
              // commonShowToast("Download error");
              print("Download error: $error");
              // Navigator.of(context).pop();
            }, cancelOnError: true);
          } else {
            // commonShowToast("Download error");
            print("Error downloading file: ${response.statusCode}");
          }
        }
      } else if (Platform.isIOS) {
        // For iOS, store files in the app's document directory
        final directory = await getApplicationDocumentsDirectory();

        // Ensure directory exists
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        if (await directory.exists()) {
          final filePath = '${directory.path}/$uniqueFileName';
          File file = File(filePath);

          // HTTP request to download the file
          final request = http.Request('GET', Uri.parse(fileUrl));
          final response = await http.Client().send(request);

          if (response.statusCode == 200) {
            int totalBytes = response.contentLength ?? 0;
            int receivedBytes = 0;

            // Stop loading animation and show download progress dialog
            Provider.of<LoadingProvider>(context, listen: false).stopLoading();
            showProgressNotification(
              progress: progress.round(),
              fileName: fileName,
              filePath: filePath,
              notificationId: notificationId,
            );

            // Listen to download stream and write to file
            response.stream.listen((data) {
              receivedBytes += data.length;
              progress = (receivedBytes / totalBytes) * 100;
              notifyListeners();

              file.writeAsBytesSync(data, mode: FileMode.append);
            }, onDone: () {
              print("File downloaded to: $filePath");
              // commonShowToast("Downloaded");
              // Navigator.of(context).pop();
            }, onError: (error) {
              // commonShowToast("Download error");
              print("Download error: $error");
              // Navigator.of(context).pop();
            }, cancelOnError: true);
          } else {
            // commonShowToast("Download error");

            print("Error downloading file: ${response.statusCode}");
          }
        }
      }
    } catch (e) {
      // commonShowToast("Download error");
      print("Error downloading file: $e");
    }finally{
      Provider.of<LoadingProvider>(context, listen: false).stopLoading();
    }
  }


  // downloadProgressDialog(BuildContext context) {
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (ctx) {
  //       return AlertDialog(
  //         title: Text("File Downloading", style: TextStyle(fontWeight: FontWeight.bold)),
  //         content: Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               const SizedBox(height: 10),
  //               Consumer<DownloadFileProvider>(builder: (context, data, _) {
  //                 return Column(
  //                   children: [
  //                     Text("Please wait while your file is being downloaded.",
  //                         textAlign: TextAlign.center),
  //                     const SizedBox(height: 20),
  //                     LinearProgressIndicator(
  //                       value: data.progress / 100,
  //                       minHeight: 8,
  //                     ),
  //                     const SizedBox(height: 20),
  //                     Text("${data.progress.round()}%",
  //                         style: TextStyle(fontWeight: FontWeight.bold))
  //                   ],
  //                 );
  //               }),
  //               const SizedBox(height: 10),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

}


// class DownloadFileProvider extends ChangeNotifier {
//   // ... existing code ...
//   Future<bool> requestPermission(Permission permission) async {
//     if (await permission.isGranted) {
//       return true;
//     } else {
//       PermissionStatus result = await permission.request();
//       if (result == PermissionStatus.granted) {
//         return true;
//       }
//     }
//     return false;
//   }
//   double progress = 0;
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   Future<int> getDeviceSdkForAndroid() async {
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     AndroidDeviceInfo androidInfo;
//     androidInfo = await deviceInfo.androidInfo;
//     final version = androidInfo.version.sdkInt;
//     print("ANDROID_DEVICE_VERSION $version");
//     print(
//         'Android version OpenPdfInOutPresent : ${androidInfo.version.sdkInt}');
//     return version;
//   }
//   Future<void> openDownloadedFile(String filePath) async {
//     try {
//       if (Platform.isAndroid) {
//         // For Android, we can either use OpenFile or launch the Downloads folder
//         final result = await OpenFile.open(filePath);
//         if (result.type != ResultType.done) {
//           // If direct file opening fails, open the Downloads folder
//           final uri = Uri.parse('content://downloads');
//           await launchUrl(uri);
//         }
//       } else if (Platform.isIOS) {
//         await OpenFile.open(filePath);
//       }
//     } catch (e) {
//       print("Error opening file: $e");
//     }
//   }
//   Future<void> showProgressNotification({
//     required int progress,
//     required String fileName,
//     required String filePath,
//     required int notificationId,
//   }) async {
//     final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'download_channel',
//       'File Download',
//       channelDescription: 'Shows file download progress',
//       importance: Importance.low,
//       priority: Priority.low,
//       showProgress: true,
//       maxProgress: 100,
//       progress: progress,
//       ongoing: progress < 100,
//       autoCancel: progress >= 100,
//     );
//
//     final NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidDetails,
//       iOS: const DarwinNotificationDetails(),
//     );
//
//     await flutterLocalNotificationsPlugin.show(
//       notificationId,
//       'Downloading $fileName',
//       progress < 100 ? 'Download in progress: $progress%' : 'Download complete',
//       platformChannelSpecifics,
//       payload: filePath,
//     );
//   }
//   Future<void> initializeNotifications() async {
//     const androidInitialize = AndroidInitializationSettings('app_icon');
//     const iOSInitialize = DarwinInitializationSettings();
//     const initializationSettings = InitializationSettings(
//       android: androidInitialize,
//       iOS: iOSInitialize,
//     );
//
//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         final String? payload = response.payload;
//         if (payload != null) {
//           openDownloadedFile(payload);
//         }
//       },
//     );
//   }
//
//   Future<void> downloadFile({
//     required String fileUrl,
//     required BuildContext context,
//   }) async {
//     try {
//       progress = 0.0;
//       String fileName = fileUrl.split('/').last;
//       String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
//       final int notificationId = DateTime.now().millisecondsSinceEpoch.hashCode;
//
//       Provider.of<LoadingProvider>(context, listen: false).startLoading();
//
//       if (Platform.isAndroid) {
//         int deviceSdk = await getDeviceSdkForAndroid();
//
//         if (deviceSdk > 31 ? true : await requestPermission(Permission.storage)) {
//           const downloadPath = '/storage/emulated/0/Download';
//           final directory = await Directory(downloadPath).create(recursive: true);
//           final filePath = '${directory.path}/$uniqueFileName';
//           File file = File(filePath);
//
//           final request = http.Request('GET', Uri.parse(fileUrl));
//           final response = await http.Client().send(request);
//
//           if (response.statusCode == 200) {
//             int totalBytes = response.contentLength ?? 0;
//             int receivedBytes = 0;
//
//             Provider.of<LoadingProvider>(context, listen: false).stopLoading();
//
//             // Show initial notification
//             await showProgressNotification(
//               progress: 0,
//               fileName: fileName,
//               filePath: filePath,
//               notificationId: notificationId,
//             );
//
//             await for (final data in response.stream) {
//               receivedBytes += data.length;
//               progress = (receivedBytes / totalBytes) * 100;
//
//               // Update notification every 5% progress to avoid too frequent updates
//               if (progress % 5 == 0 || progress == 100) {
//                 await showProgressNotification(
//                   progress: progress.round(),
//                   fileName: fileName,
//                   filePath: filePath,
//                   notificationId: notificationId,
//                 );
//               }
//
//               notifyListeners();
//               await file.writeAsBytes(data, mode: FileMode.append);
//             }
//
//             // Show completion notification
//             await showProgressNotification(
//               progress: 100,
//               fileName: fileName,
//               filePath: filePath,
//               notificationId: notificationId,
//             );
//
//             print("File downloaded to: $filePath");
//           } else {
//             throw "Download failed with status: ${response.statusCode}";
//           }
//         }
//       } else if (Platform.isIOS) {
//         final directory = await getApplicationDocumentsDirectory();
//         final filePath = '${directory.path}/$uniqueFileName';
//         File file = File(filePath);
//
//         // ... Similar implementation for iOS ...
//         // (The rest of the iOS implementation follows the same pattern as Android)
//       }
//     } catch (e) {
//       print("Error downloading file: $e");
//       // Show error notification
//       // await flutterLocalNotificationsPlugin.show(
//       //   DateTime.now().millisecondsSinceEpoch.hashCode,
//       //   'Download Failed',
//       //   'Error downloading $fileName',
//       //   NotificationDetails(
//       //     android: AndroidNotificationDetails(
//       //       'download_channel',
//       //       'File Download',
//       //       channelDescription: 'Shows file download progress',
//       //     ),
//       //   ),
//       // );
//     } finally {
//       Provider.of<LoadingProvider>(context, listen: false).stopLoading();
//     }
//   }
// }