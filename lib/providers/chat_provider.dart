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
import '../model/get_reply_message_model.dart' as reply;
import '../model/message_model.dart' as msg;
import 'common_provider.dart';
import 'file_service_provider.dart';
import '../utils/api_service/api_service.dart';
import '../utils/api_service/api_string_constants.dart';
import '../utils/common/common_function.dart';
import 'package:http/http.dart' as http;



class ChatProvider extends  ChangeNotifier {
  final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context, listen: false);
  final commonProvider = Provider.of<CommonProvider>(navigatorKey.currentState!.context, listen: false);
  List<msg.MessageGroups> messageGroups = [];
  String? lastOpenedUserId;
  String? lastOpenedUserMSGId;
  String oppUserIdForTyping = "";
  String parentId = "";
  bool? isTypingFor;
  int msgLength = 0;
  bool idChatListLoading = false;
  int currentPagea = 1;
  int totalPages = 0;
  reply.GetReplyMessageModel? getReplyMessageModel;
  FilesListingInChatModel? filesListingInChatModel;
  bool isGettingListFalse = false;


  void pinMessageModelUpdate() {
    // Increment the pinned message count safely
    commonProvider.getUserModelSecondUser ?.data?.user?.pinnedMessageCount =
    (commonProvider.getUserModelSecondUser ?.data?.user?.pinnedMessageCount ?? 0) + 1;

    // Notify listeners to update the UI
    commonProvider.notifyListeners();
    }

  void unpinMessageModelUpdate() {
    // Check if the pinned message count is greater than 0 before decrementing
    if (commonProvider.getUserModelSecondUser ?.data?.user?.pinnedMessageCount != null &&
    (commonProvider.getUserModelSecondUser ?.data?.user?.pinnedMessageCount ?? 0) > 0) {
    commonProvider.getUserModelSecondUser ?.data?.user?.pinnedMessageCount =
    (commonProvider.getUserModelSecondUser ?.data?.user?.pinnedMessageCount ?? 0) - 1;

    // Notify listeners to update the UI
    commonProvider.notifyListeners();
    }
  }

  void paginationAPICall({required String oppositeUserId}) {
    if(currentPagea < totalPages) {
      currentPagea++;
      getMessagesList(oppositeUserId: oppositeUserId, currentPage: currentPagea);
      notifyListeners();
    }
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
              messageGroups[existingIndex] = newItem;
            } else {
              messageGroups.add(newItem);
            }
          }
        }else{
          print("MSG = ${response['data']['messages'] as List}");
          messageGroups.addAll((response['data']['messages'] as List).map((message) {
            return msg.MessageGroups.fromJson(message);
          }).toList());
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
  // 42["user_typing",{"message":"","type":"userTyping",
  // "data":[{"sender":"676d5d2de010e883aec47240","receivers":"677b7adc3f5bb1fd3416ca3e"}],
  // "time":"2025-03-11T09:41:10.040Z","message_type":"message","routeId":"676d5d2de010e883aec47240","tagged_users":[],"msgLength":1,
  // "userData":{},"isChannel":false,"isReply":true,"parentId":""}]
  getTypingUpdate() {
    try {
      socketProvider.socket.onAny((event, data) {
        print("Event: $event >>> Data: $data");
        if (data['type'] == "userTyping" && data['data'] is List) {
          var typingData = data['data'];
          if (typingData.isNotEmpty) {
            msgLength = data['msgLength'] ?? 0;
            isTypingFor = data['isReply'] ?? false;
              parentId = data['parentId'] ?? "";
            oppUserIdForTyping = msgLength == 1 ? typingData[0]['sender'] : "";
            notifyListeners();
            print("Sender ID: $oppUserIdForTyping, Message Length: $msgLength & $isTypingFor && $parentId ");
          } else {
            msgLength = 0;
            oppUserIdForTyping = "";
            isTypingFor = null;
            parentId = "";
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

            // Update reply count in messageGroups when receiving socket event
            for (var messageGroup in messageGroups) {
              for (var message in messageGroup.messages ?? []) {
                if (message.sId == mId) {
                  message.replyCount = (message.replyCount ?? 0) + 1;
                  notifyListeners();
                  return;
                }
              }
            }
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
    final requestBody = {"messageId": msgId};
    final response = await ApiService.instance.request(
        endPoint: ApiString.getRepliesMsg,
        method: Method.POST,
        reqBody: requestBody);
    if (statusCode200Check(response)) {
      getReplyMessageModel = reply.GetReplyMessageModel.fromJson(response);
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
  Future<List<String>> uploadFiles(String screenName) async {
   try {
     startLoading();
     List<PlatformFile> selectedFiles = FileServiceProvider.instance.getFilesForScreen(screenName);
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
  Future<void> sendMessage({required dynamic content , required String receiverId, List<String>? files,String? replyId , String? editMsgID,bool? isEditFromReply = false})async{
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
    print("Send Message requestBody -= $requestBody");
    if(statusCode200Check(response)){
      /// Socket Emit ///
      socketProvider.sendMessagesSC(response: response['data'],emitReplyMsg: replyId != null ? true : false);
      /// find where to add ///
      if (editMsgID != null && editMsgID.isNotEmpty) {
        if(isEditFromReply == true){
          if (getReplyMessageModel != null && getReplyMessageModel!.data != null) {
            // Search for the message in the getReplyMessageModel
            for (var message in getReplyMessageModel!.data!.messages!) {
              var groupMessage = message.groupMessages!.firstWhere(
                    (msg) => msg.sId == editMsgID,
                // orElse: () => ,
              );
              if (groupMessage != null) {
                // Update the content of the found message
                groupMessage.content = content; // Update content
                groupMessage.isEdited = true; // Mark as edited
                break; // Exit the loop once the message is found and updated
              }
            }
          }
        }else {
          int editIndex = messageGroups.indexWhere((item) => item.messages!.any((msg) => msg.sId == editMsgID));

          if (editIndex != -1) {
            msg.Messages editedMessage = msg.Messages.fromJson(response['data']);
            editedMessage.isEdited = true; // Set isEdited to true
            messageGroups[editIndex].messages![messageGroups[editIndex].messages!.indexWhere((msg) => msg.sId == editMsgID)] = editedMessage;
          }
        }
      } else if(replyId != null && replyId != ""){
        // int existingIndex = getReplyMessageModel!.data!.messages!.indexWhere((item) => item.date == todayDate);
        // if (existingIndex != -1) {
        //   getReplyMessageModel!.data!.messages![existingIndex].groupMessages!.add(GroupMessages.fromJson(response['data']));
        // } else {
        //   final newListOfDate = response['data'];
        //   // getReplyMessageModel!.data!.messages!.add(GroupMessages.fromJson({
        //   //   "_id": todayDate,
        //   //   'messages': [newListOfDate],
        //   //   "count": 1,
        //   // }));
        // }
       getReplyMessageList(msgId: replyId, fromWhere: "Reply Send");
      }else /*if(replyId == null && replyId == "")*/ {
        int existingIndex = messageGroups.indexWhere((item) => item.sId == todayDate);
        if (existingIndex != -1) {
          messageGroups[existingIndex].messages!.add(msg.Messages.fromJson(response['data']));
        } else {
          final newListOfDate = response['data'];
          messageGroups.add(msg.MessageGroups.fromJson({
            "_id": todayDate,
            'messages': [newListOfDate],
            "count": 1,
          }));
        }
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
  Future<void> deleteMessageForReply({required String messageId, required firsMessageId})async{
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
  Future<void> pinUnPinMessage({required String receiverId,required String messageId,required bool pinned, bool callForUnpinPostOnly = false})async{
    final response = await ApiService.instance.request(endPoint: ApiString.pinMessage(messageId, pinned), method: Method.PUT);
    if(statusCode200Check(response)){
      if(callForUnpinPostOnly){
        getMessagesList(oppositeUserId: receiverId,currentPage: 1);
        commonProvider.getUserByIDCallForSecondUser(userId: receiverId);
      }else {
        togglePinModel(messageId);
        if(pinned){
          pinMessageModelUpdate();
        }else{
          unpinMessageModelUpdate();
        }
      }
      // _updatePinnedStatus(messageId, pinned);
      socketProvider.pinUnPinMessageEventSingleChat(senderId: signInModel.data?.user?.id ?? "", receiverId: receiverId);
    }
  }

  Future<void> pinUnPinMessageForReply({required String receiverId,required String messageId,required bool pinned})async{
    final response = await ApiService.instance.request(endPoint: ApiString.pinMessage(messageId, pinned), method: Method.PUT);
    if(statusCode200Check(response)){
      if(pinned){
        pinMessageModelUpdate();
      }else{
        unpinMessageModelUpdate();
      }
      _updatePinnedStatus(messageId, pinned);
      socketProvider.pinUnPinMessageEventSingleChat(senderId: signInModel.data?.user?.id ?? "", receiverId: receiverId);
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
  void togglePinModel(String messageId) {
    for (var messageGroup in messageGroups ?? []) {
      for (var message in messageGroup.messages ?? []) {
        if (message.sId == messageId) {
          message.isPinned = !(message.isPinned ?? false); // Toggle the isPinned status
          notifyListeners(); // Notify listeners if you're using a state management solution
          return; // Exit after updating
        }
      }
    }
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
  void updateReplyCount(String messageId) {
    // Update reply count in local state
    for (var messageGroup in messageGroups) {
      for (var message in messageGroup.messages ?? []) {
        if (message.sId == messageId) {
          message.replyCount = (message.replyCount ?? 0) + 1;
          notifyListeners();
          
          // Emit socket event to notify other users
          socketProvider.socket.emit('reply_notification', {
            'messageId': messageId,
            'replyTo': messageId,
            'senderId': signInModel.data?.user?.id,
          });
          return;
        }
      }
    }
  }

  // Reaction of message
  Future<void> reactMessage(
      {required String messageId,
      required String reactUrl,
      required String receiverId,
      required String isFrom}) async {
    Map<String, dynamic> reqBody = {
      "messageId": messageId,
      "reaction": reactUrl
    };
    print("RECAT URL + $reactUrl");
    final response = await ApiService.instance.request(
        endPoint: ApiString.reactMessage,
        method: Method.POST,
        reqBody: reqBody);
    if (statusCode200Check(response)) {
      socketProvider.reactMessagesSC(response: {"receiverId": receiverId, "senderId": signInModel.data?.user?.id});
      print("Reacted Successfully");
      print("isFrom = $isFrom");
      if (isFrom == "Chat") {
        // Manually update the message model with the new reaction
        for (var messageGroup in messageGroups) {
          for (var message in messageGroup.messages ?? []) {
            if (message.sId == messageId) {
              // Initialize reactions list if null
              message.reactions ??= [];

              // Check if user already reacted with this emoji
              final existingReactionIndex = message.reactions!.indexWhere(
                  (reaction) =>
                      reaction.userId == signInModel.data?.user?.id &&
                      reaction.emoji == reactUrl);

              if (existingReactionIndex != -1) {
                // Remove existing reaction if found
                message.reactions!.removeAt(existingReactionIndex);
              } else {
                // Add new reaction

                message.reactions!.add(msg.Reaction(
                  emoji: reactUrl,
                  userId: signInModel.data?.user?.id,
                  username: signInModel.data?.user?.username,
                  id: DateTime.now().toString(), // Temporary ID
                ));


              }

              notifyListeners();
              break;
            }
          }
        }
      } else if (isFrom == "Reply") {
        // Find the message in getReplyMessageModel and update its reactions
        for (var messageGroup in getReplyMessageModel?.data?.messages ?? []) {
          for (var message in messageGroup.groupMessages ?? []) {
            if (message.sId == messageId) {
              // Initialize reactions list if null
              message.reactions ??= [];

              // Check if user already reacted with this emoji
              final existingReactionIndex = message.reactions!.indexWhere(
                  (reaction) =>
                      reaction.userId?.sId == signInModel.data?.user?.id &&
                      reaction.emoji == reactUrl);

              if (existingReactionIndex != -1) {
                // Remove existing reaction if found
                message.reactions!.removeAt(existingReactionIndex);
              } else {
                // Add new reaction
                message.reactions!.add(reply.Reactions(
                  emoji: reactUrl,
                  userId: reply.UserId(
                    sId: signInModel.data?.user?.id,
                    username: signInModel.data?.user?.username,
                  ),
                  sId: DateTime.now().toString(), // Temporary ID
                ));
              }

              notifyListeners();
              break;
            }
          }
        }
      }
    }
  }

  Future<void> reactionRemove(
      {required String messageId,
      required String reactUrl,
      required String receiverId,
      required String isFrom}) async {
    Map<String, dynamic> reqBody = {
      "messageId": messageId,
      "reaction": reactUrl
    };
    print("reactionRemove Fun");
    final response = await ApiService.instance.request(
        endPoint: ApiString.removeReact, method: Method.POST, reqBody: reqBody);
    if (statusCode200Check(response)) {
      socketProvider.reactMessagesSC(response: {
        "receiverId": receiverId,
        "senderId": signInModel.data?.user?.id,
      });
      print("React removed Successfully");
      print("isFrom = $isFrom");

      if (isFrom == "Chat") {
        // Remove reaction from chat message model
        for (var messageGroup in messageGroups) {
          for (var message in messageGroup.messages ?? []) {
            if (message.sId == messageId) {
              // Find and remove the reaction
              final existingReactionIndex = message.reactions!.indexWhere(
                  (reaction) =>
                      reaction.userId == signInModel.data?.user?.id &&
                      reaction.emoji == reactUrl);
              if (existingReactionIndex != -1) {
                message.reactions!.removeAt(existingReactionIndex);
                notifyListeners();
              }
              break;
            }
          }
        }
      } else if (isFrom == "Reply") {
        // Remove reaction from reply message model
        for (var messageGroup in getReplyMessageModel?.data?.messages ?? []) {
          for (var message in messageGroup.groupMessages ?? []) {
            if (message.sId == messageId) {
              // Find and remove the reaction
              final existingReactionIndex = message.reactions!.indexWhere(
                  (reaction) =>
                      reaction.userId?.sId == signInModel.data?.user?.id &&
                      reaction.emoji == reactUrl);
              if (existingReactionIndex != -1) {
                message.reactions!.removeAt(existingReactionIndex);
                notifyListeners();
              }
              break;
            }
          }
        }
      }


    }
  }
}
