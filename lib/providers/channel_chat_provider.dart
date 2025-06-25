import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../main.dart';
import '../model/channel_chat_model.dart' as msg;
import '../model/channel_chat_model.dart';
import '../model/channel_members_model.dart';
import '../model/channel_pinned_message_model.dart';
import '../model/files_listing_in_channel_chat_model.dart';
import '../model/get_channel_info.dart';
import '../model/get_reply_message_channel_model.dart';
import '../socket_io/socket_io.dart';
import '../utils/api_service/api_service.dart';
import '../utils/api_service/api_string_constants.dart';
import '../utils/app_preference_constants.dart';
import '../utils/common/common_function.dart';
import '../utils/common/common_widgets.dart';
import 'channel_list_provider.dart';
import 'file_service_provider.dart';

class ChannelChatProvider extends ChangeNotifier{
  final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context, listen: false);
  GetChannelInfo? getChannelInfo;
  msg.ChannelChatModel? channelChatModel;
  ChannelPinnedMessageModel? channelPinnedMessageModel;
  GetReplyMessageChannelModel? getReplyMessageChannelModel;
  List<MemberDetails> channelMembersList = [];
  FilesListingInChannelChatModel? filesListingInChannelChatModel;
  List<msg.MessageGroup> messageGroups = [];
  int currentPage = 1;
  int totalPages = 0;
  int firstInitialPageNo = 0;

  void incrementPinnedMessagesCountModel() {
    getChannelInfo?.data?.pinnedMessagesCount = (getChannelInfo?.data?.pinnedMessagesCount ?? 0) + 1;
    notifyListeners();
  }

  void decrementPinnedMessagesCountModel() {
    if (getChannelInfo?.data?.pinnedMessagesCount != null &&
        (getChannelInfo?.data?.pinnedMessagesCount ?? 0) > 0) {
      getChannelInfo?.data?.pinnedMessagesCount =
          (getChannelInfo?.data?.pinnedMessagesCount ?? 0) - 1;
    }
  }


  int msgLength = 0;
  List<Map<String, dynamic>> typingUsers = [];
  getTypingUpdate(bool isChannel) {
    try {
      if (isChannel == false) {
        return;
      }
      socketProvider.socket.onAny((event, data) {
        // print("Event: $event >>> Data: $data");
        if (data['type'] == "userTyping" && data['data'] is List) {
          var typingData = data['data'];
          if (typingData.isNotEmpty) {
            msgLength = data['msgLength'] ?? 0;
            String userId = data['userData']['user_id'] ?? "";
            String username = data['userData']['username'] ?? "";
            String routeId = data['routeId'] ?? "";
            bool isReply = data['isReply'] ?? false;
            String parentId = data['parentId'] ?? "";

            // print("userId >>> $userId");
            // print("routeId >>> $routeId");
            // print("isReply >>> $isReply");
            // print("parentId >>> $parentId");

            // Prevent adding your own user in the list
            if (userId.toString() == signInModel!.data?.user?.sId.toString()) {
              typingUsers.removeWhere((user) => user['user_id'] == signInModel!.data?.user?.sId.toString());
              notifyListeners();
              return;
            }

            if (msgLength > 0) {
              // Check if the user already exists in the list
              bool alreadyExists = typingUsers.any((user) =>
              user['user_id'] == userId &&
                  user['routeId'] == routeId &&
                  user['isReply'] == isReply &&
                  user['parentId'] == parentId
              );

              if (!alreadyExists) {
                // Add the user to the list
                typingUsers.add({
                  'user_id': userId,
                  'username': username,
                  'routeId': routeId,
                  'isReply': isReply,
                  'parentId': parentId
                });
              }
            } else {
              // Remove user from the list if typing stops
              typingUsers.removeWhere((user) =>
              user['user_id'] == userId &&
                  user['routeId'] == routeId
              );
            }

            notifyListeners();
            print("Currently Typing Users: $typingUsers");
          } else {
            // Clear the list if no user is typing
            typingUsers.clear();
            notifyListeners();
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


  unPinOnlyFromPinnedMessages({required String channelID,required String messageId,}) async {
    final response = await ApiService.instance.request(endPoint: ApiString.pinMessage(messageId, false), method: Method.PUT);
    if(Cf.instance.statusCode200Check(response)){
      getChannelChatApiCall(channelId: channelID, pageNo: 1,onlyReadInChat: true);
      getChannelPinnedMessage(channelID: channelID,needLoader: false);
      getChannelInfoApiCall(channelId: channelID, callFroHome: false);
    }
  }

  Future<void> pinUnPinMessage({required String channelID,required String messageId,required bool pinned,bool isCalledForReply = false})async{
    final response = await ApiService.instance.request(endPoint: ApiString.pinMessage(messageId, pinned), method: Method.PUT);
    if(Cf.instance.statusCode200Check(response)){
      print("pinUnPinMessage = Success");
      socketProvider.pinUnPinMessageEventChannelChat(senderId: signInModel!.data?.user?.sId ?? "", channelId: channelID);
      if(isCalledForReply) {
        // Update in reply messages
        if (getReplyMessageChannelModel?.data?.messagesList != null) {
          for (var messageGroup in getReplyMessageChannelModel!.data!.messagesList!) {
            for (var message in messageGroup.messagesGroupList ?? []) {
              if (message.sId == messageId) {
                message.isPinned = pinned; // Toggle the pin state
                notifyListeners();
                break;
              }
            }
          }
        }
      }else {
        for (var messageGroup in messageGroups) {
          for (var message in messageGroup.messages ?? []) {
            if (message.id == messageId) {
              message.isPinned = pinned;
              notifyListeners();
              break;
            }
          }
        }
      }
      if(pinned){
        incrementPinnedMessagesCountModel();
      }else {
        decrementPinnedMessagesCountModel();
      }
    }
  }




  Future<List<String>> uploadFiles(String screenName) async {
    try {
      Cw.instance.startLoading();
      List<PlatformFile> selectedFiles = FileServiceProvider.instance.getFilesForScreen(screenName);
      List<File> filesToUpload = selectedFiles.map((platformFile) {
        return File(platformFile.path!);
      }).toList();
      print("<<<<<<<<<<SUIIIII>>>>>>>>>>>");
      var request = http.MultipartRequest('POST', Uri.parse(ApiString.baseUrl + ApiString.uploadFileForMessageMedia));
      request.headers.addAll({
        'Authorization': "Bearer ${signInModel!.data?.authToken}",
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
      Cw.instance.stopLoading();
    }
  }

  Future<void> sendMessageOld({
    required dynamic content,
    required String channelId,
    List<String>? files,
    String? replyId,
    String? editMsgID,
    bool isEditFromReply = false,
  }) async {
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
    final response = await ApiService.instance.request(endPoint: ApiString.sendChannelMessage, method: Method.POST, reqBody: requestBody);
    
    if (Cf.instance.statusCode200Check(response)) {
      /// Socket Emit ///
      socketProvider.sendMessagesSC(response: response['data'], emitReplyMsg: replyId != null ? true : false);

      /// find where to add ///
      if (editMsgID != null && editMsgID.isNotEmpty) {
        print("editMessageId>> $editMsgID $isEditFromReply");
        if(isEditFromReply == true){
          for (var message in getReplyMessageChannelModel!.data!.messagesList!) {
            int groupMessageIndex = message.messagesGroupList!.indexWhere((msg) => msg.sId == editMsgID);
            if (groupMessageIndex != -1) {
              var groupMessage = message.messagesGroupList![groupMessageIndex];
              groupMessage.content = content;
              groupMessage.isEdited = true;
              break;
            }
          }
        } else {
          int editIndex = messageGroups.indexWhere((item) => item.messages!.any((msg) => msg.id == editMsgID));
          if (editIndex != -1) {
            msg.Message editedMessage = msg.Message.fromJson(response['data']);
            editedMessage.isEdited = true;
            messageGroups[editIndex].messages![messageGroups[editIndex].messages!.indexWhere((msg) => msg.id == editMsgID)] = editedMessage;
          }
        }
      } else if (replyId != null && replyId.isNotEmpty) {
        getReplyMessageListChannel(msgId: replyId, fromWhere: "Reply Send Channel");
      } else {
        // Existing logic for adding new messages
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
    }
    notifyListeners();
  }

  /// waffle send message ///
  Future<void> sendMessage({
    required dynamic content,
    required String channelId,
    List<String>? files,
    String? replyId,
    String? editMsgID,
    bool isEditFromReply = false,
  }) async {
    final requestBody = {
      "content": content,
      "channelId": channelId,
    };
    print("content>>>> $content");
    // Check for user mentions in content if it's a string
    if (content is String) {
      content = content.replaceAll(RegExp(r':[Ww][Aa][Ff][Ff][Ll][Ee]'), ':waffle');
      RegExp mentionRegex = RegExp(r'@([A-Za-z0-9_]+)');
      final mentionMatches = mentionRegex.allMatches(content);
      List<String> taggedUsers = [];

      for (var match in mentionMatches) {
        String username = match.group(1)!;
        // Check if the mentioned user exists in channel members
        bool isValidUser = channelMembersList.any((member) => member.username == username);
        if (isValidUser) {
          // Find the user ID from channel members
          String? userId = channelMembersList.firstWhere((member) => member.username == username).sId;
          if (userId != null) {
            taggedUsers.add(userId);
          }
        }
      }

      if (taggedUsers.isNotEmpty) {
        requestBody["tagged_users"] = taggedUsers;
      }
    }

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

    /// Karma Functionality ///
    bool shouldSendMessage = true;

    // if (channelId == "67fdfe38eb1f5907bf48e624" && content is String) {
    if (channelId == AppPreferenceConstants.elsnerChannelGetId && content is String) {
      // New pattern: Look for both @username and :karma anywhere in the content
      RegExp mentionRegex = RegExp(r'@([A-Za-z0-9_]+)');
      RegExp karmaRegex = RegExp(r':waffle', caseSensitive: false);

      final mentionMatches = mentionRegex.allMatches(content);
      final karmaMatches = karmaRegex.allMatches(content);

      // Proceed if there's exactly one mention and :karma exists
      if (mentionMatches.length == 1 && karmaMatches.isNotEmpty) {
        try {
          // Get the username mentioned
          final mentionedUsername = mentionMatches.first.group(1);

          // Remove both the @username and :karma from the content
          String processedContent = content;
          final mentionToRemove = mentionMatches.first.group(0)!;
          final karmaToRemove = karmaMatches.first.group(0)!;

          processedContent = processedContent.replaceFirst(mentionToRemove, '');
          processedContent = processedContent.replaceFirst(karmaToRemove, '');
          final String contentWithoutMention = processedContent.trim();

          // Debug prints to verify content processing
          print("Original content: $content");
          print("Mention to remove: $mentionToRemove");
          print("Karma tag to remove: $karmaToRemove");
          print("Extracted username: $mentionedUsername");
          print("Content after processing: $contentWithoutMention");

          if (contentWithoutMention.trim().isNotEmpty) {
            // Find the member by username to get their email
            MemberDetails? mentionedMember;
            for (var member in channelMembersList) {
              if (member.username == mentionedUsername) {
                mentionedMember = member;
                break;
              }
            }

            if (mentionedMember != null) {
              // Check if user is not sending karma to themselves
              if (mentionedMember.email != signInModel!.data?.user?.email) {
                final karmaRequestBody = {
                  "sender_email": signInModel!.data?.user?.email ?? "",
                  "receiver_email": mentionedMember.email,
                  "transaction_type": "manualy_send",
                  "message": contentWithoutMention.trim(),
                };

                try {
                  final karmaResponse = await ApiService.instance.request(
                    endPoint: ApiString.sendKarma,
                    method: Method.POST,
                    isKarmaUrl: true,
                    reqBody: karmaRequestBody
                  );

                  // Check karma response
                  print("karmaResponse >>> ${karmaResponse}");
                  
                  // Check if the response has success field and it's true
                  if (karmaResponse['success'] == true) {
                    print("Karma sent successfully: ${karmaResponse['message']}");
                    Cw.instance.commonShowToast("${karmaResponse['message']}", Colors.green);
                  } else {
                    // If karma API fails with specific messages, don't send the message
                    print("Karma send failed: ${karmaResponse['message']}");
                    if (karmaResponse['message'] == "You cannot send Waffle to yourself" ||
                        karmaResponse['message'] == "Insufficient Waffle balance") {
                      shouldSendMessage = false;
                      // Show error message to the user
                      Cw.instance.commonShowToast("${karmaResponse['message']}", Colors.red);
                      return;
                    } else {
                      // Handle other error cases
                      shouldSendMessage = false;
                      Cw.instance.commonShowToast("${karmaResponse['message']}", Colors.red);
                      return;
                    }
                  }
                } catch (e) {
                  print("Error sending karma: $e");
                  Cw.instance.commonShowToast("Failed to send karma. Please try again.", Colors.red);
                  shouldSendMessage = false;
                  return;
                }
              } else {
                print("Cannot send Karma to yourself");
                Cw.instance.commonShowToast("You cannot send Waffle to yourself", Colors.red);
                shouldSendMessage = false;
                return;
              }
            } else {
              print("User not found in channel members");
              Cw.instance.commonShowToast("User not found in channel members", Colors.red);
              shouldSendMessage = false;
              return;
            }
          }
        } catch (e) {
          print("Error processing karma message: $e");
          Cw.instance.commonShowToast("Error processing karma message", Colors.red);
          shouldSendMessage = false;
          return;
        }
      }
    }

    if (shouldSendMessage == false) return;

    try {
      final response = await ApiService.instance.request(
        endPoint: ApiString.sendChannelMessage, 
        method: Method.POST, 
        reqBody: requestBody
      );

      if (Cf.instance.statusCode200Check(response)) {
        /// Socket Emit ///
        socketProvider.sendMessagesSC(response: response['data'], emitReplyMsg: replyId != null ? true : false);

        /// find where to add ///
        if (editMsgID != null && editMsgID.isNotEmpty) {
          print("editMessageId>> $editMsgID $isEditFromReply");
          if(isEditFromReply == true){
            for (var message in getReplyMessageChannelModel!.data!.messagesList!) {
              int groupMessageIndex = message.messagesGroupList!.indexWhere((msg) => msg.sId == editMsgID);
              if (groupMessageIndex != -1) {
                var groupMessage = message.messagesGroupList![groupMessageIndex];
                groupMessage.content = content;
                groupMessage.isEdited = true;
                break;
              }
            }
          } else {
            int editIndex = messageGroups.indexWhere((item) => item.messages!.any((msg) => msg.id == editMsgID));
            if (editIndex != -1) {
              msg.Message editedMessage = msg.Message.fromJson(response['data']);
              editedMessage.isEdited = true;
              messageGroups[editIndex].messages![messageGroups[editIndex].messages!.indexWhere((msg) => msg.id == editMsgID)] = editedMessage;
            }
          }
        } else if (replyId != null && replyId.isNotEmpty) {
          getReplyMessageListChannel(msgId: replyId, fromWhere: "Reply Send Channel");
        } else {
          // Existing logic for adding new messages
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
      }
    } catch (e) {
      print("Error sending message: $e");
      Cw.instance.commonShowToast("Failed to send message. Please try again.", Colors.red);
    }
    notifyListeners();
  }

  void paginationAPICall({required String channelId}) {
    if(currentPage < totalPages) {
      currentPage++;
      notifyListeners();
      getChannelChatApiCall(channelId: channelId,pageNo: currentPage,onlyReadInChat: false);
    }
  }

  Future<void> getChannelPinnedMessage({required String channelID,bool needLoader = true})async{
    final requestBody = {"channelId": channelID};
    final response = await ApiService.instance.request(endPoint: ApiString.getChannelPinnedMessage(channelID), method: Method.GET,needLoader: needLoader);
    if(Cf.instance.statusCode200Check(response)){
      channelPinnedMessageModel = ChannelPinnedMessageModel.fromJson(response);
      notifyListeners();
    }
  }
  void downStreamPaginationAPICall({required String channelId}) {
    print("object aaaa");
    // print("object currentPagea $currentPagea");
    print("object totalPages $totalPages");
    if(firstInitialPageNo <= totalPages) {
      if(firstInitialPageNo != 1){
        firstInitialPageNo --;
        // print("Page no paginationAPICall in down $firstInitialPageNo $oppositeUserId");
        getChannelChatApiCall(channelId: channelId,pageNo: firstInitialPageNo,isFromMsgListen: true,onlyReadInChat: false);
        // getMessagesList(oppositeUserId: oppositeUserId, currentPage: firstInitialPageNo,isFromMsgListen: true);
        notifyListeners();
      }

    }
  }
  void changeCurrentPageValue(int pageNo) {
    // Check if the pinned message count is greater than 0 before decrementing
    currentPage = pageNo;
    firstInitialPageNo = pageNo;
    notifyListeners();
  }
  Future<void> getChannelChatApiCall({required String channelId,required int pageNo,bool isFromMsgListen = false,bool? isFromJump,bool onlyReadInChat = false, bool needToReload = false, bool needLoaderFromInItState = false})async {
   try{
     if(isFromJump ?? false){
       currentPage = pageNo;
       messageGroups.clear();
     }

     if (lastOpenedChannelId != channelId || needToReload) {
       messageGroups.clear();
       totalPages = 0;
       currentPage = isFromJump ?? false ? pageNo :  1;
     }
     if(needLoaderFromInItState){
       isChannelChatLoading = true;
       notifyListeners();
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
     if(Cf.instance.statusCode200Check(response)){
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
       isChannelChatLoading = false;
       notifyListeners();
     }
     if(onlyReadInChat == true){
       await Provider.of<ChannelListProvider>(navigatorKey.currentState!.context, listen: false)
           .readUnReadChannelMessage(oppositeUserId: channelId, isCallForReadMessage: true); totalPages = response['data']['totalPages'];
     }
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
    if (Cf.instance.statusCode200Check(response)) {
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
      'Authorization': 'Bearer ${signInModel!.data!.authToken}',
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
          "senderId": signInModel!.data!.user!.sId,
          "receiverId": userIds,
          "channelId": channelId
        }
      };
      getChannelMembersList(channelId);
      getChannelInfoApiCall(channelId: channelId, callFroHome: false);
      getChannelChatApiCall(channelId: channelId, pageNo: 1,onlyReadInChat: true);
      socketProvider.addMemberToChannel(response: passInSocket);
    }
    else {
      print(response.reasonPhrase);
    }}

  Future<void> getChannelInfoApiCall({required String channelId,required bool callFroHome})async{
    final response  = await ApiService.instance.request(endPoint: ApiString.getChannelInfo(channelId), method: Method.GET,);
    if(Cf.instance.statusCode200Check(response)){
      getChannelInfo = GetChannelInfo.fromJson(response);
      notifyListeners();
    }
  }
  String? lastOpenedChannelId;
  bool isChannelChatLoading = true;

  Future<void> getFileListingInChannelChat({required String channelId})async{
    final requestBody = {"channelId": channelId};
    final response = await ApiService.instance.request(endPoint: ApiString.getFilesListingInChannelChat(channelId), method: Method.GET);
    if(Cf.instance.statusCode200Check(response)){
      filesListingInChannelChatModel = FilesListingInChannelChatModel.fromJson(response);
    }
    notifyListeners();
  }




  String? lastOpenedUserMSGId;

  Future<void> getReplyMessageListChannel({required String msgId,required String fromWhere}) async {
    print("getReplyMessageListChannel>>>> $fromWhere");
    print("messageId>>>> $msgId");
    if (lastOpenedUserMSGId != msgId) {
      print("lastOpenedUserMSGId => $lastOpenedUserMSGId => msgId = $msgId");
    }
    final requestBody = {
      "messageId": msgId
    };
    final response = await ApiService.instance.request(endPoint: ApiString.getRepliesMsg, method: Method.POST,reqBody: requestBody);
    if(Cf.instance.statusCode200Check(response)){
      getReplyMessageChannelModel = GetReplyMessageChannelModel.fromJson(response);
    }
    lastOpenedUserMSGId = msgId;
    print("lastOpenedUserMSGId store=> $lastOpenedUserMSGId");
    notifyListeners();
  }



  void getReplyListUpdateSocketForChannel(String mId,) {
    try {
      // Remove any existing listener before adding a new one
      socketProvider.socket.off("reply_notification");

      socketProvider.socket.on("reply_notification", (data) {
        // print("Event: reply_notification >>> Data: $data");

        // print("mId = $mId");
        // print("replyTo socket = ${data['replyTo']}");

        // Ensure we update only when replyTo matches the current message
        if (mId == data['replyTo']) {
          print("I'm In socketProvider for msgId: $mId");
            getReplyMessageListChannel(msgId: mId, fromWhere: "SOCKET INIT For Channel Reply List");

            for (msg.MessageGroup messageGroup in messageGroups) {
              for (msg.Message message in messageGroup.messages ?? []) {
                if (message.id == mId) {
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

  /// API ///
  Future<void> deleteMessageFromChannel({required String messageId,}) async {
    try {
      final response = await ApiService.instance.request(
          endPoint: ApiString.deleteMessageFromChannel(messageId),
          method: Method.DELETE
      );
      if (Cf.instance.statusCode200Check(response)) {
        print("Message Deleted");
        removeMessageFromModelList(messageId);
        socketProvider.deleteMessagesFromChannelSC(response: {"data": response['data']});
      }else{
        print("Message Not Deleted");
        print("response = $response");
      }
    } on Exception catch (e) {
      print("catch = ${e.toString()}");
    }
  }
  /// API ///
  Future<void> deleteMessageForReplyChannel({required String messageId, required firsMessageId})async{
    final response = await ApiService.instance.request(endPoint: ApiString.deleteMessageFromChannel(messageId), method: Method.DELETE);
    if(Cf.instance.statusCode200Check(response)){
      socketProvider.deleteMessagesFromChannelSC(response: {"data": response['data']});
      deleteMessageFromReplyModel(messageId);
      if(firsMessageId == messageId) {
        Cf.instance.pop();
        removeMessageFromModelList(messageId);
      }
    }
  }

  /// Model Functionality ///
  void deleteMessageFromReplyModel(String messageId) {
    for (MessagesList messageGroup in getReplyMessageChannelModel?.data?.messagesList ?? []) {
      messageGroup.messagesGroupList?.removeWhere((message) => message.sId == messageId);
    }
    notifyListeners();
  }

  /// Channel Chat ///
  void removeMessageFromModelList(String messageId) {
    for (msg.MessageGroup messageGroup in messageGroups) {
      messageGroup.messages?.removeWhere((message) => message.id == messageId);
      if (messageGroup.messages?.isEmpty ?? true) {
        messageGroups.remove(messageGroup);
        break;
      }
    }
    notifyListeners();
  }

/*

addChannelApiCall({required String channelName,required bool isPrivate,required String description})async{
    final requestBody = {
      "name": channelName,
      "isPrivate": isPrivate.toString(),
      "description": description,
    };
    final response = await ApiService.instance.request(endPoint: ApiString.addChannelTO, method: Method.POST,reqBody: requestBody);
}
*/


// Reaction of message
  Future<void> reactMessage(
      {required String messageId,
        required String reactUrl,
        required String channelId,
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
    if (Cf.instance.statusCode200Check(response)) {
      print("Reacted Successfully");
      print("isFrom = $isFrom");
      if (isFrom == "Channel") {
        // Manually update the message model with the new reaction
        for (var messageGroup in messageGroups) {
          for (var message in messageGroup.messages ?? []) {
            if (message.id == messageId) {
              // Initialize reactions list if null
              message.reactions ??= [];

              // Check if user already reacted with this emoji
              final existingReactionIndex = message.reactions!.indexWhere(
                      (reaction) =>
                  reaction.userId == signInModel!.data?.user?.sId &&
                      reaction.emoji == reactUrl);

              if (existingReactionIndex != -1) {
                // Remove existing reaction if found
                message.reactions!.removeAt(existingReactionIndex);
              } else {
                // Add new reaction

                message.reactions!.add(Reaction(
                  emoji: reactUrl,
                  userId: signInModel!.data?.user?.sId,
                  username: signInModel!.data?.user?.userName,
                  id: DateTime.now().toString(), // Temporary ID
                ));


              }

              notifyListeners();
              break;
            }
          }
        }
      } else if (isFrom == "ChannelReply") {
        // Find the message in getReplyMessageModel and update its reactions
        for (var messageGroup in getReplyMessageChannelModel?.data?.messagesList ?? []) {
          for (var message in messageGroup.messagesGroupList ?? []) {
            if (message.sId == messageId) {
              // Initialize reactions list if null
              message.reactions ??= [];

              // Check if user already reacted with this emoji
              final existingReactionIndex = message.reactions!.indexWhere(
                      (reaction) =>
                  reaction.userId?.sId == signInModel!.data?.user?.sId &&
                      reaction.emoji == reactUrl);

              if (existingReactionIndex != -1) {
                // Remove existing reaction if found
                message.reactions!.removeAt(existingReactionIndex);
              } else {
                // Add new reaction
                message.reactions!.add(Reactions(
                  emoji: reactUrl,
                  userId: UserId(
                    sId: signInModel!.data?.user?.sId,
                    username: signInModel!.data?.user?.userName,
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
      socketProvider.reactMessagesInChannelSC(response: {
        "channelId": channelId, // Channel ID
        "senderId": signInModel!.data?.user?.sId,
      });

    }
  }

  Future<void> reactionRemove(
      {required String messageId,
        required String reactUrl,
        required String channelId,
        required String isFrom}) async {
    Map<String, dynamic> reqBody = {
      "messageId": messageId,
      "reaction": reactUrl
    };
    print("reactionRemove Fun");
    final response = await ApiService.instance.request(
        endPoint: ApiString.removeReact, method: Method.POST, reqBody: reqBody);
    if (Cf.instance.statusCode200Check(response)) {
      print("React removed Successfully");
      print("isFrom = $isFrom");

      if (isFrom == "Channel") {
        // Remove reaction from chat message model
        for (var messageGroup in messageGroups) {
          for (var message in messageGroup.messages ?? []) {
            if (message.id == messageId) {
              // Find and remove the reaction
              final existingReactionIndex = message.reactions!.indexWhere(
                      (reaction) =>
                  reaction.userId == signInModel!.data?.user?.sId &&
                      reaction.emoji == reactUrl);
              if (existingReactionIndex != -1) {
                message.reactions!.removeAt(existingReactionIndex);
                notifyListeners();
              }
              break;
            }
          }
        }
      } else if (isFrom == "ChannelReply") {
        // Remove reaction from reply message model
        for (var messageGroup in getReplyMessageChannelModel?.data?.messagesList ?? []) {
          for (var message in messageGroup.messagesGroupList ?? []) {
            if (message.sId == messageId) {
              // Find and remove the reaction
              final existingReactionIndex = message.reactions!.indexWhere(
                      (reaction) =>
                  reaction.userId?.sId == signInModel!.data?.user?.sId &&
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

      socketProvider.reactMessagesInChannelSC(response: {
        "channelId": channelId,// Channel ID
        "senderId": signInModel!.data?.user?.sId,
      });

    }
  }


}