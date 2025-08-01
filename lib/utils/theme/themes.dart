import 'package:e_connect/utils/app_color_constants.dart';
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
    // brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    // scaffoldBackgroundColor: AppColor.appBarColor,
    primaryColor: AppColor.commonAppColor,
    hintColor: Colors.black,
    dialogBackgroundColor: Colors.white,
    dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white),

    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStatePropertyAll(AppColor.blackColor),
      thumbColor: WidgetStatePropertyAll(AppColor.appBarColor),
      trackColor: WidgetStatePropertyAll(AppColor.white),
    ),
    popupMenuTheme: PopupMenuThemeData(
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.transparent),
      ),
    ),
    appBarTheme: const AppBarTheme(
        centerTitle: false,
        titleSpacing: 0,
        surfaceTintColor: Colors.transparent,
        // backgroundColor: Colors.transparent,
        backgroundColor: AppColor.appBarColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColor.commonAppColor,
        unselectedItemColor: Colors.grey),
    primaryColorLight: const Color(0xFF3e3f4b),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: Colors.grey),
      errorStyle: TextStyle(color: Colors.red),
      activeIndicatorBorder: BorderSide(color: Colors.black),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.5),
      ),),
    iconTheme: const IconThemeData(color: Colors.black),
    iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(iconColor: MaterialStatePropertyAll(Colors.black))));

ThemeData darkMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColor.darkAppBarColor,
    primaryColor: AppColor.commonAppColor,
    hintColor: Colors.white,
    dialogBackgroundColor: const Color(0xFF212121),
    // bottomSheetTheme: ,
    dialogTheme: const DialogThemeData(surfaceTintColor: Colors.black),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStatePropertyAll(AppColor.white)
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStatePropertyAll(AppColor.white),
    ),
    popupMenuTheme: PopupMenuThemeData(
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColor.borderColor),
      ),
    ),
    appBarTheme: const AppBarTheme(
        centerTitle: false,
        titleSpacing: 0,
        surfaceTintColor: Colors.transparent,
        // backgroundColor: Colors.transparent,
        backgroundColor: AppColor.darkAppBarColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Colors.white, unselectedItemColor: Colors.grey),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: Colors.grey,),
      errorStyle: TextStyle(color: Colors.red),
      activeIndicatorBorder: BorderSide(color: Colors.white),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 1.5),
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    iconButtonTheme: const IconButtonThemeData(style: ButtonStyle(iconColor: MaterialStatePropertyAll(Colors.white))));
