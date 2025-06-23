

class ApiString{



  static const String baseUrl= 'https://dev-econnect-sass.elsnerdev.co/v1/'; /// THIS NEW DEVELOPMENT URL
  static const String profileBaseUrl = 'https://dev-econnect-sass.elsnerdev.co/'; /// Profile Image

  //static const String baseUrl = 'https://e-connect.elsner.com/v1/'; /// THIS LIVE URL
  // static const String profileBaseUrl = 'https://e-connect.elsner.com/public/'; /// Profile Image

  // static const String karmaBaseUrl = "https://dev-hrms.elsner.com/";
  static const String karmaBaseUrl = "https://hrms.elsner.com/";

  static const getAppVersion = "updateFCM_Mobile/get";

  /// End Point , Don't Change Belows End Point until didn't confirm through backend ///
  static const login = "auth/userLogin"; ///New Login End point
  static const googleSignIn = "user/googleSSOLginApp";
  static const allowGoogleSignIN = "user/alloawgoogleSSOLogin";
  static const updateStatus = "user/updateUserDetails"; ///New User update api end-point
  static const getUserById = "user/getUserDetails"; ///New Get UserDetails Api end-point
  static const favoriteListGet = "favouriteLists/get";
  static const String channelList="channelManage/getChannel";  ///New Get Channel List Api End-Point
  static const directMessageChatList = "chatList/get";
  static const createChannel = "channelManage/addChannel"; ///New Add Channel Api End-point
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
  static const addDeviceToken = "user/deviceToken";
  static const removeDeviceToken = "user/removeDeviceToken";
  static const sendKarma = "api/send-karma";
  // Chat

  static const getMessages = "messages/get-message";
  // static const readChannelMessage = "messages/channel/channel-message-seen/";
  // static const unReadChannelMessage = "channels/message-unread/";
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
  static const getUser = "user/getUsers";
  static String pinMessage(String messageId, bool pinned) => "messages/message-pin/$messageId/$pinned";
  static String reactMessage = "messages/message-reaction";
  static String removeReact = "messages/message-reaction-remove";

  // Channel
  static getChannelMembersList(String channelId) => "channels/getChannelMembers/$channelId";
  static addMembersToChannel(String channelId) => "channels/addMember/$channelId";
  static getChannelInfo(String channelId) => "channels/getChannel/$channelId";
  static readChannelMessage(String channelId) => "channelMessage/seenMessage/$channelId";
  static unReadChannelMessage(String channelId) => "channels/message-unread/$channelId";
  static const getChannelChat = "channelMessage/getMessages";
  static toggleAdminAndMember(String channelId) => "channels/toggleAdmin/$channelId";
  static removeMember(String channelId, String memberId) => "channels/removeMember/$channelId/$memberId";
  static renameChannel(String channelId) => "channels/update/$channelId";
  static const getFilesListingInChannelChat = "messages/channel/getFilesListingForChannel";
  static const getChannelPinnedMessage = "messages/channel/get-pinned-message-for-channel";

  ///New Delete Message Api End-point
  static deleteMessageFromChannel (String messageId) => "chatMessageAction/deleteMessage/$messageId";
  /// New Search Message Api End-Point
  static const searchMessages = "searchMessage/search";
  ///New Message Jump Api End-point
  static const messageJump = "chatMessage/getMessageJump";
  ///New Get Thread Unread List api
  static const getUnreadThread = "unreadThread/getUnreadThread";
  ///New Get Thread list account api
  static const getUnreadThreadCounts = "unreadThread/getUnreadThreadCount";
}