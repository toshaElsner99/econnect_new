import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../utils/loading_widget/loading_cubit.dart';

class DownloadFileProvider extends ChangeNotifier {
  double progress = 0;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<int> getDeviceSdkForAndroid() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
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
          // Open the file when notification is tapped
          openDownloadedFile(payload);
        }
      },
    );
  }

  Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      PermissionStatus result = await permission.request();
      return result == PermissionStatus.granted;
    }
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
      priority: Priority.high,
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
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final int notificationId = DateTime.now().millisecondsSinceEpoch.hashCode;

      // Show loading indicator
      Provider.of<LoadingProvider>(context, listen: false).startLoading();

      if (Platform.isAndroid) {
        int deviceSdk = await getDeviceSdkForAndroid();

        if (deviceSdk > 31 || await requestPermission(Permission.storage)) {
          const downloadPath = '/storage/emulated/0/Download';
          final directory = await Directory(downloadPath).create(recursive: true);
          final filePath = '${directory.path}/$uniqueFileName';
          File file = File(filePath);

          final request = http.Request('GET', Uri.parse(fileUrl));
          final response = await http.Client().send(request);

          if (response.statusCode == 200) {
            int totalBytes = response.contentLength ?? 0;
            int receivedBytes = 0;

            // Show initial notification
            await showProgressNotification(
              progress: 0,
              fileName: fileName,
              filePath: filePath,
              notificationId: notificationId,
            );

            // Listen to download stream and write to file
            response.stream.listen((data) {
              receivedBytes += data.length;
              progress = (receivedBytes / totalBytes) * 100;

              // Update notification with current progress
              showProgressNotification(
                progress: progress.round(),
                fileName: fileName,
                filePath: filePath,
                notificationId: notificationId,
              );

              // Write data to file
              file.writeAsBytesSync(data, mode: FileMode.append);
            }, onDone: () async {
              print("File downloaded to: $filePath");
              // Show final notification indicating download is complete
              await showProgressNotification(
                progress: 100, // Set progress to 100 to indicate completion
                fileName: fileName,
                filePath: filePath,
                notificationId: notificationId,
              );
            }, onError: (error) {
              print("Download error: $error");
            }, cancelOnError: true);
          } else {
            print("Error downloading file: ${response.statusCode}");
          }
        }
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$uniqueFileName';
        File file = File(filePath);

        final request = http.Request('GET', Uri.parse(fileUrl));
        final response = await http.Client().send(request);

        if (response.statusCode == 200) {
          int totalBytes = response.contentLength ?? 0;
          int receivedBytes = 0;

          // Show initial notification
          await showProgressNotification(
            progress: 0,
            fileName: fileName,
            filePath: filePath,
            notificationId: notificationId,
          );

          response.stream.listen((data) {
            receivedBytes += data.length;
            progress = (receivedBytes / totalBytes) * 100;

            // Update notification with current progress
            showProgressNotification(
              progress: progress.round(),
              fileName: fileName,
              filePath: filePath,
              notificationId: notificationId,
            );

            // Write data to file
            file.writeAsBytesSync(data, mode: FileMode.append);
          }, onDone: () async {
            print("File downloaded to: $filePath");
            // Show final notification indicating download is complete
            await showProgressNotification(
              progress: 100, // Set progress to 100 to indicate completion
              fileName: fileName,
              filePath: filePath,
              notificationId: notificationId,
            );
          }, onError: (error) {
            print("Download error: $error");
          }, cancelOnError: true);
        } else {
          print("Error downloading file: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Error downloading file: $e");
    } finally {
      Provider.of<LoadingProvider>(context, listen: false).stopLoading();
    }
  }

  // Future<void> openDownloadedFile(String filePath) async {
  //   try {
  //     if (Platform.isAndroid) {
  //       // Attempt to open the file
  //       final result = await OpenFile.open(filePath);
  //       if (result.type != ResultType.done) {
  //         // If opening the file fails, open the Downloads folder
  //         final uri = Uri.parse('content://downloads');
  //         await launchUrl(uri);
  //       }
  //     } else if (Platform.isIOS) {
  //       // For iOS, directly open the file
  //       await OpenFile.open(filePath);
  //     }
  //   } catch (e) {
  //     print("Error opening file: $e");
  //   }
  // }
  Future<void> openDownloadedFile(String filePath) async {
    try {
      final file = File(filePath);

      // Check if the file exists
      if (await file.exists()) {
        if (Platform.isAndroid) {
          // Attempt to open the file
          final result = await OpenFile.open(filePath);
          if (result.type != ResultType.done) {
            // If opening the file fails, open the Downloads folder
            final uri = Uri.parse('content://com.android.providers.downloads.documents');
            await launchUrl(uri);
          }
        } else if (Platform.isIOS) {
          // For iOS, directly open the file
          final result = await OpenFile.open(filePath);
          if (result.type != ResultType.done) {
            // Handle the case where the file could not be opened
            print("Could not open file on iOS: ${result.message}");
          }
        }
      } else {
        print("File does not exist: $filePath");
        // Optionally, show a message to the user
      }
    } catch (e) {
      print("Error opening file: $e");
    }
  }
}