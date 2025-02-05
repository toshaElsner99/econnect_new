import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';
import '../../model/message_model.dart';
import '../../utils/api_service/api_service.dart';
import '../../utils/api_service/api_string_constants.dart';
import '../../utils/common/common_function.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  List<MessageGroups> messageGroups = [];

  void getMessagesList(String oppositeUserId) async {
    emit(ChatLoading());

    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final response = await ApiService.instance.request(
        endPoint: ApiString.getMessages,
        method: Method.POST,
        headers: header,
        reqBody: {
          "userId": signInModel.data!.user!.id,
          "oppositeUserId": oppositeUserId,
          "pageNo": "1"
        });
    if (statusCode200Check(response)) {
      messageGroups = (response['data']['messages'] as List)
          .map((message) => MessageGroups.fromJson(message))
          .toList();
      print("Messages == ${messageGroups.length}");
      print("First group == ${messageGroups[0].sId}");
      emit(ChatSuccess(messageGroups));
    }
  }
}
