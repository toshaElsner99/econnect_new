// import 'dart:io';
//
// import 'package:e_connect/chat_model.dart';
// import 'package:e_connect/socket_io/socket_io.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:provider/provider.dart';
//
// import '../../main.dart';
// import '../../model/get_user_model.dart';
// import '../../model/message_model.dart';
// import '../../utils/api_service/api_service.dart';
// import '../../utils/api_service/api_string_constants.dart';
// import '../../utils/common/common_function.dart';
//
//
//
// class ChatProvider extends  ChangeNotifier {
//   final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context,listen: false);
//   List<MessageGroups> messageGroups = [];
//   String? lastOpenedUserId;
//   String oppUserIdForTyping = "";
//   int msgLength = 0;
//   final Map<String, dynamic> userCache = {};
//
//   // ChatModel? chatModel;
//   // MessageModel? messageModel;
//   getTypingUpdate(){
//     try {
//       socketProvider.socket.onAny((event, data) {
//         print("Event: $event >>> Data: $data");
//         if (data['type'] == "userTyping" && data['data'] is List) {
//           var typingData = data['data'];
//           if (typingData.isNotEmpty) {
//               msgLength = data['msgLength'] ?? 0;
//               oppUserIdForTyping = msgLength == 1 ? typingData[0]['sender'] : "";
//               notifyListeners();
//             print("Sender ID: $oppUserIdForTyping, Message Length: $msgLength");
//           } else {
//               msgLength = 0;
//               oppUserIdForTyping = "";
//               notifyListeners();
//             print("Data array is empty.");
//           }
//         } else {
//           print("Received data is not of the expected structure.");
//         }
//       });
//     } catch (e) {
//       print("Error processing the socket event: $e");
//     }finally{
//       notifyListeners();
//     }
//   }
//
//
//   Future<void> getMessagesList(String oppositeUserId,[bool? check]) async {
//     if (lastOpenedUserId != oppositeUserId) {
//       messageGroups.clear();
//       userCache.clear();
//     }
//     final response = await ApiService.instance.request(
//         endPoint: ApiString.getMessages,
//         method: Method.POST,
//         reqBody: {
//           "userId": signInModel.data!.user!.id,
//           "oppositeUserId": oppositeUserId,
//           "pageNo": "1"
//         });
//     if (statusCode200Check(response)) {
//       messageGroups = (response['data']['messages'] as List).map((message) => MessageGroups.fromJson(message)).toList();
//       print("Messages == ${messageGroups.length}");
//       print("First group == ${messageGroups[0].sId}");
//       lastOpenedUserId = oppositeUserId;
//     }
//     notifyListeners();
//   }
//
//   Future<void> getMessagesList2(String oppositeUserId,[bool? check]) async {
//     print("getMessagesList2>>>>>");
//     // if(check == true){
//     //   print("claaeddd");
//     // }
//     if (lastOpenedUserId != oppositeUserId) {
//       // messageModel = null;
//       messageGroups.clear();
//       notifyListeners();
//     }
//     final response = await ApiService.instance.request(
//         endPoint: ApiString.getMessages,
//         method: Method.POST,
//         reqBody: {
//           "userId": signInModel.data!.user!.id,
//           "oppositeUserId": oppositeUserId,
//           "pageNo": "1"
//         });
//     if (statusCode200Check(response)) {
//       // messageModel = MessageModel.fromJson(response);
//       messageGroups = (response['data']['messages'] as List).map((message) => MessageGroups.fromJson(message)).toList();
//       // print("Messages == ${messageGroups.length}");
//       // print("First group == ${messageGroups[0].sId}");
//       lastOpenedUserId = oppositeUserId;
//       notifyListeners();
//     }
//   }
//
//
//   Future<void> sendMessage({required dynamic content , required String receiverId, required String senderId, List<PlatformFile>? selectedFiles,})async{
//     final requestBody = {
//       "content": content,
//       "receiverId": receiverId,
//       "senderId": senderId
//     };
//     if (selectedFiles != null && selectedFiles.isNotEmpty) {
//       List<File> files = selectedFiles
//           .where((file) => file.path != null)
//           .map((file) => File(file.path!))
//           .toList();
//       requestBody["files"] = files.map((file) => "message_media/${file.path.split('/').last}").toList();
//     }
//     final response = await ApiService.instance.request(endPoint: ApiString.sendMessage, method: Method.POST,reqBody: requestBody);
//     if(statusCode200Check(response)){
//         getMessagesList(receiverId);
//       socketProvider.sendMessages(response:response['data']);
//     }
//   }
//
//   Future<void> deleteMessage({required String messageId,required String receiverId})async{
//     final response = await ApiService.instance.request(endPoint: ApiString.deleteMessage + messageId, method: Method.DELETE);
//     if(statusCode200Check(response)){
//       getMessagesList(receiverId);
//       socketProvider.sendMessages(response:response['data']);
//     }
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:e_connect/socket_io/socket_io.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../model/get_reply_message_model.dart';
import '../../model/message_model.dart';
import '../../providers/file_service_provider.dart';
import '../../utils/api_service/api_service.dart';
import '../../utils/api_service/api_string_constants.dart';
import '../../utils/common/common_function.dart';
import 'package:http/http.dart' as http;



