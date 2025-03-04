import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../main.dart';
import '../model/channel_chat_model.dart';
import '../model/channel_members_model.dart';
import '../model/channel_pinned_message_model.dart';
import '../model/files_listing_in_channel_chat_model.dart';
import '../model/get_channel_info.dart';
import '../socket_io/socket_io.dart';
import '../utils/api_service/api_service.dart';
import '../utils/api_service/api_string_constants.dart';
import '../utils/common/common_function.dart';

class ChannelChatProvider extends ChangeNotifier{
  GetChannelInfo? getChannelInfo;
  ChannelChatModel? channelChatModel;
  ChannelPinnedMessageModel? channelPinnedMessageModel;
  List<MemberDetails> channelMembersList = [];
  FilesListingInChannelChatModel? filesListingInChannelChatModel;
  List<MessageGroup> messageGroups = [];
  int currentPage = 1;
  int totalPages = 0;
  final ScrollController scrollController = ScrollController();
  final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context, listen: false);

  void pagination({required String channelId}) {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && currentPage < totalPages) {
        currentPage++;
        print("oppositeUserId in pagination==> $channelId");
        getChannelChatApiCall(channelId: channelId,pageNo: currentPage);
        print('currentPage:--->$currentPage');
      }
    });
    notifyListeners();
  }

  Future<void> getChannelPinnedMessage({required String channelID})async{
    final requestBody = {"channelId": channelID};
    final response = await ApiService.instance.request(endPoint: ApiString.getChannelPinnedMessage, method: Method.POST,reqBody: requestBody,needLoader: true);
    if(statusCode200Check(response)){
      channelPinnedMessageModel = ChannelPinnedMessageModel.fromJson(response);
      notifyListeners();
    }
  }

  Future<void> getChannelChatApiCall({required String channelId,required int pageNo,bool isFromMsgListen = false})async {
    // if (lastOpenedChannelId != lastOpenedChannelId) {
    //   channelChatModel = null;
    //   channelChatModel?.data.messages.clear();
    //   isChannelChatLoading = true;
    //   // messageGroups.clear();
    //   // totalPages = 0;
    //   // currentPage = 1;
    //   // idChatListLoading = true;
    // }
    final requestBody = {
      "channelId": channelId,
      "pageNo": pageNo.toString()
    };
    if(pageNo == 1 && !isFromMsgListen){
      messageGroups.clear();
      currentPage = 1;
    }
    final response  = await ApiService.instance.request(endPoint: ApiString.getChannelChat, method: Method.POST,reqBody: requestBody);
    // if(statusCode200Check(response)){
    //   // channelChatModel = ChannelChatModel.fromJson(response);
    //   messageGroups.addAll((response['data']['messages'] as List).map((message) => MessageGroup.fromJson(message)).toList());
    //   // lastOpenedChannelId = lastOpenedChannelId;
    //   isChannelChatLoading = false;
    // }else{
    //   isChannelChatLoading = false;
    // }
    if(isFromMsgListen){
      for (var newItem in (response['data']['messages'] as List).map((message) => MessageGroup.fromJson(message)).toList()) {
        int existingIndex = messageGroups.indexWhere((item) => item.id == newItem.id);

        if (existingIndex != -1) {
          // Replace existing data
          messageGroups[existingIndex] = newItem;
        } else {
          // Add new data if not found
          messageGroups.add(newItem);
        }
      }
    }else{
        messageGroups.addAll((response['data']['messages'] as List).map((message) => MessageGroup.fromJson(message)).toList());
    }
    totalPages = response['data']['totalPages'];
    notifyListeners();
  }

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

  Future<void> getFileListingInChannelChat({required String channelId})async{
    final requestBody = {"channelId": channelId};
    final response = await ApiService.instance.request(endPoint: ApiString.getFilesListingInChannelChat, method: Method.POST,reqBody: requestBody);
    if(statusCode200Check(response)){
      filesListingInChannelChatModel = FilesListingInChannelChatModel.fromJson(response);
    }
    notifyListeners();
  }

  // Delete Message from Channel
  Future<void> deleteMessageFromChannel({
    required String messageId
  }) async {

    try {
      final response = await ApiService.instance.request(
          endPoint: ApiString.deleteMessageFromChannel(messageId),
          method: Method.DELETE
      );
      if (statusCode200Check(response)) {
        print("Message Deleted");
        removeMessageFromList(messageId);
        socketProvider.deleteMessagesFromChannelSC(response: {"data": response['data']});
      }else{
        print("Message Not Deleted");
        print("response = ${response}");
      }
    } on Exception catch (e) {
      // TODO
      print("catch = ${e.toString()}");
    }
  }

  void removeMessageFromList(String messageId) {
    for (var messageGroup in messageGroups) {
      messageGroup.messages?.removeWhere((message) => message.id == messageId);
      if (messageGroup.messages?.isEmpty ?? true) {
        messageGroups.remove(messageGroup);
        break;
      }
    }
    notifyListeners();
  }
}