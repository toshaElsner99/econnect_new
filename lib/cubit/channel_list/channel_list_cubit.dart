import 'package:bloc/bloc.dart';
import 'package:e_connect/model/browse_and_search_channel_model.dart';
import 'package:e_connect/model/channel_list_model.dart';
import 'package:e_connect/model/favorite_list_model.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../main.dart';
import '../../model/direct_message_list_model.dart';

part 'channel_list_state.dart';

class ChannelListCubit extends Cubit<ChannelListState> {
  ChannelListCubit() : super(ChannelListInitial());

  FavoriteListModel? favoriteListModel;
  ChannelListModel? channelListModel;
  DirectMessageListModel? directMessageListModel;
  BrowseAndSearchChannelModel? browseAndSearchChannelModel;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _headerController = TextEditingController();
  bool isPrivate = false;


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
}
