import 'dart:convert';
import 'dart:developer';

import 'package:e_connect/model/browse_and_search_channel_model.dart';
import 'package:e_connect/model/channel_chat_model.dart';
import 'package:e_connect/model/channel_list_model.dart';
import 'package:e_connect/model/favorite_list_model.dart';
import 'package:e_connect/model/search_user_model.dart';
import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../model/channel_members_model.dart';
import '../model/direct_message_list_model.dart';
import '../model/get_channel_info.dart';
import '../model/get_users_suggestions.dart';
import '../model/sign_in_model.dart';
import '../screens/bottom_nav_tabs/home_screen.dart';
import '../socket_io/socket_io.dart';
import 'common_provider.dart';
import 'package:http/http.dart'as http;



class ChannelListProvider extends ChangeNotifier{
  final commonProvider = Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false);
  final channelChatProvider = Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context,listen: false);
  final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context, listen: false);

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
      getChannelList();
    }
    notifyListeners();
  }

void combineUserDataWithChannels() {
 try{
   browseAndSearchChannelModel?.data?.users?.forEach((user) {
     combinedList.clear();
     combinedList.add({
       'type': 'user',
       'fullName': user.fullName,
       'username': user.username,
       'email': user.email,
       'avatarUrl': user.thumbnailAvatarUrl,
       'userId': user.userId
     });
   });

   browseAndSearchChannelModel?.data?.channels?.forEach((channel) {
     combinedList.add({
       'type': 'channel',
       'id': channel.sId,
       'name': channel.name,
       'isPrivate': channel.isPrivate,
     });
   });
   print("combinedList>>>> ${combinedList}");
 }catch (e){
   print("e>>> $e");
 }finally{
   notifyListeners();
 }
}

final searchController = TextEditingController();
clearList(){
  combinedList.clear();
  searchController.clear();
  notifyListeners();
}
var combinedList = [];
bool isLoading = false;

