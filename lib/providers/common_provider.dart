import 'package:e_connect/main.dart';
import 'package:e_connect/model/get_user_model.dart';
import 'package:e_connect/providers/sign_in_provider.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/services/user_cache_service.dart';
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

  // Global user cache service instance
  final UserCacheService _userCacheService = UserCacheService();

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
    await signInProvider.fcmTokenRemoveInAPI();
    await clearData();
    // Clear user cache on logout
    _userCacheService.clearCache();
    Cf.instance.pushAndRemoveUntil(screen: SignInScreen());
    await NotificationService.clearBadgeCount();
    await NotificationService.clearAllNotifications();
  }

  Future<void> updateStatusCall({required String status}) async {
    final requestBody = {
      "status": status,
      "user_id": signInModel!.data?.user?.sId ?? "",
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
      "customStatus": status,
      "user_id": signInModel!.data?.user?.sId,
      "is_custom_status": "true",
      if (emojiUrl.isNotEmpty) "customStatusEmoji": emojiUrl,
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
    try {
      final response = await ApiService.instance.request(endPoint: "${ApiString.getUserById}/${/*userId ?? */signInModel!.data?.user?.sId ?? ""}", method: Method.POST,isRawPayload: false);
      if (Cf.instance.statusCode200Check(response)) {
        getUserModel = GetUserModel.fromJson(response);
        // Cache the current user data
        if (getUserModel != null && signInModel?.data?.user?.sId != null) {
          _userCacheService.cacheUser(signInModel!.data!.user!.sId!, getUserModel!);
        }
        setCustomTextController.text = getUserModel?.data?.user?.customStatus ?? "";
        customStatusTitle = getUserModel?.data?.user?.customStatus ?? "";
        customStatusUrl = getUserModel?.data?.user?.customStatusEmoji ?? "";
        notifyListeners();
      }
    } catch (e) {
      print("Error in getUserByIDCall: $e");
      // Optionally show user feedback or handle gracefully
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

      // Try to get from cache first
      final cachedUser = _userCacheService.getSecondUserDataSync(userId ?? "");
      if (cachedUser != null) {
        getUserModelSecondUser = cachedUser;
        return cachedUser;
      }

      // Fetch from API if not in cache
      final response = await ApiService.instance.request(
        endPoint: "${ApiString.getUserById}/$userId", method: Method.POST,isRawPayload: false);
      print("this is the GetUserModelSecondUser!!! ${response}");
      if (Cf.instance.statusCode200Check(response)) {
        getUserModelSecondUser = GetUserModelSecondUser.fromJson(response);
        // Cache the user data
        if (getUserModelSecondUser != null && userId != null) {
          _userCacheService.cacheSecondUser(userId, getUserModelSecondUser!);
        }
        return getUserModelSecondUser;
      }
    }catch (e){
      print("error>>>> $e");
    }finally {
      isLoadingGetUser = false;
      notifyListeners();
  }}

  Future<GetUserModel?> getUserByIDCall2({String? userId}) async {
    // Try to get from cache first
    final cachedUser = _userCacheService.getUserDataSync(userId ?? signInModel!.data?.user?.sId ?? "");
    if (cachedUser != null) {
      getUserModel = cachedUser;
      return cachedUser;
    }

    // Fetch from API if not in cache
    final response = await ApiService.instance.request(
        endPoint: "${ApiString.getUserById}/${userId ?? signInModel!.data?.user?.sId}",
        method: Method.POST,
    isRawPayload: false
    );
    if (Cf.instance.statusCode200Check(response)) {
      getUserModel = GetUserModel.fromJson(response);
      // Cache the user data
      if (getUserModel != null && userId != null) {
        _userCacheService.cacheUser(userId, getUserModel!);
      }
      print("getUserByIDCall2>>>${getUserModel?.data?.user?.pinnedMessageCount}");
      return getUserModel;
    }
    notifyListeners();
  }
  
  Future<void> getUserApi({required String id})async{
    try {
      final requestBody = {"type": "message", "id": id};
      final response = await ApiService.instance.request(endPoint: ApiString.getUser, method: Method.GET,reqBody: requestBody);
      if (Cf.instance.statusCode200Check(response)) {
        getUserMentionModel = GetUserMentionModel.fromJson(response);
        try {
          getUserMentionModel?.saveToPrefs(id);
          await GetUserMentionModel.loadFromPrefs(id);
          getUserMentionModel = (await GetUserMentionModel.loadFromPrefs(id))!;
        } catch (e) {
          print("Error saving/loading user mention model: $e");
        }
      }
    } catch (e) {
      print("Error in getUserApi: $e");
    }
  }

  // Global user cache service getters
  UserCacheService get userCacheService => _userCacheService;

  /// Get user data from global cache
  Future<GetUserModel?> getUserFromCache(String userId) async {
    return await _userCacheService.getUserData(userId);
  }

  /// Get second user data from global cache
  Future<GetUserModelSecondUser?> getSecondUserFromCache(String userId) async {
    return await _userCacheService.getSecondUserData(userId);
  }

  /// Get user data synchronously from cache
  GetUserModel? getUserFromCacheSync(String userId) {
    return _userCacheService.getUserDataSync(userId);
  }

  /// Get second user data synchronously from cache
  GetUserModelSecondUser? getSecondUserFromCacheSync(String userId) {
    return _userCacheService.getSecondUserDataSync(userId);
  }

  /// Get user display name from cache
  String getUserDisplayName(String userId) {
    return _userCacheService.getUserDisplayName(userId);
  }

  /// Get user display name with API fallback
  Future<String> getUserDisplayNameAsync(String userId) async {
    return await _userCacheService.getUserDisplayNameAsync(userId);
  }

  /// Get user avatar URL from cache
  String getUserAvatarUrl(String userId) {
    return _userCacheService.getUserAvatarUrl(userId);
  }

  /// Get user avatar URL with API fallback
  Future<String> getUserAvatarUrlAsync(String userId) async {
    return await _userCacheService.getUserAvatarUrlAsync(userId);
  }

  /// Get user status from cache
  String getUserStatus(String userId) {
    return _userCacheService.getUserStatus(userId);
  }

  /// Get user status with API fallback
  Future<String> getUserStatusAsync(String userId) async {
    return await _userCacheService.getUserStatusAsync(userId);
  }

  /// Check if user exists in cache
  bool hasUserInCache(String userId) {
    return _userCacheService.hasUser(userId);
  }

  /// Preload multiple users
  Future<void> preloadUsers(List<String> userIds) async {
    await _userCacheService.preloadUsers(userIds);
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
