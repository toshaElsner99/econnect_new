
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
String formatDateString1(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  String formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
  return formattedDate;
}

String formatTime(String utcTime) {
  DateTime dateTime = DateTime.parse(utcTime).toLocal(); // Convert to local time
  return DateFormat('hh:mm a').format(dateTime); // Format in 12-hour AM/PM format
}

String formatDateString(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return '';
  }

  try {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
    return formattedDate;
  } catch (e) {
    return '';
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
  return ""; // Return empty if size is unknown
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
      iconPath = pngUrl;
      break;
    default:
      iconPath = AppImage.commonFile;
  }

  if (iconPath != null && !iconPath.contains(ApiString.profileBaseUrl)) {
    return Image.asset(iconPath, width: 40, height: 40, fit: BoxFit.contain);
  } else if (pngUrl != null && pngUrl.isNotEmpty) {
    return InstaImageViewer(
      imageUrl: pngUrl,
      backgroundIsTransparent: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2),
        color: AppColor.lightGreyColor.withOpacity(0.6),
        child: CachedNetworkImage(imageUrl: pngUrl, width: 30, height: 40, fit: BoxFit.contain,
          errorWidget: (context, url, error) {
            return Image.asset(AppImage.commonFile, width: 40, height: 40,fit: BoxFit.contain,);
          },
        ),
      ),
    );
  } else {
    return Image.asset(AppImage.commonFile, width: 40, height: 40);
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
void pushScreenWithTransition( Widget screen) {
  Navigator.of(navigatorKey.currentState!.context).push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1), // Start from bottom
            end: Offset.zero, // Move to normal position
          ).animate(animation),
          child: child,
        );
      },
    ),
  );
}

Future<void> pushScreen({required Widget screen}) async {
  Navigator.push(
    navigatorKey.currentState!.context,
    MaterialPageRoute(builder: (context) => screen,),
  ).then((_) {});
}

Future<void> pushReplacement({required Widget screen}) async {
  Navigator.pushReplacement(
    navigatorKey.currentState!.context,
    MaterialPageRoute(builder: (context) => screen),
  ).then((value) {});
}

void pushAndRemoveUntil({required Widget screen}) {
  Navigator.pushAndRemoveUntil(
    navigatorKey.currentState!.context,
    MaterialPageRoute(builder: (context) => screen),
        (route) => false,
  );
}

Future<void> pop() async {
  Navigator.pop(navigatorKey.currentState!.context);
}

bool statusCode200Check(Map<String, dynamic> response) {
  return(response['statusCode'] == 200 || response['statusCode'] == 201);
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
  } else if (value.trim() != value) {
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
  }
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
    return 'Phone number cannot be empty';
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
    return Image.file(
        File(filePath),
        fit: BoxFit.cover);
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
