import 'dart:developer';

import 'package:e_connect/main.dart';
import 'package:e_connect/providers/channel_chat_provider.dart';
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
  String notificationForPinMessagesListen = "pin_notification";
  String notificationForPinMessagesChannelListen = "pin_notification_channel";
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
  String deleteMessagesEmit = "delete_message_chat";
  String deleteMessageForListen = "deleted_message_chat";
  String deleteMessagesChannelEmit = "delete_message_chat_channel";
  String deleteMessageChannelListen = "deleted_message_channel";
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


  // pinUnPinMessageEvent({required String senderId,required String receiverId,required isEmitForChannel}){
  //   pragma("pinUnPinMessageEvent>>>>Called");
  //   if(isEmitForChannel == false){
  //     socket.emit(pinMessage,{{"senderId": senderId,"receiverId": receiverId}});
  //     socket.on(pinMessage, (data) => print("pinUnPinMessageEvent>>>> $data"),);
  //   }else{
  //
  //     socket.emit(messagePinnedToChannel,{{"senderId": senderId,"channelId": receiverId}});
  //     socket.on(messagePinnedToChannel, (data) => print("pinUnPinMessageEvent>>>> $data"),);
  //   }
  // }
  pinUnPinMessageEventSingleChat({required String senderId,required String receiverId}){
    socket.emit(pinMessage,{"senderId": senderId,"receiverId": receiverId});
  }

  pinUnPinMessageEventChannelChat({required String senderId,required String channelId}){
    socket.emit(messagePinnedToChannel,{"senderId": senderId,"channelId": channelId});
  }


  userTypingEvent({required String oppositeUserId, required bool isReplyMsg,required int isTyping}){
    print("CALLLED_userTypingEvent>>>>>>> ");
    socket.emit(userTyping,{"senderId": signInModel.data?.user?.id ?? "","receiverId": oppositeUserId,"inputValue":isTyping,"isReply":isReplyMsg});
  }

  sendMessagesSC({required Map<String, dynamic> response,bool emitReplyMsg = false}) {
    print("emit>>>>> Send Message $response");
    socket.emit(emitReplyMsg ? sendReplyMessage : sendMessage, response);
    // socket.on(  emitReplyMsg ? sendReplyMessage : sendMessage, (data) {
    //   print("sendReplyMessage>>>>>DD $data");
    // },);
  }

  deleteMessagesSC({required Map<String, dynamic> response}) {
    print("emit>>>>> Delete Message $response");
    socket.emit(deleteMessagesEmit , response);
  }

  deleteMessagesFromChannelSC({required Map<String, dynamic> response}) {
    print("emit>>>>> Delete Message $response");
    socket.emit(deleteMessagesChannelEmit, response);
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


  void listenSingleChatScreen({required String oppositeUserId,required Function getSecondUserCall}) {
    if (!socket.connected) {
      print("⚠️ Socket is not connected. Attempting to reconnect...");
      socket.connect();
    }
    socket.off(deleteMessageForListen);
    socket.on((deleteMessageForListen), (data) {
      print("deleteMessageForListen >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getMessagesList(oppositeUserId: oppositeUserId,currentPage: 1, isFromMsgListen: true);
    });
    socket.off(notification);
    socket.on(notification, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getMessagesList(oppositeUserId: oppositeUserId,currentPage: 1,isFromMsgListen: true);
    });
    socket.off(notificationForPinMessagesListen);
    socket.on(notificationForPinMessagesListen, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getMessagesList(oppositeUserId: oppositeUserId,currentPage: 1,isFromMsgListen: true);
      getSecondUserCall.call();
    });
    socket.off(replyNotification);
    socket.on(replyNotification, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getMessagesList(oppositeUserId: oppositeUserId,currentPage: 1,isFromMsgListen: true);
    });
    socket.off(notificationForMessageReacting);
    socket.on(notificationForMessageReacting, (data) {
      print("messageReaction >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getMessagesList(oppositeUserId: oppositeUserId,currentPage: 1,isFromMsgListen: true);
    });
  }

  void listenChannelChatScreen({required String channelId,}) {
    socket.off(notification);
    socket.off(deleteMessageChannelListen);
    socket.off(notificationForPinMessagesChannelListen);
    socket.off(renameChannel);
    if (!socket.connected) {
      print("⚠️ Socket is not connected. Attempting to reconnect...");
      socket.connect();
    }
    socket.on(notification, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false).getChannelChatApiCall(channelId: channelId,pageNo: 1,isFromMsgListen: true);
    });

    socket.on((deleteMessageChannelListen), (data) {
      print("deleteMessageForListen >>> $data");
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false).getChannelChatApiCall(channelId: channelId,pageNo: 1,isFromMsgListen: true);
    });

    socket.on(notificationForPinMessagesChannelListen, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false).getChannelChatApiCall(channelId: channelId,pageNo: 1,isFromMsgListen: true);
    });
    socket.on(renameChannel, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false).getChannelInfoApiCall(channelId: channelId,callFroHome: false);
    });

    socket.off(replyNotification);
    socket.on(replyNotification, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false).getChannelChatApiCall(channelId: channelId,pageNo: 1,isFromMsgListen: true);
    });

    socket.off(notificationForMessageReactionChannel);
    socket.on(notificationForMessageReactionChannel, (data) {
      print("socketListenReactMessageInChannelScreen >>> $data");
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false).getChannelChatApiCall(channelId: channelId,pageNo: 1,isFromMsgListen: true);

    });
  }
  void commonListenForChats({
    required String id,
    required bool isSingleChat,
    Function? getSecondUserCall,
  }) {
    if (!socket.connected) {
      print("⚠️ Socket is not connected. Attempting to reconnect...");
      socket.connect();
    }

    // Common socket events
    Map<String, Function(dynamic)> eventHandlers = {
      deleteMessageForListen: (data) {
        print("deleteMessageForListen >>> $data");
        _getChatMessages(id, isSingleChat);
      },
      notification: (data) {
        print("listChatScreen >>> $data");
        _getChatMessages(id, isSingleChat);
      },
      notificationForPinMessagesListen: (data) {
        print("listChatScreen >>> $data");
        _getChatMessages(id, isSingleChat);
        getSecondUserCall?.call();
      },
      replyNotification: (data) {
        print("listChatScreen >>> $data");
        _getChatMessages(id, isSingleChat);
      },
      notificationForMessageReacting: (data) {
        print("messageReaction >>> $data");
        _getChatMessages(id, isSingleChat);
      },
      renameChannel: (data) {
        if (!isSingleChat) {
          print("renameChannel >>> $data");
          Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false)
              .getChannelInfoApiCall(channelId: id, callFroHome: false);
        }
      }
    };

    // Off and On for each event
    eventHandlers.forEach((event, handler) {
      socket.off(event);
      socket.on(event, handler);
    });
  }

  void _getChatMessages(String id, bool isSingleChat) {
    if (isSingleChat) {
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false)
          .getMessagesList(oppositeUserId: id, currentPage: 1, isFromMsgListen: true);
    } else {
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false)
          .getChannelChatApiCall(channelId: id, pageNo: 1, isFromMsgListen: true);
    }
  }



  void listenDeleteMessageSocketForReply({required String msgId}){
    socket.off(deleteMessageForListen);
    socket.on((deleteMessageForListen), (data) {
      print("deleteMessageForListen >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,listen: false).getReplyMessageList(msgId: msgId, fromWhere: "SOCKET LISTEN FROM DELETED MESSAGE CHAT");
    });
  }
 void  listenDeleteMessageSocketForChannelReply({required String msgId}){
   socket.off(deleteMessageChannelListen);
   socket.on((deleteMessageChannelListen), (data) {
     print("deleteMessageForListen >>> $data");
     Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context,listen: false).getReplyMessageListChannel(msgId: msgId, fromWhere: "SOCKET LISTEN FROM DELETED MESSAGE CHANNEL");
   });
 }


