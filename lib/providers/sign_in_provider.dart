
import 'package:e_connect/model/sign_in_model.dart';
import 'package:e_connect/screens/bottom_nav_tabs/home_screen.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/app_preference_constants.dart';
import '../utils/common/common_function.dart';
import '../utils/common/prefrance_function.dart';



class SignInProvider extends ChangeNotifier {
  final emailController = TextEditingController(text: "etamd501@elsner.com");
  final passwordController = TextEditingController(text: "Bhavik@123");
  bool isVisible = true;
  final formKey = GlobalKey<FormState>();
  // late SignInModel signInModel;
  void toggleEyeVisibility() {
    isVisible = !isVisible;
    // emit(SignInInitial());
    notifyListeners();

  }

  void clearField() {
    emailController.clear();
    passwordController.clear();
    isVisible = true;
    // emit(SignInInitial());
    notifyListeners();

  }

  Future<void> signINCALL() async {
    final requestBody = {
      "email": emailController.text.toLowerCase().trim(),
      "password": passwordController.text.trim()
    };
      if (formKey.currentState!.validate()) {
        final response = await ApiService.instance.request(endPoint: ApiString.login, method: Method.POST,reqBody: requestBody,);
        if (statusCode200Check(response)) {
            await setBool(AppPreferenceConstants.isLoginPrefs, true);
            signInModel = SignInModel.fromJson(response);
            signInModel.saveToPrefs();
            await SignInModel.loadFromPrefs();
            signInModel = (await SignInModel.loadFromPrefs())!;
            pushAndRemoveUntil(screen: const HomeScreen());
            clearField();
        }
      } else {
        commonShowToast("Please enter your email and password",Colors.red);
      }
  }
}
