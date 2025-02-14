import 'dart:io';

import 'package:e_connect/chat_model.dart';
import 'package:e_connect/socket_io/socket_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../model/get_user_model.dart';
import '../../model/message_model.dart';
import '../../utils/api_service/api_service.dart';
import '../../utils/api_service/api_string_constants.dart';
import '../../utils/common/common_function.dart';



class ChatProvider extends  ChangeNotifier {
  final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context,listen: false);
  List<MessageGroups> messageGroups = [];
  String? lastOpenedUserId;
  String oppUserIdForTyping = "";
  int msgLength = 0;
  final Map<String, dynamic> userCache = {};

  // ChatModel? chatModel;
  // MessageModel? messageModel;
  getTypingUpdate(){
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
    }finally{
      notifyListeners();
    }
  }


  Future<void> getMessagesList(String oppositeUserId,[bool? check]) async {
    if (lastOpenedUserId != oppositeUserId) {
      messageGroups.clear();
      userCache.clear();
    }
    final response = await ApiService.instance.request(
        endPoint: ApiString.getMessages,
        method: Method.POST,
        reqBody: {
          "userId": signInModel.data!.user!.id,
          "oppositeUserId": oppositeUserId,
          "pageNo": "1"
        });
    if (statusCode200Check(response)) {
      messageGroups = (response['data']['messages'] as List).map((message) => MessageGroups.fromJson(message)).toList();
      print("Messages == ${messageGroups.length}");
      print("First group == ${messageGroups[0].sId}");
      lastOpenedUserId = oppositeUserId;
    }
    notifyListeners();
  }

  Future<void> getMessagesList2(String oppositeUserId,[bool? check]) async {
    print("getMessagesList2>>>>>");
    // if(check == true){
    //   print("claaeddd");
    // }
    if (lastOpenedUserId != oppositeUserId) {
      // messageModel = null;
      messageGroups.clear();
      notifyListeners();
    }
    final response = await ApiService.instance.request(
        endPoint: ApiString.getMessages,
        method: Method.POST,
        reqBody: {
          "userId": signInModel.data!.user!.id,
          "oppositeUserId": oppositeUserId,
          "pageNo": "1"
        });
    if (statusCode200Check(response)) {
      // messageModel = MessageModel.fromJson(response);
      messageGroups = (response['data']['messages'] as List).map((message) => MessageGroups.fromJson(message)).toList();
      // print("Messages == ${messageGroups.length}");
      // print("First group == ${messageGroups[0].sId}");
      lastOpenedUserId = oppositeUserId;
      notifyListeners();
    }
  }


  Future<void> sendMessage({required dynamic content , required String receiverId, required String senderId, List<PlatformFile>? selectedFiles,})async{
    final requestBody = {
      "content": content,
      "receiverId": receiverId,
      "senderId": senderId
    };
    if (selectedFiles != null && selectedFiles.isNotEmpty) {
      List<File> files = selectedFiles
          .where((file) => file.path != null)
          .map((file) => File(file.path!))
          .toList();
      requestBody["files"] = files.map((file) => "message_media/${file.path.split('/').last}").toList();
    }
    final response = await ApiService.instance.request(endPoint: ApiString.sendMessage, method: Method.POST,reqBody: requestBody);
    if(statusCode200Check(response)){
        getMessagesList(receiverId);
      socketProvider.sendMessages(response:response['data']);
    }
  }

  Future<void> deleteMessage({required String messageId,required String receiverId})async{
    final response = await ApiService.instance.request(endPoint: ApiString.deleteMessage + messageId, method: Method.DELETE);
    if(statusCode200Check(response)){
      getMessagesList(receiverId);
      socketProvider.sendMessages(response:response['data']);
    }
  }
}
