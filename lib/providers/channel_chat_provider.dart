import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../main.dart';
import '../model/channel_chat_model.dart' as msg;
import '../model/channel_members_model.dart';
import '../model/channel_pinned_message_model.dart';
import '../model/files_listing_in_channel_chat_model.dart';
import '../model/get_channel_info.dart';
import '../socket_io/socket_io.dart';
import '../utils/api_service/api_service.dart';
import '../utils/api_service/api_string_constants.dart';
import '../utils/common/common_function.dart';
import '../utils/common/common_widgets.dart';
import 'file_service_provider.dart';

class ChannelChatProvider extends ChangeNotifier{
  final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context, listen: false);
  GetChannelInfo? getChannelInfo;
  msg.ChannelChatModel? channelChatModel;
  ChannelPinnedMessageModel? channelPinnedMessageModel;
  List<MemberDetails> channelMembersList = [];
  FilesListingInChannelChatModel? filesListingInChannelChatModel;
  List<msg.MessageGroup> messageGroups = [];
  int currentPage = 1;
  int totalPages = 0;

  Future<void> pinUnPinMessage({required String receiverId,required String messageId,required bool pinned})async{
    final response = await ApiService.instance.request(endPoint: ApiString.pinMessage(messageId, pinned), method: Method.PUT);
    if(statusCode200Check(response)){
      for (var messageGroup in messageGroups) {
        for (var message in messageGroup.messages ?? []) {
          if (message.id == messageId) {
            message.isPinned = pinned;
            notifyListeners();
            break;
          }
        }
      }
      socketProvider.pinUnPinMessageEvent(senderId: signInModel.data?.user?.id ?? "", receiverId: receiverId,isEmitForChannel: true);
    }
  }


  Future<List<String>> uploadFiles() async {
    try {
      startLoading();
      List<PlatformFile> selectedFiles = FileServiceProvider.instance.selectedFiles;
      List<File> filesToUpload = selectedFiles.map((platformFile) {
        return File(platformFile.path!);
      }).toList();
      print("<<<<<<<<<<SUIIIII>>>>>>>>>>>");
      var request = http.MultipartRequest('POST', Uri.parse(ApiString.baseUrl + ApiString.uploadFileForMessageMedia));
      request.headers.addAll({
        'Authorization': "Bearer ${signInModel.data?.authToken}",
      });
      for (var file in filesToUpload) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            file.path,
            contentType: MediaType.parse(lookupMimeType(file.path) ?? 'application/octet-stream'),
          ),
        );
      }
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      if (response.statusCode == 200) {
        selectedFiles.clear();
        var jsonResponse = jsonDecode(responseData.body);
        if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
          List<String> filePaths = [];
          for (var item in jsonResponse['data']) {
            if (item['file_path'] != null) {
              filePaths.add(item['file_path']);
            }
          }
          print("filesPathRes>>>>> $filePaths");
          return filePaths;
        } else {
          throw Exception("Unexpected response structure");
        }
      } else {
        throw Exception('Failed to upload files: ${responseData.body}');
      }
    }catch (e){
      throw Exception("$e");
    }finally{
      stopLoading();
    }
  }
  Future<void> sendMessage({required dynamic content , required String channelId, List<String>? files,String? replyId , String? editMsgID,})async{
    final requestBody = {
      "content": content,
      "channelId": channelId,
    };

    if (replyId != null && replyId.isNotEmpty) {
      requestBody['isReply'] = true;
      requestBody['replyTo'] = replyId;
    }

    if (editMsgID != null && editMsgID.isNotEmpty) {
      requestBody["isEdit"] = true;
      requestBody["editMessageId"] = editMsgID;
    }

    if (files != null && files.isNotEmpty) {
      requestBody["files"] = files;
    }
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await ApiService.instance.request(endPoint: ApiString.sendChannelMessage, method: Method.POST,reqBody: requestBody);
    if(statusCode200Check(response)){
      socketProvider.sendMessagesSC(response: response['data'],emitReplyMsg: replyId != null ? true : false);
      if (editMsgID != null && editMsgID.isNotEmpty) {
        int editIndex = messageGroups.indexWhere((item) => item.messages!.any((msg) => msg.id == editMsgID));

        if (editIndex != -1) {
          msg.Message editedMessage = msg.Message.fromJson(response['data']);
          editedMessage.isEdited = true;
          messageGroups[editIndex].messages![messageGroups[editIndex].messages!.indexWhere((msg) => msg.id == editMsgID)] = editedMessage;
        }
      } else /*if(replyId == null && replyId == "")*/ {
        int existingIndex = messageGroups.indexWhere((item) => item.id == todayDate);
        if (existingIndex != -1) {
          messageGroups[existingIndex].messages!.add(msg.Message.fromJson(response['data']));
        } else {
          final newListOfDate = response['data'];
          messageGroups.add(msg.MessageGroup.fromJson({
            "_id": todayDate,
            'messages': [newListOfDate],
            "count": 1,
          }));
        }
      }
      if(replyId != null){
        // getMessagesList(oppositeUserId: receiverId);
        print("I'm In sendMessage");
        // getReplyMessageList(msgId: replyId,fromWhere: "SEND_REPLY_MESSAGE");
      }else {
        // getMessagesList(oppositeUserId: receiverId);
      }
    }
    notifyListeners();
  }

  // void pagination({required String channelId}) {
  //       currentPage++;
  //       getChannelChatApiCall(channelId: channelId,pageNo: currentPage);
  //   notifyListeners();
  // }
  void paginationAPICall({required String channelId}) {
    if(currentPage < totalPages) {
      currentPage++;
      notifyListeners();
      getChannelChatApiCall(channelId: channelId,pageNo: currentPage);
    }
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
   try{
     if (lastOpenedChannelId != channelId) {
       messageGroups.clear();
       totalPages = 0;
       currentPage = 1;
       isChannelChatLoading = true;
     }
     final requestBody = {
       "channelId": channelId,
       "pageNo": pageNo.toString()
     };
     if(pageNo == 1 && !isFromMsgListen){
       messageGroups.clear();
       currentPage = 1;
     }
     final response  = await ApiService.instance.request(endPoint: ApiString.getChannelChat, method: Method.POST,reqBody: requestBody);
     if(statusCode200Check(response)){
       if(isFromMsgListen){
         for (var newItem in (response['data']['messages'] as List).map((message) => msg.MessageGroup.fromJson(message)).toList()) {
           int existingIndex = messageGroups.indexWhere((item) => item.id == newItem.id);
           if (existingIndex != -1) {
             messageGroups[existingIndex] = newItem;
           } else {
             messageGroups.add(newItem);
           }
         }
       }else{
         messageGroups.addAll((response['data']['messages'] as List).map((message) => msg.MessageGroup.fromJson(message)).toList());
       }
     }
     totalPages = response['data']['totalPages'];
     lastOpenedChannelId = channelId;
   }catch (e){
     print("error >>> $e");
   }finally{
     isChannelChatLoading = false;
     notifyListeners();
   }
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
      final responseString = await response.stream.bytesToString();
      final responseData = json.decode(responseString);
      log("Response data: $responseData");
      Map<String, dynamic> passInSocket = {
        "data": {
          "senderId": signInModel.data!.user!.id,
          "receiverId": userIds,
          "channelId": channelId
        }
      };
      getChannelMembersList(channelId);
      socketProvider.addMemberToChannel(response: passInSocket);
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
        print("response = $response");
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
  // void addMessageToList(String messageId) {
  //   for (var messageGroup in messageGroups) {
  //     messageGroup.messages?.removeWhere((message) => message.id == messageId);
  //     if (messageGroup.messages?.isEmpty ?? true) {
  //       messageGroups.remove(messageGroup);
  //       break;
  //     }
  //   }
  //   notifyListeners();
  // }
}