/// BROWSE AND SEARCH ///
  Future<void> browseAndSearchChannel({required String search,bool? needLoader = false,bool? combineList = false}) async {
    final requestBody = {
      "userId": signInModel.data?.user?.id,
      "searchTerm": search.isEmpty ? "" : search,
    };
    try{
      isLoading = true;
      final response = await ApiService.instance.request(endPoint: ApiString.browseChannel, method: Method.POST, reqBody: requestBody,needLoader: needLoader);
      if (statusCode200Check(response)) {
        browseAndSearchChannelModel = BrowseAndSearchChannelModel.fromJson(response);
        if(combineList == true){
          combineUserDataWithChannels();
        }
      }else if(response['data'] == []){
        combinedList.clear();
      }
    }catch (e){
      print("eroor>> $e");
    }finally {
      isLoading = false;
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
    bool? needToUpdateGetUserModel,
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
      getFavoriteList();
      getChannelList();
      getDirectMessageList();
      if(needToUpdateGetUserModel == true){
        commonProvider.getUserModelSecondUser?.data?.user?.isFavourite  = false;
        notifyListeners();
      }
    }
    notifyListeners();
  }

  Future<void> removeChannelFromFavorite({
    required String favoriteChannelID,
    Function? callOtherApi,
  }) async {
    final response = await ApiService.instance.request(
        endPoint: ApiString.removeFromChannelFromFavorite + favoriteChannelID,
        method: Method.PUT,);
    if (statusCode200Check(response)) {
      getFavoriteList();
      getChannelList();
      getDirectMessageList();
      callOtherApi?.call();
    }
    notifyListeners();
  }

  Future<void> muteUser({
    required String userIdToMute,
    required bool isForMute,
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
      Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false).getUserByIDCall();
      notifyListeners();
    }
  }
  Future<void> closeConversation({
    required String conversationUserId,
    required bool isCalledForFav,
  }) async {
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

  // Future<void> leaveChannel({
  //   required String channelId,
  // }) async {
  //   // emit(ChannelListInitial());
  //   // final header = {
  //   //   'Authorization': "Bearer ${signInModel.data!.authToken}",
  //   // };
  //   print("userId>>>${signInModel.data?.user?.id}");
  //   final response = await ApiService.instance.request(
  //       endPoint: ApiString.leaveChannel + channelId,
  //       method: Method.PUT);
  //   if (statusCode200Check(response)) {
  //     await getFavoriteList();
  //     await getChannelList();
  //     await getDirectMessageList();
  //     // emit(ChannelListInitial());
  //   }
  //   notifyListeners();
  // }

Future<void> leaveChannel({
  required String channelId,
  bool isFromMembersScreen = false,
}) async {
  print("userId>>>${signInModel.data?.user?.id}");
  final response = await ApiService.instance.request(
      endPoint: ApiString.leaveChannel + channelId,
      method: Method.PUT
  );

  if (statusCode200Check(response)) {
    if(isFromMembersScreen) {
      Navigator.pushAndRemoveUntil(
        navigatorKey.currentState!.context,
        MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false,);
    } else {
      await getChannelList();
      await getFavoriteList();
      await getDirectMessageList();
    }
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
        endPoint: isCallForReadMessage ? "${ApiString.readChannelMessage(oppositeUserId)}" : ApiString.unReadChannelMessage(oppositeUserId),
        method: isCallForReadMessage ? Method.GET : Method.PUT,);
    if (statusCode200Check(response)) {
      await getFavoriteList();
      await getChannelList();
      await getDirectMessageList();
    }
    notifyListeners();
  }


Future<void> addUserToFavorite({
    required String favouriteUserId,
    bool? needToUpdateGetUserModel,
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
            if(needToUpdateGetUserModel == true){
              commonProvider.getUserModelSecondUser?.data?.user?.isFavourite  = true;
              notifyListeners();
          }
    }
    notifyListeners();
  }
Future<void> addChannelToFavorite({
    required String channelId,
  Function? callOtherApi ,
  }) async {
    final response = await ApiService.instance.request(
        endPoint: ApiString.addChannelTOFavorite + channelId,
        method: Method.PUT,);
    if (statusCode200Check(response)) {
          getFavoriteList();
          getChannelList();
          getDirectMessageList();
          callOtherApi?.call();
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

/// TOGGLE ADMIN AND MEMBER STATUS ///
Future<void> toggleAdminAndMember(
    {required String channelId, required String userId}) async {
  var headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${signInModel.data!.authToken}',
  };

  var request = http.Request(
      'PUT',
      Uri.parse(
          ApiString.baseUrl + ApiString.toggleAdminAndMember(channelId)));
  request.body = json.encode({"memberId": userId});
  log(
      "URL = ${ApiString.baseUrl + ApiString.toggleAdminAndMember(channelId)}");
  log("memberId: $userId");
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  print("response =${response.statusCode}");
  if (response.statusCode == 200) {
    await Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context,listen: false).getChannelMembersList(channelId);
    socketProvider.memberAdminToggleSC(response: {
      "data": {
        "senderId": signInModel.data!.user!.id,
        "channelId": channelId
      }
    });
  } else {
    print(response.reasonPhrase);
  }
}

/// REMOVE MEMBER FROM CHANNEL ///
Future<void> removeMember(
    {required String channelId, required String userId}) async {
  var headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${signInModel.data!.authToken}',
  };

  var request = http.Request(
      'PUT',
      Uri.parse(
          ApiString.baseUrl + ApiString.removeMember(channelId, userId)));
  log(
      "URL = ${ApiString.baseUrl + ApiString.removeMember(channelId, userId)}");
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  log("response status code =${response.statusCode}");
  
  if (response.statusCode == 200) {
    final responseString = await response.stream.bytesToString();
    final responseData = json.decode(responseString);
    log("Response data: $responseData");
    List<String> memberIds = [];
    // Extract and print member IDs
    if (responseData['data'] != null && responseData['data']['members'] != null) {
      final members = responseData['data']['members'] as List;
      memberIds = members.map((member) => member['id'].toString()).toList();
      log("Member IDs: $memberIds");
    }
    
    await channelChatProvider.getChannelMembersList(channelId);
    await channelChatProvider.getChannelInfoApiCall(callFroHome: false,channelId: channelId);
    await channelChatProvider.getChannelChatApiCall(channelId: channelId,pageNo: 1);
    socketProvider.memberRemoveSC(response: {
      "senderId": signInModel.data!.user!.id,
      "removeduser": userId,
      "receiverId": memberIds,
      "channelId": channelId});
  } else {
    print(response.reasonPhrase);
  }
}

/// RENAME CHANNEL ///
Future<void> renameChannel({
  required String channelId,
  required String name,
  required bool isPrivate,
  String description = "",
}) async {
  var headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${signInModel.data!.authToken}',
  };

  var request = http.Request(
      'PUT',
      Uri.parse(ApiString.baseUrl + ApiString.renameChannel(channelId))
  );
  request.body = json.encode({
    "name": name,
    "isPrivate": isPrivate,
    "description": description
  });
  print("URL = ${ApiString.baseUrl + ApiString.renameChannel(channelId)}");
  print("Request Body: ${request.body}");
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  print("response =${response.statusCode}");
  if (response.statusCode == 200) {
    channelChatProvider.getChannelInfo?.data?.name = name;
    channelChatProvider.getChannelChatApiCall(channelId: channelId, pageNo: 1);
    notifyListeners();
    await getChannelList();
  } else {
    print(response.reasonPhrase);
  }
}


}
