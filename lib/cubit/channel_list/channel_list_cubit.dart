import 'package:bloc/bloc.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:meta/meta.dart';

import '../../main.dart';

part 'channel_list_state.dart';

class ChannelListCubit extends Cubit<ChannelListState> {
  ChannelListCubit() : super(ChannelListInitial());
  
  Future<void> getFavoriteList()async{
    print("userID>>>> ${signInModel.data?.user?.id}");
    final header = {
      'Authorization': "Bearer ${signInModel.data!.authToken}",
    };
    final requestBody = {
      "userId": signInModel.data?.user?.id,
    };
    final response = await ApiService.instance.request(endPoint: ApiString.favoriteListGet, method: Method.POST,headers: header,reqBody: requestBody);
  }
  
  
}
