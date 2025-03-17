
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../notificationServices/pushNotificationService.dart';
import '../utils/loading_widget/loading_cubit.dart';

class DownloadFileProvider extends ChangeNotifier {
  double progress = 0;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      NotificationService.flutterLocalNotificationsPlugin;

  Future<int> getDeviceSdkForAndroid() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  }

  /// ✅ Request Storage Permission Before Download (Only Needed for Android < 10)
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      int sdkInt = await getDeviceSdkForAndroid();
      if (sdkInt < 29) {
        return await Permission.storage.request().isGranted;
      }
    }
    return true; // No permission needed for Scoped Storage (Android 10+)
  }

  /// ✅ File Download Function Using Scoped Storage (Saves in `/Download/Econnect/`)
  Future<void> downloadFile({
    required String fileUrl,
    required BuildContext context,
  }) async {
    try {
      bool hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text("Storage permission is required to download files.")),
        );
        return;
      }

      progress = 0.0;
      String fileName = fileUrl.split('/').last;
      String formattedTime =
      DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String uniqueFileName = '${formattedTime}_$fileName';
      final int notificationId = DateTime.now().millisecondsSinceEpoch.hashCode;

      Provider.of<LoadingProvider>(context, listen: false).startLoading();

      String? filePath;

      if (Platform.isAndroid) {
        int sdkInt = await getDeviceSdkForAndroid();
        if (sdkInt >= 29) {
          // ✅ Save file using Scoped Storage in `/Download/Econnect/`
          filePath = await saveFileToScopedStorage(fileUrl, uniqueFileName);
        } else {
          // ✅ Save to external storage for Android 9 or lower
          filePath = await saveFileToLegacyStorage(fileUrl, uniqueFileName);
        }
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/$uniqueFileName';
      } else {
        return;
      }

      if (filePath == null) {
        print("Failed to get file path.");
        return;
      }

      // ✅ Show notification when download starts
      await NotificationService.showDownloadNotification(
        fileName: fileName,
        filePath: filePath,
        notificationId: notificationId,
        isCompleted: false,
      );

      print("Downloading file to: $filePath");

      final request = http.Request('GET', Uri.parse(fileUrl));
      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        int totalBytes = response.contentLength ?? 0;
        int receivedBytes = 0;
        File file = File(filePath);

        await response.stream.listen((data) async {
          receivedBytes += data.length;
          progress = (receivedBytes / totalBytes) * 100;
          file.writeAsBytesSync(data, mode: FileMode.append);

          if (progress == 100) {
            await NotificationService.showDownloadNotification(
              fileName: fileName,
              filePath: filePath!,
              notificationId: notificationId,
              isCompleted: true,
            );
          }
        }, onDone: () {
          print("File downloaded to: $filePath");
        }, onError: (error) {
          print("Download error: $error");
        }, cancelOnError: true).asFuture();
      } else {
        print("Error downloading file: ${response.statusCode}");
      }
    } catch (e) {
      print("Error downloading file: $e");
    } finally {
      Provider.of<LoadingProvider>(context, listen: false).stopLoading();
    }
  }

  /// ✅ Save File to `/Download/Econnect/` Using Scoped Storage (Android 10+)
  Future<String?> saveFileToScopedStorage(
      String fileUrl, String fileName) async {
    try {
      final directory = Directory('/storage/emulated/0/Download/Econnect');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final filePath = '${directory.path}/$fileName';
      return filePath;
    } catch (e) {
      print("Error saving file in Econnect folder: $e");
      return null;
    }
  }

  /// ✅ Save File Normally to `/Download/Econnect/` for Android 9 & Below
  Future<String?> saveFileToLegacyStorage(
      String fileUrl, String fileName) async {
    try {
      final directory = Directory('/storage/emulated/0/Download/Econnect');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final filePath = '${directory.path}/$fileName';
      return filePath;
    } catch (e) {
      print("Error saving file in Econnect folder: $e");
      return null;
    }
  }
}
