import 'package:bloc/bloc.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:meta/meta.dart';

import '../../screens/sign_in_screen/sign_in_Screen.dart';
import '../../utils/common/common_function.dart';
import '../../utils/common/prefrance_function.dart';

part 'common_state.dart';

class CommonCubit extends Cubit<CommonState> {
  CommonCubit() : super(CommonInitial());

  Future<void> logOut() async {
    await clearData();
    pushAndRemoveUntil(screen: SignInScreen());
  }

  Future<void> updateStatusCall({required String status}) async {
    final requestBody = {
      "status": status,
      "user_id": signInModel.data?.user?.id,
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
      pop();
    }
  }

  Future<void> getUserByIDCall() async {
    final queryParams = {
      "getUserById": signInModel.data?.user?.id,
    };
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.getUserById,
        method: Method.GET,
        queryParams: queryParams,
        headers: header);
    if (statusCode200Check(response)) {
    }
  }
}
