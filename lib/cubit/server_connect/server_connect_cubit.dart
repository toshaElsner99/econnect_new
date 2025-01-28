import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part 'server_connect_state.dart';

class ServerConnectCubit extends Cubit<ServerConnectState> {
  ServerConnectCubit() : super(ServerConnectInitial());
  
  final serverUrlController = TextEditingController();
  final displayNameController = TextEditingController();
}
