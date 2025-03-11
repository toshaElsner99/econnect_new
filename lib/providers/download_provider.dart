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

  /// ✅ Request Storage Permission Before Download
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      int sdkInt = await getDeviceSdkForAndroid();
      if (sdkInt >= 30) {
        return await Permission.manageExternalStorage.request().isGranted;
      } else {
        return await Permission.storage.request().isGranted;
      }
    }
    return true;
  }

  /// ✅ File Download Function
  Future<void> downloadFile({
    required String fileUrl,
    required BuildContext context,
  }) async {
    try {
      // ✅ Step 1: Request Permission First
      bool hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Storage permission is required to download files.")),
        );
        return;
      }

      // ✅ Step 2: Initialize Variables
      progress = 0.0;
      String fileName = fileUrl.split('/').last;
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final int notificationId = DateTime.now().millisecondsSinceEpoch.hashCode;

      Provider.of<LoadingProvider>(context, listen: false).startLoading();

      String filePath;
      if (Platform.isAndroid) {
        const downloadPath = '/storage/emulated/0/Download';
        final directory = await Directory(downloadPath).create(recursive: true);
        filePath = '${directory.path}/$uniqueFileName';
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/$uniqueFileName';
      } else {
        return;
      }

      File file = File(filePath);

      // ✅ Step 3: Start Download
      final request = http.Request('GET', Uri.parse(fileUrl));
      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        int totalBytes = response.contentLength ?? 0;
        int receivedBytes = 0;

        // ✅ Show notification when download starts
        await NotificationService.showDownloadNotification(
          fileName: fileName,
          filePath: filePath,
          notificationId: notificationId,
          isCompleted: false,
        );

        await response.stream.listen((data) async {
          receivedBytes += data.length;
          progress = (receivedBytes / totalBytes) * 100;
          file.writeAsBytesSync(data, mode: FileMode.append);

          // ✅ Update notification only when the download completes
          if (progress == 100) {
            await NotificationService.showDownloadNotification(
              fileName: fileName,
              filePath: filePath,
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

  /// ✅ Open Downloaded File
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
}
