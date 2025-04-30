import 'package:e_connect/model/searchMessages.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:flutter/cupertino.dart';

import '../utils/common/common_function.dart';

class SearchMessageProvider extends ChangeNotifier{
  List<SearchMessage> messageGroups = [];
  bool isLoading = false;

  Future<void> browseAndSearchMessages({required String search}) async {
    messageGroups.clear();
    notifyListeners();
    final requestBody = {
      "search": search
    };
    print("Request $requestBody");
    try{
      final response = await ApiService.instance.request(endPoint: ApiString.searchMessages, method: Method.POST, reqBody: requestBody,needLoader: true);
      if (Cf.instance.statusCode200Check(response)) {
        print("Response>> $response");

        messageGroups.clear();
        messageGroups.addAll((response['data'] as List).map((message) {
          return SearchMessage.fromJson(message);
        }).toList());
      }
    }catch (e){
      print("eroor>> $e");
    }finally {
      notifyListeners();
    }
  }

  Future<int> getPageNumber({required String messageId,required String senderId,required String? receiverId,required bool isForChannel,required String? channelId}) async {
    notifyListeners();

    dynamic requestBody;
    if(isForChannel){
      requestBody = {
        "messageId": messageId,
        "senderId": senderId,
        "channelId": channelId
      };}else{
      requestBody = {
        "messageId": messageId,
        "senderId": senderId,
        "receiverId": receiverId
      };
    }
    print("Request $requestBody");
    try{
      final response = await ApiService.instance.request(endPoint: ApiString.messageJump, method: Method.POST, reqBody: requestBody,needLoader: true);
      if (Cf.instance.statusCode200Check(response)) {
        print("Response>> $response");

        return response['data']['pageNumber'];
      }
    }catch (e){
      print("eroor>> $e");
    }finally {
      notifyListeners();
    }
    return 0;

  }
}