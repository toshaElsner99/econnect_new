import 'package:e_connect/model/browse_and_search_channel_model.dart';
import 'package:e_connect/model/channel_list_model.dart';
import 'package:e_connect/model/favorite_list_model.dart';
import 'package:e_connect/model/search_user_model.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../model/direct_message_list_model.dart';
import '../model/get_users_suggestions.dart';
import '../model/sign_in_model.dart';
import 'common_provider.dart';



class ChannelListProvider extends ChangeNotifier{
final commonCubit = Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false);
  FavoriteListModel? favoriteListModel;
  ChannelListModel? channelListModel;
  DirectMessageListModel? directMessageListModel;
  BrowseAndSearchChannelModel? browseAndSearchChannelModel;
  GetUserSuggestions? getUserSuggestions;
  SearchUserModel? searchUserModel;

  /// GET FAVORITE LIST IN HOME SCREEN ///
  Future<void> getFavoriteList()async{
    print("userID>>>> ${signInModel.data?.user?.id}");
    // final header = {
    //   'Authorization': "Bearer ${signInModel.data!.authToken}",
    // };
    final requestBody = {
      "userId": signInModel.data?.user?.id,
    };
    final response = await ApiService.instance.request(endPoint: ApiString.favoriteListGet, method: Method.POST,reqBody: requestBody);
    if(statusCode200Check(response)){
      favoriteListModel = FavoriteListModel.fromJson(response);
    }
    notifyListeners();
  }
  /// GET CHANNEL LIST IN HOME SCREEN ///
  Future<void> getChannelList()async{
    print("userID>>>> ${signInModel.data?.user?.id}");
    final response = await ApiService.instance.request(endPoint: ApiString.channelList, method: Method.GET,);
    if(statusCode200Check(response)){
      channelListModel = ChannelListModel.fromJson(response);
    }
    notifyListeners();
  }
  /// GET DIRECT MESSAGE IN HOME SCREEN ///
  Future<void> getDirectMessageList()async{
    print("userID>>>> ${signInModel.data?.user?.id}");
    final requestBody = {
      "userId": signInModel.data?.user?.id,
    };
    final response = await ApiService.instance.request(endPoint: ApiString.directMessageChatList, method: Method.POST,reqBody: requestBody);
    if(statusCode200Check(response)){
      directMessageListModel = DirectMessageListModel.fromJson(response);
      // emit(ChannelListInitial());
    }
    notifyListeners();
  }
  /// CREATE A NRE CHANNEL ///
  Future<void> createNewChannelCall({
    required String channelName,
    required String description,
    String? isPrivateChannel,
})async{
    final requestBody = {
      "name": channelName,
      "isPrivate": isPrivateChannel,
      "description": description
    };
    final response = await ApiService.instance.request(endPoint: ApiString.createChannel, method: Method.POST,reqBody: requestBody);
    if(statusCode200Check(response)){
      pop();
      directMessageListModel = DirectMessageListModel.fromJson(response);
      // emit(ChannelListInitial());
    }
    notifyListeners();
  }
  /// BROWSE AND SEARCH ///
  Future<void> browseAndSearchChannel({required String search,bool? needLoader = false}) async {
    final requestBody = {
      "userId": signInModel.data?.user?.id,
      "searchTerm": search.isEmpty ? "" : search,
    };
    try{
      final response = await ApiService.instance.request(endPoint: ApiString.browseChannel, method: Method.POST, reqBody: requestBody,needLoader: needLoader);
      if (statusCode200Check(response)) {
        browseAndSearchChannelModel = BrowseAndSearchChannelModel.fromJson(response);
      }
    }catch (e){
      print("eroor>> $e");
    }finally {
      notifyListeners();
    }
  }

  Future<void> getUserSuggestionsListing() async {
    final response = await ApiService.instance.request(
        endPoint: ApiString.userSuggestions,
        method: Method.GET,);
    if (statusCode200Check(response)) {
      getUserSuggestions = GetUserSuggestions.fromJson(response);
    }
    notifyListeners();
  }

  Future<void> searchUserByName({required String search}) async {
    final requestBody = {"searchTerm": search};
    final response = await ApiService.instance.request(
        endPoint: ApiString.searchUser,
        method: Method.POST,
        reqBody: requestBody,);
    if (statusCode200Check(response)) {
      searchUserModel = SearchUserModel.fromJson(response);
      // emit(ChannelListInitial());
    }
    notifyListeners();
  }

  Future<void> removeFromFavorite({
    required String favouriteUserId,
  }) async {
    final requestBody = {
      "userId": signInModel.data?.user?.id,
      "favouriteUserId": favouriteUserId,
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.removeFromFavorite,
        method: Method.POST,
        reqBody: requestBody);
    if (statusCode200Check(response)) {
      // browseAndSearchChannelModel = BrowseAndSearchChannelModel.fromJson(response);
      getFavoriteList();
      getChannelList();
      getDirectMessageList();
      // emit(ChannelListInitial());
    }
    notifyListeners();
  }

  Future<void> removeChannelFromFavorite({
    required String favoriteChannelID,
  }) async {
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.removeFromChannelFromFavorite + favoriteChannelID,
        method: Method.PUT,);
    if (statusCode200Check(response)) {
      getFavoriteList();
      getChannelList();
      getDirectMessageList();
    }
    notifyListeners();
  }

  Future<void> muteUser({
    required String userIdToMute,
    required bool isForMute,
    bool? needToCallGetUser = false,
  }) async {
    final requestBodyForMuteUser = {
       "userIdToMute": userIdToMute
    };
    final requestBodyForUnMuteUser = {
       "userIdToUnmute" : userIdToMute,
    };
    final response = await ApiService.instance.request(
        endPoint: isForMute == false ? ApiString.muteUser : ApiString.unMuteUser,
        method: Method.POST,
        reqBody: isForMute == false ? requestBodyForMuteUser : requestBodyForUnMuteUser);
    if (statusCode200Check(response)) {
      getFavoriteList();
      getChannelList();
      getDirectMessageList();
      if(needToCallGetUser==true){
        Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false).getUserByIDCall();
      }
      notifyListeners();
    }
  }
  Future<void> closeConversation({
    required String conversationUserId,
    required bool isCalledForFav,
  }) async {
    // final header = {
    //   'Content-Type': 'application/json',
    // };
    print("userId>>>${signInModel.data?.user?.id}");
    final requestBodyForFav = {
      "userId": signInModel.data!.user!.id,
      "conversationUserId": conversationUserId,
      "fav": true
    };
    final requestBodyNonFav = {
      "userId": signInModel.data!.user!.id,
      "conversationUserId": conversationUserId,
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.closeConversation,
        method: Method.POST,
        reqBody: isCalledForFav ? requestBodyForFav : requestBodyNonFav);
    if (statusCode200Check(response)) {
      await getFavoriteList();
      await getChannelList();
      await getDirectMessageList();
    }
    notifyListeners();
  }

  Future<void> leaveChannel({
    required String channelId,
  }) async {
    // emit(ChannelListInitial());
    // final header = {
    //   'Authorization': "Bearer ${signInModel.data!.authToken}",
    // };
    print("userId>>>${signInModel.data?.user?.id}");
    final response = await ApiService.instance.request(
        endPoint: ApiString.leaveChannel + channelId,
        method: Method.PUT);
    if (statusCode200Check(response)) {
      await getFavoriteList();
      await getChannelList();
      await getDirectMessageList();
      // emit(ChannelListInitial());
    }
    notifyListeners();
  }

  Future<void> readUnreadMessages({
    required String oppositeUserId,
    required bool isCalledForFav,
    required bool isCallForReadMessage
  }) async {
    // emit(ChannelListInitial());
    print("isCallForReadMessage>>> $isCallForReadMessage");
    // final header = {
    //   'Authorization': "Bearer ${signInModel.data!.authToken}",
    // };

    final requestBody = {
      "acknowledged": true,
      "modifiedCount": 1,
      "upsertedId": null,
      "upsertedCount" : 0,
      "matchedCount": 1,
    };
    final response = await ApiService.instance.request(
        endPoint: isCallForReadMessage ? "${ApiString.messageSeen}$oppositeUserId/chat" : ApiString.messageUnread + oppositeUserId,
        method: Method.PUT,
        reqBody: requestBody);
    if (statusCode200Check(response)) {
      await getFavoriteList();
      await getChannelList();
      await getDirectMessageList();
      // emit(ChannelListInitial());
    }
    notifyListeners();
  }

  Future<void> readUnReadChannelMessage({
    required String oppositeUserId,
    required bool isCallForReadMessage
  }) async {
    print("isCallForReadMessage>>> $isCallForReadMessage");
    final response = await ApiService.instance.request(
        endPoint: isCallForReadMessage ? "${ApiString.readChannelMessage}$oppositeUserId" : ApiString.unReadChannelMessage + oppositeUserId,
        method: isCallForReadMessage ? Method.GET : Method.PUT,

       );
    if (statusCode200Check(response)) {
      await getFavoriteList();
      await getChannelList();
      await getDirectMessageList();
    }
    notifyListeners();
  }


