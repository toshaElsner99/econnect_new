import 'dart:async';

import 'package:e_connect/screens/sign_in_screen/sign_in_Screen.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';
import '../../screens/bottom_navigation_screen/bottom_navigation_screen.dart';
import '../../utils/app_preference_constants.dart';
import '../../utils/common/prefrance_function.dart';
import '../sign_in/sign_in_model.dart';

part 'splash_screen_state.dart';

class SplashScreenCubit extends Cubit<SplashScreenState> {
  SplashScreenCubit() : super(SplashScreenInitial());

  whereToGO() async {
    signInModel = (await SignInModel.loadFromPrefs()) ?? SignInModel();
    final isLoggedIn = await getBool(AppPreferenceConstants.isLoginPrefs) ?? false;
    Timer(const Duration(seconds: 3), () {
        if (isLoggedIn != null) {
          if (isLoggedIn) {
            pushReplacement(screen: const BottomNavigationScreen());
          } else {
            pushReplacement(screen: const SignInScreen());
          }
        } else {
          pushReplacement(screen: const SignInScreen());
        }
    });
  }
}
