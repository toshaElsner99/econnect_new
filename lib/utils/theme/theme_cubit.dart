import 'package:bloc/bloc.dart';
import 'package:e_connect/utils/app_preference_constants.dart';
import 'package:e_connect/utils/common/prefrance_function.dart';
import 'package:e_connect/utils/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> with WidgetsBindingObserver {
  ThemeCubit() : super(ThemeInitial()) {
    loadThemeMode();
    WidgetsBinding.instance.addObserver(this);
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
    emit(ThemeUpdated(themeData));
  }

  Future<void> loadThemeMode() async {
    AppPreferenceConstants.themeModeBoolValueGet = await getBool(AppPreferenceConstants.isDarkModePrefs) ?? false;
    themeData = AppPreferenceConstants.themeModeBoolValueGet ? darkMode : lightMode;
    emit(ThemeUpdated(themeData));
  }
}


