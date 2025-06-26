import 'dart:async';
import 'dart:developer';

import 'package:e_connect/main.dart';
import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/providers/thread_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../providers/channel_list_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/common_provider.dart';
import '../notificationServices/pushNotificationService.dart';
import '../screens/calling/call_screen.dart';
import '../utils/app_preference_constants.dart';
import '../utils/common/prefrance_function.dart';
import '../utils/common/common_function.dart';

class SocketIoProvider extends ChangeNotifier {
  //Old Socket URl
  //static const socketBaseUrl = 'wss://e-connect-socket.elsner.com';

  //New Socket URL
  static final socketBaseUrl =
      'wss://dev-econnect-sass-socket.elsnerdev.co/?userId=${signInModel!.data?.user?.sId}&transport=websocket';
  late IO.Socket socket;

  String connection = "connection";
  String disconnect = "disconnect";
  String joinRoom = "joinRoom";
  String userActivity = "userActivity";
  String notification = "notification";
  String notificationForPinMessagesListen = "pin_notification";
  String notificationForPinMessagesChannelListen = "pin_notification_channel";
  String userTypingGet = "user_typing";
  String notificationForMessageReacting = "msg_reaction";
  String notificationForMessageReactionChannel = "msg_reaction_channel";
  String replyNotification = "reply_notification";
  String getNotification = "get_notification";
  String getUnreadNotification = "get_unread_notification";
  String readNotification = "read_notification";
  String sendMessage = "send_message";
  String pinMessage = "message_pinned";
  String userTyping = "user_typing";
  String messageReaction = "message_reaction";
  String messagePinnedToChannel = "message_pinned_channel";
  String messageReactionToChannel = "message_reaction_channel";
  // String replyNotification = "reply_notification";
  String deleteMessagesEmit = "delete_message_chat";
  String deleteMessageForListen = "deleted_message_chat";
  String deleteMessagesChannelEmit = "delete_message_chat_channel";
  String deleteMessageChannelListen = "deleted_message_channel";
  String addMember = "addMember";
  String channelHeaderMessage = "channelHeader";
  String channelHeaderChannel = "channelHeaderChannel";
  String channelHeaderMessageN = "channelHeaderUpdate";
  String channelHeaderChannelN = "channelHeaderUpdateChannel";
  String userUpdate = "userUpdate";
  String userUpdated = "userUpdated";
  String removeMember = "remove_member";
  String removedMember = "removed_member";
  String leaveMember = "leaveMember";
  String renameChannel = "rename_channel";
  String renameChannelNotification = "rename_channel_notification";
  String channelMemberUpdate = "channel_member_update";
  String channelMemberUpdateNotification = "channel_member_update_notification";
  String sendReplyMessage = "send_reply_message";

  // Calling Feature
  String register = "register";
  String deregister = "deregister";
  String signal = "signal";
  String userBusy = "userBusy";
  String callUser = "callUser";
  String callIncoming = "callIncoming";
  String acceptCall = "acceptCall";
  String callAccepted = "callAccepted";
  String peerMediaToggle = "peer-media-toggle";
  String rejectCall = "rejectCall";
  String callRejected = "callRejected";
  String startScreenShare = "startScreenShare";
  String stopScreenShare = "stopScreenShare";
  String getMediaState = "getMediaState";
  String hangUp = "hangUp";
  String leaveCall = "leaveCall";
  String inActive = "inActive";

