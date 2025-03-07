// import 'dart:io';
//
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:e_connect/utils/common/common_widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
//
// import '../utils/loading_widget/loading_cubit.dart';
//
//
// class DownloadFileProvider extends ChangeNotifier {
//   double progress = 0;
//
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
//
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
//
//   Future<void> downloadFile({
//     required String fileUrl,
//     required BuildContext context,
//   }) async {
//     try {
//       progress = 0.0;
//       String fileName = fileUrl.split('/').last;
//       // Add timestamp to filename for uniqueness
//       String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
//
//       // Show loading indicator
//       Provider.of<LoadingProvider>(context, listen: false).startLoading();
//
//       if (Platform.isAndroid) {
//         int deviceSdk = await getDeviceSdkForAndroid();
//         print("Device SDK $deviceSdk");
//
//         // Check permission for Android (SDK 31+ uses a different permission system)
//         if (deviceSdk > 31
//             ? true
//             : await requestPermission(Permission.storage)) {
//
//           const downloadPath = '/storage/emulated/0/Download';
//           final directory = await Directory(downloadPath).create(recursive: true);
//
//           // Append unique filename to the directory path
//           final filePath = '${directory.path}/$uniqueFileName';
//           File file = File(filePath);
//
//           // HTTP request to download the file
//           final request = http.Request('GET', Uri.parse(fileUrl));
//           final response = await http.Client().send(request);
//
//           if (response.statusCode == 200) {
//             int totalBytes = response.contentLength ?? 0;
//             int receivedBytes = 0;
//
//             // Stop loading animation and show download progress dialog
//             Provider.of<LoadingProvider>(context, listen: false).stopLoading();
//             downloadProgressDialog(context);
//
//             // Listen to download stream and write to file
//             response.stream.listen((data) {
//               receivedBytes += data.length;
//               progress = (receivedBytes / totalBytes) * 100;
//               notifyListeners();
//
//               file.writeAsBytesSync(data, mode: FileMode.append);
//             }, onDone: () {
//               print("File downloaded to: $filePath");
//               commonShowToast("Downloaded");
//               // AppUtils.showToast(LanguageKey.reportHasBeenDownloadedInDownloadFolder.tr(context) );
//               Navigator.of(context).pop();
//             }, onError: (error) {
//               commonShowToast("Download error");
//               print("Download error: $error");
//               Navigator.of(context).pop();
//             }, cancelOnError: true);
//           } else {
//             commonShowToast("Download error");
//             print("Error downloading file: ${response.statusCode}");
//           }
//         }
//       } else if (Platform.isIOS) {
//         // For iOS, store files in the app's document directory
//         final directory = await getApplicationDocumentsDirectory();
//
//         // Ensure directory exists
//         if (!await directory.exists()) {
//           await directory.create(recursive: true);
//         }
//
//         if (await directory.exists()) {
//           final filePath = '${directory.path}/$uniqueFileName';
//           File file = File(filePath);
//
//           // HTTP request to download the file
//           final request = http.Request('GET', Uri.parse(fileUrl));
//           final response = await http.Client().send(request);
//
//           if (response.statusCode == 200) {
//             int totalBytes = response.contentLength ?? 0;
//             int receivedBytes = 0;
//
//             // Stop loading animation and show download progress dialog
//             Provider.of<LoadingProvider>(context, listen: false).stopLoading();
//             downloadProgressDialog(context);
//
//             // Listen to download stream and write to file
//             response.stream.listen((data) {
//               receivedBytes += data.length;
//               progress = (receivedBytes / totalBytes) * 100;
//               notifyListeners();
//
//               file.writeAsBytesSync(data, mode: FileMode.append);
//             }, onDone: () {
//               print("File downloaded to: $filePath");
//               commonShowToast("Downloaded");
//               Navigator.of(context).pop();
//             }, onError: (error) {
//               commonShowToast("Download error");
//               print("Download error: $error");
//               Navigator.of(context).pop();
//             }, cancelOnError: true);
//           } else {
//             commonShowToast("Download error");
//
//             print("Error downloading file: ${response.statusCode}");
//           }
//         }
//       }
//     } catch (e) {
//       commonShowToast("Download error");
//       print("Error downloading file: $e");
//     }finally{
//       Provider.of<LoadingProvider>(context, listen: false).stopLoading();
//     }
//   }
//   downloadProgressDialog(BuildContext context) {
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) {
//         return AlertDialog(
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),
//               Consumer<DownloadFileProvider>(builder: (context, data, _) {
//                 return Column(
//                   children: [
//                     Text("Downloading..."),
//                     const SizedBox(height: 10),
//                     LinearProgressIndicator(
//                       value: data.progress / 100,
//                     ),
//                     const SizedBox(height: 20),
//                     Text("${data.progress.round()}%")
//                   ],
//                 );
//               }),
//               const SizedBox(height: 20),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../utils/loading_widget/loading_cubit.dart';


class DownloadFileProvider extends ChangeNotifier {
  double progress = 0;

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

  Future<void> downloadFile({
    required String fileUrl,
    required BuildContext context,
  }) async {
    try {
      progress = 0.0;
      String fileName = fileUrl.split('/').last;
      // Add timestamp to filename for uniqueness
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

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
            downloadProgressDialog(context);

            // Listen to download stream and write to file
            response.stream.listen((data) {
              receivedBytes += data.length;
              progress = (receivedBytes / totalBytes) * 100;
              notifyListeners();

              file.writeAsBytesSync(data, mode: FileMode.append);
            }, onDone: () {
              print("File downloaded to: $filePath");
              commonShowToast("Downloaded");
              // AppUtils.showToast(LanguageKey.reportHasBeenDownloadedInDownloadFolder.tr(context) );
              Navigator.of(context).pop();
            }, onError: (error) {
              commonShowToast("Download error");
              print("Download error: $error");
              Navigator.of(context).pop();
            }, cancelOnError: true);
          } else {
            commonShowToast("Download error");
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
            downloadProgressDialog(context);

            // Listen to download stream and write to file
            response.stream.listen((data) {
              receivedBytes += data.length;
              progress = (receivedBytes / totalBytes) * 100;
              notifyListeners();

              file.writeAsBytesSync(data, mode: FileMode.append);
            }, onDone: () {
              print("File downloaded to: $filePath");
              commonShowToast("Downloaded");
              Navigator.of(context).pop();
            }, onError: (error) {
              commonShowToast("Download error");
              print("Download error: $error");
              Navigator.of(context).pop();
            }, cancelOnError: true);
          } else {
            commonShowToast("Download error");

            print("Error downloading file: ${response.statusCode}");
          }
        }
      }
    } catch (e) {
      commonShowToast("Download error");
      print("Error downloading file: $e");
    }finally{
      Provider.of<LoadingProvider>(context, listen: false).stopLoading();
    }
  }


  downloadProgressDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text("File Downloading", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Consumer<DownloadFileProvider>(builder: (context, data, _) {
                  return Column(
                    children: [
                      Text("Please wait while your file is being downloaded.",
                          textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: data.progress / 100,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 20),
                      Text("${data.progress.round()}%",
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ],
                  );
                }),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
