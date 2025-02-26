import 'package:e_connect/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../providers/channel_list_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/common_provider.dart';
class SocketIoProvider extends ChangeNotifier{


  static const socketBaseUrl = 'wss://e-connect-socket.elsner.com';
  late IO.Socket socket;

  String connection = "connection";
  String disconnect = "disconnect";
  String joinRoom = "joinRoom";
  String userActivity = "userActivity";
  String notification = "notification";
  String notificationForPinMessages = "pin_notification";
  String notificationForPinMessagesChannel= "pin_notification_channel";
  String userTypingGet= "user_typing";
  String notificationForMessageReacting= "msg_reaction";
  String notificationForMessageReactionChannel= "msg_reaction_channel";
  String replyNotification= "reply_notification";
  String getNotification= "get_notification";
  String getUnreadNotification= "get_unread_notification";
  String readNotification= "read_notification";
  String sendMessage = "send_message";
  String callInitial = "call_initiated";
  String callReceived = "call_received";
  String pinMessage = "message_pinned";
  String userTyping = "user_typing";
  String messageReaction = "message_reaction";
  String messagePinnedToChannel= "message_pinned_channel";
  String messageReactionToChannel= "message_reaction_channel";
  // String replyNotification = "reply_notification";
  String deleteMessages = "delete_message_chat";
  String deleteMessageForListen = "deleted_message_chat";
  String deleteMessagesChannel = "delete_message_chat_channel";
  String deleteMessageChannel = "deleted_message_channel";
  String addMember = "addMember";
  String channelHeaderMessage = "channelHeader";
  String channelHeaderChannel = "channelHeaderChannel";
  String channelHeaderMessageN= "channelHeaderUpdate";
  String channelHeaderChannelN= "channelHeaderUpdateChannel";
  String userUpdate= "userUpdate";
  String userUpdated= "userUpdated";
  String removeMember= "remove_member";
  String removedMember= "removed_member";
  String leaveMember= "leaveMember";
  String renameChannel= "rename_channel";
  String renameChannelNotification= "rename_channel_notification";
  String channelMemberUpdate= "channel_member_update";
  String channelMemberUpdateNotification= "channel_member_update_notification";
  String sendReplyMessage = "send_reply_message";


  void connectSocket() {
    socket = IO.io(
      socketBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': signInModel.data?.user?.id})
          .enableAutoConnect()
          .build(),
    );

    socket.connect();
    print("Attempting to connect...");

    socket.onConnect((_) {
      print('Connected to socket server >>> ${socket.connected}, ${socket.id}');
      joinRoomEvent();
      listenForNotifications();
    });

    socket.onError((data) {
      print('Socket Error: $data');
    });

    socket.onDisconnect((data) {
      print('Disconnected from socket server $data');
    });

    socket.onConnectError((data) {
      print('Connection Error: $data');
    });

    socket.onReconnect((attempt) {
      print('Reconnected after $attempt attempts');
    });

    socket.onAny((event, data) {
      print("connected>>>> ${socket.connected}");
      print("Received event: $event >>> $data");
    });
  }

  joinRoomEvent(){
    socket.emit(joinRoom,{{'userId': signInModel.data?.user?.id}});
    socket.on(joinRoom, (data) => pragma("joinRoomEvent>>>> $data"),);
  }

  pinUnPinMessageEvent({required String senderId,required String receiverId}){
    pragma("pinUnPinMessageEvent>>>>Called");
    socket.emit(pinMessage,{{"senderId": senderId,"receiverId": receiverId}});
    socket.on(pinMessage, (data) => print("pinUnPinMessageEvent>>>> $data"),);
  }

  userTypingEvent({required String oppositeUserId, required bool isReplyMsg,required int isTyping}){
    print("CALLLED_userTypingEvent>>>>>>> ");
    socket.emit(userTyping,{"senderId": signInModel.data?.user?.id ?? "","receiverId": oppositeUserId,"inputValue":isTyping,"isReply":isReplyMsg});
  }

  sendMessagesSC({required Map<String, dynamic> response,bool? emitReplyMsg = false}) {
    print("emit>>>>> Send Message $response");
    socket.emit(sendReplyMessage, response);
    socket.on(sendReplyMessage, (data) {
      print("sendReplyMessage>>>>>DD $data");
    },);
    socket.emit(sendMessage, response);
    // if(emitReplyMsg == true){
    // }
  }

  deleteMessagesSC({required Map<String, dynamic> response}) {
    print("emit>>>>> Send Message $response");
    socket.emit(deleteMessages, response);
  }

  void listenForNotifications() {
    socket.on(notification, (data) {
      print("Received Notification >>> $data");
      Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false).getUserByIDCall();
      Provider.of<ChannelListProvider>(navigatorKey.currentState!.context,listen: false).getFavoriteList();
      Provider.of<ChannelListProvider>(navigatorKey.currentState!.context,listen: false).getChannelList();
      Provider.of<ChannelListProvider>(navigatorKey.currentState!.context,listen: false).getDirectMessageList();
    });
  }

  void listenSingleChatScreen({required String oppositeUserId,}) {
    if (!socket.connected) {
      print("⚠️ Socket is not connected. Attempting to reconnect...");
      socket.connect();
    }
    socket.on((deleteMessageForListen), (data) {
      print("deleteMessageForListen >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getMessagesList(oppositeUserId: oppositeUserId,/*callingFromSC: true*/);
    });
    socket.on(notification, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getMessagesList(oppositeUserId: oppositeUserId,/*callingFromSC: true*/);
    });
  }


  void socketListenPinMessage({required Function callFun , required String oppositeUserId}){
    socket.on(notificationForPinMessages, (data) {
      print("listSingleChatScreen >>> $data");
        Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getMessagesList(oppositeUserId: oppositeUserId,);
      callFun.call();
    });
  }
  void socketListenPinMessageInReplyScreen({String? msgId }){
    socket.off(notificationForPinMessages);
    socket.on(notificationForPinMessages, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getReplyMessageList(msgId: msgId!, fromWhere: "PIN_MSG_SOCKET");
    });
  }

}