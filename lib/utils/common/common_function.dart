import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_preference_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../screens/image_viewer_screen.dart';

import '../../main.dart';

class Cf {
  Cf._privateConstructor();
  static final Cf instance = Cf._privateConstructor();

String processContent(String content) {
  final urlRegex = RegExp(
    r'(https?:\/\/[^\s]+)',
    caseSensitive: false,
  );

  return content.replaceAllMapped(urlRegex, (match) {
    final url = match.group(0);
    return '<a href="$url" target="_blank" class="renderer_link">$url</a>';
  });
}

String formatDateString1(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  String formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
  return formattedDate;
}

String formatTime(String utcTime) {
  DateTime dateTime = DateTime.parse(utcTime).toLocal(); // Convert to local time
  return DateFormat('hh:mm a').format(dateTime); // Format in 12-hour AM/PM format
}

String formatDateWithYear(String dateHeader) {
  try {
    DateTime date = DateTime.parse(dateHeader);
    String formattedDate = DateFormat('MMMM dd, yyyy').format(date);
    return formattedDate;
  } catch (e) {
    print("Error parsing date: $e");
    return "";
  }
}
String formatDateTime(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(Duration(days: 1));

  if (dateTime.isAtSameMomentAs(today)) {
    return 'Today';
  } else if (dateTime.isAtSameMomentAs(yesterday)) {
    return 'Yesterday';
  } else {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }
}

String formatDateString(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return '';
  }

  try {
    DateTime dateTime = DateTime.parse(dateString).toLocal();
    String formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
    return formattedDate;
  } catch (e) {
    return '';
  }
}

String getTimeAgo(String dateString) {
  DateTime parsedDate = DateTime.parse(dateString);
  final now = DateTime.now();
  final difference = now.difference(parsedDate);

  if (difference.inSeconds < 60) {
    return "Last reply ${difference.inSeconds} sec ago";
  } else if (difference.inMinutes < 60) {
    return "Last reply ${difference.inMinutes} min ago";
  } else if (difference.inHours < 24) {
    return "Last reply ${difference.inHours} hr ago";
  } else if (difference.inDays < 30) {
    return "Last reply ${difference.inDays} day ago";
  } else if (difference.inDays < 365) {
    return "Last reply ${(difference.inDays / 30).floor()} month ago";
  } else {
    return "${(difference.inDays / 365).floor()} year ago";
  }
}

String getLastOnlineStatus(String status, String? timestamp) {
  if (status.toLowerCase() == "offline" && timestamp != null) {
    DateTime lastOnline = DateTime.parse(timestamp).toLocal();
    DateTime now = DateTime.now();
    Duration difference = now.difference(lastOnline);

    if (difference.inSeconds < 60) {
      return "Last online ${difference.inSeconds} sec ago";
    } else if (difference.inMinutes < 60) {
      return "Last online ${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "Last online ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
    } else if (difference.inDays == 1) {
      return "Last online yesterday";
    } else {
      return "Offline";
    }
  }
  return capitalizeFirstLetter(status);
}

Future<String> fetchFileSize(String url) async {
  try {
    final response = await http.head(Uri.parse(url));
    if (response.statusCode == 200) {
      String? contentLength = response.headers['content-length'];
      if (contentLength != null) {
        int sizeInBytes = int.parse(contentLength);
        return formatFileSize(sizeInBytes); // Convert to KB, MB, etc.
      }
    }
  } catch (e) {
    print("Error fetching file size: $e");
  }
  return "";
}

String formatFileSize(int bytes) {
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  int i = 0;
  double size = bytes.toDouble();

  while (size >= 1024 && i < suffixes.length - 1) {
    size /= 1024;
    i++;
  }

  return "${size.toStringAsFixed(2)} ${suffixes[i]}";
}