/// single Chat reply pin listen ///

  void socketListenPinMessageInReplyScreen({required String msgId }){
    socket.off(notificationForPinMessagesListen);
    socket.on(notificationForPinMessagesListen, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getReplyMessageList(msgId: msgId!, fromWhere: "PIN_MSG_SOCKET_LISTEN_SINGLE_CHAT");
    });
  }
  /// channel Chat reply pin listen ///

  void socketListenPinMessageInChannelReplyScreen({required String msgId }){
    socket.off(notificationForPinMessagesChannelListen);
    socket.on(notificationForPinMessagesChannelListen, (data) {
      print("listChannelChatScreen >>> $data");
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false).getReplyMessageListChannel(msgId: msgId, fromWhere: "PIN_MSG_SOCKET_LISTEN_CHANNEL");
    });
  }

  memberAdminToggleSC({required Map<String, dynamic> response}) {
    log("emit>>>>> memberAdminToggleSC ${"data : $response"}");
    socket.emit(channelMemberUpdate,response);


  }
  listenMemberUpdates({required String channelID}){
    socket.off(channelMemberUpdateNotification);
    socket.on(channelMemberUpdateNotification, (data) {
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false).getChannelMembersList(channelID);
    },);
  }

  memberRemoveSC({required Map<String, dynamic> response}) {
    log("emit>>>>> memberRemoveSC $response");
    socket.emit(removeMember, response);
  }

  void addMemberToChannel({required Map<String, dynamic> response}){
    socket.emit(addMember,response);
  }

  reactMessagesSC({required Map<String, dynamic> response}) {
    print("emit>>>>> React Message $response");
    socket.emit(messageReaction , response);
  }

  void socketListenReactMessageInReplyScreen({String? msgId }){
    socket.off(notificationForMessageReacting);
    socket.on(notificationForMessageReacting, (data) {
      print("notificationForMessageReacting >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getReplyMessageList(msgId: msgId!, fromWhere: "PIN_MSG_SOCKET");
    });
  }

  reactMessagesInChannelSC({required Map<String, dynamic> response}) {
    print("emit>>>>> reactMessagesInChannelSC $response");
    socket.emit(messageReactionToChannel , response);
  }

  void socketListenReactMessageInChannelReplyScreen({String? msgId }){
    socket.off(notificationForMessageReactionChannel);
    socket.on(notificationForMessageReactionChannel, (data) {
      print("socketListenReactMessageInChannelReplyScreen  >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getReplyMessageList(msgId: msgId!, fromWhere: "PIN_MSG_SOCKET");
    });
  }
}