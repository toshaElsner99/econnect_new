import 'dart:async';

import 'package:e_connect/screens/bottom_nav_tabs/home_screen.dart';
import 'package:e_connect/screens/sign_in_screen/sign_in_Screen.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:flutter/cupertino.dart';

import '../main.dart';
import '../utils/app_preference_constants.dart';
import '../utils/common/prefrance_function.dart';
import '../model/sign_in_model.dart';


class SplashProvider extends ChangeNotifier{
  whereToGO() async {
    signInModel = (await SignInModel.loadFromPrefs()) ?? SignInModel();
    final isLoggedIn = await getBool(AppPreferenceConstants.isLoginPrefs) ?? false;
    Timer(const Duration(seconds: 3), () {
        if (isLoggedIn != null) {
          if (isLoggedIn) {
            pushReplacement(screen: const HomeScreen());
          } else {
            pushReplacement(screen: const SignInScreen());
          }
        } else {
          pushReplacement(screen: const SignInScreen());
        }
    });
    notifyListeners();
  }
}