Future<void> addUserToFavorite({
    required String favouriteUserId,
  }) async {
    final requestBody = {
      "userId": signInModel.data?.user?.id,
      "favouriteUserId": favouriteUserId,
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.addTOFavorite,
        method: Method.POST,
                reqBody: requestBody);
    if (statusCode200Check(response)) {
          getFavoriteList();
          getChannelList();
          getDirectMessageList();
    }
    notifyListeners();
  }
Future<void> addChannelToFavorite({
    required String channelId,
  }) async {
    final response = await ApiService.instance.request(
        endPoint: ApiString.addChannelTOFavorite + channelId,
        method: Method.PUT,);
    if (statusCode200Check(response)) {
          getFavoriteList();
          getChannelList();
          getDirectMessageList();
    }
    notifyListeners();
  }

  Future<void> muteUnMuteChannels({
    required String channelId,
    required bool isMutedChannel
  }) async {
    final unMuteBody = {"channelIdToUnmute": channelId};
    final muteBody = {"channelIdToMute": channelId};
    final response = await ApiService.instance.request(
        endPoint: isMutedChannel ? ApiString.unMuteChannel : ApiString.muteChannel,
        method: Method.POST,
        reqBody: isMutedChannel ? unMuteBody : muteBody,
        );
    if (statusCode200Check(response)) {
        if (isMutedChannel) {
          signInModel.data?.user?.muteChannels?.remove(channelId);
        } else {
          signInModel.data?.user?.muteChannels?.add(channelId);
        }
          signInModel.saveToPrefs();
          await SignInModel.loadFromPrefs();
          getFavoriteList();
          getChannelList();
          getDirectMessageList();
    }
    notifyListeners();
  }

  Future<void> addUserToChatList({required String selectedUserId}) async {
    final requestBody ={"userId": signInModel.data?.user?.id, "selectedUserId": selectedUserId};
    final response = await ApiService.instance.request(
      endPoint: ApiString.addUserToChatList,
      method: Method.POST,
      reqBody: requestBody,
      );
  }
}
