import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:e_connect/screens/server_connect_screen/server_connect_screen.dart';
import 'package:e_connect/screens/sign_in_screen/sign_in_Screen.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:meta/meta.dart';

import '../../screens/bottom_navigation_screen/bottom_navigation_screen.dart';
import '../../utils/app_preference_constants.dart';
import '../../utils/common/prefrance_function.dart';

part 'splash_screen_state.dart';

class SplashScreenCubit extends Cubit<SplashScreenState> {
  SplashScreenCubit() : super(SplashScreenInitial());

  whereToGO() async {
    final isLoggedIn = await getBool(AppPreferenceConstants.isLoginPrefs) ?? false;
    // final isConnectedToServer = await getBool(AppPreferenceConstants.isConnectedToServer) ?? false;
    print("isLoginInUser>>>>>>>> $isLoggedIn");
    // print("isConnectedToServer>>>>>>>> $isConnectedToServer");
    Timer(const Duration(seconds: 3), () {
      // if(isConnectedToServer != null){
        if (isLoggedIn != null) {
          if (isLoggedIn) {
            pushReplacement(screen: const BottomNavigationScreen());
          } else {
            pushReplacement(screen: const SignInScreen());
          }
        } else {
          pushReplacement(screen: const SignInScreen());
        }
      // }else {
      //   pushReplacement(screen: ServerConnectScreen());
      // }
    });
  }
}
