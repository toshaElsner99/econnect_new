import 'dart:async';
import 'dart:developer';

import 'package:e_connect/main.dart';
import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/providers/thread_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../providers/channel_list_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/common_provider.dart';
import '../notificationServices/pushNotificationService.dart';

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


  void connectSocket([bool? connectFrom = false]) {
    if(connectFrom == true){
      print("socket connected >>>> ${socket.active} || ${socket.connected}");
      if (socket.active == true) {
        return;
      }
    }
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

    // Remove duplicate listeners and implement a single optimized handler
    listenForNotifications();
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


  userTypingEvent({
    required String oppositeUserId,
    required bool isReplyMsg,
    required int isTyping,
    String msgId = ""
  }) {
    print("CALLLED_userTypingEvent>>>>>>>");

    Map<String, dynamic> data = {
      "senderId": signInModel.data?.user?.id ?? "",
      "receiverId": oppositeUserId,
      "inputValue": isTyping,
      "isReply": isReplyMsg,
    };

    if (msgId.isNotEmpty) {
      data["parentId"] = msgId;
    }

    socket.emit(userTyping, data);
  }


  userTypingEventChannel({required String channelId,required int isTyping, required bool isReplyMsg,String msgId = ""}){
    print("CALLLED_userTypingEventChannel>>>>>>> ");
    Map<String, dynamic> data = {
      "senderId": signInModel.data?.user?.id ?? "",
      "channelId": channelId,
      "inputValue":isTyping,
      "username": signInModel.data?.user?.username ?? "",
      "userId": signInModel.data?.user?.id ?? "",
      "isReply":isReplyMsg
    };
    if (msgId.isNotEmpty) {
      data["parentId"] = msgId;
    }
    socket.emit(userTyping,data);
  }

  sendMessagesSC({required Map<String, dynamic> response,bool emitReplyMsg = false}) {
    print("emit>>>>> Send Message $response");
    // print("emit>>>>> For reply $emitReplyMsg");
    String a = emitReplyMsg ? sendReplyMessage : sendMessage;
    print("emit>>>>> For reply $a");
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
    // Remove any existing listeners to avoid duplicates
    socket.off(notification);
    
    socket.on(notification, (data) {
      print("Received Notification >>> $data");
      
      // Refresh the list with the latest data
      final channelListProvider = Provider.of<ChannelListProvider>(
        navigatorKey.currentState!.context, 
        listen: false
      );
      final threadProvider = Provider.of<ThreadProvider>(
          navigatorKey.currentState!.context,
          listen: false
      );
      
      // Explicitly refresh all lists in sequence to ensure we have the latest data with timestamps
      print("Socket notification received - refreshing lists...");
      
      // Make sure all lists are refreshed before combining
      Future.wait([
        channelListProvider.getFavoriteList(),
        channelListProvider.getChannelList(),
        channelListProvider.getDirectMessageList(),
         threadProvider.fetchUnreadThreads(),
          threadProvider.fetchUnreadThreadCount()
      ]).then((_) {
        // Explicitly combine lists after all data is fetched to ensure proper sorting
        channelListProvider.combineAllLists();
        print("All lists refreshed and combined after socket notification");
        
        // Also update user data and badge count
        Provider.of<CommonProvider>(
          navigatorKey.currentState!.context,
          listen: false
        ).getUserByIDCall();
        
        NotificationService.setBadgeCount();
      });
    });
    socket.on(replyNotification, (data) {
      print("Received Notification >>> $data");

      // Refresh the list with the latest data
      final channelListProvider = Provider.of<ChannelListProvider>(
        navigatorKey.currentState!.context,
        listen: false
      );
      final threadProvider = Provider.of<ThreadProvider>(
          navigatorKey.currentState!.context,
          listen: false
      );

      // Explicitly refresh all lists in sequence to ensure we have the latest data with timestamps
      print("Socket notification received - refreshing lists...");

      // Make sure all lists are refreshed before combining
      Future.wait([
        channelListProvider.getFavoriteList(),
        channelListProvider.getChannelList(),
        channelListProvider.getDirectMessageList(),
         threadProvider.fetchUnreadThreads(),
          threadProvider.fetchUnreadThreadCount()
      ]).then((_) {
        // Explicitly combine lists after all data is fetched to ensure proper sorting
        channelListProvider.combineAllLists();
        print("All lists refreshed and combined after socket notification");

        // Also update user data and badge count
        Provider.of<CommonProvider>(
          navigatorKey.currentState!.context,
          listen: false
        ).getUserByIDCall();

        NotificationService.setBadgeCount();
      });
    });
  }

  /// This is for single chat screen ///
  void listenForSingleChatScreen({required String oppositeUserId,required Function getSecondUserCall}) {
    socket.off(notification);
    socket.off(deleteMessageForListen);
    socket.off(notificationForPinMessagesListen);
    socket.off(replyNotification);
    socket.off(notificationForMessageReacting);
    if (!socket.connected) {
      print("⚠️ Socket is not connected. Attempting to reconnect...");
      socket.connect();
    }

    socket.on(notification, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getMessagesList(oppositeUserId: oppositeUserId,currentPage: 1,isFromMsgListen: true,onlyReadInChat: false);
    });

    socket.on((deleteMessageForListen), (data) {
      print("deleteMessageForListen >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getMessagesList(oppositeUserId: oppositeUserId,currentPage: 1, isFromMsgListen: true,onlyReadInChat: false);
    });

    socket.on(notificationForPinMessagesListen, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getMessagesList(oppositeUserId: oppositeUserId,currentPage: 1,isFromMsgListen: true,onlyReadInChat: false);
      getSecondUserCall.call();
    });

    socket.on(replyNotification, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getMessagesList(oppositeUserId: oppositeUserId,currentPage: 1,isFromMsgListen: true,onlyReadInChat: false);
    });

    socket.on(notificationForMessageReacting, (data) {
      print("messageReaction >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getMessagesList(oppositeUserId: oppositeUserId,currentPage: 1,isFromMsgListen: true,onlyReadInChat: false);
    });
  }
  /// This is for channel chat screen ///
  void listenForChannelChatScreen({required String channelId,}) {
    socket.off(notification);
    socket.off(deleteMessageChannelListen);
    socket.off(notificationForPinMessagesChannelListen);
    socket.off(renameChannel);
    socket.off(replyNotification);
    socket.off(notificationForMessageReactionChannel);
    if (!socket.connected) {
      print("⚠️ Socket is not connected. Attempting to reconnect...");
      socket.connect();
    }

    socket.on(notification, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false).getChannelChatApiCall(channelId: channelId, pageNo: 1, isFromMsgListen: true,onlyReadInChat: false);
    });

    socket.on((deleteMessageChannelListen), (data) {
      print("deleteMessageForListen >>> $data");
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false).getChannelChatApiCall(channelId: channelId, pageNo: 1, isFromMsgListen: true,onlyReadInChat: false);
    });

    socket.on(notificationForPinMessagesChannelListen, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false).getChannelChatApiCall(channelId: channelId, pageNo: 1, isFromMsgListen: true,onlyReadInChat: false);
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false).getChannelInfoApiCall(channelId: channelId, callFroHome: false);
    });

    socket.on(renameChannel, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false).getChannelChatApiCall(channelId: channelId, pageNo: 1, isFromMsgListen: true,onlyReadInChat: false);
    });

    socket.on(replyNotification, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false).getChannelChatApiCall(channelId: channelId, pageNo: 1, isFromMsgListen: true,onlyReadInChat: false);
    });

    socket.on(notificationForMessageReactionChannel, (data) {
      print("messageReaction >>> $data");
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context, listen: false).getChannelChatApiCall(channelId: channelId, pageNo: 1, isFromMsgListen: true,onlyReadInChat: false);
    });
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
      Provider.of<ChatProvider>(navigatorKey.currentState!.context, listen: false).getReplyMessageList(msgId: msgId, fromWhere: "PIN_MSG_SOCKET_LISTEN_SINGLE_CHAT");
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