
import 'package:bloc/bloc.dart';
import 'package:e_connect/cubit/common_cubit/common_cubit.dart';
import 'package:e_connect/model/browse_and_search_channel_model.dart';
import 'package:e_connect/model/channel_list_model.dart';
import 'package:e_connect/model/favorite_list_model.dart';
import 'package:e_connect/model/search_user_model.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../main.dart';
import '../../model/direct_message_list_model.dart';
import '../../model/get_users_suggestions.dart';

part 'channel_list_state.dart';

class ChannelListCubit extends Cubit<ChannelListState> {
  ChannelListCubit() : super(ChannelListInitial());

  final commonCubit = CommonCubit();

  FavoriteListModel? favoriteListModel;
  ChannelListModel? channelListModel;
  DirectMessageListModel? directMessageListModel;
  BrowseAndSearchChannelModel? browseAndSearchChannelModel;
  GetUserSuggestions? getUserSuggestions;
  SearchUserModel? searchUserModel;
  /// GET FAVORITE LIST IN HOME SCREEN ///
  Future<void> getFavoriteList()async{
    print("userID>>>> ${signInModel.data?.user?.id}");
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final requestBody = {
      "userId": signInModel.data?.user?.id,
    };
    final response = await ApiService.instance.request(endPoint: ApiString.favoriteListGet, method: Method.POST,headers: header,reqBody: requestBody);
    if(statusCode200Check(response)){
      favoriteListModel = FavoriteListModel.fromJson(response);
      emit(ChannelListInitial());
    }
  }
  /// GET CHANNEL LIST IN HOME SCREEN ///
  Future<void> getChannelList()async{
    print("userID>>>> ${signInModel.data?.user?.id}");
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final response = await ApiService.instance.request(endPoint: ApiString.channelList, method: Method.GET,headers: header);
    if(statusCode200Check(response)){
      channelListModel = ChannelListModel.fromJson(response);
      emit(ChannelListInitial());
    }
  }
  /// GET DIRECT MESSAGE IN HOME SCREEN ///
  Future<void> getDirectMessageList()async{
    print("userID>>>> ${signInModel.data?.user?.id}");
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final requestBody = {
      "userId": signInModel.data?.user?.id,
    };
    final response = await ApiService.instance.request(endPoint: ApiString.directMessageChatList, method: Method.POST,headers: header,reqBody: requestBody);
    if(statusCode200Check(response)){
      directMessageListModel = DirectMessageListModel.fromJson(response);
      emit(ChannelListInitial());
    }
  }
  /// CREATE A NRE CHANNEL ///
  Future<void> createNewChannelCall({
    required String channelName,
    required String description,
    String? isPrivateChannel,
})async{
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final requestBody = {
      "name": channelName,
      "isPrivate": isPrivateChannel,
      "description": description
    };
    final response = await ApiService.instance.request(endPoint: ApiString.createChannel, method: Method.POST,headers: header,reqBody: requestBody);
    if(statusCode200Check(response)){
      directMessageListModel = DirectMessageListModel.fromJson(response);
      emit(ChannelListInitial());
    }
  }
  /// BROWSE AND SEARCH ///
  Future<void> browseAndSearchChannel({
    required String search,
  }) async {
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final requestBody = {
      "userId": signInModel.data?.user?.id,
      "searchTerm": search.isEmpty ? "" : search,
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.browseChannel,
        method: Method.POST,
        headers: header,
        reqBody: requestBody);
    if (statusCode200Check(response)) {
      browseAndSearchChannelModel = BrowseAndSearchChannelModel.fromJson(response);
      emit(ChannelListInitial());
    }
  }

  Future<void> getUserSuggestionsListing() async {
    emit(ChannelListInitial());
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };

