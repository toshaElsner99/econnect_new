import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/material.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  bool isLoading = false;

  Future<void> forgotPasswordCall({required String email}) async {
    try {
      isLoading = true;
      notifyListeners();
      final requestBody = {"email": email};
      final response = await ApiService.instance.request(
        endPoint: ApiString.forgotPassword,
        method: Method.POST,
        reqBody: requestBody,
        needLoader: true,
      );
      if (Cf.instance.statusCode200Check(response)) {
        if(response['status'] == 1) {
          Cw.instance.commonShowToast(
            response['message'] ?? "Password reset link sent!",
            Colors.green,
          );
        }else{
          Cw.instance.commonShowToast(
            response['message'] ?? "Failed to send reset link",
            Colors.red,
          );
        }
      } else {
        Cw.instance.commonShowToast(
          response['message'] ?? "Failed to send reset link",
          Colors.red,
        );
      }
    } catch (e) {
      Cw.instance.commonShowToast(
        "Error: $e",
        Colors.red,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
} 