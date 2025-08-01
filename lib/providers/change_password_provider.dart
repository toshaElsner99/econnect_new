import 'package:e_connect/main.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/material.dart';

class ChangePasswordProvider extends ChangeNotifier {
  bool isLoading = false;

  Future<void> changePasswordCall({
    required String newPassword
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final requestBody = {"password": newPassword, "user_id": signInModel!.data!.user!.sId};

      final response = await ApiService.instance.request(
        endPoint: ApiString.updateStatus,
        method: Method.POST,
        reqBody: requestBody,
        needLoader: true,
      );

      if (Cf.instance.statusCode200Check(response)) {
        Cw.commonShowToast(
          response['message'] ?? "Password changed successfully",
          Colors.green,
        );
      } else {
        Cw.commonShowToast(
          response['message'] ?? "Failed to change password",
          Colors.red,
        );
      }
    } catch (e) {
      print("Error changing password: $e");
      Cw.commonShowToast(
        "Error changing password: $e",
        Colors.red,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
} 