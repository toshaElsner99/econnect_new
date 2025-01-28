import 'package:bloc/bloc.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/utils/api_service/api_service.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:meta/meta.dart';

part 'common_state.dart';

class CommonCubit extends Cubit<CommonState> {
  CommonCubit() : super(CommonInitial());


  Future<void> updateStatusCall({required String status})async{
    final requestBody = {
      "status": status,
      "user_id": signInModel.data?.user?.id,
    };
    final header = {
      'Authorization': "Bearer ${signInModel.data?.authToken}",
      'Content-Type': 'application/json'
    };
    final response = await ApiService.instance.request(endPoint: ApiString.updateStatus, method: Method.POST,reqBody: requestBody,headers: header);
  }
}
