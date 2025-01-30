import 'package:e_connect/cubit/channel_list/channel_list_cubit.dart';
import 'package:e_connect/cubit/common_cubit/common_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../utils/api_service/api_string_constants.dart';
import '../chat/single_chat_message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  final channelListCubit = ChannelListCubit();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    channelListCubit.getFavoriteList();
    connect();
  }
  connect() {
    ApiString.socket = IO.io(ApiString.socketBaseUrl, <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });

    ApiString.socket?.connect();
    ApiString.socket?.onConnect((data) {
      print('Socket-ID:------->${ApiString.socket?.id}');
      print('connectivity :---->${ApiString.socket?.connected}');
    });
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SingleChatScreen()),
              );
            },
            child: Text("CHAT")),
      )
    );
  }
}
