import 'dart:convert';
import 'dart:io';

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
  final List domainList =
  ["elsner.com", "elsner.in", "elsner.com.au", "linkpublishers.com"]; /// make it empty if needed

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
      if (Cf.instance.statusCode200Check(response)) {
        fcmTokenSendInAPI();
        await setBool(AppPreferenceConstants.isLoginPrefs, true);
        signInModel = SignInModel.fromJson(response);
        signInModel.saveToPrefs();
        await SignInModel.loadFromPrefs();
        signInModel = (await SignInModel.loadFromPrefs())!;
        Cf.instance.pushAndRemoveUntil(screen: const HomeScreen());
        clearField();
      }
    } else {
      Cw.instance.commonShowToast("Please enter your email and password", Colors.red);
    }
  }

  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile'],);

  Future<void> signInWithGoogle(BuildContext? context) async {
    try {
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in flow
        print("Google sign-in canceled by user");
        return;
      }

      final email = googleUser.email;
      final domain = email.split('@').last;

      if (domainList.contains(domain)) {
        try {
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final String? idToken = googleAuth.idToken;

          if (idToken != null && idToken.isNotEmpty) {
            await sendGoogleEmailToBackend(email);
          } else {
            Cw.instance.commonShowToast("Failed to get authentication token", Colors.white);
          }
        } catch (e) {
          print("❌ Google authentication failed: $e");
          Cw.instance.commonShowToast("❌ Authentication failed: $e", Colors.white);
        }
      } else {
        Cw.instance.commonShowToast("❌ Email domain not allowed", Colors.white);
      }
    } catch (e) {
      print("❌ Google sign-in failed: $e");
      Cw.instance.commonShowToast("❌ Google sign-in failed", Colors.white);
    }
  }

  Future<void> sendGoogleEmailToBackend(String email)async {
    try {
      final response = await ApiService.instance.request(
          endPoint: ApiString.googleSignIn,
          method: Method.POST,
          needLoader: true,
          reqBody: {
          "credential": email.trim().toString().toLowerCase()
          });
          
      if(Cf.instance.statusCode200Check(response) || response['statusCode'] == 200){
        await setBool(AppPreferenceConstants.isLoginPrefs, true);
        
        // Create and save the SignInModel before sending FCM token
        if (response['data'] != null) {
          signInModel = SignInModel.fromJson(response);
          await signInModel.saveToPrefs();
          await SignInModel.loadFromPrefs();
          signInModel = (await SignInModel.loadFromPrefs())!;
          
          // Now that we have a valid token, send FCM token
          await fcmTokenSendInAPI();
          
          Cf.instance.pushAndRemoveUntil(screen: const HomeScreen());
          clearField();
        } else {
          Cw.instance.commonShowToast("Invalid login response", Colors.white);
        }
      } else {
        Cw.instance.commonShowToast("Sign in Failed", Colors.white);
      }
    } catch (e) {
      print("Google sign-in backend error: $e");
      Cw.instance.commonShowToast("Sign in Failed: $e", Colors.white);
    }
  }

  fcmTokenSendInAPI() async {
    String? fcmToken = "";

    fcmToken = await FirebaseMessaging.instance.getToken();
    await setData(AppPreferenceConstants.fcmToken, fcmToken ?? "");

    print("FCM_Token From login :::::> $fcmToken");
    if (fcmToken != null && signInModel.data?.authToken != null) {
      final requestBody = {"deviceToken": fcmToken};
      try {
        final response = await ApiService.instance.request(
            endPoint: ApiString.addDeviceToken,
            method: Method.POST,
            reqBody: requestBody);
        if (Cf.instance.statusCode200Check(response)) {
          print("FCM Token Send Successfully");
        }
      } catch (e) {
        print("Error sending FCM token: $e");
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
      if (Cf.instance.statusCode200Check(response)) {
        print("FCM Token Removed Successfully");
      }
    }
  }
  /// Domain List Api Call ///
  // Future<void> getDomainsCall() async {
  //   final url = Uri.parse('https://dev-hrms.elsner.com/api/emailDomain');
  //   print("DOMAIN URL: $url");
  //   try {
  //     final response = await http.get(url);
  //
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       domainList.clear();
  //       for (var item in data) {
  //         if (item['isActive'] == true && item['domain'] != null) {
  //           domainList.add(item['domain']);
  //         }
  //       }
  //       print('Domains: $domainList');
  //     } else {
  //       print('Failed to load domains: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching domains: $e');
  //   }finally{
  //     notifyListeners();
  //   }
  // }
}