  void connectSocket([bool? connectFrom = false]) async {
    final isLoggedIn =
        await getBool(AppPreferenceConstants.isLoginPrefs) ?? false;
    if (connectFrom == true && isLoggedIn == true) {
      print("socket connected >>>> ${socket.active} || ${socket.connected}");
      if (socket.active == true) {
        return;
      }
    }
    socket = IO.io(
      socketBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': signInModel!.data?.user?.sId})
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

    // socket.onAny((event, data) {
    //   // print("connected>>>> ${socket.connected}");
    //   // print("Received event: $event >>> $data");
    // });
    registerUser();
    // Remove duplicate listeners and implement a single optimized handler
    listenForNotifications();
  }

  joinRoomEvent() {
    socket.emit(joinRoom, {
      {'userId': signInModel!.data?.user?.sId}
    });
    socket.on(
      joinRoom,
      (data) => pragma("joinRoomEvent>>>> $data"),
    );
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
  pinUnPinMessageEventSingleChat(
      {required String senderId, required String receiverId}) {
    socket.emit(pinMessage, {"senderId": senderId, "receiverId": receiverId});
  }

  pinUnPinMessageEventChannelChat(
      {required String senderId, required String channelId}) {
    socket.emit(
        messagePinnedToChannel, {"senderId": senderId, "channelId": channelId});
  }

  userTypingEvent(
      {required String oppositeUserId,
      required bool isReplyMsg,
      required int isTyping,
      String msgId = ""}) {
    Map<String, dynamic> data = {
      "senderId": signInModel!.data?.user?.sId ?? "",
      "receiverId": oppositeUserId,
      "inputValue": isTyping,
      "isReply": isReplyMsg,
    };

    if (msgId.isNotEmpty) {
      data["parentId"] = msgId;
    }

    socket.emit(userTyping, data);
  }

  userTypingEventChannel(
      {required String channelId,
      required int isTyping,
      required bool isReplyMsg,
      String msgId = ""}) {
    Map<String, dynamic> data = {
      "senderId": signInModel!.data?.user?.sId ?? "",
      "channelId": channelId,
      "inputValue": isTyping,
      "username": signInModel!.data?.user?.userName ?? "",
      "userId": signInModel!.data?.user?.sId ?? "",
      "isReply": isReplyMsg
    };
    if (msgId.isNotEmpty) {
      data["parentId"] = msgId;
    }
    socket.emit(userTyping, data);
  }

  sendMessagesSC(
      {required Map<String, dynamic> response, bool emitReplyMsg = false}) {
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
    socket.emit(deleteMessagesEmit, response);
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
          listen: false);
      final threadProvider = Provider.of<ThreadProvider>(
          navigatorKey.currentState!.context,
          listen: false);

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
        Provider.of<CommonProvider>(navigatorKey.currentState!.context,
                listen: false)
            .getUserByIDCall();

        NotificationService.setBadgeCount();
      });
    });
    socket.on(replyNotification, (data) {
      print("Received Notification >>> $data");

      // Refresh the list with the latest data
      final channelListProvider = Provider.of<ChannelListProvider>(
          navigatorKey.currentState!.context,
          listen: false);
      final threadProvider = Provider.of<ThreadProvider>(
          navigatorKey.currentState!.context,
          listen: false);

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
        Provider.of<CommonProvider>(navigatorKey.currentState!.context,
                listen: false)
            .getUserByIDCall();

        NotificationService.setBadgeCount();
      });
    });
    // Calling Feature Listeners
    listenSignalForCall();
    getCallFromAnyUser();
    listenHangUpCallEvent();
  }

  /// This is for single chat screen ///
  void listenForSingleChatScreen(
      {required String oppositeUserId, required Function getSecondUserCall}) {
    // Clean up any existing listeners first
    cleanupChatListeners();

    if (!socket.connected) {
      print("⚠️ Socket is not connected. Attempting to reconnect...");
      socket.connect();
    }

    // Set up new listeners
    socket.on(notification, (data) {
      print("listSingleChatScreen >>> $data");
      if (navigatorKey.currentState?.context != null) {
        Provider.of<ChatProvider>(navigatorKey.currentState!.context,
                listen: false)
            .getMessagesList(
                oppositeUserId: oppositeUserId,
                currentPage: 1,
                isFromMsgListen: true,
                onlyReadInChat: false);
      }
    });

    socket.on(deleteMessageForListen, (data) {
      print("deleteMessageForListen >>> $data");
      if (navigatorKey.currentState?.context != null) {
        Provider.of<ChatProvider>(navigatorKey.currentState!.context,
                listen: false)
            .getMessagesList(
                oppositeUserId: oppositeUserId,
                currentPage: 1,
                isFromMsgListen: true,
                onlyReadInChat: false);
      }
    });

    socket.on(notificationForPinMessagesListen, (data) {
      print("listSingleChatScreen >>> $data");
      if (navigatorKey.currentState?.context != null) {
        Provider.of<ChatProvider>(navigatorKey.currentState!.context,
                listen: false)
            .getMessagesList(
                oppositeUserId: oppositeUserId,
                currentPage: 1,
                isFromMsgListen: true,
                onlyReadInChat: false);
        getSecondUserCall.call();
      }
    });

    socket.on(replyNotification, (data) {
      print("listSingleChatScreen >>> $data");
      if (navigatorKey.currentState?.context != null) {
        Provider.of<ChatProvider>(navigatorKey.currentState!.context,
                listen: false)
            .getMessagesList(
                oppositeUserId: oppositeUserId,
                currentPage: 1,
                isFromMsgListen: true,
                onlyReadInChat: false);
      }
    });

    socket.on(notificationForMessageReacting, (data) {
      print("messageReaction >>> $data");
      if (navigatorKey.currentState?.context != null) {
        Provider.of<ChatProvider>(navigatorKey.currentState!.context,
                listen: false)
            .getMessagesList(
                oppositeUserId: oppositeUserId,
                currentPage: 1,
                isFromMsgListen: true,
                onlyReadInChat: false);
      }
    });
  }

  /// This is for channel chat screen ///
  void listenForChannelChatScreen({
    required String channelId,
  }) {
    // Clean up any existing listeners first
    cleanupChatListeners();

    if (!socket.connected) {
      print("⚠️ Socket is not connected. Attempting to reconnect...");
      socket.connect();
    }

    // Set up new listeners
    socket.on(notification, (data) {
      print("listSingleChatScreen >>> $data");
      if (navigatorKey.currentState?.context != null) {
        Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context,
                listen: false)
            .getChannelChatApiCall(
                channelId: channelId,
                pageNo: 1,
                isFromMsgListen: true,
                onlyReadInChat: false);
      }
    });

    socket.on(deleteMessageChannelListen, (data) {
      print("deleteMessageForListen >>> $data");
      if (navigatorKey.currentState?.context != null) {
        Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context,
                listen: false)
            .getChannelChatApiCall(
                channelId: channelId,
                pageNo: 1,
                isFromMsgListen: true,
                onlyReadInChat: false);
      }
    });

    socket.on(notificationForPinMessagesChannelListen, (data) {
      print("listSingleChatScreen >>> $data");
      if (navigatorKey.currentState?.context != null) {
        Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context,
                listen: false)
            .getChannelChatApiCall(
                channelId: channelId,
                pageNo: 1,
                isFromMsgListen: true,
                onlyReadInChat: false);
        Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context,
                listen: false)
            .getChannelInfoApiCall(channelId: channelId, callFroHome: false);
      }
    });

    socket.on(renameChannel, (data) {
      print("listSingleChatScreen >>> $data");
      if (navigatorKey.currentState?.context != null) {
        Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context,
                listen: false)
            .getChannelChatApiCall(
                channelId: channelId,
                pageNo: 1,
                isFromMsgListen: true,
                onlyReadInChat: false);
      }
    });

    socket.on(replyNotification, (data) {
      print("listSingleChatScreen >>> $data");
      if (navigatorKey.currentState?.context != null) {
        Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context,
                listen: false)
            .getChannelChatApiCall(
                channelId: channelId,
                pageNo: 1,
                isFromMsgListen: true,
                onlyReadInChat: false);
      }
    });

    socket.on(notificationForMessageReactionChannel, (data) {
      print("messageReaction >>> $data");
      if (navigatorKey.currentState?.context != null) {
        Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context,
                listen: false)
            .getChannelChatApiCall(
                channelId: channelId,
                pageNo: 1,
                isFromMsgListen: true,
                onlyReadInChat: false);
      }
    });
  }

  void listenDeleteMessageSocketForReply({required String msgId}) {
    socket.off(deleteMessageForListen);
    socket.on(deleteMessageForListen, (data) {
      print("deleteMessageForListen >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
              listen: false)
          .getReplyMessageList(
              msgId: msgId,
              fromWhere: "SOCKET LISTEN FROM DELETED MESSAGE CHAT");
    });
  }

  void listenDeleteMessageSocketForChannelReply({required String msgId}) {
    socket.off(deleteMessageChannelListen);
    socket.on(deleteMessageChannelListen, (data) {
      print("deleteMessageForListen >>> $data");
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context,
              listen: false)
          .getReplyMessageListChannel(
              msgId: msgId,
              fromWhere: "SOCKET LISTEN FROM DELETED MESSAGE CHANNEL");
    });
  }

  /// single Chat reply pin listen ///

  void socketListenPinMessageInReplyScreen({required String msgId}) {
    socket.off(notificationForPinMessagesListen);
    socket.on(notificationForPinMessagesListen, (data) {
      print("listSingleChatScreen >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
              listen: false)
          .getReplyMessageList(
              msgId: msgId, fromWhere: "PIN_MSG_SOCKET_LISTEN_SINGLE_CHAT");
    });
  }

  /// channel Chat reply pin listen ///

  void socketListenPinMessageInChannelReplyScreen({required String msgId}) {
    socket.off(notificationForPinMessagesChannelListen);
    socket.on(notificationForPinMessagesChannelListen, (data) {
      print("listChannelChatScreen >>> $data");
      Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context,
              listen: false)
          .getReplyMessageListChannel(
              msgId: msgId, fromWhere: "PIN_MSG_SOCKET_LISTEN_CHANNEL");
    });
  }

  memberAdminToggleSC({required Map<String, dynamic> response}) {
    log("emit>>>>> memberAdminToggleSC ${"data : $response"}");
    socket.emit(channelMemberUpdate, response);
  }

  listenMemberUpdates({required String channelID}) {
    socket.off(channelMemberUpdateNotification);
    socket.on(
      channelMemberUpdateNotification,
      (data) {
        Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context,
                listen: false)
            .getChannelMembersList(channelID);
      },
    );
  }

  memberRemoveSC({required Map<String, dynamic> response}) {
    log("emit>>>>> memberRemoveSC $response");
    socket.emit(removeMember, response);
  }

  void addMemberToChannel({required Map<String, dynamic> response}) {
    socket.emit(addMember, response);
  }

  reactMessagesSC({required Map<String, dynamic> response}) {
    print("emit>>>>> React Message $response");
    socket.emit(messageReaction, response);
  }

  void socketListenReactMessageInReplyScreen({String? msgId}) {
    socket.off(notificationForMessageReacting);
    socket.on(notificationForMessageReacting, (data) {
      print("notificationForMessageReacting >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
              listen: false)
          .getReplyMessageList(msgId: msgId!, fromWhere: "PIN_MSG_SOCKET");
    });
  }

  reactMessagesInChannelSC({required Map<String, dynamic> response}) {
    print("emit>>>>> reactMessagesInChannelSC $response");
    socket.emit(messageReactionToChannel, response);
  }

  void socketListenReactMessageInChannelReplyScreen({String? msgId}) {
    socket.off(notificationForMessageReactionChannel);
    socket.on(notificationForMessageReactionChannel, (data) {
      print("socketListenReactMessageInChannelReplyScreen  >>> $data");
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
              listen: false)
          .getReplyMessageList(msgId: msgId!, fromWhere: "PIN_MSG_SOCKET");
    });
  }

  void cleanupChatListeners() {
    // Remove all chat-related listeners
    socket.off(notification);
    socket.off(deleteMessageForListen);
    socket.off(notificationForPinMessagesListen);
    socket.off(replyNotification);
    socket.off(notificationForMessageReacting);
    socket.off(deleteMessageChannelListen);
    socket.off(notificationForPinMessagesChannelListen);
    socket.off(renameChannel);
    socket.off(notificationForMessageReactionChannel);
    socket.off("reply_notification");
    socket.off("user_typing");
  }

  /// Calling Feature Methods ///

  registerUser() {
    print("registerUser");
    socket.emit(register, signInModel!.data?.user?.sId);
    socket.on(register, (data) {
      print("User registered to socket >>> $data");
    });
  }

  deRegisterUser() {
    socket.emit(deregister, signInModel!.data?.user?.sId);
    socket.off(deregister);
    print("User deregistered from socket");
  }

  void sendSignalForCall(
      String callToUserId, dynamic description, dynamic offer) {
    bool isBusy = checkUserIsBusyOrNot(callToUserId) ?? false;
    // If the user is available for call
    if (!isBusy) {
      print("User is available for call");
      socket.off(signal);
      // Emit the signal event to the server with the SDP description
      socket.emit(signal, {"toUserId": callToUserId, "data": description});
      print("sendSignalForCall");

      // Start the call by emitting the callUser event
      callAnyUser(
        callToUserId,
        signInModel!.data!.user!.sId!,
        signInModel!.data!.user!.fullName ??
            signInModel!.data!.user!.userName ??
            '',
        offer,
      );
    } else {
      // User is busy, show a popup and pop the current screen
      print("User is busy, cannot accept call");
      Navigator.of(navigatorKey.currentState!.context).pop();
      Cf.showCommonDialog(
        navigatorKey.currentState!.context,
        "User Busy",
        "User is busy, cannot accept call",
      );
      //  emit a hangup event
    }
  }

  // Enhanced signal listening for both SDP and ICE candidates
  void listenSignalForCall([Function(dynamic)? callback]) {
    socket.off(signal);
    socket.on(signal, (data) {
      print("Signal received >>> $data");

      if (data != null && data['data'] != null) {
        if (data['data']['type'] == 'offer' || data['data']['type'] == 'answer') {
          // Handle SDP offer/answer
          print("📞 Received SDP ${data['data']['type']}");

          // Call the callback if provided
          if (callback != null) {
            callback(data);
          }
        } else if (data['data']['type'] == 'candidate') {
          // Handle ICE candidate
          print("🧊 Received ICE candidate");

          // Call the callback if provided
          if (callback != null) {
            callback(data);
          }
        }
      }
    });
  }

  callAnyUser(String callToUserId, String callFromUserId,
      String callFromUserName, RTCSessionDescription offer) {
    socket.emit(callUser, {
      "toUserId": callToUserId,
      "fromUserId": callFromUserId,
      "signal": offer.toMap(),
      "discussionId": callToUserId,
      "name": callFromUserName,
      "cameraOn": false,
      "micOn": true
    });
    print(
        "Done Emitting Audio Call User >>> $callToUserId, $callFromUserId, $callFromUserName, ${offer.sdp}, ${offer.type}");
  }

  getCallFromAnyUser() {
    socket.off(callIncoming);
    socket.on(callIncoming, (data) {
      print("Call Incoming >>> $data");
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            dataOfSocket: data,
              callerName: 'John Doe',
              callerId: data['fromUserId'],
              imageUrl:
                  'https://t3.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg',
              callDirection: CallDirection.incoming,
              ),
        ),
      );
      // Handle incoming call data
      // You can show a dialog or navigate to a call screen here
    });
  }

  bool? checkUserIsBusyOrNot(String callToUserId) {
    socket.off(userBusy);
    socket.on(userBusy, (data) {
      print("Is userBusy >>> $data");
      print("callToUserId >>> $callToUserId");

      if (data['toUserId'] == callToUserId) {
        return false;
      } else {
        return true;
      }
    });
  }

  hangUpCallEvent({required String targetId,required String whoHangUpCallId}) {
    socket.emit(
        hangUp, {"toUserId": targetId, "oppositeUserId": whoHangUpCallId});
    print("hangUpCallEvent");
  }

  leaveCallEvent({required String callToUserId,required String callFromUserId}){
    socket.emit(leaveCall, {"userId": callFromUserId, "otherUserID": callToUserId});
    print("User left the call");
  }

  listenHangUpCallEvent(){
    socket.off(hangUp);
    socket.on(hangUp, (data) {
      print("Hang up call event received >>> $data");
      Navigator.of(navigatorKey.currentState!.context).pop();
    });
  }

  acceptCallEvent({required String callToUserId,required dynamic signal}) {
    socket.emit(acceptCall, {
      'toUserId' : callToUserId,
      'signal': signal, //answer - which is created by webrtc ~ createAnswer()
      'discussion': callToUserId
    });
    print("acceptCallEvent Emitted");
  }

  listenAcceptedCallEvent([Function(dynamic)? callback]) {
    socket.on(callAccepted, (data){
      print("callAccepted Listened = $data");

      // Handle the call accepted event - both users should now be connected
      if (data != null && data['signal'] != null) {
        // For the caller (outgoing call), set the remote description with the answer
        // This completes the WebRTC handshake
        print("Call accepted - setting remote description with answer");

        // Call the callback if provided
        if (callback != null) {
          callback(data);
        }

        // You can access the current call screen context here if needed
        // For now, we'll just log the successful connection
        print("✅ Call connection established between both users");
      }
    });
  }


}
