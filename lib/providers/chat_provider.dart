import 'dart:convert';
import 'dart:io';

import 'package:e_connect/socket_io/socket_io.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../model/files_listening_in_chat_model.dart';
import '../model/get_reply_message_model.dart';
import '../model/message_model.dart' as msg;
import 'file_service_provider.dart';
import '../utils/api_service/api_service.dart';
import '../utils/api_service/api_string_constants.dart';
import '../utils/common/common_function.dart';
import 'package:http/http.dart' as http;



class ChatProvider extends  ChangeNotifier {
  final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context, listen: false);
  List<msg.MessageGroups> messageGroups = [];
  String? lastOpenedUserId;
  String? lastOpenedUserMSGId;
  String oppUserIdForTyping = "";
  int msgLength = 0;
  bool idChatListLoading = false;
  final ScrollController scrollController = ScrollController();
  int currentPagea = 1;
  int totalPages = 0;
  GetReplyMessageModel? getReplyMessageModel;
  FilesListingInChatModel? filesListingInChatModel;
  bool isGettingListFalse = false;

  void pagination({required String oppositeUserId}) {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && currentPagea < totalPages) {
        currentPagea++;
        print("oppositeUserId in pagination==> $oppositeUserId");
        getMessagesList(oppositeUserId: oppositeUserId,currentPage: currentPagea);
        print('currentPage:--->$currentPagea');
      }
    });
    notifyListeners();
  }
  Future<void> getMessagesList({required String oppositeUserId,required int currentPage,bool isFromMsgListen = false}) async {
    print("oppositeUserId in getMessagesList==> $oppositeUserId");

    try {
      if (lastOpenedUserId != oppositeUserId) {
        messageGroups.clear();
        totalPages = 0;
        currentPage = 1;
        currentPagea = 1;
        idChatListLoading = true;
        print("List Length ${messageGroups.length}");
      }
      print("Current Page ==> $currentPage");
      if(currentPage == 1 && !isFromMsgListen){
        messageGroups.clear();
        currentPagea = 1;
      }

      final response = await ApiService.instance.request(
          endPoint: ApiString.getMessages,
          method: Method.POST,
          reqBody: {
            "userId": signInModel.data!.user!.id,
            "oppositeUserId": oppositeUserId,
            "pageNo": currentPage.toString()
          });

      if (statusCode200Check(response)) {
          //
        if(isFromMsgListen){
          for (var newItem in (response['data']['messages'] as List).map((message) => msg.MessageGroups.fromJson(message)).toList()) {
            int existingIndex = messageGroups.indexWhere((item) => item.sId == newItem.sId);

            if (existingIndex != -1) {
              // Replace existing data
              messageGroups[existingIndex] = newItem;
            } else {
              // Add new data if not found
              messageGroups.add(newItem);
            }
          }
        }else{
          messageGroups.addAll((response['data']['messages'] as List).map((message) => msg.MessageGroups.fromJson(message)).toList());
        }
          totalPages = response['data']['totalPages'];
          lastOpenedUserId = oppositeUserId;
      }
    } catch (e) {
      print("ERROR>>>$e");
    } finally {
      idChatListLoading = false;
      notifyListeners();
    }
  }
  getTypingUpdate() {
    try {
      socketProvider.socket.onAny((event, data) {
        print("Event: $event >>> Data: $data");
        if (data['type'] == "userTyping" && data['data'] is List) {
          var typingData = data['data'];
          if (typingData.isNotEmpty) {
            msgLength = data['msgLength'] ?? 0;
            oppUserIdForTyping = msgLength == 1 ? typingData[0]['sender'] : "";
            notifyListeners();
            print("Sender ID: $oppUserIdForTyping, Message Length: $msgLength");
          } else {
            msgLength = 0;
            oppUserIdForTyping = "";
            notifyListeners();
            print("Data array is empty.");
          }
        } else {
          print("Received data is not of the expected structure.");
        }
      });
    } catch (e) {
      print("Error processing the socket event: $e");
    } finally {
      notifyListeners();
    }
  }
  void disposeReplyMSG(){
    socketProvider.socket.off("reply_notification");
  }
  void getReplyListUpdateSC(String mId) {
    try {
      // Remove any existing listener before adding a new one
      socketProvider.socket.off("reply_notification");
      socketProvider.socket.on("reply_notification", (data) {
        print("Event: reply_notification >>> Data: $data");

        print("mId = $mId");
        print("replyTo socket = ${data['replyTo']}");

        // Ensure we update only when replyTo matches the current message
        if (mId == data['replyTo']) {
          print("I'm In socketProvider for msgId: $mId");
          getReplyMessageList(msgId: mId, fromWhere: "SOCKET INIT");
        }
      });
    } catch (e) {
      print("Error processing the socket event: $e");
    } finally {
      notifyListeners();
    }
  }
  Future<void> getReplyMessageList({required String msgId,required String fromWhere}) async {
    print("getReplyMessageList>>>> $fromWhere");
    print("messageId>>>> $msgId");
    if (lastOpenedUserMSGId != msgId) {
      print("lastOpenedUserMSGId => $lastOpenedUserMSGId => msgId = $msgId");
      getReplyMessageModel = null;
    }
    final requestBody = {
      "messageId": msgId
    };
    final response = await ApiService.instance.request(endPoint: ApiString.getRepliesMsg, method: Method.POST,reqBody: requestBody);
    if(statusCode200Check(response)){
      getReplyMessageModel = GetReplyMessageModel.fromJson(response);
      lastOpenedUserMSGId = msgId;
      print("lastOpenedUserMSGId store=> $lastOpenedUserMSGId");
      notifyListeners();
    }
  }
  Future<void> seenReplayMessage({required String msgId}) async {
    final requestBody = {
      "messageId": msgId
    };
    final response = await ApiService.instance.request(endPoint: ApiString.replayMsgSeen, method: Method.POST,reqBody: requestBody);
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
  Future<void> sendMessage({required dynamic content , required String receiverId, List<String>? files,String? replyId , String? editMsgID,})async{
    final requestBody = {
      "content": content,
      "receiverId": receiverId,
      "senderId": signInModel.data?.user?.id,
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
    final response = await ApiService.instance.request(endPoint: ApiString.sendMessage, method: Method.POST,reqBody: requestBody);
    if(statusCode200Check(response)){
      /// Socket Emit ///
      socketProvider.sendMessagesSC(response: response['data'],emitReplyMsg: replyId != null ? true : false);
      /// find where to add ///
      int existingIndex = messageGroups.indexWhere((item) => item.sId == todayDate);
      // int replyIndex = messageGroups.indexWhere((item) => item.messages. == todayDate);
      if(existingIndex != -1){
        /// grp date exists then add ///
        messageGroups[existingIndex].messages!.add(msg.Messages.fromJson(response['data']));
      }else{
        /// grp date not exists then add ///
        final newListOfDate = response['data'];
        messageGroups.add(msg.MessageGroups.fromJson({"_id" : todayDate,'messages':[newListOfDate],"count":1}));
      }
      if(replyId != null){
        // getReplyMessageList(msgId: replyId,fromWhere: "SEND_REPLY_MESSAGE");
        // messageGroups.


      }else {
        // getMessagesList(oppositeUserId: receiverId);
      }
    }
    notifyListeners();
  }
  Future<void> forwardMessage({required Map<String,dynamic> forwardBody})async{
    final response = await ApiService.instance.request(endPoint: forwardBody.keys.contains('channelId') ? ApiString.sendChannelMessage : ApiString.sendMessage, method: Method.POST,reqBody: forwardBody,needLoader: false);
    if(statusCode200Check(response)){
      socketProvider.sendMessagesSC(response: response['data'],emitReplyMsg: false);
    }
  }
  Future<void> deleteMessage({required String messageId,required String receiverId})async{
    final response = await ApiService.instance.request(endPoint: ApiString.deleteMessage + messageId, method: Method.DELETE);
    if(statusCode200Check(response)){
      // getMessagesList(oppositeUserId: receiverId);
      deleteMessageFromModelSingleChat(messageId);
      socketProvider.deleteMessagesSC(response: {"data": response['data']});
    }
  }
  Future<void> deleteMessageForReply({required String messageId, required firsMessageId,required String userName, required String oppId})async{
    final response = await ApiService.instance.request(endPoint: ApiString.deleteMessage + messageId, method: Method.DELETE);
    if(statusCode200Check(response)){
      deleteMessageFromReplyModel(messageId);
      socketProvider.deleteMessagesSC(response: {"data": response['data']});
        if(firsMessageId == messageId) {
          pop();
          deleteMessageFromModelSingleChat(messageId);
        }
    }
  }
  Future<void> pinUnPinMessage({required String receiverId,required String messageId,required bool pinned})async{
    final response = await ApiService.instance.request(endPoint: ApiString.pinMessage(messageId, pinned), method: Method.PUT);
    if(statusCode200Check(response)){
      // getMessagesList(oppositeUserId: receiverId);
      socketProvider.pinUnPinMessageEvent(senderId: signInModel.data?.user?.id ?? "", receiverId: receiverId);
    }
  }
  Future<void> pinUnPinMessageForReply({required String receiverId,required String messageId,required bool pinned})async{
    final response = await ApiService.instance.request(endPoint: ApiString.pinMessage(messageId, pinned), method: Method.PUT);
    if(statusCode200Check(response)){
      _updatePinnedStatus(messageId, pinned);
      socketProvider.pinUnPinMessageEvent(senderId: signInModel.data?.user?.id ?? "", receiverId: receiverId);
    }
  }
  void _updatePinnedStatus(String messageId, bool pinned) {
    for (var messageGroup in getReplyMessageModel?.data?.messages ?? []) {
      for (var message in messageGroup.groupMessages ?? []) {
        if (message.sId == messageId) {
          message.isPinned = pinned;
          notifyListeners();
          return;
        }
      }
    }
  }
  void deleteMessageFromReplyModel(String messageId) {
    for (var messageGroup in getReplyMessageModel?.data?.messages ?? []) {
      messageGroup.groupMessages?.removeWhere((message) => message.sId == messageId);
    }
    notifyListeners();
  }
  void deleteMessageFromModelSingleChat(String messageId) {
    for (var messageGroup in messageGroups) {
      messageGroup.messages?.removeWhere((message) => message.sId == messageId);
      if (messageGroup.messages?.isEmpty ?? true) {
        messageGroups.remove(messageGroup);
        break;
      }
    }
    notifyListeners();
  }
  Future<void> getFileListingInChat({required String oppositeUserId})async{
    final requestBody = {"oppositeUserId": oppositeUserId};
    final response = await ApiService.instance.request(endPoint: ApiString.getFileListingInChat, method: Method.POST,reqBody: requestBody);
    if(statusCode200Check(response)){
      filesListingInChatModel = FilesListingInChatModel.fromJson(response);
    }
    notifyListeners();
  }
}
