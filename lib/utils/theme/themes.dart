import 'package:e_connect/utils/app_color_constants.dart';
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: AppColor.commonAppColor,
    hintColor: Colors.black,
    dialogBackgroundColor: Colors.white,
    dialogTheme: const DialogTheme(surfaceTintColor: Colors.white),
    appBarTheme: const AppBarTheme(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
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
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: AppColor.commonAppColor,
    hintColor: Colors.white,
    dialogBackgroundColor: const Color(0xFF212121),
    dialogTheme: const DialogTheme(surfaceTintColor: Colors.black),
    appBarTheme: const AppBarTheme(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
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
