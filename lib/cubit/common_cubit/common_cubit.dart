// import 'package:bloc/bloc.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/model/favorite_list_model.dart';
import 'package:e_connect/model/get_user_model.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

import '../../screens/sign_in_screen/sign_in_Screen.dart';
import '../../utils/common/common_function.dart';
import '../../utils/common/prefrance_function.dart';

part 'common_state.dart';

// class CommonCubit extends Cubit<CommonState> {
//   CommonCubit() : super(CommonInitial());
class CommonProvider extends ChangeNotifier {
  GetUserModel? getUserModel;
  final setCustomTextController = TextEditingController();
  int? selectedIndexOfStatus;
  String customStatusUrl = "";
  String customStatusTitle = "";

  void updatesCustomStatus(){
    selectedIndexOfStatus = null;
    setCustomTextController.text = getUserModel?.data?.user?.customStatus;
    customStatusTitle = getUserModel?.data?.user?.customStatus;
    customStatusUrl = getUserModel?.data?.user?.customStatusEmoji;
    notifyListeners();
  }

  void updateIndexForCustomStatus(int index,String title){
    selectedIndexOfStatus = index;
    setCustomTextController.text = title;
    // emit(CommonInitial());
    notifyListeners();
    print("selectedIndexOfStatus>>>>> $selectedIndexOfStatus");
  }

 clearUpdates(){
   selectedIndexOfStatus = null;
   setCustomTextController.clear();
   // emit(CommonInitial());
   notifyListeners();
 }



  Future<void> logOut() async {
    await clearData();
    pushAndRemoveUntil(screen: SignInScreen());
  }

  Future<void> updateStatusCall({required String status}) async {
    // emit(CommonInitial());
    final requestBody = {
      "status": status,
      "user_id": signInModel.data?.user?.id,
      "isAutomatic": false.toString(),
      "is_status": true.toString(),
    };
    // final header = {
    //   'Authorization': "Bearer ${signInModel.data!.authToken}",
    // };
    final response = await ApiService.instance.request(
        endPoint: ApiString.updateStatus,
        method: Method.POST,
        reqBody: requestBody,);
    if (statusCode200Check(response)) {
      getUserByIDCall();
      // emit(CommonInitial());
    }
    notifyListeners();
  }
  Future<void> updateCustomStatusCall({required String status,required String emojiUrl,}) async {
    // emit(CommonInitial());
    final requestBody = {
      "custom_status": status,
      "user_id": signInModel.data?.user?.id,
      "is_custom_status": "true",
      "custom_status_emoji": emojiUrl,
    };
    // final header = {
    //   'Authorization': "Bearer ${signInModel.data!.authToken}",
    // };
    final response = await ApiService.instance.request(
        endPoint: ApiString.updateStatus,
        method: Method.POST,
        reqBody: requestBody,);
    if (statusCode200Check(response)) {
      getUserByIDCall();
      clearUpdates();
      // emit(CommonInitial());
    }
    notifyListeners();
  }


  Future<void> getUserByIDCall() async {
    // emit(CommonInitial());
    final favoriteListModel = FavoriteListModel();
    // final header = {
    //   'Authorization': "Bearer ${signInModel.data!.authToken}",
    // };
    final response = await ApiService.instance.request(
        endPoint: "${ApiString.getUserById}/${signInModel.data?.user?.id}",
        method: Method.GET,);
    if (statusCode200Check(response)) {
      getUserModel = GetUserModel.fromJson(response);
      setCustomTextController.text = getUserModel?.data?.user?.customStatus;
      customStatusTitle = getUserModel?.data?.user?.customStatus;
      customStatusUrl = getUserModel?.data?.user?.customStatusEmoji;
      // print(">>>>>>>>>|||${getUserModel?.data?.user!.muteUsers!}");
      // print("STATUS>>>>>>>>>|||${getUserModel?.data?.user!.status!}");
      // favoriteListModel.data?.mutedUsers?.add(getUserModel?.data?.user?.muteUsers);
      // if (getUserModel?.data?.user?.muteUsers != null) {
      //   favoriteListModel.data?.mutedUsers ??= [];
      //   favoriteListModel.data?.mutedUsers?.add(getUserModel!.data!.user!.muteUsers!);
      // }
      // print("MUTEDS>> ${getUserModel?.data?.user?.muteUsers}");
      // print("MUTEDS>> ${favoriteListModel.data?.mutedUsers}");
      // emit(CommonInitial());
    }
    notifyListeners();
  }
  Future<GetUserModel?> getUserByIDCall2({String? userId}) async {
    // final header = {
    //   'Authorization': "Bearer ${signInModel.data!.authToken}",
    // };
    final response = await ApiService.instance.request(
        endPoint: "${ApiString.getUserById}/${userId ?? signInModel.data?.user?.id}",
        method: Method.GET,);
    if (statusCode200Check(response)) {
      getUserModel = GetUserModel.fromJson(response);
      // emit(CommonInitial());
      return getUserModel;
    }
    notifyListeners();
  }
}
