import 'dart:convert';
import 'dart:developer';
import 'dart:math' show min;

import 'package:e_connect/model/browse_and_search_channel_model.dart';
import 'package:e_connect/model/channel_chat_model.dart';
import 'package:e_connect/model/channel_list_model.dart';
import 'package:e_connect/model/favorite_list_model.dart';
import 'package:e_connect/model/search_user_model.dart';
import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/screens/channel/channel_chat_screen.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
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
import '../notificationServices/pushNotificationService.dart';



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
  
  // New property for combined list
  List<Map<String, dynamic>> combinedAllItems = [];

  /// GET FAVORITE LIST IN HOME SCREEN ///
  Future<void> getFavoriteList()async{
    print("userID>>>> ${signInModel.data?.user?.id}");
    final requestBody = {
      "userId": signInModel.data?.user?.id,
    };
    final response = await ApiService.instance.request(endPoint: ApiString.favoriteListGet, method: Method.POST,reqBody: requestBody);
    if(statusCode200Check(response)){
      favoriteListModel = FavoriteListModel.fromJson(response);
    }
    NotificationService.setBadgeCount();
    combineAllLists(); // Add this call to combine lists
    notifyListeners();
  }
  /// GET CHANNEL LIST IN HOME SCREEN ///
  Future<void> getChannelList()async{
    print("userID>>>> ${signInModel.data?.user?.id}");
    final response = await ApiService.instance.request(endPoint: ApiString.channelList, method: Method.GET,);
    if(statusCode200Check(response)){
      channelListModel = ChannelListModel.fromJson(response);
      
      // Debug channel data to verify lastmessage timestamps
      print("=== Channel List Debug ===");
      if (channelListModel?.data != null) {
        for (var channel in channelListModel!.data!) {
          print("Channel: ${channel.name}");
          print("  - lastmessage: ${channel.lastmessage != null ? 'exists' : 'null'}");
          if (channel.lastmessage != null) {
            print("  - lastmessage.createdAt: ${channel.lastmessage!.createdAt}");
          }
          print("  - updatedAt: ${channel.updatedAt}");
          print("  - createdAt: ${channel.createdAt}");
          print("  - unreadCount: ${channel.unreadCount}");
          print("---------------------");
        }
      }
    }
    NotificationService.setBadgeCount();
    combineAllLists(); // Add this call to combine lists
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
    NotificationService.setBadgeCount();
    combineAllLists(); // Add this call to combine lists
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
      pushScreen(screen: ChannelChatScreen(channelId: response["data"]["_id"]));
      getChannelList();
    }else if(response['statusCode'] == 403) {
        commonShowToast("Channel Name is already used",Colors.red);
    }
    notifyListeners();
  }