class ChatProvider extends  ChangeNotifier {
  final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context, listen: false);
  List<MessageGroups> messageGroups = [];
  String? lastOpenedUserId;
  String oppUserIdForTyping = "";
  int msgLength = 0;
  final Map<String, dynamic> userCache = {};
  final ScrollController scrollController = ScrollController();
  int currentPage = 1;
  int totalPages = 0;
  GetReplyMessageModel? getReplyMessageModel;
  clearForFirstTimeMessages(bool needToCLear) {
    if (needToCLear) {
      messageGroups.clear();
      currentPage = 1;
    }
    notifyListeners();
  }

  // void pagination({required String oppositeUserId}) {
  //   scrollController.addListener(() {
  //     if (scrollController.position.pixels ==
  //         scrollController.position.maxScrollExtent &&
  //         currentPage < totalPages) { // currentPage is less than totalPages
  //       currentPage = currentPage + 1; // Increment the currentPage to load the next page
  //       notifyListeners(); // Update listeners for UI changes
  //
  //       getMessagesList(oppositeUserId: oppositeUserId);
  //
  //       print('currentPage:--->$currentPage');
  //     }
  //   });
  // }
  void pagination({required String oppositeUserId}) {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && currentPage < totalPages) {
        currentPage++; // Increment the currentPage to load the next page
        getMessagesList(oppositeUserId: oppositeUserId,storeLatest: false); // Fetch the next page of messages
        print('currentPage:--->$currentPage');
      }
    });
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

  Future<void> getReplyMessageList({required String msgId}) async {
    getReplyMessageModel = null;
    final requestBody = {
      "messageId": msgId
    };
    final response = await ApiService.instance.request(endPoint: ApiString.getRepliesMsg, method: Method.POST,reqBody: requestBody);
    if(statusCode200Check(response)){
      getReplyMessageModel = GetReplyMessageModel.fromJson(response);
    }
    notifyListeners();
  }
  Future<void> seenReplayMessage({required String msgId}) async {
    final requestBody = {
      "messageId": msgId
    };
    final response = await ApiService.instance.request(endPoint: ApiString.replayMsgSeen, method: Method.POST,reqBody: requestBody);
  }

  // Future<void> getMessagesList({required String oppositeUserId, bool? needClearFirstTime}) async {
  //   if (lastOpenedUserId != oppositeUserId) {
  //     messageGroups = [];
  //     messageGroups.clear();
  //     userCache.clear();
  //     totalPages = 0;
  //     currentPage = 1;
  //   }
  //   if(needClearFirstTime == true){
  //     totalPages = 0;
  //     currentPage = 1;
  //   }
  //   final response = await ApiService.instance.request(
  //       endPoint: ApiString.getMessages,
  //       method: Method.POST,
  //       reqBody: {
  //         "userId": signInModel.data!.user!.id,
  //         "oppositeUserId": oppositeUserId,
  //         "pageNo": currentPage.toString()
  //       });
  //
  //   if (statusCode200Check(response)) {
  //     messageGroups = (response['data']['messages'] as List).map((message) => MessageGroups.fromJson(message)).toList();
  //     // final newMessages = (response['data']['messages'] as List).map((message) => MessageGroups.fromJson(message)).toList();
  //     // messageGroups.addAll(newMessages);
  //     // final newMessages = (response['data']['messages'] as List).map((message) => MessageGroups.fromJson(message)).toList();
  //     // messageGroups.addAll(newMessages);
  //     totalPages = response['data']['totalPages'];
  //     print("Messages == ${messageGroups.length}");
  //     print("First group == ${messageGroups[0].sId}");
  //     lastOpenedUserId = oppositeUserId;
  //     notifyListeners();
  //   }
  // }
  Future<void> getMessagesList({required String oppositeUserId, bool? needClearFirstTime, bool? storeLatest = true}) async {
    if (lastOpenedUserId != oppositeUserId) {
      messageGroups.clear();
      userCache.clear();
      totalPages = 0;
      currentPage = 1;
    }

    if (needClearFirstTime == true) {
      totalPages = 0;
      currentPage = 1;
    }

    final response = await ApiService.instance.request(
        endPoint: ApiString.getMessages,
        method: Method.POST,
        reqBody: {
            "userId": signInModel.data!.user!.id,
            "oppositeUserId": oppositeUserId,
            "pageNo": currentPage.toString()
          }
    );

    if (statusCode200Check(response)) {
      // if(storeLatest == true){
      //   messageGroups = (response['data']['messages'] as List).map((message) => MessageGroups.fromJson(message)).toList();
      // }else{
      //   final newMessages = (response['data']['messages'] as List).map((message) => MessageGroups.fromJson(message)).toList();
      //   messageGroups.addAll(newMessages);
      // }
      messageGroups = (response['data']['messages'] as List).map((message) => MessageGroups.fromJson(message)).toList();
      totalPages = response['data']['totalPages']; // Update total pages
      print("Messages == ${messageGroups.length}");
      if (messageGroups.isNotEmpty) {
        print("First group == ${messageGroups[0].sId}");
      }
      lastOpenedUserId = oppositeUserId;
      notifyListeners();
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



  Future<void> sendMessage({required dynamic content , required String receiverId, required String senderId, List<String>? files,bool? isEditMessage = false, String? editMsgID})async{
    final requestBody = {
      "content": content,
      "receiverId": receiverId,
      "senderId": senderId
    };
    if(editMsgID != null && editMsgID.isNotEmpty){
      requestBody["isEdit"] = true;
      requestBody["editMessageId"] = editMsgID;
    }else{
      if (files != null && files.isNotEmpty) {
        requestBody["files"] = files;
      }
    }

    final response = await ApiService.instance.request(endPoint: ApiString.sendMessage, method: Method.POST,reqBody: requestBody);
    if(statusCode200Check(response)){
      socketProvider.sendMessagesSC(response:response['data']);
      socketProvider.sendMessagesSC(response:response['data']);
      getMessagesList(oppositeUserId: receiverId);
    }
  }

  Future<void> deleteMessage({required String messageId,required String receiverId})async{
    final response = await ApiService.instance.request(endPoint: ApiString.deleteMessage + messageId, method: Method.DELETE);
    if(statusCode200Check(response)){
      getMessagesList(oppositeUserId: receiverId);
      socketProvider.deleteMessagesSC(response: {"data": response['data']});
    }
  }
  Future<void> pinUnPinMessage({required String receiverId,required String messageId,required bool pinned})async{
    final response = await ApiService.instance.request(endPoint: ApiString.pinMessage(messageId, pinned), method: Method.PUT);
    if(statusCode200Check(response)){
      getMessagesList(oppositeUserId: receiverId);
      socketProvider.pinUnPinMessageEvent(senderId: signInModel.data?.user?.id ?? "", receiverId: receiverId);
    }
  }
}
