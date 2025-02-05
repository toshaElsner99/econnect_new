import 'package:socket_io_client/socket_io_client.dart' as IO;

class ApiString{

  static const String baseUrl = 'https://e-connect.elsner.com/v1/'; /// THIS LIVE URL
  // static const String baseUrl= 'https://dev-econnect.elsnerdev.co/v1/'; /// THIS DEVELOPMENT URL
  static const String profileBaseUrl = 'https://e-connect.elsner.com/public/'; /// Profile Image

  static const socketBaseUrl = 'wss://dev-econnect-socket.elsnerdev.co/socket.io';
  static IO.Socket? socket;



  /// End Point , Don't Change Belows End Point until didn't confirm through backend ///
  static const login = "user/login";
  static const updateStatus = "user/update";
  static const getUserById = "user/getUserById";
  static const favoriteListGet = "favouriteLists/get";
  static const channelList = "channels/get";
  static const directMessageChatList = "chatList/get";
  static const createChannel = "channels/add";
  static const browseChannel = "user/search-user-channel";
  static const removeFromFavorite = "favouriteLists/removeFromFavourite";
  static const muteUser = "user/mute-user";
  static const unMuteUser = "user/unmute-user";
  static const closeConversation = "chatList/close-conversation";
  static const messageUnread = "messages/message-unread/";
  static const messageSeen = "messages/message-seen/";
  static const addTOFavorite = "favouriteLists/add";
  static const leaveChannel = "channels/leaveChannel/";
  static const userSuggestions = "user/user-suggestions";
  static const searchUser = "user/search-user";

  // Chat
  static const getMessages = "messages/get-message";

}