    final response = await ApiService.instance.request(
        endPoint: ApiString.userSuggestions,
        method: Method.GET,
        headers: header,);
    if (statusCode200Check(response)) {
      getUserSuggestions = GetUserSuggestions.fromJson(response);
      emit(ChannelListInitial());
    }
  }

  Future<void> searchUserByName({required String search}) async {
    emit(ChannelListInitial());
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final requestBody = {"searchTerm": search};

    final response = await ApiService.instance.request(
        endPoint: ApiString.searchUser,
        method: Method.POST,
        reqBody: requestBody,
        headers: header,);
    if (statusCode200Check(response)) {
      searchUserModel = SearchUserModel.fromJson(response);
      emit(ChannelListInitial());
    }
  }

  Future<void> removeFromFavorite({
    required String favouriteUserId,
  }) async {
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final requestBody = {
      "userId": signInModel.data?.user?.id,
      "favouriteUserId": favouriteUserId,
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.removeFromFavorite,
        method: Method.POST,
        headers: header,
        reqBody: requestBody);
    if (statusCode200Check(response)) {
      // browseAndSearchChannelModel = BrowseAndSearchChannelModel.fromJson(response);
      getFavoriteList();
      getChannelList();
      getDirectMessageList();
      emit(ChannelListInitial());
    }
  }

  Future<void> muteUser({
    required String userIdToMute,
    required bool isForMute,
  }) async {
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final requestBodyForMuteUser = {
       "userIdToMute": userIdToMute
    };
    final requestBodyForUnMuteUser = {
       "userIdToUnmute" : userIdToMute,
    };
    final response = await ApiService.instance.request(
        endPoint: isForMute == false ? ApiString.muteUser : ApiString.unMuteUser,
        method: Method.POST,
        headers: header,
        reqBody: isForMute == false ? requestBodyForMuteUser : requestBodyForUnMuteUser);
    if (statusCode200Check(response)) {
      // browseAndSearchChannelModel = BrowseAndSearchChannelModel.fromJson(response);
       getFavoriteList();
       getChannelList();
       getDirectMessageList();
       emit(ChannelListInitial());
       commonCubit.getUserByIDCall();
    }
  }
  Future<void> closeConversation({
    required String conversationUserId,
    required bool isCalledForFav,
  }) async {
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    print("userId>>>${signInModel.data?.user?.id}");
    final requestBodyForFav = {
      "userId": signInModel.data!.user!.id,
      "conversationUserId": conversationUserId,
      "fav": isCalledForFav
    };
    final requestBodyNonFav = {
      "userId": signInModel.data!.user!.id,
      "conversationUserId": conversationUserId,
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.closeConversation,
        method: Method.POST,
        headers: header,
        reqBody: isCalledForFav ? requestBodyForFav : requestBodyNonFav);
    if (statusCode200Check(response)) {
      await getFavoriteList();
      await getChannelList();
      await getDirectMessageList();
      emit(ChannelListInitial());
    }
  }

  Future<void> leaveChannel({
    required String channelId,
    required String channelName,
    required String channelDescription,
  }) async {
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    print("userId>>>${signInModel.data?.user?.id}");
    final requestBody = {
      "_id": channelId,
      "name": channelName,
      "description" : channelDescription,
      "ownerId": "",
      "isPrivate": true,
      "members": [],
      "isDeleted": false,
      "isDefault": false,
      "updatedBy": null,
      "deletedBy": null,
      "header_history": [],
      "createdAt": "2025-01-27T11:28:14.552Z",
      "updatedAt": "2025-01-31T11:16:43.172Z",
      "__v": 0
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.leaveChannel,
        method: Method.POST,
        headers: header,
        reqBody: requestBody);
    if (statusCode200Check(response)) {
      await getFavoriteList();
      await getChannelList();
      await getDirectMessageList();
      emit(ChannelListInitial());
    }
  }

  Future<void> readUnreadMessages({
    required String oppositeUserId,
    required bool isCalledForFav,
    required bool isCallForReadMessage
  }) async {
    print("isCallForReadMessage>>> $isCallForReadMessage");
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };

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
        headers: header,
        reqBody: requestBody);
    if (statusCode200Check(response)) {
      await getFavoriteList();
      await getChannelList();
      await getDirectMessageList();
      emit(ChannelListInitial());
    }
  }

  // Future<void> removeFavChannelFromList({
  //   https://e-connect.elsner.com/v1/favouriteLists/channel/remove/6752c01136682054c04e0874
  //   required String favouriteUserId,
  // }) async {
  //   final header = {
  //     'Authorization': "Bearer ${signInModel.data!.authToken}",
  //   };
  //   final requestBody = {
  //     "userId": signInModel.data?.user?.id,
  //     "favouriteUserId": favouriteUserId,
  //   };
  //   final response = await ApiService.instance.request(
  //       endPoint: ApiString.removeFromFavorite,
  //       method: Method.PUT,
  //       headers: header,
  //       reqBody: requestBody);
  //   if (statusCode200Check(response)) {
  //     // browseAndSearchChannelModel = BrowseAndSearchChannelModel.fromJson(response);
  //     emit(ChannelListInitial());
  //   }
  // }
Future<void> addUserToFavorite({
    required String favouriteUserId,
  }) async {
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final requestBody = {
      "userId": signInModel.data?.user?.id,
      "favouriteUserId": favouriteUserId,
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.addTOFavorite,
        method: Method.POST,
        headers: header,
        reqBody: requestBody);
    if (statusCode200Check(response)) {
          getFavoriteList();
          getChannelList();
          getDirectMessageList();
          emit(ChannelListInitial());
    }
  }
}
