import 'package:e_connect/main.dart';
import 'package:e_connect/model/favorite_list_model.dart';
import 'package:e_connect/model/get_user_model.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/get_user_mention_model.dart';
import '../screens/sign_in_screen/sign_in_Screen.dart';
import '../utils/common/common_function.dart';
import '../utils/common/prefrance_function.dart';


class CommonProvider extends ChangeNotifier {
  GetUserModel? getUserModel;
  GetUserModelSecondUser? getUserModelSecondUser;
  final setCustomTextController = TextEditingController();
  int? selectedIndexOfStatus;
  String customStatusUrl = "";
  String customStatusTitle = "";
  bool isMutedUser = false;
  GetUserMentionModel? getUserMentionModel;
  List<Users>? allUsers;

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
    notifyListeners();
    print("selectedIndexOfStatus>>>>> $selectedIndexOfStatus");
  }

 clearUpdates(){
   selectedIndexOfStatus = null;
   setCustomTextController.clear();
   notifyListeners();
 }



  Future<void> logOut() async {
    await clearData();
    pushAndRemoveUntil(screen: SignInScreen());
  }

  Future<void> updateStatusCall({required String status}) async {
    if(getUserModel == null) return;
    if(getUserModel?.data!.user!.status != "offline") return;
    final requestBody = {
      "status": status,
      "user_id": signInModel.data?.user?.id,
      "isAutomatic": false.toString(),
      "is_status": true.toString(),
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.updateStatus,
        method: Method.POST,
        reqBody: requestBody,);
    if (statusCode200Check(response)) {
      getUserByIDCall();
    }
    notifyListeners();
  }
  Future<void> updateCustomStatusCall({required String status,required String emojiUrl,}) async {
    final requestBody = {
      "custom_status": status,
      "user_id": signInModel.data?.user?.id,
      "is_custom_status": "true",
      "custom_status_emoji": emojiUrl,
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.updateStatus,
        method: Method.POST,
        reqBody: requestBody,);
    if (statusCode200Check(response)) {
      getUserByIDCall();
      clearUpdates();
    }
    notifyListeners();
  }


  Future<void> getUserByIDCall(/*{String? userId}*/) async {
    final response = await ApiService.instance.request(endPoint: "${ApiString.getUserById}//${/*userId ?? */signInModel.data?.user?.id ?? ""}", method: Method.GET,);
    if (statusCode200Check(response)) {
      updateStatusCall(status: "online");
      getUserModel = GetUserModel.fromJson(response);
      // getUserModelSecondUser = GetUserModelSecondUser.fromJson(response);
      // isMutedUser = signInModel.data?.user!.muteUsers!.contains(userId) ?? false;
      setCustomTextController.text = getUserModel?.data?.user?.customStatus;
      customStatusTitle = getUserModel?.data?.user?.customStatus;
      customStatusUrl = getUserModel?.data?.user?.customStatusEmoji;
      notifyListeners();
    }
  }
  bool isLoadingGetUser = false;
  Future<GetUserModelSecondUser?> getUserByIDCallForSecondUser({String? userId}) async {
    print("Called>>>>getUserByIDCallForSecondUser>>>");
    try{
      isLoadingGetUser = true;
      if(userId != (getUserModelSecondUser?.data?.user?.sId ?? "")){
        getUserModelSecondUser = null;
        notifyListeners();
      }
      final response = await ApiService.instance.request(
        endPoint: "${ApiString.getUserById}/$userId", method: Method.GET,);
      if (statusCode200Check(response)) {
        getUserModelSecondUser = GetUserModelSecondUser.fromJson(response);
        print("getUserByIDCallForSecondUser>>>${getUserModelSecondUser?.data?.user?.pinnedMessageCount}");
        return getUserModelSecondUser;
      }
    }catch (e){
      print("error>>>> $e");
    }finally {
      isLoadingGetUser = false;
      notifyListeners();
  }}

  Future<GetUserModel?> getUserByIDCall2({String? userId}) async {
    final response = await ApiService.instance.request(
        endPoint: "${ApiString.getUserById}/${userId ?? signInModel.data?.user?.id}",
        method: Method.GET,);
    if (statusCode200Check(response)) {
      getUserModel = GetUserModel.fromJson(response);
      print("getUserByIDCall2>>>${getUserModel?.data?.user?.pinnedMessageCount}");
      return getUserModel;
    }
    notifyListeners();
  }
  Future<void> getUserApi({required String id})async{
    final requestBody = {"type": "message", "id": id};
    final response = await ApiService.instance.request(endPoint: ApiString.getUser, method: Method.POST,reqBody: requestBody);
    if (statusCode200Check(response)) {
      getUserMentionModel = GetUserMentionModel.fromJson(response);
    }
  }

  Future<void> getAllUsers() async {
    final requestBody = {"type": "message"};
    final response = await ApiService.instance.request(
      endPoint: ApiString.getUser,
      method: Method.POST,
      reqBody: requestBody
    );
    if (statusCode200Check(response)) {
      getUserMentionModel = GetUserMentionModel.fromJson(response);
      allUsers = getUserMentionModel?.data?.users;
      notifyListeners();
    }
  }

  Users? getUserById(String userId) {
    try {
      return getUserMentionModel!.data?.users?.firstWhere((user) => user.sId == userId);
    } catch (e) {
      return null;
    }
  }

  List<Users>? filterUsers(String? searchQuery) {
    if (searchQuery == null || searchQuery.isEmpty) {
      return allUsers;
    }
    return allUsers?.where((user) => 
      (user.username?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
      (user.fullName?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
    ).toList();
  }

}
