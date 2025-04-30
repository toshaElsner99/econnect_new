import 'package:e_connect/main.dart';
import 'package:e_connect/model/get_user_model.dart';
import 'package:e_connect/providers/sign_in_provider.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';


import '../model/get_user_mention_model.dart';
import '../notificationServices/pushNotificationService.dart';
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
    setCustomTextController.text = getUserModel?.data?.user?.customStatus ?? "";
    customStatusTitle = getUserModel?.data?.user?.customStatus ?? "";
    customStatusUrl = getUserModel?.data?.user?.customStatusEmoji ?? "";
    notifyListeners();
  }

  void updateIndexForCustomStatus(int index, String title){
    selectedIndexOfStatus = index;
    setCustomTextController.text = title;
    customStatusTitle = title;
    notifyListeners();
  }

  void clearUpdates(){
    selectedIndexOfStatus = null;
    setCustomTextController.clear();
    customStatusTitle = "";
    customStatusUrl = "";
    notifyListeners();
  }



  Future<void> logOut() async {
    var signInProvider = Provider.of<SignInProvider>(navigatorKey.currentState!.context,listen: false);
    signInProvider.fcmTokenRemoveInAPI();
    await clearData();
    Cf.instance.pushAndRemoveUntil(screen: SignInScreen());
    await NotificationService.clearBadgeCount();
    await NotificationService.clearAllNotifications();
  }

  Future<void> updateStatusCall({required String status}) async {
    final requestBody = {
      "status": status,
      "user_id": signInModel.data?.user?.id ?? "",
      "isAutomatic": false.toString(),
      "is_status": true.toString(),
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.updateStatus,
        method: Method.POST,
        reqBody: requestBody,);
    if (Cf.instance.statusCode200Check(response)) {
      getUserByIDCall();
    }
    notifyListeners();
  }
  Future<void> updateCustomStatusCall({required String status, String emojiUrl = ""}) async {
    final requestBody = {
      "custom_status": status,
      "user_id": signInModel.data?.user?.id,
      "is_custom_status": "true",
      if (emojiUrl.isNotEmpty) "custom_status_emoji": emojiUrl,
    };
    
    final response = await ApiService.instance.request(
      endPoint: ApiString.updateStatus,
      method: Method.POST,
      reqBody: requestBody,
    );
    
    if (Cf.instance.statusCode200Check(response)) {
      customStatusTitle = status;
      customStatusUrl = emojiUrl;
      getUserByIDCall();
      if (status.isEmpty && emojiUrl.isEmpty) {
        clearUpdates();
      }
    }
    notifyListeners();
  }


  Future<void> getUserByIDCall() async {
    final response = await ApiService.instance.request(endPoint: "${ApiString.getUserById}//${/*userId ?? */signInModel.data?.user?.id ?? ""}", method: Method.GET,);
    if (Cf.instance.statusCode200Check(response)) {
      getUserModel = GetUserModel.fromJson(response);
      // getUserModelSecondUser = GetUserModelSecondUser.fromJson(response);
      // isMutedUser = signInModel.data?.user!.muteUsers!.contains(userId) ?? false;
      setCustomTextController.text = getUserModel?.data?.user?.customStatus ?? "";
      customStatusTitle = getUserModel?.data?.user?.customStatus ?? "";
      customStatusUrl = getUserModel?.data?.user?.customStatusEmoji ?? "";
      notifyListeners();
    }
  }
  bool isLoadingGetUser = false;

  Future<GetUserModelSecondUser?> getUserByIDCallForSecondUser({String? userId}) async {
    try{
      isLoadingGetUser = true;
      if(userId != (getUserModelSecondUser?.data?.user?.sId ?? "")){
        getUserModelSecondUser = null;
        notifyListeners();
      }
      final response = await ApiService.instance.request(
        endPoint: "${ApiString.getUserById}/$userId", method: Method.GET,);
      if (Cf.instance.statusCode200Check(response)) {
        getUserModelSecondUser = GetUserModelSecondUser.fromJson(response);
        // print("getUserByIDCallForSecondUser>>>${getUserModelSecondUser?.data?.user?.pinnedMessageCount}");
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
    if (Cf.instance.statusCode200Check(response)) {
      getUserModel = GetUserModel.fromJson(response);
      print("getUserByIDCall2>>>${getUserModel?.data?.user?.pinnedMessageCount}");
      return getUserModel;
    }
    notifyListeners();
  }
  Future<void> getUserApi({required String id})async{
    final requestBody = {"type": "message", "id": id};
    final response = await ApiService.instance.request(endPoint: ApiString.getUser, method: Method.POST,reqBody: requestBody);
    if (Cf.instance.statusCode200Check(response)) {
      getUserMentionModel = GetUserMentionModel.fromJson(response);
      getUserMentionModel?.saveToPrefs(id);
      await GetUserMentionModel.loadFromPrefs(id);
      getUserMentionModel = (await GetUserMentionModel.loadFromPrefs(id))!;
    }
  }

  // Future<void> getAllUsers() async {
  //   try {
  //     print("Fetching all users...");
  //     final requestBody = {"type": "message"};
  //     final response = await ApiService.instance.request(
  //       endPoint: ApiString.getUser,
  //       method: Method.POST,
  //       reqBody: requestBody
  //     );
  //     if (statusCode200Check(response)) {
  //       getUserMentionModel = GetUserMentionModel.fromJson(response);
  //       allUsers = getUserMentionModel?.data?.users;
  //       print("Users fetched successfully. Count: ${allUsers?.length ?? 0}");
  //     } else {
  //       print("Failed to fetch users. Status code: ${response['statusCode']}");
  //     }
  //   } catch (e) {
  //     print("Error fetching users: $e");
  //     allUsers = [];  // Initialize to empty list on error
  //   } finally {
  //     notifyListeners();
  //   }
  // }


  List<Users>? filterUsers(String? searchQuery) {
    if (searchQuery == null || searchQuery.isEmpty) {
      return allUsers;
    }
    return allUsers?.where((user) => 
      (user.username?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
      (user.fullName?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
    ).toList();
  }

  bool isUserInAllUsers(String username) {
    final specialMentions = ['here', 'channel', 'all'];
    if (specialMentions.contains(username.toLowerCase())) {
      return true;
    }

    if (getUserMentionModel == null) {
      print("Warning: getUserMentionModel is null in isUserInAllUsers check");
      return false;
    }

    return getUserMentionModel?.data!.users!.any((user) =>
      user.username?.toLowerCase() == username.toLowerCase() ||
      user.fullName?.toLowerCase() == username.toLowerCase()
    ) ?? false;
  }

}
