

class ApiString{

  static const String baseUrl = 'https://e-connect.elsner.com/v1/'; /// THIS LIVE URL
  // static const String baseUrl= 'https://dev-econnect.elsnerdev.co/v1/'; /// THIS DEVELOPMENT URL
  static const String profileBaseUrl = 'https://e-connect.elsner.com/public/'; /// Profile Image






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
  static const removeFromChannelFromFavorite = "favouriteLists/channel/remove/";
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
  static const readChannelMessage = "messages/channel/channel-message-seen/";
  static const unReadChannelMessage = "channels/message-unread/";
  static const addChannelTOFavorite = "favouriteLists/channel/add/";
  static const unMuteChannel = "user/unmute-channel";
  static const muteChannel = "user/mute-channel";
  static const addUserToChatList = "chatList/add";
  static const sendMessage = "messages/send-message";
  static const sendChannelMessage = "messages/channel/send-message";
  static const deleteMessage = "messages/delete/";
  static const replayMsgSeen = "messages/reply-message-seen";
  static const getRepliesMsg = "messages/get-replies";
  static const uploadFileForMessageMedia = "files/upload?file_for=message_media";
  static const getFileListingInChat = "messages/getFilesListing";
  static const getUser = "/user/getUsers";
  static String pinMessage(String messageId, bool pinned) => "messages/message-pin/$messageId/$pinned";
  // static const getRepliesMsg = "messages/get-replies";
  // Channel
  static getChannelMembersList(String channelId) => "/channels/getChannelMembers/$channelId";
  static addMembersToChannel(String channelId) => "/channels/addMember/$channelId";

}