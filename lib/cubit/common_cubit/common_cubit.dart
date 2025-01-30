import 'package:bloc/bloc.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/model/get_user_model.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../screens/sign_in_screen/sign_in_Screen.dart';
import '../../utils/common/common_function.dart';
import '../../utils/common/prefrance_function.dart';

part 'common_state.dart';

class CommonCubit extends Cubit<CommonState> {
  CommonCubit() : super(CommonInitial());
  GetUserModel? getUserModel;

  Future<void> logOut() async {
    await clearData();
    pushAndRemoveUntil(screen: SignInScreen());
  }

  Future<void> updateStatusCall({required String status}) async {
    final requestBody = {
      "status": status,
      "user_id": signInModel.data?.user?.id,
      "isAutomatic": false.toString(),
      "is_status": true.toString(),
    };
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.updateStatus,
        method: Method.POST,
        reqBody: requestBody,
        headers: header);
    if (statusCode200Check(response)) {
      getUserByIDCall();
      emit(CommonInitial());
    }
  }
  Future<void> updateCustomStatusCall({required String status,required String emojiUrl}) async {
    final requestBody = {
      "custom_status": status,
      "user_id": signInModel.data?.user?.id,
      "is_custom_status": "false",
      "custom_status_emoji": emojiUrl,
    };
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.updateStatus,
        method: Method.POST,
        reqBody: requestBody,
        headers: header);
    if (statusCode200Check(response)) {
      // getUserByIDCall();
      emit(CommonInitial());
    }
  }

  Future<void> getUserByIDCall() async {
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final response = await ApiService.instance.request(
        endPoint: "${ApiString.getUserById}/${signInModel.data?.user?.id}",
        method: Method.GET,
        headers: header);
    if (statusCode200Check(response)) {
      getUserModel = GetUserModel.fromJson(response);
      emit(CommonInitial());
    }
  }
}
