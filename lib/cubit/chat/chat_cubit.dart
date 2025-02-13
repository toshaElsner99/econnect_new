import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';
import '../../model/message_model.dart';
import '../../utils/api_service/api_service.dart';
import '../../utils/api_service/api_string_constants.dart';
import '../../utils/common/common_function.dart';

part 'chat_state.dart';

// class ChatCubit extends Cubit<ChatState> {
//   ChatCubit() : super(ChatInitial());
class ChatProvider extends  ChangeNotifier {
  List<MessageGroups> messageGroups = [];
  String? lastOpenedUserId;
  // late final MessageModel messageModel;
  Future<void> getMessagesList(String oppositeUserId) async {
    if (lastOpenedUserId != oppositeUserId) {
      messageGroups.clear();
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
      messageGroups = (response['data']['messages'] as List)
          .map((message) => MessageGroups.fromJson(message))
          .toList();
      print("Messages == ${messageGroups.length}");
      print("First group == ${messageGroups[0].sId}");
      lastOpenedUserId = oppositeUserId;
    }
    notifyListeners();
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
    }
  }
}
