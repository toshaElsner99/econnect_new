import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../model/channel_chat_model.dart';
import '../model/channel_members_model.dart';
import '../model/files_listing_in_channel_chat_model.dart';
import '../model/get_channel_info.dart';
import '../utils/api_service/api_service.dart';
import '../utils/api_service/api_string_constants.dart';
import '../utils/common/common_function.dart';

class ChannelChatProvider extends ChangeNotifier{
  GetChannelInfo? getChannelInfo;
  ChannelChatModel? channelChatModel;
  List<MemberDetails> channelMembersList = [];
  FilesListingInChannelChatModel? filesListingInChannelChatModel;

  MemberDetails? getUserById(String userId) {
    try {
      return channelMembersList.firstWhere((member) => member.sId == userId);
    } catch (e) {
      return null;
    }
  }
  /// GET Channel Members List ///
  Future<void> getChannelMembersList(String channelId) async {
    print("channelId>>>> $channelId");
    final response = await ApiService.instance.request(endPoint: ApiString.getChannelMembersList(channelId), method: Method.GET);
    if (statusCode200Check(response)) {
      channelMembersList = (response['data']['memberDetails'] as List).map((list) => MemberDetails.fromJson(list as Map<String, dynamic>)).toList();
    }
    notifyListeners();
  }

  /// ADD MEMBER TO CHANNEL ///
  Future<void> addMembersToChannel({
    required String channelId,
    required List<String> userIds,
  }) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${signInModel.data!.authToken}',
    };
    var request = http.Request('PUT', Uri.parse(ApiString.baseUrl + ApiString.addMembersToChannel(channelId)));
    request.body = json.encode({
      "members": userIds
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      getChannelMembersList(channelId);
    }
    else {
      print(response.reasonPhrase);
    }}

  Future<void> getChannelInfoApiCall({required String channelId})async{
    final response  = await ApiService.instance.request(endPoint: ApiString.getChannelInfo(channelId), method: Method.GET,);
    if(statusCode200Check(response)){
      getChannelInfo = GetChannelInfo.fromJson(response);
      notifyListeners();
    }
  }
  String? lastOpenedChannelId;
  bool isChannelChatLoading = false;

  Future<void> getChannelChatApiCall({required String channelId})async {

    if (lastOpenedChannelId != lastOpenedChannelId) {
      channelChatModel = null;
      channelChatModel?.data.messages.clear();
      isChannelChatLoading = true;
      // messageGroups.clear();
      // totalPages = 0;
      // currentPage = 1;
      // idChatListLoading = true;
    }
    final requestBody = {
      "channelId": channelId,
      "pageNo": "1"
    };
    final response  = await ApiService.instance.request(endPoint: ApiString.getChannelChat, method: Method.POST,reqBody: requestBody);
    if(statusCode200Check(response)){
      channelChatModel = ChannelChatModel.fromJson(response);
      lastOpenedChannelId = lastOpenedChannelId;
      isChannelChatLoading = false;
    }else{
      isChannelChatLoading = false;
    }
    notifyListeners();
  }
  Future<void> getFileListingInChannelChat({required String channelId})async{
    final requestBody = {"channelId": channelId};
    final response = await ApiService.instance.request(endPoint: ApiString.getFilesListingInChannelChat, method: Method.POST,reqBody: requestBody);
    if(statusCode200Check(response)){
      filesListingInChannelChatModel = FilesListingInChannelChatModel.fromJson(response);
    }
    notifyListeners();
  }
}