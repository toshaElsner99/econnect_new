import 'dart:convert';

import 'package:e_connect/model/sign_in_model.dart';
import 'package:e_connect/screens/bottom_nav_tabs/home_screen.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../main.dart';
import '../utils/app_preference_constants.dart';
import '../utils/common/common_function.dart';
import '../utils/common/prefrance_function.dart';
import 'package:http/http.dart' as http;

class SignInProvider extends ChangeNotifier {
  final emailController = TextEditingController(text: "");
  final passwordController = TextEditingController(text: "");
  final List domainList = [];

  bool isVisible = true;
  final formKey = GlobalKey<FormState>();
  void toggleEyeVisibility() {
    isVisible = !isVisible;
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
      final response = await ApiService.instance.request(
        endPoint: ApiString.login,
        method: Method.POST,
        reqBody: requestBody,
      );
      if (statusCode200Check(response)) {
        fcmTokenSendInAPI();
        await setBool(AppPreferenceConstants.isLoginPrefs, true);
        signInModel = SignInModel.fromJson(response);
        signInModel.saveToPrefs();
        await SignInModel.loadFromPrefs();
        signInModel = (await SignInModel.loadFromPrefs())!;
        pushAndRemoveUntil(screen: const HomeScreen());
        clearField();
      }
    } else {
      commonShowToast("Please enter your email and password", Colors.red);
    }
  }

  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<void> signInWithGoogle(BuildContext? context) async {
    await googleSignIn.signOut();

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final email = googleUser.email;
      final domain = email.split('@').last;

      print("Selected email: $email, domain: $domain");

      if (domainList.contains(domain)) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final String? idToken = googleAuth.idToken;

        if (idToken != null && idToken.isNotEmpty) {
          // await sendTokenToBackend(idToken);
        } else {
          print("❌ ID token is null or empty.");
        }
      } else {
        print("❌ Email domain not allowed.");
        commonShowToast("❌ Email domain not allowed");
      }
    } catch (e) {
      print("❌ Google sign-in failed: $e");
      commonShowToast("❌ Google sign-in failed");
    }
  }

  fcmTokenSendInAPI() async {
    String? fcmToken = "";

    fcmToken = await FirebaseMessaging.instance.getToken();
    await setData(AppPreferenceConstants.fcmToken, fcmToken ?? "");

    print("FCM_Token From login :::::> $fcmToken");
    if (fcmToken != null) {
      final requestBody = {"deviceToken": fcmToken};
      final response = await ApiService.instance.request(
          endPoint: ApiString.addDeviceToken,
          method: Method.POST,
          reqBody: requestBody);
      if (statusCode200Check(response)) {
        print("FCM Token Send Successfully");
      }
    }
  }

  fcmTokenRemoveInAPI() async {
    String? fcmToken = "";
    fcmToken = await getData(AppPreferenceConstants.fcmToken);

    print("FCM_Token From logout :::::> $fcmToken");
    if (fcmToken != null) {
      final requestBody = {"deviceToken": fcmToken};
      final response = await ApiService.instance.request(
          endPoint: ApiString.removeDeviceToken,
          method: Method.POST,
          reqBody: requestBody);
      if (statusCode200Check(response)) {
        print("FCM Token Removed Successfully");
      }
    }
  }

  Future<void> getDomainsCall() async {
    final url = Uri.parse('https://dev-hrms.elsner.com/api/emailDomain');
    print("DOMAIN URL: $url");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        domainList.clear();
        for (var item in data) {
          if (item['isActive'] == true && item['domain'] != null) {
            domainList.add(item['domain']);
          }
        }
        print('Domains: $domainList');
      } else {
        print('Failed to load domains: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching domains: $e');
    }
  }
}