void combineUserDataWithChannels() {
 try{
   // Clear the list once before adding items
   combinedList.clear();
   
   // Add all users to the combined list
   browseAndSearchChannelModel?.data?.users?.forEach((user) {
     combinedList.add({
       'type': 'user',
       'fullName': user.fullName,
       'username': user.username,
       'email': user.email,
       'avatarUrl': user.thumbnailAvatarUrl,
       'userId': user.userId
     });
   });

   // Add all channels to the combined list
   browseAndSearchChannelModel?.data?.channels?.forEach((channel) {
     combinedList.add({
       'type': 'channel',
       'id': channel.sId,
       'name': channel.name,
       'isPrivate': channel.isPrivate,
     });
   });
   print("combinedList>>>> ${combinedList.length} items found");
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
      await NotificationService.setBadgeCount();
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
      await NotificationService.setBadgeCount();
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
  print(
      "URL = ${ApiString.baseUrl + ApiString.toggleAdminAndMember(channelId)}");
  print("memberId: $userId");
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
  print(
      "URL = ${ApiString.baseUrl + ApiString.removeMember(channelId, userId)}");
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  print("response status code =${response.statusCode}");
  
  if (response.statusCode == 200) {
    final responseString = await response.stream.bytesToString();
    final responseData = json.decode(responseString);
    print("Response data: $responseData");
    List<String> memberIds = [];
    // Extract and print member IDs
    if (responseData['data'] != null && responseData['data']['members'] != null) {
      final members = responseData['data']['members'] as List;
      memberIds = members.map((member) => member['id'].toString()).toList();
      print("Member IDs: $memberIds");
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

/// COMBINE ALL LISTS INTO ONE LIST FOR ALL TAB ///
void combineAllLists() {
  combinedAllItems.clear();
  
  // Add favorite users
  if (favoriteListModel?.data?.chatList != null) {
    for (var item in favoriteListModel!.data!.chatList!) {
      // Get the most recent message timestamp for favorite users
      String timestamp = '';
      if (item.latestMessageCreatedAt != null && item.latestMessageCreatedAt!.isNotEmpty) {
        timestamp = item.latestMessageCreatedAt!;
        print("Favorite User ${item.username}: Using latestMessageCreatedAt: $timestamp");
      } else {
        timestamp = item.updatedAt ?? item.lastActiveTime ?? item.createdAt ?? '';
        print("Favorite User ${item.username}: No latestMessageCreatedAt, using: $timestamp");
      }
      
      combinedAllItems.add({
        'type': 'favoriteUser',
        'data': item,
        'unreadCount': item.unseenMessagesCount ?? 0,
        'timestamp': timestamp
      });
    }
  }
  
  // Add favorite channels
  if (favoriteListModel?.data?.favouriteChannels != null) {
    for (var item in favoriteListModel!.data!.favouriteChannels!) {
      // Use lastMessage for favorite channels if available
      String timestamp = '';
      if (item.lastMessage != null && item.lastMessage!.isNotEmpty) {
        timestamp = item.lastMessage!;
        print("Favorite Channel ${item.name}: Using lastMessage: $timestamp");
      } else {
        timestamp = item.updatedAt ?? item.createdAt ?? '';
        print("Favorite Channel ${item.name}: No lastMessage, using: $timestamp");
      }
      
      combinedAllItems.add({
        'type': 'favoriteChannel',
        'data': item,
        'unreadCount': item.unseenMessagesCount ?? 0,
        'timestamp': timestamp
      });
    }
  }
  
  // Add channels
  if (channelListModel?.data != null) {
    for (var item in channelListModel!.data!) {
      // Check if channel is already in favorites
      bool alreadyInFavorites = favoriteListModel?.data?.favouriteChannels
          ?.any((favChannel) => favChannel.sId == item.sId) ?? false;
      
      if (!alreadyInFavorites) {
        // Always prioritize lastmessage.createdAt as it's the best indicator of recent activity
        String timestamp = '';
        if (item.lastmessage?.createdAt != null && item.lastmessage!.createdAt!.isNotEmpty) {
          timestamp = item.lastmessage!.createdAt!;
          print("Channel ${item.name}: Using lastmessage timestamp: $timestamp");
        } else {
          timestamp = item.updatedAt ?? item.createdAt ?? '';
          print("Channel ${item.name}: No lastmessage, using: $timestamp");
        }
        
        combinedAllItems.add({
          'type': 'channel',
          'data': item,
          'unreadCount': item.unreadCount ?? 0,
          'timestamp': timestamp
        });
      }
    }
  }
  
  // Add direct messages
  if (directMessageListModel?.data?.chatList != null) {
    for (var item in directMessageListModel!.data!.chatList!) {
      // Check if user is already in favorites
      bool alreadyInFavorites = favoriteListModel?.data?.chatList
          ?.any((favUser) => favUser.sId == item.sId) ?? false;
      
      if (!alreadyInFavorites) {
        // For direct messages, prioritize latestMessageCreatedAt if available
        String timestamp = '';
        if (item.latestMessageCreatedAt != null && item.latestMessageCreatedAt!.isNotEmpty) {
          timestamp = item.latestMessageCreatedAt!;
          print("DM ${item.username}: Using latestMessageCreatedAt: $timestamp");
        } else {
          timestamp = item.updatedAt ?? item.lastActiveTime ?? item.createdAt ?? '';
          print("DM ${item.username}: No latestMessageCreatedAt, using: $timestamp");
        }
        
        combinedAllItems.add({
          'type': 'directMessage',
          'data': item,
          'unreadCount': item.unseenMessagesCount ?? 0,
          'timestamp': timestamp
        });
      }
    }
  }
  
  // Sort purely by timestamp in descending order (newest first)
  combinedAllItems.sort((a, b) {
    String timestampA = a['timestamp'] as String;
    String timestampB = b['timestamp'] as String;
    
    // Handle empty timestamps by treating them as oldest
    if (timestampA.isEmpty) return 1;
    if (timestampB.isEmpty) return -1;
    
    // For debugging
    print("Comparing timestamps - Item A: ${a['type']} - ${a['timestamp']}");
    print("Comparing timestamps - Item B: ${b['type']} - ${b['timestamp']}");
    
    // Compare timestamps - most recent first
    return timestampB.compareTo(timestampA);
  });
  
  // Debug the final order
  for (int i = 0; i < min(5, combinedAllItems.length); i++) {
    var item = combinedAllItems[i];
    String name = '';
    if (item['type'] == 'channel' || item['type'] == 'favoriteChannel') {
      name = item['data'].name ?? 'Unknown channel';
    } else {
      name = item['data'].username ?? 'Unknown user';
    }
    print("Final order #$i: $name - ${item['timestamp']}");
  }
  
  notifyListeners();
}

// Call this method after refreshes or app start
Future<void> refreshAllLists() async {
  print("Refreshing all lists...");
  await getFavoriteList();
  await getChannelList();
  await getDirectMessageList();
  
  // Make sure to combine lists explicitly after all are fetched
  combineAllLists();
  print("All lists refreshed and combined.");
}

}
