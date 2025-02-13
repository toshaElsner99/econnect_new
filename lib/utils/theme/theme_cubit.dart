import 'package:e_connect/utils/app_preference_constants.dart';
import 'package:e_connect/utils/common/prefrance_function.dart';
import 'package:e_connect/utils/theme/themes.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeProvider() {
    loadThemeMode();
  }

  ThemeData themeData = lightMode;

  Future<void> toggleTheme() async {
    final isDarkMode = AppPreferenceConstants.themeModeBoolValueGet;
    if (isDarkMode) {
      themeData = lightMode;
      await setBool(AppPreferenceConstants.isDarkModePrefs, false);
    } else {
      themeData = darkMode;
      await setBool(AppPreferenceConstants.isDarkModePrefs, true);
    }
    AppPreferenceConstants.themeModeBoolValueGet = await getBool(AppPreferenceConstants.isDarkModePrefs) ?? false;
    notifyListeners();
  }

  Future<void> loadThemeMode() async {
    AppPreferenceConstants.themeModeBoolValueGet = await getBool(AppPreferenceConstants.isDarkModePrefs) ?? false;
    themeData = AppPreferenceConstants.themeModeBoolValueGet ? darkMode : lightMode;
    notifyListeners();
  }
}

// import 'package:flutter/material.dart';
//
// class ThemeProvider with ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.system;
//
//   ThemeMode get themeMode => _themeMode;
//
//   void toggleTheme() {
//     _themeMode = _themeMode == ThemeMode.light
//         ? ThemeMode.dark
//         : ThemeMode.light;
//     notifyListeners();
//   }
// }