Widget getFileIconInChat({required String fileType, String? pngUrl}) {
  String? iconPath;

  switch (fileType) {
    case 'mp3':
    case 'wav':
    case 'aac':
      iconPath = AppImage.audioFile;
      break;
    case 'mp4':
    case 'avi':
    case 'mov':
    case 'mkv':
      iconPath = AppImage.videoFile;
      break;
    case 'xls':
    case 'xlsx':
      iconPath = AppImage.excelFile;
      break;
    case 'pdf':
      iconPath = AppImage.pdfFile;
      break;
    case 'txt':
      iconPath = AppImage.textFile;
      break;
    case 'png':
    case 'jpg':
    case 'jpeg':
      iconPath = ApiString.profileBaseUrl + pngUrl!;
      break;
    default:
      iconPath = AppImage.commonFile;
  }

  if (iconPath != null && !iconPath.contains(ApiString.profileBaseUrl)) {
    return Image.asset(iconPath, width: 40, height: 40, fit: BoxFit.contain, color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black);
  } else if (pngUrl != null && pngUrl.isNotEmpty) {
    return GestureDetector(
      onTap: () {
        try {
          Navigator.push(
            navigatorKey.currentState!.context,
            MaterialPageRoute(
              builder: (context) => ImageViewerScreen(imageUrl: pngUrl),
            ),
          );
        } catch (e) {
          print("Error navigating to image viewer: $e");
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2),
        color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.grey[800]!.withOpacity(0.6) : AppColor.lightGreyColor.withOpacity(0.6),
        child: CachedNetworkImage(imageUrl: pngUrl, width: 30, height: 40, fit: BoxFit.contain,
          errorWidget: (context, url, error) {
            return Image.asset(AppImage.commonFile, width: 40, height: 40, fit: BoxFit.contain, color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black);
          },
        ),
      ),
    );
  } else {
    return Image.asset(AppImage.commonFile, width: 40, height: 40, color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black);
  }
}

void copyToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Copied"), duration: Duration(seconds: 1)),
  );
}

String formatFileName(String fileName) {
  String extension = getFileExtension(fileName);
  String nameWithoutExt = fileName.replaceAll(".$extension", "");

  if (nameWithoutExt.length > 15) {
    return "${nameWithoutExt.substring(0, 15)}.....$extension";
  }
  return "$nameWithoutExt.$extension";
}

String getFileName(String path) {
  return path.split('/').last;
}

String getFileExtension(String path) {
  return path.split('.').last.toLowerCase();
}

String getFileType(String path) {
  return path.split('.').last.toUpperCase();
}


Future<dynamic> pushScreen({required Widget screen}) async {
  try {
    return await Navigator.push(
      navigatorKey.currentState!.context,
      MaterialPageRoute(builder: (context) => screen,),
    );
  } catch (e) {
    print("Error pushing screen: $e");
    return null;
  }
}

Future<void> pushReplacement({required Widget screen}) async {
  try {
    await Navigator.pushReplacement(
      navigatorKey.currentState!.context,
      MaterialPageRoute(builder: (context) => screen),
    );
  } catch (e) {
    print("Error pushing replacement screen: $e");
  }
}

void pushAndRemoveUntil({required Widget screen}) {
  try {
    Navigator.pushAndRemoveUntil(
      navigatorKey.currentState!.context,
      MaterialPageRoute(builder: (context) => screen),
          (route) => false,
    );
  } catch (e) {
    print("Error pushing and removing until screen: $e");
  }
}

Future<void> pop({bool? popValue}) async {
  try {
    Navigator.pop(navigatorKey.currentState!.context, popValue);
  } catch (e) {
    print("Error popping screen: $e");
  }
}

bool statusCode200Check(Map<String, dynamic> response, [bool checkForKarmaRes = false]) {
  if(checkForKarmaRes = true) {
    return (response['statusCode'] == 200 || response['statusCode'] == 201);
  }else {
    return(response['success'] == true);
  }
}

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}

dynamicSize({required double size,required BuildContext context, bool width = false}){
  final screenSize = MediaQuery.of(context).size;
  return width ? screenSize.width * (size / screenSize.width) : screenSize.height * (size / screenSize.height);
}

String? validateEmail(String? value, TextEditingController textController) {
    bool emailValid = RegExp(r'^\S+@[a-zA-Z]+\.[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(textController.text);
    if (value!.isEmpty) {
      return "Email field cannot be empty";
    } else if (!emailValid) {
      return "Please enter valid email";
    }
    return null;
}

String? validatePassword(TextEditingController controller, String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter password";
  } /*else if (value.trim() != value) {
    return "Please enter a valid password";
  } else if (!RegExp(r'^(?=.*[A-Z])').hasMatch(controller.text)) {
    return 'Password must contain uppercase letters';
  } else if (!RegExp(r'(?=.*[a-z])').hasMatch(controller.text)) {
    return 'Password must contain lowercase letters';
  } else if (!RegExp(r'(?=.*[@#\$%^&+=!])').hasMatch(controller.text)) {
    return 'Password must contain at least one special character';
  } else if (!RegExp(r'(?=.*?[0-9])').hasMatch(controller.text)) {
    return 'Password must contain at least one numeric character';
  } else if (!RegExp(r'(?=.{8,})').hasMatch(controller.text)) {
    return 'Password must contain at least 8 characters';
  }*/
  return null;
}

String? validatePhoneNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Phone number cannot be empty';
  }
  if (value.length != 9) {
    return 'Phone number must be 9 digits';
  }
  return null;
}
String? validateTwoControllerMatch(String? value,TextEditingController textController,String? returnMsg) {
  if (value == null || value.isEmpty) {
    return 'Password cannot be empty';
  }
  if (value != textController.text.trim()) {
    return returnMsg ?? 'Field not matched';
  }
  return null;
}

String? validateNonEmpty(String? value, String returnMsg) {
  if (value == null || value.isEmpty) {
    return '$returnMsg field cannot be empty';
  }
  return null;
}

bool isImage(String extension) {
  return ['jpg', 'png', 'jpeg'].contains(extension.toLowerCase());
}

Widget getFileIcon(String? extension, String? filePath) {
  if (extension == null || filePath == null) {
    return Image.asset(AppImage.commonFile, fit: BoxFit.contain);
  }

  if (isImage(extension)) {
    try {
      return Image.file(
          File(filePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading file image: $error");
            return Image.asset(AppImage.commonFile, fit: BoxFit.contain);
          },
      );
    } catch (e) {
      print("Error creating file image widget: $e");
      return Image.asset(AppImage.commonFile, fit: BoxFit.contain);
    }
  }

  String iconPath;
  switch (extension) {
    case 'mp3':
    case 'wav':
    case 'aac':
      iconPath = AppImage.audioFile;
      break;
    case 'mp4':
    case 'avi':
    case 'mov':
    case 'mkv':
      iconPath = AppImage.videoFile;
      break;
    case 'xls':
    case 'xlsx':
      iconPath = AppImage.excelFile;
      break;
    case 'pdf':
      iconPath = AppImage.pdfFile;
      break;
    case 'txt':
      iconPath = AppImage.textFile;
      break;
    default:
      iconPath = AppImage.commonFile;
  }

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Image.asset(iconPath, fit: BoxFit.contain,width: 30,height: 20,),
  );
}

String formatDateTime2(String dateTimeStr) {
  if(dateTimeStr == " "){
    return "";
  }else if(dateTimeStr == null){
    return "";
  }else if(dateTimeStr == "null"){
    return "";
  }else if(dateTimeStr == ""){
    return "";
  }
  DateTime parsedDate = DateTime.parse(dateTimeStr).toLocal(); // Convert to local time
  DateTime now = DateTime.now();
  DateTime yesterday = now.subtract(Duration(days: 1));

  if (parsedDate.year == now.year &&
      parsedDate.month == now.month &&
      parsedDate.day == now.day) {
    return DateFormat('hh:mm a').format(parsedDate);
  } else if (parsedDate.year == yesterday.year &&
      parsedDate.month == yesterday.month &&
      parsedDate.day == yesterday.day) {
    return "Yesterday";
  } else {
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }
}

static void showCommonDialog(BuildContext context, String title, String message, {String buttonText = "OK"}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(buttonText),
        ),
      ],
    ),
  );
}

}
class NoLeadingSpacesFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove leading spaces from the new value
    final newText = newValue.text.trimLeft();

    // Ensure that the selection range is adjusted correctly
    final newSelection = _adjustSelection(
      newValue.selection,
      newText,
    );

    return TextEditingValue(
      text: newText,
      selection: newSelection,
      composing: newValue.composing,
    );
  }

  TextSelection _adjustSelection(TextSelection selection, String newText) {
    final newBase = selection.baseOffset;
    final newExtent = selection.extentOffset;

    // Ensure selection indices are within the new text bounds
    final adjustedBase = newBase.clamp(0, newText.length);
    final adjustedExtent = newExtent.clamp(0, newText.length);

    return TextSelection(
      baseOffset: adjustedBase,
      extentOffset: adjustedExtent,
    );
  }
}
