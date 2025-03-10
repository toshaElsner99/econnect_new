import 'dart:io';
import 'dart:typed_data';
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
        if (payload != null && payload.isNotEmpty) {
          if (await requestStoragePermission()) {
            openDownloadedFile(payload); // Proceed with file opening
          } else {
            print("Storage permission denied.");
          }
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

  Future<void> showDownloadNotification({
    required String fileName,
    required String filePath,
    required int notificationId,
    required bool isCompleted,
  }) async {
    // Android Notification Details
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'download_channel',
      'File Download',
      channelDescription: 'Shows file download progress',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: !isCompleted, // Ongoing for active downloads
      autoCancel: false, // Prevent auto-cancel to avoid overlapping
    );

    // iOS Notification Details
    DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      // Customize for iOS if needed
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    String notificationTitle = isCompleted ? 'Download Complete' : 'Downloading...';
    String notificationBody = isCompleted ? 'Tap to open $fileName' : 'Downloading $fileName...';

    // Show/Update Notification
    await flutterLocalNotificationsPlugin.show(
      notificationId, // Use the same notification ID to update
      notificationTitle,
      notificationBody,
      platformChannelSpecifics,
      payload: isCompleted ? filePath : null, // Attach file path only on completion
    );

    // // If the download is complete, cancel the notification or auto-remove it
    // if (isCompleted) {
    //   await flutterLocalNotificationsPlugin.cancel(notificationId); // Optionally cancel when done
    // }
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

      String filePath;
      if (Platform.isAndroid) {
        int deviceSdk = await getDeviceSdkForAndroid();

        if (deviceSdk > 31 || await requestPermission(Permission.storage)) {
          const downloadPath = '/storage/emulated/0/Download';
          final directory = await Directory(downloadPath).create(recursive: true);
          filePath = '${directory.path}/$uniqueFileName';
          File file = File(filePath);

          final request = http.Request('GET', Uri.parse(fileUrl));
          final response = await http.Client().send(request);

          if (response.statusCode == 200) {
            int totalBytes = response.contentLength ?? 0;
            int receivedBytes = 0;

            // ✅ Show single notification when download starts
            await showDownloadNotification(
              fileName: fileName,
              filePath: filePath,
              notificationId: notificationId,
              isCompleted: false, // Downloading...
            );

            // Create the file and write to it in chunks
            await response.stream.listen((data) async{
              receivedBytes += data.length;
              progress = (receivedBytes / totalBytes) * 100;

              // Silent progress update (No extra notifications)
              if(progress == 100){
                await flutterLocalNotificationsPlugin.cancel(notificationId); // Optionally cancel when done
                await showDownloadNotification(
                fileName: fileName,
                filePath: filePath,
                notificationId: notificationId,
                isCompleted: true, // Download completed
                );
              }

              // Write data to file
              file.writeAsBytesSync(data, mode: FileMode.append);
            }, onDone: () async {
              print("File downloaded to: $filePath");

              // ✅ Update the same notification when the download is complete
              await showDownloadNotification(
                fileName: fileName,
                filePath: filePath,
                notificationId: notificationId,
                isCompleted: true, // Download completed
              );
            }, onError: (error) {
              print("Download error: $error");
            }, cancelOnError: true).asFuture(); // Convert Stream to Future
          } else {
            print("Error downloading file: ${response.statusCode}");
          }
        }
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/$uniqueFileName';
        File file = File(filePath);

        final request = http.Request('GET', Uri.parse(fileUrl));
        final response = await http.Client().send(request);

        if (response.statusCode == 200) {
          int totalBytes = response.contentLength ?? 0;
          int receivedBytes = 0;

          // ✅ Show single notification when download starts
          await showDownloadNotification(
            fileName: fileName,
            filePath: filePath,
            notificationId: notificationId,
            isCompleted: false, // Downloading...
          );

          // Create the file and write to it in chunks
          await response.stream.listen((data) async{
            receivedBytes += data.length;
            progress = (receivedBytes / totalBytes) * 100;

            // Silent progress update (No extra notifications)
            if(progress == 100){
              await flutterLocalNotificationsPlugin.cancel(notificationId); // Optionally cancel when done
              await showDownloadNotification(
                fileName: fileName,
                filePath: filePath,
                notificationId: notificationId,
                isCompleted: true, // Download completed
              );
            }


            // Write data to file
            file.writeAsBytesSync(data, mode: FileMode.append);
          }, onDone: () async {
            print("File downloaded to: $filePath");

            // ✅ Update the same notification when the download is complete
            await showDownloadNotification(
              fileName: fileName,
              filePath: filePath,
              notificationId: notificationId,
              isCompleted: true, // Download completed
            );
          }, onError: (error) {
            print("Download error: $error");
          }, cancelOnError: true).asFuture(); // Convert Stream to Future
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


  Future<void> openDownloadedFile(String filePath) async {
    try {
      if (await requestStoragePermission()) {
        final file = File(filePath);

        if (await file.exists()) {
          final result = await OpenFile.open(filePath);
          if (result.type != ResultType.done) {
            if (Platform.isAndroid) {
              await launchUrl(Uri.parse("content://com.android.externalstorage.documents/document/primary:Download"));
            } else if (Platform.isIOS) {
              // Show alert if the file couldn't be opened
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


  Future<bool> requestStoragePermission() async {
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

}