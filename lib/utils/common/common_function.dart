
import 'dart:io';

import 'package:e_connect/utils/app_image_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';

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
  Navigator.of(navigatorKey!.currentState!.context).push(
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
    child: Image.asset(iconPath, fit: BoxFit.contain),
  );
}
